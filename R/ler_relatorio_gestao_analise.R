#' Ler dados do endpoint relatorio_gestao_analise
#'
#' @export
ler_relatorio_gestao_analise <- function(id_relatorio_gestao_analise = NULL,
                                         tipo_analise_relatorio_gestao_analise = NULL,
                                         resultado_analise_relatorio_gestao_analise = NULL,
                                         parecer_analise_relatorio_gestao_analise = NULL,
                                         origem_analise_relatorio_gestao_analise = NULL,
                                         data_analise_relatorio_gestao_analise = NULL,
                                         versao_analise_relatorio_gestao_analise = NULL,
                                         id_relatorio_gestao = NULL) {

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

  pg.get(table = table, filter = filters)
}
