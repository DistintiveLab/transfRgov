# Testes para download_despesas_ptransp().
#
# Nenhum teste acessa a internet: download.file e unzip sao substituidos por
# stubs com mockery, e os arquivos de fixture sao criados no diretorio
# temporario da sessao. O ZIP diario de despesas tem cerca de 12 MB e o host
# da CGU limita rajadas de requisicoes, por isso nao ha cassettes aqui.

# Conteudo de marcador: identifica sem ambiguidade qual membro do ZIP foi lido.
conteudo_marcador <- function(membro) {
  paste(
    "Marcador;Valor",
    paste0(membro, ";1"),
    sep = "\n"
  )
}

conteudo_membro <- function(membro) {
  if (membro == "Empenho") {
    return(paste(
      "Id Empenho;Valor do Empenho Convertido pra R$",
      "1;100,50",
      sep = "\n"
    ))
  }
  conteudo_marcador(membro)
}

# Todos os onze membros medidos em um ZIP diario real do Portal.
membros_despesas <- c(
  "Empenho", "ItemEmpenho", "ItemEmpenhoHistorico", "Liquidacao",
  "Liquidacao_EmpenhosImpactados", "Pagamento", "Pagamento_EmpenhosImpactados",
  "Pagamento_FavorecidosFinais", "Pagamento_ListaBancos",
  "Pagamento_ListaFaturas", "Pagamento_ListaPrecatorios"
)

# Stub de download.file: apenas cria um arquivo no destino.
mock_download_file <- function() {
  function(url, destfile, mode) {
    writeLines("conteudo de zip simulado", con = destfile)
    invisible(0L)
  }
}

# Stub de unzip: escreve os membros pedidos e devolve os caminhos completos.
mock_unzip_membros <- function(membros = membros_despesas) {
  function(zipfile, exdir) {
    destino <- file.path(exdir, basename(tempfile("despesas")))
    dir.create(destino)
    caminhos <- file.path(
      destino,
      paste0("20240115_Despesas_", membros, ".csv")
    )
    for (i in seq_along(membros)) {
      writeLines(conteudo_membro(membros[[i]]), con = caminhos[[i]])
    }
    caminhos
  }
}

test_that("download_despesas_ptransp valida o parametro data", {
  expect_error(
    download_despesas_ptransp(),
    "O parâmetro 'data' deve ser uma única data válida"
  )
  expect_error(
    download_despesas_ptransp("nao-e-uma-data"),
    "O parâmetro 'data' deve ser uma única data válida"
  )
  expect_error(
    download_despesas_ptransp(as.Date(NA)),
    "O parâmetro 'data' deve ser uma única data válida"
  )
  expect_error(
    download_despesas_ptransp(c("2024-01-15", "2024-01-16")),
    "O parâmetro 'data' deve ser uma única data válida"
  )
  expect_error(
    download_despesas_ptransp(as.Date("2013-12-31")),
    "O parâmetro 'data' deve ser igual ou posterior a 2014-01-01"
  )
  expect_error(
    download_despesas_ptransp(Sys.Date() + 2),
    "O parâmetro 'data' não pode estar no futuro"
  )
})

test_that("download_despesas_ptransp valida o parametro tipo", {
  expect_error(download_despesas_ptransp(as.Date("2024-01-15"), tipo = "xyz"))
  expect_error(download_despesas_ptransp(as.Date("2024-01-15"), tipo = "Pagamento"))
})

test_that("download_despesas_ptransp le e limpa nomes do membro escolhido (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_despesas_ptransp, "download.file", mock_download_file())
  mockery::stub(download_despesas_ptransp, "unzip", mock_unzip_membros())

  resultado <- suppressMessages(
    download_despesas_ptransp(as.Date("2024-01-15"), tipo = "empenho")
  )

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 1)
  expect_true(all(c("id_empenho", "valor_do_empenho_convertido_pra_r") %in% names(resultado)))
})

test_that("download_despesas_ptransp escolhe o membro certo para cada tipo (mocked)", {
  skip_if_not_installed("mockery")

  tipos <- c(
    empenho = "Empenho",
    item_empenho = "ItemEmpenho",
    item_empenho_historico = "ItemEmpenhoHistorico",
    liquidacao = "Liquidacao",
    liquidacao_empenhos_impactados = "Liquidacao_EmpenhosImpactados",
    pagamento = "Pagamento",
    pagamento_empenhos_impactados = "Pagamento_EmpenhosImpactados",
    pagamento_favorecidos_finais = "Pagamento_FavorecidosFinais",
    pagamento_lista_bancos = "Pagamento_ListaBancos",
    pagamento_lista_faturas = "Pagamento_ListaFaturas",
    pagamento_lista_precatorios = "Pagamento_ListaPrecatorios"
  )

  mockery::stub(download_despesas_ptransp, "download.file", mock_download_file())
  mockery::stub(download_despesas_ptransp, "unzip", mock_unzip_membros())

  for (tipo in names(tipos)) {
    resultado <- suppressMessages(
      download_despesas_ptransp(as.Date("2024-01-15"), tipo = tipo)
    )
    esperado <- tipos[[tipo]]
    if (esperado == "Empenho") {
      expect_true("id_empenho" %in% names(resultado), info = tipo)
    } else {
      expect_equal(unique(resultado$marcador), esperado, info = tipo)
    }
  }
})

