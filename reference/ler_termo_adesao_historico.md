# Obter dados do endpoint termo_adesao_historico

Esta função acessa os dados do endpoint \*\*termo_adesao_historico\*\*
da API FundoaFundo (TransfereGov) utilizando a função interna `pg_get`.
Em vez de incorporar o endpoint na URL, utiliza-se o parâmetro
`table = "termo_adesao_historico"` para especificar a tabela a ser
consultada. Os filtros são aplicados por meio do argumento `filter` e
devem estar no formato "nome_parametro=eq.valor". Todos os parâmetros
são opcionais.

## Usage

``` r
ler_termo_adesao_historico(
  id_historico_termo_adesao = NULL,
  situacao_historico_termo_adesao = NULL,
  data_historico_termo_adesao = NULL,
  id_termo_adesao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_historico_termo_adesao:

  Identificador do histórico do termo de adesão (numérico).

- situacao_historico_termo_adesao:

  Situação do histórico do termo de adesão (texto).

- data_historico_termo_adesao:

  Data do histórico do termo de adesão (formato YYYY-MM-DD).

- id_termo_adesao:

  Identificador do termo de adesão ao qual o histórico está vinculado
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
# \donttest{
  # Exemplo: consultar o histórico de um termo de adesão específico
  historico <- ler_termo_adesao_historico(id_termo_adesao = 1234)
  head(historico)
#>   id_historico_termo_adesao situacao_historico_termo_adesao
#> 1                      2993                   EM ELABORACAO
#> 2                      2994                         ENVIADO
#> 3                      5807                        ASSINADO
#>   data_historico_termo_adesao id_termo_adesao
#> 1                  2020-09-14            1234
#> 2                  2020-09-14            1234
#> 3                  2020-09-23            1234
# }
```
