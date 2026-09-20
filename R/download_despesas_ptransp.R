#' @title Baixar Dados de Despesas do Portal da Transparência
#' @description Baixa os dados diários de despesas da União publicados pelo
#'   Portal da Transparência (CGU) para uma data específica.
#' @param data Um objeto \code{Date} (ou valor conversível a \code{Date}, como a
#'   string \code{"2024-01-15"}) com a data desejada. Uma única data por chamada.
#' @param tipo Qual dos arquivos contidos no ZIP diário deve ser lido. O padrão é
#'   \code{"empenho"}; use \code{tipo} para escolher outro arquivo. Ver
#'   \emph{Detalhes} para a lista completa e para o encadeamento entre arquivos.
#' @return Um data frame com o conteúdo do arquivo escolhido e nomes de coluna
#'   normalizados por \code{janitor::clean_names()}. Dias sem movimento não são
#'   erro: o data frame volta com zero linhas. Retorna \code{NULL} (invisível) e
#'   emite \code{warning()} se o download, a descompactação ou a leitura falhar.
#' @details
#' A função monta a URL do arquivo \code{{AAAAMMDD}_Despesas.zip}, baixa o
#' arquivo, descompacta e lê o CSV correspondente ao \code{tipo} informado.
#' O ZIP diário reúne onze arquivos, um por tipo de registro:
#' \code{empenho}, \code{item_empenho}, \code{item_empenho_historico},
#' \code{liquidacao}, \code{liquidacao_empenhos_impactados}, \code{pagamento},
#' \code{pagamento_empenhos_impactados}, \code{pagamento_favorecidos_finais},
#' \code{pagamento_lista_bancos}, \code{pagamento_lista_faturas} e
#' \code{pagamento_lista_precatorios}.
#' O dicionário de dados e os arquivos podem ser consultados em
#' \url{https://dadosabertos-download.cgu.gov.br/PortalDaTransparencia/saida/despesas/}.
#'
#' Chegar ao beneficiário final de um pagamento exige encadear dois arquivos:
#' \code{pagamento} traz o total por ordem bancária (colunas
#' \code{codigo_pagamento} e \code{valor_do_pagamento_convertido_pra_r}) e
#' \code{pagamento_favorecidos_finais} traz os beneficiários daquela ordem
#' (colunas \code{codigo_pagamento}, \code{codigo_favorecido} e
#' \code{valor_do_pagamento_em_r}). A junção é 1:N por \code{codigo_pagamento} e
#' cobre apenas as ordens detalhadas. O mesmo encadeamento vale para
#' \code{liquidacao} com \code{liquidacao_empenhos_impactados}, \code{pagamento}
#' com \code{pagamento_empenhos_impactados} e \code{empenho} com
#' \code{item_empenho} (por \code{id_empenho}).
#'
#' A função lida com arquivos temporários e tenta ler o CSV considerando a
#' codificação e os separadores comuns no Portal.
#' Requer os pacotes 'readr', 'janitor' e 'utils'.
#' @importFrom readr read_delim locale
#' @importFrom utils unzip download.file read.csv
#' @export
download_despesas_ptransp <- function(
    data,
    tipo = c(
      "empenho", "item_empenho", "item_empenho_historico",
      "liquidacao", "liquidacao_empenhos_impactados",
      "pagamento", "pagamento_empenhos_impactados",
      "pagamento_favorecidos_finais", "pagamento_lista_bancos",
      "pagamento_lista_faturas", "pagamento_lista_precatorios"
    )) {

  # --- 1. Validação dos parâmetros ---
  if (missing(data)) {
    stop("O par\u00e2metro 'data' deve ser uma \u00fanica data v\u00e1lida.")
  }

  data <- tryCatch(as.Date(data), error = function(e) as.Date(NA))

  if (length(data) != 1 || is.na(data)) {
    stop("O par\u00e2metro 'data' deve ser uma \u00fanica data v\u00e1lida.")
  }
  if (data < as.Date("2014-01-01")) {
    stop("O par\u00e2metro 'data' deve ser igual ou posterior a 2014-01-01.")
  }
  if (data > Sys.Date()) {
    stop("O par\u00e2metro 'data' n\u00e3o pode estar no futuro.")
  }

  tipo <- match.arg(tipo)

  sufixos <- c(
    empenho = "Empenho",
    item_empenho = "ItemEmpenho",
    item_empenho_historico = "ItemEmpenhoHistorico",
    liquidacao = "Liquidacao",
    liquidacao_empenhos_impactados = "Liquidacao_EmpenhosImpactados",
    pagamento = "Pagamento",
    pagamento_empenhos_impactados = "Pagamento_EmpenhosImpactados",
    pagamento_favorecidos_finais = "Pagamento_FavorecidosFinais",
    pagamento_lista_bancos = "Pagamento_ListaBancos",
    pagamento_lista_faturas = "Pagamento_ListaFaturas",
    pagamento_lista_precatorios = "Pagamento_ListaPrecatorios"
  )

  data_str <- format(data, "%Y%m%d")

  # URL do arquivo ZIP publicado pelo Portal da Transparência
  zip_url <- paste0(
    "https://dadosabertos-download.cgu.gov.br/PortalDaTransparencia/saida/despesas/",
    data_str, "_Despesas.zip"
  )

  # --- 2. Baixar o arquivo ZIP ---
  temp_zip <- tempfile(fileext = ".zip")
  message("Baixando ZIP para: ", temp_zip)

  download_status <- tryCatch({
    download.file(zip_url, temp_zip, mode = "wb")
    TRUE
  }, error = function(e) {
    warning("Erro ao baixar arquivo ZIP de ", zip_url, ": ", e$message)
    FALSE
  })

  if (!download_status) {
    if (file.exists(temp_zip)) unlink(temp_zip)
    return(invisible(NULL))
  }

  # --- 3. Descompactar o arquivo ---
  temp_dir <- tempdir()
  extracted_files <- tryCatch({
    unzip(temp_zip, exdir = temp_dir)
  }, error = function(e) {
    warning("Erro ao descompactar o arquivo ZIP ", temp_zip, ": ", e$message)
    if (file.exists(temp_zip)) unlink(temp_zip)
    return(NULL)
  })

  if (is.null(extracted_files) || length(extracted_files) == 0) {
    warning("Falha na descompacta\u00e7\u00e3o ou nenhum arquivo foi extra\u00eddo.")
    if (file.exists(temp_zip)) unlink(temp_zip)
    return(invisible(NULL))
  }

  # --- 4. Selecionar o CSV pelo tipo informado ---
  # O ZIP diario traz onze CSVs; o nome de cada um termina em _Despesas_<X>.csv
  alvo <- paste0("_Despesas_", sufixos[[tipo]], ".csv")
  encontrados <- extracted_files[endsWith(basename(extracted_files), alvo)]
  csv_file <- if (length(encontrados) > 0) encontrados[[1]] else NA_character_

  if (is.na(csv_file) || !file.exists(csv_file)) {
    warning("N\u00e3o foi encontrado o arquivo CSV '", alvo, "' ap\u00f3s a descompacta\u00e7\u00e3o.")
    if (file.exists(temp_zip)) unlink(temp_zip)
    if (length(extracted_files) > 0 && all(file.exists(extracted_files))) unlink(extracted_files)
    return(invisible(NULL))
  }
  message("Arquivo CSV extra\u00eddo: ", csv_file)

  # --- 5. Ler o arquivo CSV ---
  dados <- tryCatch({
    suppressWarnings(read_delim(
      csv_file,
      delim = ";",
      quote = "\"",
      col_names = TRUE,
      locale = locale(encoding = "ISO-8859-1", decimal_mark = ","),
      show_col_types = FALSE
    ) |> janitor::clean_names())
  }, error = function(e) {
    warning("Erro ao ler arquivo CSV com readr: ", e$message, "\nTentar ler com base R read.csv...")
    tryCatch({
      read.csv(
        csv_file,
        sep = ";",
        dec = ",",
        header = TRUE,
        encoding = "Latin1",
        stringsAsFactors = FALSE
      ) |> janitor::clean_names()
    }, error = function(e2) {
      warning("Falha ao ler arquivo CSV com base R read.csv: ", e2$message)
      return(NULL)
    })
  })

  # --- 6. Limpar arquivos temporários ---
  if (file.exists(temp_zip)) unlink(temp_zip)
  if (file.exists(csv_file)) unlink(csv_file)

  # --- 7. Retornar o data frame ou NULL se falhou ---
  if (is.null(dados)) {
    warning("Falha final ao processar os dados de despesas de ", data_str, ".")
    return(invisible(NULL))
  }

  message("Despesas de ", data_str, " (", tipo, ") baixadas e lidas com sucesso. ",
          nrow(dados), " linhas, ", ncol(dados), " colunas.")

  return(dados)
}
