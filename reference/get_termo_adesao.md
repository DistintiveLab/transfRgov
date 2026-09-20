# Obter dados do endpoint termo_adesao

Esta função acessa os dados do endpoint \*\*termo_adesao\*\* da API
FundoaFundo (TransfereGov) utilizando a função interna `pg_get`. Em vez
de incorporar o endpoint na URL, utiliza-se o parâmetro
`table = "termo_adesao"` para especificar a tabela a ser consultada. Os
filtros são aplicados por meio do argumento `filter` e devem estar no
formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Usage

``` r
get_termo_adesao(
  id_termo_adesao = NULL,
  numero_processo_termo_adesao = NULL,
  situacao_termo_adesao = NULL,
  objeto_termo_adesao = NULL,
  data_assinatura_termo_adesao = NULL,
  ano_termo_adesao = NULL,
  secao_publicacao_dou_termo_adesao = NULL,
  pagina_publicacao_dou_termo_adesao = NULL,
  data_publicacao_dou_termo_adesao = NULL,
  id_plano_acao = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_termo_adesao:

  Identificador do termo de adesão (numérico).

- numero_processo_termo_adesao:

  Número do processo do termo de adesão (texto).

- situacao_termo_adesao:

  Situação do termo de adesão (texto).

- objeto_termo_adesao:

  Objeto do termo de adesão (texto).

- data_assinatura_termo_adesao:

  Data de assinatura do termo de adesão (formato YYYY-MM-DD).

- ano_termo_adesao:

  Ano do termo de adesão (numérico).

- secao_publicacao_dou_termo_adesao:

  Seção da publicação no DOU do termo de adesão (texto).

- pagina_publicacao_dou_termo_adesao:

  Página da publicação no DOU do termo de adesão (texto ou numérico).

- data_publicacao_dou_termo_adesao:

  Data da publicação no DOU do termo de adesão (formato YYYY-MM-DD).

- id_plano_acao:

  Identificador do plano de ação ao qual o termo de adesão está
  vinculado (numérico).

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
  # Exemplo: consultar termos de adesão para um plano de ação específico
  termo <- get_termo_adesao(id_plano_acao = 1234)
  head(termo)
} # }
```
