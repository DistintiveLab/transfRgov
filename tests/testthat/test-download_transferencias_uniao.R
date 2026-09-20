# Testes para download_transferencias_uniao().
#
# As chamadas de rede e de descompactação são substituídas por stubs com
# mockery, de modo que nenhum teste acessa a internet.

mock_csv_content <- paste(
  "ano_mes;tipo_transferencia;codigo_favorecido;codigo_municipio_siafi",
  "202301;Estadual;1234;0001",
  "202301;Municipal;5678;0002",
  sep = "\n"
)

mock_municipios_siafi_ibge <- data.frame(
  codigo_municipio_siafi = c("0001", "0002", "9999"),
  codigo_ibge = c("1100106", "1100379", "3550308"),
  stringsAsFactors = FALSE
)

# Stub de download.file: apenas cria um arquivo no destino.
mock_download_file <- function() {
  function(url, destfile, mode, quiet) {
    writeLines("conteudo de zip simulado", con = destfile)
    invisible(0L)
  }
}

# Stub de unzip: escreve o CSV simulado no diretório de extração.
mock_unzip_csv <- function() {
  function(zipfile, exdir, overwrite) {
    caminho <- file.path(exdir, "dados_transferencias.csv")
    writeLines(mock_csv_content, con = caminho)
    caminho
  }
}

test_that("download_transferencias_uniao valida ano e mes corretamente", {
  expect_error(
    download_transferencias_uniao("vinte e tres", 1),
    "O parâmetro 'ano' deve ser um inteiro válido"
  )
  expect_error(
    download_transferencias_uniao(1999, 1),
    "O parâmetro 'ano' deve ser um inteiro válido"
  )
  expect_error(
    download_transferencias_uniao(as.integer(format(Sys.Date(), "%Y")) + 1, 1),
    "O parâmetro 'ano' deve ser um inteiro válido"
  )
  expect_error(
    download_transferencias_uniao(2023, 0),
    "O parâmetro 'mes' deve ser um inteiro entre 1 e 12"
  )
  expect_error(
    download_transferencias_uniao(2023, 13),
    "O parâmetro 'mes' deve ser um inteiro entre 1 e 12"
  )
})

test_that("download_transferencias_uniao baixa e processa dados com IBGE (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_transferencias_uniao, "download.file", mock_download_file())
  mockery::stub(download_transferencias_uniao, "unzip", mock_unzip_csv())

  resultado <- download_transferencias_uniao(
    2023, 1,
    codigo_ibge = TRUE,
    municipios_mapping = mock_municipios_siafi_ibge
  )

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 2)
  expect_true(all(
    c("ano_mes", "tipo_transferencia", "codigo_favorecido",
      "codigo_municipio_siafi", "codigo_ibge") %in% names(resultado)
  ))
  expect_equal(as.character(resultado$codigo_ibge), c("1100106", "1100379"))
  expect_false(file.exists(file.path(tempdir(), "dados_transferencias.csv")))
})

test_that("download_transferencias_uniao baixa e processa dados SEM IBGE (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_transferencias_uniao, "download.file", mock_download_file())
  mockery::stub(download_transferencias_uniao, "unzip", mock_unzip_csv())

  resultado <- download_transferencias_uniao(2023, 1, codigo_ibge = FALSE)

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 2)
  expect_false("codigo_ibge" %in% names(resultado))
  expect_true(all(
    c("ano_mes", "tipo_transferencia", "codigo_favorecido",
      "codigo_municipio_siafi") %in% names(resultado)
  ))
})

test_that("download_transferencias_uniao nao aplica o mapeamento sem a coluna SIAFI", {
  skip_if_not_installed("mockery")

  mockery::stub(download_transferencias_uniao, "download.file", mock_download_file())
  mockery::stub(
    download_transferencias_uniao, "unzip",
    function(zipfile, exdir, overwrite) {
      caminho <- file.path(exdir, "dados_transferencias.csv")
      writeLines("ano_mes;tipo_transferencia\n202301;Estadual", con = caminho)
      caminho
    }
  )

  avisos <- capture_warnings(
    resultado <- suppressMessages(
      download_transferencias_uniao(
        2023, 1,
        codigo_ibge = TRUE,
        municipios_mapping = mock_municipios_siafi_ibge
      )
    )
  )

  expect_s3_class(resultado, "data.frame")
  expect_false("codigo_ibge" %in% names(resultado))
  expect_true(any(grepl("codigo_municipio_siafi", avisos)))
})

test_that("download_transferencias_uniao retorna NULL em falha de download (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(
    download_transferencias_uniao, "download.file",
    function(url, destfile, mode, quiet) {
      stop("Erro simulado de download")
    }
  )

  avisos <- capture_warnings(
    resultado <- suppressMessages(download_transferencias_uniao(2023, 1))
  )

  expect_null(resultado)
  expect_true(any(grepl("Erro ao baixar arquivo ZIP", avisos)))
})

test_that("download_transferencias_uniao retorna NULL em falha de descompactacao (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_transferencias_uniao, "download.file", mock_download_file())
  mockery::stub(
    download_transferencias_uniao, "unzip",
    function(zipfile, exdir, overwrite) {
      stop("Erro simulado de descompactação")
    }
  )

  avisos <- capture_warnings(
    resultado <- suppressMessages(download_transferencias_uniao(2023, 1))
  )

  expect_null(resultado)
  expect_true(any(grepl("Erro ao descompactar", avisos)))
})

test_that("download_transferencias_uniao retorna NULL se CSV nao for encontrado (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_transferencias_uniao, "download.file", mock_download_file())
  mockery::stub(
    download_transferencias_uniao, "unzip",
    function(zipfile, exdir, overwrite) {
      caminho <- file.path(exdir, "some_other_file.txt")
      writeLines("conteudo de texto simulado", con = caminho)
      caminho
    }
  )

  avisos <- capture_warnings(
    resultado <- suppressMessages(download_transferencias_uniao(2023, 1))
  )

  expect_null(resultado)
  expect_true(any(grepl("Não foi encontrado um arquivo CSV", avisos)))
})

test_that("download_transferencias_uniao retorna NULL em falha de leitura do CSV (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_transferencias_uniao, "download.file", mock_download_file())
  mockery::stub(download_transferencias_uniao, "unzip", mock_unzip_csv())
  mockery::stub(
    download_transferencias_uniao, "read_delim",
    function(file, delim, quote, col_names, locale, show_col_types) {
      stop("Erro simulado de leitura CSV")
    }
  )
  mockery::stub(
    download_transferencias_uniao, "read.csv",
    function(...) {
      stop("Erro simulado de leitura CSV com base R")
    }
  )

  avisos <- capture_warnings(
    resultado <- suppressMessages(download_transferencias_uniao(2023, 1))
  )

  expect_null(resultado)
  expect_true(any(grepl("Falha ao ler arquivo CSV com base R", avisos)))
})
