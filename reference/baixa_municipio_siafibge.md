# Obter Mapeamento SIAFI-IBGE de Municípios

Baixa a tabela de mapeamento entre códigos SIAFI e IBGE de municípios do
Tesouro Transparente.

## Usage

``` r
baixa_municipio_siafibge()
```

## Value

Um data frame contendo o mapeamento de municípios. Retorna NULL
(invisível) se ocorrer um erro.

## Details

Esta função baixa o arquivo tabmun.csv, que contém o mapeamento entre
códigos SIAFI e IBGE de municípios brasileiros, do portal Tesouro
Transparente CKAN. Os dados são comumente separados por vírgulas e podem
estar em codificação UTF-8 ou Latin1. É crucial que as colunas de código
sejam lidas como texto para preservar zeros à esquerda antes de realizar
joins. Requer o pacote 'readr' e 'utils'.
