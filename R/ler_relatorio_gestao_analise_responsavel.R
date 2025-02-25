#' Ler dados do endpoint relatorio_gestao_analise_responsavel
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

  pg.get(table = table, filter = filters)
}
