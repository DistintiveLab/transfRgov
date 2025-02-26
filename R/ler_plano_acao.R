#' Obter dados do endpoint plano_acao
#'
#' Esta função acessa os dados do endpoint **plano_acao** da API FundoaFundo (TransfereGov) utilizando a função
#' \code{pg.get} do pacote postgrestR. Em vez de inserir o endpoint na URL, utiliza-se o parâmetro \code{table = "plano_acao"}
#' para especificar a tabela a ser consultada. Os filtros são aplicados por meio do argumento \code{filter} e devem estar
#' no formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{id_plano_acao}}{Identificador do plano de ação (numérico).}
#'   \item{\code{codigo_plano_acao}}{Código do plano de ação (texto).}
#'   \item{\code{data_inicio_vigencia_plano_acao}}{Data de início de vigência do plano de ação (formato YYYY-MM-DD).}
#'   \item{\code{data_fim_vigencia_plano_acao}}{Data de fim de vigência do plano de ação (formato YYYY-MM-DD).}
#'   \item{\code{diagnostico_plano_acao}}{Diagnóstico do plano de ação (texto).}
#'   \item{\code{objetivos_plano_acao}}{Objetivos do plano de ação (texto).}
#'   \item{\code{situacao_plano_acao}}{Situação do plano de ação (texto).}
#'   \item{\code{valor_repasse_emenda_plano_acao}}{Valor de repasse por emenda (numérico).}
#'   \item{\code{valor_repasse_especifico_plano_acao}}{Valor de repasse específico (numérico).}
#'   \item{\code{valor_repasse_voluntario_plano_acao}}{Valor de repasse voluntário (numérico).}
#'   \item{\code{valor_total_repasse_plano_acao}}{Valor total de repasse (numérico).}
#'   \item{\code{valor_recursos_proprios_plano_acao}}{Valor de recursos próprios (numérico).}
#'   \item{\code{valor_outros_plano_acao}}{Valor de outros repasses (numérico).}
#'   \item{\code{valor_rendimentos_aplicacao_plano_acao}}{Valor de rendimentos de aplicação (numérico).}
#'   \item{\code{valor_total_plano_acao}}{Valor total do plano de ação (numérico).}
#'   \item{\code{valor_total_investimento_plano_acao}}{Valor total de investimento (numérico).}
#'   \item{\code{valor_total_custeio_plano_acao}}{Valor total de custeio (numérico).}
#'   \item{\code{valor_saldo_disponivel_plano_acao}}{Valor do saldo disponível (numérico).}
#'   \item{\code{id_orgao_repassador_plano_acao}}{Identificador do órgão repassador (numérico).}
#'   \item{\code{sigla_orgao_repassador_plano_acao}}{Sigla do órgão repassador (texto).}
#'   \item{\code{cnpj_orgao_repassador_plano_acao}}{CNPJ do órgão repassador (texto).}
#'   \item{\code{nome_orgao_repassador_plano_acao}}{Nome do órgão repassador (texto).}
#'   \item{\code{id_ente_repassador_plano_acao}}{Identificador do ente repassador (numérico).}
#'   \item{\code{cnpj_ente_repassador_plano_acao}}{CNPJ do ente repassador (texto).}
#'   \item{\code{nome_ente_repassador_plano_acao}}{Nome do ente repassador (texto).}
#'   \item{\code{uf_ente_repassador_plano_acao}}{UF do ente repassador (texto).}
#'   \item{\code{nome_municipio_ente_repassador_plano_acao}}{Nome do município do ente repassador (texto).}
#'   \item{\code{codigo_ibge_municipio_ente_repassador_plano_acao}}{Código IBGE do município do ente repassador (texto ou numérico).}
#'   \item{\code{id_ente_recebedor_plano_acao}}{Identificador do ente recebedor (numérico).}
#'   \item{\code{cnpj_ente_recebedor_plano_acao}}{CNPJ do ente recebedor (texto).}
#'   \item{\code{nome_ente_recebedor_plano_acao}}{Nome do ente recebedor (texto).}
#'   \item{\code{uf_ente_recebedor_plano_acao}}{UF do ente recebedor (texto).}
#'   \item{\code{nome_municipio_ente_recebedor_plano_acao}}{Nome do município do ente recebedor (texto).}
#'   \item{\code{codigo_ibge_municipio_ente_recebedor_plano_acao}}{Código IBGE do município do ente recebedor (texto ou numérico).}
#'   \item{\code{id_fundo_repassador_plano_acao}}{Identificador do fundo repassador (numérico).}
#'   \item{\code{cnpj_fundo_repassador_plano_acao}}{CNPJ do fundo repassador (texto).}
#'   \item{\code{nome_fundo_repassador_plano_acao}}{Nome do fundo repassador (texto).}
#'   \item{\code{uf_fundo_repassador_plano_acao}}{UF do fundo repassador (texto).}
#'   \item{\code{municipio_fundo_repassador_plano_acao}}{Município do fundo repassador (texto).}
#'   \item{\code{codigo_ibge_fundo_repassador_plano_acao}}{Código IBGE do fundo repassador (texto ou numérico).}
#'   \item{\code{id_fundo_recebedor_plano_acao}}{Identificador do fundo recebedor (numérico).}
#'   \item{\code{cnpj_fundo_recebedor_plano_acao}}{CNPJ do fundo recebedor (texto).}
#'   \item{\code{nome_fundo_recebedor_plano_acao}}{Nome do fundo recebedor (texto).}
#'   \item{\code{uf_fundo_recebedor_plano_acao}}{UF do fundo recebedor (texto).}
#'   \item{\code{municipio_fundo_recebedor_plano_acao}}{Município do fundo recebedor (texto).}
#'   \item{\code{codigo_ibge_fundo_recebedor_plano_acao}}{Código IBGE do fundo recebedor (texto ou numérico).}
#'   \item{\code{id_programa}}{Identificador do programa ao qual o plano de ação está vinculado (numérico).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: consultar planos de ação para um programa específico
#'   plano <- get_plano_acao(id_programa = 1234)
#'   head(plano)
#' }
#'
#' @export
get_plano_acao <- function(id_plano_acao = NULL,
                           codigo_plano_acao = NULL,
                           data_inicio_vigencia_plano_acao = NULL,
                           data_fim_vigencia_plano_acao = NULL,
                           diagnostico_plano_acao = NULL,
                           objetivos_plano_acao = NULL,
                           situacao_plano_acao = NULL,
                           valor_repasse_emenda_plano_acao = NULL,
                           valor_repasse_especifico_plano_acao = NULL,
                           valor_repasse_voluntario_plano_acao = NULL,
                           valor_total_repasse_plano_acao = NULL,
                           valor_recursos_proprios_plano_acao = NULL,
                           valor_outros_plano_acao = NULL,
                           valor_rendimentos_aplicacao_plano_acao = NULL,
                           valor_total_plano_acao = NULL,
                           valor_total_investimento_plano_acao = NULL,
                           valor_total_custeio_plano_acao = NULL,
                           valor_saldo_disponivel_plano_acao = NULL,
                           id_orgao_repassador_plano_acao = NULL,
                           sigla_orgao_repassador_plano_acao = NULL,
                           cnpj_orgao_repassador_plano_acao = NULL,
                           nome_orgao_repassador_plano_acao = NULL,
                           id_ente_repassador_plano_acao = NULL,
                           cnpj_ente_repassador_plano_acao = NULL,
                           nome_ente_repassador_plano_acao = NULL,
                           uf_ente_repassador_plano_acao = NULL,
                           nome_municipio_ente_repassador_plano_acao = NULL,
                           codigo_ibge_municipio_ente_repassador_plano_acao = NULL,
                           id_ente_recebedor_plano_acao = NULL,
                           cnpj_ente_recebedor_plano_acao = NULL,
                           nome_ente_recebedor_plano_acao = NULL,
                           uf_ente_recebedor_plano_acao = NULL,
                           nome_municipio_ente_recebedor_plano_acao = NULL,
                           codigo_ibge_municipio_ente_recebedor_plano_acao = NULL,
                           id_fundo_repassador_plano_acao = NULL,
                           cnpj_fundo_repassador_plano_acao = NULL,
                           nome_fundo_repassador_plano_acao = NULL,
                           uf_fundo_repassador_plano_acao = NULL,
                           municipio_fundo_repassador_plano_acao = NULL,
                           codigo_ibge_fundo_repassador_plano_acao = NULL,
                           id_fundo_recebedor_plano_acao = NULL,
                           cnpj_fundo_recebedor_plano_acao = NULL,
                           nome_fundo_recebedor_plano_acao = NULL,
                           uf_fundo_recebedor_plano_acao = NULL,
                           municipio_fundo_recebedor_plano_acao = NULL,
                           codigo_ibge_fundo_recebedor_plano_acao = NULL,
                           id_programa = NULL) {

  table <- "plano_acao"
  filters <- c()

  if (!is.null(id_plano_acao))
    filters <- c(filters, paste0("id_plano_acao=eq.", id_plano_acao))
  if (!is.null(codigo_plano_acao))
    filters <- c(filters, paste0("codigo_plano_acao=eq.", codigo_plano_acao))
  if (!is.null(data_inicio_vigencia_plano_acao))
    filters <- c(filters, paste0("data_inicio_vigencia_plano_acao=eq.", data_inicio_vigencia_plano_acao))
  if (!is.null(data_fim_vigencia_plano_acao))
    filters <- c(filters, paste0("data_fim_vigencia_plano_acao=eq.", data_fim_vigencia_plano_acao))
  if (!is.null(diagnostico_plano_acao))
    filters <- c(filters, paste0("diagnostico_plano_acao=eq.", diagnostico_plano_acao))
  if (!is.null(objetivos_plano_acao))
    filters <- c(filters, paste0("objetivos_plano_acao=eq.", objetivos_plano_acao))
  if (!is.null(situacao_plano_acao))
    filters <- c(filters, paste0("situacao_plano_acao=eq.", situacao_plano_acao))
  if (!is.null(valor_repasse_emenda_plano_acao))
    filters <- c(filters, paste0("valor_repasse_emenda_plano_acao=eq.", valor_repasse_emenda_plano_acao))
  if (!is.null(valor_repasse_especifico_plano_acao))
    filters <- c(filters, paste0("valor_repasse_especifico_plano_acao=eq.", valor_repasse_especifico_plano_acao))
  if (!is.null(valor_repasse_voluntario_plano_acao))
    filters <- c(filters, paste0("valor_repasse_voluntario_plano_acao=eq.", valor_repasse_voluntario_plano_acao))
  if (!is.null(valor_total_repasse_plano_acao))
    filters <- c(filters, paste0("valor_total_repasse_plano_acao=eq.", valor_total_repasse_plano_acao))
  if (!is.null(valor_recursos_proprios_plano_acao))
    filters <- c(filters, paste0("valor_recursos_proprios_plano_acao=eq.", valor_recursos_proprios_plano_acao))
  if (!is.null(valor_outros_plano_acao))
    filters <- c(filters, paste0("valor_outros_plano_acao=eq.", valor_outros_plano_acao))
  if (!is.null(valor_rendimentos_aplicacao_plano_acao))
    filters <- c(filters, paste0("valor_rendimentos_aplicacao_plano_acao=eq.", valor_rendimentos_aplicacao_plano_acao))
  if (!is.null(valor_total_plano_acao))
    filters <- c(filters, paste0("valor_total_plano_acao=eq.", valor_total_plano_acao))
  if (!is.null(valor_total_investimento_plano_acao))
    filters <- c(filters, paste0("valor_total_investimento_plano_acao=eq.", valor_total_investimento_plano_acao))
  if (!is.null(valor_total_custeio_plano_acao))
    filters <- c(filters, paste0("valor_total_custeio_plano_acao=eq.", valor_total_custeio_plano_acao))
  if (!is.null(valor_saldo_disponivel_plano_acao))
    filters <- c(filters, paste0("valor_saldo_disponivel_plano_acao=eq.", valor_saldo_disponivel_plano_acao))
  if (!is.null(id_orgao_repassador_plano_acao))
    filters <- c(filters, paste0("id_orgao_repassador_plano_acao=eq.", id_orgao_repassador_plano_acao))
  if (!is.null(sigla_orgao_repassador_plano_acao))
    filters <- c(filters, paste0("sigla_orgao_repassador_plano_acao=eq.", sigla_orgao_repassador_plano_acao))
  if (!is.null(cnpj_orgao_repassador_plano_acao))
    filters <- c(filters, paste0("cnpj_orgao_repassador_plano_acao=eq.", cnpj_orgao_repassador_plano_acao))
  if (!is.null(nome_orgao_repassador_plano_acao))
    filters <- c(filters, paste0("nome_orgao_repassador_plano_acao=eq.", nome_orgao_repassador_plano_acao))
  if (!is.null(id_ente_repassador_plano_acao))
    filters <- c(filters, paste0("id_ente_repassador_plano_acao=eq.", id_ente_repassador_plano_acao))
  if (!is.null(cnpj_ente_repassador_plano_acao))
    filters <- c(filters, paste0("cnpj_ente_repassador_plano_acao=eq.", cnpj_ente_repassador_plano_acao))
  if (!is.null(nome_ente_repassador_plano_acao))
    filters <- c(filters, paste0("nome_ente_repassador_plano_acao=eq.", nome_ente_repassador_plano_acao))
  if (!is.null(uf_ente_repassador_plano_acao))
    filters <- c(filters, paste0("uf_ente_repassador_plano_acao=eq.", uf_ente_repassador_plano_acao))
  if (!is.null(nome_municipio_ente_repassador_plano_acao))
    filters <- c(filters, paste0("nome_municipio_ente_repassador_plano_acao=eq.", nome_municipio_ente_repassador_plano_acao))
  if (!is.null(codigo_ibge_municipio_ente_repassador_plano_acao))
    filters <- c(filters, paste0("codigo_ibge_municipio_ente_repassador_plano_acao=eq.", codigo_ibge_municipio_ente_repassador_plano_acao))
  if (!is.null(id_ente_recebedor_plano_acao))
    filters <- c(filters, paste0("id_ente_recebedor_plano_acao=eq.", id_ente_recebedor_plano_acao))
  if (!is.null(cnpj_ente_recebedor_plano_acao))
    filters <- c(filters, paste0("cnpj_ente_recebedor_plano_acao=eq.", cnpj_ente_recebedor_plano_acao))
  if (!is.null(nome_ente_recebedor_plano_acao))
    filters <- c(filters, paste0("nome_ente_recebedor_plano_acao=eq.", nome_ente_recebedor_plano_acao))
  if (!is.null(uf_ente_recebedor_plano_acao))
    filters <- c(filters, paste0("uf_ente_recebedor_plano_acao=eq.", uf_ente_recebedor_plano_acao))
  if (!is.null(nome_municipio_ente_recebedor_plano_acao))
    filters <- c(filters, paste0("nome_municipio_ente_recebedor_plano_acao=eq.", nome_municipio_ente_recebedor_plano_acao))
  if (!is.null(codigo_ibge_municipio_ente_recebedor_plano_acao))
    filters <- c(filters, paste0("codigo_ibge_municipio_ente_recebedor_plano_acao=eq.", codigo_ibge_municipio_ente_recebedor_plano_acao))
  if (!is.null(id_fundo_repassador_plano_acao))
    filters <- c(filters, paste0("id_fundo_repassador_plano_acao=eq.", id_fundo_repassador_plano_acao))
  if (!is.null(cnpj_fundo_repassador_plano_acao))
    filters <- c(filters, paste0("cnpj_fundo_repassador_plano_acao=eq.", cnpj_fundo_repassador_plano_acao))
  if (!is.null(nome_fundo_repassador_plano_acao))
    filters <- c(filters, paste0("nome_fundo_repassador_plano_acao=eq.", nome_fundo_repassador_plano_acao))
  if (!is.null(uf_fundo_repassador_plano_acao))
    filters <- c(filters, paste0("uf_fundo_repassador_plano_acao=eq.", uf_fundo_repassador_plano_acao))
  if (!is.null(municipio_fundo_repassador_plano_acao))
    filters <- c(filters, paste0("municipio_fundo_repassador_plano_acao=eq.", municipio_fundo_repassador_plano_acao))
  if (!is.null(codigo_ibge_fundo_repassador_plano_acao))
    filters <- c(filters, paste0("codigo_ibge_fundo_repassador_plano_acao=eq.", codigo_ibge_fundo_repassador_plano_acao))
  if (!is.null(id_fundo_recebedor_plano_acao))
    filters <- c(filters, paste0("id_fundo_recebedor_plano_acao=eq.", id_fundo_recebedor_plano_acao))
  if (!is.null(cnpj_fundo_recebedor_plano_acao))
    filters <- c(filters, paste0("cnpj_fundo_recebedor_plano_acao=eq.", cnpj_fundo_recebedor_plano_acao))
  if (!is.null(nome_fundo_recebedor_plano_acao))
    filters <- c(filters, paste0("nome_fundo_recebedor_plano_acao=eq.", nome_fundo_recebedor_plano_acao))
  if (!is.null(uf_fundo_recebedor_plano_acao))
    filters <- c(filters, paste0("uf_fundo_recebedor_plano_acao=eq.", uf_fundo_recebedor_plano_acao))
  if (!is.null(municipio_fundo_recebedor_plano_acao))
    filters <- c(filters, paste0("municipio_fundo_recebedor_plano_acao=eq.", municipio_fundo_recebedor_plano_acao))
  if (!is.null(codigo_ibge_fundo_recebedor_plano_acao))
    filters <- c(filters, paste0("codigo_ibge_fundo_recebedor_plano_acao=eq.", codigo_ibge_fundo_recebedor_plano_acao))
  if (!is.null(id_programa))
    filters <- c(filters, paste0("id_programa=eq.", id_programa))

  pg.get(table = table, filter = filters)
}
