# Ler dados de Programa Especial da API TransfereGov

Esta função acessa os dados do endpoint \*\*programa_especial\*\* da API
TransfereGov utilizando a função interna `pg_get`. Os filtros são
aplicados por meio do argumento `filter` e devem estar no formato
"nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Usage

``` r
ler_programa_especial(
  id_programa = NULL,
  ano_programa = NULL,
  nome_programa = NULL,
  situacao_programa = NULL,
  id_proponente = NULL,
  data_inicio = NULL,
  data_fim = NULL,
  esfera = NULL,
  orgao_executor = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_programa:

  Identificador único do programa especial (numérico).

- ano_programa:

  Ano do programa especial (numérico).

- nome_programa:

  Nome ou descrição do programa especial (texto).

- situacao_programa:

  Situação atual do programa (e.g., "Ativo", "Concluído") (texto).

- id_proponente:

  Identificador do proponente (e.g., CNPJ, CPF) (texto).

- data_inicio:

  Data de início do programa (formato YYYY-MM-DD).

- data_fim:

  Data de fim do programa (formato YYYY-MM-DD).

- esfera:

  Nível da esfera do programa (e.g., "FEDERAL", "ESTADUAL", "MUNICIPAL")
  (texto).

- orgao_executor:

  Nome ou código do órgão executor do programa (texto).

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
  # Exemplo: ler programas especiais do ano de 2022
  programas_2022 <- ler_programa_especial(ano_programa = 2022)
  head(programas_2022)

  # Exemplo: ler programas com um ID específico
  programa_especifico <- ler_programa_especial(id_programa = 12345)
  head(programa_especifico)
} # }
```
