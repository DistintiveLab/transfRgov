# Obter dados do endpoint plano_acao_analise

Esta função acessa os dados do endpoint \*\*plano_acao_analise\*\* da
API FundoaFundo (TransfereGov) utilizando a função interna `pg_get`. Em
vez de incorporar o endpoint na URL, utiliza-se o parâmetro
`table = "plano_acao_analise"` para especificar a tabela a ser
consultada. Os filtros são aplicados por meio do argumento `filter` e
devem estar no formato "nome_parametro=eq.valor". Todos os parâmetros
são opcionais.

## Usage

``` r
ler_plano_acao_analise(
  id_analise_plano_acao = NULL,
  tipo_analise_plano_acao = NULL,
  tipo_analise_resultado_plano_acao = NULL,
  data_analise_plano_acao = NULL,
  parecer_analise_plano_acao = NULL,
  tipo_origem_analise_plano_acao = NULL,
  id_plano_acao = NULL,
  id_historico_plano_acao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_analise_plano_acao:

  Identificador da análise do plano de ação (numérico).

- tipo_analise_plano_acao:

  Tipo da análise do plano de ação (texto).

- tipo_analise_resultado_plano_acao:

  Tipo do resultado da análise do plano de ação (texto).

- data_analise_plano_acao:

  Data da análise do plano de ação (formato YYYY-MM-DD).

- parecer_analise_plano_acao:

  Parecer da análise do plano de ação (texto).

- tipo_origem_analise_plano_acao:

  Tipo de origem da análise do plano de ação (texto).

- id_plano_acao:

  Identificador do plano de ação ao qual a análise está vinculada
  (numérico).

- id_historico_plano_acao:

  Identificador do histórico do plano de ação (numérico).

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
  # Exemplo: consultar análises de plano de ação para um plano específico
  analise <- ler_plano_acao_analise(id_plano_acao = 1234)
  head(analise)
} # }
```
