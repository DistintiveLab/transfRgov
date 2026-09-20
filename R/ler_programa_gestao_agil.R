#' Obter dados do endpoint programa_gestao_agil
#'
#' Esta função acessa os dados do endpoint **programa_gestao_agil** da API FundoaFundo (TransfereGov)
#' utilizando a função interna \code{pg_get}. Em vez de incorporar o endpoint na URL, utiliza-se
#' o parâmetro \code{table = "programa_gestao_agil"} para especificar a tabela a ser consultada.
#'
#' Os filtros são aplicados por meio do argumento \code{filter} da função \code{pg_get}. Para cada parâmetro informado,
#' é criada uma condição no formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' @param id_programa_agil Identificador do programa ágil (numérico).
#' @param id_programa_agil_bb Identificador do programa ágil BB (numérico).
#' @param nome_programa_agil Nome do programa ágil (texto).
#' @param codigo_programa_agil Código do programa ágil (texto).
#' @param codigo_siorg_orgao_programa_agil Código SIORG do órgão do programa ágil (texto).
#' @param sigla_orgao_programa_agil Sigla do órgão do programa ágil (texto).
#' @param cnpj_orgao_programa_agil CNPJ do órgão do programa ágil (texto).
#' @param nome_orgao_programa_agil Nome do órgão do programa ágil (texto).
#' @param id_programa Identificador do programa ao qual o registro está vinculado (numérico).
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
#'   # Exemplo: consultar registros do programa_gestao_agil para um programa específico
#'   agil <- ler_programa_gestao_agil(id_programa = 1234)
#'   head(agil)
#' }
#'
#' @export
ler_programa_gestao_agil <- function(id_programa_agil = NULL,
                                     id_programa_agil_bb = NULL,
                                     nome_programa_agil = NULL,
                                     codigo_programa_agil = NULL,
                                     codigo_siorg_orgao_programa_agil = NULL,
                                     sigla_orgao_programa_agil = NULL,
                                     cnpj_orgao_programa_agil = NULL,
                                     nome_orgao_programa_agil = NULL,
                                     id_programa = NULL,
                                     select = NULL,
                                     order = NULL) {

  # Define o parâmetro table para acessar a tabela correta na API
  table <- "programa_gestao_agil"

  # Vetor para armazenar os filtros no formato "nome_parametro=eq.valor"
  filters <- c()

  if (!is.null(id_programa_agil))
    filters <- c(filters, paste0("id_programa_agil=eq.", id_programa_agil))
  if (!is.null(id_programa_agil_bb))
    filters <- c(filters, paste0("id_programa_agil_bb=eq.", id_programa_agil_bb))
  if (!is.null(nome_programa_agil))
    filters <- c(filters, paste0("nome_programa_agil=eq.", nome_programa_agil))
  if (!is.null(codigo_programa_agil))
    filters <- c(filters, paste0("codigo_programa_agil=eq.", codigo_programa_agil))
  if (!is.null(codigo_siorg_orgao_programa_agil))
    filters <- c(filters, paste0("codigo_siorg_orgao_programa_agil=eq.", codigo_siorg_orgao_programa_agil))
  if (!is.null(sigla_orgao_programa_agil))
    filters <- c(filters, paste0("sigla_orgao_programa_agil=eq.", sigla_orgao_programa_agil))
  if (!is.null(cnpj_orgao_programa_agil))
    filters <- c(filters, paste0("cnpj_orgao_programa_agil=eq.", cnpj_orgao_programa_agil))
  if (!is.null(nome_orgao_programa_agil))
    filters <- c(filters, paste0("nome_orgao_programa_agil=eq.", nome_orgao_programa_agil))
  if (!is.null(id_programa))
    filters <- c(filters, paste0("id_programa=eq.", id_programa))

  # Chama a função pg_get passando o parâmetro table e o vetor de filtros
  pg_get(table = table, filter = filters, select = select, order = order)
}
