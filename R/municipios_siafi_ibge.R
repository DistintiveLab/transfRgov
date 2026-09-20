#' Mapeamento entre códigos de município SIAFI e IBGE
#'
#' @name municipios_siafi_ibge
#' @aliases municipios_siafi_ibge
#' @docType data
#' @title IBGE e SIAFI Lista de IDs
#'
#' @description
#' Tabela de correspondência entre os códigos de município utilizados pelo
#' SIAFI e os códigos de município do IBGE, com o nome do município, a unidade
#' da federação e o CNPJ da prefeitura. Os dados são extraídos do arquivo
#' \code{tabmun.csv} publicado pelo Tesouro Transparente.
#'
#' @usage municipios_siafi_ibge
#'
#' @format
#'  A data frame with 5589 observations on the following 5 variables.
#'  \describe{
#'    \item{\code{codigo_municipio_siafi}}{a character vector with 4 digit SIAFI code}
#'    \item{\code{cnpj}}{a character vector of business fiscal CNPJ code}
#'    \item{\code{nome_municipio}}{a character vector with city name}
#'    \item{\code{uf}}{a character vector of UF 2 char abbreviation}
#'    \item{\code{codigo_ibge}}{a numeric vector with City's IBGE Code}
#'  }
#'
#' @details
#' O código SIAFI é mantido como texto para preservar os zeros à esquerda, que
#' são significativos. As junções entre os dados do Portal da Transparência e
#' este mapeamento devem sempre ser feitas pela coluna
#' \code{codigo_municipio_siafi}, e não pela coluna \code{cnpj}.
#'
#' @source
#' Tesouro Transparente, arquivo \code{tabmun.csv}:
#' \url{https://www.tesourotransparente.gov.br/}
#'
#' @references
#' Portal da Transparência do Governo Federal:
#' \url{https://portaldatransparencia.gov.br/}
#'
#' @examples
#' str(municipios_siafi_ibge)
#' head(municipios_siafi_ibge)
#'
#' @keywords datasets
#' @keywords ibge
#' @keywords siafi
#' @keywords cnpj
NULL
