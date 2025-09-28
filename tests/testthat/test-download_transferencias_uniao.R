# Certifique-se de que os pacotes necessários para o teste estão instalados:
# install.packages(c("testthat", "mockery", "readr", "dplyr", "janitor", "tibble"))

library(testthat)
library(mockery)
library(readr)
library(dplyr)
library(janitor)
library(tibble)

# --- Cole a sua função `download_transferencias_uniao` AQUI (a versão com `municipios_mapping = NULL`) ---
# ... (Sua função completa aqui) ...
# --- Fim da função ---


# --- Mock data para simular arquivos e datasets internos ---
mock_csv_content <- "ano_mes;tipo_transferencia;codigo_favorecido;\nval1;valA;1234\nval2;valB;5678"
mock_df_from_csv <- suppressWarnings(readr::read_delim(
  file = I(mock_csv_content),
  delim = ";",
  quote = "\"",
  col_names = TRUE,
  locale = readr::locale(encoding = "UTF-8", decimal_mark = ","),
  col_types = cols(.default = col_character()),
  show_col_types = FALSE
) |> janitor::clean_names())

mock_municipios_siafi_ibge <- tibble::tibble(
  codigo_municipio_siafi = c("0001", "0002", "9999"),
  codigo_ibge = c("1100106", "1100379", "3550308")
)


# Testes unitários para download_transferencias_uniao
test_that("download_transferencias_uniao valida ano e mes corretamente", {
  expect_error(download_transferencias_uniao("vinte e tres", 1), "O parâmetro 'ano' deve ser um inteiro válido")
  expect_error(download_transferencias_uniao(1999, 1), "O parâmetro 'ano' deve ser um inteiro válido")
  expect_error(download_transferencias_uniao(2050, 1), "O parâmetro 'ano' deve ser um inteiro válido")
  expect_error(download_transferencias_uniao(2023, 0), "O parâmetro 'mes' deve ser um inteiro entre 1 e 12")
  expect_error(download_transferencias_uniao(2023, 13), "O parâmetro 'mes' deve ser um inteiro entre 1 e 12")
})

test_that("download_transferencias_uniao baixa e processa dados com IBGE (mocked)", {
  # Stubs para todas as chamadas externas
  stub(download_transferencias_uniao, "download.file", mock(
    function(url, destfile, mode, quiet) {
      temp_csv_for_zip <- file.path(tempdir(), "mock_data_in_zip.csv")
      writeLines(mock_csv_content, con = temp_csv_for_zip)
      utils::zip(zipfile = destfile, files = temp_csv_for_zip, flags = "-j")
      unlink(temp_csv_for_zip)
      0
    }, cycle = TRUE
  ))

  stub(download_transferencias_uniao, "unzip", mock(
    function(zipfile, exdir, overwrite) {
      # Retorne um vetor de caracteres explícito e certifique-se de que os arquivos existem para file.exists
      extracted_paths <- c(file.path(exdir, "dados_transferencias.csv"), file.path(exdir, "some_other.txt"))
      writeLines(mock_csv_content, con = extracted_paths[1]) # Cria o arquivo CSV para ser lido
      return(extracted_paths) # Retorna um vetor de caracteres
    }, cycle = TRUE
  ))

  stub(download_transferencias_uniao, "read_delim", mock( # Note: "readr::read_delim" como string
    function(file, delim, quote, col_names, locale, col_types, show_col_types) {
      mock_df_from_csv
    }, cycle = TRUE
  ))

  # Não precisamos stubbar transfRgov:::municipios_siafi_ibge aqui,
  # pois estamos passando-o via argumento `municipios_mapping`.

  # Limpa diretórios temporários antes do teste para garantir estado limpo
  if (file.exists(file.path(tempdir(), "dados_transferencias.csv"))) {
    unlink(file.path(tempdir(), "dados_transferencias.csv"))
  }

  result <- download_transferencias_uniao(2023, 1, codigo_ibge = TRUE,
                                          municipios_mapping = mock_municipios_siafi_ibge)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("codigo_ibge" %in% names(result))
  expect_true(all( c("ano_mes", "tipo_transferencia", "codigo_favorecido", "codigo_ibge") %in% names(result)))
  expect_true(result$codigo_ibge[1] %in% c(NA,1100379))
  expect_true(result$codigo_ibge[2] %in% c(NA,1100106))
  expect_false(file.exists(file.path(tempdir(), "dados_transferencias.csv")))
})

