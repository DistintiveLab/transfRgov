# Testes para consultar_renuncias_fiscais() e baixa_municipio_siafibge().
#
# consultar_renuncias_fiscais() chama httr::GET de forma qualificada, então
# mockery::stub não intercepta a requisição HTTP: esses testes usam webmockr,
# que registra respostas sem tocar a rede. Como a chave da API não existe no
# ambiente de testes, ela é sempre passada explicitamente como valor falso.
#
# baixa_municipio_siafibge() chama download.file e read.csv sem qualificação,
# então esses dois pontos são substituídos com mockery. O readr é chamado de
# forma qualificada (readr::read_csv2) e por isso não é substituível: os testes
# provocam a falha do readr deixando o arquivo temporário inexistente.

url_renuncias <- "https://api.portaldatransparencia.gov.br/api-de-dados/renuncias-valor"

# --- consultar_renuncias_fiscais() ------------------------------------------

test_that("consultar_renuncias_fiscais exige a chave da API", {
  expect_error(
    consultar_renuncias_fiscais(pagina = 1, chave_api = ""),
    "n\u00e3o foi encontrada"
  )
  expect_error(
    consultar_renuncias_fiscais(pagina = 1, chave_api = ""),
    "PORTAL_TRANSPARENCIA_API_KEY"
  )
})

test_that("consultar_renuncias_fiscais consulta a pagina e devolve os dados", {
  skip_if_not_installed("webmockr")

  webmockr::enable(quiet = TRUE)
  webmockr::stub_registry_clear()
  on.exit(webmockr::disable(quiet = TRUE), add = TRUE)

  webmockr::stub_request("get", url_renuncias) |>
    webmockr::wi_th(query = list(pagina = 1)) |>
    webmockr::to_return(
      status = 200,
      body = '[{"ano":2023,"valor":1.5}]',
      headers = list("Content-Type" = "application/json")
    )

  dados <- consultar_renuncias_fiscais(chave_api = "chave-falsa")

  expect_s3_class(dados, "data.frame")
  expect_equal(nrow(dados), 1)
  expect_true(all(c("ano", "valor") %in% names(dados)))
  expect_equal(dados$ano, 2023)

  requisicao <- webmockr::last_request()
  expect_true(grepl("renuncias-valor", unlist(requisicao$url)))
  expect_true(grepl("pagina=1", unlist(requisicao$url)))
  expect_equal(requisicao$headers[["chave-api-dados"]], "chave-falsa")
})

test_that("consultar_renuncias_fiscais omite os filtros nao informados", {
  skip_if_not_installed("webmockr")

  webmockr::enable(quiet = TRUE)
  webmockr::stub_registry_clear()
  on.exit(webmockr::disable(quiet = TRUE), add = TRUE)

  webmockr::stub_request("get", url_renuncias) |>
    webmockr::wi_th(query = list(pagina = 1)) |>
    webmockr::to_return(
      status = 200,
      body = '[{"origem":"sem_filtro"}]',
      headers = list("Content-Type" = "application/json")
    )

  dados <- consultar_renuncias_fiscais(chave_api = "chave-falsa")
  expect_equal(dados$origem, "sem_filtro")

  url_usada <- unlist(webmockr::last_request()$url)
  expect_false(grepl("nomeSiglaUF", url_usada))
  expect_false(grepl("codigoIbge", url_usada))
  expect_false(grepl("cnpj", url_usada))
})

test_that("consultar_renuncias_fiscais traduz os filtros opcionais para a API", {
  skip_if_not_installed("webmockr")

  webmockr::enable(quiet = TRUE)
  webmockr::stub_registry_clear()
  on.exit(webmockr::disable(quiet = TRUE), add = TRUE)

  webmockr::stub_request("get", url_renuncias) |>
    webmockr::wi_th(query = list(
      pagina = 1,
      nomeSiglaUF = "SP",
      codigoIbge = "3550308",
      cnpj = "00000000000191"
    )) |>
    webmockr::to_return(
      status = 200,
      body = '[{"origem":"com_filtro"}]',
      headers = list("Content-Type" = "application/json")
    )

  dados <- consultar_renuncias_fiscais(
    pagina = 1,
    uf = "SP",
    codigo_ibge = "3550308",
    cnpj = "00000000000191",
    chave_api = "chave-falsa"
  )

  expect_equal(dados$origem, "com_filtro")

  url_usada <- unlist(webmockr::last_request()$url)
  expect_true(grepl("nomeSiglaUF=SP", url_usada))
  expect_true(grepl("codigoIbge=3550308", url_usada))
  expect_true(grepl("cnpj=00000000000191", url_usada))
})

