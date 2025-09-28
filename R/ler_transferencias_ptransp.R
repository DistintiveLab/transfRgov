#' @title Baixar Dados de Transferências da União
#' @description Baixa dados de transferências de recursos da União do Portal da Transparência para um ano e mês específicos.
#' @param ano O ano dos dados (inteiro, e.g., 2023).
#' @param mes O mês dos dados (inteiro, 1-12).
#' @return Um data frame contendo os dados de transferências. Retorna NULL (invisível) se ocorrer um erro.
#' @details
#' Esta função acessa a página de download para o ano e mês especificados no Portal da Transparência,
#' identifica o link do arquivo ZIP de "Recursos transferidos", baixa, descompacta e lê o arquivo CSV.
#' O dicionário de dados pode ser consultado em \url{https://portaldatransparencia.gov.br/pagina-interna/603420-dicionario-de-dados-recursos-transferidos}.
#' A função lida com arquivos temporários e tenta ler o CSV considerando a codificação e separadores comuns no Portal.
#' Requer os pacotes 'httr', 'rvest', 'readr' e 'utils'.
#' @importFrom httr GET content
#' @importFrom rvest read_html html_nodes html_attr
#' @importFrom readr read_delim cols col_character
#' @importFrom utils unzip download.file
#' @export
download_transferencias_uniao <- function(ano, mes,codigo_ibge=T) {

  # --- 1. Validação e Construção da URL Intermediária ---
  if (!is.numeric(ano) || length(ano) != 1 || ano < 2000 || ano > as.integer(format(Sys.Date(), "%Y"))) {
    stop("O parâmetro 'ano' deve ser um inteiro válido representando o ano.")
  }
  if (!is.numeric(mes) || length(mes) != 1 || mes < 1 || mes > 12) {
    stop("O parâmetro 'mes' deve ser um inteiro entre 1 e 12.")
  }

  mes_str <- sprintf("%02d", as.integer(mes)) # Formata o mês com zero à esquerda (e.g., 01, 02)
  ano_str <- as.character(as.integer(ano))

  # URL da página intermediária que contém o link para o ZIP
  zip_url <- paste0("https://dadosabertos-download.cgu.gov.br/PortalDaTransparencia/saida/transferencias/", ano_str, mes_str, "_Transferencias.zip")
  #message("Acessando a página: ", intermediate_url)




  # --- 3. Baixar o arquivo ZIP ---
  temp_zip <- tempfile(fileext = ".zip") # Cria um nome de arquivo temporário para o ZIP
  message("Baixando ZIP para: ", temp_zip)

  download_status <- tryCatch({
    # Usar 'mode = "wb"' para garantir que o download seja tratado como arquivo binário
    download.file(zip_url, temp_zip, mode = "wb")
    TRUE # Indica sucesso
  }, error = function(e) {
    warning("Erro ao baixar arquivo ZIP de ", zip_url, ": ", e$message)
    FALSE # Indica falha
  })

  # Se o download falhou, limpa e retorna NULL
  if (!download_status) {
    if (file.exists(temp_zip)) unlink(temp_zip) # Limpa o arquivo temporário se criado parcialmente
    return(invisible(NULL))
  }


  # --- 4. Descompactar o arquivo ---
  temp_dir <- tempdir() # Diretório temporário para descompactar
  extracted_files <- tryCatch({
    unzip(temp_zip, exdir = temp_dir)
  }, error = function(e) {
    warning("Erro ao descompactar o arquivo ZIP ", temp_zip, ": ", e$message)
    # Limpa arquivos temporários antes de sair
    if (file.exists(temp_zip)) unlink(temp_zip)
    return(NULL) # Indica falha
  })

  if (is.null(extracted_files) || length(extracted_files) == 0) {
    warning("Falha na descompactação ou nenhum arquivo foi extraído.")
    # Limpa arquivos temporários
    if (file.exists(temp_zip)) unlink(temp_zip)
    return(invisible(NULL))
  }

  # Tenta encontrar o arquivo CSV extraído (geralmente há apenas um)
  csv_file <- extracted_files[grep("\\.csv$", extracted_files, ignore.case = TRUE)][1]

  if (is.na(csv_file) || !file.exists(csv_file)) {
    warning("Não foi encontrado um arquivo CSV após a descompactação.")
    # Limpa arquivos temporários
    if (file.exists(temp_zip)) unlink(temp_zip)
    if (length(extracted_files) > 0 && all(file.exists(extracted_files))) unlink(extracted_files)
    return(invisible(NULL))
  }
  message("Arquivo CSV extraído: ", csv_file)

  # --- 5. Ler o arquivo CSV ---
  # O Portal usa frequentemente ';' como separador, ',' como decimal, e codificação ISO-8859-1 (Latin1)
  # É recomendado usar readr::read_delim por ser mais robusto, especialmente com codificação
  dados <- tryCatch({
    suppressWarnings(readr::read_delim(
      csv_file,
      delim = ";",
      quote = "\"",
      col_names = TRUE, # Assume que a primeira linha é o cabeçalho
      locale = readr::locale(encoding = "ISO-8859-1", decimal_mark = ","),
      # Pode ser útil ler a maioria das colunas como texto para evitar problemas
      # com tipos mistos, zeros à esquerda, etc., e converter depois
      # col_types = cols(.default = col_character()),
      show_col_types = FALSE # Não mostrar a mensagem de inferência de tipos do readr
    )|>janitor::clean_names())
  }, error = function(e) {
    warning("Erro ao ler arquivo CSV com readr: ", e$message, "\nTentar ler com base R read.csv...")
    # Tenta com a função base read.csv como alternativa
    tryCatch({
      read.csv(
        csv_file,
        sep = ";",
        dec = ",",
        header = TRUE,
        encoding = "Latin1", # Tenta Latin1, pode ser necessário tentar "UTF-8"
        stringsAsFactors = FALSE
      )|>janitor::clean_names()
    }, error = function(e2) {
      warning("Falha ao ler arquivo CSV com base R read.csv: ", e2$message)
      return(NULL) # Indica falha total
    })
  })


  # --- 6. Limpar arquivos temporários ---
  # Garante que os arquivos temporários sejam removidos
  if (file.exists(temp_zip)) unlink(temp_zip)
  if (file.exists(csv_file)) unlink(csv_file) # Limpa o arquivo CSV extraído também


  # --- 7. Retornar o data frame ou NULL se falhou ---
  if (is.null(dados)) {
    warning("Falha final ao processar os dados de ", ano_str, "-", mes_str, ".")
    return(invisible(NULL))
  }

  message("Dados de ", ano_str, "-", mes_str, " baixados e lidos com sucesso. ",
          nrow(dados), " linhas, ", ncol(dados), " colunas.")

  # --- 8. O Dicionário de Dados ---
  # O dicionário NÃO é aplicado magicamente aqui.
  # Você deve consultá-lo manualmente para entender as colunas retornadas (dados$NomeColuna...).
  # As informações do dicionário devem ser usadas na documentação desta função (@details ou @section).
  # Ex: Descrever o que 'CD FAVORECIDO' significa.
  # Se quiser, pode adicionar um atributo ao data frame:
  # attr(dados, "dicionario_url") <- "https://portaldatransparencia.gov.br/pagina-interna/603420-dicionario-de-dados-recursos-transferidos"

  if(codigo_ibge==T){
    dados <- dados|>dplyr::left_join(municipios_siafi_ibge|>dplyr::select(codigo_municipio_siafi,codigo_ibge))
  }
  return(dados)
}
