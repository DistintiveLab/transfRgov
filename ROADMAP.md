# Roadmap — transfRgov

Plano de próximas inclusões e melhorias, da versão 0.1.1 em diante. Cada item
está ancorado em medições feitas diretamente na API e em auditoria do código.

## Evidências coletadas

| Medição | Resultado |
|---|---|
| Tamanho de página padrão da API | 1000 linhas (`content-range: 0-999/*`) |
| Totais reais (`Prefer: count=exact`) | `gestao_financeira_lancamentos` 1.115.444; `plano_acao` 25.972; `termo_adesao` 23.885; `relatorio_gestao` 19.271; `empenho` 4.248; `programa` 129 |
| `limit` / `offset` | funcionam (`?limit=5&offset=5` retorna `content-range: 5-9/*`) |
| `order` | funciona; campo inexistente responde HTTP 400 |
| `select` (projeção de colunas) | funciona |
| `Prefer: count=exact` | devolve o total, mas com status 206 (Partial Content) |
| `Accept: text/csv` | funciona, `content-type: text/csv; charset=utf-8`, corpo CSV real |
| Filtro com espaço, sem codificação | erro de curl: `Malformed input to a URL function` |
| Filtro com acento sem espaço, sem codificação | HTTP 400 |
| Filtro com `utils::URLencode(valor, reserved = TRUE)` | HTTP 200 |
| Endpoints do `metafaftab` com leitor | 21 de 21 |
| Tabelas `empenho_especial` e `programa_especial` | HTTP 404 — os leitores `ler_empenho_especial()` e `ler_programa_especial()` apontam para tabelas inexistentes |
| Bases irmãs no mesmo host | `parcerias`, `emendas`, `convenios`, `transferencias`, `propostas` respondem 404 |
| Especificação OpenAPI na raiz da API | 21 caminhos, exatamente os do `metafaftab`; nenhum contém "espec" |
| `programa.modalidade_programa` | valor único `FUNDO_A_FUNDO` em 129 de 129 linhas — não discrimina "especial" |
| `empenho.tipo_empenho` | `1` em 4.246 linhas, `3` em 2 linhas — único discriminador raro encontrado |
| `empenho.situacao_empenho` | valor único `6` em 4.248 linhas — não discrimina |
| Parâmetros de `ler_empenho_especial()` ausentes da tabela `empenho` | `id_empenho_especial`, `id_programa` |
| Parâmetros de `ler_programa_especial()` ausentes da tabela `programa` | `id_proponente`, `data_inicio`, `data_fim`, `esfera`, `orgao_executor` |

## Fase 1 — Correções de correção em `pg_get` (concluída)

Tudo em `R/utils-pg_get.R`. São defeitos de correção, não funcionalidades novas.

1. **Truncamento silencioso em 1000 linhas**. `pg_get()` não paginava, portanto
   consultas a endpoints grandes devolviam apenas a primeira página sem avisar:
   `gestao_financeira_lancamentos` entregava 0,09% dos registros. Resolvido com
   laço de `limit`/`offset`, parâmetros `limite`, `offset`, `paginar` e
   `max_linhas`, e aviso explícito quando o resultado é parcial.
2. **Codificação dos valores de filtro**. `pg_build_url()` concatenava com
   `paste0`, então valor com espaço lançava erro de curl e valor com acento
   retornava HTTP 400. Resolvido com `pg_encode_filter()`, que codifica só o
   valor com `utils::URLencode(valor, reserved = TRUE)` e preserva o operador
   `=`; a codificação ficou em um único ponto, não nos 23 locais de chamada.
3. **Status 206 derruba `stop_for_status()`**.
   **Medido em 2026-09-20: não é defeito.** `httr::stop_for_status()` já ignora
   qualquer status menor que 300 (`if (status_code(x) < 300) return(...)`), então
   200 e 206 passam sem erro e apenas 400+ interrompem. Nenhuma alteração de
   código foi necessária; o teste `pg_get aceita respostas HTTP 206` fixa o
   comportamento.
4. **Parser CSV inconsistente**. O ramo CSV usava `utils::read.csv()`, enquanto o
   restante do pacote usa `readr::read_delim()`. Resolvido com
   `readr::read_delim(I(conteudo), ...)` e `janitor::clean_names()`.
5. **Resultado vazio virava `list()`**. Descoberto no teste de fumaça:
   `jsonlite::fromJSON("[]")` devolve `list()`, então uma consulta sem linhas
   retornava uma lista de comprimento zero em vez do `data.frame` documentado.
   Resolvido normalizando para `data.frame()` dentro de `pg_parse_response()`.

## Fase 2 — Robustez de transporte (concluída)

6. **Retry, timeout e backoff**. O `httr::GET()` seco virou
   `httr2::req_retry()`, `httr2::req_timeout()` e `httr2::req_user_agent()`
   dentro de `pg_get()`, com os parâmetros novos `tempo_limite = 30` e
   `tentativas = 3L`; por padrão o `httr2` repete apenas falhas de rede e os
   status 429/503, e erros definitivos (como um 400 de filtro inválido)
   continuam interrompendo de imediato. `httr2` entrou em `Imports:`; `httr`
   permanece, pois `R/ler_renuncias_ptransp.R` ainda o usa.
7. **Classe de condição estruturada**. Os dois `warning()` crus viraram
   `pg_warning()` (`R/utils-pg_get.R:293` e `R/utils-pg_get.R:335`), que monta a
   condição `c("transfRgov_<classe>", "warning", "condition")` só com R base, sem
   `rlang`. As classes emitidas são `transfRgov_unsupported_type` e
   `transfRgov_partial_result`, permitindo `tryCatch()` por classe no chamador.
8. **User-Agent identificando o pacote**. `pg_user_agent()` monta
   `"transfRgov/<versão> (https://github.com/DistintiveLab/transfRgov)"` a partir
   de `utils::packageVersion()`.
9. **Passagem de `select` e `order`** aos 23 leitores. Os dois parâmetros foram
   acrescentados a `pg_get()` e a `pg_build_url()`, com `pg_encode_lista()`
   juntando os valores por vírgula e codificando cada um; os 23 leitores
   repassam `select` e `order` a cada página. Como isso acrescentou 46 `@param`
   novos em funções exportadas, 23 arquivos de `man/` foram regerados.
10. **Resultado vazio com corpo vazio** (achado no teste de fumaça).
    `jsonlite::fromJSON("")` abortava com `premature EOF`, então uma consulta sem
    linhas que devolvesse corpo vazio quebrava em vez de retornar o `data.frame`
    vazio documentado. Resolvido com retorno antecipado em
    `pg_parse_response()`.
11. **Cache em disco opcional**: adiado. Fica para uma entrega própria, junto da
    formalização do diretório `cache/` já usado nas análises.

## Fase 3 — Novas inclusões

12. **(concluída) Nenhum endpoint novo na API Fundo a Fundo**: os 21 endpoints
    do `metafaftab` já possuem leitor (verificado). O fato está registrado em
    `AGENTS.md`, inclusive o motivo de um `grep` ingênuo por `table = "`
    encontrar apenas 17 endpoints.
