# Obter dados do endpoint gestao_financeira_categorias_despesa

Esta função acessa os dados do endpoint
\*\*gestao_financeira_categorias_despesa\*\* da API FundoaFundo
(TransfereGov) utilizando a função interna `pg_get`. Em vez de
incorporar o endpoint na URL, utiliza-se o parâmetro
`table = "gestao_financeira_categorias_despesa"` para especificar a
tabela a ser consultada. Os filtros são aplicados por meio do argumento
`filter` e devem estar no formato "nome_parametro=eq.valor". Todos os
parâmetros são opcionais.

## Usage

``` r
ler_gestao_financeira_categorias_despesa(
  id_categoria_despesa_gestao_financeira = NULL,
  id_nivel_pai_categoria_despesa_gestao_financeira = NULL,
  nome_nivel_atual_categoria_despesa_gestao_financeira = NULL,
  nivel_atual_categoria_despesa_gestao_financeira = NULL,
  nome_completo_niveis_categoria_despesa_gestao_financeira = NULL,
  codigo_programa_agil = NULL,
  nome_programa_agil = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_categoria_despesa_gestao_financeira:

  Identificador da categoria de despesa (numérico).

- id_nivel_pai_categoria_despesa_gestao_financeira:

  Identificador do nível pai da categoria de despesa (numérico).

- nome_nivel_atual_categoria_despesa_gestao_financeira:

  Nome do nível atual da categoria de despesa (texto).

- nivel_atual_categoria_despesa_gestao_financeira:

  Nível atual da categoria de despesa (texto ou numérico).

- nome_completo_niveis_categoria_despesa_gestao_financeira:

  Nome completo dos níveis da categoria de despesa (texto).

- codigo_programa_agil:

  Código do programa ágil associado (texto ou numérico).

- nome_programa_agil:

  Nome do programa ágil associado (texto).

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
  # Exemplo: consultar categorias de despesa para um programa ágil específico
  categorias <- ler_gestao_financeira_categorias_despesa(
    codigo_programa_agil = "001",
    nome_programa_agil = "Programa Exemplo"
  )
  head(categorias)
} # }
```
