# Ler dados de Relatório de Gestão da API TransfereGov

Esta função acessa os dados do endpoint \*\*relatorio_gestao\*\* da API
FundoaFundo (TransfereGov) utilizando a função interna `pg_get`. Os
filtros são aplicados por meio do argumento `filter` e devem estar no
formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Usage

``` r
ler_relatorio_gestao(
  id_relatorio_gestao = NULL,
  data_relatorio_gestao = NULL,
  data_e_hora_relatorio_gestao = NULL,
  tipo_relatorio_gestao = NULL,
  situacao_relatorio_gestao = NULL,
  valor_executado_relatorio_gestao = NULL,
  valor_pendente_relatorio_gestao = NULL,
  resultados_alcancados_metas_relatorio_gestao = NULL,
  descritivo_relatorio_gestao = NULL,
  contrapartida_relatorio_gestao = NULL,
  endereco_eletronico_publicidade_acoes_relatorio_gestao = NULL,
  declaracao_conformidade_relatorio_gestao = NULL,
  id_plano_acao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_relatorio_gestao:

  Identificador único do relatório de gestão (numérico).

- data_relatorio_gestao:

  Data do relatório de gestão (formato YYYY-MM-DD).

- data_e_hora_relatorio_gestao:

  Data e hora do relatório de gestão (texto).

- tipo_relatorio_gestao:

  Tipo do relatório de gestão (texto).

- situacao_relatorio_gestao:

  Situação do relatório de gestão (texto).

- valor_executado_relatorio_gestao:

  Valor executado informado no relatório de gestão (numérico).

- valor_pendente_relatorio_gestao:

  Valor pendente informado no relatório de gestão (numérico).

- resultados_alcancados_metas_relatorio_gestao:

  Resultados alcançados em relação às metas (texto).

- descritivo_relatorio_gestao:

  Texto descritivo do relatório de gestão (texto).

- contrapartida_relatorio_gestao:

  Contrapartida informada no relatório de gestão (texto).

- endereco_eletronico_publicidade_acoes_relatorio_gestao:

  Endereço eletrônico de publicidade das ações (texto).

- declaracao_conformidade_relatorio_gestao:

  Declaração de conformidade do relatório de gestão (texto).

- id_plano_acao:

  Identificador do plano de ação associado (numérico).

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
  # Exemplo: ler relatórios de gestão vinculados a um plano de ação
  relatorios <- ler_relatorio_gestao(id_plano_acao = 12345)
  head(relatorios)
} # }
```