13. **(concluída) Outros provedores**, já que a API do TransfereGov não expõe
    bases irmãs (todas respondem 404). **Provedor escolhido: CGU / dados
    abertos.** O conjunto escolhido é **`despesas` do Portal da Transparência**
    (decidido em 2026-09-20). O leitor novo é
    `download_despesas_ptransp()` (`R/download_despesas_ptransp.R`), com testes
    próprios e `Description:` atualizada.
    - **Portal da Transparência**: hoje só `renuncias-valor`
      (`R/ler_renuncias_ptransp.R:34`). Candidatos: despesas, favorecidos,
      contratos, servidores.
    - **Tesouro Transparente / CKAN**: hoje só `tabmun.csv`
      (`R/baixa_municipio_siafibge.R:16`); o CKAN publica outros conjuntos.
    - **CGU / dados abertos** (escolhido): `download_transferencias_uniao()` cobre
      os ZIPs mensais; avaliar séries anteriores a 2019 e os demais conjuntos do
      portal de dados abertos da CGU.

    **Conjunto `despesas` — fatos medidos em 2026-09-20 (somente leitura).**

    - Cadência **diária**; arquivo `{AAAAMMDD}_Despesas.zip` em
      `https://dadosabertos-download.cgu.gov.br/PortalDaTransparencia/saida/despesas/`.
      Um dia comum pesa ~12,7 MB; um dia vazio (2024-01-01) cabe em 22 KB.
    - O ZIP **não** traz um CSV único: são **onze** arquivos nomeados
      (`_Despesas_Empenho`, `_Despesas_ItemEmpenho`,
      `_Despesas_ItemEmpenhoHistorico`, `_Despesas_Liquidacao`,
      `_Despesas_Liquidacao_EmpenhosImpactados`, `_Despesas_Pagamento`,
      `_Despesas_Pagamento_EmpenhosImpactados`,
      `_Despesas_Pagamento_FavorecidosFinais`, `_Despesas_Pagamento_ListaBancos`,
      `_Despesas_Pagamento_ListaFaturas`, `_Despesas_Pagamento_ListaPrecatorios`).
      O nome real do membro é **`ListaFaturas`** (plural); a documentação do portal
      escreve `ListaFatura` no singular. Vale o medido.
      Logo, o atalho `extracted_files[grep("\\.csv$", ...)][1]` de
      `R/ler_transferencias_ptransp.R:77` **não** pode ser reaproveitado: o
      leitor novo precisa selecionar o CSV pelo nome.
    - Os CSVs do portal são Windows-1252 com separador `;` — exatamente o que o
      caminho de leitura já existente em `download_transferencias_uniao()`
      atende (`locale(encoding = "ISO-8859-1", decimal_mark = ",")`).
    - **Séries anteriores a 2019 já funcionam sem qualquer alteração de código.**
      A série de transferências publicada começa em `201401` (2009-01 a 2013-01
      respondem 403: nunca foram publicadas). O smoke test ao vivo de 2015-01
      devolveu 100.908 linhas com o mesmo esquema de colunas. A dúvida do item
      está, portanto, encerrada.
    - O host `dadosabertos-download.cgu.gov.br` responde bem, mas **limita
      rajadas de requisições**: uma sequência de sondagens devolveu `HTTP 405`
      para URLs que, espaçadas, respondem 200/206. Sempre intercalar `Sys.sleep`
      e reconferir antes de acreditar em 403/405. O mesmo vale para testes.
    - O host CKAN `dadosabertos.cgu.gov.br` **não resolve** deste ambiente;
      `portaldatransparencia.gov.br/download-de-dados` responde 405 ao `fetch`
      simples (usar `agentic_fetch`).

    **Chegar ao beneficiário final exige encadear dois CSVs.** Medido em
    2024-01-15 (ZIP de 3,78 MB; `Pagamento` com 14.949 linhas e 34 colunas):

    - `Pagamento` traz o **total por ordem bancária** (`codigo_pagamento` +
      `valor_do_pagamento_convertido_pra_r`); `Pagamento_FavorecidosFinais` traz
      os **beneficiários** (`codigo_pagamento` + `codigo_favorecido` +
      `valor_do_pagamento_em_r`). A junção por `codigo_pagamento` fecha
      exatamente: 162 ordens com detalhe, `max |total - soma|` de `3,6e-12` e
      **99 das 162 com mais de um favorecido** (relação 1:N, não 1:1).
    - O mesmo par total/detalhe existe em `Liquidacao` ×
      `Liquidacao_EmpenhosImpactados`, `Pagamento` ×
      `Pagamento_EmpenhosImpactados` e `Empenho` × `ItemEmpenho` (por
      `id_empenho`: 2.512 dos 2.516 empenhos casaram, 421 com mais de um item).
    - O detalhamento é **parcial**: em 2024-01-15 só 162 das 14.949 ordens
      (1,1%) tinham linha em `Pagamento_FavorecidosFinais`.
      `Pagamento_ListaBancos` (102 bytes) e `Pagamento_ListaPrecatorios`
      (92 bytes) vieram só com cabeçalho. Um dia válido pode gerar data frame de
      **zero linhas** — o leitor deve devolver o data frame vazio, não `NULL`.

    **Implementação — entrega de 2026-09-20.**

    - Assinatura: `download_despesas_ptransp(data, tipo = "empenho")`. `data` é
      **uma única** data (`Date` ou conversível, como `"2024-01-15"`); `tipo` é um
      `match.arg` com os onze nomes medidos, cada um mapeado para o sufixo real do
      membro do ZIP. A seleção do CSV é por sufixo
      (`endsWith(basename(extraido), "_Despesas_<Sufixo>.csv")`), porque o membro
      vem prefixado com `{AAAAMMDD}_`.
    - Piso de data **medido**, não chutado: `20140102` responde 200 (ZIP de
      2.499.501 bytes), enquanto `20090102` e `20130102` respondem 403. Daí o
      limite `data >= as.Date("2014-01-01")` e também `data <= Sys.Date()`.
    - O leitor devolve **data frame vazio, não `NULL`**, em dia sem movimento —
      confirmado ao vivo em 2024-01-01 (`pagamento`, `pagamento_empenhos_impactados`
      e `pagamento_favorecidos_finais` com 0 linhas) e fixado por teste.
    - Fluxo idêntico ao de `download_transferencias_uniao()`: valida, monta a URL,
      `download.file(mode = "wb")` em `tempfile()` dentro de `tryCatch`, `unzip()`
      em `tempdir()`, `read_delim(delim = ";", locale(ISO-8859-1, decimal_mark = ","))`
      com `janitor::clean_names()` e queda para `read.csv`, `unlink()` dos
      temporários e retorno. Falhas devolvem `invisible(NULL)` com `warning()`;
      erros de argumento fazem `stop()`.
    - Sem bloco de mapeamento SIAFI→IBGE: as colunas medidas de `despesas` não
      trazem `codigo_municipio_siafi`.
    - O encadeamento total/detalhe **não é feito automaticamente**: o contrato é um
      artefato por chamada, e a junção (1:N) está descrita no `@details`, junto com
      a cobertura parcial (~1%) e o alerta do dia sem linhas.
    - Nome fora de `^(ler_|get_)` de propósito: mantém em **23** a contagem que a
      asserção de completude de `test-leitores.R` verifica. Exportações passam de
      26 para **27**.
    - Testes novos em `tests/testthat/test-download_despesas_ptransp.R`: 12 blocos
      e 41 asserções, **sem tocar a rede** (`mockery::stub` sobre
      `download.file`/`unzip`/`read_delim`/`read.csv`, com ZIPs e CSVs gerados em
      `tempdir()`). Cassette foi descartada de propósito: são ~12,7 MB por dia e o
      host limita rajadas. A suíte total vai de 397 para **438** asserções.
    - O smoke ao vivo (2024-01-15) devolveu `empenho` 2.516×63, `liquidacao`
      13.233×28, `pagamento` 14.949×34 e `pagamento_favorecidos_finais` 3.902×6 —
      as mesmas contagens da investigação que motivou o item.

## Fase 4 — Testes

