# Ler dados de Ações do Relatório de Gestão da API TransfereGov

Esta função acessa os dados do endpoint \*\*relatorio_gestao_acoes\*\*
da API FundoaFundo (TransfereGov) utilizando a função interna `pg_get`.
Os filtros são aplicados por meio do argumento `filter` e devem estar no
formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Usage

``` r
ler_relatorio_gestao_acoes(
  id_acao_relatorio_gestao = NULL,
  percentual_execucao_fisica_acao_relatorio_gestao_acao = NULL,
  observacoes_justificativas_relatorio_gestao_acao = NULL,
  id_relatorio_gestao = NULL,
  id_acao_meta_plano_acao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_acao_relatorio_gestao:

  Identificador único da ação do relatório de gestão (numérico).

- percentual_execucao_fisica_acao_relatorio_gestao_acao:

  Percentual de execução física da ação (numérico).

- observacoes_justificativas_relatorio_gestao_acao:

  Observações e justificativas da ação (texto).

- id_relatorio_gestao:

  Identificador do relatório de gestão associado (numérico).

- id_acao_meta_plano_acao:

  Identificador da ação/meta do plano de ação associado (numérico).

- select:

  Vetor de caracteres com os nomes das colunas a serem retornadas.
  Quando `NULL` (padrão), todas as colunas do endpoint são retornadas.

- order:

  Vetor de caracteres com os critérios de ordenação, no formato
  `"coluna.asc"` ou `"coluna.desc"`. Quando `NULL` (padrão), a ordem
  definida pela API é mantida.

## Value

Um objeto contendo os dados retornados pela API (geralmente um
data.frame).

## Examples

``` r
# \donttest{
  # Exemplo: ler ações vinculadas a um relatório de gestão
  acoes <- ler_relatorio_gestao_acoes(id_relatorio_gestao = 12345)
  head(acoes)
#>   id_acao_relatorio_gestao
#> 1                    27594
#> 2                    27595
#> 3                    27596
#> 4                    27597
#>   percentual_execucao_fisica_acao_relatorio_gestao_acao
#> 1                                                  0,00
#> 2                                                  0,00
#> 3                                                  0,00
#> 4                                                  0,00
#>   observacoes_justificativas_relatorio_gestao_acao id_relatorio_gestao
#> 1                                               NA               12345
#> 2                                               NA               12345
#> 3                                               NA               12345
#> 4                                               NA               12345
#>   id_acao_meta_plano_acao
#> 1                   72177
#> 2                   72176
#> 3                   72174
#> 4                   72175
# }
```