test_that("consultar_renuncias_fiscais avisa quando a consulta nao retorna dados", {
  skip_if_not_installed("webmockr")

  webmockr::enable(quiet = TRUE)
  webmockr::stub_registry_clear()
  on.exit(webmockr::disable(quiet = TRUE), add = TRUE)

  webmockr::stub_request("get", url_renuncias) |>
    webmockr::wi_th(query = list(pagina = 1)) |>
    webmockr::to_return(
      status = 200,
      body = "[]",
      headers = list("Content-Type" = "application/json")
    )

  avisos <- capture_warnings(
    dados <- consultar_renuncias_fiscais(chave_api = "chave-falsa")
  )

  expect_s3_class(dados, "data.frame")
  expect_equal(ncol(dados), 0)
  expect_true(any(grepl("n\u00e3o retornou dados", avisos)))
})

test_that("consultar_renuncias_fiscais propaga erro HTTP da API", {
  skip_if_not_installed("webmockr")

  webmockr::enable(quiet = TRUE)
  webmockr::stub_registry_clear()
  on.exit(webmockr::disable(quiet = TRUE), add = TRUE)

  webmockr::stub_request("get", url_renuncias) |>
    webmockr::wi_th(query = list(pagina = 7)) |>
    webmockr::to_return(
      status = 404,
      body = '{"message":"Not Found"}',
      headers = list("Content-Type" = "application/json")
    )

  expect_error(
    consultar_renuncias_fiscais(pagina = 7, chave_api = "chave-falsa"),
    class = "http_error"
  )
})

# --- baixa_municipio_siafibge() ---------------------------------------------

mock_tabmun_siafibge <- paste(
  "1001;123;SAO PAULO;SP;3550308",
  "1002;456;RIO DE JANEIRO;RJ;3304557",
  sep = "\n"
)

test_that("baixa_municipio_siafibge le o tabmun e preserva os codigos", {
  skip_if_not_installed("mockery")

  caminho_baixado <- NULL
  mockery::stub(
    baixa_municipio_siafibge, "download.file",
    function(url, destfile, mode, quiet) {
      caminho_baixado <<- destfile
      writeLines(mock_tabmun_siafibge, con = destfile)
      invisible(0L)
    }
  )

  mensagens <- capture_messages(
    dados <- suppressWarnings(baixa_municipio_siafibge())
  )

  expect_s3_class(dados, "data.frame")
  expect_equal(nrow(dados), 2)
  expect_equal(
    names(dados),
    c("codigo_municipio_siafi", "id", "nome_municipio", "uf", "codigo_ibge")
  )
  expect_type(dados$codigo_municipio_siafi, "character")
  expect_type(dados$uf, "character")
  expect_type(dados$codigo_ibge, "double")
  expect_equal(dados$codigo_ibge, c(3550308, 3304557))
  expect_false(is.null(caminho_baixado))
  expect_false(file.exists(caminho_baixado))
  expect_true(any(grepl("baixados e lidos com sucesso", mensagens)))
})

test_that("baixa_municipio_siafibge retorna NULL quando o download falha", {
  skip_if_not_installed("mockery")

  mockery::stub(
    baixa_municipio_siafibge, "download.file",
    function(url, destfile, mode, quiet) stop("falha simulada de download")
  )

  avisos <- capture_warnings(
    dados <- suppressMessages(baixa_municipio_siafibge())
  )

  expect_null(dados)
  expect_true(any(grepl("Erro ao baixar arquivo CSV de mapeamento de ", avisos)))
})

test_that("baixa_municipio_siafibge recorre ao read.csv quando o readr falha", {
  skip_if_not_installed("mockery")

  # O stub de download não cria o arquivo: read_csv2 falha ao abrir o caminho
  # e o caminho alternativo (Latin1, read.csv) é acionado.
  mockery::stub(
    baixa_municipio_siafibge, "download.file",
    function(url, destfile, mode, quiet) invisible(0L)
  )

  esperado <- data.frame(
    codigo_municipio_siafi = "1001",
    id = "123",
    nome_municipio = "SAO PAULO",
    uf = "SP",
    codigo_ibge = 3550308,
    stringsAsFactors = FALSE
  )
  mockery::stub(
    baixa_municipio_siafibge, "read.csv",
    function(file, sep, header, encoding, stringsAsFactors) esperado
  )

  avisos <- capture_warnings(
    dados <- suppressMessages(baixa_municipio_siafibge())
  )

  expect_identical(dados, esperado)
  expect_true(any(grepl("Erro ao ler arquivo CSV de mapeamento com readr", avisos)))
})

test_that("baixa_municipio_siafibge retorna NULL quando as duas leituras falham", {
  skip_if_not_installed("mockery")

  mockery::stub(
    baixa_municipio_siafibge, "download.file",
    function(url, destfile, mode, quiet) invisible(0L)
  )
  mockery::stub(
    baixa_municipio_siafibge, "read.csv",
    function(file, sep, header, encoding, stringsAsFactors) {
      stop("falha simulada de leitura")
    }
  )

  avisos <- capture_warnings(
    dados <- suppressMessages(baixa_municipio_siafibge())
  )

  expect_null(dados)
  expect_true(any(grepl("Falha ao ler arquivo CSV de mapeamento com read.csv", avisos)))
  expect_true(any(grepl("Falha final ao processar os dados de mapeamento de munic\u00edpios", avisos)))
})
