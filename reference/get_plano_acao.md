# Obter dados do endpoint plano_acao

Esta função acessa os dados do endpoint \*\*plano_acao\*\* da API
FundoaFundo (TransfereGov) utilizando a função interna `pg_get`. Em vez
de inserir o endpoint na URL, utiliza-se o parâmetro
`table = "plano_acao"` para especificar a tabela a ser consultada. Os
filtros são aplicados por meio do argumento `filter` e devem estar no
formato "nome_parametro=eq.valor". Todos os parâmetros são opcionais.

## Usage

``` r
get_plano_acao(
  id_plano_acao = NULL,
  codigo_plano_acao = NULL,
  data_inicio_vigencia_plano_acao = NULL,
  data_fim_vigencia_plano_acao = NULL,
  diagnostico_plano_acao = NULL,
  objetivos_plano_acao = NULL,
  situacao_plano_acao = NULL,
  valor_repasse_emenda_plano_acao = NULL,
  valor_repasse_especifico_plano_acao = NULL,
  valor_repasse_voluntario_plano_acao = NULL,
  valor_total_repasse_plano_acao = NULL,
  valor_recursos_proprios_plano_acao = NULL,
  valor_outros_plano_acao = NULL,
  valor_rendimentos_aplicacao_plano_acao = NULL,
  valor_total_plano_acao = NULL,
  valor_total_investimento_plano_acao = NULL,
  valor_total_custeio_plano_acao = NULL,
  valor_saldo_disponivel_plano_acao = NULL,
  id_orgao_repassador_plano_acao = NULL,
  sigla_orgao_repassador_plano_acao = NULL,
  cnpj_orgao_repassador_plano_acao = NULL,
  nome_orgao_repassador_plano_acao = NULL,
  id_ente_repassador_plano_acao = NULL,
  cnpj_ente_repassador_plano_acao = NULL,
  nome_ente_repassador_plano_acao = NULL,
  uf_ente_repassador_plano_acao = NULL,
  nome_municipio_ente_repassador_plano_acao = NULL,
  codigo_ibge_municipio_ente_repassador_plano_acao = NULL,
  id_ente_recebedor_plano_acao = NULL,
  cnpj_ente_recebedor_plano_acao = NULL,
  nome_ente_recebedor_plano_acao = NULL,
  uf_ente_recebedor_plano_acao = NULL,
  nome_municipio_ente_recebedor_plano_acao = NULL,
  codigo_ibge_municipio_ente_recebedor_plano_acao = NULL,
  id_fundo_repassador_plano_acao = NULL,
  cnpj_fundo_repassador_plano_acao = NULL,
  nome_fundo_repassador_plano_acao = NULL,
  uf_fundo_repassador_plano_acao = NULL,
  municipio_fundo_repassador_plano_acao = NULL,
  codigo_ibge_fundo_repassador_plano_acao = NULL,
  id_fundo_recebedor_plano_acao = NULL,
  cnpj_fundo_recebedor_plano_acao = NULL,
  nome_fundo_recebedor_plano_acao = NULL,
  uf_fundo_recebedor_plano_acao = NULL,
  municipio_fundo_recebedor_plano_acao = NULL,
  codigo_ibge_fundo_recebedor_plano_acao = NULL,
  id_programa = NULL,
  select = NULL,
  order = NULL
)
```

## Arguments

- id_plano_acao:

  Identificador do plano de ação (numérico).

- codigo_plano_acao:

  Código do plano de ação (texto).

- data_inicio_vigencia_plano_acao:

  Data de início de vigência do plano de ação (formato YYYY-MM-DD).

- data_fim_vigencia_plano_acao:

  Data de fim de vigência do plano de ação (formato YYYY-MM-DD).

- diagnostico_plano_acao:

  Diagnóstico do plano de ação (texto).

- objetivos_plano_acao:

  Objetivos do plano de ação (texto).

- situacao_plano_acao:

  Situação do plano de ação (texto).

