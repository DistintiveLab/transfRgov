# Encadear dois arquivos de despesas do Portal da Transparência

Junta um arquivo de despesas que traz o total por registro com o arquivo
que traz o detalhamento desse mesmo registro. No caso mais usado, o
total por ordem bancária (`pagamento`) e os beneficiários daquela ordem
(`pagamento_favorecidos_finais`).

## Usage

``` r
encadeia_despesas_ptransp(
  total,
  detalhe,
  chave = "codigo_pagamento",
  somente_detalhados = FALSE
)
```

## Arguments

- total:

  Um `data.frame` com uma linha de total por registro. É o resultado de
  [`download_despesas_ptransp()`](https://distintivelab.github.io/transfRgov/reference/download_despesas_ptransp.md)
  para o tipo agregador (por exemplo `"pagamento"`).

- detalhe:

  Um `data.frame` com zero ou mais linhas de detalhe por registro. É o
  resultado de
  [`download_despesas_ptransp()`](https://distintivelab.github.io/transfRgov/reference/download_despesas_ptransp.md)
  para o tipo detalhado (por exemplo `"pagamento_favorecidos_finais"`).

- chave:

  Texto com o nome da coluna que identifica o registro nos dois data
  frames. O padrão `"codigo_pagamento"` serve ao par `pagamento` ×
  `pagamento_favorecidos_finais`; use `"id_empenho"` no par `empenho` ×
  `item_empenho`.

- somente_detalhados:

  Lógico. Com `FALSE` (o padrão) toda linha de `total` aparece no
  resultado, e as colunas de detalhe ficam `NA` onde não há
  detalhamento. Com `TRUE`, só as linhas de `total` que têm ao menos uma
  linha em `detalhe` são devolvidas.

## Value

Um `data.frame` com as colunas de `total` seguidas das colunas
exclusivas de `detalhe`, na ordem em que aparecem nas entradas. A coluna
`detalhado` (lógica), inserida logo depois da coluna `chave`, indica
quais linhas encontraram detalhamento. Colunas homônimas nos dois data
frames recebem os sufixos `.total` e `.detalhe`. A ordem das linhas de
`total` é preservada, e quando um registro tem mais de um detalhe as
linhas ficam adjacentes. Um `detalhe` com zero linhas não é erro: o
resultado sai com as colunas de detalhe em `NA` e `detalhado = FALSE`.

## Details

A junção é 1:N na coluna `chave`, como em
`merge(..., all.x = !somente_detalhados, sort = FALSE)`. Ela foi medida
em 2024-01-15: `pagamento` tinha 14.949 ordens bancárias e
`pagamento_favorecidos_finais` detalhava 162 delas, com 99 dessas 162
trazendo mais de um beneficiário. A soma dos detalhes fecha com
`valor_do_pagamento_convertido_pra_r` (maior diferença encontrada:
`3,6e-12`, tolerância `0,01`).

O detalhamento é **parcial**: no dia medido, apenas cerca de 1% das
ordens bancárias tinham linha correspondente no arquivo de
beneficiários. Por isso o padrão é devolver todas as linhas de `total`,
e não tratar um dia sem detalhamento como erro.

Os pares total/detalhe do ZIP diário e as chaves correspondentes são:
`liquidacao` com `liquidacao_empenhos_impactados`, `pagamento` com
`pagamento_empenhos_impactados` e `pagamento` com
`pagamento_favorecidos_finais` (todos por `codigo_pagamento` ou pela
coluna de mesmo nome nos dois lados) e `empenho` com `item_empenho` (por
`id_empenho`).

Os nomes das colunas de valor não coincidem entre os lados: o total por
ordem bancária usa `valor_do_pagamento_convertido_pra_r` e o
detalhamento usa `valor_do_pagamento_em_r`. A função não compara
valores; ela entrega as duas colunas lado a lado.

## See also

[`download_despesas_ptransp`](https://distintivelab.github.io/transfRgov/reference/download_despesas_ptransp.md)

## Examples

``` r
total <- data.frame(
  codigo_pagamento = c("A", "B", "C"),
  valor_do_pagamento_convertido_pra_r = c(100, 50, 25)
)
detalhe <- data.frame(
  codigo_pagamento = c("A", "A", "B"),
  codigo_favorecido = c("F1", "F2", "F3"),
  valor_do_pagamento_em_r = c(60, 40, 50)
)
encadeia_despesas_ptransp(total, detalhe)
#>   codigo_pagamento detalhado valor_do_pagamento_convertido_pra_r
#> 1                A      TRUE                                 100
#> 2                A      TRUE                                 100
#> 3                B      TRUE                                  50
#> 4                C     FALSE                                  25
#>   codigo_favorecido valor_do_pagamento_em_r
#> 1                F1                      60
#> 2                F2                      40
#> 3                F3                      50
#> 4              <NA>                      NA
encadeia_despesas_ptransp(total, detalhe, somente_detalhados = TRUE)
#>   codigo_pagamento detalhado valor_do_pagamento_convertido_pra_r
#> 1                A      TRUE                                 100
#> 2                A      TRUE                                 100
#> 3                B      TRUE                                  50
#>   codigo_favorecido valor_do_pagamento_em_r
#> 1                F1                      60
#> 2                F2                      40
#> 3                F3                      50
```
