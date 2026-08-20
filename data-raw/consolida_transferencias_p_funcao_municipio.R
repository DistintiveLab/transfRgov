
consolida_tr_funcao <- \(ano){

  dados <- data.table::rbindlist(lapply(1:12,\(x) transfRgov:::download_transferencias_uniao(ano,x,municipios_mapping = municipios_siafi_ibge)|>
                                          dplyr::mutate(ano=trunc(ano_mes/100))),use.names = TRUE)

dados|>
  dplyr::mutate(privadopub=ifelse(grepl("Privadas",nome_modalidade_aplicacao_despesa),'inst_privadas','publico'))|>
  dplyr::group_by(ano,codigo_ibge,uf,tipo_transferencia,privadopub,nome_funcao)|>
  dplyr::summarize(valor_transferido=sum(valor_transferido,na.rm=T))|>
  tidyr::pivot_wider(names_from=c('tipo_transferencia','privadopub'),values_from='valor_transferido',values_fill = 0)
#|>
#dplyr::rename('governo_e_publico'='FALSE','privadas'='TRUE')

}



transfpubs_14_24 <-
  data.table::rbindlist(lapply(2014:2024,\(x) consolida_tr_funcao(x)))


#names(transfpubs_14_24)[5:6] <- c('governo_e_publico','privadas')

transfpubswide <- transfpubs_14_24|>
  dplyr::select(-privadas)|>
  tidyr::pivot_wider(names_from=nome_funcao,values_from=governo_e_publico,values_fill=0)|>
  dplyr::mutate(transftotal=rowSums(dplyr::across(-c(ano,codigo_ibge))))


gastostrib <- "https://www.gov.br/receitafederal/pt-br/centrais-de-conteudo/publicacoes/relatorios/renuncia/gastos-tributarios-bases-efetivas/dgt-bases-efetivas-2022-serie-2020-a-2025-quadros.xlsx/@@download/file"
gtrib <- tempfile(fileext = ".xlsx")
download.file(gastostrib,gtrib,method="wget",extra = "--no-check-certificate")
gtribx <- readxl::read_xlsx(gtrib,skip=4)
gtribquadros <- readxl::excel_sheets(gtrib)



##cebas
