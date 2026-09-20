#' Codificar os valores dos filtros PostgREST
#'
#' Função interna que codifica apenas o valor de cada filtro, preservando o
#' operador da consulta. Valores com espaço ou acento só são aceitos pela API
#' quando codificados.
#'
#' @param filter Vetor de caracteres com os filtros no formato
#'   \code{"campo=eq.valor"}.
#'
#' @return O vetor de filtros com os valores codificados para uso em URL.
#'
#' @keywords internal
#' @noRd
pg_encode_filter <- function(filter) {
  filter <- as.character(filter)

  vapply(filter, function(filtro) {
    separador <- regexpr("=", filtro, fixed = TRUE)

    if (separador < 1) {
      return(utils::URLencode(filtro, reserved = TRUE))
    }

    paste0(
      substr(filtro, 1, separador),
      utils::URLencode(substr(filtro, separador + 1, nchar(filtro)), reserved = TRUE)
    )
  }, character(1), USE.NAMES = FALSE)
}

#' Montar a URL de consulta no padrão PostgREST
#'
#' Função interna que combina o domínio, o nome da tabela, os filtros e os
#' parâmetros de paginação em uma única URL de consulta.
#'
#' @param table Nome do endpoint (tabela) da API.
#' @param filter Vetor de caracteres com os filtros no formato
#'   \code{"campo=eq.valor"}. Os valores são codificados para uso em URL.
#' @param domain URL base da API.
#' @param limite Número máximo de linhas por página (\code{limit}). Quando
#'   \code{NULL}, o parâmetro não é enviado.
#' @param offset Número de linhas a ignorar antes da primeira linha
#'   (\code{offset}). Quando \code{NULL}, o parâmetro não é enviado.
#'
#' @return Uma string com a URL da consulta.
#'
#' @keywords internal
#' @noRd
pg_build_url <- function(table, filter = character(), domain,
                         limite = NULL, offset = NULL) {
  parametros <- pg_encode_filter(filter)

  if (!is.null(limite)) {
    parametros <- c(parametros, paste0("limit=", as.integer(limite)))
  }

  if (!is.null(offset)) {
    parametros <- c(parametros, paste0("offset=", as.integer(offset)))
  }

  base_url <- paste0(domain, "/", table, "?")

  if (length(parametros) > 0) {
    return(paste0(base_url, paste(parametros, collapse = "&")))
  }

  base_url
}

#' Interpretar o corpo de uma resposta da API
#'
#' Função interna que converte o corpo da resposta de acordo com o
#' \code{content-type} informado, no formato JSON ou CSV.
#'
#' @param tipo O valor do cabeçalho \code{content-type} da resposta.
#' @param conteudo O corpo da resposta, já convertido para texto.
#'
#' @return Uma lista com os elementos \code{suportado} (lógico) e \code{dados}
#'   (o resultado da conversão, ou \code{NULL} quando o tipo não é suportado).
#'
#' @keywords internal
#' @noRd
pg_parse_response <- function(tipo, conteudo) {
  if (length(tipo) != 1 || is.na(tipo)) {
    tipo <- ""
  }

  if (grepl("json", tipo, ignore.case = TRUE)) {
    dados <- jsonlite::fromJSON(conteudo)

    # Uma lista vazia na API devolve `[]`, que o jsonlite converte em `list()`.
    # O contrato da função pede um data.frame, então o resultado é normalizado.
    if (length(dados) == 0) {
      dados <- data.frame()
    }

    return(list(suportado = TRUE, dados = dados))
  }

  if (grepl("csv", tipo, ignore.case = TRUE)) {
    dados <- readr::read_delim(
      I(conteudo),
      delim = ",",
      locale = readr::locale(encoding = "UTF-8"),
      show_col_types = FALSE
    )

    return(list(suportado = TRUE, dados = janitor::clean_names(dados)))
  }

  list(suportado = FALSE, dados = NULL)
}

#' Consultar um endpoint da API Fundo a Fundo
#'
#' Função interna que monta a URL de consulta no padrão PostgREST, executa a
#' requisição HTTP e converte a resposta em um \code{data.frame}. Quando a
#' resposta é tabular, a consulta é paginada com \code{limit} e \code{offset}
#' até que a última página seja alcançada, pois a API devolve no máximo 1000
#' linhas por requisição.
#'
#' @param table Nome do endpoint (tabela) da API.
#' @param filter Vetor de caracteres com os filtros no formato
#'   \code{"campo=eq.valor"}.
#' @param domain URL base da API. Por padrão, a API Fundo a Fundo do
#'   TransfereGov.
#' @param encoding Codificação utilizada para ler a resposta.
#' @param limite Número máximo de linhas por página (\code{limit}). O padrão
#'   \code{1000} é o tamanho máximo de página aceito pela API.
#' @param offset Número de linhas a ignorar antes da primeira linha
#'   (\code{offset}) da primeira página.
#' @param paginar Lógico. Quando \code{TRUE} (padrão), percorre todas as páginas
#'   até o fim dos dados. Quando \code{FALSE}, devolve apenas a primeira página.
#' @param max_linhas Teto de segurança de linhas acumuladas. Quando o resultado
#'   é truncado, a função emite um aviso.
#'
#' @return Um \code{data.frame} com o resultado da consulta.
#'
#' @keywords internal
#' @noRd
pg_get <- function(table,
                   filter = character(),
                   domain = "https://api.transferegov.gestao.gov.br/fundoafundo",
                   encoding = "UTF-8",
                   limite = 1000L,
                   offset = 0L,
                   paginar = TRUE,
                   max_linhas = Inf) {
  limite <- as.integer(limite)
  offset <- as.integer(offset)

  acumulado <- NULL
  parcial <- FALSE

  repeat {
    url <- pg_build_url(table, filter, domain, limite = limite, offset = offset)

    resposta <- httr::GET(url)
    httr::stop_for_status(resposta)

    conteudo <- httr::content(resposta, "text", encoding = encoding)
    tipo <- httr::headers(resposta)[["content-type"]]

    resultado <- pg_parse_response(tipo, conteudo)

    if (!resultado$suportado) {
      warning(paste(tipo, "n\u00e3o \u00e9 suportado. Retornando o objeto de resposta."))
      return(resposta)
    }

    lote <- resultado$dados

    # Respostas não tabulares são devolvidas na primeira chamada.
    if (!is.data.frame(lote) || !isTRUE(paginar)) {
      if (is.null(acumulado)) {
        return(lote)
      }

      break
    }

    acumulado <- if (is.null(acumulado)) lote else rbind(acumulado, lote)

    linhas <- nrow(lote)

    # Última página: a API devolve menos linhas do que o limite pedido.
    if (linhas < limite || linhas == 0) {
      break
    }

    if (nrow(acumulado) >= max_linhas) {
      parcial <- TRUE
      break
    }

    offset <- offset + linhas
  }

  if (nrow(acumulado) > max_linhas) {
    parcial <- TRUE
    acumulado <- acumulado[seq_len(max_linhas), , drop = FALSE]
  }

  if (parcial) {
    warning("Resultado parcial: a consulta foi limitada a max_linhas = ", max_linhas, ".")
  }

  acumulado
}
