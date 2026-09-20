# Testes das funções internas de consulta à API (helpers PostgREST).
#
# As funções `pg_encode_filter()`, `pg_build_url()` e `pg_parse_response()` são
# puras e podem ser testadas sem acesso à rede. Os testes de `pg_get()`
# substituem as chamadas do pacote `httr` por stubs do `mockery`, portanto
# também não acessam a internet.

test_that("pg_encode_filter codifica apenas o valor do filtro", {
  expect_equal(
    transfRgov:::pg_encode_filter(c("a=eq.1", "b=eq.2")),
    c("a=eq.1", "b=eq.2")
  )

  expect_equal(
    transfRgov:::pg_encode_filter("nome_programa=eq.Valorização"),
    "nome_programa=eq.Valoriza%C3%A7%C3%A3o"
  )

  expect_equal(
    transfRgov:::pg_encode_filter("nome=eq.São Paulo"),
    "nome=eq.S%C3%A3o%20Paulo"
  )

  expect_equal(transfRgov:::pg_encode_filter(character()), character())
})

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

test_that("pg_build_url acrescenta os parâmetros de paginação", {
  expect_equal(
    transfRgov:::pg_build_url("programa", character(), "https://x", limite = 5, offset = 10),
    "https://x/programa?limit=5&offset=10"
  )

  expect_equal(
    transfRgov:::pg_build_url("programa", "ano_programa=eq.2020", "https://x", limite = 1000, offset = 0),
    "https://x/programa?ano_programa=eq.2020&limit=1000&offset=0"
  )

  expect_equal(
    transfRgov:::pg_build_url("programa", "ano_programa=eq.2020", "https://x"),
    "https://x/programa?ano_programa=eq.2020"
  )
})

test_that("pg_parse_response interpreta respostas JSON", {
  skip_if_not_installed("jsonlite")

  resultado <- transfRgov:::pg_parse_response("application/json", '{"a":1}')

  expect_true(resultado$suportado)
  expect_equal(resultado$dados, list(a = 1))

  expect_true(transfRgov:::pg_parse_response("APPLICATION/JSON", '{"a":1}')$suportado)
})

test_that("pg_parse_response normaliza uma resposta JSON sem linhas em data.frame", {
  skip_if_not_installed("jsonlite")

  vazio <- transfRgov:::pg_parse_response("application/json", "[]")

  expect_true(vazio$suportado)
  expect_s3_class(vazio$dados, "data.frame")
  expect_equal(nrow(vazio$dados), 0)
})

test_that("pg_parse_response interpreta respostas CSV", {
  skip_if_not_installed("readr")
  skip_if_not_installed("janitor")

  resultado <- transfRgov:::pg_parse_response("text/csv", "a,b\n1,2\n3,4")

  expect_true(resultado$suportado)
  expect_s3_class(resultado$dados, "data.frame")
  expect_equal(names(resultado$dados), c("a", "b"))
  expect_equal(nrow(resultado$dados), 2)
})

test_that("pg_parse_response limpa os nomes das colunas de respostas CSV", {
  skip_if_not_installed("readr")
  skip_if_not_installed("janitor")

  resultado <- transfRgov:::pg_parse_response(
    "text/csv; charset=utf-8",
    "Código IBGE,Nome do Município\n1100379,Poço\n"
  )

  expect_true(resultado$suportado)
  expect_equal(names(resultado$dados), c("codigo_ibge", "nome_do_municipio"))
  expect_equal(resultado$dados$nome_do_municipio, "Poço")
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
  expect_equal(
    urls_consultadas,
    "https://x/programa?ano_programa=eq.2020&limit=1000&offset=0"
  )
})

