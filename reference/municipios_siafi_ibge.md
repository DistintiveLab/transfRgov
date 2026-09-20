# IBGE e SIAFI Lista de IDs

Tabela de correspondência entre os códigos de município utilizados pelo
SIAFI e os códigos de município do IBGE, com o nome do município, a
unidade da federação e o CNPJ da prefeitura. Os dados são extraídos do
arquivo `tabmun.csv` publicado pelo Tesouro Transparente.

## Usage

``` r
municipios_siafi_ibge
```

## Format

A data frame with 5589 observations on the following 5 variables.

- `codigo_municipio_siafi`:

  a character vector with 4 digit SIAFI code

- `cnpj`:

  a character vector of business fiscal CNPJ code

- `nome_municipio`:

  a character vector with city name

- `uf`:

  a character vector of UF 2 char abbreviation

- `codigo_ibge`:

  a numeric vector with City's IBGE Code

## Source

Tesouro Transparente, arquivo `tabmun.csv`:
<https://www.tesourotransparente.gov.br/>

## Details

Mapeamento entre códigos de município SIAFI e IBGE

O código SIAFI é mantido como texto para preservar os zeros à esquerda,
que são significativos. As junções entre os dados do Portal da
Transparência e este mapeamento devem sempre ser feitas pela coluna
`codigo_municipio_siafi`, e não pela coluna `cnpj`.

## References

Portal da Transparência do Governo Federal:
<https://portaldatransparencia.gov.br/>

## Examples

``` r
str(municipios_siafi_ibge)
#> spc_tbl_ [5,589 × 5] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
#>  $ codigo_municipio_siafi: chr [1:5589] "0001" "0002" "0003" "0008" ...
#>  $ cnpj                  : chr [1:5589] "05893631000109" "84744994000140" "05903125000145" "84736941000188" ...
#>  $ nome_municipio        : chr [1:5589] "GUAJARA-MIRIM" "ALTO ALEGRE DOS PARECIS" "PORTO VELHO" "CUJUBIM" ...
#>  $ uf                    : chr [1:5589] "RO" "RO" "RO" "RO" ...
#>  $ codigo_ibge           : num [1:5589] 1100106 1100379 1100205 1100940 1100304 ...
#>  - attr(*, "spec")=
#>   .. cols(
#>   ..   .default = col_character(),
#>   ..   codigo_municipio_siafi = col_character(),
#>   ..   cnpj = col_character(),
#>   ..   nome_municipio = col_character(),
#>   ..   uf = col_character(),
#>   ..   codigo_ibge = col_number()
#>   .. )
#>  - attr(*, "problems")=<pointer: (nil)> 
head(municipios_siafi_ibge)
#> # A tibble: 6 × 5
#>   codigo_municipio_siafi cnpj           nome_municipio         uf    codigo_ibge
#>   <chr>                  <chr>          <chr>                  <chr>       <dbl>
#> 1 0001                   05893631000109 GUAJARA-MIRIM          RO        1100106
#> 2 0002                   84744994000140 ALTO ALEGRE DOS PAREC… RO        1100379
#> 3 0003                   05903125000145 PORTO VELHO            RO        1100205
#> 4 0008                   84736941000188 CUJUBIM                RO        1100940
#> 5 0013                   04092706000181 VILHENA                RO        1100304
#> 6 0015                   04279238000159 JARU                   RO        1100114
```
