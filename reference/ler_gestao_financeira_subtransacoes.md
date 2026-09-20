# Obter dados do endpoint gestao_financeira_subtransacoes

Esta função acessa os dados do endpoint
\*\*gestao_financeira_subtransacoes\*\* da API FundoaFundo
(TransfereGov) utilizando a função interna `pg_get`. Em vez de inserir o
endpoint na URL, utiliza-se o parâmetro
`table = "gestao_financeira_subtransacoes"` para especificar a tabela a
ser consultada. Os filtros são aplicados por meio do argumento `filter`
e devem estar no formato "nome_parametro=eq.valor". Todos os parâmetros
são opcionais.

## Usage

``` r
ler_gestao_financeira_subtransacoes(
  id_subtransacao_gestao_financeira = NULL,
  estado_subtransacao_gestao_financeira = NULL,
  situacao_pagamento_subtransacao_gestao_financeira = NULL,
  descricao_situacao_pagamento_subtransacao_gestao_financeira = NULL,
  data_pagamento_subtransacao_gestao_financeira = NULL,
  tipo_pessoa_beneficiario_subtransacao_gestao_financeira = NULL,
  descricao_tipo_pessoa_beneficiario_subtransacao_gestao_financei = NULL,
  numero_documento_beneficiario_subtransacao_gestao_financeira_ma = NULL,
  nome_beneficiario_subtransacao_gestao_financeira = NULL,
  codigo_banco_beneficiario_subtransacao_gestao_financeira = NULL,
  codigo_agencia_beneficiario_subtransacao_gestao_financeira = NULL,
  codigo_conta_beneficiario_subtransacao_gestao_financeira = NULL,
  descricao_subtransacao_gestao_financeira = NULL,
  valor_subtransacao_gestao_financeira = NULL,
  id_categoria_despesa_gestao_financeira = NULL,
  id_lancamento_gestao_financeira = NULL,
  data_evento_lancamento_gestao_financeira = NULL,
  numero_ordem_gestao_financeira = NULL,
  numero_referencia_unica_gestao_financeira = NULL,
  tipo_favorecido_gestao_financeira = NULL,
  descricao_tipo_favorecido_gestao_financeira = NULL,
  doc_favorecido_gestao_financeira_mask = NULL,
  nome_favorecido_gestao_financeira = NULL,
  codigo_banco_favorecido_gestao_financeira = NULL,
  codigo_agencia_favorecido_gestao_financeira = NULL,
  dv_agencia_favorecido_gestao_financeira = NULL,
  codigo_conta_favorecido_gestao_financeira = NULL,
  dv_conta_favorecido_gestao_financeira = NULL,
  valor_lancamento_gestao_financeira = NULL,
  quantidade_subtransacoes_lancamento_gestao_financeira = NULL,
  id_agencia_conta = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_subtransacao_gestao_financeira:

  Identificador da subtransação (numérico).

- estado_subtransacao_gestao_financeira:

  Estado da subtransação (texto).

- situacao_pagamento_subtransacao_gestao_financeira:

  Situação do pagamento (texto).

- descricao_situacao_pagamento_subtransacao_gestao_financeira:

  Descrição da situação de pagamento (texto).

- data_pagamento_subtransacao_gestao_financeira:

  Data de pagamento (formato YYYY-MM-DD).

- tipo_pessoa_beneficiario_subtransacao_gestao_financeira:

  Tipo de pessoa beneficiária (texto).

- descricao_tipo_pessoa_beneficiario_subtransacao_gestao_financei:

  Descrição do tipo de pessoa beneficiária (texto).

- numero_documento_beneficiario_subtransacao_gestao_financeira_ma:

  Número do documento do beneficiário (texto).

- nome_beneficiario_subtransacao_gestao_financeira:

  Nome do beneficiário (texto).

- codigo_banco_beneficiario_subtransacao_gestao_financeira:

  Código do banco do beneficiário (texto ou numérico).

- codigo_agencia_beneficiario_subtransacao_gestao_financeira:

  Código da agência do beneficiário (texto ou numérico).

- codigo_conta_beneficiario_subtransacao_gestao_financeira:

  Código da conta do beneficiário (texto ou numérico).

- descricao_subtransacao_gestao_financeira:

  Descrição da subtransação (texto).

- valor_subtransacao_gestao_financeira:

  Valor da subtransação (numérico).

- id_categoria_despesa_gestao_financeira:

  Identificador da categoria de despesa (numérico).

- id_lancamento_gestao_financeira:

  Identificador do lançamento de gestão financeira (numérico).

- data_evento_lancamento_gestao_financeira:

  Data do evento do lançamento (formato YYYY-MM-DD).

- numero_ordem_gestao_financeira:

  Número da ordem (numérico).

- numero_referencia_unica_gestao_financeira:

  Número de referência única (texto ou numérico).

- tipo_favorecido_gestao_financeira:

  Tipo de favorecido (texto).

- descricao_tipo_favorecido_gestao_financeira:

  Descrição do tipo de favorecido (texto).

- doc_favorecido_gestao_financeira_mask:

  Documento do favorecido (texto mascarado).

- nome_favorecido_gestao_financeira:

  Nome do favorecido (texto).

- codigo_banco_favorecido_gestao_financeira:

  Código do banco do favorecido (texto ou numérico).

- codigo_agencia_favorecido_gestao_financeira:

  Código da agência do favorecido (texto ou numérico).

- dv_agencia_favorecido_gestao_financeira:

  Dígito verificador da agência do favorecido (texto).

- codigo_conta_favorecido_gestao_financeira:

  Código da conta do favorecido (texto ou numérico).

- dv_conta_favorecido_gestao_financeira:

  Dígito verificador da conta do favorecido (texto).

- valor_lancamento_gestao_financeira:

  Valor do lançamento (numérico).

- quantidade_subtransacoes_lancamento_gestao_financeira:

  Quantidade de subtransações (numérico).

- id_agencia_conta:

  Identificador da agência/conta (numérico).

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
if (FALSE) { # \dontrun{
  # Exemplo: consultar subtransações para um lançamento de gestão financeira específico
  subtransacoes <- ler_gestao_financeira_subtransacoes(id_lancamento_gestao_financeira = 1234)
  head(subtransacoes)
} # }
```
