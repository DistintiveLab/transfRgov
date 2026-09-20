# Baixar Dados de Despesas do Portal da Transparência

Baixa os dados diários de despesas da União publicados pelo Portal da
Transparência (CGU) para uma data específica.

## Usage

``` r
download_despesas_ptransp(
  data,
  tipo = c("empenho", "item_empenho", "item_empenho_historico", "liquidacao",
    "liquidacao_empenhos_impactados", "pagamento", "pagamento_empenhos_impactados",
    "pagamento_favorecidos_finais", "pagamento_lista_bancos", "pagamento_lista_faturas",
    "pagamento_lista_precatorios")
)
```

## Arguments

- data:

  Um objeto `Date` (ou valor conversível a `Date`, como a string
  `"2024-01-15"`) com a data desejada. Uma única data por chamada.

- tipo:

  Qual dos arquivos contidos no ZIP diário deve ser lido. O padrão é
  `"empenho"`; use `tipo` para escolher outro arquivo. Ver *Detalhes*
  para a lista completa e para o encadeamento entre arquivos.

## Value

Um data frame com o conteúdo do arquivo escolhido e nomes de coluna
normalizados por
[`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html).
Dias sem movimento não são erro: o data frame volta com zero linhas.
Retorna `NULL` (invisível) e emite
[`warning()`](https://rdrr.io/r/base/warning.html) se o download, a
descompactação ou a leitura falhar.

## Details

A função monta a URL do arquivo `{AAAAMMDD}_Despesas.zip`, baixa o
arquivo, descompacta e lê o CSV correspondente ao `tipo` informado. O
ZIP diário reúne onze arquivos, um por tipo de registro: `empenho`,
`item_empenho`, `item_empenho_historico`, `liquidacao`,
`liquidacao_empenhos_impactados`, `pagamento`,
`pagamento_empenhos_impactados`, `pagamento_favorecidos_finais`,
`pagamento_lista_bancos`, `pagamento_lista_faturas` e
`pagamento_lista_precatorios`. O dicionário de dados e os arquivos podem
ser consultados em
<https://dadosabertos-download.cgu.gov.br/PortalDaTransparencia/saida/despesas/>.

Chegar ao beneficiário final de um pagamento exige encadear dois
arquivos: `pagamento` traz o total por ordem bancária (colunas
`codigo_pagamento` e `valor_do_pagamento_convertido_pra_r`) e
`pagamento_favorecidos_finais` traz os beneficiários daquela ordem
(colunas `codigo_pagamento`, `codigo_favorecido` e
`valor_do_pagamento_em_r`). A junção é 1:N por `codigo_pagamento` e
cobre apenas as ordens detalhadas. O mesmo encadeamento vale para
`liquidacao` com `liquidacao_empenhos_impactados`, `pagamento` com
`pagamento_empenhos_impactados` e `empenho` com `item_empenho` (por
`id_empenho`).

A função lida com arquivos temporários e tenta ler o CSV considerando a
codificação e os separadores comuns no Portal. Requer os pacotes
'readr', 'janitor' e 'utils'.
