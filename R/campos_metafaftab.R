#' Nomes possíveis dos parâmetros de controle do PostgREST
#'
#' Função interna que reúne os nomes que um endpoint aceita como parâmetro de
#' controle, e não como coluna da resposta. O \code{select} muda de nome em dois
#' endpoints (\code{/plano_acao} e \code{/relatorio_gestao_analise}), então as
#' duas formas são devolvidas e a filtragem com \code{\%in\%} mantém só a que
#' existe de fato.
#'
#' @param endpoint Caminho do endpoint, com a barra inicial.
#'
#' @return Um vetor de caracteres com os nomes dos parâmetros de controle.
#'
#' @keywords internal
#' @noRd
controles_postgrest <- function(endpoint) {
  fixos <- c("order", "range", "rangeUnit", "offset", "limit", "preferCount")

  c("select", fixos, paste0("select_", sub("^/", "", endpoint)))
}

#' Listar os campos aceitos por cada endpoint da API Fundo a Fundo
#'
#' @description
#' Acessor do conjunto de dados \code{\link{metafaftab}}. Transforma a lista
#' crua de caminhos e vetores em uma tabela de três colunas (\code{endpoint},
#' \code{campo} e \code{controle}) ou devolve apenas o vetor de campos de um
#' endpoint escolhido.
#'
#' @param endpoint Caminho de um endpoint, em texto. Pode ser informado com ou
#'   sem a barra inicial (\code{"/programa"} ou \code{"programa"}). Quando
#'   \code{NULL} (o padrão), a função descreve todos os endpoints.
#' @param incluir_controle Lógico. Cada endpoint aceita os parâmetros de controle
#'   do PostgREST (\code{order}, \code{range}, \code{rangeUnit}, \code{offset},
#'   \code{limit}, \code{preferCount} e \code{select}), que não são colunas da
#'   resposta e por isso ficam fora do resultado por padrão (\code{FALSE}). Com
#'   \code{TRUE} eles são incluídos e sinalizados pela coluna \code{controle}.
#'
#' @return
#' Com \code{endpoint = NULL}, um \code{data.frame} com as colunas
#' \code{endpoint} (caminho do endpoint), \code{campo} (nome do parâmetro) e
#' \code{controle} (lógico, indica se o campo é um parâmetro de controle do
#' PostgREST e não uma coluna). Com um \code{endpoint} informado, um vetor de
#' caracteres com os campos daquele endpoint, na ordem em que aparecem no
#' \code{metafaftab}.
#'
#' @details
#' A função é útil para descobrir os nomes válidos dos argumentos das funções
#' \code{ler_*}/\code{get_*} do pacote, que refletem os campos da API. Por
#' exemplo, \code{campos_metafaftab("empenho")} lista os filtros aceitos por
#' \code{\link{ler_empenho}}.
#'
#' Dos 21 endpoints, 19 expõem um \code{select} comum; \code{/plano_acao} expõe
#' \code{select_plano_acao} e \code{/relatorio_gestao_analise} expõe
#' \code{select_relatorio_gestao_analise}. Os demais seis controles aparecem nos
#' 21 endpoints, o que dá sete parâmetros de controle por endpoint.
#'
#' @seealso \code{\link{metafaftab}}
#'
#' @examples
#' head(campos_metafaftab())
#' campos_metafaftab("/programa")
#'
#' @export
campos_metafaftab <- function(endpoint = NULL, incluir_controle = FALSE) {
  if (!is.logical(incluir_controle) || length(incluir_controle) != 1L ||
      is.na(incluir_controle)) {
    stop("O par\u00e2metro 'incluir_controle' deve ser TRUE ou FALSE.")
  }

  dados <- get("metafaftab", envir = asNamespace("transfRgov"))
  caminhos <- names(dados)

  if (is.null(endpoint)) {
    por_endpoint <- lapply(caminhos, controles_postgrest)

    tabela <- data.frame(
      endpoint = rep(caminhos, lengths(dados)),
      campo = unlist(dados, use.names = FALSE),
      stringsAsFactors = FALSE
    )
    tabela$controle <- paste0(tabela$endpoint, "|", tabela$campo) %in%
      paste0(
        rep(caminhos, lengths(por_endpoint)), "|",
        unlist(por_endpoint, use.names = FALSE)
      )

    if (!incluir_controle) {
      tabela <- tabela[!tabela$controle, , drop = FALSE]
    }
    rownames(tabela) <- NULL

    return(tabela)
  }

  if (!is.character(endpoint) || length(endpoint) != 1L || is.na(endpoint)) {
    stop("O par\u00e2metro 'endpoint' deve ser um \u00fanico caminho de endpoint, em texto.")
  }

  chave <- if (startsWith(endpoint, "/")) endpoint else paste0("/", endpoint)

  if (!chave %in% caminhos) {
    stop("O par\u00e2metro 'endpoint' deve ser um dos ", length(dados),
         " caminhos listados em metafaftab, por exemplo \"/programa\".")
  }

  campos <- dados[[chave]]
  if (!incluir_controle) {
    campos <- campos[!campos %in% controles_postgrest(chave)]
  }

  campos
}
