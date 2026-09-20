#' @title Ler dados de Análise do Relatório de Gestão da API TransfereGov
#'
#' @description Esta função acessa os dados do endpoint **relatorio_gestao_analise** da API FundoaFundo
#' (TransfereGov) utilizando a função interna \code{pg_get}.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato
#' "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' @param id_relatorio_gestao_analise Identificador único da análise do relatório de gestão (numérico).
#' @param tipo_analise_relatorio_gestao_analise Tipo da análise do relatório de gestão (texto).
#' @param resultado_analise_relatorio_gestao_analise Resultado da análise do relatório de gestão (texto).
#' @param parecer_analise_relatorio_gestao_analise Parecer da análise do relatório de gestão (texto).
#' @param origem_analise_relatorio_gestao_analise Origem da análise do relatório de gestão (texto).
#' @param data_analise_relatorio_gestao_analise Data da análise do relatório de gestão (formato YYYY-MM-DD).
#' @param versao_analise_relatorio_gestao_analise Versão da análise do relatório de gestão (numérico).
#' @param id_relatorio_gestao Identificador do relatório de gestão associado (numérico).
#'
#' @param select Vetor de caracteres com os nomes das colunas a serem
#'   retornadas. Quando \code{NULL} (padrão), todas as colunas do endpoint
#'   são retornadas.
#' @param order Vetor de caracteres com os critérios de ordenação, no formato
#'   \code{"coluna.asc"} ou \code{"coluna.desc"}. Quando \code{NULL}
#'   (padrão), a ordem definida pela API é mantida.
#' @return Um objeto contendo os dados retornados pela API (geralmente um data.frame).
#'
#' @examples
#' \donttest{
#'   # Exemplo: ler análises vinculadas a um relatório de gestão
#'   analises <- ler_relatorio_gestao_analise(id_relatorio_gestao = 12345)
#'   head(analises)
#' }
#'
#' @export
ler_relatorio_gestao_analise <- function(id_relatorio_gestao_analise = NULL,
                                         tipo_analise_relatorio_gestao_analise = NULL,
                                         resultado_analise_relatorio_gestao_analise = NULL,
                                         parecer_analise_relatorio_gestao_analise = NULL,
                                         origem_analise_relatorio_gestao_analise = NULL,
                                         data_analise_relatorio_gestao_analise = NULL,
                                         versao_analise_relatorio_gestao_analise = NULL,
                                         id_relatorio_gestao = NULL,
                                         select = NULL,
                                         order = NULL) {

  table <- "relatorio_gestao_analise"
  filters <- c()

  if (!is.null(id_relatorio_gestao_analise))
    filters <- c(filters, paste0("id_relatorio_gestao_analise=eq.", id_relatorio_gestao_analise))
  if (!is.null(tipo_analise_relatorio_gestao_analise))
    filters <- c(filters, paste0("tipo_analise_relatorio_gestao_analise=eq.", tipo_analise_relatorio_gestao_analise))
  if (!is.null(resultado_analise_relatorio_gestao_analise))
    filters <- c(filters, paste0("resultado_analise_relatorio_gestao_analise=eq.", resultado_analise_relatorio_gestao_analise))
  if (!is.null(parecer_analise_relatorio_gestao_analise))
    filters <- c(filters, paste0("parecer_analise_relatorio_gestao_analise=eq.", parecer_analise_relatorio_gestao_analise))
  if (!is.null(origem_analise_relatorio_gestao_analise))
    filters <- c(filters, paste0("origem_analise_relatorio_gestao_analise=eq.", origem_analise_relatorio_gestao_analise))
  if (!is.null(data_analise_relatorio_gestao_analise))
    filters <- c(filters, paste0("data_analise_relatorio_gestao_analise=eq.", data_analise_relatorio_gestao_analise))
  if (!is.null(versao_analise_relatorio_gestao_analise))
    filters <- c(filters, paste0("versao_analise_relatorio_gestao_analise=eq.", versao_analise_relatorio_gestao_analise))
  if (!is.null(id_relatorio_gestao))
    filters <- c(filters, paste0("id_relatorio_gestao=eq.", id_relatorio_gestao))

  pg_get(table = table, filter = filters, select = select, order = order)
}
