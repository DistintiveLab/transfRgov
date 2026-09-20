# Obter dados do endpoint plano_acao_destinacao_recursos

Esta função acessa os dados do endpoint
\*\*plano_acao_destinacao_recursos\*\* da API FundoaFundo (TransfereGov)
utilizando a função interna `pg_get`. Em vez de incorporar o endpoint na
URL, utiliza-se o parâmetro `table = "plano_acao_destinacao_recursos"`
para especificar a tabela a ser consultada. Os filtros são aplicados por
meio do argumento `filter` e devem estar no formato
"nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Usage

``` r
get_plano_acao_destinacao_recursos(
  id_destinacao_recursos_plano_acao = NULL,
  codigo_natureza_despesa_destinacao_recursos_plano_acao = NULL,
  descricao_natureza_despesa_destinacao_recursos_plano_acao = NULL,
  tipo_despesa_destinacao_recursos_plano_acao = NULL,
  valor_destinacao_recursos_plano_acao = NULL,
  id_plano_acao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_destinacao_recursos_plano_acao:

  Identificador da destinacão de recursos do plano de ação (numérico).

- codigo_natureza_despesa_destinacao_recursos_plano_acao:

  Código da natureza de despesa (texto ou numérico).

- descricao_natureza_despesa_destinacao_recursos_plano_acao:

  Descrição da natureza de despesa (texto).

- tipo_despesa_destinacao_recursos_plano_acao:

  Tipo de despesa da destinacão de recursos (texto).

- valor_destinacao_recursos_plano_acao:

  Valor destinado (numérico).

- id_plano_acao:

  Identificador do plano de ação ao qual a destinacão de recursos está
  vinculada (numérico).

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
# \donttest{
  # Exemplo: consultar destinacões de recursos para um determinado plano de ação
  dest_recursos <- get_plano_acao_destinacao_recursos(id_plano_acao = 1234)
  head(dest_recursos)
#> data frame with 0 columns and 0 rows
# }
```
