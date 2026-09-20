# Package index

## Transferências mensais para municípios

Baixa os arquivos mensais de transferências da União publicados pelo
Portal da Transparência e associa cada código SIAFI de município ao
código IBGE correspondente.

- [`download_transferencias_uniao()`](https://distintivelab.github.io/transfRgov/reference/download_transferencias_uniao.md)
  : Baixar Dados de Transferências da União
- [`municipios_siafi_ibge`](https://distintivelab.github.io/transfRgov/reference/municipios_siafi_ibge.md)
  : IBGE e SIAFI Lista de IDs

## Despesas e renúncias fiscais

Arquivos diários de despesas com o detalhamento dos beneficiários,
consulta de renúncias fiscais e a tabela de correspondência entre
códigos SIAFI e IBGE do Tesouro Transparente.

- [`download_despesas_ptransp()`](https://distintivelab.github.io/transfRgov/reference/download_despesas_ptransp.md)
  : Baixar Dados de Despesas do Portal da Transparência
- [`consultar_renuncias_fiscais()`](https://distintivelab.github.io/transfRgov/reference/consultar_renuncias_fiscais.md)
  : Consultar Valores de Renúncia Fiscal
- [`baixa_municipio_siafibge()`](https://distintivelab.github.io/transfRgov/reference/baixa_municipio_siafibge.md)
  : Obter Mapeamento SIAFI-IBGE de Municípios

## Programas

Programas federais, seus beneficiários e as modalidades especiais.

- [`ler_programas()`](https://distintivelab.github.io/transfRgov/reference/ler_programas.md)
  : Obter dados do endpoint /programa
- [`ler_programa_beneficiario()`](https://distintivelab.github.io/transfRgov/reference/ler_programa_beneficiario.md)
  : Obter dados do endpoint programa_beneficiario
- [`ler_programa_gestao_agil()`](https://distintivelab.github.io/transfRgov/reference/ler_programa_gestao_agil.md)
  : Obter dados do endpoint programa_gestao_agil
- [`ler_programa_especial()`](https://distintivelab.github.io/transfRgov/reference/ler_programa_especial.md)
  : Ler dados de Programa Especial da API TransfereGov

## Empenhos

Empenhos registrados nos planos de ação.

- [`ler_empenho()`](https://distintivelab.github.io/transfRgov/reference/ler_empenho.md)
  : Ler dados do endpoint empenho
- [`ler_empenho_especial()`](https://distintivelab.github.io/transfRgov/reference/ler_empenho_especial.md)
  : Ler dados de Empenho Especial da API TransfereGov

## Planos de ação

Planos de ação, seus dados bancários, destinação de recursos, histórico,
análises e metas.

- [`get_plano_acao()`](https://distintivelab.github.io/transfRgov/reference/get_plano_acao.md)
  : Obter dados do endpoint plano_acao
- [`get_plano_acao_dado_bancario()`](https://distintivelab.github.io/transfRgov/reference/get_plano_acao_dado_bancario.md)
  : Obter dados do endpoint plano_acao_dado_bancario
- [`get_plano_acao_destinacao_recursos()`](https://distintivelab.github.io/transfRgov/reference/get_plano_acao_destinacao_recursos.md)
  : Obter dados do endpoint plano_acao_destinacao_recursos
- [`get_plano_acao_historico()`](https://distintivelab.github.io/transfRgov/reference/get_plano_acao_historico.md)
  : Obter dados do endpoint plano_acao_historico
- [`ler_plano_acao_analise()`](https://distintivelab.github.io/transfRgov/reference/ler_plano_acao_analise.md)
  : Obter dados do endpoint plano_acao_analise
- [`ler_plano_acao_analise_responsavel()`](https://distintivelab.github.io/transfRgov/reference/ler_plano_acao_analise_responsavel.md)
  : Obter dados do endpoint plano_acao_analise_responsavel
- [`ler_plano_acao_meta()`](https://distintivelab.github.io/transfRgov/reference/ler_plano_acao_meta.md)
  : Obter dados do endpoint plano_acao_meta
- [`ler_plano_acao_meta_acao()`](https://distintivelab.github.io/transfRgov/reference/ler_plano_acao_meta_acao.md)
  : Obter dados do endpoint plano_acao_meta_acao

## Termos de adesão

Termos de adesão e seu histórico.

- [`get_termo_adesao()`](https://distintivelab.github.io/transfRgov/reference/get_termo_adesao.md)
  : Obter dados do endpoint termo_adesao
- [`ler_termo_adesao_historico()`](https://distintivelab.github.io/transfRgov/reference/ler_termo_adesao_historico.md)
  : Obter dados do endpoint termo_adesao_historico

## Relatórios de gestão

Relatórios de gestão, ações, análises e responsáveis.

- [`ler_relatorio_gestao()`](https://distintivelab.github.io/transfRgov/reference/ler_relatorio_gestao.md)
  : Ler dados de Relatório de Gestão da API TransfereGov
- [`ler_relatorio_gestao_acoes()`](https://distintivelab.github.io/transfRgov/reference/ler_relatorio_gestao_acoes.md)
  : Ler dados de Ações do Relatório de Gestão da API TransfereGov
- [`ler_relatorio_gestao_analise()`](https://distintivelab.github.io/transfRgov/reference/ler_relatorio_gestao_analise.md)
  : Ler dados de Análise do Relatório de Gestão da API TransfereGov
- [`ler_relatorio_gestao_analise_responsavel()`](https://distintivelab.github.io/transfRgov/reference/ler_relatorio_gestao_analise_responsavel.md)
  : Ler dados de Responsáveis pela Análise do Relatório de Gestão da API
  TransfereGov

## Gestão financeira

Categorias de despesa, lançamentos e subtransações da gestão financeira.

- [`ler_gestao_financeira_categorias_despesa()`](https://distintivelab.github.io/transfRgov/reference/ler_gestao_financeira_categorias_despesa.md)
  : Obter dados do endpoint gestao_financeira_categorias_despesa
- [`ler_gestao_financeira_lancamentos()`](https://distintivelab.github.io/transfRgov/reference/ler_gestao_financeira_lancamentos.md)
  : Obter dados do endpoint gestao_financeira_lancamentos
- [`ler_gestao_financeira_subtransacoes()`](https://distintivelab.github.io/transfRgov/reference/ler_gestao_financeira_subtransacoes.md)
  : Obter dados do endpoint gestao_financeira_subtransacoes

## Metadados

Descrição dos endpoints da API e dos campos aceitos como filtro.

- [`metafaftab`](https://distintivelab.github.io/transfRgov/reference/metafaftab.md)
  : Parâmetros aceitos por cada endpoint da API Fundo a Fundo