test_that("pg_get percorre todas as paginas ate a ultima incompleta (mocked)", {
  skip_on_cran()
  skip_if_not_installed("mockery")
  skip_if_not_installed("httr")
  skip_if_not_installed("jsonlite")

  urls_consultadas <- character()
  chamadas <- 0L
  corpo_pagina_cheia <- jsonlite::toJSON(data.frame(id = 1:1000))
  corpo_ultima_pagina <- jsonlite::toJSON(data.frame(id = 1001:1005))

  mockery::stub(pg_get, "httr::GET", function(url) {
    urls_consultadas <<- c(urls_consultadas, url)
    chamadas <<- chamadas + 1L
    structure(list(), class = "resposta_simulada")
  })
  mockery::stub(pg_get, "httr::stop_for_status", function(resposta) resposta)
  mockery::stub(pg_get, "httr::content", function(resposta, tipo, encoding) {
    if (chamadas == 1L) corpo_pagina_cheia else corpo_ultima_pagina
  })
  mockery::stub(pg_get, "httr::headers", function(resposta) {
    list("content-type" = "application/json")
  })

  resultado <- pg_get("programa", "ano_programa=eq.2020", "https://x")

  expect_equal(nrow(resultado), 1005)
  expect_equal(chamadas, 2L)
  expect_equal(length(urls_consultadas), 2L)
  expect_true(grepl("offset=0&?$", urls_consultadas[[1]]))
  expect_true(grepl("offset=1000&?$", urls_consultadas[[2]]))
})

test_that("pg_get nao pagina quando paginar = FALSE (mocked)", {
  skip_on_cran()
  skip_if_not_installed("mockery")
  skip_if_not_installed("httr")
  skip_if_not_installed("jsonlite")

  chamadas <- 0L

  mockery::stub(pg_get, "httr::GET", function(url) {
    chamadas <<- chamadas + 1L
    structure(list(), class = "resposta_simulada")
  })
  mockery::stub(pg_get, "httr::stop_for_status", function(resposta) resposta)
  mockery::stub(pg_get, "httr::content", function(resposta, tipo, encoding) {
    jsonlite::toJSON(data.frame(id = 1:10))
  })
  mockery::stub(pg_get, "httr::headers", function(resposta) {
    list("content-type" = "application/json")
  })

  resultado <- pg_get("programa", character(), "https://x", paginar = FALSE)

  expect_equal(nrow(resultado), 10)
  expect_equal(chamadas, 1L)
})

test_that("pg_get trunca e avisa quando atinge max_linhas (mocked)", {
  skip_on_cran()
  skip_if_not_installed("mockery")
  skip_if_not_installed("httr")
  skip_if_not_installed("jsonlite")

  corpo <- jsonlite::toJSON(data.frame(id = 1:10))

  mockery::stub(pg_get, "httr::GET", function(url) structure(list(), class = "resposta_simulada"))
  mockery::stub(pg_get, "httr::stop_for_status", function(resposta) resposta)
  mockery::stub(pg_get, "httr::content", function(resposta, tipo, encoding) corpo)
  mockery::stub(pg_get, "httr::headers", function(resposta) {
    list("content-type" = "application/json")
  })

  avisos <- capture_warnings(
    resultado <- pg_get("programa", character(), "https://x", limite = 10, max_linhas = 25)
  )

  expect_equal(nrow(resultado), 25)
  expect_true(any(grepl("Resultado parcial", avisos)))
})

test_that("pg_get devolve data.frame vazio quando nao ha linhas (mocked)", {
  skip_on_cran()
  skip_if_not_installed("mockery")
  skip_if_not_installed("httr")
  skip_if_not_installed("jsonlite")

  mockery::stub(pg_get, "httr::GET", function(url) structure(list(), class = "resposta_simulada"))
  mockery::stub(pg_get, "httr::stop_for_status", function(resposta) resposta)
  mockery::stub(pg_get, "httr::content", function(resposta, tipo, encoding) "[]")
  mockery::stub(pg_get, "httr::headers", function(resposta) {
    list("content-type" = "application/json")
  })

  resultado <- suppressWarnings(pg_get("programa", character(), "https://x"))

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 0)
})

test_that("pg_get aceita respostas HTTP 206 (Prefer: count=exact)", {
  skip_on_cran()
  skip_if_not_installed("mockery")
  skip_if_not_installed("httr")
  skip_if_not_installed("jsonlite")

  resposta_206 <- structure(
    list(
      url = "https://x/programa?limit=1000&offset=0",
      status_code = 206L,
      headers = list("content-type" = "application/json"),
      content = charToRaw('[{"a":1}]')
    ),
    class = "response"
  )

  mockery::stub(pg_get, "httr::GET", function(url) resposta_206)

  # `httr::stop_for_status()` não é substituído: o teste comprova que o 206
  # passa pela verificação real de status sem erro.
  resultado <- pg_get("programa", character(), "https://x")

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 1)
  expect_equal(resultado$a, 1)
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