14. **(concluída) 23 leitores sem teste.** Antes: `tests/testthat/` tinha dois
    arquivos e 108 asserções. Agora tem três arquivos de teste e um auxiliar, com
    **385 asserções**, todas passando (`FAIL 0 | WARN 0 | SKIP 0`).

    - `tests/testthat/test-leitores.R` (novo) cobre os 23 leitores de endpoint
      com 70 blocos `test_that` e 277 asserções, gerados em laço a partir de uma
      lista `leitores` que associa cada função à tabela que ela consulta. Para
      cada leitor verifica três coisas: a URL aponta para a tabela certa e
      carrega todos os parâmetros como filtro `campo=eq.valor`; `select` e
      `order` são repassados; e o resultado tem as colunas do endpoint. Um
      primeiro bloco compara `names(leitores)` com os exports que casam
      `^(ler_|get_)`, de modo que um leitor novo sem teste quebra a suíte.
    - `tests/testthat/helper-httr2.R` (novo) guarda os auxiliares comuns:
      `resposta_simulada()`, `mock_capturando_urls()` e `sem_avisos()`. O
      `resposta_simulada()` que vivia dentro de `test-pg_get.R` foi movido para
      cá; o testthat carrega `helper-*.R` automaticamente.
    - Duas decisões divergem do texto original do item, ambas deliberadas:
      1. **Sem `skip_on_cran()`.** O texto condicionava o `skip` aos "testes que
         dependem de rede", mas estes não tocam a rede: o mock de
         `httr2::with_mocked_responses()` desvia `req_perform()` antes de abrir
         qualquer socket. Marcar `skip_on_cran()` só esconderia a cobertura das
         verificações do CRAN.
      2. **`httr2::with_mocked_responses()` em vez de
         `httr2::local_mocked_responses()`.** As duas formas funcionam; a
         primeira permite que o auxiliar devolva, na mesma chamada, o resultado
         *e* as URLs efetivamente requisitadas, que é o que viabiliza as
         asserções por leitor.
    - Uma resposta `[]`, ou com uma única linha, encerra a paginação na primeira
      página, então `expect_length(urls, 1)` é seguro e o mock é sempre
      limitado.
    - **Defeito encontrado, ainda não corrigido:** `ler_empenho_especial()`
      (`R/ler_empenho_especial.R:54`) e `ler_programa_especial()`
      (`R/ler_programas_especiais.R:49`) consultam as tabelas `empenho_especial`
      e `programa_especial`, e ambas respondem **404** na API no ar. Nenhuma das
      duas está no `metafaftab`. A hipótese é que "especial" seja um *valor de
      filtro* das tabelas `programa`/`empenho`, não uma tabela separada. Os
      testes novos verificam apenas o contrato de transporte (que o leitor monta
      `/<tabela>?...`), de modo que passam hoje e continuam corretos se o nome da
      tabela for corrigido depois. Aguarda decisão do mantenedor.
      Investigação de 2026-09-20 (somente leitura, nenhum leitor alterado):
      a especificação OpenAPI servida na raiz da API lista exatamente os 21
      caminhos do `metafaftab` e nenhum contém "espec", o que confirma que as duas
      tabelas não existem sob nenhuma grafia testada (`empenho_especial`,
      `empenhos_especiais`, `programa_especial`, `programas_especiais` — todas
      404). Nenhuma coluna discrimina "especial": `programa.modalidade_programa` é
      `FUNDO_A_FUNDO` em 129 de 129 linhas, e `empenho.situacao_empenho` tem valor
      único `6` em 4.248 linhas; o único candidato raro é `empenho.tipo_empenho == 3`,
      presente em 2 linhas. Além disso, vários parâmetros dos dois leitores não
      existem como colunas: em `empenho` faltam `id_empenho_especial` e
      `id_programa` (a ligação com planos de ação é por `id_plano_acao`); em
      `programa` faltam `id_proponente`, `data_inicio`, `data_fim`, `esfera` e
      `orgao_executor`. Ou seja, uma correção não é troca de nome de tabela.
      **Decisão do mantenedor em 2026-09-20: adiar** (alternativa (d) das três
      apresentadas). A evidência acima fica registrada e nenhum dos dois leitores
      é alterado por enquanto.
15. **(concluída) `vcr` com cassettes gravadas.** O objetivo literal era permitir
    que o CRAN exercitasse testes HTTP hoje marcados com `skip_on_cran()`. A
    leitura do código mostrou que as 19 ocorrências de `skip_on_cran()` já estavam
    **offline** (12 com `httr2::with_mocked_responses()`, 7 com `mockery::stub()`),
    de modo que converter aqueles blocos para cassettes não acrescentaria nada. A
    entrega ficou então dividida em duas partes: testes novos de comportamento real
    contra a API no ar, gravados como cassettes, e a remoção das 19 chamadas
    redundantes de `skip_on_cran()`.

    - **Ferramenta: `vcr` 1.6.0, não `httptest`.** O `vcr` importa `httr2` e
      `webmockr` diretamente; o `httptest` não está instalado. `Suggests:` passou a
      listar `vcr` e `webmockr`.
    - `tests/testthat/helper-vcr.R` (novo) faz `library(vcr)` e configura
      `vcr::vcr_configure(dir = vcr::vcr_test_path("testthat", "_vcr"), record = "once")`,
      protegido por `requireNamespace()`. O `library(vcr)` é **obrigatório**, não
      estilo: o `webmockr` só grava quando `"package:vcr" %in% search()`, então
      chamar `vcr::use_cassette()` sem anexar o pacote faz a requisição ir à rede,
      gravar zero interações e apagar a cassette vazia em silêncio.
    - `tests/testthat/test-cassettes.R` (novo) tem 6 blocos `test_that` e 12
      asserções. Cada bloco é protegido por `skip_if_not_installed("vcr")`,
      `skip_if_not_installed("httr2")` e `vcr::skip_if_vcr_off()`. Cobre paginação
      (duas páginas, `limit=2`), `select` com `order`, ordenação ascendente,
      resultado vazio, filtro por `id_programa` e `order` inválido (HTTP 400
      `httr2_http_400`, gravado com o corpo de erro do PostgreSQL).
    - As 6 cassettes ficam em `tests/testthat/_vcr/`. `vcr::vcr_test_path()`
      resolve a partir de `tests/`, então o primeiro argumento precisa ser
      `"testthat"` para cair na convenção do pacote. Elas **viajam no tarball**:
      nenhuma regra foi acrescentada ao `.Rbuildignore`, que é a prática padrão do
      `vcr` e o que permite o CRAN reexecutar os testes.
    - Todas as cassettes usam `limite` pequeno (2 ou 3) para que a página gravada
      seja curta e o laço de `pg_get()` (`if (linhas < limite || linhas == 0) break`)
      encerre na reprodução offline.
    - A paginação se ancora em `order=id_programa.asc`, que devolve
      deterministicamente `1,2,3,…`.
    - **As 19 chamadas de `skip_on_cran()` foram removidas** (`test-pg_get.R` 12,
      `test-download_transferencias_uniao.R` 7). Elas não protegiam nada: todos
      aqueles blocos já são offline. Mantê-las só escondia do CRAN a cobertura de
      transporte, `select`/`order`, paginação, corpo vazio e caminhos de falha.
    - Suíte: 397 asserções, `FAIL 0 | WARN 0 | SKIP 0`. Os cinco gates passaram,
      inclusive `check --as-cran` com `Status: OK` e 0 erros, 0 avisos e 0 notas.
      O único NOTA do modo `incoming` continua sendo o de submissão nova
      (e-mail do mantenedor e nomes próprios), idêntico ao da linha de base.
    - A reprodução é offline e estável: os 6 arquivos YAML mantêm o mesmo
      `md5sum` antes e depois de rodar a suíte, ou seja, nada é regravado.
16. **(concluída) Cobertura ausente:** `consultar_renuncias_fiscais()` e
    `baixa_municipio_siafibge()` não têm nenhum teste.

    **Implementação — entrega de 2026-09-20.** Os dois leitores passaram a ser
    cobertos inteiramente offline por um único arquivo novo,
    `tests/testthat/test-renuncias_e_siafibge.R` (10 blocos `test_that`, 38
    asserções). O total da suíte foi de **438 para 476 asserções**, com
    `FAIL 0 | WARN 0 | SKIP 0`. Nenhuma linha de `R/`, `NAMESPACE`, `man/` ou
    `DESCRIPTION` mudou.

    - **Duas estratégias, por um motivo mecânico.** `consultar_renuncias_fiscais()`
      chama `httr::GET` qualificado, então `mockery::stub()` não consegue
      interceptá-lo; a cobertura vem de `webmockr` 2.0.0. Já
      `baixa_municipio_siafibge()` chama `download.file` e `read.csv` sem
      qualificação, então `mockery` funciona para ela. Os dois pacotes já estavam
      em `Suggests:` e nenhuma dependência nova foi acrescentada.
    - **A receita de `webmockr` que casa com query string.** Um stub criado sem
      `wi_th()` **não casa** com requisição que carrega query string: a chamada
      aborta com `Real HTTP connections are disabled. Unregistered request:`. A
      forma que funciona registra a URL **sem** query string e desambigua pelos
      parâmetros:
      `webmockr::stub_request("get", url) |> webmockr::wi_th(query = list(pagina = 1)) |> webmockr::to_return(status = 200, body = ..., headers = ...)`.
    - **O primeiro stub registrado vence**, então `webmockr::stub_registry_clear()`
      é obrigatório no início de cada bloco que registra stub; sem ele, os stubs
      de um bloco anterior sequestram as chamadas do seguinte.
    - **`allow_net_connect` já é `FALSE` por padrão** no `webmockr` 2.0.0, e
      `webmockr_configure_reset()` não desabilita o stubbing. Nenhum teardown de
      rede é necessário; basta `on.exit(webmockr::disable(quiet = TRUE), add = TRUE)`
      para desligar o `webmockr` ao fim do bloco.
    - **`webmockr::last_request()$url` é uma lista de comprimento 1**, não uma
      string: é preciso `unlist()` (ou `as.character()`) antes de qualquer `grepl()`,
      e `cat()` direto sobre ela falha. Já `$headers[["chave-api-dados"]]` é escalar
      `character`, o que permite asserir o cabeçalho de autenticação.
    - **A ausência de chave separa este leitor do padrão dos `download_*`.**
      `consultar_renuncias_fiscais()` faz `stop()` duro quando
      `chave_api == ""`, enquanto os `download_*` devolvem `warning()` +
      `invisible(NULL)`. Dois blocos cobrem isso: um para o texto do erro e outro
      para o nome da variável de ambiente (`PORTAL_TRANSPARENCIA_API_KEY`).
    - **HTTP 404 vira `http_error`.** `httr::stop_for_status()` levanta
      `http_404`/`http_400`/`http_error`, então o caminho de erro é asseverado com
      `expect_error(..., class = "http_error")` sobre um stub de status 404.
    - **Delimitador do `read_csv2` é `;`**, com `col_names` fixos (não há linha de
      cabeçalho na fixture) e `codigo_ibge` numérico por `col_number()`. O gatilho
      confiável da falha do `readr` é um **caminho inexistente**, não um arquivo
      vazio (arquivo vazio devolve `0 × 2` sem erro); com a falha forçada, o
      fallback `read.csv` Latin1 é exercitado por stub.
    - **O `readr::read_csv2` qualificado não foi desqualificado** (opção A): a
      mudança de fonte evita tocar `R/`, `NAMESPACE` e `man/`, e a falha do `readr`
      é provocada naturalmente pelo stub de download que não cria o arquivo.
    - **Cassette `vcr` não era opção** para o endpoint de renúncias: não existe
      chave de API neste ambiente e o portal responde erro sem ela, então a via
      offline determinística é o `webmockr`.

