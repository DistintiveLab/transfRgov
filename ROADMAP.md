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
| Bases irmãs no mesmo host | `parcerias`, `emendas`, `convenios`, `transferencias`, `propostas` respondem 404 |

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

## Fase 2 — Robustez de transporte

5. **Retry, timeout e backoff** (`R/utils-pg_get.R:76`). Hoje é um
   `httr::GET()` seco, sem timeout e sem repetição. Avaliar migração para
   `httr2` (`req_retry()`, `req_timeout()`), o que exige alterar `Imports:` em
   `DESCRIPTION`.
6. **Classe de condição estruturada** no lugar do `warning()` cru de
   `R/utils-pg_get.R:85`, permitindo `tryCatch()` por classe no chamador.
7. **User-Agent identificando o pacote**.
8. **Passagem de `select` e `order`** aos leitores, ambos comprovadamente
   suportados, o que reduz tráfego em endpoints com mais de 30 colunas.
9. **Cache em disco opcional**, formalizando o diretório `cache/` já usado nas
   análises.

## Fase 3 — Novas inclusões

10. **Nenhum endpoint novo na API Fundo a Fundo**: os 21 endpoints do
    `metafaftab` já possuem leitor (verificado). Registrar isso para evitar
    trabalho duplicado.
11. **Outros provedores**, já que a API do TransfereGov não expõe bases irmãs
    (todas respondem 404):
    - **Portal da Transparência**: hoje só `renuncias-valor`
      (`R/ler_renuncias_ptransp.R:34`). Candidatos: despesas, favorecidos,
      contratos, servidores.
    - **Tesouro Transparente / CKAN**: hoje só `tabmun.csv`
      (`R/baixa_municipio_siafibge.R:16`); o CKAN publica outros conjuntos.
    - **CGU / dados abertos**: `download_transferencias_uniao()` cobre os ZIPs
      mensais; avaliar séries anteriores a 2019.

## Fase 4 — Testes

12. **23 leitores sem teste.** `tests/testthat/` tem dois arquivos e 44
    asserções. Seguir o padrão de `tests/testthat/test-pg_get.R`: chamada nua
    (o `mockery` não intercepta chamadas com `:::`), stub com função simples e
    `cycle = TRUE`.
13. **`vcr` ou `httptest` com cassettes gravadas**, o que permitiria exercitar
    no CRAN os dois testes HTTP hoje marcados com `skip_on_cran()`.
14. **Cobertura ausente:** `consultar_renuncias_fiscais()` e
    `baixa_municipio_siafibge()` não têm nenhum teste.

## Fase 5 — Documentação e usabilidade

15. **Vignette** (não existe `vignettes/`): fluxo "baixar, tratar e consolidar
    por município e função", hoje restrito ao script
    `data-raw/consolida_transferencias_p_funcao_municipio.R`.
16. **`_pkgdown.yml` com publicação no GitHub Pages**.
17. **`\dontrun{}` para `\donttest{}`** nos exemplos que dependem de rede,
    conforme preferência do CRAN.
18. **Tornar o `metafaftab` mais útil**: hoje é uma lista crua de caminhos para
    parâmetros; um acessor que liste endpoints e campos legíveis melhora a
    descoberta.

## Fase 6 — Infraestrutura e limpeza

19. **Integração contínua**: criar `.github/workflows/R-CMD-check.yaml`
    (`.github/` não existe) rodando `devtools::check(args = "--as-cran")`.
20. **`lintr` e `styler`**, hoje sem nenhuma configuração.
21. **Lastro local**: `data/` guarda cerca de 176 MB que não são dados do pacote
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

## Ordem sugerida de versões

- **0.2.0** — Fase 1 (itens 1 a 4) e Fase 2 (itens 5 a 7). Sem quebra de
  assinatura; lançamento de correção.
- **0.3.0** — Fase 3 (item 11) e Fase 4 (itens 12 a 14).
- **0.4.0** — Fases 5 e 6.
