#' @title Consultar Valores de Renúncia Fiscal
#'
#' @description Esta função busca os dados de renúncias fiscais da API do Portal da Transparência do Governo Federal.
#'
#' @param pagina O número da página a ser retornada. O padrão é 1.
#' @param uf String com o nome ou a sigla da Unidade Federativa a ser consultada. Ex: "São Paulo" ou "SP".
#' @param codigo_ibge String com o código IBGE do município a ser consultado.
#' @param cnpj String com o CNPJ do beneficiário a ser consultado (apenas números).
#' @param chave_api A sua chave da API. Por padrão, a função buscará a variável de ambiente 'PORTAL_TRANSPARENCIA_API_KEY'.
#'
#' @return Um data.frame com os dados das renúncias fiscais.
#'
#' @examples
#' \dontrun{
#'   # Para usar esta função, você precisa de uma chave de API válida
#'   # e tê-la configurado em seu ambiente.
#'   dados_renuncia <- consultar_renuncias_fiscais(ano = 202301)
#'   print(dados_renuncia)
#' }
#'
#' @export
consultar_renuncias_fiscais <- \(pagina = 1,
                                 uf = NULL,
                                 codigo_ibge = NULL,
                                 cnpj = NULL,
                                 chave_api = Sys.getenv("PORTAL_TRANSPARENCIA_API_KEY")) {

  # Validação da chave da API
  if (chave_api == "") {
    stop("A chave da API não foi encontrada. Por favor, configure a variável de ambiente 'PORTAL_TRANSPARENCIA_API_KEY' ou forneça a chave diretamente no parâmetro 'chave_api'.")
  }

  # URL base da API
  base_url <- "https://api.portaldatransparencia.gov.br/api-de-dados/renuncias-valor"

  # Cria uma lista para os parâmetros da query. Começa com os obrigatórios.
  params <- list(
    pagina = pagina
  )

  # Adiciona os parâmetros opcionais à lista apenas se eles foram fornecidos
  if (!is.null(uf)) {
    params$nomeSiglaUF <- uf
  }
  if (!is.null(codigo_ibge)) {
    params$codigoIbge <- codigo_ibge
  }
  if (!is.null(cnpj)) {
    params$cnpj <- cnpj
  }

  # Montando a requisição
  resposta <- httr::GET(
    url = base_url,
    query = params,
    httr::add_headers(`chave-api-dados` = chave_api)
  )

  # Verificando o status da resposta HTTP
  httr::stop_for_status(resposta, "consultar a API do Portal da Transparência")

  # Processando o conteúdo da resposta
  conteudo <- httr::content(resposta, "text", encoding = "UTF-8")
  dados <- jsonlite::fromJSON(conteudo, flatten = TRUE)

  # Verificando se a consulta retornou dados
  if (length(dados) == 0) {
    warning("A consulta não retornou dados para os parâmetros fornecidos.")
    return(data.frame())
  }

  return(dados)
}
