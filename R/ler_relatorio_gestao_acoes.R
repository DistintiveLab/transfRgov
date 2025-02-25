#' Ler dados do endpoint relatorio_gestao_acoes
#'
#' @export
ler_relatorio_gestao_acoes <- function(id_acao_relatorio_gestao = NULL,
                                       percentual_execucao_fisica_acao_relatorio_gestao_acao = NULL,
                                       observacoes_justificativas_relatorio_gestao_acao = NULL,
                                       id_relatorio_gestao = NULL,
                                       id_acao_meta_plano_acao = NULL) {
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

  pg.get(table = table, filter = filters)
}
