#' @name municipios_siafi_ibge
#' @aliases municipios_siafi_ibge
#' @docType data
#' @title IBGE e SIAFI Lista de IDs
#'
#' @description
#' %%  ~~ A concise (1-5 lines) description of the dataset. ~~
#'
#' @usage data("municipios_siafi_ibge")
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
#' %%  ~~ Harmonization for IBGE ~~
#'
#' @source
#' %%  ~~ reference to a publication or URL from which the data were obtained ~~
#'
#' @references
#' %%  ~~ possibly secondary sources and usages ~~
#'
#' @examples
#' data(municipios_siafi_ibge)
#' ## maybe str(municipios_siafi_ibge) ; plot(municipios_siafi_ibge) ...
#'
#' @keywords datasets
#' @keywords ibge
#' @keywords siafi
#' @keywords cnpj
NULL
