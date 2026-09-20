# Testes das funções internas de consulta à API (helpers PostgREST).
#
# As funções `pg_build_url()` e `pg_parse_response()` são puras e podem ser
# testadas sem acesso à rede. O teste de `pg_get()` substitui as chamadas do
# pacote `httr` por stubs do `mockery`, portanto também não acessa a internet.

test_that("pg_build_url monta a URL com e sem filtros", {
  expect_equal(
    transfRgov:::pg_build_url("programa", character(), "https://x"),
    "https://x/programa?"
  )

  expect_equal(
    transfRgov:::pg_build_url("programa", c("a=eq.1", "b=eq.2"), "https://x"),
    "https://x/programa?a=eq.1&b=eq.2"
  )
})

test_that("pg_parse_response interpreta respostas JSON", {
  skip_if_not_installed("jsonlite")

  resultado <- transfRgov:::pg_parse_response("application/json", '{"a":1}')

  expect_true(resultado$suportado)
  expect_equal(resultado$dados, list(a = 1))

  expect_true(transfRgov:::pg_parse_response("APPLICATION/JSON", '{"a":1}')$suportado)
})

test_that("pg_parse_response interpreta respostas CSV", {
  resultado <- transfRgov:::pg_parse_response("text/csv", "a,b\n1,2\n3,4")

  expect_true(resultado$suportado)
  expect_s3_class(resultado$dados, "data.frame")
  expect_equal(names(resultado$dados), c("a", "b"))
  expect_equal(nrow(resultado$dados), 2)
})

test_that("pg_parse_response sinaliza tipos nao suportados ou ausentes", {
  html <- transfRgov:::pg_parse_response("text/html", "<html></html>")
  expect_false(html$suportado)
  expect_null(html$dados)

  ausente <- transfRgov:::pg_parse_response(NA_character_, "x")
  expect_false(ausente$suportado)
  expect_null(ausente$dados)

  vazio <- transfRgov:::pg_parse_response(character(), "x")
  expect_false(vazio$suportado)
  expect_null(vazio$dados)
})

test_that("pg_get monta a URL, le o conteudo e converte a resposta (mocked)", {
  skip_on_cran()
  skip_if_not_installed("mockery")
  skip_if_not_installed("httr")
  skip_if_not_installed("jsonlite")

  urls_consultadas <- character()

  mockery::stub(pg_get, "httr::GET", function(url) {
    urls_consultadas <<- c(urls_consultadas, url)
    structure(list(), class = "resposta_simulada")
  })
  mockery::stub(pg_get, "httr::stop_for_status", function(resposta) resposta)
  mockery::stub(pg_get, "httr::content", function(resposta, tipo, encoding) '{"a":1}')
  mockery::stub(pg_get, "httr::headers", function(resposta) {
    list("content-type" = "application/json")
  })

  resultado <- pg_get("programa", c("ano_programa=eq.2020"), "https://x")

  expect_equal(resultado, list(a = 1))
  expect_equal(urls_consultadas, "https://x/programa?ano_programa=eq.2020")
})

test_that("pg_get avisa e devolve a resposta quando o tipo nao e suportado (mocked)", {
  skip_on_cran()
  skip_if_not_installed("mockery")
  skip_if_not_installed("httr")

  resposta_simulada <- structure(list(), class = "resposta_simulada")

  mockery::stub(pg_get, "httr::GET", function(url) resposta_simulada)
  mockery::stub(pg_get, "httr::stop_for_status", function(resposta) resposta)
  mockery::stub(pg_get, "httr::content", function(resposta, tipo, encoding) "<html></html>")
  mockery::stub(pg_get, "httr::headers", function(resposta) {
    list("content-type" = "text/html")
  })

  avisos <- capture_warnings(
    resultado <- suppressMessages(pg_get("programa"))
  )

  expect_identical(resultado, resposta_simulada)
  expect_true(any(grepl("não é suportado", avisos)))
})
