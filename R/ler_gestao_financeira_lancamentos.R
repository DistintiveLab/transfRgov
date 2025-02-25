#' Obter dados do endpoint gestao_financeira_lancamentos
#'
#' Esta função acessa os dados do endpoint **gestao_financeira_lancamentos** da API FundoaFundo (TransfereGov)
#' utilizando a função \code{pg.get} do pacote postgrestR. Em vez de incorporar o endpoint na URL, utiliza-se
#' o parâmetro \code{table = "gestao_financeira_lancamentos"} para especificar a tabela a ser consultada.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
#' Todos os parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{id_lancamento_gestao_financeira}}{Identificador do lançamento (numérico).}
#'   \item{\code{origem_solicitacao_gestao_financeira}}{Origem da solicitação (texto).}
#'   \item{\code{descricao_origem_solicitacao_gestao_financeira}}{Descrição da origem da solicitação (texto).}
#'   \item{\code{cnpj_ente_solicitante_gestao_financeira}}{CNPJ do ente solicitante (texto).}
#'   \item{\code{nome_ente_solicitante_gestao_financeira}}{Nome do ente solicitante (texto).}
#'   \item{\code{nome_personalizado_ente_solicitante_gestao_financeira}}{Nome personalizado do ente solicitante (texto).}
#'   \item{\code{codigo_programa_agil_ente_solicitante_gestao_financeira}}{Código do programa ágil do ente solicitante (texto).}
#'   \item{\code{codigo_banco_gestao_financeira}}{Código do banco (texto ou numérico).}
#'   \item{\code{codigo_agencia_gestao_financeira}}{Código da agência (texto ou numérico).}
#'   \item{\code{dv_agencia_gestao_financeira}}{Dígito verificador da agência (texto).}
#'   \item{\code{codigo_conta_gestao_financeira}}{Código da conta (texto ou numérico).}
#'   \item{\code{dv_conta_gestao_financeira}}{Dígito verificador da conta (texto).}
#'   \item{\code{tipo_operacao_gestao_financeira}}{Tipo de operação (texto).}
#'   \item{\code{descricao_tipo_operacao_gestao_financeira}}{Descrição do tipo de operação (texto).}
#'   \item{\code{descricao_gestao_financeira}}{Descrição da gestão financeira (texto).}
#'   \item{\code{data_lancamento_gestao_financeira}}{Data do lançamento (formato YYYY-MM-DD).}
#'   \item{\code{data_evento_lancamento_gestao_financeira}}{Data do evento do lançamento (formato YYYY-MM-DD).}
#'   \item{\code{numero_ordem_gestao_financeira}}{Número da ordem (numérico).}
#'   \item{\code{numero_referencia_unica_gestao_financeira}}{Número de referência única (texto ou numérico).}
#'   \item{\code{tipo_favorecido_gestao_financeira}}{Tipo de favorecido (texto).}
#'   \item{\code{descricao_tipo_favorecido_gestao_financeira}}{Descrição do tipo de favorecido (texto).}
#'   \item{\code{doc_favorecido_gestao_financeira_mask}}{Documento do favorecido (texto mascarado).}
#'   \item{\code{nome_favorecido_gestao_financeira}}{Nome do favorecido (texto).}
#'   \item{\code{codigo_banco_favorecido_gestao_financeira}}{Código do banco do favorecido (texto ou numérico).}
#'   \item{\code{codigo_agencia_favorecido_gestao_financeira}}{Código da agência do favorecido (texto ou numérico).}
#'   \item{\code{dv_agencia_favorecido_gestao_financeira}}{Dígito verificador da agência do favorecido (texto).}
#'   \item{\code{codigo_conta_favorecido_gestao_financeira}}{Código da conta do favorecido (texto ou numérico).}
#'   \item{\code{dv_conta_favorecido_gestao_financeira}}{Dígito verificador da conta do favorecido (texto).}
#'   \item{\code{valor_lancamento_gestao_financeira}}{Valor do lançamento (numérico).}
#'   \item{\code{id_categoria_despesa_gestao_financeira}}{Identificador da categoria de despesa (numérico).}
#'   \item{\code{quantidade_subtransacoes_lancamento_gestao_financeira}}{Quantidade de subtransações (numérico).}
#'   \item{\code{id_agencia_conta}}{Identificador da agência/conta (numérico).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: consultar lançamentos de gestão financeira para um determinado ente solicitante
#'   lancamentos <- ler_gestao_financeira_lancamentos(cnpj_ente_solicitante_gestao_financeira = "12.345.678/0001-99")
#'   head(lancamentos)
#' }
#'
#' @export
ler_gestao_financeira_lancamentos <- function(id_lancamento_gestao_financeira = NULL,
                                              origem_solicitacao_gestao_financeira = NULL,
                                              descricao_origem_solicitacao_gestao_financeira = NULL,
                                              cnpj_ente_solicitante_gestao_financeira = NULL,
                                              nome_ente_solicitante_gestao_financeira = NULL,
                                              nome_personalizado_ente_solicitante_gestao_financeira = NULL,
                                              codigo_programa_agil_ente_solicitante_gestao_financeira = NULL,
                                              codigo_banco_gestao_financeira = NULL,
                                              codigo_agencia_gestao_financeira = NULL,
                                              dv_agencia_gestao_financeira = NULL,
                                              codigo_conta_gestao_financeira = NULL,
                                              dv_conta_gestao_financeira = NULL,
                                              tipo_operacao_gestao_financeira = NULL,
                                              descricao_tipo_operacao_gestao_financeira = NULL,
                                              descricao_gestao_financeira = NULL,
                                              data_lancamento_gestao_financeira = NULL,
                                              data_evento_lancamento_gestao_financeira = NULL,
                                              numero_ordem_gestao_financeira = NULL,
                                              numero_referencia_unica_gestao_financeira = NULL,
                                              tipo_favorecido_gestao_financeira = NULL,
                                              descricao_tipo_favorecido_gestao_financeira = NULL,
                                              doc_favorecido_gestao_financeira_mask = NULL,
                                              nome_favorecido_gestao_financeira = NULL,
                                              codigo_banco_favorecido_gestao_financeira = NULL,
                                              codigo_agencia_favorecido_gestao_financeira = NULL,
                                              dv_agencia_favorecido_gestao_financeira = NULL,
                                              codigo_conta_favorecido_gestao_financeira = NULL,
                                              dv_conta_favorecido_gestao_financeira = NULL,
                                              valor_lancamento_gestao_financeira = NULL,
                                              id_categoria_despesa_gestao_financeira = NULL,
                                              quantidade_subtransacoes_lancamento_gestao_financeira = NULL,
                                              id_agencia_conta = NULL) {

  table <- "gestao_financeira_lancamentos"
  filters <- c()

  if (!is.null(id_lancamento_gestao_financeira))
    filters <- c(filters, paste0("id_lancamento_gestao_financeira=eq.", id_lancamento_gestao_financeira))
  if (!is.null(origem_solicitacao_gestao_financeira))
    filters <- c(filters, paste0("origem_solicitacao_gestao_financeira=eq.", origem_solicitacao_gestao_financeira))
  if (!is.null(descricao_origem_solicitacao_gestao_financeira))
    filters <- c(filters, paste0("descricao_origem_solicitacao_gestao_financeira=eq.", descricao_origem_solicitacao_gestao_financeira))
  if (!is.null(cnpj_ente_solicitante_gestao_financeira))
    filters <- c(filters, paste0("cnpj_ente_solicitante_gestao_financeira=eq.", cnpj_ente_solicitante_gestao_financeira))
  if (!is.null(nome_ente_solicitante_gestao_financeira))
    filters <- c(filters, paste0("nome_ente_solicitante_gestao_financeira=eq.", nome_ente_solicitante_gestao_financeira))
  if (!is.null(nome_personalizado_ente_solicitante_gestao_financeira))
    filters <- c(filters, paste0("nome_personalizado_ente_solicitante_gestao_financeira=eq.", nome_personalizado_ente_solicitante_gestao_financeira))
  if (!is.null(codigo_programa_agil_ente_solicitante_gestao_financeira))
    filters <- c(filters, paste0("codigo_programa_agil_ente_solicitante_gestao_financeira=eq.", codigo_programa_agil_ente_solicitante_gestao_financeira))
  if (!is.null(codigo_banco_gestao_financeira))
    filters <- c(filters, paste0("codigo_banco_gestao_financeira=eq.", codigo_banco_gestao_financeira))
  if (!is.null(codigo_agencia_gestao_financeira))
    filters <- c(filters, paste0("codigo_agencia_gestao_financeira=eq.", codigo_agencia_gestao_financeira))
  if (!is.null(dv_agencia_gestao_financeira))
    filters <- c(filters, paste0("dv_agencia_gestao_financeira=eq.", dv_agencia_gestao_financeira))
  if (!is.null(codigo_conta_gestao_financeira))
    filters <- c(filters, paste0("codigo_conta_gestao_financeira=eq.", codigo_conta_gestao_financeira))
  if (!is.null(dv_conta_gestao_financeira))
    filters <- c(filters, paste0("dv_conta_gestao_financeira=eq.", dv_conta_gestao_financeira))
  if (!is.null(tipo_operacao_gestao_financeira))
    filters <- c(filters, paste0("tipo_operacao_gestao_financeira=eq.", tipo_operacao_gestao_financeira))
  if (!is.null(descricao_tipo_operacao_gestao_financeira))
    filters <- c(filters, paste0("descricao_tipo_operacao_gestao_financeira=eq.", descricao_tipo_operacao_gestao_financeira))
  if (!is.null(descricao_gestao_financeira))
    filters <- c(filters, paste0("descricao_gestao_financeira=eq.", descricao_gestao_financeira))
  if (!is.null(data_lancamento_gestao_financeira))
    filters <- c(filters, paste0("data_lancamento_gestao_financeira=eq.", data_lancamento_gestao_financeira))
  if (!is.null(data_evento_lancamento_gestao_financeira))
    filters <- c(filters, paste0("data_evento_lancamento_gestao_financeira=eq.", data_evento_lancamento_gestao_financeira))
  if (!is.null(numero_ordem_gestao_financeira))
    filters <- c(filters, paste0("numero_ordem_gestao_financeira=eq.", numero_ordem_gestao_financeira))
  if (!is.null(numero_referencia_unica_gestao_financeira))
    filters <- c(filters, paste0("numero_referencia_unica_gestao_financeira=eq.", numero_referencia_unica_gestao_financeira))
  if (!is.null(tipo_favorecido_gestao_financeira))
    filters <- c(filters, paste0("tipo_favorecido_gestao_financeira=eq.", tipo_favorecido_gestao_financeira))
  if (!is.null(descricao_tipo_favorecido_gestao_financeira))
    filters <- c(filters, paste0("descricao_tipo_favorecido_gestao_financeira=eq.", descricao_tipo_favorecido_gestao_financeira))
  if (!is.null(doc_favorecido_gestao_financeira_mask))
    filters <- c(filters, paste0("doc_favorecido_gestao_financeira_mask=eq.", doc_favorecido_gestao_financeira_mask))
  if (!is.null(nome_favorecido_gestao_financeira))
    filters <- c(filters, paste0("nome_favorecido_gestao_financeira=eq.", nome_favorecido_gestao_financeira))
  if (!is.null(codigo_banco_favorecido_gestao_financeira))
    filters <- c(filters, paste0("codigo_banco_favorecido_gestao_financeira=eq.", codigo_banco_favorecido_gestao_financeira))
  if (!is.null(codigo_agencia_favorecido_gestao_financeira))
    filters <- c(filters, paste0("codigo_agencia_favorecido_gestao_financeira=eq.", codigo_agencia_favorecido_gestao_financeira))
  if (!is.null(dv_agencia_favorecido_gestao_financeira))
    filters <- c(filters, paste0("dv_agencia_favorecido_gestao_financeira=eq.", dv_agencia_favorecido_gestao_financeira))
  if (!is.null(codigo_conta_favorecido_gestao_financeira))
    filters <- c(filters, paste0("codigo_conta_favorecido_gestao_financeira=eq.", codigo_conta_favorecido_gestao_financeira))
  if (!is.null(dv_conta_favorecido_gestao_financeira))
    filters <- c(filters, paste0("dv_conta_favorecido_gestao_financeira=eq.", dv_conta_favorecido_gestao_financeira))
  if (!is.null(valor_lancamento_gestao_financeira))
    filters <- c(filters, paste0("valor_lancamento_gestao_financeira=eq.", valor_lancamento_gestao_financeira))
  if (!is.null(id_categoria_despesa_gestao_financeira))
    filters <- c(filters, paste0("id_categoria_despesa_gestao_financeira=eq.", id_categoria_despesa_gestao_financeira))
  if (!is.null(quantidade_subtransacoes_lancamento_gestao_financeira))
    filters <- c(filters, paste0("quantidade_subtransacoes_lancamento_gestao_financeira=eq.", quantidade_subtransacoes_lancamento_gestao_financeira))
  if (!is.null(id_agencia_conta))
    filters <- c(filters, paste0("id_agencia_conta=eq.", id_agencia_conta))

  pg.get(table = table, filter = filters)
}
