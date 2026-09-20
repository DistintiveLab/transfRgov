#' Montar a URL de consulta no padrão PostgREST
#'
#' Função interna que combina o domínio, o nome da tabela e os filtros em uma
#' única URL de consulta.
#'
#' @param table Nome do endpoint (tabela) da API.
#' @param filter Vetor de caracteres com os filtros no formato
#'   \code{"campo=eq.valor"}.
#' @param domain URL base da API.
#'
#' @return Uma string com a URL da consulta.
#'
#' @keywords internal
#' @noRd
pg_build_url <- function(table, filter = character(), domain) {
  base_url <- paste0(domain, "/", table, "?")

  if (length(filter) > 0) {
    return(paste0(base_url, paste(filter, collapse = "&")))
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
    return(list(suportado = TRUE, dados = jsonlite::fromJSON(conteudo)))
  }

  if (grepl("csv", tipo, ignore.case = TRUE)) {
    return(list(suportado = TRUE, dados = utils::read.csv(text = conteudo)))
  }

  list(suportado = FALSE, dados = NULL)
}

#' Consultar um endpoint da API Fundo a Fundo
#'
#' Função interna que monta a URL de consulta no padrão PostgREST, executa a
#' requisição HTTP e converte a resposta em um \code{data.frame}.
#'
#' @param table Nome do endpoint (tabela) da API.
#' @param filter Vetor de caracteres com os filtros no formato
#'   \code{"campo=eq.valor"}.
#' @param domain URL base da API. Por padrão, a API Fundo a Fundo do
#'   TransfereGov.
#' @param encoding Codificação utilizada para ler a resposta.
#'
#' @return Um \code{data.frame} com o resultado da consulta.
#'
#' @keywords internal
#' @noRd
pg_get <- function(table,
                   filter = character(),
                   domain = "https://api.transferegov.gestao.gov.br/fundoafundo",
                   encoding = "UTF-8") {
  url <- pg_build_url(table, filter, domain)

  resposta <- httr::GET(url)
  httr::stop_for_status(resposta)

  conteudo <- httr::content(resposta, "text", encoding = encoding)
  tipo <- httr::headers(resposta)[["content-type"]]

  resultado <- pg_parse_response(tipo, conteudo)

  if (!resultado$suportado) {
    warning(paste(tipo, "n\u00e3o \u00e9 suportado. Retornando o objeto de resposta."))
    return(resposta)
  }

  resultado$dados
}
