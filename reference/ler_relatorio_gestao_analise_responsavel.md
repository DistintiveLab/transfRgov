# Ler dados de Responsáveis pela Análise do Relatório de Gestão da API TransfereGov

Esta função acessa os dados do endpoint
\*\*relatorio_gestao_analise_responsavel\*\* da API FundoaFundo
(TransfereGov) utilizando a função interna `pg_get`. Os filtros são
aplicados por meio do argumento `filter` e devem estar no formato
"nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Usage

``` r
ler_relatorio_gestao_analise_responsavel(
  relatorio_gestao_analise_fk = NULL,
  nome_responsavel_analise_relatorio_gestao_analise = NULL,
  cargo_responsavel_analise_relatorio_gestao_analise = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- relatorio_gestao_analise_fk:

  Identificador da análise do relatório de gestão à qual o responsável
  está vinculado (numérico).

- nome_responsavel_analise_relatorio_gestao_analise:

  Nome do responsável pela análise do relatório de gestão (texto).

- cargo_responsavel_analise_relatorio_gestao_analise:

  Cargo do responsável pela análise do relatório de gestão (texto).

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
if (FALSE) { # \dontrun{
  # Exemplo: ler responsáveis vinculados a uma análise
  responsaveis <- ler_relatorio_gestao_analise_responsavel(relatorio_gestao_analise_fk = 12345)
  head(responsaveis)
} # }
```
