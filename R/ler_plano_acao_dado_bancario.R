#' Obter dados do endpoint plano_acao_dado_bancario
#'
#' Esta função acessa os dados do endpoint **plano_acao_dado_bancario** da API FundoaFundo (TransfereGov)
#' utilizando a função \code{pg.get} do pacote postgrestR. Em vez de inserir o endpoint na URL, utiliza-se
#' o parâmetro \code{table = "plano_acao_dado_bancario"} para especificar a tabela a ser consultada. Os filtros
#' são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
#' Todos os parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{id_plano_acao_dado_bancario}}{Identificador do dado bancário do plano de ação (numérico).}
#'   \item{\code{id_agencia_conta}}{Identificador da agência/conta (numérico).}
#'   \item{\code{codigo_banco_plano_acao_dado_bancario}}{Código do banco (texto).}
#'   \item{\code{nome_banco_plano_acao_dado_bancario}}{Nome do banco (texto).}
#'   \item{\code{numero_agencia_plano_acao_dado_bancario}}{Número da agência (texto ou numérico).}
#'   \item{\code{dv_agencia_plano_acao_dado_bancario}}{Dígito verificador da agência (texto).}
#'   \item{\code{numero_conta_plano_acao_dado_bancario}}{Número da conta (texto ou numérico).}
#'   \item{\code{dv_conta_plano_acao_dado_bancario}}{Dígito verificador da conta (texto).}
#'   \item{\code{situacao_conta_plano_acao_dado_bancario}}{Situação da conta (texto).}
#'   \item{\code{data_abertura_conta_plano_acao_dado_bancario}}{Data de abertura da conta (formato YYYY-MM-DD).}
#'   \item{\code{nome_programa_agil_conta_plano_acao_dado_bancario}}{Nome do programa ágil associado à conta (texto).}
#'   \item{\code{saldo_final_conta_plano_acao_dado_bancario}}{Saldo final da conta (numérico).}
#'   \item{\code{id_plano_acao}}{Identificador do plano de ação ao qual o dado bancário está vinculado (numérico).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: consultar dados bancários para um plano de ação específico
#'   dados_bancarios <- get_plano_acao_dado_bancario(id_plano_acao = 1234)
#'   head(dados_bancarios)
#' }
#'
#' @export
get_plano_acao_dado_bancario <- function(id_plano_acao_dado_bancario = NULL,
                                         id_agencia_conta = NULL,
                                         codigo_banco_plano_acao_dado_bancario = NULL,
                                         nome_banco_plano_acao_dado_bancario = NULL,
                                         numero_agencia_plano_acao_dado_bancario = NULL,
                                         dv_agencia_plano_acao_dado_bancario = NULL,
                                         numero_conta_plano_acao_dado_bancario = NULL,
                                         dv_conta_plano_acao_dado_bancario = NULL,
                                         situacao_conta_plano_acao_dado_bancario = NULL,
                                         data_abertura_conta_plano_acao_dado_bancario = NULL,
                                         nome_programa_agil_conta_plano_acao_dado_bancario = NULL,
                                         saldo_final_conta_plano_acao_dado_bancario = NULL,
                                         id_plano_acao = NULL) {

  table <- "plano_acao_dado_bancario"
  filters <- c()

  if (!is.null(id_plano_acao_dado_bancario))
    filters <- c(filters, paste0("id_plano_acao_dado_bancario=eq.", id_plano_acao_dado_bancario))
  if (!is.null(id_agencia_conta))
    filters <- c(filters, paste0("id_agencia_conta=eq.", id_agencia_conta))
  if (!is.null(codigo_banco_plano_acao_dado_bancario))
    filters <- c(filters, paste0("codigo_banco_plano_acao_dado_bancario=eq.", codigo_banco_plano_acao_dado_bancario))
  if (!is.null(nome_banco_plano_acao_dado_bancario))
    filters <- c(filters, paste0("nome_banco_plano_acao_dado_bancario=eq.", nome_banco_plano_acao_dado_bancario))
  if (!is.null(numero_agencia_plano_acao_dado_bancario))
    filters <- c(filters, paste0("numero_agencia_plano_acao_dado_bancario=eq.", numero_agencia_plano_acao_dado_bancario))
  if (!is.null(dv_agencia_plano_acao_dado_bancario))
    filters <- c(filters, paste0("dv_agencia_plano_acao_dado_bancario=eq.", dv_agencia_plano_acao_dado_bancario))
  if (!is.null(numero_conta_plano_acao_dado_bancario))
    filters <- c(filters, paste0("numero_conta_plano_acao_dado_bancario=eq.", numero_conta_plano_acao_dado_bancario))
  if (!is.null(dv_conta_plano_acao_dado_bancario))
    filters <- c(filters, paste0("dv_conta_plano_acao_dado_bancario=eq.", dv_conta_plano_acao_dado_bancario))
  if (!is.null(situacao_conta_plano_acao_dado_bancario))
    filters <- c(filters, paste0("situacao_conta_plano_acao_dado_bancario=eq.", situacao_conta_plano_acao_dado_bancario))
  if (!is.null(data_abertura_conta_plano_acao_dado_bancario))
    filters <- c(filters, paste0("data_abertura_conta_plano_acao_dado_bancario=eq.", data_abertura_conta_plano_acao_dado_bancario))
  if (!is.null(nome_programa_agil_conta_plano_acao_dado_bancario))
    filters <- c(filters, paste0("nome_programa_agil_conta_plano_acao_dado_bancario=eq.", nome_programa_agil_conta_plano_acao_dado_bancario))
  if (!is.null(saldo_final_conta_plano_acao_dado_bancario))
    filters <- c(filters, paste0("saldo_final_conta_plano_acao_dado_bancario=eq.", saldo_final_conta_plano_acao_dado_bancario))
  if (!is.null(id_plano_acao))
    filters <- c(filters, paste0("id_plano_acao=eq.", id_plano_acao))

  pg.get(table = table, filter = filters)
}
