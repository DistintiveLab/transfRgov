#' Obter dados do endpoint plano_acao_historico
#'
#' Esta função acessa os dados do endpoint **plano_acao_historico** da API FundoaFundo (TransfereGov)
#' utilizando a função interna \code{pg_get}. Em vez de incorporar o endpoint na URL, utiliza-se
#' o parâmetro \code{table = "plano_acao_historico"} para especificar a tabela a ser consultada. Os filtros
#' são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
#' Todos os parâmetros são opcionais.
#'
#' @param id_historico_plano_acao Identificador do histórico do plano de ação (numérico).
#' @param situacao_historico_plano_acao Situação do histórico do plano de ação (texto).
#' @param data_historico_plano_acao Data do histórico do plano de ação (formato YYYY-MM-DD).
#' @param versao_historico_plano_acao Versão do histórico do plano de ação (texto ou numérico).
#' @param id_plano_acao Identificador do plano de ação ao qual o histórico está vinculado (numérico).
#'
#' @param select Vetor de caracteres com os nomes das colunas a serem
#'   retornadas. Quando \code{NULL} (padrão), todas as colunas do endpoint
#'   são retornadas.
#' @param order Vetor de caracteres com os critérios de ordenação, no formato
#'   \code{"coluna.asc"} ou \code{"coluna.desc"}. Quando \code{NULL}
#'   (padrão), a ordem definida pela API é mantida.
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \donttest{
#'   # Exemplo: consultar o histórico de um plano de ação específico
#'   historico <- get_plano_acao_historico(id_plano_acao = 1234)
#'   head(historico)
#' }
#'
#' @export
get_plano_acao_historico <- function(id_historico_plano_acao = NULL,
                                     situacao_historico_plano_acao = NULL,
                                     data_historico_plano_acao = NULL,
                                     versao_historico_plano_acao = NULL,
                                     id_plano_acao = NULL,
                                     select = NULL,
                                     order = NULL) {

  table <- "plano_acao_historico"
  filters <- c()

  if (!is.null(id_historico_plano_acao))
    filters <- c(filters, paste0("id_historico_plano_acao=eq.", id_historico_plano_acao))
  if (!is.null(situacao_historico_plano_acao))
    filters <- c(filters, paste0("situacao_historico_plano_acao=eq.", situacao_historico_plano_acao))
  if (!is.null(data_historico_plano_acao))
    filters <- c(filters, paste0("data_historico_plano_acao=eq.", data_historico_plano_acao))
  if (!is.null(versao_historico_plano_acao))
    filters <- c(filters, paste0("versao_historico_plano_acao=eq.", versao_historico_plano_acao))
  if (!is.null(id_plano_acao))
    filters <- c(filters, paste0("id_plano_acao=eq.", id_plano_acao))

  pg_get(table = table, filter = filters, select = select, order = order)
}
