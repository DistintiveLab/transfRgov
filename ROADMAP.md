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
16. **Cobertura ausente:** `consultar_renuncias_fiscais()` e
    `baixa_municipio_siafibge()` não têm nenhum teste.

## Fase 5 — Documentação e usabilidade

17. **Vignette** (não existe `vignettes/`): fluxo "baixar, tratar e consolidar
    por município e função", hoje restrito ao script
    `data-raw/consolida_transferencias_p_funcao_municipio.R`.
18. **`_pkgdown.yml` com publicação no GitHub Pages**.
19. **`\dontrun{}` para `\donttest{}`** nos exemplos que dependem de rede,
    conforme preferência do CRAN.
20. **Tornar o `metafaftab` mais útil**: hoje é uma lista crua de caminhos para
    parâmetros; um acessor que liste endpoints e campos legíveis melhora a
    descoberta.

## Fase 6 — Infraestrutura e limpeza

21. **Integração contínua**: criar `.github/workflows/R-CMD-check.yaml`
    (`.github/` não existe) rodando `devtools::check(args = "--as-cran")`.
22. **`lintr` e `styler`**, hoje sem nenhuma configuração.
23. **Lastro local**: `data/` guarda cerca de 176 MB que não são dados do pacote
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
