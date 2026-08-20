##renuncias fiscais por município:

pega_renuncias_e_espera <- \(x){
  lapply(x,consultar_renuncias_fiscais)
  system("sleep 55")
}

renuncias <- lapply(lapply(1:2,\(x){(x-1)*700+1:700}),pega_renuncias_e_espera)



####
##Dados de renúncias fiscais:

anos <- 2015:2024

links_baixar <- glue::glue("https://dadosabertos-download.cgu.gov.br/PortalDaTransparencia/saida/renuncias/{anos}_RenunciasFiscais.zip")


pasta_renuncias <- "cache/renuncias/"

nomes_arquivos <- paste0(pasta_renuncias,gsub(".*/([^/]+$)","\\1",links_baixar))


mapply(\(x,y) {download.file(x,y)},links_baixar,nomes_arquivos)

lapply(nomes_arquivos,\(x){archive::archive_extract(x,dir=pasta_renuncias)})

renuncias <- data.table::rbindlist(lapply(gsub("_Renun","_Renún",gsub("zip","csv",nomes_arquivos)),data.table::fread,encoding="Latin-1"))

renuncias <-
  renuncias|>
  dplyr::mutate(
    Município = dplyr::case_when(
      Município == "EMBU" ~ "EMBU DAS ARTES",
      Município == "BIRITIBA-MIRIM" ~ "BIRITIBA MIRIM",
      Município == "SANTA ISABEL DO PARÁ" ~ "SANTA IZABEL DO PARÁ",
      Município == "SANTANA DO LIVRAMENTO" ~ "SANT'ANA DO LIVRAMENTO",
      Município == "SANTO ANTÔNIO DO LEVERGER" ~ "SANTO ANTÔNIO DE LEVERGER",
      Município == "ELDORADO DOS CARAJÁS" ~ "ELDORADO DO CARAJÁS",
      Município == "POXORÉO" ~ "POXORÉU",
      Município == "ITAPAGÉ" ~ "ITAPAJÉ",
      Município == "GRÃO PARÁ" ~ "GRÃO-PARÁ",
      Município == "SÃO LUÍS DO PARAITINGA" ~ "SÃO LUIZ DO PARAITINGA",
      Município == "DONA EUSÉBIA" ~ "DONA EUZÉBIA",
      Município == "AUGUSTO SEVERO" ~ "CAMPO GRANDE",
      Município == "BRASÓPOLIS" ~ "BRAZÓPOLIS",
      Município == "SERIDÓ" ~ "SÃO VICENTE DO SERIDÓ" ,
      T ~ Município
    )
  )

pormunano <- renuncias[,.(valor=sum(`Valor Renúncia Fiscal (R$)`,na.rm=TRUE)),by = .(`Ano-calendário`,Município,UF)]

pormunano$valor <- pormunano$valor

tiracento <- \(x){
  toupper(stringi::stri_trans_general(x,"latin-ascii"))
}

mapa_gtrib <- pop_municipios|>dplyr::mutate(across(ano,lubridate::year))|>
  dplyr::left_join(municipios_siafi_ibge) |>
  dplyr::mutate(across(nome_municipio,tiracento))|>
  dplyr::right_join(pormunano|>dplyr::mutate(across(`Município`,tiracento)),by=c("nome_municipio"="Município","uf"="UF","ano"="Ano-calendário"))

mapamunicipios <- geobr::read_municipality(year=2022)

mmapa_gtrib <- mapa_gtrib|>
  dplyr::mutate(renuncia_pc=valor/populacao)|>
  dplyr::left_join(mapamunicipios,by=c("codigo_ibge"="code_muni"))

mmapa_gtrib[is.na(mmapa_gtrib$populacao),]$populacao <- 1

library(ggplot2)
plotagtrib <- \(anop=2023) {
  ggplot(mmapa_gtrib[mmapa_gtrib$ano == anop & !is.na(mmapa_gtrib$codigo_ibge),],aes(fill=renuncia_pc,geometry=geom))+
  geom_sf()+
  geom_sf(data=geobr::read_state(),fill=NA,linewidth=0.1)+
  scale_fill_viridis_b(breaks=c(0,500,1500,3000,5000,15000,50000)/2)+
    labs(title = paste0("Renúncias fiscais - R$ per capita - ",anop))+
  theme_minimal()

}


gtrib19 <- plotagtrib(2019)

gtrib23 <- plotagtrib()
gtrib24 <- plotagtrib(2024)

#Valores de Renúncias Fiscais por Localidade do Beneficiário
# A localidade da pessoa jurídica beneficiária é baseada no endereço da matriz registrado no Cadastro Nacional da Pessoa Jurídica (CNPJ), tendo em vista o agrupamento de benefícios das filiais nas respectivas matrizes.
#
#
#
# -> renúncia fiscal por cnpj
# -> cnpj -> rais, massa_sal x município
#
# -> municipalização

##Até 2020
lgtribpf <- "https://www.gov.br/receitafederal/dados/municipio-de-residencia-do-declarante-e-tipo-de-formulario.csv/@@download/file/Município de Residência do Declarante e Tipo de Formulário.csv"
ngtribpf <- "irpf_grandes_numeros_municipio.csv"
download.file(lgtribpf,paste0(pasta_renuncias,ngtribpf))

pfgtrib <- data.table::fread(paste0(pasta_renuncias,ngtribpf),sep=";",dec=",")

pfgtrib <- pfgtrib|>
  dplyr::mutate(across(`Quantidade de Declarantes`:`Doações Efetuadas`,\(x) {as.numeric(gsub(",",".",x))}))


### Após
#2023

lgtribpf23 <- "https://www.gov.br/receitafederal/pt-br/centrais-de-conteudo/publicacoes/estudos/imposto-de-renda/estudos-por-ano/grandes-numeros-do-IRPF-2008-a-2023/grandes-numeros-do-irpf-2024-ano-calendario-2023-tabelas-1/@@download/file"
n23gtribpf <- "irpf_grandes_numeros_2023.xlsx"
download.file(lgtribpf23,paste0(pasta_renuncias,n23gtribpf))


gtribpf23 <- readxl::read_xlsx(paste0(pasta_renuncias,n23gtribpf),sheet="Tab13",skip=1)
gtribpf23$ano <- 2023

gtribpf19 <- readxl::read_xlsx(gsub(2023,2019,paste0(pasta_renuncias,n23gtribpf)),sheet="Tab12B_Municipio",skip=12,col_names = FALSE)
colunas_gtribpf19 <- readxl::read_xlsx(gsub(2023,2019,paste0(pasta_renuncias,n23gtribpf)),sheet="Tab12B_Municipio",skip=9,col_names = FALSE,n_max=2)
colunas_gtribpf19 <- gsub(" - NA","",as.character(paste0(t(zoo::na.locf(t(colunas_gtribpf19[1,])))," - ",colunas_gtribpf19[2,])))
names(gtribpf19) <- janitor::make_clean_names(colunas_gtribpf19)
gtribpf19$ano <- 2019

resumo_deducoes_19 <-
  gtribpf19|>group_by(municipio)|>summarize(across(ano,first),across(c(qtde_declarantes,contains('deducoes')),\(x){sum(x,na.rm=T)}))|>transmute(ano,municipio,total_deducoes=rowSums(across(3:13))*qtde_declarantes)

resumo_deducoes_23 <-
  gtribpf23|>group_by(descricao)|>
  summarize(across(ano,first),across(c(qtde_contribuintes,contains('deducao')),\(x){sum(x,na.rm=T)}))|>
  transmute(ano,municipio=descricao,total_deducoes=rowSums(across(3:13))*qtde_contribuintes)
