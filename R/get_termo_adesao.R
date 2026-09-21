#' Obter dados do endpoint termo_adesao
#'
#' Esta função acessa os dados do endpoint **termo_adesao** da API FundoaFundo (TransfereGov)
#' utilizando a função interna \code{pg_get}. Em vez de incorporar o endpoint na URL,
#' utiliza-se o parâmetro \code{table = "termo_adesao"} para especificar a tabela a ser consultada.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
#' Todos os parâmetros são opcionais.
#'
#' @param id_termo_adesao Identificador do termo de adesão (numérico).
#' @param numero_processo_termo_adesao Número do processo do termo de adesão (texto).
#' @param situacao_termo_adesao Situação do termo de adesão (texto).
#' @param objeto_termo_adesao Objeto do termo de adesão (texto).
#' @param data_assinatura_termo_adesao Data de assinatura do termo de adesão (formato YYYY-MM-DD).
#' @param ano_termo_adesao Ano do termo de adesão (numérico).
#' @param secao_publicacao_dou_termo_adesao Seção da publicação no DOU do termo de adesão (texto).
#' @param pagina_publicacao_dou_termo_adesao Página da publicação no DOU do termo de adesão (texto ou numérico).
#' @param data_publicacao_dou_termo_adesao Data da publicação no DOU do termo de adesão (formato YYYY-MM-DD).
#' @param id_plano_acao Identificador do plano de ação ao qual o termo de adesão está vinculado (numérico).
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
#'   # Exemplo: consultar termos de adesão para um plano de ação específico
#'   termo <- get_termo_adesao(id_plano_acao = 1234)
#'   head(termo)
#' }
#'
#' @export
get_termo_adesao <- function(id_termo_adesao = NULL,
                             numero_processo_termo_adesao = NULL,
                             situacao_termo_adesao = NULL,
                             objeto_termo_adesao = NULL,
                             data_assinatura_termo_adesao = NULL,
                             ano_termo_adesao = NULL,
                             secao_publicacao_dou_termo_adesao = NULL,
                             pagina_publicacao_dou_termo_adesao = NULL,
                             data_publicacao_dou_termo_adesao = NULL,
                             id_plano_acao = NULL,
                             select = NULL,
                             order = NULL) {

  table <- "termo_adesao"
  filters <- c()

  if (!is.null(id_termo_adesao))
    filters <- c(filters, paste0("id_termo_adesao=eq.", id_termo_adesao))
  if (!is.null(numero_processo_termo_adesao))
    filters <- c(filters, paste0("numero_processo_termo_adesao=eq.", numero_processo_termo_adesao))
  if (!is.null(situacao_termo_adesao))
    filters <- c(filters, paste0("situacao_termo_adesao=eq.", situacao_termo_adesao))
  if (!is.null(objeto_termo_adesao))
    filters <- c(filters, paste0("objeto_termo_adesao=eq.", objeto_termo_adesao))
  if (!is.null(data_assinatura_termo_adesao))
    filters <- c(filters, paste0("data_assinatura_termo_adesao=eq.", data_assinatura_termo_adesao))
  if (!is.null(ano_termo_adesao))
    filters <- c(filters, paste0("ano_termo_adesao=eq.", ano_termo_adesao))
  if (!is.null(secao_publicacao_dou_termo_adesao))
    filters <- c(filters, paste0("secao_publicacao_dou_termo_adesao=eq.", secao_publicacao_dou_termo_adesao))
  if (!is.null(pagina_publicacao_dou_termo_adesao))
    filters <- c(filters, paste0("pagina_publicacao_dou_termo_adesao=eq.", pagina_publicacao_dou_termo_adesao))
  if (!is.null(data_publicacao_dou_termo_adesao))
    filters <- c(filters, paste0("data_publicacao_dou_termo_adesao=eq.", data_publicacao_dou_termo_adesao))
  if (!is.null(id_plano_acao))
    filters <- c(filters, paste0("id_plano_acao=eq.", id_plano_acao))

  pg_get(table = table, filter = filters, select = select, order = order)
}
