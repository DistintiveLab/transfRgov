#' Obter dados do endpoint termo_adesao
#'
#' Esta função acessa os dados do endpoint **termo_adesao** da API FundoaFundo (TransfereGov)
#' utilizando a função \code{pg.get} do pacote postgrestR. Em vez de incorporar o endpoint na URL,
#' utiliza-se o parâmetro \code{table = "termo_adesao"} para especificar a tabela a ser consultada.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
#' Todos os parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{id_termo_adesao}}{Identificador do termo de adesão (numérico).}
#'   \item{\code{numero_processo_termo_adesao}}{Número do processo do termo de adesão (texto).}
#'   \item{\code{situacao_termo_adesao}}{Situação do termo de adesão (texto).}
#'   \item{\code{objeto_termo_adesao}}{Objeto do termo de adesão (texto).}
#'   \item{\code{data_assinatura_termo_adesao}}{Data de assinatura do termo de adesão (formato YYYY-MM-DD).}
#'   \item{\code{ano_termo_adesao}}{Ano do termo de adesão (numérico).}
#'   \item{\code{secao_publicacao_dou_termo_adesao}}{Seção da publicação no DOU do termo de adesão (texto).}
#'   \item{\code{pagina_publicacao_dou_termo_adesao}}{Página da publicação no DOU do termo de adesão (texto ou numérico).}
#'   \item{\code{data_publicacao_dou_termo_adesao}}{Data da publicação no DOU do termo de adesão (formato YYYY-MM-DD).}
#'   \item{\code{id_plano_acao}}{Identificador do plano de ação ao qual o termo de adesão está vinculado (numérico).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
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
                             id_plano_acao = NULL) {

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

  pg.get(table = table, filter = filters)
}
