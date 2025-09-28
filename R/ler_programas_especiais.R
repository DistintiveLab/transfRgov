# Certifique-se de que o pacote postgrestR está instalado e carregado.
# Se ainda não estiver, instale-o: install.packages("postgrestR")
# library(postgrestR) # Certifique-se de que está no DESCRIPTION do seu pacote (Imports: postgrestR)

#' @title Ler dados de Programa Especial da API TransfereGov
#' @description Esta função acessa os dados do endpoint **programa_especial** da API
#' TransfereGov utilizando a função \code{pg.get} do pacote postgrestR.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato
#' "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' @param id_programa Identificador único do programa especial (numérico).
#' @param ano_programa Ano do programa especial (numérico).
#' @param nome_programa Nome ou descrição do programa especial (texto).
#' @param situacao_programa Situação atual do programa (e.g., "Ativo", "Concluído") (texto).
#' @param id_proponente Identificador do proponente (e.g., CNPJ, CPF) (texto).
#' @param data_inicio Data de início do programa (formato YYYY-MM-DD).
#' @param data_fim Data de fim do programa (formato YYYY-MM-DD).
#' @param esfera Nível da esfera do programa (e.g., "FEDERAL", "ESTADUAL", "MUNICIPAL") (texto).
#' @param orgao_executor Nome ou código do órgão executor do programa (texto).
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente um data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: ler programas especiais do ano de 2022
#'   programas_2022 <- ler_programa_especial(ano_programa = 2022)
#'   head(programas_2022)
#'
#'   # Exemplo: ler programas com um ID específico
#'   programa_especifico <- ler_programa_especial(id_programa = 12345)
#'   head(programa_especifico)
#' }
#'
#' @importFrom postgrestR pg.get
#' @export
ler_programa_especial <- function(id_programa = NULL,
                                  ano_programa = NULL,
                                  nome_programa = NULL,
                                  situacao_programa = NULL,
                                  id_proponente = NULL,
                                  data_inicio = NULL,
                                  data_fim = NULL,
                                  esfera = NULL,
                                  orgao_executor = NULL) {

  table <- "programa_especial" # Nome da tabela para o endpoint de Programa Especial
  filters <- c()

  if (!is.null(id_programa))
    filters <- c(filters, paste0("id_programa=eq.", id_programa))
  if (!is.null(ano_programa))
    filters <- c(filters, paste0("ano_programa=eq.", ano_programa))
  if (!is.null(nome_programa))
    filters <- c(filters, paste0("nome_programa=eq.", nome_programa))
  if (!is.null(situacao_programa))
    filters <- c(filters, paste0("situacao_programa=eq.", situacao_programa))
  if (!is.null(id_proponente))
    filters <- c(filters, paste0("id_proponente=eq.", id_proponente))
  if (!is.null(data_inicio))
    filters <- c(filters, paste0("data_inicio=eq.", data_inicio))
  if (!is.null(data_fim))
    filters <- c(filters, paste0("data_fim=eq.", data_fim))
  if (!is.null(esfera))
    filters <- c(filters, paste0("esfera=eq.", esfera))
  if (!is.null(orgao_executor))
    filters <- c(filters, paste0("orgao_executor=eq.", orgao_executor))

  pg.get(table = table, filter = filters)
}

