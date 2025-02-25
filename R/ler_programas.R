#' Obter dados do endpoint /programa
#'
#' Esta função acessa o endpoint `/programa` da API FundoaFundo (TransfereGov) e retorna os
#' dados filtrados de programas, utilizando a função \code{pg.get} do pacote postgrestR.
#'
#' Os filtros são aplicados via o parâmetro \code{filter} da \code{pg.get}. Para cada parâmetro
#' informado, é criada uma condição no formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' Parâmetros disponíveis:
#' \describe{
#'   \item{\code{id_programa}}{Identificador do programa (numérico).}
#'   \item{\code{ano_programa}}{Ano de referência do programa (numérico).}
#'   \item{\code{modalidade_programa}}{Modalidade ou categoria do programa (texto).}
#'   \item{\code{codigo_programa}}{Código do programa (texto).}
#'   \item{\code{nome_programa}}{Nome do programa (texto).}
#'   \item{\code{id_unidade_gestora_programa}}{Identificador da unidade gestora do programa (numérico).}
#'   \item{\code{nome_institucional_programa}}{Nome institucional do programa (texto).}
#'   \item{\code{permite_transferencia_sem_fundo_programa}}{Indica se o programa permite transferência sem fundo (booleano ou texto).}
#'   \item{\code{objetivo_programa}}{Objetivo do programa (texto).}
#'   \item{\code{descricao_programa}}{Descrição do programa (texto).}
#'   \item{\code{situacao_programa}}{Situação do programa (texto).}
#'   \item{\code{valor_global_programa}}{Valor global do programa (numérico).}
#'   \item{\code{quantidade_parcelas_programa}}{Quantidade de parcelas do programa (numérico).}
#'   \item{\code{id_orgao_superior_programa}}{Identificador do órgão superior do programa (numérico).}
#'   \item{\code{sigla_orgao_superior_programa}}{Sigla do órgão superior (texto).}
#'   \item{\code{cnpj_orgao_superior_programa}}{CNPJ do órgão superior (texto).}
#'   \item{\code{nome_orgao_superior_programa}}{Nome do órgão superior (texto).}
#'   \item{\code{id_fundo_programa}}{Identificador do fundo do programa (numérico).}
#'   \item{\code{cnpj_fundo_programa}}{CNPJ do fundo (texto).}
#'   \item{\code{nome_fundo_programa}}{Nome do fundo (texto).}
#'   \item{\code{uf_fundo_programa}}{Unidade Federativa do fundo (texto).}
#'   \item{\code{municipio_fundo_programa}}{Município do fundo (texto).}
#'   \item{\code{codigo_ibge_fundo_programa}}{Código IBGE do fundo (texto ou numérico).}
#'   \item{\code{grupo_natureza_despesa_programa}}{Grupo de natureza de despesa do programa (texto).}
#'   \item{\code{codigo_descricao_orcamentaria_programa}}{Código ou descrição orçamentária do programa (texto).}
#'   \item{\code{descricao_acao_orcamentaria_programa}}{Descrição da ação orçamentária (texto).}
#'   \item{\code{valor_acao_orcamentaria_programa}}{Valor da ação orçamentária (numérico).}
#'   \item{\code{data_inicio_recebimento_planos_acao_beneficiarios_especificos}}{Data de início do recebimento de planos de ação para beneficiários específicos (formato YYYY-MM-DD).}
#'   \item{\code{data_fim_recebimento_planos_acao_beneficiarios_especificos}}{Data de fim do recebimento de planos de ação para beneficiários específicos (formato YYYY-MM-DD).}
#'   \item{\code{data_inicio_recebimento_planos_acao_beneficiarios_emendas}}{Data de início do recebimento de planos de ação para beneficiários de emendas (formato YYYY-MM-DD).}
#'   \item{\code{data_fim_recebimento_planos_acao_beneficiarios_emendas}}{Data de fim do recebimento de planos de ação para beneficiários de emendas (formato YYYY-MM-DD).}
#'   \item{\code{data_inicio_recebimento_planos_acao_beneficiarios_voluntarios}}{Data de início do recebimento de planos de ação para beneficiários voluntários (formato YYYY-MM-DD).}
#'   \item{\code{data_fim_recebimento_planos_acao_beneficiarios_voluntarios}}{Data de fim do recebimento de planos de ação para beneficiários voluntários (formato YYYY-MM-DD).}
#'   \item{\code{nome_gestao_agil_programa}}{Nome da gestão ágil do programa (texto).}
#' }
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: consultar programas do ano 2020, modalidade "Ordinário",
#'   # e com data de início dos planos de ação para beneficiários específicos a partir de "2020-01-01"
#'   prog <- ler_programas(
#'     ano_programa = 2020,
#'     modalidade_programa = "Ordinário",
#'     data_inicio_recebimento_planos_acao_beneficiarios_especificos = "2020-01-01"
#'   )
#'   head(prog)
#' }
#'
#' @export
ler_programas <- function(id_programa = NULL,
                         ano_programa = NULL,
                         modalidade_programa = NULL,
                         codigo_programa = NULL,
                         nome_programa = NULL,
                         id_unidade_gestora_programa = NULL,
                         nome_institucional_programa = NULL,
                         permite_transferencia_sem_fundo_programa = NULL,
                         objetivo_programa = NULL,
                         descricao_programa = NULL,
                         situacao_programa = NULL,
                         valor_global_programa = NULL,
                         quantidade_parcelas_programa = NULL,
                         id_orgao_superior_programa = NULL,
                         sigla_orgao_superior_programa = NULL,
                         cnpj_orgao_superior_programa = NULL,
                         nome_orgao_superior_programa = NULL,
                         id_fundo_programa = NULL,
                         cnpj_fundo_programa = NULL,
                         nome_fundo_programa = NULL,
                         uf_fundo_programa = NULL,
                         municipio_fundo_programa = NULL,
                         codigo_ibge_fundo_programa = NULL,
                         grupo_natureza_despesa_programa = NULL,
                         codigo_descricao_orcamentaria_programa = NULL,
                         descricao_acao_orcamentaria_programa = NULL,
                         valor_acao_orcamentaria_programa = NULL,
                         data_inicio_recebimento_planos_acao_beneficiarios_especificos = NULL,
                         data_fim_recebimento_planos_acao_beneficiarios_especificos = NULL,
                         data_inicio_recebimento_planos_acao_beneficiarios_emendas = NULL,
                         data_fim_recebimento_planos_acao_beneficiarios_emendas = NULL,
                         data_inicio_recebimento_planos_acao_beneficiarios_voluntarios = NULL,
                         data_fim_recebimento_planos_acao_beneficiarios_voluntarios = NULL,
                         nome_gestao_agil_programa = NULL) {

  # URL base corrigida: "fundoafundo" (e não "fundafundo")
  url <- "https://api.transferegov.gestao.gov.br/fundoafundo"

  # Cria um vetor de filtros no formato "nome_parametro=eq.valor"
  filters <- c()

  if (!is.null(id_programa))
    filters <- c(filters, paste0("id_programa=eq.", id_programa))
  if (!is.null(ano_programa))
    filters <- c(filters, paste0("ano_programa=eq.", ano_programa))
  if (!is.null(modalidade_programa))
    filters <- c(filters, paste0("modalidade_programa=eq.", modalidade_programa))
  if (!is.null(codigo_programa))
    filters <- c(filters, paste0("codigo_programa=eq.", codigo_programa))
  if (!is.null(nome_programa))
    filters <- c(filters, paste0("nome_programa=eq.", nome_programa))
  if (!is.null(id_unidade_gestora_programa))
    filters <- c(filters, paste0("id_unidade_gestora_programa=eq.", id_unidade_gestora_programa))
  if (!is.null(nome_institucional_programa))
    filters <- c(filters, paste0("nome_institucional_programa=eq.", nome_institucional_programa))
  if (!is.null(permite_transferencia_sem_fundo_programa))
    filters <- c(filters, paste0("permite_transferencia_sem_fundo_programa=eq.", permite_transferencia_sem_fundo_programa))
  if (!is.null(objetivo_programa))
    filters <- c(filters, paste0("objetivo_programa=eq.", objetivo_programa))
  if (!is.null(descricao_programa))
    filters <- c(filters, paste0("descricao_programa=eq.", descricao_programa))
  if (!is.null(situacao_programa))
    filters <- c(filters, paste0("situacao_programa=eq.", situacao_programa))
  if (!is.null(valor_global_programa))
    filters <- c(filters, paste0("valor_global_programa=eq.", valor_global_programa))
  if (!is.null(quantidade_parcelas_programa))
    filters <- c(filters, paste0("quantidade_parcelas_programa=eq.", quantidade_parcelas_programa))
  if (!is.null(id_orgao_superior_programa))
    filters <- c(filters, paste0("id_orgao_superior_programa=eq.", id_orgao_superior_programa))
  if (!is.null(sigla_orgao_superior_programa))
    filters <- c(filters, paste0("sigla_orgao_superior_programa=eq.", sigla_orgao_superior_programa))
  if (!is.null(cnpj_orgao_superior_programa))
    filters <- c(filters, paste0("cnpj_orgao_superior_programa=eq.", cnpj_orgao_superior_programa))
  if (!is.null(nome_orgao_superior_programa))
    filters <- c(filters, paste0("nome_orgao_superior_programa=eq.", nome_orgao_superior_programa))
  if (!is.null(id_fundo_programa))
    filters <- c(filters, paste0("id_fundo_programa=eq.", id_fundo_programa))
  if (!is.null(cnpj_fundo_programa))
    filters <- c(filters, paste0("cnpj_fundo_programa=eq.", cnpj_fundo_programa))
  if (!is.null(nome_fundo_programa))
    filters <- c(filters, paste0("nome_fundo_programa=eq.", nome_fundo_programa))
  if (!is.null(uf_fundo_programa))
    filters <- c(filters, paste0("uf_fundo_programa=eq.", uf_fundo_programa))
  if (!is.null(municipio_fundo_programa))
    filters <- c(filters, paste0("municipio_fundo_programa=eq.", municipio_fundo_programa))
  if (!is.null(codigo_ibge_fundo_programa))
    filters <- c(filters, paste0("codigo_ibge_fundo_programa=eq.", codigo_ibge_fundo_programa))
  if (!is.null(grupo_natureza_despesa_programa))
    filters <- c(filters, paste0("grupo_natureza_despesa_programa=eq.", grupo_natureza_despesa_programa))
  if (!is.null(codigo_descricao_orcamentaria_programa))
    filters <- c(filters, paste0("codigo_descricao_orcamentaria_programa=eq.", codigo_descricao_orcamentaria_programa))
  if (!is.null(descricao_acao_orcamentaria_programa))
    filters <- c(filters, paste0("descricao_acao_orcamentaria_programa=eq.", descricao_acao_orcamentaria_programa))
  if (!is.null(valor_acao_orcamentaria_programa))
    filters <- c(filters, paste0("valor_acao_orcamentaria_programa=eq.", valor_acao_orcamentaria_programa))
  if (!is.null(data_inicio_recebimento_planos_acao_beneficiarios_especificos))
    filters <- c(filters, paste0("data_inicio_recebimento_planos_acao_beneficiarios_especificos=eq.", data_inicio_recebimento_planos_acao_beneficiarios_especificos))
  if (!is.null(data_fim_recebimento_planos_acao_beneficiarios_especificos))
    filters <- c(filters, paste0("data_fim_recebimento_planos_acao_beneficiarios_especificos=eq.", data_fim_recebimento_planos_acao_beneficiarios_especificos))
  if (!is.null(data_inicio_recebimento_planos_acao_beneficiarios_emendas))
    filters <- c(filters, paste0("data_inicio_recebimento_planos_acao_beneficiarios_emendas=eq.", data_inicio_recebimento_planos_acao_beneficiarios_emendas))
  if (!is.null(data_fim_recebimento_planos_acao_beneficiarios_emendas))
    filters <- c(filters, paste0("data_fim_recebimento_planos_acao_beneficiarios_emendas=eq.", data_fim_recebimento_planos_acao_beneficiarios_emendas))
  if (!is.null(data_inicio_recebimento_planos_acao_beneficiarios_voluntarios))
    filters <- c(filters, paste0("data_inicio_recebimento_planos_acao_beneficiarios_voluntarios=eq.", data_inicio_recebimento_planos_acao_beneficiarios_voluntarios))
  if (!is.null(data_fim_recebimento_planos_acao_beneficiarios_voluntarios))
    filters <- c(filters, paste0("data_fim_recebimento_planos_acao_beneficiarios_voluntarios=eq.", data_fim_recebimento_planos_acao_beneficiarios_voluntarios))
  if (!is.null(nome_gestao_agil_programa))
    filters <- c(filters, paste0("nome_gestao_agil_programa=eq.", nome_gestao_agil_programa))

  # Chama a função pg.get passando a URL e o vetor de filtros
  pg.get(url, table="programa",
         filter = filters)
}