- valor_repasse_emenda_plano_acao:

  Valor de repasse por emenda (numérico).

- valor_repasse_especifico_plano_acao:

  Valor de repasse específico (numérico).

- valor_repasse_voluntario_plano_acao:

  Valor de repasse voluntário (numérico).

- valor_total_repasse_plano_acao:

  Valor total de repasse (numérico).

- valor_recursos_proprios_plano_acao:

  Valor de recursos próprios (numérico).

- valor_outros_plano_acao:

  Valor de outros repasses (numérico).

- valor_rendimentos_aplicacao_plano_acao:

  Valor de rendimentos de aplicação (numérico).

- valor_total_plano_acao:

  Valor total do plano de ação (numérico).

- valor_total_investimento_plano_acao:

  Valor total de investimento (numérico).

- valor_total_custeio_plano_acao:

  Valor total de custeio (numérico).

- valor_saldo_disponivel_plano_acao:

  Valor do saldo disponível (numérico).

- id_orgao_repassador_plano_acao:

  Identificador do órgão repassador (numérico).

- sigla_orgao_repassador_plano_acao:

  Sigla do órgão repassador (texto).

- cnpj_orgao_repassador_plano_acao:

  CNPJ do órgão repassador (texto).

- nome_orgao_repassador_plano_acao:

  Nome do órgão repassador (texto).

- id_ente_repassador_plano_acao:

  Identificador do ente repassador (numérico).

- cnpj_ente_repassador_plano_acao:

  CNPJ do ente repassador (texto).

- nome_ente_repassador_plano_acao:

  Nome do ente repassador (texto).

- uf_ente_repassador_plano_acao:

  UF do ente repassador (texto).

- nome_municipio_ente_repassador_plano_acao:

  Nome do município do ente repassador (texto).

- codigo_ibge_municipio_ente_repassador_plano_acao:

  Código IBGE do município do ente repassador (texto ou numérico).

- id_ente_recebedor_plano_acao:

  Identificador do ente recebedor (numérico).

- cnpj_ente_recebedor_plano_acao:

  CNPJ do ente recebedor (texto).

- nome_ente_recebedor_plano_acao:

  Nome do ente recebedor (texto).

- uf_ente_recebedor_plano_acao:

  UF do ente recebedor (texto).

- nome_municipio_ente_recebedor_plano_acao:

  Nome do município do ente recebedor (texto).

- codigo_ibge_municipio_ente_recebedor_plano_acao:

  Código IBGE do município do ente recebedor (texto ou numérico).

- id_fundo_repassador_plano_acao:

  Identificador do fundo repassador (numérico).

- cnpj_fundo_repassador_plano_acao:

  CNPJ do fundo repassador (texto).

- nome_fundo_repassador_plano_acao:

  Nome do fundo repassador (texto).

- uf_fundo_repassador_plano_acao:

  UF do fundo repassador (texto).

- municipio_fundo_repassador_plano_acao:

  Município do fundo repassador (texto).

- codigo_ibge_fundo_repassador_plano_acao:

  Código IBGE do fundo repassador (texto ou numérico).

- id_fundo_recebedor_plano_acao:

  Identificador do fundo recebedor (numérico).

- cnpj_fundo_recebedor_plano_acao:

  CNPJ do fundo recebedor (texto).

- nome_fundo_recebedor_plano_acao:

  Nome do fundo recebedor (texto).

- uf_fundo_recebedor_plano_acao:

  UF do fundo recebedor (texto).

- municipio_fundo_recebedor_plano_acao:

  Município do fundo recebedor (texto).

- codigo_ibge_fundo_recebedor_plano_acao:

  Código IBGE do fundo recebedor (texto ou numérico).

- id_programa:

  Identificador do programa ao qual o plano de ação está vinculado
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
  # Exemplo: consultar planos de ação para um programa específico
  plano <- get_plano_acao(id_programa = 1234)
  head(plano)
#> data frame with 0 columns and 0 rows
# }
```
