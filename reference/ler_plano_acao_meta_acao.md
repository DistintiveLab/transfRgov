# Obter dados do endpoint plano_acao_meta_acao

Esta função acessa os dados do endpoint \*\*plano_acao_meta_acao\*\* da
API FundoaFundo (TransfereGov) utilizando a função interna `pg_get`. Em
vez de incorporar o endpoint na URL, utiliza-se o parâmetro
`table = "plano_acao_meta_acao"` para especificar a tabela a ser
consultada. Os filtros são aplicados por meio do argumento `filter` e
devem estar no formato "nome_parametro=eq.valor". Todos os parâmetros
são opcionais.

## Usage

``` r
ler_plano_acao_meta_acao(
  id_acao_meta_plano_acao = NULL,
  numero_acao_meta_plano_acao = NULL,
  nome_acao_meta_plano_acao = NULL,
  descricao_acao_meta_plano_acao = NULL,
  valor_acao_meta_plano_acao = NULL,
  versao_acao_meta_plano_acao = NULL,
  sequencial_acao_meta_plano_acao = NULL,
  id_meta_plano_acao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_acao_meta_plano_acao:

  Identificador da ação da meta do plano de ação (numérico).

- numero_acao_meta_plano_acao:

  Número da ação da meta do plano de ação (texto ou numérico).

- nome_acao_meta_plano_acao:

  Nome da ação da meta do plano de ação (texto).

- descricao_acao_meta_plano_acao:

  Descrição da ação da meta do plano de ação (texto).

- valor_acao_meta_plano_acao:

  Valor da ação da meta do plano de ação (numérico).

- versao_acao_meta_plano_acao:

  Versão da ação da meta do plano de ação (texto ou numérico).

- sequencial_acao_meta_plano_acao:

  Sequencial da ação da meta do plano de ação (numérico).

- id_meta_plano_acao:

  Identificador da meta do plano de ação à qual a ação está vinculada
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
  # Exemplo: consultar ações de meta para uma meta de plano de ação específica
  acao_meta <- ler_plano_acao_meta_acao(id_meta_plano_acao = 5678)
  head(acao_meta)
#>   id_acao_meta_plano_acao numero_acao_meta_plano_acao nome_acao_meta_plano_acao
#> 1                    9075                        A1.1   Subsídio de R$ 3.000,00
#>                                                                                                                                                                                                                                                                                                                         descricao_acao_meta_plano_acao
#> 1 Concessão de subsídio mensal para a manutenção dos de cerca de 47 espaços artísticos e culturais, microempresas e pequenas empresas culturais, cooperativas, instituições e organizações culturais comunitárias, existentes no Município, com o valor único de R$ 3.000,00, para cada, pelo período de três meses, somando o total de R$ 423.000,00.
#>   valor_acao_meta_plano_acao versao_acao_meta_plano_acao
#> 1                     423000                           1
#>   sequencial_acao_meta_plano_acao id_meta_plano_acao
#> 1                               1               5678
# }
```
