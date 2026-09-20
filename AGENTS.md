# AGENTS.md

## Project overview

**transfRgov** is an R package (`Type: Package`, MIT license in DESCRIPTION, GPL-3 claimed in README — see gotchas) that fetches Brazilian federal government transfer data ("Fundo a Fundo") from the TransfereGov API and from Portal da Transparência / Tesouro Transparente open-data downloads.

Everything user-facing (docs, comments, messages, column names) is written in **Brazilian Portuguese (pt-BR)**. New functions/docs should follow that convention. The data is fiscal data on transfers to municipalities (SIAFI/IBGE codes, empenhos, planos de ação, renúncias fiscais).

## Commands

This is a roxygen2 package; there is no Makefile, no CI config, and no lintr config.

```r
devtools::load_all()              # load package code
devtools::document()              # regenerate NAMESPACE + man/*.Rd from roxygen blocks
devtools::test()                  # run tests/testthat
devtools::check()                 # R CMD check equivalent
```

Tests use **mockery** (`mockery::stub`) to stub network calls; `mockery` and `httr` are declared in DESCRIPTION (Suggests/Imports). Stubs must be **plain `function(...)` objects**, never `mockery::mock()` wrappers: a mocked binding only intercepts bare (unqualified) calls inside the target function, so stub call sites with `pg_get(...)`, not `transfRgov:::pg_get(...)`.

## Code organization

- `R/` — one file per endpoint/function (mostly), each with a full roxygen block.
- `data-raw/` — two kinds of scripts, both excluded from build via `.Rbuildignore` (`^data-raw$`):
  - **Dataset prep** (`municipios_siafi_ibge.R`, `metafaftab.R`) — generate packaged datasets via `usethis::use_data()`.
  - **Analysis scripts** (`consolida_transferencias_p_funcao_municipio.R`, `gastos_tributarios.R`) — ad-hoc pipelines that call internal functions with `transfRgov:::` (e.g. `transfRgov:::download_transferencias_uniao(ano, x, municipios_mapping = municipios_siafi_ibge)`), download renúncias ZIPs into `cache/renuncias/`, and pull in many undeclared packages (`data.table`, `tidyr`, `glue`, `archive`, `readxl`, `geobr`, `stringi`, `lubridate`, `ggplot2`). Not runnable as-is without those.
- `data/` — packaged datasets (`municipios_siafi_ibge.rda`, `metafaftab.rda`) plus raw downloaded CSV/XLS/ODS files used for analysis (not part of the built package data).
- `tests/testthat/` — three test files (`test-download_transferencias_uniao.R`, `test-pg_get.R`, `test-leitores.R`) plus `helper-httr2.R`, which holds the helpers the testthat edition 3 loader auto-sources for every test file.
- `cache/` — downloaded intermediate data (siconv zips, renuncias), not tracked by build. `cache/renuncias/` also contains LibreOffice lock files (`.~lock.*.xlsx#`) — leave them alone.
- Repo root: `.RData` (~150 MB) and `.Rhistory` are RStudio session artifacts (gitignored) — never rely on or commit them. Loose CSVs at root (e.g. `201901_Transferencias.csv`) are untracked clutter.

### Filename ≠ function name (gotcha)

The exported function does not always live in the file you'd expect — search by function name, not filename:

| Function | File |
|---|---|
| `consultar_renuncias_fiscais` | `R/ler_renuncias_ptransp.R` |
| `download_transferencias_uniao` | `R/ler_transferencias_ptransp.R` |
| `ler_plano_acao_analise` | `R/plano_acao_analise.R` |
| `ler_plano_acao_analise_responsavel` | `R/plano_acao_analise_responsavel.R` |
| `get_plano_acao_destinacao_recursos` | `R/plano_acao_destinacao_recursos.R` |
| `get_plano_acao` | `R/ler_plano_acao.R` |
| `get_plano_acao_dado_bancario` | `R/ler_plano_acao_dado_bancario.R` |
| `get_plano_acao_historico` | `R/ler_plano_acao_historico.R` |
| `get_termo_adesao` | `R/ler_termo_adesao.R` |
| `ler_programa_especial` | `R/ler_programas_especiais.R` (plural file, singular function) |

## Architecture / two function families

### 1. `ler_*` / `get_*` — TransfereGov API (via internal `pg_get`)

Access the Fundo a Fundo API: `https://api.transferegov.gestao.gov.br/fundoafundo` — **note the spelling "fundoafundo"** (a code comment warns against "fundafundo"; README prose also writes "FundoaFundo"; do not "fix" it).

