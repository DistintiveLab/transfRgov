# Obter dados do endpoint plano_acao_meta

Esta função acessa os dados do endpoint \*\*plano_acao_meta\*\* da API
FundoaFundo (TransfereGov) utilizando a função interna `pg_get`. Em vez
de incorporar o endpoint na URL, utiliza-se o parâmetro
`table = "plano_acao_meta"` para especificar a tabela a ser consultada.

## Usage

``` r
ler_plano_acao_meta(
  id_meta_plano_acao = NULL,
  numero_meta_plano_acao = NULL,
  nome_meta_plano_acao = NULL,
  descricao_meta_plano_acao = NULL,
  valor_meta_plano_acao = NULL,
  versao_meta_plano_acao = NULL,
  sequencial_meta_plano_acao = NULL,
  id_plano_acao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_meta_plano_acao:

  Identificador da meta do plano de ação (numérico).

- numero_meta_plano_acao:

  Número da meta do plano de ação (texto ou numérico).

- nome_meta_plano_acao:

  Nome da meta do plano de ação (texto).

- descricao_meta_plano_acao:

  Descrição da meta do plano de ação (texto).

- valor_meta_plano_acao:

  Valor da meta do plano de ação (numérico).

- versao_meta_plano_acao:

  Versão da meta do plano de ação (texto ou numérico).

- sequencial_meta_plano_acao:

  Sequencial da meta do plano de ação (numérico).

- id_plano_acao:

  Identificador do plano de ação ao qual a meta está vinculada
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

## Details

Os filtros são aplicados por meio do argumento `filter` da função
`pg_get`. Para cada parâmetro informado, é criada uma condição no
formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Exemplo: consultar metas de plano de ação para um plano específico
  meta <- ler_plano_acao_meta(id_plano_acao = 1234)
  head(meta)
} # }
```
