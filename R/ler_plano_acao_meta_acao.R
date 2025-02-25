#' Obter dados do endpoint plano_acao_meta_acao
#'
#' Esta função acessa os dados do endpoint **plano_acao_meta_acao** da API FundoaFundo (TransfereGov)
#' utilizando a função \code{pg.get} do pacote postgrestR. Em vez de incorporar o endpoint na URL, utiliza-se
#' o parâmetro \code{table = "plano_acao_meta_acao"} para especificar a tabela a ser consultada. Os filtros
#' são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
#' Todos os parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{id_acao_meta_plano_acao}}{Identificador da ação da meta do plano de ação (numérico).}
#'   \item{\code{numero_acao_meta_plano_acao}}{Número da ação da meta do plano de ação (texto ou numérico).}
#'   \item{\code{nome_acao_meta_plano_acao}}{Nome da ação da meta do plano de ação (texto).}
#'   \item{\code{descricao_acao_meta_plano_acao}}{Descrição da ação da meta do plano de ação (texto).}
#'   \item{\code{valor_acao_meta_plano_acao}}{Valor da ação da meta do plano de ação (numérico).}
#'   \item{\code{versao_acao_meta_plano_acao}}{Versão da ação da meta do plano de ação (texto ou numérico).}
#'   \item{\code{sequencial_acao_meta_plano_acao}}{Sequencial da ação da meta do plano de ação (numérico).}
#'   \item{\code{id_meta_plano_acao}}{Identificador da meta do plano de ação à qual a ação está vinculada (numérico).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: consultar ações de meta para uma meta de plano de ação específica
#'   acao_meta <- ler_plano_acao_meta_acao(id_meta_plano_acao = 5678)
#'   head(acao_meta)
#' }
#'
#' @export
ler_plano_acao_meta_acao <- function(id_acao_meta_plano_acao = NULL,
                                     numero_acao_meta_plano_acao = NULL,
                                     nome_acao_meta_plano_acao = NULL,
                                     descricao_acao_meta_plano_acao = NULL,
                                     valor_acao_meta_plano_acao = NULL,
                                     versao_acao_meta_plano_acao = NULL,
                                     sequencial_acao_meta_plano_acao = NULL,
                                     id_meta_plano_acao = NULL) {

  table <- "plano_acao_meta_acao"
  filters <- c()

  if (!is.null(id_acao_meta_plano_acao))
    filters <- c(filters, paste0("id_acao_meta_plano_acao=eq.", id_acao_meta_plano_acao))
  if (!is.null(numero_acao_meta_plano_acao))
    filters <- c(filters, paste0("numero_acao_meta_plano_acao=eq.", numero_acao_meta_plano_acao))
  if (!is.null(nome_acao_meta_plano_acao))
    filters <- c(filters, paste0("nome_acao_meta_plano_acao=eq.", nome_acao_meta_plano_acao))
  if (!is.null(descricao_acao_meta_plano_acao))
    filters <- c(filters, paste0("descricao_acao_meta_plano_acao=eq.", descricao_acao_meta_plano_acao))
  if (!is.null(valor_acao_meta_plano_acao))
    filters <- c(filters, paste0("valor_acao_meta_plano_acao=eq.", valor_acao_meta_plano_acao))
  if (!is.null(versao_acao_meta_plano_acao))
    filters <- c(filters, paste0("versao_acao_meta_plano_acao=eq.", versao_acao_meta_plano_acao))
  if (!is.null(sequencial_acao_meta_plano_acao))
    filters <- c(filters, paste0("sequencial_acao_meta_plano_acao=eq.", sequencial_acao_meta_plano_acao))
  if (!is.null(id_meta_plano_acao))
    filters <- c(filters, paste0("id_meta_plano_acao=eq.", id_meta_plano_acao))

  pg.get(table = table, filter = filters)
}