Pattern (see `R/ler_programas.R`, `R/ler_empenho.R`):

1. Every API column becomes a parameter, all defaulting to `NULL`, named exactly after the API field (`id_plano_acao`, `ano_empenho`, ...).
2. Non-NULL params are appended to a `filters` character vector as `paste0("campo=eq.", valor)` (PostgREST `eq` filter syntax).
3. Single call at the end: `pg_get(table = "<endpoint>", filter = filters, select = select, order = order)`, where `select` and `order` are extra `NULL`-defaulted parameters forwarded verbatim (some functions pass the domain via a `url` variable, others rely on the default).

All parameters are optional. The readers leave pagination and the URL envelope to `pg_get()`.

The HTTP layer lives in `R/utils-pg_get.R` (`pg_encode_filter`, `pg_encode_lista`, `pg_build_url`, `pg_parse_response`, `pg_warning`, `pg_user_agent`, `pg_get`, all `@noRd`). It replaced the former dependency on the non-CRAN `postgrestR` package. Requests are built with **httr2**: `httr2::req_perform()` raises on HTTP errors (no `stop_for_status()` needed), `httr2::req_retry()` repeats only network failures and the 429/503 statuses up to `tentativas` (default 3), `httr2::req_timeout()` enforces `tempo_limite` (default 30 s), and `httr2::req_user_agent()` identifies the package (`pg_user_agent()`, built from `utils::packageVersion()`). `pg_get()` follows `offset` until the last page, and `select`/`order` are passed through on every page. Warnings go through `pg_warning()`, which builds base-R condition classes `transfRgov_unsupported_type` and `transfRgov_partial_result` (no `rlang`). Defaults to `https://api.transferegov.gestao.gov.br/fundoafundo`.

Note that `httr2::resp_body_string()` aborts on an empty body and `jsonlite::fromJSON("")` aborts with `premature EOF`; `pg_get()` and `pg_parse_response()` guard both cases because the API returns an empty body for a query with no rows.

**Naming is inconsistent within this family**: most readers use the `ler_` prefix, but five exported functions use `get_` (`get_plano_acao`, `get_plano_acao_dado_bancario`, `get_plano_acao_historico`, `get_plano_acao_destinacao_recursos`, `get_termo_adesao`) with the identical `eq.`-filter implementation. Don't "normalize" one into the other without asking the maintainer.

The `metafaftab` packaged dataset is a list of API endpoint paths → parameter names, scraped from the API's own OpenAPI spec (`httr::GET("https://api.transferegov.gestao.gov.br/fundoafundo/")` in `data-raw/metafaftab.R`). It can tell you the valid field names for filters.

### Endpoint coverage

All **21** `metafaftab` endpoints already have a reader — check this list before implementing a new one. The `table` values in use: `programa`, `programa_beneficiario`, `programa_gestao_agil`, `plano_acao`, `plano_acao_dado_bancario`, `plano_acao_meta`, `plano_acao_meta_acao`, `plano_acao_destinacao_recursos`, `plano_acao_analise`, `plano_acao_analise_responsavel`, `plano_acao_historico`, `termo_adesao`, `termo_adesao_historico`, `gestao_financeira_lancamentos`, `gestao_financeira_subtransacoes`, `gestao_financeira_categorias_despesa`, `empenho`, `relatorio_gestao`, `relatorio_gestao_acoes`, `relatorio_gestao_analise`, `relatorio_gestao_analise_responsavel`.

Four of the `relatorio_gestao*` readers assign `table <- "..."` on its own line before the call, so grepping for `table = "` finds only 17 distinct endpoints — that is not a missing reader. The Fundo a Fundo API exposes no sibling bases: `parcerias`, `emendas`, `convenios`, `transferencias` and `propostas` all return 404.

### 2. Downloader/scraper functions (Portal da Transparência / Tesouro)

