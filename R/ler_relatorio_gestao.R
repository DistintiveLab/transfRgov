#' @title Ler dados de Relatório de Gestão da API TransfereGov
#'
#' @description Esta função acessa os dados do endpoint **relatorio_gestao** da API FundoaFundo
#' (TransfereGov) utilizando a função interna \code{pg_get}.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato
#' "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' @param id_relatorio_gestao Identificador único do relatório de gestão (numérico).
#' @param data_relatorio_gestao Data do relatório de gestão (formato YYYY-MM-DD).
#' @param data_e_hora_relatorio_gestao Data e hora do relatório de gestão (texto).
#' @param tipo_relatorio_gestao Tipo do relatório de gestão (texto).
#' @param situacao_relatorio_gestao Situação do relatório de gestão (texto).
#' @param valor_executado_relatorio_gestao Valor executado informado no relatório de gestão (numérico).
#' @param valor_pendente_relatorio_gestao Valor pendente informado no relatório de gestão (numérico).
#' @param resultados_alcancados_metas_relatorio_gestao Resultados alcançados em relação às metas (texto).
#' @param descritivo_relatorio_gestao Texto descritivo do relatório de gestão (texto).
#' @param contrapartida_relatorio_gestao Contrapartida informada no relatório de gestão (texto).
#' @param endereco_eletronico_publicidade_acoes_relatorio_gestao Endereço eletrônico de publicidade das ações (texto).
#' @param declaracao_conformidade_relatorio_gestao Declaração de conformidade do relatório de gestão (texto).
#' @param id_plano_acao Identificador do plano de ação associado (numérico).
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
#' \donttest{
#'   # Exemplo: ler relatórios de gestão vinculados a um plano de ação
#'   relatorios <- ler_relatorio_gestao(id_plano_acao = 12345)
#'   head(relatorios)
#' }
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
                                 id_plano_acao = NULL,
                                 select = NULL,
                                 order = NULL) {

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

  pg_get(table = table, filter = filters, select = select, order = order)
}
