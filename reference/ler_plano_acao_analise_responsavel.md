# Obter dados do endpoint plano_acao_analise_responsavel

Esta função acessa os dados do endpoint
\*\*plano_acao_analise_responsavel\*\* da API FundoaFundo (TransfereGov)
utilizando a função interna `pg_get`. Em vez de incorporar o endpoint na
URL, utiliza-se o parâmetro `table = "plano_acao_analise_responsavel"`
para especificar a tabela a ser consultada. Os filtros são aplicados por
meio do argumento `filter` e devem estar no formato
"nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Usage

``` r
ler_plano_acao_analise_responsavel(
  plano_acao_analise_fk = NULL,
  nome_responsavel_analise_plano_acao = NULL,
  cargo_responsavel_analise_plano_acao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- plano_acao_analise_fk:

  Chave estrangeira que referencia a análise do plano de ação
  (numérico).

- nome_responsavel_analise_plano_acao:

  Nome do responsável pela análise do plano de ação (texto).

- cargo_responsavel_analise_plano_acao:

  Cargo do responsável pela análise do plano de ação (texto).

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
  # Exemplo: consultar os responsáveis pela análise de um plano de ação específico
  resp <- ler_plano_acao_analise_responsavel(plano_acao_analise_fk = 1234)
  head(resp)
} # }
```
