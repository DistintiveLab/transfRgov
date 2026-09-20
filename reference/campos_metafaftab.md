# Listar os campos aceitos por cada endpoint da API Fundo a Fundo

Acessor do conjunto de dados
[`metafaftab`](https://distintivelab.github.io/transfRgov/reference/metafaftab.md).
Transforma a lista crua de caminhos e vetores em uma tabela de duas
colunas (`endpoint` e `campo`) ou devolve apenas o vetor de campos de um
endpoint escolhido.

## Usage

``` r
campos_metafaftab(endpoint = NULL, incluir_controle = FALSE)
```

## Arguments

- endpoint:

  Caminho de um endpoint, em texto. Pode ser informado com ou sem a
  barra inicial (`"/programa"` ou `"programa"`). Quando `NULL` (o
  padrão), a função descreve todos os endpoints.

- incluir_controle:

  Lógico. Cada endpoint aceita os parâmetros de controle do PostgREST
  (`order`, `range`, `rangeUnit`, `offset`, `limit`, `preferCount` e
  `select`), que não são colunas da resposta e por isso ficam fora do
  resultado por padrão (`FALSE`). Com `TRUE` eles são incluídos e
  sinalizados pela coluna `controle`.

## Value

Com `endpoint = NULL`, um `data.frame` com as colunas `endpoint`
(caminho do endpoint), `campo` (nome do parâmetro) e `controle` (lógico,
indica se o campo é um parâmetro de controle do PostgREST e não uma
coluna). Com um `endpoint` informado, um vetor de caracteres com os
campos daquele endpoint, na ordem em que aparecem no `metafaftab`.

## Details

A função é útil para descobrir os nomes válidos dos argumentos das
funções `ler_*`/`get_*` do pacote, que refletem os campos da API. Por
exemplo, `campos_metafaftab("empenho")` lista os filtros aceitos por
[`ler_empenho`](https://distintivelab.github.io/transfRgov/reference/ler_empenho.md).

Dos 21 endpoints, 19 expõem um `select` comum; `/plano_acao` expõe
`select_plano_acao` e `/relatorio_gestao_analise` expõe
`select_relatorio_gestao_analise`. Os demais seis controles aparecem nos
21 endpoints, o que dá sete parâmetros de controle por endpoint.

## See also

[`metafaftab`](https://distintivelab.github.io/transfRgov/reference/metafaftab.md)

## Examples

``` r
head(campos_metafaftab())
#>    endpoint                       campo controle
#> 1 /programa                 id_programa    FALSE
#> 2 /programa                ano_programa    FALSE
#> 3 /programa         modalidade_programa    FALSE
#> 4 /programa             codigo_programa    FALSE
#> 5 /programa               nome_programa    FALSE
#> 6 /programa id_unidade_gestora_programa    FALSE
campos_metafaftab("/programa")
#>  [1] "id_programa"                                                  
#>  [2] "ano_programa"                                                 
#>  [3] "modalidade_programa"                                          
#>  [4] "codigo_programa"                                              
#>  [5] "nome_programa"                                                
#>  [6] "id_unidade_gestora_programa"                                  
#>  [7] "nome_institucional_programa"                                  
#>  [8] "permite_transferencia_sem_fundo_programa"                     
#>  [9] "objetivo_programa"                                            
#> [10] "descricao_programa"                                           
#> [11] "situacao_programa"                                            
#> [12] "valor_global_programa"                                        
#> [13] "quantidade_parcelas_programa"                                 
#> [14] "id_orgao_superior_programa"                                   
#> [15] "sigla_orgao_superior_programa"                                
#> [16] "cnpj_orgao_superior_programa"                                 
#> [17] "nome_orgao_superior_programa"                                 
#> [18] "id_fundo_programa"                                            
#> [19] "cnpj_fundo_programa"                                          
#> [20] "nome_fundo_programa"                                          
#> [21] "uf_fundo_programa"                                            
#> [22] "municipio_fundo_programa"                                     
#> [23] "codigo_ibge_fundo_programa"                                   
#> [24] "grupo_natureza_despesa_programa"                              
#> [25] "codigo_descricao_orcamentaria_programa"                       
#> [26] "descricao_acao_orcamentaria_programa"                         
#> [27] "valor_acao_orcamentaria_programa"                             
#> [28] "data_inicio_recebimento_planos_acao_beneficiarios_especificos"
#> [29] "data_fim_recebimento_planos_acao_beneficiarios_especificos"   
#> [30] "data_inicio_recebimento_planos_acao_beneficiarios_emendas"    
#> [31] "data_fim_recebimento_planos_acao_beneficiarios_emendas"       
#> [32] "data_inicio_recebimento_planos_acao_beneficiarios_voluntarios"
#> [33] "data_fim_recebimento_planos_acao_beneficiarios_voluntarios"   
#> [34] "nome_gestao_agil_programa"                                    
```
