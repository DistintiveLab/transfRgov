#' Obter dados do endpoint gestao_financeira_subtransacoes
#'
#' Esta função acessa os dados do endpoint **gestao_financeira_subtransacoes** da API FundoaFundo (TransfereGov)
#' utilizando a função interna \code{pg_get}. Em vez de inserir o endpoint na URL, utiliza-se o parâmetro
#' \code{table = "gestao_financeira_subtransacoes"} para especificar a tabela a ser consultada. Os filtros são aplicados
#' por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' @param id_subtransacao_gestao_financeira Identificador da subtransação (numérico).
#' @param estado_subtransacao_gestao_financeira Estado da subtransação (texto).
#' @param situacao_pagamento_subtransacao_gestao_financeira Situação do pagamento (texto).
#' @param descricao_situacao_pagamento_subtransacao_gestao_financeira Descrição da situação de pagamento (texto).
#' @param data_pagamento_subtransacao_gestao_financeira Data de pagamento (formato YYYY-MM-DD).
#' @param tipo_pessoa_beneficiario_subtransacao_gestao_financeira Tipo de pessoa beneficiária (texto).
#' @param descricao_tipo_pessoa_beneficiario_subtransacao_gestao_financei Descrição do tipo de pessoa beneficiária (texto).
#' @param numero_documento_beneficiario_subtransacao_gestao_financeira_ma Número do documento do beneficiário (texto).
#' @param nome_beneficiario_subtransacao_gestao_financeira Nome do beneficiário (texto).
#' @param codigo_banco_beneficiario_subtransacao_gestao_financeira Código do banco do beneficiário (texto ou numérico).
#' @param codigo_agencia_beneficiario_subtransacao_gestao_financeira Código da agência do beneficiário (texto ou numérico).
#' @param codigo_conta_beneficiario_subtransacao_gestao_financeira Código da conta do beneficiário (texto ou numérico).
#' @param descricao_subtransacao_gestao_financeira Descrição da subtransação (texto).
#' @param valor_subtransacao_gestao_financeira Valor da subtransação (numérico).
#' @param id_categoria_despesa_gestao_financeira Identificador da categoria de despesa (numérico).
#' @param id_lancamento_gestao_financeira Identificador do lançamento de gestão financeira (numérico).
#' @param data_evento_lancamento_gestao_financeira Data do evento do lançamento (formato YYYY-MM-DD).
#' @param numero_ordem_gestao_financeira Número da ordem (numérico).
#' @param numero_referencia_unica_gestao_financeira Número de referência única (texto ou numérico).
#' @param tipo_favorecido_gestao_financeira Tipo de favorecido (texto).
#' @param descricao_tipo_favorecido_gestao_financeira Descrição do tipo de favorecido (texto).
#' @param doc_favorecido_gestao_financeira_mask Documento do favorecido (texto mascarado).
#' @param nome_favorecido_gestao_financeira Nome do favorecido (texto).
#' @param codigo_banco_favorecido_gestao_financeira Código do banco do favorecido (texto ou numérico).
#' @param codigo_agencia_favorecido_gestao_financeira Código da agência do favorecido (texto ou numérico).
#' @param dv_agencia_favorecido_gestao_financeira Dígito verificador da agência do favorecido (texto).
#' @param codigo_conta_favorecido_gestao_financeira Código da conta do favorecido (texto ou numérico).
#' @param dv_conta_favorecido_gestao_financeira Dígito verificador da conta do favorecido (texto).
#' @param valor_lancamento_gestao_financeira Valor do lançamento (numérico).
#' @param quantidade_subtransacoes_lancamento_gestao_financeira Quantidade de subtransações (numérico).
#' @param id_agencia_conta Identificador da agência/conta (numérico).
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
#' \dontrun{
#'   # Exemplo: consultar subtransações para um lançamento de gestão financeira específico
#'   subtransacoes <- ler_gestao_financeira_subtransacoes(id_lancamento_gestao_financeira = 1234)
#'   head(subtransacoes)
#' }
#'
#' @export
ler_gestao_financeira_subtransacoes <- function(
    id_subtransacao_gestao_financeira = NULL,
    estado_subtransacao_gestao_financeira = NULL,
    situacao_pagamento_subtransacao_gestao_financeira = NULL,
    descricao_situacao_pagamento_subtransacao_gestao_financeira = NULL,
    data_pagamento_subtransacao_gestao_financeira = NULL,
    tipo_pessoa_beneficiario_subtransacao_gestao_financeira = NULL,
    descricao_tipo_pessoa_beneficiario_subtransacao_gestao_financei = NULL,
    numero_documento_beneficiario_subtransacao_gestao_financeira_ma = NULL,
    nome_beneficiario_subtransacao_gestao_financeira = NULL,
    codigo_banco_beneficiario_subtransacao_gestao_financeira = NULL,
    codigo_agencia_beneficiario_subtransacao_gestao_financeira = NULL,
    codigo_conta_beneficiario_subtransacao_gestao_financeira = NULL,
    descricao_subtransacao_gestao_financeira = NULL,
    valor_subtransacao_gestao_financeira = NULL,
    id_categoria_despesa_gestao_financeira = NULL,
    id_lancamento_gestao_financeira = NULL,
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
    quantidade_subtransacoes_lancamento_gestao_financeira = NULL,
    id_agencia_conta = NULL,
    select = NULL,
    order = NULL
) {
  table <- "gestao_financeira_subtransacoes"
  filters <- c()

  if (!is.null(id_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("id_subtransacao_gestao_financeira=eq.", id_subtransacao_gestao_financeira))
  if (!is.null(estado_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("estado_subtransacao_gestao_financeira=eq.", estado_subtransacao_gestao_financeira))
  if (!is.null(situacao_pagamento_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("situacao_pagamento_subtransacao_gestao_financeira=eq.", situacao_pagamento_subtransacao_gestao_financeira))
  if (!is.null(descricao_situacao_pagamento_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("descricao_situacao_pagamento_subtransacao_gestao_financeira=eq.", descricao_situacao_pagamento_subtransacao_gestao_financeira))
  if (!is.null(data_pagamento_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("data_pagamento_subtransacao_gestao_financeira=eq.", data_pagamento_subtransacao_gestao_financeira))
  if (!is.null(tipo_pessoa_beneficiario_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("tipo_pessoa_beneficiario_subtransacao_gestao_financeira=eq.", tipo_pessoa_beneficiario_subtransacao_gestao_financeira))
  if (!is.null(descricao_tipo_pessoa_beneficiario_subtransacao_gestao_financei))
    filters <- c(filters, paste0("descricao_tipo_pessoa_beneficiario_subtransacao_gestao_financei=eq.", descricao_tipo_pessoa_beneficiario_subtransacao_gestao_financei))
  if (!is.null(numero_documento_beneficiario_subtransacao_gestao_financeira_ma))
    filters <- c(filters, paste0("numero_documento_beneficiario_subtransacao_gestao_financeira_ma=eq.", numero_documento_beneficiario_subtransacao_gestao_financeira_ma))
  if (!is.null(nome_beneficiario_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("nome_beneficiario_subtransacao_gestao_financeira=eq.", nome_beneficiario_subtransacao_gestao_financeira))
  if (!is.null(codigo_banco_beneficiario_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("codigo_banco_beneficiario_subtransacao_gestao_financeira=eq.", codigo_banco_beneficiario_subtransacao_gestao_financeira))
  if (!is.null(codigo_agencia_beneficiario_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("codigo_agencia_beneficiario_subtransacao_gestao_financeira=eq.", codigo_agencia_beneficiario_subtransacao_gestao_financeira))
  if (!is.null(codigo_conta_beneficiario_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("codigo_conta_beneficiario_subtransacao_gestao_financeira=eq.", codigo_conta_beneficiario_subtransacao_gestao_financeira))
  if (!is.null(descricao_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("descricao_subtransacao_gestao_financeira=eq.", descricao_subtransacao_gestao_financeira))
  if (!is.null(valor_subtransacao_gestao_financeira))
    filters <- c(filters, paste0("valor_subtransacao_gestao_financeira=eq.", valor_subtransacao_gestao_financeira))
  if (!is.null(id_categoria_despesa_gestao_financeira))
    filters <- c(filters, paste0("id_categoria_despesa_gestao_financeira=eq.", id_categoria_despesa_gestao_financeira))
  if (!is.null(id_lancamento_gestao_financeira))
    filters <- c(filters, paste0("id_lancamento_gestao_financeira=eq.", id_lancamento_gestao_financeira))
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
  if (!is.null(quantidade_subtransacoes_lancamento_gestao_financeira))
    filters <- c(filters, paste0("quantidade_subtransacoes_lancamento_gestao_financeira=eq.", quantidade_subtransacoes_lancamento_gestao_financeira))
  if (!is.null(id_agencia_conta))
    filters <- c(filters, paste0("id_agencia_conta=eq.", id_agencia_conta))

  pg_get(table = table, filter = filters, select = select, order = order)
}
