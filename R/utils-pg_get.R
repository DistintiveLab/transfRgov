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

#' Codificar uma lista de colunas para uso em URL
#'
#' Função interna que codifica cada elemento de um vetor e reúne o resultado em
#' uma lista separada por vírgulas, formato esperado pelos parâmetros
#' \code{select} e \code{order} do PostgREST.
#'
#' @param valores Vetor de caracteres com os nomes das colunas.
#'
#' @return Uma única string com os valores codificados e separados por vírgula,
#'   ou \code{NULL} quando \code{valores} é vazio.
#'
#' @keywords internal
#' @noRd
pg_encode_lista <- function(valores) {
  if (is.null(valores) || length(valores) == 0) {
    return(NULL)
  }

  paste(
    utils::URLencode(as.character(valores), reserved = TRUE),
    collapse = ","
  )
}

#' Montar a URL de consulta no padrão PostgREST
#'
#' Função interna que combina o domínio, o nome da tabela, os filtros, os
#' parâmetros de paginação e as cláusulas de projeção e ordenação em uma única
#' URL de consulta.
#'
#' @param table Nome do endpoint (tabela) da API.
#' @param filter Vetor de caracteres com os filtros no formato
#'   \code{"campo=eq.valor"}. Os valores são codificados para uso em URL.
#' @param domain URL base da API.
#' @param limite Número máximo de linhas por página (\code{limit}). Quando
#'   \code{NULL}, o parâmetro não é enviado.
#' @param offset Número de linhas a ignorar antes da primeira linha
#'   (\code{offset}). Quando \code{NULL}, o parâmetro não é enviado.
#' @param select Vetor de caracteres com as colunas a projetar
#'   (\code{select}). Quando \code{NULL}, o parâmetro não é enviado.
#' @param order Vetor de caracteres com os critérios de ordenação
#'   (\code{order}). Quando \code{NULL}, o parâmetro não é enviado.
#'
#' @return Uma string com a URL da consulta.
#'
#' @keywords internal
#' @noRd
pg_build_url <- function(table, filter = character(), domain,
                         limite = NULL, offset = NULL,
                         select = NULL, order = NULL) {
  parametros <- pg_encode_filter(filter)

  if (!is.null(limite)) {
    parametros <- c(parametros, paste0("limit=", as.integer(limite)))
  }

  if (!is.null(offset)) {
    parametros <- c(parametros, paste0("offset=", as.integer(offset)))
  }

  if (!is.null(select)) {
    parametros <- c(parametros, paste0("select=", pg_encode_lista(select)))
  }

  if (!is.null(order)) {
    parametros <- c(parametros, paste0("order=", pg_encode_lista(order)))
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
    # Corpo vazio não é JSON válido e faria o `jsonlite` abortar. Como a API
    # devolve corpo vazio quando não há linhas, o caso é tratado como tal.
    if (!nzchar(trimws(conteudo))) {
      return(list(suportado = TRUE, dados = data.frame()))
    }

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

#' Sinalizar um aviso com classe de condição própria
#'
#' Função interna que emite um aviso acrescido de uma classe de condição
#' específica do pacote. Isso permite que o chamador trate o aviso de forma
#' seletiva, com \code{tryCatch()} ou \code{withCallingHandlers()}, sem
#' depender do texto da mensagem.
#'
#' @param mensagem Texto do aviso.
#' @param classe Classe da condição, sem o prefixo \code{"transfRgov_"}.
#'
#' @return Invisivelmente \code{NULL}. A função é chamada pelo efeito da
#'   sinalização do aviso.
#'
#' @keywords internal
#' @noRd
pg_warning <- function(mensagem, classe) {
  condicao <- structure(
    list(message = mensagem, call = NULL),
    class = c(paste0("transfRgov_", classe), "warning", "condition")
  )

  warning(condicao)

  invisible(NULL)
}

#' Identificar o pacote nas requisições HTTP
#'
#' Função interna que devolve o \code{User-Agent} enviado em cada requisição,
#' com o nome e a versão do pacote, além do repositório de origem.
#'
#' @return Uma string com o valor do \code{User-Agent}.
#'
#' @keywords internal
#' @noRd
pg_user_agent <- function() {
  versao <- tryCatch(
    as.character(utils::packageVersion("transfRgov")),
    error = function(e) "0.0.0"
  )

  paste0("transfRgov/", versao, " (https://github.com/DistintiveLab/transfRgov)")
}

#' Consultar um endpoint da API Fundo a Fundo
#'
#' Função interna que monta a URL de consulta no padrão PostgREST, executa a
#' requisição HTTP e converte a resposta em um \code{data.frame}. Quando a
#' resposta é tabular, a consulta é paginada com \code{limit} e \code{offset}
#' até que a última página seja alcançada, pois a API devolve no máximo 1000
#' linhas por requisição.
#'
#' Cada requisição é enviada com o \code{User-Agent} do pacote, com um tempo
#' limite próprio e com até \code{tentativas} tentativas, repetindo apenas
#' falhas de rede e respostas 429 ou 503. Erros HTTP definitivos, como o 400 de
#' um filtro inválido, são propagados imediatamente.
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
#'   é truncado, a função emite um aviso da classe
#'   \code{"transfRgov_partial_result"}.
#' @param tempo_limite Tempo limite, em segundos, de cada requisição HTTP.
#' @param tentativas Número máximo de tentativas por requisição. O valor precisa
#'   ser um inteiro maior ou igual a 1; \code{1} desativa as repetições.
#' @param select Vetor de caracteres com os nomes das colunas a serem
#'   retornadas. Quando \code{NULL} (padrão), todas as colunas do endpoint
#'   são retornadas.
#' @param order Vetor de caracteres com os critérios de ordenação, no formato
#'   \code{"coluna.asc"} ou \code{"coluna.desc"}. Quando \code{NULL}
#'   (padrão), a ordem definida pela API é mantida.
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
                   max_linhas = Inf,
                   tempo_limite = 30,
                   tentativas = 3L,
                   select = NULL,
                   order = NULL) {
  limite <- as.integer(limite)
  offset <- as.integer(offset)
  tentativas <- max(as.integer(tentativas), 1L)

  acumulado <- NULL
  parcial <- FALSE

  repeat {
    url <- pg_build_url(
      table, filter, domain,
      limite = limite, offset = offset, select = select, order = order
    )

    requisicao <- httr2::request(url)
    requisicao <- httr2::req_user_agent(requisicao, pg_user_agent())
    requisicao <- httr2::req_timeout(requisicao, tempo_limite)
    requisicao <- httr2::req_retry(requisicao, max_tries = tentativas)

    resposta <- httr2::req_perform(requisicao)

    # Um corpo vazio faz `httr2::resp_body_string()` falhar, então esse caso é
    # tratado como texto vazio, que é o que a API devolve quando não há linhas.
    conteudo <- if (length(resposta$body) == 0) {
      ""
    } else {
      httr2::resp_body_string(resposta, encoding = encoding)
    }

    tipo <- httr2::resp_content_type(resposta)

    if (length(tipo) != 1 || is.na(tipo)) {
      tipo <- ""
    }

    resultado <- pg_parse_response(tipo, conteudo)

    if (!resultado$suportado) {
      pg_warning(
        paste(tipo, "n\u00e3o \u00e9 suportado. Retornando o objeto de resposta."),
        "unsupported_type"
      )

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
    pg_warning(
      paste0("Resultado parcial: a consulta foi limitada a max_linhas = ", max_linhas, "."),
      "partial_result"
    )
  }

  acumulado
}
