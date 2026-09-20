#' Obter dados do endpoint plano_acao_analise_responsavel
#'
#' Esta função acessa os dados do endpoint **plano_acao_analise_responsavel** da API FundoaFundo (TransfereGov)
#' utilizando a função interna \code{pg_get}. Em vez de incorporar o endpoint na URL, utiliza-se
#' o parâmetro \code{table = "plano_acao_analise_responsavel"} para especificar a tabela a ser consultada.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
#' Todos os parâmetros são opcionais.
#'
#' @param plano_acao_analise_fk Chave estrangeira que referencia a análise do plano de ação (numérico).
#' @param nome_responsavel_analise_plano_acao Nome do responsável pela análise do plano de ação (texto).
#' @param cargo_responsavel_analise_plano_acao Cargo do responsável pela análise do plano de ação (texto).
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
#'   # Exemplo: consultar os responsáveis pela análise de um plano de ação específico
#'   resp <- ler_plano_acao_analise_responsavel(plano_acao_analise_fk = 1234)
#'   head(resp)
#' }
#'
#' @export
ler_plano_acao_analise_responsavel <- function(plano_acao_analise_fk = NULL,
                                               nome_responsavel_analise_plano_acao = NULL,
                                               cargo_responsavel_analise_plano_acao = NULL,
                                               select = NULL,
                                               order = NULL) {

  table <- "plano_acao_analise_responsavel"
  filters <- c()

  if (!is.null(plano_acao_analise_fk))
    filters <- c(filters, paste0("plano_acao_analise_fk=eq.", plano_acao_analise_fk))
  if (!is.null(nome_responsavel_analise_plano_acao))
    filters <- c(filters, paste0("nome_responsavel_analise_plano_acao=eq.", nome_responsavel_analise_plano_acao))
  if (!is.null(cargo_responsavel_analise_plano_acao))
    filters <- c(filters, paste0("cargo_responsavel_analise_plano_acao=eq.", cargo_responsavel_analise_plano_acao))

  pg_get(table = table, filter = filters, select = select, order = order)
}
