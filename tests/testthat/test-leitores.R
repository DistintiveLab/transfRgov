# Testes dos leitores de endpoints da API Fundo a Fundo.
#
# Nenhum teste acessa a internet: as respostas do pacote `httr2` são
# substituídas por `httr2::with_mocked_responses()`, com um mock que registra a
# URL requisitada e devolve um corpo sintético montado em `helper-httr2.R`. Por
# dependerem apenas de código local, os testes não levam `skip_on_cran()`.
#
# Todos os leitores seguem o mesmo contrato: cada parâmetro, exceto `select` e
# `order`, corresponde a uma coluna do endpoint e é convertido no filtro
# PostgREST `coluna=eq.valor`. Os testes percorrem a lista de leitores abaixo e
# verificam esse contrato sem repetir código para cada função.

# Nome de cada função leitora e endpoint (tabela) que ela deve consultar.
leitores <- list(
  ler_empenho = "empenho",
  ler_empenho_especial = "empenho_especial",
  ler_gestao_financeira_categorias_despesa = "gestao_financeira_categorias_despesa",
  ler_gestao_financeira_lancamentos = "gestao_financeira_lancamentos",
  ler_gestao_financeira_subtransacoes = "gestao_financeira_subtransacoes",
  get_plano_acao = "plano_acao",
  get_plano_acao_dado_bancario = "plano_acao_dado_bancario",
  get_plano_acao_historico = "plano_acao_historico",
  ler_plano_acao_meta = "plano_acao_meta",
  ler_plano_acao_meta_acao = "plano_acao_meta_acao",
  ler_programas = "programa",
  ler_programa_beneficiario = "programa_beneficiario",
  ler_programa_gestao_agil = "programa_gestao_agil",
  ler_programa_especial = "programa_especial",
  ler_relatorio_gestao = "relatorio_gestao",
  ler_relatorio_gestao_acoes = "relatorio_gestao_acoes",
  ler_relatorio_gestao_analise = "relatorio_gestao_analise",
  ler_relatorio_gestao_analise_responsavel = "relatorio_gestao_analise_responsavel",
  get_termo_adesao = "termo_adesao",
  ler_termo_adesao_historico = "termo_adesao_historico",
  ler_plano_acao_analise = "plano_acao_analise",
  ler_plano_acao_analise_responsavel = "plano_acao_analise_responsavel",
  get_plano_acao_destinacao_recursos = "plano_acao_destinacao_recursos"
)

# Valor sentinela usado nos filtros. Os leitores aceitam texto e número, e a
# comparação do valor não faz parte deste arquivo.
valor_sentinela <- 1L

# Devolve, para um leitor, a lista de argumentos que ativa todos os filtros: um
# valor sentinela por parâmetro, exceto `select` e `order`.
argumentos_com_filtros <- function(nome) {
  campos <- campos_do_leitor(nome)
  campos <- setdiff(campos, c("select", "order"))

  stats::setNames(rep(list(valor_sentinela), length(campos)), campos)
}

# Devolve os nomes dos parâmetros (as colunas do endpoint) de um leitor.
campos_do_leitor <- function(nome) {
  names(formals(get(nome, envir = asNamespace("transfRgov"))))
}

# Monta o corpo de uma resposta JSON com uma única linha contendo os campos
# indicados, todos com o valor sentinela.
corpo_com_uma_linha <- function(campos) {
  paste0("[{", paste0("\"", campos, "\":", valor_sentinela, collapse = ","), "}]")
}

# Executa um leitor com os argumentos indicados e devolve o resultado ao lado
# das URLs requisitadas. Os parâmetros ausentes de `argumentos` são enviados
# como `NULL`, que é o padrão das funções.
executar_leitor <- function(nome, argumentos = list(), corpo = "[]") {
  fn <- get(nome, envir = asNamespace("transfRgov"))
  campos <- names(formals(fn))

  desconhecidos <- setdiff(names(argumentos), campos)
  if (length(desconhecidos) > 0) {
    stop(
      "Argumento desconhecido para ", nome, ": ",
      paste(desconhecidos, collapse = ", ")
    )
  }

  valores <- lapply(campos, function(campo) argumentos[[campo]])
  names(valores) <- campos

  captura <- mock_capturando_urls(corpo)

  resultado <- sem_avisos(
    httr2::with_mocked_responses(captura$responder, do.call(fn, valores))
  )

  list(resultado = resultado, urls = captura$registro$urls)
}

# Extrai os nomes dos campos enviados como filtro `campo=eq.valor`.
campos_filtrados <- function(url) {
  padrao <- paste0("[^?&]+=eq\\.", valor_sentinela)
  encontrados <- regmatches(url, gregexpr(padrao, url))[[1]]

  sub(paste0("=eq\\.", valor_sentinela, "$"), "", encontrados)
}

test_that("a lista de leitores cobre todos os leitores exportados", {
  exportados <- getNamespaceExports("transfRgov")
  leitores_exportados <- grep("^(ler_|get_)", exportados, value = TRUE)

  expect_setequal(names(leitores), leitores_exportados)
})

for (nome in names(leitores)) {
  test_that(paste("leitor", nome, "consulta a tabela e envia todos os campos como filtro"), {
    tabela <- leitores[[nome]]
    argumentos <- argumentos_com_filtros(nome)
    execucao <- executar_leitor(nome, argumentos)
    url <- execucao$urls[[1]]

    # A resposta `[]` encerra a paginação na primeira página.
    expect_length(execucao$urls, 1)
    expect_match(url, paste0("/", tabela, "?"), fixed = TRUE)

    expect_setequal(campos_filtrados(url), names(argumentos))

    expect_false(grepl("select=", url, fixed = TRUE))
    expect_false(grepl("order=", url, fixed = TRUE))

    expect_s3_class(execucao$resultado, "data.frame")
    expect_equal(nrow(execucao$resultado), 0L)
  })

  test_that(paste("leitor", nome, "repassa select e order"), {
    execucao <- executar_leitor(
      nome,
      list(select = "campo_teste", order = "campo_teste.asc")
    )
    url <- execucao$urls[[1]]

    expect_match(url, "select=campo_teste", fixed = TRUE)
    expect_match(url, "order=campo_teste.asc", fixed = TRUE)
  })

  test_that(paste("leitor", nome, "devolve as colunas do endpoint"), {
    argumentos <- argumentos_com_filtros(nome)
    execucao <- executar_leitor(
      nome,
      argumentos,
      corpo = corpo_com_uma_linha(names(argumentos))
    )

    expect_s3_class(execucao$resultado, "data.frame")
    expect_equal(nrow(execucao$resultado), 1L)
    expect_setequal(names(execucao$resultado), names(argumentos))
  })
}
