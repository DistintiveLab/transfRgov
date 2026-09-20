# Testes do acessor `campos_metafaftab()`.
#
# O acessor lê apenas o conjunto de dados embarcado `metafaftab`, então nenhum
# teste acessa a internet e nada precisa ser mockado. As contagens abaixo
# (21 endpoints, 425 entradas, 264 nomes únicos, 278 campos de verdade, 255
# nomes únicos de campo e 147 parâmetros de controle) são o retrato atual de
# `data/metafaftab.rda`: se o conjunto for regravado, estes testes devem ser
# atualizados junto.

# Parâmetros de controle do PostgREST que aparecem nos 21 endpoints, mas não são
# colunas da resposta. O `select` fica de fora desta lista porque muda de nome em
# dois endpoints.
controles_fixos <- c("order", "range", "rangeUnit", "offset", "limit", "preferCount")

test_that("campos_metafaftab descreve todos os endpoints", {
  tabela <- campos_metafaftab()

  expect_s3_class(tabela, "data.frame")
  expect_identical(names(tabela), c("endpoint", "campo", "controle"))

  expect_identical(unique(tabela$endpoint), names(metafaftab))
  expect_length(unique(tabela$endpoint), 21L)

  completo <- campos_metafaftab(incluir_controle = TRUE)
  expect_identical(completo$endpoint, rep(names(metafaftab), lengths(metafaftab)))
  expect_identical(completo$campo, unlist(metafaftab, use.names = FALSE))
})

test_that("campos_metafaftab omite os parâmetros de controle por padrão", {
  tabela <- campos_metafaftab()

  expect_false(any(tabela$campo %in% controles_fixos))
  expect_false(any(grepl("^select", tabela$campo)))
  expect_false(any(tabela$controle))
  expect_identical(nrow(tabela), 278L)
  expect_identical(length(unique(tabela$campo)), 255L)

  # O mesmo nome de campo pode aparecer em endpoints diferentes (`id_plano_acao`
  # está em nove deles), mas nunca duas vezes no mesmo endpoint.
  dentro_do_endpoint <- split(tabela$campo, tabela$endpoint)
  expect_true(all(sapply(dentro_do_endpoint, anyDuplicated) == 0L))
})

test_that("campos_metafaftab inclui e sinaliza os parâmetros de controle", {
  tabela <- campos_metafaftab(incluir_controle = TRUE)

  expect_identical(nrow(tabela), 425L)
  expect_identical(length(unique(tabela$campo)), 264L)
  expect_identical(sum(tabela$controle), 147L)
  expect_identical(sum(tabela$controle), 7L * length(metafaftab))

  expect_setequal(
    unique(tabela$campo[tabela$controle]),
    c(
      controles_fixos,
      "select",
      "select_plano_acao",
      "select_relatorio_gestao_analise"
    )
  )

  for (controle in controles_fixos) {
    expect_length(unique(tabela$endpoint[tabela$campo == controle]), 21L)
  }

  # `select` não existe em /plano_acao nem em /relatorio_gestao_analise, que
  # usam o nome próprio.
  endpoints_select <- unique(tabela$endpoint[tabela$campo == "select"])
  expect_length(endpoints_select, 19L)
  expect_false("/plano_acao" %in% endpoints_select)
  expect_false("/relatorio_gestao_analise" %in% endpoints_select)

  expect_identical(
    tabela$endpoint[tabela$campo == "select_plano_acao"],
    "/plano_acao"
  )
  expect_identical(
    tabela$endpoint[tabela$campo == "select_relatorio_gestao_analise"],
    "/relatorio_gestao_analise"
  )
})

test_that("campos_metafaftab classifica sete controles em cada endpoint", {
  tabela <- campos_metafaftab(incluir_controle = TRUE)

  por_endpoint <- split(tabela$controle, tabela$endpoint)
  total <- vapply(por_endpoint, sum, integer(1))

  expect_length(total, length(metafaftab))
  expect_true(all(total == 7L))
})

test_that("campos_metafaftab devolve os campos de um endpoint", {
  brutos <- metafaftab[["/empenho"]]
  esperado <- brutos[!brutos %in% c("select", controles_fixos)]

  campos <- campos_metafaftab("/empenho")

  expect_type(campos, "character")
  expect_identical(campos, esperado)
  expect_false(any(campos %in% controles_fixos))
  expect_identical(length(brutos), 37L)
  expect_identical(length(campos), 30L)

  # A barra inicial é opcional.
  expect_identical(campos_metafaftab("empenho"), campos)

  campos_com_controle <- campos_metafaftab("/empenho", incluir_controle = TRUE)
  expect_identical(campos_com_controle, brutos)

  # Os dois endpoints com `select` de nome próprio também perdem os sete
  # controles.
  for (chave in c("/plano_acao", "/relatorio_gestao_analise")) {
    campos <- campos_metafaftab(chave)

    expect_identical(length(campos), length(metafaftab[[chave]]) - 7L)
    expect_false(any(campos %in% controles_fixos))
    expect_false(any(grepl("^select", campos)))
  }
})

test_that("campos_metafaftab aceita os 21 endpoints com e sem barra inicial", {
  for (chave in names(metafaftab)) {
    sem_barra <- sub("^/", "", chave)
    expect_identical(campos_metafaftab(sem_barra), campos_metafaftab(chave))
    expect_false(any(campos_metafaftab(chave) %in% controles_fixos))
  }
})

test_that("campos_metafaftab valida os argumentos", {
  expect_error(
    campos_metafaftab("/nao_existe"),
    "O parâmetro 'endpoint' deve ser um dos"
  )
  expect_error(
    campos_metafaftab(c("/programa", "/empenho")),
    "O parâmetro 'endpoint' deve ser um único caminho"
  )
  expect_error(
    campos_metafaftab(1),
    "O parâmetro 'endpoint' deve ser um único caminho"
  )
  expect_error(
    campos_metafaftab(incluir_controle = NA),
    "O parâmetro 'incluir_controle' deve ser TRUE ou FALSE"
  )
  expect_error(
    campos_metafaftab(incluir_controle = "sim"),
    "O parâmetro 'incluir_controle' deve ser TRUE ou FALSE"
  )
})
