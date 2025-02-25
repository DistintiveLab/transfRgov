#' Obter dados do endpoint programa_beneficiario
#'
#' Esta função acessa os dados referentes ao endpoint de beneficiários de programas na API FundoaFundo (TransfereGov),
#' utilizando a função \code{pg.get} do pacote postgrestR. Em vez de inserir o endpoint na URL, utiliza-se o parâmetro
#' \code{table = 'programa_beneficiario'} para especificar a tabela a ser consultada.
#'
#' Os filtros são aplicados por meio do parâmetro \code{filter} da \code{pg.get}. Para cada parâmetro informado, é criada
#' uma condição no formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{id_beneficiario_programa}}{Identificador do beneficiário do programa (numérico).}
#'   \item{\code{cnpj_beneficiario_programa}}{CNPJ do beneficiário do programa (texto).}
#'   \item{\code{nome_beneficiario_programa}}{Nome do beneficiário do programa (texto).}
#'   \item{\code{valor_beneficiario_programa}}{Valor atribuído ao beneficiário do programa (numérico).}
#'   \item{\code{numero_emenda_beneficiario_programa}}{Número da emenda do beneficiário do programa (texto ou numérico).}
#'   \item{\code{nome_parlamentar_beneficiario_programa}}{Nome do parlamentar associado ao beneficiário (texto).}
#'   \item{\code{tipo_beneficiario_programa}}{Tipo de beneficiário do programa (texto).}
#'   \item{\code{uf_beneficiario_programa}}{Unidade Federativa do beneficiário do programa (texto).}
#'   \item{\code{id_programa}}{Identificador do programa ao qual o beneficiário está vinculado (numérico).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
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
                                      id_programa = NULL) {

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

  # Chama a função pg.get passando o parâmetro table e o vetor de filtros
  pg.get(table = "programa_beneficiario", filter = filters)
}
