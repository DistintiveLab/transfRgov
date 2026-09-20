#' @title Ler dados de Ações do Relatório de Gestão da API TransfereGov
#'
#' @description Esta função acessa os dados do endpoint **relatorio_gestao_acoes** da API FundoaFundo
#' (TransfereGov) utilizando a função interna \code{pg_get}.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato
#' "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' @param id_acao_relatorio_gestao Identificador único da ação do relatório de gestão (numérico).
#' @param percentual_execucao_fisica_acao_relatorio_gestao_acao Percentual de execução física da ação (numérico).
#' @param observacoes_justificativas_relatorio_gestao_acao Observações e justificativas da ação (texto).
#' @param id_relatorio_gestao Identificador do relatório de gestão associado (numérico).
#' @param id_acao_meta_plano_acao Identificador da ação/meta do plano de ação associado (numérico).
#'
#' @param select Vetor de caracteres com os nomes das colunas a serem
#'   retornadas. Quando \code{NULL} (padrão), todas as colunas do endpoint
#'   são retornadas.
#' @param order Vetor de caracteres com os critérios de ordenação, no formato
#'   \code{"coluna.asc"} ou \code{"coluna.desc"}. Quando \code{NULL}
#'   (padrão), a ordem definida pela API é mantida.
#' @return Um objeto contendo os dados retornados pela API (geralmente um data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: ler ações vinculadas a um relatório de gestão
#'   acoes <- ler_relatorio_gestao_acoes(id_relatorio_gestao = 12345)
#'   head(acoes)
#' }
#'
#' @export
ler_relatorio_gestao_acoes <- function(id_acao_relatorio_gestao = NULL,
                                       percentual_execucao_fisica_acao_relatorio_gestao_acao = NULL,
                                       observacoes_justificativas_relatorio_gestao_acao = NULL,
                                       id_relatorio_gestao = NULL,
                                       id_acao_meta_plano_acao = NULL,
                                       select = NULL,
                                       order = NULL) {
  table <- "relatorio_gestao_acoes"
  filters <- c()

  if (!is.null(id_acao_relatorio_gestao))
    filters <- c(filters, paste0("id_acao_relatorio_gestao=eq.", id_acao_relatorio_gestao))
  if (!is.null(percentual_execucao_fisica_acao_relatorio_gestao_acao))
    filters <- c(filters, paste0("percentual_execucao_fisica_acao_relatorio_gestao_acao=eq.", percentual_execucao_fisica_acao_relatorio_gestao_acao))
  if (!is.null(observacoes_justificativas_relatorio_gestao_acao))
    filters <- c(filters, paste0("observacoes_justificativas_relatorio_gestao_acao=eq.", observacoes_justificativas_relatorio_gestao_acao))
  if (!is.null(id_relatorio_gestao))
    filters <- c(filters, paste0("id_relatorio_gestao=eq.", id_relatorio_gestao))
  if (!is.null(id_acao_meta_plano_acao))
    filters <- c(filters, paste0("id_acao_meta_plano_acao=eq.", id_acao_meta_plano_acao))

  pg_get(table = table, filter = filters, select = select, order = order)
}
