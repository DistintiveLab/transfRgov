#' Obter dados do endpoint termo_adesao_historico
#'
#' Esta função acessa os dados do endpoint **termo_adesao_historico** da API FundoaFundo (TransfereGov)
#' utilizando a função interna \code{pg_get}. Em vez de incorporar o endpoint na URL,
#' utiliza-se o parâmetro \code{table = "termo_adesao_historico"} para especificar a tabela a ser consultada.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
#' Todos os parâmetros são opcionais.
#'
#' @param id_historico_termo_adesao Identificador do histórico do termo de adesão (numérico).
#' @param situacao_historico_termo_adesao Situação do histórico do termo de adesão (texto).
#' @param data_historico_termo_adesao Data do histórico do termo de adesão (formato YYYY-MM-DD).
#' @param id_termo_adesao Identificador do termo de adesão ao qual o histórico está vinculado (numérico).
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
#'   # Exemplo: consultar o histórico de um termo de adesão específico
#'   historico <- ler_termo_adesao_historico(id_termo_adesao = 1234)
#'   head(historico)
#' }
#'
#' @export
ler_termo_adesao_historico <- function(id_historico_termo_adesao = NULL,
                                       situacao_historico_termo_adesao = NULL,
                                       data_historico_termo_adesao = NULL,
                                       id_termo_adesao = NULL,
                                       select = NULL,
                                       order = NULL) {

  table <- "termo_adesao_historico"
  filters <- c()

  if (!is.null(id_historico_termo_adesao))
    filters <- c(filters, paste0("id_historico_termo_adesao=eq.", id_historico_termo_adesao))
  if (!is.null(situacao_historico_termo_adesao))
    filters <- c(filters, paste0("situacao_historico_termo_adesao=eq.", situacao_historico_termo_adesao))
  if (!is.null(data_historico_termo_adesao))
    filters <- c(filters, paste0("data_historico_termo_adesao=eq.", data_historico_termo_adesao))
  if (!is.null(id_termo_adesao))
    filters <- c(filters, paste0("id_termo_adesao=eq.", id_termo_adesao))

  pg_get(table = table, filter = filters, select = select, order = order)
}
