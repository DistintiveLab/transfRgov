# Ler dados de Análise do Relatório de Gestão da API TransfereGov

Esta função acessa os dados do endpoint \*\*relatorio_gestao_analise\*\*
da API FundoaFundo (TransfereGov) utilizando a função interna `pg_get`.
Os filtros são aplicados por meio do argumento `filter` e devem estar no
formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Usage

``` r
ler_relatorio_gestao_analise(
  id_relatorio_gestao_analise = NULL,
  tipo_analise_relatorio_gestao_analise = NULL,
  resultado_analise_relatorio_gestao_analise = NULL,
  parecer_analise_relatorio_gestao_analise = NULL,
  origem_analise_relatorio_gestao_analise = NULL,
  data_analise_relatorio_gestao_analise = NULL,
  versao_analise_relatorio_gestao_analise = NULL,
  id_relatorio_gestao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_relatorio_gestao_analise:

  Identificador único da análise do relatório de gestão (numérico).

- tipo_analise_relatorio_gestao_analise:

  Tipo da análise do relatório de gestão (texto).

- resultado_analise_relatorio_gestao_analise:

  Resultado da análise do relatório de gestão (texto).

- parecer_analise_relatorio_gestao_analise:

  Parecer da análise do relatório de gestão (texto).

- origem_analise_relatorio_gestao_analise:

  Origem da análise do relatório de gestão (texto).

- data_analise_relatorio_gestao_analise:

  Data da análise do relatório de gestão (formato YYYY-MM-DD).

- versao_analise_relatorio_gestao_analise:

  Versão da análise do relatório de gestão (numérico).

- id_relatorio_gestao:

  Identificador do relatório de gestão associado (numérico).

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
  # Exemplo: ler análises vinculadas a um relatório de gestão
  analises <- ler_relatorio_gestao_analise(id_relatorio_gestao = 12345)
  head(analises)
} # }
```
