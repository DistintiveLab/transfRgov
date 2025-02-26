transfRgov - Pacote de Acesso a APIs do TransfereGov
================
Rodrigo E. S. Borges
2025-02-24

# Introdução

# transfRgov <img src='man/figures/logodali.webp' align="right" height="139" />

[![codecov](https://codecov.io/gh/distintivelab/transfRgov/graph/badge.svg?token=7B3AMAQYHS)](https://app.codecov.io/gh/distintivelab/transfRgov)

O **transfRgov** é um pacote em R que facilita o acesso aos dados
disponíveis na API FundoaFundo (TransfereGov).  
O pacote utiliza a função `pg.get` do pacote
[postgrestR](https://github.com/clesiemo3/postgrestR) para construir
consultas aos diferentes endpoints da API.  
Cada endpoint é acessado por uma função cujo nome inicia com `ler_`,
permitindo filtrar os resultados utilizando o parâmetro `filter` no
formato `nome_parametro=valor` (traduzido para nome_parametro=eq.valor
na requisição http interna).

# Instalação

Para instalar o pacote, utilize:

``` r
# Instale o postgrestR se ainda não o tiver
# devtools::install_github("clesiemo3/postgrestR")

# Instale o transfRgov 
devtools::install_github("distintivelab/transfRgov")
```

# Uso

Carregue o pacote e utilize as funções para acessar os dados dos
diversos endpoints da API.

## Exemplos

### Ler dados do endpoint programa

``` r
library(transfRgov)

# Exemplo: Ler dados de programas filtrando pelo ano 2020 e modalidade "Ordinário"
dados_programa <- ler_programa(ano_programa = 2020, modalidade_programa = "Ordinário")
head(dados_programa)


# Exemplo: Ler dados de programas filtrando pelo ano 2020 e modalidade "Ordinário"


dados_programa <- ler_programa(ano_programa = 2020, modalidade_programa = "Ordinário")
head(dados_programa)
```

### Ler dados do endpoint empenho

``` r
# Exemplo: Ler empenhos do ano de 2020 para um determinado plano de ação
dados_empenho <- ler_empenho(ano_empenho = 2020, id_plano_acao = 1234)
head(dados_empenho)
```

### Ler dados do endpoint relatorio_gestao

``` r
# Exemplo: Ler relatórios de gestão para um plano de ação específico
dados_relatorio <- ler_relatorio_gestao(id_plano_acao = 1234)
head(dados_relatorio)
```

## Endpoints Disponíveis

- ler_programa: Retorna informações sobre os programas.

- ler_programa_beneficiario: Retorna dados dos beneficiários dos
  programas.

- ler_programa_gestao_agil: Retorna informações da gestão ágil dos
  programas.

- ler_plano_acao: Retorna os dados dos planos de ação.

- ler_plano_acao_dado_bancario: Retorna os dados bancários dos planos de
  ação.

- ler_plano_acao_meta: Retorna as metas dos planos de ação.

- ler_plano_acao_meta_acao: Retorna as ações associadas às metas dos
  planos de ação.

- ler_plano_acao_destinacao_recursos: Retorna os dados de destinação de
  recursos dos planos de ação.

- ler_plano_acao_analise: Retorna os dados das análises dos planos de
  ação.

- ler_plano_acao_analise_responsavel: Retorna os responsáveis pelas
  análises dos planos de ação.

- ler_plano_acao_historico: Retorna o histórico dos planos de ação.

- ler_termo_adesao: Retorna os dados dos termos de adesão.

- ler_termo_adesao_historico: Retorna o histórico dos termos de adesão.

- ler_gestao_financeira_lancamentos: Retorna os lançamentos da gestão
  financeira.

- ler_gestao_financeira_subtransacoes: Retorna as subtransações dos
  lançamentos de gestão financeira.

- ler_gestao_financeira_categorias_despesa: Retorna as categorias de
  despesa da gestão financeira.

- ler_empenho: Retorna os dados dos empenhos.

- ler_relatorio_gestao: Retorna os relatórios de gestão.

- ler_relatorio_gestao_acoes: Retorna as ações dos relatórios de gestão.

- ler_relatorio_gestao_analise: Retorna as análises dos relatórios de
  gestão.

- ler_relatorio_gestao_analise_responsavel: Retorna os responsáveis
  pelas análises dos relatórios de gestão.

- ler_relatorio_gestao_acoes: Retorna as ações dos relatórios de gestão.

- ler_relatorio_gestao_analise: Retorna as análises dos relatórios de
  gestão.

- ler_relatorio_gestao_analise_responsavel: Retorna os responsáveis
  pelas análises dos relatórios de gestão.

# Dados de Resposta

Cada função retorna os dados da API FundoaFundo como uma lista ou data
frame, contendo as colunas especificadas pela documentação da API. Estes
dados podem ser manipulados e analisados diretamente no R.

# Contribuição

Contribuições são bem-vindas! Envie issues e pull requests para melhorar
o pacote.

# Licença

Este pacote é distribuído sob a Licença GPL-3.

# Disclaimer - Nota de isenção de responsabilidade:

Este pacote não é uma ferramenta oficial do Ministério da Gestão ou de
qualquer órgão do governo federal. Ele foi desenvolvido de forma
voluntária e independente, sem qualquer vínculo, afiliação ou endosso
por parte de autoridades governamentais. Os desenvolvedores não assumem
responsabilidade por alterações na API FundoaFundo, eventuais
inconsistências ou interrupções na disponibilidade dos dados.
