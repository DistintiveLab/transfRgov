# Baixar Dados de Transferências da União

Baixa dados de transferências de recursos da União do Portal da
Transparência para um ano e mês específicos.

## Usage

``` r
download_transferencias_uniao(
  ano,
  mes,
  codigo_ibge = TRUE,
  municipios_mapping = NULL
)
```

## Arguments

- ano:

  O ano dos dados (inteiro, e.g., 2023).

- mes:

  O mês dos dados (inteiro, 1-12).

- codigo_ibge:

  Lógico. Se `TRUE` (o padrão), acrescenta a coluna `codigo_ibge` aos
  dados, por meio do mapeamento SIAFI-IBGE.

- municipios_mapping:

  possibilidade de passar mapeamento distinto do padrão incluído no
  pacote

## Value

Um data frame contendo os dados de transferências. Retorna NULL
(invisível) se ocorrer um erro.

## Details

Esta função monta a URL do arquivo ZIP de "Recursos transferidos" do
Portal da Transparência referente ao ano e mês informados, baixa o
arquivo, descompacta e lê o CSV resultante. O dicionário de dados pode
ser consultado em
<https://portaldatransparencia.gov.br/pagina-interna/603420-dicionario-de-dados-recursos-transferidos>.
A função lida com arquivos temporários e tenta ler o CSV considerando a
codificação e os separadores comuns no Portal. Requer os pacotes
'readr', 'janitor' e 'utils'.
