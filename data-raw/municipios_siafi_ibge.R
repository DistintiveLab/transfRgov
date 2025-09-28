## code to prepare `municipios_siafi_ibge` dataset goes here
mapping_url <- "https://www.tesourotransparente.gov.br/ckan/dataset/abb968cb-3710-4f85-89cf-875c91b9c7f6/resource/eebb3bc6-9eea-4496-8bcf-304f33155282/download/tabmun.csv"
temp_csv <- tempfile(fileext = ".csv") # Arquivo temporário para o CSV
download.file(mapping_url, temp_csv, mode = "wb", quiet = TRUE)

municipios_siafi_ibge <- readr::read_csv2(
  temp_csv,
  col_names = c('codigo_municipio_siafi','cnpj','nome_municipio','uf','codigo_ibge'),
  locale = readr::locale(encoding = "UTF-8"), # Tenta UTF-8
  col_types =  cols(.default = readr::col_character(),codigo_ibge = readr::col_number()), # Ler tudo como texto
  show_col_types = FALSE
)

usethis::use_data(municipios_siafi_ibge, overwrite = TRUE)
