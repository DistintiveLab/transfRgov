#' Obter dados do endpoint plano_acao_analise
#'
#' Esta função acessa os dados do endpoint **plano_acao_analise** da API FundoaFundo (TransfereGov)
#' utilizando a função interna \code{pg_get}. Em vez de incorporar o endpoint na URL, utiliza-se
#' o parâmetro \code{table = "plano_acao_analise"} para especificar a tabela a ser consultada. Os filtros
#' são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
#' Todos os parâmetros são opcionais.
#'
#' @param id_analise_plano_acao Identificador da análise do plano de ação (numérico).
#' @param tipo_analise_plano_acao Tipo da análise do plano de ação (texto).
#' @param tipo_analise_resultado_plano_acao Tipo do resultado da análise do plano de ação (texto).
#' @param data_analise_plano_acao Data da análise do plano de ação (formato YYYY-MM-DD).
#' @param parecer_analise_plano_acao Parecer da análise do plano de ação (texto).
#' @param tipo_origem_analise_plano_acao Tipo de origem da análise do plano de ação (texto).
#' @param id_plano_acao Identificador do plano de ação ao qual a análise está vinculada (numérico).
#' @param id_historico_plano_acao Identificador do histórico do plano de ação (numérico).
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: consultar análises de plano de ação para um plano específico
#'   analise <- ler_plano_acao_analise(id_plano_acao = 1234)
#'   head(analise)
#' }
#'
#' @export
ler_plano_acao_analise <- function(id_analise_plano_acao = NULL,
                                   tipo_analise_plano_acao = NULL,
                                   tipo_analise_resultado_plano_acao = NULL,
                                   data_analise_plano_acao = NULL,
                                   parecer_analise_plano_acao = NULL,
                                   tipo_origem_analise_plano_acao = NULL,
                                   id_plano_acao = NULL,
                                   id_historico_plano_acao = NULL) {

  table <- "plano_acao_analise"
  filters <- c()

  if (!is.null(id_analise_plano_acao))
    filters <- c(filters, paste0("id_analise_plano_acao=eq.", id_analise_plano_acao))
  if (!is.null(tipo_analise_plano_acao))
    filters <- c(filters, paste0("tipo_analise_plano_acao=eq.", tipo_analise_plano_acao))
  if (!is.null(tipo_analise_resultado_plano_acao))
    filters <- c(filters, paste0("tipo_analise_resultado_plano_acao=eq.", tipo_analise_resultado_plano_acao))
  if (!is.null(data_analise_plano_acao))
    filters <- c(filters, paste0("data_analise_plano_acao=eq.", data_analise_plano_acao))
  if (!is.null(parecer_analise_plano_acao))
    filters <- c(filters, paste0("parecer_analise_plano_acao=eq.", parecer_analise_plano_acao))
  if (!is.null(tipo_origem_analise_plano_acao))
    filters <- c(filters, paste0("tipo_origem_analise_plano_acao=eq.", tipo_origem_analise_plano_acao))
  if (!is.null(id_plano_acao))
    filters <- c(filters, paste0("id_plano_acao=eq.", id_plano_acao))
  if (!is.null(id_historico_plano_acao))
    filters <- c(filters, paste0("id_historico_plano_acao=eq.", id_historico_plano_acao))

  pg_get(table = table, filter = filters)
}
