# Ler dados do endpoint empenho

Esta função acessa os dados do endpoint \*\*empenho\*\* da API
FundoaFundo (TransfereGov) utilizando a função interna `pg_get`. Em vez
de incorporar o endpoint na URL, utiliza-se o parâmetro
`table = "empenho"` para especificar a tabela a ser consultada. Os
filtros são aplicados por meio do argumento `filter` e devem estar no
formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Usage

``` r
ler_empenho(
  id_empenho = NULL,
  numero_empenho = NULL,
  ano_empenho = NULL,
  gestao_emitente_empenho = NULL,
  ug_emitente_empenho = NULL,
  data_emissao_empenho = NULL,
  fonte_recurso_empenho = NULL,
  esfera_orcamentaria_empenho = NULL,
  descricao_esfera_orcamentaria_empenho = NULL,
  plano_interno_empenho = NULL,
  unidade_gestora_responsavel_empenho = NULL,
  observacao_empenho = NULL,
  cnpj_favorecido_empenho = NULL,
  numero_lista_empenho = NULL,
  unidade_gestora_referencia_empenho = NULL,
  gestao_referencia_empenho = NULL,
  numero_interno_empenho = NULL,
  objeto_empenho = NULL,
  numero_sistema_empenho = NULL,
  natureza_despesa_empenho = NULL,
  natureza_despesa_sub_item_empenho = NULL,
  tipo_empenho = NULL,
  descricao_tipo_empenho = NULL,
  codigo_tipo_nota_empenho = NULL,
  descricao_tipo_nota_empenho = NULL,
  situacao_empenho = NULL,
  descricao_situacao_empenho = NULL,
  valor_empenho = NULL,
  versao_empenho = NULL,
  id_plano_acao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_empenho:

  Identificador do empenho (numérico).

- numero_empenho:

  Número do empenho (texto ou numérico).

- ano_empenho:

  Ano do empenho (numérico).

- gestao_emitente_empenho:

  Gestão emitente do empenho (texto).

- ug_emitente_empenho:

  Unidade gestora emitente do empenho (texto).

- data_emissao_empenho:

  Data de emissão do empenho (formato YYYY-MM-DD).

- fonte_recurso_empenho:

  Fonte de recurso do empenho (texto).

- esfera_orcamentaria_empenho:

  Esfera orçamentária do empenho (texto).

- descricao_esfera_orcamentaria_empenho:

  Descrição da esfera orçamentária (texto).

- plano_interno_empenho:

  Plano interno do empenho (texto).

- unidade_gestora_responsavel_empenho:

  Unidade gestora responsável pelo empenho (texto).

- observacao_empenho:

  Observação sobre o empenho (texto).

- cnpj_favorecido_empenho:

  CNPJ do favorecido do empenho (texto).

- numero_lista_empenho:

  Número da lista do empenho (texto ou numérico).

- unidade_gestora_referencia_empenho:

  Unidade gestora de referência do empenho (texto).

- gestao_referencia_empenho:

  Gestão de referência do empenho (texto).

- numero_interno_empenho:

  Número interno do empenho (texto ou numérico).

- objeto_empenho:

  Objeto do empenho (texto).

- numero_sistema_empenho:

  Número do sistema do empenho (texto ou numérico).

- natureza_despesa_empenho:

  Natureza da despesa do empenho (texto).

- natureza_despesa_sub_item_empenho:

  Subitem da natureza de despesa do empenho (texto).

- tipo_empenho:

  Tipo do empenho (texto).

- descricao_tipo_empenho:

  Descrição do tipo de empenho (texto).

- codigo_tipo_nota_empenho:

  Código do tipo de nota do empenho (texto ou numérico).

- descricao_tipo_nota_empenho:

  Descrição do tipo de nota do empenho (texto).

- situacao_empenho:

  Situação do empenho (texto).

- descricao_situacao_empenho:

  Descrição da situação do empenho (texto).

- valor_empenho:

  Valor do empenho (numérico).

- versao_empenho:

  Versão do empenho (texto ou numérico).

- id_plano_acao:

  Identificador do plano de ação ao qual o empenho está vinculado
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
  # Exemplo: ler empenhos do ano de 2020 para um determinado plano de ação
  empenhos <- ler_empenho(ano_empenho = 2020, id_plano_acao = 1234)
  head(empenhos)
#> data frame with 0 columns and 0 rows
# }
```
