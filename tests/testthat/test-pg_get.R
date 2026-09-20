# Testes das funções internas de consulta à API (helpers PostgREST).
#
# As funções `pg_encode_filter()`, `pg_encode_lista()`, `pg_build_url()` e
# `pg_parse_response()` são puras e podem ser testadas sem acesso à rede. Os
# testes de `pg_get()` substituem as respostas do pacote `httr2` por
# `httr2::local_mocked_responses()`, portanto também não acessam a internet.
# Os auxiliares usados aqui ficam em `helper-httr2.R`.

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

test_that("pg_encode_lista reune as colunas codificadas em uma unica string", {
  expect_equal(
    transfRgov:::pg_encode_lista(c("id_programa", "nome_programa")),
    "id_programa,nome_programa"
  )

  expect_equal(transfRgov:::pg_encode_lista("ano_programa.desc"), "ano_programa.desc")

  expect_equal(transfRgov:::pg_encode_lista("nome do municipio"), "nome%20do%20municipio")

  expect_null(transfRgov:::pg_encode_lista(NULL))
  expect_null(transfRgov:::pg_encode_lista(character()))
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

test_that("pg_build_url acrescenta as cláusulas select e order", {
  expect_equal(
    transfRgov:::pg_build_url("programa", character(), "https://x", select = "id_programa"),
    "https://x/programa?select=id_programa"
  )

  expect_equal(
    transfRgov:::pg_build_url(
      "programa", character(), "https://x",
      select = c("id_programa", "nome_programa"), order = "ano_programa.desc"
    ),
    "https://x/programa?select=id_programa,nome_programa&order=ano_programa.desc"
  )

  expect_equal(
    transfRgov:::pg_build_url("programa", character(), "https://x", order = NULL),
    "https://x/programa?"
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

test_that("pg_parse_response trata corpo vazio como ausencia de linhas", {
  skip_if_not_installed("jsonlite")

  vazio <- transfRgov:::pg_parse_response("application/json", "")

  expect_true(vazio$suportado)
  expect_s3_class(vazio$dados, "data.frame")
  expect_equal(nrow(vazio$dados), 0)

  expect_equal(nrow(transfRgov:::pg_parse_response("application/json", "   \n")$dados), 0)
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

test_that("pg_warning cria condicoes com classe propria", {
  condicao <- NULL

  withCallingHandlers(
    transfRgov:::pg_warning("mensagem de teste", "minha_classe"),
    warning = function(w) {
      condicao <<- w
      invokeRestart("muffleWarning")
    }
  )

  expect_s3_class(condicao, "transfRgov_minha_classe")
  expect_s3_class(condicao, "warning")
  expect_s3_class(condicao, "condition")
  expect_equal(conditionMessage(condicao), "mensagem de teste")
  expect_null(conditionCall(condicao))

  # A classe permite o tratamento seletivo no chamador.
  capturada <- tryCatch(
    transfRgov:::pg_warning("outra mensagem", "minha_classe"),
    transfRgov_minha_classe = function(w) "capturada"
  )

  expect_equal(capturada, "capturada")
})

test_that("pg_user_agent identifica o pacote", {
  agente <- transfRgov:::pg_user_agent()

  expect_type(agente, "character")
  expect_length(agente, 1)
  expect_match(agente, "^transfRgov/")
  expect_match(agente, "DistintiveLab/transfRgov", fixed = TRUE)
})

test_that("pg_get monta a URL, le o conteudo e converte a resposta (mocked)", {
  skip_if_not_installed("httr2")
  skip_if_not_installed("jsonlite")

  urls_consultadas <- character()

  httr2::local_mocked_responses(function(req) {
    urls_consultadas <<- c(urls_consultadas, req$url)
    resposta_simulada(req, '{"a":1}')
  })

  resultado <- pg_get("programa", c("ano_programa=eq.2020"), "https://x")

  expect_equal(resultado, list(a = 1))
  expect_equal(
    urls_consultadas,
    "https://x/programa?ano_programa=eq.2020&limit=1000&offset=0"
  )
})

test_that("pg_get envia User-Agent, tempo limite e repeticoes na requisicao", {
  skip_if_not_installed("httr2")
  skip_if_not_installed("jsonlite")

  capturada <- NULL

  httr2::local_mocked_responses(function(req) {
    capturada <<- req
    resposta_simulada(req, '{"a":1}')
  })

  pg_get("programa", character(), "https://x", tempo_limite = 12, tentativas = 4L)

  expect_equal(capturada$options$useragent, transfRgov:::pg_user_agent())
  expect_equal(capturada$options$timeout_ms, 12000)
  expect_equal(capturada$policies$retry_max_tries, 4L)
})

test_that("pg_get nao engole falha transitoria (mocked)", {
  skip_if_not_installed("httr2")

  # As respostas simuladas curto-circuitam o laco de repeticoes do proprio
  # `httr2::req_perform()`, entao a repeticao em si e responsabilidade do
  # httr2 (a politica e verificada no teste do User-Agent). O contrato
  # testado aqui e que o `pg_get` propaga o erro em vez de mascara-lo.
  chamadas <- 0L

  httr2::local_mocked_responses(function(req) {
    chamadas <<- chamadas + 1L
    resposta_simulada(req, "indisponivel", tipo = "text/plain", status = 503L)
  })

  expect_error(
    pg_get("programa", character(), "https://x", limite = 100, tentativas = 2L),
    class = "httr2_http_503"
  )

  expect_equal(chamadas, 1L)
})

test_that("pg_get nao repete erros HTTP definitivos (mocked)", {
  skip_if_not_installed("httr2")

  chamadas <- 0L

  httr2::local_mocked_responses(function(req) {
    chamadas <<- chamadas + 1L
    resposta_simulada(req, "erro de filtro", tipo = "text/plain", status = 400L)
  })

  expect_error(
    pg_get("programa", c("ano_programa=eq.abc"), "https://x", tentativas = 3L),
    class = "httr2_http_400"
  )

  # Um 400 e definitivo: as tres tentativas configuradas nao sao consumidas.
  expect_equal(chamadas, 1L)
})

test_that("pg_get percorre todas as paginas ate a ultima incompleta (mocked)", {
  skip_if_not_installed("httr2")
  skip_if_not_installed("jsonlite")

  urls_consultadas <- character()

  httr2::local_mocked_responses(function(req) {
    urls_consultadas <<- c(urls_consultadas, req$url)
    corpo <- if (length(urls_consultadas) == 1L) {
      jsonlite::toJSON(data.frame(id = 1:1000))
    } else {
      jsonlite::toJSON(data.frame(id = 1001:1005))
    }
    resposta_simulada(req, corpo)
  })

  resultado <- pg_get("programa", "ano_programa=eq.2020", "https://x")

  expect_equal(nrow(resultado), 1005)
  expect_equal(length(urls_consultadas), 2L)
  expect_true(grepl("offset=0&?$", urls_consultadas[[1]]))
  expect_true(grepl("offset=1000&?$", urls_consultadas[[2]]))
})

test_that("pg_get repassa select e order em todas as paginas (mocked)", {
  skip_if_not_installed("httr2")
  skip_if_not_installed("jsonlite")

  urls_consultadas <- character()

  httr2::local_mocked_responses(function(req) {
    urls_consultadas <<- c(urls_consultadas, req$url)
    corpo <- if (length(urls_consultadas) == 1L) {
      jsonlite::toJSON(data.frame(id = 1:1000))
    } else {
      jsonlite::toJSON(data.frame(id = 1001:1002))
    }
    resposta_simulada(req, corpo)
  })

  resultado <- pg_get(
    "programa", character(), "https://x",
    select = c("id_programa", "ano_programa"), order = "ano_programa.desc"
  )

  expect_equal(nrow(resultado), 1002)
  expect_equal(length(urls_consultadas), 2L)

  for (url in urls_consultadas) {
    expect_match(url, "select=id_programa,ano_programa", fixed = TRUE)
    expect_match(url, "order=ano_programa.desc", fixed = TRUE)
  }
})

test_that("pg_get nao pagina quando paginar = FALSE (mocked)", {
  skip_if_not_installed("httr2")
  skip_if_not_installed("jsonlite")

  chamadas <- 0L

  httr2::local_mocked_responses(function(req) {
    chamadas <<- chamadas + 1L
    resposta_simulada(req, jsonlite::toJSON(data.frame(id = 1:10)))
  })

  resultado <- pg_get("programa", character(), "https://x", paginar = FALSE)

  expect_equal(nrow(resultado), 10)
  expect_equal(chamadas, 1L)
})

test_that("pg_get trunca e avisa quando atinge max_linhas (mocked)", {
  skip_if_not_installed("httr2")
  skip_if_not_installed("jsonlite")

  corpo <- jsonlite::toJSON(data.frame(id = 1:10))

  httr2::local_mocked_responses(function(req) {
    resposta_simulada(req, corpo)
  })

  expect_warning(
    resultado <- pg_get("programa", character(), "https://x", limite = 10, max_linhas = 25),
    class = "transfRgov_partial_result"
  )

  expect_equal(nrow(resultado), 25)
})

test_that("pg_get devolve data.frame vazio quando nao ha linhas (mocked)", {
  skip_if_not_installed("httr2")
  skip_if_not_installed("jsonlite")

  httr2::local_mocked_responses(function(req) {
    resposta_simulada(req, "[]")
  })

  resultado <- suppressWarnings(pg_get("programa", character(), "https://x"))

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 0)
})

test_that("pg_get trata corpo vazio como data.frame vazio (mocked)", {
  skip_if_not_installed("httr2")
  skip_if_not_installed("jsonlite")

  httr2::local_mocked_responses(function(req) {
    httr2::response(
      200L,
      url = req$url,
      headers = list("content-type" = "application/json"),
      body = raw()
    )
  })

  resultado <- suppressWarnings(pg_get("programa", character(), "https://x"))

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 0)
})

test_that("pg_get aceita respostas HTTP 206 (Prefer: count=exact)", {
  skip_if_not_installed("httr2")
  skip_if_not_installed("jsonlite")

  httr2::local_mocked_responses(function(req) {
    resposta_simulada(req, '[{"a":1}]', status = 206L)
  })

  # Nenhum tratamento de erro e substituido: o teste comprova que o 206 passa
  # pela verificacao real de status do httr2 sem levantar erro.
  resultado <- pg_get("programa", character(), "https://x")

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 1)
  expect_equal(resultado$a, 1)
})

test_that("pg_get avisa e devolve a resposta quando o tipo nao e suportado (mocked)", {
  skip_if_not_installed("httr2")

  httr2::local_mocked_responses(function(req) {
    resposta_simulada(req, "<html></html>", tipo = "text/html")
  })

  expect_warning(
    resultado <- suppressMessages(pg_get("programa")),
    class = "transfRgov_unsupported_type"
  )

  expect_s3_class(resultado, "httr2_response")
  expect_equal(httr2::resp_status(resultado), 200L)
})
