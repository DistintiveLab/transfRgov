# Obter dados do endpoint plano_acao_historico

Esta função acessa os dados do endpoint \*\*plano_acao_historico\*\* da
API FundoaFundo (TransfereGov) utilizando a função interna `pg_get`. Em
vez de incorporar o endpoint na URL, utiliza-se o parâmetro
`table = "plano_acao_historico"` para especificar a tabela a ser
consultada. Os filtros são aplicados por meio do argumento `filter` e
devem estar no formato "nome_parametro=eq.valor". Todos os parâmetros
são opcionais.

## Usage

``` r
get_plano_acao_historico(
  id_historico_plano_acao = NULL,
  situacao_historico_plano_acao = NULL,
  data_historico_plano_acao = NULL,
  versao_historico_plano_acao = NULL,
  id_plano_acao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_historico_plano_acao:

  Identificador do histórico do plano de ação (numérico).

- situacao_historico_plano_acao:

  Situação do histórico do plano de ação (texto).

- data_historico_plano_acao:

  Data do histórico do plano de ação (formato YYYY-MM-DD).

- versao_historico_plano_acao:

  Versão do histórico do plano de ação (texto ou numérico).

- id_plano_acao:

  Identificador do plano de ação ao qual o histórico está vinculado
  (numérico).

- select:

  Vetor de caracteres com os nomes das colunas a serem retornadas.
  Quando `NULL` (padrão), todas as colunas do endpoint são retornadas.

- order:

  Vetor de caracteres com os critérios de ordenação, no formato
  `"coluna.asc"` ou `"coluna.desc"`. Quando `NULL` (padrão), a ordem
  definida pela API é mantida.

## Value

Um objeto contendo os dados retornados pela API (geralmente uma lista ou
data.frame).

## Examples

``` r
if (FALSE) { # \dontrun{
  # Exemplo: consultar o histórico de um plano de ação específico
  historico <- get_plano_acao_historico(id_plano_acao = 1234)
  head(historico)
} # }
```
