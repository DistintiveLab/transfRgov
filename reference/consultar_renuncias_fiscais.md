# Consultar Valores de Renúncia Fiscal

Esta função busca os dados de renúncias fiscais da API do Portal da
Transparência do Governo Federal.

## Usage

``` r
consultar_renuncias_fiscais(
  pagina = 1,
  uf = NULL,
  codigo_ibge = NULL,
  cnpj = NULL,
  chave_api = Sys.getenv("PORTAL_TRANSPARENCIA_API_KEY")
)
```

## Arguments

- pagina:

  O número da página a ser retornada. O padrão é 1.

- uf:

  String com o nome ou a sigla da Unidade Federativa a ser consultada.
  Ex: "São Paulo" ou "SP".

- codigo_ibge:

  String com o código IBGE do município a ser consultado.

- cnpj:

  String com o CNPJ do beneficiário a ser consultado (apenas números).

- chave_api:

  A sua chave da API. Por padrão, a função buscará a variável de
  ambiente 'PORTAL_TRANSPARENCIA_API_KEY'.

## Value

Um data.frame com os dados das renúncias fiscais.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Para usar esta função, você precisa de uma chave de API válida,
  # configurada na variável de ambiente 'PORTAL_TRANSPARENCIA_API_KEY'.
  dados_renuncia <- consultar_renuncias_fiscais(pagina = 1, uf = "SP")
  print(dados_renuncia)
} # }
```
