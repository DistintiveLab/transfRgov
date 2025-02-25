#' Ler dados do endpoint empenho
#'
#' Esta função acessa os dados do endpoint **empenho** da API FundoaFundo (TransfereGov) utilizando a função
#' \code{pg.get} do pacote postgrestR. Em vez de incorporar o endpoint na URL, utiliza-se o parâmetro
#' \code{table = "empenho"} para especificar a tabela a ser consultada. Os filtros são aplicados por meio do
#' argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{id_empenho}}{Identificador do empenho (numérico).}
#'   \item{\code{numero_empenho}}{Número do empenho (texto ou numérico).}
#'   \item{\code{ano_empenho}}{Ano do empenho (numérico).}
#'   \item{\code{gestao_emitente_empenho}}{Gestão emitente do empenho (texto).}
#'   \item{\code{ug_emitente_empenho}}{Unidade gestora emitente do empenho (texto).}
#'   \item{\code{data_emissao_empenho}}{Data de emissão do empenho (formato YYYY-MM-DD).}
#'   \item{\code{fonte_recurso_empenho}}{Fonte de recurso do empenho (texto).}
#'   \item{\code{esfera_orcamentaria_empenho}}{Esfera orçamentária do empenho (texto).}
#'   \item{\code{descricao_esfera_orcamentaria_empenho}}{Descrição da esfera orçamentária (texto).}
#'   \item{\code{plano_interno_empenho}}{Plano interno do empenho (texto).}
#'   \item{\code{unidade_gestora_responsavel_empenho}}{Unidade gestora responsável pelo empenho (texto).}
#'   \item{\code{observacao_empenho}}{Observação sobre o empenho (texto).}
#'   \item{\code{cnpj_favorecido_empenho}}{CNPJ do favorecido do empenho (texto).}
#'   \item{\code{numero_lista_empenho}}{Número da lista do empenho (texto ou numérico).}
#'   \item{\code{unidade_gestora_referencia_empenho}}{Unidade gestora de referência do empenho (texto).}
#'   \item{\code{gestao_referencia_empenho}}{Gestão de referência do empenho (texto).}
#'   \item{\code{numero_interno_empenho}}{Número interno do empenho (texto ou numérico).}
#'   \item{\code{objeto_empenho}}{Objeto do empenho (texto).}
#'   \item{\code{numero_sistema_empenho}}{Número do sistema do empenho (texto ou numérico).}
#'   \item{\code{natureza_despesa_empenho}}{Natureza da despesa do empenho (texto).}
#'   \item{\code{natureza_despesa_sub_item_empenho}}{Subitem da natureza de despesa do empenho (texto).}
#'   \item{\code{tipo_empenho}}{Tipo do empenho (texto).}
#'   \item{\code{descricao_tipo_empenho}}{Descrição do tipo de empenho (texto).}
#'   \item{\code{codigo_tipo_nota_empenho}}{Código do tipo de nota do empenho (texto ou numérico).}
#'   \item{\code{descricao_tipo_nota_empenho}}{Descrição do tipo de nota do empenho (texto).}
#'   \item{\code{situacao_empenho}}{Situação do empenho (texto).}
#'   \item{\code{descricao_situacao_empenho}}{Descrição da situação do empenho (texto).}
#'   \item{\code{valor_empenho}}{Valor do empenho (numérico).}
#'   \item{\code{versao_empenho}}{Versão do empenho (texto ou numérico).}
#'   \item{\code{id_plano_acao}}{Identificador do plano de ação ao qual o empenho está vinculado (numérico).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: ler empenhos do ano de 2020 para um determinado plano de ação
#'   empenhos <- ler_empenho(ano_empenho = 2020, id_plano_acao = 1234)
#'   head(empenhos)
#' }
#'
#' @export
ler_empenho <- function(id_empenho = NULL,
                        numero_empenho = NULL,
                        ano_empenho = NULL,
                        gestao_emitente_empenho = NULL,
                        ug_emitente_empenho = NULL,
                        data_emissao_empenho = NULL,
                        fonte_recurso_empenho = NULL,
                        esfera_orcamentaria_empenho = NULL,
                        descricao_esfera_orcamentaria_empenho = NULL,
                        plano_interno_empenho = NULL,
                        unidade_gestora_responsavel_empenho = NULL,
                        observacao_empenho = NULL,
                        cnpj_favorecido_empenho = NULL,
                        numero_lista_empenho = NULL,
                        unidade_gestora_referencia_empenho = NULL,
                        gestao_referencia_empenho = NULL,
                        numero_interno_empenho = NULL,
                        objeto_empenho = NULL,
                        numero_sistema_empenho = NULL,
                        natureza_despesa_empenho = NULL,
                        natureza_despesa_sub_item_empenho = NULL,
                        tipo_empenho = NULL,
                        descricao_tipo_empenho = NULL,
                        codigo_tipo_nota_empenho = NULL,
                        descricao_tipo_nota_empenho = NULL,
                        situacao_empenho = NULL,
                        descricao_situacao_empenho = NULL,
                        valor_empenho = NULL,
                        versao_empenho = NULL,
                        id_plano_acao = NULL) {

  table <- "empenho"
  filters <- c()

  if (!is.null(id_empenho))
    filters <- c(filters, paste0("id_empenho=eq.", id_empenho))
  if (!is.null(numero_empenho))
    filters <- c(filters, paste0("numero_empenho=eq.", numero_empenho))
  if (!is.null(ano_empenho))
    filters <- c(filters, paste0("ano_empenho=eq.", ano_empenho))
  if (!is.null(gestao_emitente_empenho))
    filters <- c(filters, paste0("gestao_emitente_empenho=eq.", gestao_emitente_empenho))
  if (!is.null(ug_emitente_empenho))
    filters <- c(filters, paste0("ug_emitente_empenho=eq.", ug_emitente_empenho))
  if (!is.null(data_emissao_empenho))
    filters <- c(filters, paste0("data_emissao_empenho=eq.", data_emissao_empenho))
  if (!is.null(fonte_recurso_empenho))
    filters <- c(filters, paste0("fonte_recurso_empenho=eq.", fonte_recurso_empenho))
  if (!is.null(esfera_orcamentaria_empenho))
    filters <- c(filters, paste0("esfera_orcamentaria_empenho=eq.", esfera_orcamentaria_empenho))
  if (!is.null(descricao_esfera_orcamentaria_empenho))
    filters <- c(filters, paste0("descricao_esfera_orcamentaria_empenho=eq.", descricao_esfera_orcamentaria_empenho))
  if (!is.null(plano_interno_empenho))
    filters <- c(filters, paste0("plano_interno_empenho=eq.", plano_interno_empenho))
  if (!is.null(unidade_gestora_responsavel_empenho))
    filters <- c(filters, paste0("unidade_gestora_responsavel_empenho=eq.", unidade_gestora_responsavel_empenho))
  if (!is.null(observacao_empenho))
    filters <- c(filters, paste0("observacao_empenho=eq.", observacao_empenho))
  if (!is.null(cnpj_favorecido_empenho))
    filters <- c(filters, paste0("cnpj_favorecido_empenho=eq.", cnpj_favorecido_empenho))
  if (!is.null(numero_lista_empenho))
    filters <- c(filters, paste0("numero_lista_empenho=eq.", numero_lista_empenho))
  if (!is.null(unidade_gestora_referencia_empenho))
    filters <- c(filters, paste0("unidade_gestora_referencia_empenho=eq.", unidade_gestora_referencia_empenho))
  if (!is.null(gestao_referencia_empenho))
    filters <- c(filters, paste0("gestao_referencia_empenho=eq.", gestao_referencia_empenho))
  if (!is.null(numero_interno_empenho))
    filters <- c(filters, paste0("numero_interno_empenho=eq.", numero_interno_empenho))
  if (!is.null(objeto_empenho))
    filters <- c(filters, paste0("objeto_empenho=eq.", objeto_empenho))
  if (!is.null(numero_sistema_empenho))
    filters <- c(filters, paste0("numero_sistema_empenho=eq.", numero_sistema_empenho))
  if (!is.null(natureza_despesa_empenho))
    filters <- c(filters, paste0("natureza_despesa_empenho=eq.", natureza_despesa_empenho))
  if (!is.null(natureza_despesa_sub_item_empenho))
    filters <- c(filters, paste0("natureza_despesa_sub_item_empenho=eq.", natureza_despesa_sub_item_empenho))
  if (!is.null(tipo_empenho))
    filters <- c(filters, paste0("tipo_empenho=eq.", tipo_empenho))
  if (!is.null(descricao_tipo_empenho))
    filters <- c(filters, paste0("descricao_tipo_empenho=eq.", descricao_tipo_empenho))
  if (!is.null(codigo_tipo_nota_empenho))
    filters <- c(filters, paste0("codigo_tipo_nota_empenho=eq.", codigo_tipo_nota_empenho))
  if (!is.null(descricao_tipo_nota_empenho))
    filters <- c(filters, paste0("descricao_tipo_nota_empenho=eq.", descricao_tipo_nota_empenho))
  if (!is.null(situacao_empenho))
    filters <- c(filters, paste0("situacao_empenho=eq.", situacao_empenho))
  if (!is.null(descricao_situacao_empenho))
    filters <- c(filters, paste0("descricao_situacao_empenho=eq.", descricao_situacao_empenho))
  if (!is.null(valor_empenho))
    filters <- c(filters, paste0("valor_empenho=eq.", valor_empenho))
  if (!is.null(versao_empenho))
    filters <- c(filters, paste0("versao_empenho=eq.", versao_empenho))
  if (!is.null(id_plano_acao))
    filters <- c(filters, paste0("id_plano_acao=eq.", id_plano_acao))

  pg.get(table = table, filter = filters)
}
