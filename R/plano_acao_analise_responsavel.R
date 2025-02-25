#' Obter dados do endpoint plano_acao_analise_responsavel
#'
#' Esta função acessa os dados do endpoint **plano_acao_analise_responsavel** da API FundoaFundo (TransfereGov)
#' utilizando a função \code{pg.get} do pacote postgrestR. Em vez de incorporar o endpoint na URL, utiliza-se
#' o parâmetro \code{table = "plano_acao_analise_responsavel"} para especificar a tabela a ser consultada.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
#' Todos os parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{plano_acao_analise_fk}}{Chave estrangeira que referencia a análise do plano de ação (numérico).}
#'   \item{\code{nome_responsavel_analise_plano_acao}}{Nome do responsável pela análise do plano de ação (texto).}
#'   \item{\code{cargo_responsavel_analise_plano_acao}}{Cargo do responsável pela análise do plano de ação (texto).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: consultar os responsáveis pela análise de um plano de ação específico
#'   resp <- ler_plano_acao_analise_responsavel(plano_acao_analise_fk = 1234)
#'   head(resp)
#' }
#'
#' @export
ler_plano_acao_analise_responsavel <- function(plano_acao_analise_fk = NULL,
                                               nome_responsavel_analise_plano_acao = NULL,
                                               cargo_responsavel_analise_plano_acao = NULL) {

  table <- "plano_acao_analise_responsavel"
  filters <- c()

  if (!is.null(plano_acao_analise_fk))
    filters <- c(filters, paste0("plano_acao_analise_fk=eq.", plano_acao_analise_fk))
  if (!is.null(nome_responsavel_analise_plano_acao))
    filters <- c(filters, paste0("nome_responsavel_analise_plano_acao=eq.", nome_responsavel_analise_plano_acao))
  if (!is.null(cargo_responsavel_analise_plano_acao))
    filters <- c(filters, paste0("cargo_responsavel_analise_plano_acao=eq.", cargo_responsavel_analise_plano_acao))

  pg.get(table = table, filter = filters)
}