test_that("download_despesas_ptransp aceita o membro ListaFaturas no plural (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_despesas_ptransp, "download.file", mock_download_file())
  mockery::stub(
    download_despesas_ptransp, "unzip",
    mock_unzip_membros(c("Pagamento_ListaFatura"))
  )

  avisos <- capture_warnings(
    resultado <- suppressMessages(
      download_despesas_ptransp(as.Date("2024-01-15"), tipo = "pagamento_lista_faturas")
    )
  )

  expect_null(resultado)
  expect_true(any(grepl("Não foi encontrado o arquivo CSV", avisos)))
  expect_true(any(grepl("_Despesas_Pagamento_ListaFaturas.csv", avisos)))
})

test_that("download_despesas_ptransp devolve data frame vazio em dia sem movimento (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_despesas_ptransp, "download.file", mock_download_file())
  mockery::stub(
    download_despesas_ptransp, "unzip",
    function(zipfile, exdir) {
      destino <- file.path(exdir, basename(tempfile("despesas")))
      dir.create(destino)
      caminho <- file.path(destino, "20240101_Despesas_Pagamento.csv")
      writeLines("Codigo Pagamento;Valor do Pagamento Convertido pra R$", con = caminho)
      caminho
    }
  )

  resultado <- suppressMessages(
    download_despesas_ptransp(as.Date("2024-01-01"), tipo = "pagamento")
  )

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 0)
  expect_true(all(c("codigo_pagamento", "valor_do_pagamento_convertido_pra_r") %in% names(resultado)))
})

test_that("download_despesas_ptransp retorna NULL em falha de download (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(
    download_despesas_ptransp, "download.file",
    function(url, destfile, mode) {
      stop("Erro simulado de download")
    }
  )

  avisos <- capture_warnings(
    resultado <- suppressMessages(
      download_despesas_ptransp(as.Date("2024-01-15"))
    )
  )

  expect_null(resultado)
  expect_true(any(grepl("Erro ao baixar arquivo ZIP", avisos)))
})

test_that("download_despesas_ptransp retorna NULL em falha de descompactacao (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_despesas_ptransp, "download.file", mock_download_file())
  mockery::stub(
    download_despesas_ptransp, "unzip",
    function(zipfile, exdir) {
      stop("Erro simulado de descompactacao")
    }
  )

  avisos <- capture_warnings(
    resultado <- suppressMessages(
      download_despesas_ptransp(as.Date("2024-01-15"))
    )
  )

  expect_null(resultado)
  expect_true(any(grepl("Erro ao descompactar", avisos)))
})

test_that("download_despesas_ptransp retorna NULL se nada for extraido (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_despesas_ptransp, "download.file", mock_download_file())
  mockery::stub(
    download_despesas_ptransp, "unzip",
    function(zipfile, exdir) character(0)
  )

  avisos <- capture_warnings(
    resultado <- suppressMessages(
      download_despesas_ptransp(as.Date("2024-01-15"))
    )
  )

  expect_null(resultado)
  expect_true(any(grepl("Falha na descompactação ou nenhum arquivo foi extraído", avisos)))
})

test_that("download_despesas_ptransp usa read.csv quando read_delim falha (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_despesas_ptransp, "download.file", mock_download_file())
  mockery::stub(download_despesas_ptransp, "unzip", mock_unzip_membros(c("Empenho")))
  mockery::stub(
    download_despesas_ptransp, "read_delim",
    function(file, delim, quote, col_names, locale, show_col_types) {
      stop("Erro simulado de leitura com readr")
    }
  )

  avisos <- capture_warnings(
    resultado <- suppressMessages(
      download_despesas_ptransp(as.Date("2024-01-15"), tipo = "empenho")
    )
  )

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 1)
  expect_true(any(grepl("Tentar ler com base R read.csv", avisos)))
})

test_that("download_despesas_ptransp retorna NULL em falha total de leitura (mocked)", {
  skip_if_not_installed("mockery")

  mockery::stub(download_despesas_ptransp, "download.file", mock_download_file())
  mockery::stub(download_despesas_ptransp, "unzip", mock_unzip_membros(c("Empenho")))
  mockery::stub(
    download_despesas_ptransp, "read_delim",
    function(file, delim, quote, col_names, locale, show_col_types) {
      stop("Erro simulado de leitura com readr")
    }
  )
  mockery::stub(
    download_despesas_ptransp, "read.csv",
    function(...) {
      stop("Erro simulado de leitura com base R")
    }
  )

  avisos <- capture_warnings(
    resultado <- suppressMessages(
      download_despesas_ptransp(as.Date("2024-01-15"), tipo = "empenho")
    )
  )

  expect_null(resultado)
  expect_true(any(grepl("Falha final ao processar os dados de despesas", avisos)))
})

test_that("download_despesas_ptransp remove os temporarios apos o sucesso (mocked)", {
  skip_if_not_installed("mockery")

  caminhos <- NULL
  mockery::stub(download_despesas_ptransp, "download.file", mock_download_file())
  mockery::stub(
    download_despesas_ptransp, "unzip",
    function(zipfile, exdir) {
      caminhos <<- mock_unzip_membros(c("Pagamento"))(zipfile, exdir)
      caminhos
    }
  )

  resultado <- suppressMessages(
    download_despesas_ptransp(as.Date("2024-01-15"), tipo = "pagamento")
  )

  expect_s3_class(resultado, "data.frame")
  expect_false(any(file.exists(caminhos)))
})
