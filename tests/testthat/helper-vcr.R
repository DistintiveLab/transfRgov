# Auxiliares das cassettes gravadas com o pacote `vcr`.
#
# As cassettes de `_vcr/` reproduzem as respostas da API do TransfereGov, de
# modo que os testes de comportamento real (paginação, `select`, `order`,
# resultado vazio e erro HTTP) rodem também no CRAN, sem acesso à rede.
#
# Atenção: o `vcr` precisa estar anexado ao caminho de busca, e não apenas
# qualificado com `vcr::`. O `webmockr` só repassa as requisições ao `vcr`
# quando `"package:vcr" %in% search()` é verdadeiro; sem o `library(vcr)`
# abaixo a requisição sai para a rede de verdade e a cassette fica vazia.

if (requireNamespace("vcr", quietly = TRUE)) {
  library(vcr)
  vcr::vcr_configure(dir = vcr::vcr_test_path("testthat", "_vcr"), record = "once")
}
