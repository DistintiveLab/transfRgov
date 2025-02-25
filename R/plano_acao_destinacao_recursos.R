#' Obter dados do endpoint plano_acao_destinacao_recursos
#'
#' Esta função acessa os dados do endpoint **plano_acao_destinacao_recursos** da API FundoaFundo (TransfereGov)
#' utilizando a função \code{pg.get} do pacote postgrestR. Em vez de incorporar o endpoint na URL, utiliza-se
#' o parâmetro \code{table = "plano_acao_destinacao_recursos"} para especificar a tabela a ser consultada. Os filtros
#' são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor". Todos os
#' parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{id_destinacao_recursos_plano_acao}}{Identificador da destinacão de recursos do plano de ação (numérico).}
#'   \item{\code{codigo_natureza_despesa_destinacao_recursos_plano_acao}}{Código da natureza de despesa (texto ou numérico).}
#'   \item{\code{descricao_natureza_despesa_destinacao_recursos_plano_acao}}{Descrição da natureza de despesa (texto).}
#'   \item{\code{tipo_despesa_destinacao_recursos_plano_acao}}{Tipo de despesa da destinacão de recursos (texto).}
#'   \item{\code{valor_destinacao_recursos_plano_acao}}{Valor destinado (numérico).}
#'   \item{\code{id_plano_acao}}{Identificador do plano de ação ao qual a destinacão de recursos está vinculada (numérico).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: consultar destinacões de recursos para um determinado plano de ação
#'   dest_recursos <- get_plano_acao_destinacao_recursos(id_plano_acao = 1234)
#'   head(dest_recursos)
#' }
#'
#' @export
get_plano_acao_destinacao_recursos <- function(id_destinacao_recursos_plano_acao = NULL,
                                               codigo_natureza_despesa_destinacao_recursos_plano_acao = NULL,
                                               descricao_natureza_despesa_destinacao_recursos_plano_acao = NULL,
                                               tipo_despesa_destinacao_recursos_plano_acao = NULL,
                                               valor_destinacao_recursos_plano_acao = NULL,
                                               id_plano_acao = NULL) {

  table <- "plano_acao_destinacao_recursos"
  filters <- c()

  if (!is.null(id_destinacao_recursos_plano_acao))
    filters <- c(filters, paste0("id_destinacao_recursos_plano_acao=eq.", id_destinacao_recursos_plano_acao))
  if (!is.null(codigo_natureza_despesa_destinacao_recursos_plano_acao))
    filters <- c(filters, paste0("codigo_natureza_despesa_destinacao_recursos_plano_acao=eq.", codigo_natureza_despesa_destinacao_recursos_plano_acao))
  if (!is.null(descricao_natureza_despesa_destinacao_recursos_plano_acao))
    filters <- c(filters, paste0("descricao_natureza_despesa_destinacao_recursos_plano_acao=eq.", descricao_natureza_despesa_destinacao_recursos_plano_acao))
  if (!is.null(tipo_despesa_destinacao_recursos_plano_acao))
    filters <- c(filters, paste0("tipo_despesa_destinacao_recursos_plano_acao=eq.", tipo_despesa_destinacao_recursos_plano_acao))
  if (!is.null(valor_destinacao_recursos_plano_acao))
    filters <- c(filters, paste0("valor_destinacao_recursos_plano_acao=eq.", valor_destinacao_recursos_plano_acao))
  if (!is.null(id_plano_acao))
    filters <- c(filters, paste0("id_plano_acao=eq.", id_plano_acao))

  pg.get(table = table, filter = filters)
}
