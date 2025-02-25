#' Ler dados do endpoint relatorio_gestao
#'
#' @export
ler_relatorio_gestao <- function(id_relatorio_gestao = NULL,
                                 data_relatorio_gestao = NULL,
                                 data_e_hora_relatorio_gestao = NULL,
                                 tipo_relatorio_gestao = NULL,
                                 situacao_relatorio_gestao = NULL,
                                 valor_executado_relatorio_gestao = NULL,
                                 valor_pendente_relatorio_gestao = NULL,
                                 resultados_alcancados_metas_relatorio_gestao = NULL,
                                 descritivo_relatorio_gestao = NULL,
                                 contrapartida_relatorio_gestao = NULL,
                                 endereco_eletronico_publicidade_acoes_relatorio_gestao = NULL,
                                 declaracao_conformidade_relatorio_gestao = NULL,
                                 id_plano_acao = NULL) {

  table <- "relatorio_gestao"
  filters <- c()

  if (!is.null(id_relatorio_gestao))
    filters <- c(filters, paste0("id_relatorio_gestao=eq.", id_relatorio_gestao))
  if (!is.null(data_relatorio_gestao))
    filters <- c(filters, paste0("data_relatorio_gestao=eq.", data_relatorio_gestao))
  if (!is.null(data_e_hora_relatorio_gestao))
    filters <- c(filters, paste0("data_e_hora_relatorio_gestao=eq.", data_e_hora_relatorio_gestao))
  if (!is.null(tipo_relatorio_gestao))
    filters <- c(filters, paste0("tipo_relatorio_gestao=eq.", tipo_relatorio_gestao))
  if (!is.null(situacao_relatorio_gestao))
    filters <- c(filters, paste0("situacao_relatorio_gestao=eq.", situacao_relatorio_gestao))
  if (!is.null(valor_executado_relatorio_gestao))
    filters <- c(filters, paste0("valor_executado_relatorio_gestao=eq.", valor_executado_relatorio_gestao))
  if (!is.null(valor_pendente_relatorio_gestao))
    filters <- c(filters, paste0("valor_pendente_relatorio_gestao=eq.", valor_pendente_relatorio_gestao))
  if (!is.null(resultados_alcancados_metas_relatorio_gestao))
    filters <- c(filters, paste0("resultados_alcancados_metas_relatorio_gestao=eq.", resultados_alcancados_metas_relatorio_gestao))
  if (!is.null(descritivo_relatorio_gestao))
    filters <- c(filters, paste0("descritivo_relatorio_gestao=eq.", descritivo_relatorio_gestao))
  if (!is.null(contrapartida_relatorio_gestao))
    filters <- c(filters, paste0("contrapartida_relatorio_gestao=eq.", contrapartida_relatorio_gestao))
  if (!is.null(endereco_eletronico_publicidade_acoes_relatorio_gestao))
    filters <- c(filters, paste0("endereco_eletronico_publicidade_acoes_relatorio_gestao=eq.", endereco_eletronico_publicidade_acoes_relatorio_gestao))
  if (!is.null(declaracao_conformidade_relatorio_gestao))
    filters <- c(filters, paste0("declaracao_conformidade_relatorio_gestao=eq.", declaracao_conformidade_relatorio_gestao))
  if (!is.null(id_plano_acao))
    filters <- c(filters, paste0("id_plano_acao=eq.", id_plano_acao))

  pg.get(table = table, filter = filters)
}
