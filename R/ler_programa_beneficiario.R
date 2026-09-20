#' Obter dados do endpoint programa_beneficiario
#'
#' Esta função acessa os dados referentes ao endpoint de beneficiários de programas na API FundoaFundo (TransfereGov),
#' utilizando a função interna \code{pg_get}. Em vez de inserir o endpoint na URL, utiliza-se o parâmetro
#' \code{table = 'programa_beneficiario'} para especificar a tabela a ser consultada.
#'
#' Os filtros são aplicados por meio do parâmetro \code{filter} da função \code{pg_get}. Para cada parâmetro informado, é criada
#' uma condição no formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' @param id_beneficiario_programa Identificador do beneficiário do programa (numérico).
#' @param cnpj_beneficiario_programa CNPJ do beneficiário do programa (texto).
#' @param nome_beneficiario_programa Nome do beneficiário do programa (texto).
#' @param valor_beneficiario_programa Valor atribuído ao beneficiário do programa (numérico).
#' @param numero_emenda_beneficiario_programa Número da emenda do beneficiário do programa (texto ou numérico).
#' @param nome_parlamentar_beneficiario_programa Nome do parlamentar associado ao beneficiário (texto).
#' @param tipo_beneficiario_programa Tipo de beneficiário do programa (texto).
#' @param uf_beneficiario_programa Unidade Federativa do beneficiário do programa (texto).
#' @param id_programa Identificador do programa ao qual o beneficiário está vinculado (numérico).
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
#'   # Exemplo: consultar beneficiários do programa com id 1234 e UF "SP"
#'   beneficiarios <- ler_programa_beneficiario(id_programa = 1234, uf_beneficiario_programa = "SP")
#'   head(beneficiarios)
#' }
#'
#' @export
ler_programa_beneficiario <- function(id_beneficiario_programa = NULL,
                                      cnpj_beneficiario_programa = NULL,
                                      nome_beneficiario_programa = NULL,
                                      valor_beneficiario_programa = NULL,
                                      numero_emenda_beneficiario_programa = NULL,
                                      nome_parlamentar_beneficiario_programa = NULL,
                                      tipo_beneficiario_programa = NULL,
                                      uf_beneficiario_programa = NULL,
                                      id_programa = NULL,
                                      select = NULL,
                                      order = NULL) {

  # Vetor para armazenar os filtros no formato "nome_parametro=eq.valor"
  filters <- c()

  if (!is.null(id_beneficiario_programa))
    filters <- c(filters, paste0("id_beneficiario_programa=eq.", id_beneficiario_programa))
  if (!is.null(cnpj_beneficiario_programa))
    filters <- c(filters, paste0("cnpj_beneficiario_programa=eq.", cnpj_beneficiario_programa))
  if (!is.null(nome_beneficiario_programa))
    filters <- c(filters, paste0("nome_beneficiario_programa=eq.", nome_beneficiario_programa))
  if (!is.null(valor_beneficiario_programa))
    filters <- c(filters, paste0("valor_beneficiario_programa=eq.", valor_beneficiario_programa))
  if (!is.null(numero_emenda_beneficiario_programa))
    filters <- c(filters, paste0("numero_emenda_beneficiario_programa=eq.", numero_emenda_beneficiario_programa))
  if (!is.null(nome_parlamentar_beneficiario_programa))
    filters <- c(filters, paste0("nome_parlamentar_beneficiario_programa=eq.", nome_parlamentar_beneficiario_programa))
  if (!is.null(tipo_beneficiario_programa))
    filters <- c(filters, paste0("tipo_beneficiario_programa=eq.", tipo_beneficiario_programa))
  if (!is.null(uf_beneficiario_programa))
    filters <- c(filters, paste0("uf_beneficiario_programa=eq.", uf_beneficiario_programa))
  if (!is.null(id_programa))
    filters <- c(filters, paste0("id_programa=eq.", id_programa))

  # Chama a função pg_get passando o parâmetro table e o vetor de filtros
  pg_get(table = "programa_beneficiario", filter = filters, select = select, order = order)
}