## Fase 5 — Documentação e usabilidade

17. **(concluída) Vignette**: fluxo "baixar, tratar e consolidar
    por município e função", antes restrito ao script
    `data-raw/consolida_transferencias_p_funcao_municipio.R`.

    **Implementação — entrega de 2026-09-20.**
    - **`vignettes/transfRgov.Rmd` criado** (394 linhas) sob o título "Baixar,
      tratar e consolidar transferências por município e função"; é a primeira
      vignette do pacote e o diretório `vignettes/` não existia.
    - **`VignetteBuilder: knitr`** adicionado ao `DESCRIPTION` e cinco entradas
      novas em `Suggests:`: `data.table`, `dplyr`, `knitr`, `rmarkdown` e
      `tidyr`. São exatamente as usadas pelo texto e pelos chunks executáveis; a
      versão do pacote não foi tocada.
    - **Todo chunk de rede é `eval = FALSE`.** O CRAN não tem rede durante o
      build e o servidor da CGU limita rajadas (a investigação do item 13 viu 15
      requisições seguidas voltarem `HTTP 405` e as mesmas URLs voltarem 200
      depois de uma pausa). A vignette explica o padrão de URL e mostra a
      chamada, mas não a executa.
    - **A consolidação é demonstrada de fato sobre um `data.frame` sintético**
      montado dentro do documento, com os nomes de coluna que o
      `janitor::clean_names()` produz em tempo de execução e com os valores
      categóricos reais do arquivo da CGU (`Constitucionais e Royalties`,
      `Legais, Voluntárias e Específicas`, `Transferências a Instituições
      Privadas sem Fins Lucrativos`, as três funções do exemplo). Como esses
      chunks rodam no build, o leitor vê saída real e o `R CMD check` exercita o
      encadeamento inteiro sem rede e sem chave de API.
    - **O encadeamento é parametrizado no baixador** (`consolida_tr_funcao(ano,
      baixar = download_transferencias_uniao)`), de modo que o mesmo código é
      mostrado uma vez para uso real e outra contra o quadro sintético. É o
      ponto de projeto que evita duplicar o pipeline.
    - **A divergência de nomes em relação ao script de origem é deliberada.** O
      script faz `select(-privadas)` e `values_from = governo_e_publico`, mas o
      `pivot_wider` anterior nunca produz essas colunas: o nome é dinâmico, no
      formato `{tipo_transferencia}_{privadopub}`. A verificação empírica
      mostrou que o script **não roda de ponta a ponta**; a vignette seleciona
      por padrão (`ends_with("_publico")` com
      `rename_with(janitor::make_clean_names, ...)`) e documenta a
      dinamicidade dos nomes. O script em `data-raw/` foi deixado como está: seus
      defeitos são a justificativa da vignette.
    - **Os demais defeitos do script foram corrigidos no texto, não copiados**:
      sai o `transfRgov:::` sobre função exportada, entra `.groups = "drop"` no
      `summarise`, e o total passa a somar
      `dplyr::across(dplyr::where(is.numeric) & -c(ano, codigo_ibge))` para que a
      coluna `uf`, que é caractere, não quebre o `rowSums`. O laço multianual
      ganha guarda `if (is.null(mes_dados)) return(NULL)`, porque
      `download_transferencias_uniao()` avisa e devolve `NULL` em vez de parar.
    - **O bloco de `readxl`/"cebas" foi excluído**: é material de análise do
      script, não faz parte do fluxo do pacote, e `readxl` não está instalado nem
      declarado.
    - **Limitações registradas na própria vignette**: não existe quadro
      pré-consolidado, os valores são nominais e o `match()` entre código SIAFI e
      código IBGE devolve `NA` silenciosamente quando o código não está no
      mapeamento (a vignette ensina a conferir com
      `sum(is.na(dados$codigo_ibge))`).
    - **Verificação**: `rmarkdown::render()` com saída `EXIT:0` e 29 chunks;
      tabelas renderizadas conferidas contra o `data.frame` sintético (o total
      real é 330001 e uma afirmação da prosa dizia 330002 — corrigida); os cinco
      gates passaram: `devtools::document()` sem diferença, `devtools::test()`
      com `FAIL 0 | WARN 0 | SKIP 0 | PASS 476` (inalterado), gate ASCII com 0
      ofensas em 30 arquivos `R`, auditoria dos `\arguments` com 26 de 26, e
      `devtools::check(args = "--as-cran")` com `Status: OK` e, no modo
      `_R_CHECK_CRAN_INCOMING_ = "true"`, `Status: 1 NOTE` idêntico ao da linha
      de base. O `check` mostra `creating vignettes ... OK`,
      `checking files in 'vignettes' ... OK` e
      `checking re-building of vignette outputs ... OK`. O HTML gerado pelo
      render foi apagado; só o `.Rmd` entra no commit.
