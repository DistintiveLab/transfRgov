#' Obter dados do endpoint gestao_financeira_categorias_despesa
#'
#' Esta função acessa os dados do endpoint **gestao_financeira_categorias_despesa** da API FundoaFundo (TransfereGov)
#' utilizando a função \code{pg.get} do pacote postgrestR. Em vez de incorporar o endpoint na URL, utiliza-se
#' o parâmetro \code{table = "gestao_financeira_categorias_despesa"} para especificar a tabela a ser consultada.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
#' Todos os parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{id_categoria_despesa_gestao_financeira}}{Identificador da categoria de despesa (numérico).}
#'   \item{\code{id_nivel_pai_categoria_despesa_gestao_financeira}}{Identificador do nível pai da categoria de despesa (numérico).}
#'   \item{\code{nome_nivel_atual_categoria_despesa_gestao_financeira}}{Nome do nível atual da categoria de despesa (texto).}
#'   \item{\code{nivel_atual_categoria_despesa_gestao_financeira}}{Nível atual da categoria de despesa (texto ou numérico).}
#'   \item{\code{nome_completo_niveis_categoria_despesa_gestao_financeira}}{Nome completo dos níveis da categoria de despesa (texto).}
#'   \item{\code{codigo_programa_agil}}{Código do programa ágil associado (texto ou numérico).}
#'   \item{\code{nome_programa_agil}}{Nome do programa ágil associado (texto).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: consultar categorias de despesa para um programa ágil específico
#'   categorias <- ler_gestao_financeira_categorias_despesa(codigo_programa_agil = "001", nome_programa_agil = "Programa Exemplo")
#'   head(categorias)
#' }
#'
#' @export
ler_gestao_financeira_categorias_despesa <- function(
    id_categoria_despesa_gestao_financeira = NULL,
    id_nivel_pai_categoria_despesa_gestao_financeira = NULL,
    nome_nivel_atual_categoria_despesa_gestao_financeira = NULL,
    nivel_atual_categoria_despesa_gestao_financeira = NULL,
    nome_completo_niveis_categoria_despesa_gestao_financeira = NULL,
    codigo_programa_agil = NULL,
    nome_programa_agil = NULL
) {
  table <- "gestao_financeira_categorias_despesa"
  filters <- c()

  if (!is.null(id_categoria_despesa_gestao_financeira))
    filters <- c(filters, paste0("id_categoria_despesa_gestao_financeira=eq.", id_categoria_despesa_gestao_financeira))
  if (!is.null(id_nivel_pai_categoria_despesa_gestao_financeira))
    filters <- c(filters, paste0("id_nivel_pai_categoria_despesa_gestao_financeira=eq.", id_nivel_pai_categoria_despesa_gestao_financeira))
  if (!is.null(nome_nivel_atual_categoria_despesa_gestao_financeira))
    filters <- c(filters, paste0("nome_nivel_atual_categoria_despesa_gestao_financeira=eq.", nome_nivel_atual_categoria_despesa_gestao_financeira))
  if (!is.null(nivel_atual_categoria_despesa_gestao_financeira))
    filters <- c(filters, paste0("nivel_atual_categoria_despesa_gestao_financeira=eq.", nivel_atual_categoria_despesa_gestao_financeira))
  if (!is.null(nome_completo_niveis_categoria_despesa_gestao_financeira))
    filters <- c(filters, paste0("nome_completo_niveis_categoria_despesa_gestao_financeira=eq.", nome_completo_niveis_categoria_despesa_gestao_financeira))
  if (!is.null(codigo_programa_agil))
    filters <- c(filters, paste0("codigo_programa_agil=eq.", codigo_programa_agil))
  if (!is.null(nome_programa_agil))
    filters <- c(filters, paste0("nome_programa_agil=eq.", nome_programa_agil))

  pg.get(table = table, filter = filters)
}
