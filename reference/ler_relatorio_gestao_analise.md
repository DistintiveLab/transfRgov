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
# \donttest{
  # Exemplo: ler análises vinculadas a um relatório de gestão
  analises <- ler_relatorio_gestao_analise(id_relatorio_gestao = 12345)
  head(analises)
#>   id_relatorio_gestao_analise tipo_analise_relatorio_gestao_analise
#> 1                        4486                      RELATORIO_GESTAO
#>   resultado_analise_relatorio_gestao_analise
#> 1                               COM_RESSALVA
#>                                                                                                                                                                                                                                                                                                                                                                                                                 parecer_analise_relatorio_gestao_analise
#> 1 Relatório de Gestão Parcial aprovado com ressalva, considerando os requisitos da Portaria MinC nº 119, de 28 de março de 2024, e do Comunicado GTPNAB/MinC nº 1, de 1º de agosto de 2024. No entanto, solicitamos que no próximo Relatório de Gestão seja incluído o arquivo ou link disponível referente à publicação do PAAR na ÍNTEGRA para acesso à sociedade. (Publicação no Diário Oficial, site da Secretaria de Cultura ou outro meio público)
#>   origem_analise_relatorio_gestao_analise data_analise_relatorio_gestao_analise
#> 1                              REPASSADOR                            2024-10-22
#>   versao_analise_relatorio_gestao_analise id_relatorio_gestao
#> 1                                       0               12345
# }
```
