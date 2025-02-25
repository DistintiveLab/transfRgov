#' Obter dados do endpoint plano_acao_meta
#'
#' Esta função acessa os dados do endpoint **plano_acao_meta** da API FundoaFundo (TransfereGov)
#' utilizando a função \code{pg.get} do pacote postgrestR. Em vez de incorporar o endpoint na URL,
#' utiliza-se o parâmetro \code{table = "plano_acao_meta"} para especificar a tabela a ser consultada.
#'
#' Os filtros são aplicados por meio do argumento \code{filter} da \code{pg.get}. Para cada parâmetro informado,
#' é criada uma condição no formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{id_meta_plano_acao}}{Identificador da meta do plano de ação (numérico).}
#'   \item{\code{numero_meta_plano_acao}}{Número da meta do plano de ação (texto ou numérico).}
#'   \item{\code{nome_meta_plano_acao}}{Nome da meta do plano de ação (texto).}
#'   \item{\code{descricao_meta_plano_acao}}{Descrição da meta do plano de ação (texto).}
#'   \item{\code{valor_meta_plano_acao}}{Valor da meta do plano de ação (numérico).}
#'   \item{\code{versao_meta_plano_acao}}{Versão da meta do plano de ação (texto ou numérico).}
#'   \item{\code{sequencial_meta_plano_acao}}{Sequencial da meta do plano de ação (numérico).}
#'   \item{\code{id_plano_acao}}{Identificador do plano de ação ao qual a meta está vinculada (numérico).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: consultar metas de plano de ação para um plano específico
#'   meta <- ler_plano_acao_meta(id_plano_acao = 1234)
#'   head(meta)
#' }
#'
#' @export
ler_plano_acao_meta <- function(id_meta_plano_acao = NULL,
                                numero_meta_plano_acao = NULL,
                                nome_meta_plano_acao = NULL,
                                descricao_meta_plano_acao = NULL,
                                valor_meta_plano_acao = NULL,
                                versao_meta_plano_acao = NULL,
                                sequencial_meta_plano_acao = NULL,
                                id_plano_acao = NULL) {

  table <- "plano_acao_meta"
  filters <- c()

  if (!is.null(id_meta_plano_acao))
    filters <- c(filters, paste0("id_meta_plano_acao=eq.", id_meta_plano_acao))
  if (!is.null(numero_meta_plano_acao))
    filters <- c(filters, paste0("numero_meta_plano_acao=eq.", numero_meta_plano_acao))
  if (!is.null(nome_meta_plano_acao))
    filters <- c(filters, paste0("nome_meta_plano_acao=eq.", nome_meta_plano_acao))
  if (!is.null(descricao_meta_plano_acao))
    filters <- c(filters, paste0("descricao_meta_plano_acao=eq.", descricao_meta_plano_acao))
  if (!is.null(valor_meta_plano_acao))
    filters <- c(filters, paste0("valor_meta_plano_acao=eq.", valor_meta_plano_acao))
  if (!is.null(versao_meta_plano_acao))
    filters <- c(filters, paste0("versao_meta_plano_acao=eq.", versao_meta_plano_acao))
  if (!is.null(sequencial_meta_plano_acao))
    filters <- c(filters, paste0("sequencial_meta_plano_acao=eq.", sequencial_meta_plano_acao))
  if (!is.null(id_plano_acao))
    filters <- c(filters, paste0("id_plano_acao=eq.", id_plano_acao))

  pg.get(table = table, filter = filters)
}
