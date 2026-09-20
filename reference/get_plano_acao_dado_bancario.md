# Obter dados do endpoint plano_acao_dado_bancario

Esta função acessa os dados do endpoint \*\*plano_acao_dado_bancario\*\*
da API FundoaFundo (TransfereGov) utilizando a função interna `pg_get`.
Em vez de inserir o endpoint na URL, utiliza-se o parâmetro
`table = "plano_acao_dado_bancario"` para especificar a tabela a ser
consultada. Os filtros são aplicados por meio do argumento `filter` e
devem estar no formato "nome_parametro=eq.valor". Todos os parâmetros
são opcionais.

## Usage

``` r
get_plano_acao_dado_bancario(
  id_plano_acao_dado_bancario = NULL,
  id_agencia_conta = NULL,
  codigo_banco_plano_acao_dado_bancario = NULL,
  nome_banco_plano_acao_dado_bancario = NULL,
  numero_agencia_plano_acao_dado_bancario = NULL,
  dv_agencia_plano_acao_dado_bancario = NULL,
  numero_conta_plano_acao_dado_bancario = NULL,
  dv_conta_plano_acao_dado_bancario = NULL,
  situacao_conta_plano_acao_dado_bancario = NULL,
  data_abertura_conta_plano_acao_dado_bancario = NULL,
  nome_programa_agil_conta_plano_acao_dado_bancario = NULL,
  saldo_final_conta_plano_acao_dado_bancario = NULL,
  id_plano_acao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_plano_acao_dado_bancario:

  Identificador do dado bancário do plano de ação (numérico).

- id_agencia_conta:

  Identificador da agência/conta (numérico).

- codigo_banco_plano_acao_dado_bancario:

  Código do banco (texto).

- nome_banco_plano_acao_dado_bancario:

  Nome do banco (texto).

- numero_agencia_plano_acao_dado_bancario:

  Número da agência (texto ou numérico).

- dv_agencia_plano_acao_dado_bancario:

  Dígito verificador da agência (texto).

- numero_conta_plano_acao_dado_bancario:

  Número da conta (texto ou numérico).

- dv_conta_plano_acao_dado_bancario:

  Dígito verificador da conta (texto).

- situacao_conta_plano_acao_dado_bancario:

  Situação da conta (texto).

- data_abertura_conta_plano_acao_dado_bancario:

  Data de abertura da conta (formato YYYY-MM-DD).

- nome_programa_agil_conta_plano_acao_dado_bancario:

  Nome do programa ágil associado à conta (texto).

- saldo_final_conta_plano_acao_dado_bancario:

  Saldo final da conta (numérico).

- id_plano_acao:

  Identificador do plano de ação ao qual o dado bancário está vinculado
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
if (FALSE) { # \dontrun{
  # Exemplo: consultar dados bancários para um plano de ação específico
  dados_bancarios <- get_plano_acao_dado_bancario(id_plano_acao = 1234)
  head(dados_bancarios)
} # }
```
