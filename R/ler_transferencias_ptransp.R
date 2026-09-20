#' @title Baixar Dados de Transferências da União
#' @description Baixa dados de transferências de recursos da União do Portal da Transparência para um ano e mês específicos.
#' @param ano O ano dos dados (inteiro, e.g., 2023).
#' @param mes O mês dos dados (inteiro, 1-12).
#' @param codigo_ibge Lógico. Se \code{TRUE} (o padrão), acrescenta a coluna
#'   \code{codigo_ibge} aos dados, por meio do mapeamento SIAFI-IBGE.
#' @param municipios_mapping possibilidade de passar mapeamento distinto do padrão incluído no pacote
#' @return Um data frame contendo os dados de transferências. Retorna NULL (invisível) se ocorrer um erro.
#' @details
#' Esta função monta a URL do arquivo ZIP de "Recursos transferidos" do Portal da
#' Transparência referente ao ano e mês informados, baixa o arquivo, descompacta
#' e lê o CSV resultante.
#' O dicionário de dados pode ser consultado em \url{https://portaldatransparencia.gov.br/pagina-interna/603420-dicionario-de-dados-recursos-transferidos}.
#' A função lida com arquivos temporários e tenta ler o CSV considerando a
#' codificação e os separadores comuns no Portal.
#' Requer os pacotes 'readr', 'janitor' e 'utils'.
#' @importFrom readr read_delim locale
#' @importFrom utils unzip download.file read.csv
#' @export
download_transferencias_uniao <- function(ano, mes, codigo_ibge = TRUE, municipios_mapping = NULL) {

  # --- 1. Validação e Construção da URL ---
  if (!is.numeric(ano) || length(ano) != 1 || ano < 2000 || ano > as.integer(format(Sys.Date(), "%Y"))) {
    stop("O par\u00e2metro 'ano' deve ser um inteiro v\u00e1lido representando o ano.")
  }
  if (!is.numeric(mes) || length(mes) != 1 || mes < 1 || mes > 12) {
    stop("O par\u00e2metro 'mes' deve ser um inteiro entre 1 e 12.")
  }

  mes_str <- sprintf("%02d", as.integer(mes)) # Formata o mês com zero à esquerda (e.g., 01, 02)
  ano_str <- as.character(as.integer(ano))

  # URL do arquivo ZIP publicado pelo Portal da Transparência
  zip_url <- paste0(
    "https://dadosabertos-download.cgu.gov.br/PortalDaTransparencia/saida/transferencias/",
    ano_str, mes_str, "_Transferencias.zip"
  )

  # --- 2. Baixar o arquivo ZIP ---
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

  # --- 3. Descompactar o arquivo ---
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
    warning("Falha na descompacta\u00e7\u00e3o ou nenhum arquivo foi extra\u00eddo.")
    # Limpa arquivos temporários
    if (file.exists(temp_zip)) unlink(temp_zip)
    return(invisible(NULL))
  }

  # Tenta encontrar o arquivo CSV extraído (geralmente há apenas um)
  csv_file <- extracted_files[grep("\\.csv$", extracted_files, ignore.case = TRUE)][1]

  if (is.na(csv_file) || !file.exists(csv_file)) {
    warning("N\u00e3o foi encontrado um arquivo CSV ap\u00f3s a descompacta\u00e7\u00e3o.")
    # Limpa arquivos temporários
    if (file.exists(temp_zip)) unlink(temp_zip)
    if (length(extracted_files) > 0 && all(file.exists(extracted_files))) unlink(extracted_files)
    return(invisible(NULL))
  }
  message("Arquivo CSV extra\u00eddo: ", csv_file)

  # --- 4. Ler o arquivo CSV ---
  # O Portal usa frequentemente ';' como separador, ',' como decimal, e codificação ISO-8859-1 (Latin1)
  # É recomendado usar readr::read_delim por ser mais robusto, especialmente com codificação
  dados <- tryCatch({
    suppressWarnings(read_delim(
      csv_file,
      delim = ";",
      quote = "\"",
      col_names = TRUE, # Assume que a primeira linha é o cabeçalho
      locale = locale(encoding = "ISO-8859-1", decimal_mark = ","),
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

  # --- 5. Limpar arquivos temporários ---
  if (file.exists(temp_zip)) unlink(temp_zip)
  if (file.exists(csv_file)) unlink(csv_file) # Limpa o arquivo CSV extraído também

  # --- 6. Retornar o data frame ou NULL se falhou ---
  if (is.null(dados)) {
    warning("Falha final ao processar os dados de ", ano_str, "-", mes_str, ".")
    return(invisible(NULL))
  }

  message("Dados de ", ano_str, "-", mes_str, " baixados e lidos com sucesso. ",
          nrow(dados), " linhas, ", ncol(dados), " colunas.")

  # --- 7. Acrescentar o código IBGE via mapeamento SIAFI-IBGE ---
  # O dicionário de dados não é aplicado automaticamente aqui; consulte
  # https://portaldatransparencia.gov.br/pagina-interna/603420-dicionario-de-dados-recursos-transferidos
  if (isTRUE(codigo_ibge)) {
    if (is.null(municipios_mapping)) {
      # Usa o mapeamento embarcado no pacote quando nenhum é fornecido
      municipios_mapping_data <- tryCatch(
        get("municipios_siafi_ibge", envir = asNamespace("transfRgov")),
        error = function(e) NULL
      )
    } else {
      municipios_mapping_data <- municipios_mapping
    }

    colunas_mapeamento <- c("codigo_municipio_siafi", "codigo_ibge")

    if (!inherits(municipios_mapping_data, "data.frame") ||
        !all(colunas_mapeamento %in% names(municipios_mapping_data))) {
      warning("O mapeamento SIAFI-IBGE n\u00e3o foi encontrado ou n\u00e3o cont\u00e9m as colunas ",
              "'codigo_municipio_siafi' e 'codigo_ibge'.")
      return(invisible(NULL))
    }

    if (!("codigo_municipio_siafi" %in% names(dados))) {
      warning("A coluna 'codigo_municipio_siafi' n\u00e3o foi encontrada nos dados; ",
              "o mapeamento para c\u00f3digos IBGE n\u00e3o p\u00f4de ser aplicado.")
      return(dados)
    }

    dados$codigo_ibge <- municipios_mapping_data$codigo_ibge[
      match(dados$codigo_municipio_siafi,
            municipios_mapping_data$codigo_municipio_siafi)
    ]
  }

  return(dados)
}
