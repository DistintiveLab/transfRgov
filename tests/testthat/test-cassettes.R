# Testes de comportamento real da API Fundo a Fundo com cassettes do `vcr`.
#
# Cada bloco abaixo reproduz uma resposta gravada da API verdadeira, guardada em
# `_vcr/`. A gravação cobre comportamentos que os mocks não exercitam: a
# paginação em duas páginas, o ida-e-volta de `select` e `order`, o resultado
# vazio e o erro HTTP 400 devolvido pela API. Como as cassettes são gravadas uma
# única vez e depois apenas reproduzidas, estes testes rodam no CRAN sem acesso
# à rede — por isso não levam `skip_on_cran()`.
#
# Os auxiliares do `vcr` ficam em `helper-vcr.R`. Nenhuma cassette usa uma
# `limite` grande: a página gravada precisa ser curta para o laço de paginação
# de `pg_get()` terminar na reprodução.

test_that("pg_get percorre duas paginas gravadas da API", {
  skip_if_not_installed("vcr")
  skip_if_not_installed("httr2")
  vcr::skip_if_vcr_off()

  vcr::use_cassette("programa_paginacao", {
    resultado <- sem_avisos(
      transfRgov:::pg_get(
        "programa", character(),
        select = "id_programa", order = "id_programa.asc",
        limite = 2, max_linhas = 4
      )
    )

    expect_equal(nrow(resultado), 4)
    expect_equal(resultado$id_programa, 1:4)
  })
})

test_that("pg_get respeita select e order decrescente gravados", {
  skip_if_not_installed("vcr")
  skip_if_not_installed("httr2")
  vcr::skip_if_vcr_off()

  vcr::use_cassette("programa_select_order", {
    resultado <- sem_avisos(
      transfRgov:::pg_get(
        "programa", character(),
        select = c("id_programa", "ano_programa", "nome_programa"),
        order = "ano_programa.desc",
        limite = 3, max_linhas = 3
      )
    )

    expect_equal(names(resultado), c("id_programa", "ano_programa", "nome_programa"))
    expect_equal(nrow(resultado), 3)
    expect_true(all(diff(as.integer(resultado$ano_programa)) <= 0))
  })
})

test_that("pg_get respeita order ascendente gravado", {
  skip_if_not_installed("vcr")
  skip_if_not_installed("httr2")
  vcr::skip_if_vcr_off()

  vcr::use_cassette("programa_order_asc", {
    resultado <- sem_avisos(
      transfRgov:::pg_get(
        "programa", character(),
        select = "ano_programa", order = "ano_programa.asc",
        limite = 3, max_linhas = 3
      )
    )

    expect_equal(nrow(resultado), 3)
    expect_true(all(diff(as.integer(resultado$ano_programa)) >= 0))
  })
})

test_that("pg_get devolve data.frame vazio quando nao ha linhas", {
  skip_if_not_installed("vcr")
  skip_if_not_installed("httr2")
  vcr::skip_if_vcr_off()

  vcr::use_cassette("programa_vazio", {
    resultado <- transfRgov:::pg_get(
      "programa", c("ano_programa=eq.1900"),
      limite = 2
    )

    expect_s3_class(resultado, "data.frame")
    expect_equal(nrow(resultado), 0)
  })
})

test_that("pg_get devolve a linha unica de um filtro de igualdade gravado", {
  skip_if_not_installed("vcr")
  skip_if_not_installed("httr2")
  vcr::skip_if_vcr_off()

  vcr::use_cassette("programa_filtro", {
    resultado <- transfRgov:::pg_get(
      "programa", c("id_programa=eq.1"),
      select = "id_programa", limite = 2
    )

    expect_equal(nrow(resultado), 1)
    expect_equal(resultado$id_programa, 1)
  })
})

test_that("pg_get propaga o erro HTTP 400 gravado da API", {
  skip_if_not_installed("vcr")
  skip_if_not_installed("httr2")
  vcr::skip_if_vcr_off()

  vcr::use_cassette("programa_order_invalido", {
    expect_error(
      transfRgov:::pg_get("programa", character(), order = "naoexiste.asc"),
      class = "httr2_http_400"
    )
  })
})
