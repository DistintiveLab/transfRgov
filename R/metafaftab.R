#' Metadados dos endpoints da API Fundo a Fundo
#'
#' @name metafaftab
#' @aliases metafaftab
#' @docType data
#' @title Parâmetros aceitos por cada endpoint da API Fundo a Fundo
#'
#' @description
#' Lista nomeada que associa o caminho de cada endpoint da API Fundo a Fundo
#' (TransfereGov) ao vetor com os nomes dos parâmetros aceitos por aquele
#' endpoint. Os nomes da lista são os caminhos dos endpoints (por exemplo,
#' \code{"/programa"}) e cada elemento é um vetor de caracteres.
#'
#' @usage metafaftab
#'
#' @format
#'  A list with 21 elements, each a character vector whose length varies
#'  according to the number of parameters of the endpoint.
#'  \describe{
#'    \item{\code{/programa}}{vetor com os parâmetros do endpoint de programas}
#'    \item{\code{/plano_acao}}{vetor com os parâmetros do endpoint de planos de ação}
#'    \item{\code{/empenho}}{vetor com os parâmetros do endpoint de empenhos}
#'    \item{...}{demais endpoints da API}
#'  }
#'
#' @details
#' A lista é obtida a partir da especificação OpenAPI publicada pela própria
#' API. Ela serve de referência para descobrir os nomes válidos dos parâmetros
#' de filtro aceitos por cada função \code{ler_*}/\code{get_*} do pacote.
#'
#' @source
#' Especificação OpenAPI da API Fundo a Fundo, em
#' \code{https://api.transferegov.gestao.gov.br/fundoafundo/}
#' (o servidor responde apenas a requisições \code{GET}).
#'
#' @references
#' Documentação do TransfereGov:
#' \url{https://www.gov.br/transferegov/pt-br}
#'
#' @examples
#' names(metafaftab)
#' metafaftab[["/programa"]]
#'
#' @keywords datasets
#' @keywords transferegov
#' @keywords api
NULL