- `download_transferencias_uniao(ano, mes, codigo_ibge = TRUE, municipios_mapping = NULL)` — builds URL `https://dadosabertos-download.cgu.gov.br/PortalDaTransparencia/saida/transferencias/{YYYYMM}_Transferencias.zip`, downloads to a tempfile, unzips, reads the CSV with `read_delim(delim = ";", locale(encoding = "ISO-8859-1", decimal_mark = ","))`, cleans names with `janitor::clean_names()`, and optionally left-joins the SIAFI→IBGE mapping. Returns `invisible(NULL)` (with `warning`) on any failure — **never throws** for download/parse errors. Uses `download.file` (not httr) and `unzip`, both imported from `utils` and called unqualified so tests can stub them. Emits `message()` progress lines on the happy path.
- `baixa_municipio_siafibge()` — downloads `tabmun.csv` from Tesouro Transparente CKAN. Reads codes as character to preserve leading zeros; `codigo_ibge` as numeric. `read_csv2` fallback chain: UTF-8 → Latin1 via base `read.csv`. Note: it names the second column `id`, while the packaged dataset version (from `data-raw/municipios_siafi_ibge.R`) names it `cnpj` — joins rely on `codigo_municipio_siafi`, not that column.
- `consultar_renuncias_fiscais(pagina, uf, codigo_ibge, cnpj, chave_api)` — Portal da Transparência REST API (`/renuncias-valor`), requires API key from env var `PORTAL_TRANSPARENCIA_API_KEY` (hard `stop()` if missing; also throws `httr::stop_for_status` on HTTP errors). Headers: `chave-api-dados`. Parses with `jsonlite::fromJSON`. Uses `\()` (R 4.1+ lambda) syntax. Returns empty `data.frame()` with `warning()` when the query returns nothing.

### Data flow for IBGE mapping

`download_transferencias_uniao(codigo_ibge=TRUE)` with no mapping loads the packaged dataset via `data(municipios_siafi_ibge, overwrite = TRUE)` and joins on `codigo_municipio_siafi` (character, leading zeros) → `codigo_ibge`. `municipios_siafi_ibge.rda` is regenerated by `data-raw/municipios_siafi_ibge.R`. `codigo_ibge` in the mapping is numeric, so after the join it appears as numeric in the result (the test asserts `result$codigo_ibge %in% c(NA, 1100379)`).

## Conventions

- **Documentation**: roxygen blocks in pt-BR with `\describe` listing every parameter. `@export` only; NAMESPACE is generated (`do not edit by hand`).
- **Function style**: base R pipe `|>` is used; `<-` assignment; functions use `return()` explicitly in some files, bare expression at the end in others (both coexist). `\()` lambdas appear in newer code.
- **Parameters**: snake_case, matching the API field names verbatim (e.g. `valor_global_programa`). Values are NOT quoted — text values with spaces (e.g. `"Ordinário"`) must be passed as R strings and are embedded into the `eq.` filter as-is.
- **Naming**: `ler_`/`get_` prefix = read from TransfereGov API; `baixa_`/`download_` = fetch files; `consultar_` = REST API query.
- **Temporary files**: always `tempfile()`, `mode = "wb"` on `download.file`, and `unlink()` cleanup after use (incl. failure paths).
- **CSV encoding**: Portal da Transparência CSVs are `;`-separated, ISO-8859-1, decimal `,`. Always read codes as `col_character()` before joins.
- **Roxygen examples are unreliable**: e.g. the `consultar_renuncias_fiscais` example calls `consultar_renuncias_fiscais(ano = 202301)` but no `ano` parameter exists. Don't trust examples without checking signatures.

## Testing