18. **(concluída) `_pkgdown.yml` com publicação no GitHub Pages**.

    **Implementação — entrega de 2026-09-20.**
    - **`_pkgdown.yml` escrito à mão**, não gerado por
      `usethis::use_pkgdown_github_pages()`: o `usethis` 3.1.0 instalado aqui não
      traz os modelos de workflow do GitHub (`system.file("templates", "github",
      package = "usethis")` devolve vazio) e o ajudante ainda mexe em
      configuração do repositório como efeito colateral. O arquivo define
      `url: https://distintivelab.github.io/transfRgov/`, `lang: pt`,
      `template: bootstrap: 5` e uma `navbar` com o rótulo `Início`.
    - **O índice de referência tem nove grupos temáticos** em português
      (transferências mensais, despesas e renúncias, programas, empenhos, planos
      de ação, termos de adesão, relatórios de gestão, gestão financeira e
      metadados) e cobre os 27 objetos exportados mais os dois conjuntos de dados
      (`municipios_siafi_ibge` e `metafaftab`). A conferência é o próprio
      `build_site()`, que fecha com `✔ Reference metadata ok`: qualquer entrada
      de `contents:` que não resolvesse viraria aviso ali.
    - **A vignette do item 17 entra no site sozinha**: não foi preciso bloco
      `articles:` porque o `pkgdown` descobre `vignettes/`; o artigo saiu em
      `docs/articles/transfRgov.html` e o `build_site()` fecha com
      `✔ Articles metadata ok`.
    - **`DESCRIPTION` ganhou a URL publicada**: a linha `URL:` passou a ter duas
      entradas, o repositório e `https://distintivelab.github.io/transfRgov`. Sem
      isso o `build_site()` acusava `✖ URLs not ok / In DESCRIPTION, URL is
      missing package url`; agora o `✔ URLs ok` fecha a verificação. O campo
      `Description:` não foi refluído de propósito, porque o `NOTE` de ortografia
      do CRAN cita posições `linha:coluna` dentro dele.
    - **O defeito que motivou o trabalho de verdade: o `pkgdown` publica todo
      `*.md` da raiz.** O `pkgdown:::package_mds()` varre `*.md` da raiz e de
      `.github/` e exclui apenas uma lista fixa em código (`README`, `LICENSE`,
      `LICENCE`, `NEWS`, `404`, `issue_template`, `pull_request_template`,
      `cran-comments`). O `.Rbuildignore` **não é consultado em ponto nenhum** do
      `pkgdown`, então `AGENTS.md` e `ROADMAP.md` saíram como `docs/AGENTS.html` e
      `docs/ROADMAP.html` e entraram no índice de busca (o relato público
      `gcol33/tulpa#402` mostra que o arquivo de instruções para agentes passa a
      ser o primeiro item do `search.json`). Não existe opção de configuração: o
      pedido `r-lib/pkgdown#2959` está aberto e o `#2971`, que propõe um
      `.pkgdownignore`, não foi mesclado.
    - **A correção é mover os dois arquivos para fora da raiz durante o build e
      devolvê-los depois**, com asserção de que as páginas não saíram. Localmente
      foi um comando só (`mv AGENTS.md ROADMAP.md` para `/tmp`, `build_site()`,
      `mv` de volta) e no CI o workflow usa `$RUNNER_TEMP` mais um passo que falha
      se `docs/AGENTS.html`, `docs/ROADMAP.html` ou `docs/cran-comments.html`
      existirem. Depois da reconstrução limpa,
      `ls docs/AGENTS.html docs/ROADMAP.html` não encontra nada e
      `grep -c "AGENTS\|ROADMAP" docs/search.json docs/sitemap.xml` devolve zero
      (o arquivo gerado é `sitemap.xml`, sem o prefixo `docs/` dentro da pasta).
    - **O workflow `.github/workflows/pkgdown.yaml` foi derivado do exemplo
      canônico do `r-lib/actions` v2** e se afasta dele em exatamente dois
      pontos: o emoji do nome do passo de publicação foi removido (regra do
      projeto) e os dois passos de esconder e verificar os documentos de
      desenvolvimento foram acrescentados. A publicação usa
      `JamesIves/github-pages-deploy-action` fixada por SHA, no ramo `gh-pages`.
    - **A publicação segue a opção (a)**: Actions publicando no ramo `gh-pages`.
      O mecanismo foi executado no mesmo dia e está no ar. O primeiro push do
      workflow disparou a execução `35539527146`, que fechou `completed success`
      na primeira tentativa, e criou o ramo `gh-pages` no commit `fd816e6`. O
      Pages foi habilitado pela linha de comando com
      `gh api -X POST repos/DistintiveLab/transfRgov/pages -f 'source[branch]=gh-pages' -f 'source[path]=/'`,
      cuja resposta traz `build_type: legacy`, `public: true` e
      `https_enforced: true`; o build `1228272698` fechou `built`.
    - **O escopo `workflow` já estava no token do `gh`.** A suposição de que
      seria preciso `gh auth refresh -s workflow` estava errada: `gh auth status`
      mostra `admin:public_key`, `gist`, `read:org`, `repo` e `workflow`, e o
      workflow foi enviado sem nenhum passo adicional. Isso já destrava o item 22.
    - **O site responde em `https://distintivelab.github.io/transfRgov/`**: a raiz
      devolve 200 com o `README` em português e o rodapé do `pkgdown`, o índice de
      referência mostra os nove grupos na ordem prevista, e
      `articles/transfRgov.html` está publicado. O mesmo teste confirma o
      vazamento selado em produção: `AGENTS.html` e `ROADMAP.html` respondem
      404 e um `grep -o "AGENTS\|ROADMAP"` sobre `search.json` e `sitemap.xml` do
      ramo publicado não devolve nada. A homepage do repositório passou a apontar
      para o site com `gh repo edit DistintiveLab/transfRgov --homepage`.
    - **O CI resolveu `pkgdown` 2.2.1**, mais novo que o 2.1.1 instalado aqui, e
      o site publicado não é byte-idêntico ao `docs/` local: a versão nova publica
      um `llms.txt` na raiz e copia o próprio `pkgdown.yml` para dentro do site.
      Nada disso quebra o build, mas quem comparar as duas saídas precisa saber da
      diferença de versão.
    - **Build local limpo**: `pkgdown::build_site()` com `EXIT:0` e as cinco
      linhas do relatório final em `✔` (URLs, favicons, metadados de open graph,
      metadados de artigos e metadados de referência). O `docs/` gerado tem 81
      arquivos e cerca de 3,9 MB e continua fora do controle de versão, pela
      entrada `docs/` no `.gitignore` e `^docs$` no `.Rbuildignore`.
    - **`pkgdown/` (conjunto de favicons) entra no repositório**: é o original
      reproduzível dos ícones do site e já está excluído do build por
      `^pkgdown$` no `.Rbuildignore`, como recomenda a própria ajuda de
      `build_favicons()`.
    - **Dois `NOTE`s novos de `R CMD check` apareceram na primeira rodada e foram
      fechados**: o diretório `.github` e o `_pkgdown.yml` não eram conhecidos
      pelo `R CMD check` (mensagens "hidden files and directories" e
      "Non-standard file/directory found at top level"). Ambos entraram no
      `.Rbuildignore` (`^\.github$` e `^_pkgdown\.yml$`), que é justamente o que
      `usethis::use_pkgdown()` faz.
    - **Verificação**: os cinco gates. `devtools::document()` sem diferença,
      `devtools::test()` com `FAIL 0 | WARN 0 | SKIP 0 | PASS 476` (inalterado),
      gate ASCII com 0 ofensas em 30 arquivos `R`, auditoria dos `\arguments`
      com 26 de 26, e `devtools::check(args = "--as-cran")` de volta a
      `Status: OK`, com o modo `_R_CHECK_CRAN_INCOMING_ = "true"` mantendo
      `Status: 1 NOTE` e as mesmas nove palavras nos mesmos `linha:coluna` da
      linha de base.
    - **`AGENTS.md` foi corrigido**: a frase que dizia não haver configuração de
      CI deixou de valer quando o workflow entrou, e a organização do código
      ganhou o item do `_pkgdown.yml`.
19. **(concluída) `\dontrun{}` para `\donttest{}` nos exemplos que dependem de
    rede**, conforme preferência do CRAN.

    **Implementação — entrega de 2026-09-20.**
    - **A premissa do item estava errada em um ponto decisivo**:
      `R CMD check --as-cran` **liga o `--run-donttest`**. A lista de bandeiras de
      `R CMD check --help` mostra `--run-donttest` como opção separada, e daí se
      concluiu que ela não roda por omissão; a primeira rodada da troca integral
      provou o contrário, com `checking examples with --run-donttest ... ERROR`.
      A troca **não** é inócua: ela passa a executar os exemplos de rede dentro do
      gate 5, e portanto dentro do `check` que o CRAN roda.
    - **A troca foi feita em 21 arquivos, não nos 24**: os três que sobraram não
      podem rodar de jeito nenhum e por isso mantêm `\dontrun{}`, que é
      exatamente o marcador prescrito para esse caso. São
      `R/ler_empenho_especial.R` e `R/ler_programas_especiais.R`, que chamam as
      tabelas do defeito 404 adiado pela decisão (d), e
      `R/ler_renuncias_ptransp.R` (define `consultar_renuncias_fiscais()`), cujo
      exemplo depende de `PORTAL_TRANSPARENCIA_API_KEY`, uma credencial que nunca
      existiu neste ambiente. Contagem final: **21 `\donttest{}` e
      3 `\dontrun{}`** em `R/`.
    - **A primeira rodada integral devolveu `Status: 1 ERROR`** e identificou o
      caso: `ler_empenho_especial()` responde HTTP 404, o mesmo defeito já
      registrado. Depois de devolver os três arquivos a `\dontrun{}`, o gate
      voltou a `Status: OK` com `checking examples with --run-donttest ... OK` em
      21,7 s: **os 21 exemplos rodaram de verdade contra a API pública e
      passaram**.
    - **Os dois `@examples` sem guard não foram tocados**: `R/metafaftab.R` e
      `R/municipios_siafi_ibge.R` usam só dados embarcados e já rodam no `check`.
    - **`devtools::document()` regenerou 21 `.Rd`** e o `NAMESPACE` ficou
      intocado, porque guard de exemplo não mexe em export.
    - **Verificação**: `devtools::document()` sem diferença, `devtools::test()`
      com `FAIL 0 | WARN 0 | SKIP 0 | PASS 476` (inalterado), gate ASCII com
      0 ofensas em 30 arquivos `R`, auditoria dos `\arguments` com
      `OK: 26 Rd \arguments sections exactly match formals`, `check --as-cran`
      com `Status: OK` e o modo `_R_CHECK_CRAN_INCOMING_ = "true"` mantendo
      `Status: 1 NOTE` com as mesmas nove palavras da linha de base.
