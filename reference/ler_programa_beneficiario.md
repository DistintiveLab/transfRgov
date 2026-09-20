# Obter dados do endpoint programa_beneficiario

Esta função acessa os dados referentes ao endpoint de beneficiários de
programas na API FundoaFundo (TransfereGov), utilizando a função interna
`pg_get`. Em vez de inserir o endpoint na URL, utiliza-se o parâmetro
`table = 'programa_beneficiario'` para especificar a tabela a ser
consultada.

## Usage

``` r
ler_programa_beneficiario(
  id_beneficiario_programa = NULL,
  cnpj_beneficiario_programa = NULL,
  nome_beneficiario_programa = NULL,
  valor_beneficiario_programa = NULL,
  numero_emenda_beneficiario_programa = NULL,
  nome_parlamentar_beneficiario_programa = NULL,
  tipo_beneficiario_programa = NULL,
  uf_beneficiario_programa = NULL,
  id_programa = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_beneficiario_programa:

  Identificador do beneficiário do programa (numérico).

- cnpj_beneficiario_programa:

  CNPJ do beneficiário do programa (texto).

- nome_beneficiario_programa:

  Nome do beneficiário do programa (texto).

- valor_beneficiario_programa:

  Valor atribuído ao beneficiário do programa (numérico).

- numero_emenda_beneficiario_programa:

  Número da emenda do beneficiário do programa (texto ou numérico).

- nome_parlamentar_beneficiario_programa:

  Nome do parlamentar associado ao beneficiário (texto).

- tipo_beneficiario_programa:

  Tipo de beneficiário do programa (texto).

- uf_beneficiario_programa:

  Unidade Federativa do beneficiário do programa (texto).

- id_programa:

  Identificador do programa ao qual o beneficiário está vinculado
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

Os filtros são aplicados por meio do parâmetro `filter` da função
`pg_get`. Para cada parâmetro informado, é criada uma condição no
formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Examples

``` r
# \donttest{
  # Exemplo: consultar beneficiários do programa com id 1234 e UF "SP"
  beneficiarios <- ler_programa_beneficiario(id_programa = 1234, uf_beneficiario_programa = "SP")
  head(beneficiarios)
#> data frame with 0 columns and 0 rows
# }
```
