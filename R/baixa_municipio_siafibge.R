#' @title Obter Mapeamento SIAFI-IBGE de Municípios
#' @description Baixa a tabela de mapeamento entre códigos SIAFI e IBGE de municípios
#' do Tesouro Transparente.
#' @return Um data frame contendo o mapeamento de municípios. Retorna NULL (invisível) se ocorrer um erro.
#' @details
#' Esta função baixa o arquivo tabmun.csv, que contém o mapeamento entre códigos SIAFI
#' e IBGE de municípios brasileiros, do portal Tesouro Transparente CKAN.
#' Os dados são comumente separados por vírgulas e podem estar em codificação UTF-8 ou Latin1.
#' É crucial que as colunas de código sejam lidas como texto para preservar zeros à esquerda
#' antes de realizar joins.
#' Requer o pacote 'readr' e 'utils'.
#' @importFrom readr read_csv cols col_character
#' @importFrom utils download.file
#' @export
baixa_municipio_siafibge <- function() {
  mapping_url <- "https://www.tesourotransparente.gov.br/ckan/dataset/abb968cb-3710-4f85-89cf-875c91b9c7f6/resource/eebb3bc6-9eea-4496-8bcf-304f33155282/download/tabmun.csv"
  message("Tentando baixar mapeamento de: ", mapping_url)

  temp_csv <- tempfile(fileext = ".csv") # Arquivo temporário para o CSV
  message("Baixando CSV de mapeamento para: ", temp_csv)

  download_status <- tryCatch({
    download.file(mapping_url, temp_csv, mode = "wb", quiet = TRUE)
    TRUE # Indica sucesso
  }, error = function(e) {
    warning("Erro ao baixar arquivo CSV de mapeamento de ", mapping_url, ": ", e$message)
    FALSE # Indica falha
  })

  if (!download_status) {
    if (file.exists(temp_csv)) unlink(temp_csv)
    return(invisible(NULL))
  }


  # Ler o arquivo CSV. Geralmente é separado por vírgula e pode ser UTF-8.
  # Ler todas as colunas como texto para garantir a preservação dos códigos.
  mapping_data <- tryCatch({
    readr::read_csv2(
      temp_csv,
      col_names = c('codigo_municipio_siafi','id','nome_municipio','uf','codigo_ibge'),
      locale = readr::locale(encoding = "UTF-8"), # Tenta UTF-8
      col_types = cols(.default = col_character(),codigo_ibge = col_number()), # Ler tudo como texto
      show_col_types = FALSE
    )
  }, error = function(e) {
    warning("Erro ao ler arquivo CSV de mapeamento com readr (assumindo UTF-8): ", e$message, "\nTentando com Latin1 e read.csv...")
    # Tenta com Latin1 e read.csv como alternativa
    tryCatch({
      read.csv(
        temp_csv,
        sep = ",", # Geralmente CSV é separado por vírgula
        header = TRUE,
        encoding = "Latin1", # Tenta Latin1
        stringsAsFactors = FALSE
      )
    }, error = function(e2) {
      warning("Falha ao ler arquivo CSV de mapeamento com read.csv (assumindo Latin1): ", e2$message)
      return(NULL) # Indica falha total
    })
  })

  # Limpa o arquivo temporário
  if (file.exists(temp_csv)) unlink(temp_csv)

  if (is.null(mapping_data)) {
    warning("Falha final ao processar os dados de mapeamento de municípios.")
    return(invisible(NULL))
  }

  message("Dados de mapeamento de municípios baixados e lidos com sucesso. ",
          nrow(mapping_data), " linhas, ", ncol(mapping_data), " colunas.")

  # Consulte a estrutura do arquivo baixado para saber os nomes exatos das colunas de código
  # Ex: Colunas podem ser "COD_MUN_SIAFI", "COD_MUN_IBGE", "NOME_MUNICIPIO", etc.
  # Renomear para facilitar o join? Ex:
  # names(mapping_data) <- tolower(names(mapping_data)) # Opcional: tudo minúsculo
  # if("cod_mun_siafi" %in% names(mapping_data) && "cod_mun_ibge" %in% names(mapping_data)) {
  #    # OK, colunas esperadas presentes
  # } else {
  #     warning("As colunas esperadas ('COD_MUN_SIAFI', 'COD_MUN_IBGE') não foram encontradas no mapeamento.")
  #     # Pode ser útil parar ou retornar NULL aqui
  # }


  return(mapping_data)
}

# Exemplo de uso:
# mapeamento_municipios <- baixa_municipio_siafibge()
# if (!is.null(mapeamento_municipios)) {
#   print(head(mapeamento_municipios))
# }
