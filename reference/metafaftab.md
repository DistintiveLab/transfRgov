# Parâmetros aceitos por cada endpoint da API Fundo a Fundo

Lista nomeada que associa o caminho de cada endpoint da API Fundo a
Fundo (TransfereGov) ao vetor com os nomes dos parâmetros aceitos por
aquele endpoint. Os nomes da lista são os caminhos dos endpoints (por
exemplo, `"/programa"`) e cada elemento é um vetor de caracteres.

## Usage

``` r
metafaftab
```

## Format

A list with 21 elements, each a character vector whose length varies
according to the number of parameters of the endpoint.

- `/programa`:

  vetor com os parâmetros do endpoint de programas

- `/plano_acao`:

  vetor com os parâmetros do endpoint de planos de ação

- `/empenho`:

  vetor com os parâmetros do endpoint de empenhos

- ...:

  demais endpoints da API

## Source

Especificação OpenAPI da API Fundo a Fundo, em
`https://api.transferegov.gestao.gov.br/fundoafundo/` (o servidor
responde apenas a requisições `GET`).

## Details

Metadados dos endpoints da API Fundo a Fundo

A lista é obtida a partir da especificação OpenAPI publicada pela
própria API. Ela serve de referência para descobrir os nomes válidos dos
parâmetros de filtro aceitos por cada função `ler_*`/`get_*` do pacote.

## References

Documentação do TransfereGov: <https://www.gov.br/transferegov/pt-br>

## Examples

``` r
names(metafaftab)
#>  [1] "/programa"                            
#>  [2] "/programa_beneficiario"               
#>  [3] "/programa_gestao_agil"                
#>  [4] "/plano_acao"                          
#>  [5] "/plano_acao_dado_bancario"            
#>  [6] "/plano_acao_meta"                     
#>  [7] "/plano_acao_meta_acao"                
#>  [8] "/plano_acao_destinacao_recursos"      
#>  [9] "/plano_acao_analise"                  
#> [10] "/plano_acao_analise_responsavel"      
#> [11] "/plano_acao_historico"                
#> [12] "/termo_adesao"                        
#> [13] "/termo_adesao_historico"              
#> [14] "/gestao_financeira_lancamentos"       
#> [15] "/gestao_financeira_subtransacoes"     
#> [16] "/gestao_financeira_categorias_despesa"
#> [17] "/empenho"                             
#> [18] "/relatorio_gestao"                    
#> [19] "/relatorio_gestao_acoes"              
#> [20] "/relatorio_gestao_analise"            
#> [21] "/relatorio_gestao_analise_responsavel"
metafaftab[["/programa"]]
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
#> [35] "select"                                                       
#> [36] "order"                                                        
#> [37] "range"                                                        
#> [38] "rangeUnit"                                                    
#> [39] "offset"                                                       
#> [40] "limit"                                                        
#> [41] "preferCount"                                                  
```
