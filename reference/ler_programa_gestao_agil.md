# Obter dados do endpoint programa_gestao_agil

Esta função acessa os dados do endpoint \*\*programa_gestao_agil\*\* da
API FundoaFundo (TransfereGov) utilizando a função interna `pg_get`. Em
vez de incorporar o endpoint na URL, utiliza-se o parâmetro
`table = "programa_gestao_agil"` para especificar a tabela a ser
consultada.

## Usage

``` r
ler_programa_gestao_agil(
  id_programa_agil = NULL,
  id_programa_agil_bb = NULL,
  nome_programa_agil = NULL,
  codigo_programa_agil = NULL,
  codigo_siorg_orgao_programa_agil = NULL,
  sigla_orgao_programa_agil = NULL,
  cnpj_orgao_programa_agil = NULL,
  nome_orgao_programa_agil = NULL,
  id_programa = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_programa_agil:

  Identificador do programa ágil (numérico).

- id_programa_agil_bb:

  Identificador do programa ágil BB (numérico).

- nome_programa_agil:

  Nome do programa ágil (texto).

- codigo_programa_agil:

  Código do programa ágil (texto).

- codigo_siorg_orgao_programa_agil:

  Código SIORG do órgão do programa ágil (texto).

- sigla_orgao_programa_agil:

  Sigla do órgão do programa ágil (texto).

- cnpj_orgao_programa_agil:

  CNPJ do órgão do programa ágil (texto).

- nome_orgao_programa_agil:

  Nome do órgão do programa ágil (texto).

- id_programa:

  Identificador do programa ao qual o registro está vinculado
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
  # Exemplo: consultar registros do programa_gestao_agil para um programa específico
  agil <- ler_programa_gestao_agil(id_programa = 1234)
  head(agil)
} # }
```
