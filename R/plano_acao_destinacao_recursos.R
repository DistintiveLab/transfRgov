#' Obter dados do endpoint plano_acao_destinacao_recursos
#'
#' Esta função acessa os dados do endpoint **plano_acao_destinacao_recursos** da API FundoaFundo (TransfereGov)
#' utilizando a função interna \code{pg_get}. Em vez de incorporar o endpoint na URL, utiliza-se
#' o parâmetro \code{table = "plano_acao_destinacao_recursos"} para especificar a tabela a ser consultada. Os filtros
#' são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor". Todos os
#' parâmetros são opcionais.
#'
#' @param id_destinacao_recursos_plano_acao Identificador da destinacão de recursos do plano de ação (numérico).
#' @param codigo_natureza_despesa_destinacao_recursos_plano_acao Código da natureza de despesa (texto ou numérico).
#' @param descricao_natureza_despesa_destinacao_recursos_plano_acao Descrição da natureza de despesa (texto).
#' @param tipo_despesa_destinacao_recursos_plano_acao Tipo de despesa da destinacão de recursos (texto).
#' @param valor_destinacao_recursos_plano_acao Valor destinado (numérico).
#' @param id_plano_acao Identificador do plano de ação ao qual a destinacão de recursos está vinculada (numérico).
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
#'   # Exemplo: consultar destinacões de recursos para um determinado plano de ação
#'   dest_recursos <- get_plano_acao_destinacao_recursos(id_plano_acao = 1234)
#'   head(dest_recursos)
#' }
#'
#' @export
get_plano_acao_destinacao_recursos <- function(id_destinacao_recursos_plano_acao = NULL,
                                               codigo_natureza_despesa_destinacao_recursos_plano_acao = NULL,
                                               descricao_natureza_despesa_destinacao_recursos_plano_acao = NULL,
                                               tipo_despesa_destinacao_recursos_plano_acao = NULL,
                                               valor_destinacao_recursos_plano_acao = NULL,
                                               id_plano_acao = NULL,
                                               select = NULL,
                                               order = NULL) {

  table <- "plano_acao_destinacao_recursos"
  filters <- c()

  if (!is.null(id_destinacao_recursos_plano_acao))
    filters <- c(filters, paste0("id_destinacao_recursos_plano_acao=eq.", id_destinacao_recursos_plano_acao))
  if (!is.null(codigo_natureza_despesa_destinacao_recursos_plano_acao))
    filters <- c(filters, paste0("codigo_natureza_despesa_destinacao_recursos_plano_acao=eq.", codigo_natureza_despesa_destinacao_recursos_plano_acao))
  if (!is.null(descricao_natureza_despesa_destinacao_recursos_plano_acao))
    filters <- c(filters, paste0("descricao_natureza_despesa_destinacao_recursos_plano_acao=eq.", descricao_natureza_despesa_destinacao_recursos_plano_acao))
  if (!is.null(tipo_despesa_destinacao_recursos_plano_acao))
    filters <- c(filters, paste0("tipo_despesa_destinacao_recursos_plano_acao=eq.", tipo_despesa_destinacao_recursos_plano_acao))
  if (!is.null(valor_destinacao_recursos_plano_acao))
    filters <- c(filters, paste0("valor_destinacao_recursos_plano_acao=eq.", valor_destinacao_recursos_plano_acao))
  if (!is.null(id_plano_acao))
    filters <- c(filters, paste0("id_plano_acao=eq.", id_plano_acao))

  pg_get(table = table, filter = filters, select = select, order = order)
}