20. **(concluída) Tornar o `metafaftab` mais útil**: hoje é uma lista crua de
    caminhos para parâmetros; um acessor que liste endpoints e campos legíveis
    melhora a descoberta.

    **Implementação — entrega de 2026-09-20.**
    - **O acessor é `campos_metafaftab()`**, em `R/campos_metafaftab.R`, e entrou
      no grupo "Metadados" do `_pkgdown.yml`, logo depois do `metafaftab`. Com
      `endpoint = NULL` (o padrão) devolve um `data.frame` de três colunas —
      `endpoint`, `campo` e `controle` — cobrindo os 21 endpoints; com um
      `endpoint` informado, devolve só o vetor de campos daquele endpoint, na
      ordem em que aparecem no conjunto de dados. O caminho pode ser escrito com
      ou sem a barra inicial (`"programa"` e `"/programa"`).
    - **A classificação dos parâmetros de controle não era a suposta.** A leitura
      inicial reconhecia quatro nomes (`select`, `order`, `limit`, `offset`) e
      chegava a 260 campos. Uma sondagem direta sobre `data/metafaftab.rda`
      mostrou **sete controles por endpoint**: os seis fixos `order`, `range`,
      `rangeUnit`, `offset`, `limit` e `preferCount`, presentes nos 21 endpoints,
      mais um `select` de cada endpoint. São **147 linhas de controle** das 425
      totais, sobrando **278 campos verdadeiros**, que correspondem a **255 nomes
      únicos** porque alguns campos se repetem entre endpoints
      (`id_plano_acao` aparece em 9).
    - **O `select` não é uniforme, e por isso a classificação não pode ser um
      `%in%` global**: 19 endpoints expõem `select` puro, `/plano_acao` expõe
      `select_plano_acao` e `/relatorio_gestao_analise` expõe
      `select_relatorio_gestao_analise`. A coluna `controle` sai de uma chave
      composta `endpoint|campo`, e a função interna `controles_postgrest()`
      (marcada `@noRd`, no padrão dos auxiliares de `R/utils-pg_get.R`) monta a
      lista de cada endpoint.
    - **Alternativa rejeitada**: regravar `data/metafaftab.rda` em uma estrutura
      mais rica. Isso mudaria um objeto documentado, o `@format` e os testes, o
      que é mais do que "acrescentar um acessor"; o `metafaftab` seguiu intacto.
    - **Nenhuma dependência nova.** O retorno é `data.frame` da base e o teste é
      `testthat` puro, então `DESCRIPTION` não mudou. O nome ficou de fora do
      prefixo `ler_`/`get_` de propósito, para não entrar na lista de 23 leitores
      que `test-leitores.R` confere.
    - **Um `NOTE` novo apareceu e foi fechado.** O primeiro `check --as-cran`
      acusou `campos_metafaftab: no visible binding for global variable
      'metafaftab'`, porque o conjunto de dados era lido pelo nome nu dentro da
      função. A correção segue o precedente já existente em
      `R/ler_transferencias_ptransp.R`:
      `get("metafaftab", envir = asNamespace("transfRgov"))`. Depois disso o
      gate 5 voltou a `Status: OK`.
    - **Verificação**: os cinco gates. `devtools::document()` sem diferença,
      `devtools::test()` com `FAIL 0 | WARN 0 | SKIP 0 | PASS 566` (eram 476; o
      arquivo novo — sete blocos `test_that` — acrescenta 90 expectativas), gate
      ASCII com 0 ofensas em 31 arquivos `R`, auditoria dos `\arguments` com
      `OK: 27 Rd \arguments sections exactly match formals`, e
      `devtools::check(args = "--as-cran")` com `Status: OK`, com o modo
      `_R_CHECK_CRAN_INCOMING_ = "true"` mantendo `Status: 1 NOTE` e as mesmas
      nove palavras da linha de base.
21. **(concluída) Encadear total e detalhe no Portal da Transparência.** O
    mantenedor observou que, na parte de despesas, chegar aos beneficiários
    exatos exige combinar dois arquivos: um traz o total por ordem bancária e o
    outro traz, para cada ordem, os beneficiários.

    **Implementação — entrega de 2026-09-20.**

    - **A junção é uma função separada e offline**, `encadeia_despesas_ptransp()`
      em `R/encadeia_despesas_ptransp.R`: recebe os dois data frames já baixados
      e devolve o encadeamento. A alternativa de fazer o próprio
      `download_despesas_ptransp()` baixar os dois membros e juntá-los foi
      rejeitada porque quebraria o contrato de um artefato por chamada
      (registrado no item 13), baixaria e descompactaria o mesmo ZIP duas vezes
      e seria muito mais difícil de testar sem rede.
    - Assinatura: `encadeia_despesas_ptransp(total, detalhe, chave =
      "codigo_pagamento", somente_detalhados = FALSE)`. O padrão devolve
      **todas** as linhas de `total`, porque o detalhamento cobre cerca de 1%
      das ordens e esconder o resto enganaria; `somente_detalhados = TRUE` é a
      forma de junção interna. A mesma chamada aceita o par `empenho` ×
      `item_empenho` passando `chave = "id_empenho"`.
    - O resultado é `merge(..., by = chave, all.x = !somente_detalhados,
      sort = FALSE, suffixes = c(".total", ".detalhe"))` mais três toques: uma
      coluna lógica `detalhado` **inserida logo depois de `chave`** (não no
      fim), `rownames` zerado e um `warning()` quando os dois lados têm linhas
      mas nenhuma chave casa. `detalhe` com zero linhas **não é erro**: as
      colunas de detalhe saem `NA` e `detalhado` sai `FALSE`.
    - **A validação é toda local, inclusive a do tipo da chave.** Uma sondagem
      direta mostrou que `merge()` casa `"1"` com `1` em silêncio e que uma
      chave ausente estoura com a mensagem localizada do R (`'by' deve
      unicamente especificar coluna válida`). Por isso a função confere presença
      e classe da chave nos dois data frames antes de chamar `merge()`;
      `integer` × `double` é aceito, `factor` × `character` é recusado.
    - As medições que motivaram a junção já estão registradas no item 13
      (2024-01-15: 14.949 ordens, 162 com detalhe, 99 com mais de um favorecido,
      `max |total - soma|` de `3,6e-12` e cobertura de 1,1%). A função **não**
      compara os valores: as colunas de valor não têm o mesmo nome
      (`valor_do_pagamento_convertido_pra_r` contra `valor_do_pagamento_em_r`).
    - **A afirmação de 2026-09-20 no item 13 não vale mais.** O texto dizia que
      o encadeamento total/detalhe "não é feito automaticamente"; ele agora é
      feito por `encadeia_despesas_ptransp()`, e o `@details` de
      `download_despesas_ptransp()` aponta para a função nova.
    - **Nenhuma dependência nova**: só base, então `DESCRIPTION` não mudou — e a
      versão fica em `0.1.1`, já na fila do CRAN. O nome fica fora de
      `^(ler_|get_)` pelo mesmo motivo de `download_despesas_ptransp()`:
      preservar as 23 funções que `test-leitores.R` confere. Exportações passam
      de 27 para **29**, contando as duas entregas (`campos_metafaftab()`, do
      item 20, e esta).
    - **O `@description` de `campos_metafaftab()` foi corrigido no mesmo
      commit**: ele anunciava "uma tabela de duas colunas", quando o `@return` e
      a implementação entregam três (`endpoint`, `campo` e `controle`).
    - O exemplo da função roda **sem guard**, como os de `metafaftab`,
      `municipios_siafi_ibge` e `campos_metafaftab`, porque só monta data frames
      em memória. O placar de guards vira **21 `\donttest{}` / 3 `\dontrun{}` /
      4 sem guard**.
    - Testes novos em `tests/testthat/test-encadeia_despesas_ptransp.R`: 11
      blocos e 56 asserções, todos **offline** com data frames feitos à mão (o
      `cache/` não guarda nada de despesas, justamente porque o host limita
      rajadas). A suíte vai de 566 para **622** asserções.
    - **Verificação**: os cinco gates. `devtools::document()` sem diferença,
      `devtools::test()` com `FAIL 0 | WARN 0 | SKIP 0 | PASS 622`, gate ASCII
      com 0 ofensas em 32 arquivos `R` (538 literais), auditoria dos `\arguments`
      com `OK: 28 Rd \arguments sections exactly match formals`, e
      `devtools::check(args = "--as-cran")` com `Status: OK`, com o modo
      `_R_CHECK_CRAN_INCOMING_ = "true"` mantendo `Status: 1 NOTE` e as mesmas
      nove palavras da linha de base.

