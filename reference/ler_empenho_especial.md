# Ler dados de Empenho Especial da API TransfereGov

Esta função acessa os dados do endpoint \*\*empenho_especial\*\* da API
FundoaFundo (TransfereGov) utilizando a função interna `pg_get`. Os
filtros são aplicados por meio do argumento `filter` e devem estar no
formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Usage

``` r
ler_empenho_especial(
  id_empenho_especial = NULL,
  numero_empenho = NULL,
  ano_empenho = NULL,
  id_programa = NULL,
  cnpj_favorecido_empenho = NULL,
  valor_empenho = NULL,
  data_emissao_empenho = NULL,
  tipo_empenho = NULL,
  situacao_empenho = NULL,
  ug_emitente_empenho = NULL,
  objeto_empenho = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_empenho_especial:

  Identificador único do empenho especial (numérico).

- numero_empenho:

  Número do empenho (texto ou numérico).

- ano_empenho:

  Ano do empenho (numérico).

- id_programa:

  Identificador do programa especial ao qual o empenho está vinculado
  (numérico).

- cnpj_favorecido_empenho:

  CNPJ do favorecido do empenho (texto).

- valor_empenho:

  Valor do empenho (numérico).

- data_emissao_empenho:

  Data de emissão do empenho (formato YYYY-MM-DD).

- tipo_empenho:

  Tipo do empenho especial (texto).

- situacao_empenho:

  Situação do empenho (e.g., "Liquidado", "Pago") (texto).

- ug_emitente_empenho:

  Unidade gestora emitente do empenho (texto).

- objeto_empenho:

  Objeto do empenho (texto).

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
  # Exemplo: ler empenhos especiais do ano de 2023
  empenhos_especiais_2023 <- ler_empenho_especial(ano_empenho = 2023)
  head(empenhos_especiais_2023)

  # Exemplo: ler empenhos especiais vinculados a um programa específico
  empenhos_de_programa <- ler_empenho_especial(id_programa = 12345, ano_empenho = 2022)
  head(empenhos_de_programa)
} # }
```
