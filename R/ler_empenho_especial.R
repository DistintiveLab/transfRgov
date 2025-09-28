
#' @title Ler dados de Empenho Especial da API TransfereGov
#' @description Esta função acessa os dados do endpoint **empenho_especial** da API FundoaFundo
#' (TransfereGov) utilizando a função \code{pg.get} do pacote postgrestR.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato
#' "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' @param id_empenho_especial Identificador único do empenho especial (numérico).
#' @param numero_empenho Número do empenho (texto ou numérico).
#' @param ano_empenho Ano do empenho (numérico).
#' @param id_programa Identificador do programa especial ao qual o empenho está vinculado (numérico).
#' @param cnpj_favorecido_empenho CNPJ do favorecido do empenho (texto).
#' @param valor_empenho Valor do empenho (numérico).
#' @param data_emissao_empenho Data de emissão do empenho (formato YYYY-MM-DD).
#' @param tipo_empenho Tipo do empenho especial (texto).
#' @param situacao_empenho Situação do empenho (e.g., "Liquidado", "Pago") (texto).
#' @param ug_emitente_empenho Unidade gestora emitente do empenho (texto).
#' @param objeto_empenho Objeto do empenho (texto).
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente um data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: ler empenhos especiais do ano de 2023
#'   empenhos_especiais_2023 <- ler_empenho_especial(ano_empenho = 2023)
#'   head(empenhos_especiais_2023)
#'
#'   # Exemplo: ler empenhos especiais vinculados a um programa específico
#'   empenhos_de_programa <- ler_empenho_especial(id_programa = 12345, ano_empenho = 2022)
#'   head(empenhos_de_programa)
#' }
#'
#' @importFrom postgrestR pg.get
#' @export
ler_empenho_especial <- function(id_empenho_especial = NULL,
                                 numero_empenho = NULL,
                                 ano_empenho = NULL,
                                 id_programa = NULL,
                                 cnpj_favorecido_empenho = NULL,
                                 valor_empenho = NULL,
                                 data_emissao_empenho = NULL,
                                 tipo_empenho = NULL,
                                 situacao_empenho = NULL,
                                 ug_emitente_empenho = NULL,
                                 objeto_empenho = NULL) {

  table <- "empenho_especial" # Nome da tabela para o endpoint de Empenho Especial
  filters <- c()

  if (!is.null(id_empenho_especial))
    filters <- c(filters, paste0("id_empenho_especial=eq.", id_empenho_especial))
  if (!is.null(numero_empenho))
    filters <- c(filters, paste0("numero_empenho=eq.", numero_empenho))
  if (!is.null(ano_empenho))
    filters <- c(filters, paste0("ano_empenho=eq.", ano_empenho))
  if (!is.null(id_programa))
    filters <- c(filters, paste0("id_programa=eq.", id_programa))
  if (!is.null(cnpj_favorecido_empenho))
    filters <- c(filters, paste0("cnpj_favorecido_empenho=eq.", cnpj_favorecido_empenho))
  if (!is.null(valor_empenho))
    filters <- c(filters, paste0("valor_empenho=eq.", valor_empenho))
  if (!is.null(data_emissao_empenho))
    filters <- c(filters, paste0("data_emissao_empenho=eq.", data_emissao_empenho))
  if (!is.null(tipo_empenho))
    filters <- c(filters, paste0("tipo_empenho=eq.", tipo_empenho))
  if (!is.null(situacao_empenho))
    filters <- c(filters, paste0("situacao_empenho=eq.", situacao_empenho))
  if (!is.null(ug_emitente_empenho))
    filters <- c(filters, paste0("ug_emitente_empenho=eq.", ug_emitente_empenho))
  if (!is.null(objeto_empenho))
    filters <- c(filters, paste0("objeto_empenho=eq.", objeto_empenho))

  pg.get(table = table, filter = filters)
}