## Fase 6 — Infraestrutura e limpeza

22. **(concluída) Integração contínua**: criar
    `.github/workflows/R-CMD-check.yaml` rodando
    `devtools::check(args = "--as-cran")`. O diretório `.github/` já existe
    desde o item 18, que colocou ali o workflow de publicação do site.

    **Implementação — entrega de 2026-09-20.**

    - **O arquivo `.github/workflows/R-CMD-check.yaml` foi derivado do exemplo
      canônico `check-standard.yaml` do `r-lib/actions` v2**, a mesma
      procedência que o mantenedor já aceitou para o `pkgdown.yaml`, com o
      comentário de origem preservado no cabeçalho. Os passos são os de sempre:
      `actions/checkout@v6`, `setup-pandoc@v2`, `setup-r@v2`,
      `setup-r-dependencies@v2` com `extra-packages: any::rcmdcheck` e
      `needs: check`, e `check-r-package@v2`. Nada de `rcmdcheck` em `Suggests`:
      quem instala é a ação.
    - **Os gatilhos são `push` em `main`/`master` e `pull_request`**, os dois do
      exemplo. O item **não** responde a `release: [published]` nem a
      `workflow_dispatch`, ao contrário do `pkgdown.yaml`: a publicação do site
      precisa ser reprodutível sob demanda e a cada release, enquanto o check
      é o mesmo em qualquer um dos dois eventos. Se depois fizer falta disparar
      à mão, é uma linha a mais.
    - **O desvio deliberado em relação ao exemplo canônico é a matriz de uma
      linha só** (`ubuntu-latest` com `r: 'release'`, contra as cinco do
      `check-standard.yaml`). O motivo é a postura de rede registrada no item
      19: os 21 exemplos em `\donttest{}` vão à API pública do TransfereGov, e
      cada plataforma a mais multiplica a exposição a uma queda de rede e ao
      limitador de rajadas dos hosts do governo (as sondagens ao host de
      arquivos da CGU precisam ficar a pelo menos 20 s uma da outra). A receita
      para reabrir a cobertura está escrita no próprio cabeçalho do arquivo,
      com as linhas exatas de `macos-latest`, `windows-latest`, `devel` e
      `oldrel-1`, para a escolha ser reversível sem pesquisa.
    - **`error-on: '"warning"'` é passado à mão, embora seja o padrão da ação.**
      É o mesmo critério que o `devtools::check()` escolhe sozinho quando a
      sessão não é interativa, e escrevê-lo deixa a postura estrita visível no
      arquivo em vez de herdada em silêncio: qualquer `WARNING` derruba o job,
      qualquer `NOTE` não. Nada de `args:` foi sobrescrito, porque o padrão da
      ação já é `c("--no-manual", "--as-cran")`, exatamente o comando do item
      mais o `--no-manual` que o ambiente local também usa.
    - **O job reproduz o gate 5 local, não o 5b.** A ação zera
      `_R_CHECK_FORCE_SUGGESTS_` e `_R_CHECK_CRAN_INCOMING_` quando eles não
      vêm definidos, então o `NOTE` de ortografia do incoming não é emitido e o
      desfecho esperado é `Status: OK`, não `Status: 1 NOTE`. A suposição do
      item 19 de que `--as-cran` liga o `--run-donttest` continua valendo, e é
      o que se quer: são justamente os 21 exemplos com rede que dão sentido a
      rodar o check completo no CI.
    - **O bloco `concurrency:` foi acrescentado à mão, porque nenhum exemplo do
      `r-lib/actions` tem um.** Sem ele os dois workflows, que disparam nos
      mesmos eventos (`push` em `main`/`master` e `pull_request`), entrariam no
      mesmo grupo e um cancelaria o outro. O grupo é
      `R-CMD-check-${{ github.event_name != 'pull_request' || github.run_id }}`,
      o mesmo formato do `pkgdown.yaml` com o nome trocado.
    - `upload-snapshots: true` e o `build_args` canônico
      (`c("--no-manual","--compact-vignettes=gs+qpdf")`) foram mantidos do
      exemplo. O pacote não tem snapshots do `testthat`, então o primeiro é
      inerte, mas mantém o arquivo colado na referência.
    - **Nenhuma mudança de build e nenhuma mudança em `DESCRIPTION`**: o
      `^\.github$` já está no `.Rbuildignore` desde o item 18 e a versão fica em
      `0.1.1`, já na fila do CRAN.
    - **Verificação**: o YAML foi lido por um analisador (`yaml.safe_load`) e as
      chaves de topo, o bloco de `concurrency`, a matriz e a lista de passos
      bateram com o desenho acima; o gate local
      `devtools::check(args = "--as-cran", error_on = "never")` fechou
      `Status: OK` contra o mesmo código do commit anterior, sem tocar em
      `R/`.
    - **O primeiro `push` disparou a execução 35548685388**, que fechou
      `completed success` em 2m17s, com `* checking examples with
      --run-donttest ... OK` e `Status: OK`, isto é, confirmou no CI a previsão
      de que a ação zera o check de incoming e o desfecho é `OK`, e não
      `Status: 1 NOTE`. O `pkgdown.yaml` disparou no mesmo `push` (execução
      35548685452) e fechou `success` em 2m3s, sem que um cancelasse o outro: o
      bloco `concurrency:` cumpriu o papel para o qual foi escrito.