- Four test files plus `tests/testthat/_vcr/`, 397 passing expectations in total. `tests/testthat/test-download_transferencias_uniao.R` (8 `test_that` blocks / 25 expectations: `ano`/`mes` validation, mocked happy paths with and without the IBGE join, and 4 mocked failure paths — download, unzip, missing CSV, read failure — each asserting `NULL`). `tests/testthat/test-pg_get.R` (25 `test_that` blocks / 83 expectations: pure-function tests for `pg_encode_filter`/`pg_encode_lista`/`pg_build_url`/`pg_parse_response`/`pg_warning`/`pg_user_agent`, plus mocked `pg_get` paths). `tests/testthat/test-leitores.R` (70 `test_that` blocks / 277 expectations: the 23 endpoint readers, data-driven). `tests/testthat/test-cassettes.R` (6 `test_that` blocks / 12 expectations: real recorded API behaviour through `vcr`). Testthat edition 3 via `Config/testthat/edition`.
- `tests/testthat/helper-httr2.R` holds the shared helpers: `resposta_simulada()` (builds an `httr2::response()`), `mock_capturando_urls()` (a mock that records every requested URL, and therefore lets a test assert the URL as well as the result), and `sem_avisos()` (runs an expression with the package's classed warnings muffled). `resposta_simulada()` used to live inside `test-pg_get.R`; do not re-inline it — the loader picks up `helper-*.R` automatically.
- Style: in `test-download_transferencias_uniao.R`, `mockery::stub(func, "name", function(...) ...)`. Pass a **plain function**, never `mockery::mock(...)`: the returned closure has only `...` formals and does not reliably reproduce the wrapped function's return value. A mocked binding is installed into a child environment of the target function, so it only intercepts **bare, unqualified** calls — stub call sites as `pg_get(...)`, not `transfRgov:::pg_get(...)`, or the stub is bypassed. For the same reason `R/ler_transferencias_ptransp.R` calls `download.file`, `unzip`, `read_delim` and `read.csv` unqualified.
- HTTP is mocked with `httr2::local_mocked_responses()` (in `test-pg_get.R`) or `httr2::with_mocked_responses()` (the `executar_leitor()` helper in `test-leitores.R`, which needs the captured URLs back alongside the result), and synthetic answers are built with `httr2::response(status, url =, headers =, body = charToRaw(...))` (`httr:::response()` cannot produce a usable synthetic answer). **A mocked response short-circuits the retry loop inside `httr2::req_perform()`**, so retry behaviour cannot be exercised with mocks — assert the policy instead (`req$policies$retry_max_tries`). Always bound a mock so it eventually returns a short page; an unbounded mock hangs `pg_get()` forever.
- Download stubs must actually create the zip/CSV files in `tempdir()` because the target checks `file.exists()`.
- Tests verify argument validation errors (`expect_error` with a pt-BR message substring) — the `stop()` text is "O parâmetro 'ano' deve ser um inteiro válido representando o ano." and tests match the prefix "O parâmetro 'ano' deve ser um inteiro válido", so keep that prefix stable if you change `stop()` texts.
- `skip_on_cran()` is **not** used anywhere in this suite. Every mocked block is already offline — `httr2::with_mocked_responses()`/`local_mocked_responses()` divert `httr2::req_perform()` before any socket is opened, and `mockery::stub()` prevents the call entirely — so skipping on CRAN would only hide real coverage. 19 redundant `skip_on_cran()` calls were removed for that reason; do not reintroduce them. The suite must stay hermetic (397 passing expectations, 0 failures) because `R CMD check` runs it on machines without internet access.
- **Recorded cassettes (`vcr`)**: `tests/testthat/test-cassettes.R` exercises the real API offline through recorded cassettes in `tests/testthat/_vcr/` (6 files: paginação across two pages, `select` + `order`, `order` ascending, empty result, a filter, and an invalid `order` returning HTTP 400). `tests/testthat/helper-vcr.R` configures `vcr::vcr_configure(dir = vcr::vcr_test_path("testthat", "_vcr"), record = "once")` — `vcr_test_path()` resolves from `tests/`, so passing `"testthat", "_vcr"` is what lands on the package convention. Each block is guarded by `skip_if_not_installed("vcr")`, `skip_if_not_installed("httr2")` and `vcr::skip_if_vcr_off()`, then wrapped in `vcr::use_cassette("nome", {...})`.
- **`library(vcr)` in the helper is load-bearing, not style.** `webmockr` records only while `"package:vcr" %in% search()`; calling `vcr::use_cassette()` without attaching the package makes the request go live, record zero interactions, and silently delete the resulting empty cassette. `vcr::vcr_cassettes()` is not exported and `vcr::insert_cassette()` has no `warn_on_empty_cassette` argument. webmockr is enabled only inside a `use_cassette()` block and reverted on eject, which is why it does not interfere with the `httr2::with_mocked_responses()`/`mockery::stub()` blocks elsewhere in the suite.
- **Re-recording** a cassette means deleting its YAML under `tests/testthat/_vcr/` and rerunning `devtools::test(filter = "cassettes")` against the live API. Otherwise `record = "once"` replays from disk; replay is deterministic and does not rewrite the files. Keep every cassette's `limite` small (2–3) so the recorded page is short and `pg_get()`'s loop (`if (linhas < limite || linhas == 0) break`) terminates offline. The pagination cassette is anchored on `order=id_programa.asc`, which deterministically returns `1,2,3,…`. Cassettes are intentionally shipped in the tarball (no `.Rbuildignore` rule), which is the standard `vcr` practice.
- Two exported readers point at tables that do not exist: `ler_empenho_especial()` (`R/ler_empenho_especial.R:54`, table `empenho_especial`) and `ler_programa_especial()` (`R/ler_programas_especiais.R:49`, table `programa_especial`) both get **HTTP 404** from the live API, and neither table is in `metafaftab`. The OpenAPI spec served at the API root lists exactly the 21 `metafaftab` paths and nothing matching "espec", and neither `empenhos_especiais` nor `programas_especiais` exists either. No column cleanly separates "special" records: `programa.modalidade_programa` is `FUNDO_A_FUNDO` in all 129 rows and `empenho.situacao_empenho` is the single value `6` in all 4.248 rows; the only rare discriminator found is `empenho.tipo_empenho == 3` (2 rows). Several parameters of the two readers also match no real column (`id_empenho_especial` and `id_programa` on `empenho` — plans link via `id_plano_acao`; `id_proponente`, `data_inicio`, `data_fim`, `esfera`, `orgao_executor` on `programa`), so a fix is not a one-line table rename. The tests assert the transport contract only (that the reader builds `/<table>?...`), so they pass today and stay correct if the table name is later fixed; do not "fix" the table names without asking.
- `test-leitores.R` derives everything from a single `leitores` list mapping each reader to the table it queries; it never hard-codes parameter or expectation counts. Three checks run per reader (URL targets that table and carries every parameter as a `campo=eq.valor` filter; `select`/`order` are forwarded; the result carries the endpoint's columns), plus one completeness check comparing `names(leitores)` against the exports matching `^(ler_|get_)` — so adding a reader without a test breaks the suite. Each mock returns either `[]` or a single row, which ends pagination after one page; that is what makes `expect_length(urls, 1)` valid. **Never make these mocks return a full `limite`-sized page**, or `pg_get()` loops forever.
- Two exported readers point at tables that do not exist: `ler_empenho_especial()` (`R/ler_empenho_especial.R:54`, table `empenho_especial`) and `ler_programa_especial()` (`R/ler_programas_especiais.R:49`, table `programa_especial`) both get **HTTP 404** from the live API, and neither table is in `metafaftab`. The likely cause is that "especial" is a filter *value* on `programa`/`empenho` rather than a separate table. The tests assert the transport contract only (that the reader builds `/<table>?...`), so they pass today and stay correct if the table name is later fixed; do not "fix" the table names without asking.

## Gotchas / non-obvious

1. **Dependencies**: DESCRIPTION declares `Depends: R (>= 4.1)`, `Imports: httr, httr2, janitor, jsonlite, readr, utils`, `Suggests: mockery, testthat (>= 3.0.0), vcr, webmockr`. `httr` is still needed by `consultar_renuncias_fiscais()`; do not drop it. `vcr` and `webmockr` are needed by the cassette tests; since `vcr` hard-imports both `httr2` and `webmockr`, the cassette blocks are additionally guarded by `skip_if_not_installed()`. Source files use `::` qualification for every non-base call, and all imports are declared. `tibble`, `data.table`, `tidyr`, `glue`, `archive`, `readxl`, `geobr`, `stringi`, `lubridate` and `ggplot2` are used only in `data-raw/` analysis scripts and are intentionally not declared.
2. **License**: `DESCRIPTION` and README both say MIT.
3. **URL spelling**: `fundoafundo`, not `fundafundo`.
4. **Leading zeros**: SIAFI codes must stay character; any numeric coercion breaks joins. `codigo_ibge` is numeric by design (leading zeros aren't significant for IBGE codes but SIAFI are).
5. **Accented filenames** in repo (`data/transferências_para_municípios.csv`) and pt-BR encoding — be careful with non-ASCII handling when scripting around the repo. The renúncias files are also accent-inconsistent: URLs use `{ano}_RenunciasFiscais.zip` but extracted CSVs are named `{ano}_RenúnciasFiscais.csv` (the analysis script reconciles with `gsub("_Renun","_Renún", ...)`).
6. `.Rbuildignore` excludes `data-raw/`, `LICENSE.md`, `AGENTS.md`, `README.Rmd`, `README.html`, `cache/`, `.crush/`, and every raw download under `data/` (`*.zip|csv|xlsx|xls|ods|txt|old`). `cache/` and loose CSVs at repo root are untracked clutter, not part of the package. `data/` holds several untracked raw files (`estimativa_dou_2025.ods/.xls`, UUID-named `.xlsx`, `link_baixada_transferencia.txt`, `transf_mun_ptransp.zip`) that are inputs/outputs of analysis, not package data.
7. Failures in download functions return `invisible(NULL)` + `warning()`, never `stop()`; validation errors (bad `ano`/`mes`) do `stop()`. Match this split in new code. Note the exception: `consultar_renuncias_fiscais` does `stop()` for missing API key and HTTP errors — it's a REST API call, not a file download.
8. Never call `data(municipios_siafi_ibge)` inside a function to load the built-in mapping: on newer R it can return the *name* of the dataset rather than the data frame, silently skipping the IBGE join. `R/ler_transferencias_ptransp.R` uses `get("municipios_siafi_ibge", envir = asNamespace("transfRgov"))`; callers that need control should pass `municipios_mapping` explicitly.
