# Testes do encadeamento `encadeia_despesas_ptransp()`.
#
# A função opera apenas sobre data frames já em memória, então nenhum teste
# acessa a internet e nada precisa ser mockado. A massa de teste imita os dois
# pares total/detalhe do ZIP diário do Portal da Transparência:
# `pagamento` com `pagamento_favorecidos_finais` (por `codigo_pagamento`) e
# `empenho` com `item_empenho` (por `id_empenho`).

# Três ordens bancárias, das quais duas têm detalhe e uma delas com dois
# favorecidos. É o caso 1:N que motiva a função.
pagamento <- data.frame(
  codigo_pagamento = c("A", "B", "C"),
  valor_do_pagamento_convertido_pra_r = c(100, 50, 25)
)

favorecidos <- data.frame(
  codigo_pagamento = c("A", "A", "B"),
  codigo_favorecido = c("F1", "F2", "F3"),
  valor_do_pagamento_em_r = c(60, 40, 50)
)

test_that("encadeia_despesas_ptransp detalha cada registro com uma ou mais linhas", {
  expect_no_warning(resultado <- encadeia_despesas_ptransp(pagamento, favorecidos))

  expect_s3_class(resultado, "data.frame")
  expect_identical(nrow(resultado), 4L)

  # A ordem de `total` é preservada e as duas linhas de A ficam adjacentes.
  expect_identical(resultado$codigo_pagamento, c("A", "A", "B", "C"))
  expect_identical(resultado$codigo_favorecido, c("F1", "F2", "F3", NA))
  expect_identical(resultado$valor_do_pagamento_em_r, c(60, 40, 50, NA))
  expect_identical(resultado$detalhado, c(TRUE, TRUE, TRUE, FALSE))
  expect_type(resultado$detalhado, "logical")
  expect_identical(rownames(resultado), as.character(1:4))
})

test_that("encadeia_despesas_ptransp põe `detalhado` logo depois da chave", {
  resultado <- encadeia_despesas_ptransp(pagamento, favorecidos)

  expect_identical(
    names(resultado),
    c(
      "codigo_pagamento",
      "detalhado",
      "valor_do_pagamento_convertido_pra_r",
      "codigo_favorecido",
      "valor_do_pagamento_em_r"
    )
  )

  # As colunas de valor têm nomes diferentes nos dois lados, então nenhuma
  # delas recebe sufixo.
  expect_false(any(grepl("\\.total$|\\.detalhe$", names(resultado))))
})

test_that("encadeia_despesas_ptransp sufixa as colunas homônimas", {
  total <- data.frame(
    codigo_pagamento = c("A", "B"),
    ano = c(2024L, 2024L),
    valor = c(100, 50)
  )
  detalhe <- data.frame(
    codigo_pagamento = c("A", "B"),
    ano = c(2023L, 2023L),
    favorecido = c("F1", "F2")
  )

  resultado <- encadeia_despesas_ptransp(total, detalhe)

  expect_identical(
    names(resultado),
    c(
      "codigo_pagamento",
      "detalhado",
      "ano.total",
      "valor",
      "ano.detalhe",
      "favorecido"
    )
  )
  expect_identical(resultado$ano.total, c(2024L, 2024L))
  expect_identical(resultado$ano.detalhe, c(2023L, 2023L))
  expect_identical(resultado$valor, c(100, 50))
  expect_identical(resultado$favorecido, c("F1", "F2"))
})

test_that("somente_detalhados = TRUE devolve apenas os registros detalhados", {
  resultado <- encadeia_despesas_ptransp(
    pagamento,
    favorecidos,
    somente_detalhados = TRUE
  )

  expect_identical(nrow(resultado), 3L)
  expect_identical(resultado$codigo_pagamento, c("A", "A", "B"))
  expect_true(all(resultado$detalhado))
  expect_false(anyNA(resultado$codigo_favorecido))
  expect_false(anyNA(resultado$valor_do_pagamento_em_r))
})

test_that("um detalhe vazio não é erro e não gera aviso", {
  vazio <- data.frame(
    codigo_pagamento = character(0),
    codigo_favorecido = character(0),
    valor_do_pagamento_em_r = numeric(0)
  )

  expect_no_warning(resultado <- encadeia_despesas_ptransp(pagamento, vazio))

  expect_identical(nrow(resultado), 3L)
  expect_identical(resultado$codigo_pagamento, c("A", "B", "C"))
  expect_identical(resultado$detalhado, c(FALSE, FALSE, FALSE))
  expect_true(all(is.na(resultado$codigo_favorecido)))
  expect_true(all(is.na(resultado$valor_do_pagamento_em_r)))

  # As colunas do detalhe mantêm o tipo mesmo sem nenhuma linha de origem.
  expect_type(resultado$codigo_favorecido, "character")
  expect_type(resultado$valor_do_pagamento_em_r, "double")
})

test_that("um total vazio devolve o mesmo desenho de colunas", {
  pagamento_vazio <- pagamento[0, , drop = FALSE]

  expect_no_warning(
    resultado <- encadeia_despesas_ptransp(pagamento_vazio, favorecidos)
  )

  expect_identical(nrow(resultado), 0L)
  expect_identical(
    names(resultado),
    names(encadeia_despesas_ptransp(pagamento, favorecidos))
  )
})

