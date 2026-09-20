# Auxiliares de HTTP compartilhados pelos arquivos de teste.
#
# Os testes de rede substituem as respostas do pacote `httr2` por objetos
# sintéticos montados aqui e por `httr2::with_mocked_responses()`, portanto
# nenhum teste acessa a internet.

# Cria uma resposta simulada do httr2 em resposta a uma requisição.
resposta_simulada <- function(req, corpo, tipo = "application/json", status = 200L) {
  httr2::response(
    status,
    url = req$url,
    headers = list("content-type" = tipo),
    body = charToRaw(corpo)
  )
}

# Cria um mock que registra a URL de cada requisição e devolve sempre o mesmo
# corpo. O registro fica em um ambiente próprio, de modo que o chamador leia as
# URLs efetivamente enviadas mesmo depois de o mock ter sido usado.
mock_capturando_urls <- function(corpo = "[]", tipo = "application/json") {
  registro <- new.env(parent = emptyenv())
  registro$urls <- character()

  responder <- function(req) {
    registro$urls <- c(registro$urls, req$url)
    resposta_simulada(req, corpo, tipo = tipo)
  }

  list(registro = registro, responder = responder)
}

# Avalia uma expressão silenciando os avisos sinalizados. Os avisos do pacote
# usam classes de condição próprias e são verificados em testes específicos.
sem_avisos <- function(expr) {
  withCallingHandlers(
    expr,
    warning = function(w) invokeRestart("muffleWarning")
  )
}
