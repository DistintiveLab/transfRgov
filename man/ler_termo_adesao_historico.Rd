% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ler_termo_adesao_historico.R
\name{ler_termo_adesao_historico}
\alias{ler_termo_adesao_historico}
\title{Obter dados do endpoint termo_adesao_historico}
\usage{
ler_termo_adesao_historico(
  id_historico_termo_adesao = NULL,
  situacao_historico_termo_adesao = NULL,
  data_historico_termo_adesao = NULL,
  id_termo_adesao = NULL
)
}
\value{
Um objeto contendo os dados retornados pela API (geralmente uma lista ou data.frame).
}
\description{
Esta função acessa os dados do endpoint **termo_adesao_historico** da API FundoaFundo (TransfereGov)
utilizando a função \code{pg.get} do pacote postgrestR. Em vez de incorporar o endpoint na URL,
utiliza-se o parâmetro \code{table = "termo_adesao_historico"} para especificar a tabela a ser consultada.
Os filtros são aplicados por meio do argumento \code{filter} e devem estar no formato "nome_parametro=eq.valor".
Todos os parâmetros são opcionais.
}
\details{
Parâmetros disponíveis:
\describe{
  \item{\code{id_historico_termo_adesao}}{Identificador do histórico do termo de adesão (numérico).}
  \item{\code{situacao_historico_termo_adesao}}{Situação do histórico do termo de adesão (texto).}
  \item{\code{data_historico_termo_adesao}}{Data do histórico do termo de adesão (formato YYYY-MM-DD).}
  \item{\code{id_termo_adesao}}{Identificador do termo de adesão ao qual o histórico está vinculado (numérico).}
}
}
\examples{
\dontrun{
  # Exemplo: consultar o histórico de um termo de adesão específico
  historico <- ler_termo_adesao_historico(id_termo_adesao = 1234)
  head(historico)
}

}
