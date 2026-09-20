#' @title Ler dados de Responsáveis pela Análise do Relatório de Gestão da API TransfereGov
#'
#' @description Esta função acessa os dados do endpoint **relatorio_gestao_analise_responsavel**
#' da API FundoaFundo (TransfereGov) utilizando a função interna \code{pg_get}.
#' Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato
#' "nome_parametro=eq.valor". Todos os parâmetros são opcionais.
#'
#' @param relatorio_gestao_analise_fk Identificador da análise do relatório de gestão à qual o responsável está vinculado (numérico).
#' @param nome_responsavel_analise_relatorio_gestao_analise Nome do responsável pela análise do relatório de gestão (texto).
#' @param cargo_responsavel_analise_relatorio_gestao_analise Cargo do responsável pela análise do relatório de gestão (texto).
#'
#' @return Um objeto contendo os dados retornados pela API (geralmente um data.frame).
#'
#' @examples
#' \dontrun{
#'   # Exemplo: ler responsáveis vinculados a uma análise
#'   responsaveis <- ler_relatorio_gestao_analise_responsavel(relatorio_gestao_analise_fk = 12345)
#'   head(responsaveis)
#' }
#'
#' @export
ler_relatorio_gestao_analise_responsavel <- function(relatorio_gestao_analise_fk = NULL,
                                                     nome_responsavel_analise_relatorio_gestao_analise = NULL,
                                                     cargo_responsavel_analise_relatorio_gestao_analise = NULL) {
  table <- "relatorio_gestao_analise_responsavel"
  filters <- c()

  if (!is.null(relatorio_gestao_analise_fk))
    filters <- c(filters, paste0("relatorio_gestao_analise_fk=eq.", relatorio_gestao_analise_fk))
  if (!is.null(nome_responsavel_analise_relatorio_gestao_analise))
    filters <- c(filters, paste0("nome_responsavel_analise_relatorio_gestao_analise=eq.", nome_responsavel_analise_relatorio_gestao_analise))
  if (!is.null(cargo_responsavel_analise_relatorio_gestao_analise))
    filters <- c(filters, paste0("cargo_responsavel_analise_relatorio_gestao_analise=eq.", cargo_responsavel_analise_relatorio_gestao_analise))

  pg_get(table = table, filter = filters)
}