test_that("chaves disjuntas avisam que não houve detalhamento", {
  outro <- data.frame(
    codigo_pagamento = "Z",
    codigo_favorecido = "F9",
    valor_do_pagamento_em_r = 7
  )

  expect_warning(
    resultado <- encadeia_despesas_ptransp(pagamento, outro),
    "Nenhuma chave de 'total' foi encontrada em 'detalhe'"
  )

  expect_identical(nrow(resultado), 3L)
  expect_identical(resultado$detalhado, c(FALSE, FALSE, FALSE))
  expect_true(all(is.na(resultado$codigo_favorecido)))
})

test_that("encadeia_despesas_ptransp aceita o par empenho / item_empenho", {
  empenho <- data.frame(
    id_empenho = c(1L, 2L),
    valor = c(300, 700)
  )
  item <- data.frame(
    id_empenho = c(1L, 1L, 2L, 2L),
    item = c("a", "b", "c", "d")
  )

  resultado <- encadeia_despesas_ptransp(empenho, item, chave = "id_empenho")

  expect_identical(
    names(resultado),
    c("id_empenho", "detalhado", "valor", "item")
  )
  expect_identical(nrow(resultado), 4L)
  expect_true(all(resultado$detalhado))
  expect_identical(resultado$item, c("a", "b", "c", "d"))
})

test_that("encadeia_despesas_ptransp valida os argumentos", {
  expect_error(
    encadeia_despesas_ptransp(),
    "O parâmetro 'total' deve ser um data frame"
  )
  expect_error(
    encadeia_despesas_ptransp(pagamento),
    "O parâmetro 'detalhe' deve ser um data frame"
  )
  expect_error(
    encadeia_despesas_ptransp(list(), favorecidos),
    "O parâmetro 'total' deve ser um data frame"
  )
  expect_error(
    encadeia_despesas_ptransp(pagamento, 1),
    "O parâmetro 'detalhe' deve ser um data frame"
  )
  expect_error(
    encadeia_despesas_ptransp(pagamento, favorecidos, chave = 1),
    "O parâmetro 'chave' deve ser um texto válido"
  )
  expect_error(
    encadeia_despesas_ptransp(pagamento, favorecidos, chave = c("a", "b")),
    "O parâmetro 'chave' deve ser um texto válido"
  )
  expect_error(
    encadeia_despesas_ptransp(pagamento, favorecidos, chave = NA_character_),
    "O parâmetro 'chave' deve ser um texto válido"
  )
  expect_error(
    encadeia_despesas_ptransp(pagamento, favorecidos, somente_detalhados = NA),
    "O parâmetro 'somente_detalhados' deve ser TRUE ou FALSE"
  )
  expect_error(
    encadeia_despesas_ptransp(pagamento, favorecidos, somente_detalhados = "sim"),
    "O parâmetro 'somente_detalhados' deve ser TRUE ou FALSE"
  )
  expect_error(
    encadeia_despesas_ptransp(
      pagamento,
      favorecidos,
      somente_detalhados = c(TRUE, FALSE)
    ),
    "O parâmetro 'somente_detalhados' deve ser TRUE ou FALSE"
  )
})

test_that("encadeia_despesas_ptransp exige a chave nos dois data frames", {
  expect_error(
    encadeia_despesas_ptransp(pagamento, favorecidos, chave = "id_empenho"),
    "A coluna 'id_empenho' não existe em 'total'"
  )

  outro_nome <- data.frame(
    codigo_de_pagamento = "A",
    codigo_favorecido = "F1"
  )
  expect_error(
    encadeia_despesas_ptransp(pagamento, outro_nome),
    "A coluna 'codigo_pagamento' não existe em 'detalhe'"
  )
})

test_that("encadeia_despesas_ptransp recusa tipos divergentes na chave", {
  # O `merge` da base R casa `"1"` com `1` em silêncio, então a divergência
  # precisa virar erro aqui, e não um resultado errado mais adiante.
  texto <- data.frame(codigo_pagamento = "1", codigo_favorecido = "F1")
  numero <- data.frame(codigo_pagamento = 1L, valor = 100)

  expect_error(
    encadeia_despesas_ptransp(numero, texto),
    "A coluna 'codigo_pagamento' deve ter o mesmo tipo nos dois data frames"
  )
  expect_error(
    encadeia_despesas_ptransp(texto, numero),
    "A coluna 'codigo_pagamento' deve ter o mesmo tipo nos dois data frames"
  )

  # Dois tipos numéricos convivem: a checagem só exige que ambos sejam numéricos.
  inteiro <- data.frame(codigo_pagamento = 1L, valor = 100)
  decimal <- data.frame(codigo_pagamento = 1, favorecido = "F1")
  expect_identical(nrow(encadeia_despesas_ptransp(inteiro, decimal)), 1L)

  # `factor` não é o mesmo tipo que `character`.
  fator <- data.frame(codigo_pagamento = factor("A"), favorecido = "F1")
  expect_error(
    encadeia_despesas_ptransp(pagamento, fator),
    "A coluna 'codigo_pagamento' deve ter o mesmo tipo nos dois data frames"
  )
})