23. **(concluída) `lintr` e `styler`**: criar a configuração de lint do
    repositório e decidir sobre o formatador automático.

    **Implementação — entrega de 2026-09-20.**

    - **Não havia nenhuma configuração de lint no repositório**, e o `lintr`
      3.2.0 (instalado na biblioteca do sistema, em
      `/usr/lib/R/site-library/lintr`) rodava a lista padrão inteira sobre o
      pacote como um todo. A medição inicial, feita com
      `parse_settings = FALSE` para ignorar qualquer configuração, deu **1271
      avisos**: `line_length_linter` 815, `object_length_linter` 146,
      `commas_linter` 131, `infix_spaces_linter` 82, `object_usage_linter` 25,
      `quotes_linter` 17, `brace_linter` 15, `indentation_linter` 9,
      `paren_body_linter` 8, `commented_code_linter` 7, `return_linter` 6,
      `T_and_F_symbol_linter` 4, `object_name_linter` 2,
      `pipe_continuation_linter` 2, `spaces_left_parentheses_linter` 1 e
      `trailing_blank_lines_linter` 1. Desse total, **292 estavam em
      `data-raw/`** e **979 no resto do pacote**.
    - **O `lintr` resolve o `object_usage_linter` contra o pacote
      INSTALADO**, não contra a árvore de trabalho. Com a instalação anterior
      defasada, a primeira leitura marcava 1296 avisos, 50 deles de uso de
      objeto; depois de `devtools::install()` os mesmos números caíram para
      1271 e 25. **Toda medição passou a ser precedida de uma reinstalação**, e
      a linha de base registrada é a de 1271.
    - **O diretório `data-raw/` foi excluído por inteiro.** É código de
      preparação de dados, está no `.Rbuildignore` desde antes e nunca roda sob
      `R CMD check`, de modo que os seus 292 avisos não têm relação com o que o
      check enxerga. A exclusão é uma string solta na chave `exclusions` do
      `.lintr`, que é a forma que o próprio `lintr` documenta para excluir um
      diretório inteiro.
    - **No resto do pacote o conjunto mecânico era de 31 avisos: 29 corrigidos
      por edição e 2 dispensados por exclusão de arquivo.** As correções foram
      indentação em `R/campos_metafaftab.R` (linha 66),
      `R/encadeia_despesas_ptransp.R` (95),
      `R/ler_gestao_financeira_categorias_despesa.R` (37),
      `R/ler_gestao_financeira_subtransacoes.R` (57), `R/ler_programas.R` (66)
      e `R/ler_transferencias_ptransp.R` (148); `return_linter` em
      `R/baixa_municipio_siafibge.R` (59 e 86),
      `R/download_despesas_ptransp.R` (117 e 163) e
      `R/ler_transferencias_ptransp.R` (66 e 114); aspas e vírgulas em
      `R/baixa_municipio_siafibge.R` (41 e 43); código comentado morto nas
      linhas 74 a 83 e 89 a 93 do mesmo arquivo; o espaço de infixo nas linhas
      99 e 111 de `R/ler_transferencias_ptransp.R`; e a linha em branco final
      de `R/ler_programas_especiais.R`. **Nada foi renomeado**: os dois avisos
      de `object_name_linter` são o argumento `stringsAsFactors` dos mocks de
      `mockery::stub` em `tests/testthat/test-renuncias_e_siafibge.R` (linhas
      237 e 257), que precisa manter a grafia, e por isso o arquivo inteiro
      entra em `exclusions`.
    - **O `object_length_linter` foi elevado do padrão de 30 para 64
      caracteres.** O limite padrão era o único motivo dos 146 avisos, e
      reduzi-lo não era opção: os nomes vêm da própria API. Medido de duas
      formas independentes, `unique(unlist(metafaftab))` sobre o dataset
      empacotado (264 nomes de campo) e os tokens `SYMBOL` de
      `utils::getParseData()` sobre os arquivos de `R/` (384 símbolos),
      **o identificador mais longo tem exatamente 63 caracteres**: 46 passam de
      40, 22 passam de 50, 4 passam de 60 e nenhum passa de 70. Os dois nomes de
      63 caracteres são truncados pela própria especificação da API e **não são
      renomeáveis**. Com o limite em 64 o linter continua ativo e com zero
      avisos hoje, pronto para pegar um nome longo escrito à mão amanhã.
    - **O `object_usage_linter` foi zerado com um arquivo novo e uma exclusão de
      linha.** Dos 25 avisos originais, 11 eram de `data-raw/` e saíram junto
      com o diretório, deixando 14: 12 nos chunks da vinheta
      `vignettes/transfRgov.Rmd` e 2 em `tests/testthat/test-leitores.R` (82 e
      84). O novo `R/zzz.R` declara com um único `utils::globalVariables()` as
      oito colunas usadas por avaliação não padrão na vinheta e nos scripts de
      análise, e **os 12 avisos da vinheta sumiram**; os 2 restantes são os
      ajudantes `mock_capturando_urls` e `sem_avisos`, definidos em
      `tests/testthat/helper-httr2.R`, que o linter não enxerga ao examinar o
      arquivo de teste isolado, e por isso são dispensados por
      `"tests/testthat/test-leitores.R" = list(object_usage_linter = c(82L, 84L))`.
    - **O único linter que sobra é o `line_length_linter`, com 93 avisos**, do
      limite de 120 caracteres. São 22 linhas de roxygen e 71 de código, e
      **todas as 71 são listas de campos `select=` de PostgREST**, isto é,
      nomes de coluna da API concatenados num argumento só; quebrá-las exigiria
      inventar apelidos e mudaria o contrato do pacote. A linha mais longa tem
      198 caracteres (`R/ler_renuncias_ptransp.R:30`), 48 passam de 130, 36
      passam de 140 e 13 passam de 160. O limite de 120 é o ponto de equilíbrio:
      em 80 haveria 703 linhas de `R/` marcadas, quase metade delas prosa de
      roxygen, que nenhum formatador reescreve.
    - **O `styler` não foi executado.** Ele não está instalado, e uma passagem
      completa reescreveria centenas de linhas, invalidando a linha de base do
      gate de check e misturando formatação com a correção de lint num commit
      só. A decisão fica registrada aqui como não executada, para ser retomada
      à parte se o mantenedor quiser.
    - **O arquivo `.lintr` é DCF, não YAML, e por isso não tem comentário
      nenhum.** O `read.dcf` não entende uma linha começando com `#`: no topo
      do arquivo ela vira um campo fantasma que engole a linha seguinte, e no
      meio ela aborta a leitura com "Linha começando com '#' está mal formada!".
      Toda a justificativa mora aqui e em `AGENTS.md`, e o `.lintr` fica só com
      as duas chaves, `linters` e `exclusions`. A configuração mantém os 25
      linters padrão ativos, eleva `line_length_linter` para 120 e
      `object_length_linter` para 64 e declara as três exclusões.
    - **O `.lintr` não entra no tarball**: a linha `^\.lintr$` foi acrescentada
      ao `.Rbuildignore`, ao lado da `^\.crush$`. Sem isso o arquivo iria para
      dentro do `R CMD check` e poderia mexer no desfecho dos gates 5 e 5b.
    - **A cláusula sobre lint do `AGENTS.md` foi reescrita** para descrever o
      `.lintr`, a restrição de não ter comentários, os dois limites elevados e
      as três exclusões, no lugar da frase que dizia não haver configuração
      nenhuma.
    - **Verificação**: os gates rápidos e lentos fecharam como antes, sem
      nenhum efeito no build. O `devtools::document()` foi um no-op puro
      (`EXIT:0`, nenhuma linha `Writing`, `man/` com os mesmos 31 `.Rd` e
      `git status man/` vazio). O `devtools::test()` fechou
      `FAIL 0 | WARN 0 | SKIP 0 | PASS 622` em 2,7 s, com as 22 expressões
      adiadas rodadas. O gate de ASCII fechou
      `OK: 0 offenders across 33 R files (546 string literals scanned)`: o
      arquivo a mais é o `R/zzz.R` e as oito strings a mais são as suas
      variáveis globais, todas ASCII, sem regressão. A auditoria de
      `\arguments` fechou `OK: 28 Rd \arguments sections exactly match
      formals`. O `devtools::check(args = "--as-cran", error_on = "never")`
      fechou `Status: OK`, e a variante com `_R_CHECK_CRAN_INCOMING_ = "true"`
      fechou `Status: 1 NOTE`, com o aviso de ortografia das nove palavras do
      `DESCRIPTION` exatamente nas mesmas colunas de antes.
24. **Lastro local**: `data/` guarda cerca de 176 MB que não são dados do pacote
    e há um `201901_Transferencias.csv` de cerca de 46 MB na raiz. Ambos já estão
    excluídos do build, mas seguem dentro do diretório do pacote; decidir se
    saem para um diretório de análise fora do repositório.

## Itens que exigem aprovação explícita

Renomeações esbarram nas convenções registradas em `AGENTS.md`:
`baixa_municipio_siafibge` (grafia intencional), a grafia `fundoafundo` da API e
os oito descompassos intencionais entre nome de arquivo e nome de função
(por exemplo `R/ler_plano_acao.R` define `get_plano_acao`). Nada disso deve ser
normalizado sem consulta. O mesmo vale para a URL em `R/metafaftab.R:31-34`, que
hoje aparece em `\code{}` de propósito: como o servidor responde 403 a `HEAD`,
promovê-la a `\url{}` reintroduz o aviso de verificação de URLs do CRAN.

Também exige decisão, e por isso ainda não foi corrigido, o defeito descrito no
item 14: `ler_empenho_especial()` e `ler_programa_especial()` consultam as
tabelas `empenho_especial` e `programa_especial`, que respondem 404. A
investigação de 2026-09-20 mostrou que essas tabelas não existem em nenhuma
grafia, que a especificação OpenAPI só publica os 21 endpoints do `metafaftab` e
que nenhum campo separa registros "especiais" de forma limpa (o melhor candidato
é `empenho.tipo_empenho == 3`, com 2 linhas em 4.248). Além disso, parte dos
parâmetros das duas funções não corresponde a nenhuma coluna real. As
alternativas são: (a) reapontar para `empenho`/`programa` com um filtro de
"especial" e retirar os parâmetros inexistentes, o que muda assinatura e exige
versão 0.x.0; (b) descontinuar ou remover as duas funções; (c) mantê-las
documentadas como defeituosas. Nenhuma dessas alternativas deve ser tomada sem
aval do mantenedor. **Em 2026-09-20 o mantenedor optou por adiar a decisão
(alternativa (d)): a evidência fica registrada e as duas funções permanecem
como estão, sem correção e sem descontinuação.**

## Ordem sugerida de versões

- **0.2.0** — Fase 1 (itens 1 a 5) e Fase 2 (itens 6 a 10). Sem quebra de
  assinatura; lançamento de correção. Já concluídos e ainda não lançados, viajam
  junto o item 12 (documentação), o item 14 (testes) e o item 15 (cassettes do
  `vcr`), pois nenhum dos três altera assinatura de função.
- **0.3.0** — Fase 3 (item 13, provedor CGU, conjunto `despesas`) e Fase 4
  (item 16). Se a correção do defeito 404 for a alternativa (a), com mudança de
  assinatura, ela entra aqui. O mantenedor optou por adiar essa decisão.
- **0.4.0** — Fases 5 e 6.