test_that("download_transferencias_uniao baixa e processa dados SEM IBGE (mocked)", {
  stub(download_transferencias_uniao, "download.file", mock(
    function(url, destfile, mode, quiet) {
      temp_csv_for_zip <- file.path(tempdir(), "mock_data_in_zip.csv")
      writeLines(mock_csv_content, con = temp_csv_for_zip)
      zip(zipfile = destfile, files = temp_csv_for_zip, flags = "-j")
      unlink(temp_csv_for_zip)
      0
    }, cycle = TRUE
  ))

  stub(download_transferencias_uniao, "unzip", mock(
    function(zipfile, exdir, overwrite) {
      csv_path <- file.path(exdir, "dados_transferencias.csv")
      writeLines(mock_csv_content, con = csv_path)
      return(csv_path)
    }, cycle = TRUE
  ))

  stub(download_transferencias_uniao, "read_delim", mock(
    function(file, delim, quote, col_names, locale, col_types, show_col_types) {
      mock_df_from_csv
    }, cycle = TRUE
  ))

  result <- download_transferencias_uniao(2023, 1, codigo_ibge = FALSE)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_false("codigo_ibge" %in% names(result))
  expect_true(all( c("ano_mes", "tipo_transferencia", "codigo_favorecido", "valor_transferido") %in% names(result)))
})


test_that("download_transferencias_uniao retorna NULL em falha de download (mocked)", {
  stub(download_transferencias_uniao, "download.file", mock(
    function(url, destfile, mode, quiet) {
      stop("Erro simulado de download")
    }, cycle = TRUE
  ))

  result <- download_transferencias_uniao(2023, 1)
  expect_null(result)
})

test_that("download_transferencias_uniao retorna NULL em falha de descompactação (mocked)", {
  stub(download_transferencias_uniao, "download.file", mock(
    function(url, destfile, mode, quiet) {
      writeLines("dummy zip content", con = destfile)
      0
    }, cycle = TRUE
  ))

  stub(download_transferencias_uniao, "unzip", mock(
    function(zipfile, exdir, overwrite) {
      stop("Erro simulado de descompactação")
    }, cycle = TRUE
  ))

  result <- download_transferencias_uniao(2023, 1)
  expect_null(result)
})

test_that("download_transferencias_uniao retorna NULL se CSV não for encontrado (mocked)", {
  stub(download_transferencias_uniao, "download.file", mock(
    function(url, destfile, mode, quiet) {
      temp_txt_for_zip <- file.path(tempdir(), "some_other_file.txt")
      writeLines("dummy txt content", con = temp_txt_for_zip)
      zip(zipfile = destfile, files = temp_txt_for_zip, flags = "-j")
      unlink(temp_txt_for_zip)
      0
    }, cycle = TRUE
  ))

  stub(download_transferencias_uniao, "unzip", mock(
    function(zipfile, exdir, overwrite) {
      txt_path <- file.path(exdir, "some_other_file.txt")
      writeLines("dummy text", con = txt_path)
      return(txt_path)
    }, cycle = TRUE
  ))

  result <- download_transferencias_uniao(2023, 1)
  expect_null(result)
})

test_that("download_transferencias_uniao retorna NULL em falha de leitura do CSV (mocked)", {
  stub(download_transferencias_uniao, "download.file", mock(
    function(url, destfile, mode, quiet) {
      temp_csv_for_zip <- file.path(tempdir(), "mock_data_in_zip.csv")
      writeLines(mock_csv_content, con = temp_csv_for_zip)
      zip(zipfile = destfile, files = temp_csv_for_zip, flags = "-j")
      unlink(temp_csv_for_zip)
      0
    }, cycle = TRUE
  ))

  stub(download_transferencias_uniao, "unzip", mock(
    function(zipfile, exdir, overwrite) {
      csv_path <- file.path(exdir, "dados_transferencias.csv")
      writeLines(mock_csv_content, con = csv_path)
      return(csv_path)
    }, cycle = TRUE
  ))

  stub(download_transferencias_uniao, "read_delim", mock(
    function(file, delim, quote, col_names, locale, col_types, show_col_types) {
      stop("Erro simulado de leitura CSV")
    }, cycle = TRUE
  ))

  result <- download_transferencias_uniao(2023, 1)
  expect_null(result)
})

