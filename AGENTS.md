# AGENTS.md

## Project overview

**transfRgov** is an R package (`Type: Package`, MIT license in DESCRIPTION, GPL-3 claimed in README — see gotchas) that fetches Brazilian federal government transfer data ("Fundo a Fundo") from the TransfereGov API and from Portal da Transparência / Tesouro Transparente open-data downloads.

Everything user-facing (docs, comments, messages, column names) is written in **Brazilian Portuguese (pt-BR)**. New functions/docs should follow that convention. The data is fiscal data on transfers to municipalities (SIAFI/IBGE codes, empenhos, planos de ação, renúncias fiscais).

## Commands

This is a roxygen2 package; there is no Makefile, no CI config, and no lintr config.

```r
# Install the one non-CRAN dependency first (required for ler_* functions)
devtools::install_github("clesiemo3/postgrestR")

devtools::load_all()              # load package code
devtools::document()              # regenerate NAMESPACE + man/*.Rd from roxygen blocks
devtools::test()                  # run tests/testthat
devtools::check()                 # R CMD check equivalent
```

Tests use **mockery** (`mockery::stub`) to stub network calls; `mockery` is NOT declared in DESCRIPTION `Suggests` (only `testthat`), so `devtools::test()` fails on a clean install until `install.packages("mockery")` is run (the test file also `library()`s `dplyr`, `janitor`, `readr`, `tibble` directly — all must be installed).

## Code organization

- `R/` — one file per endpoint/function (mostly), each with a full roxygen block.
- `data-raw/` — two kinds of scripts, both excluded from build via `.Rbuildignore` (`^data-raw$`):
  - **Dataset prep** (`municipios_siafi_ibge.R`, `metafaftab.R`) — generate packaged datasets via `usethis::use_data()`.
  - **Analysis scripts** (`consolida_transferencias_p_funcao_municipio.R`, `gastos_tributarios.R`) — ad-hoc pipelines that call internal functions with `transfRgov:::` (e.g. `transfRgov:::download_transferencias_uniao(ano, x, municipios_mapping = municipios_siafi_ibge)`), download renúncias ZIPs into `cache/renuncias/`, and pull in many undeclared packages (`data.table`, `tidyr`, `glue`, `archive`, `readxl`, `geobr`, `stringi`, `lubridate`, `ggplot2`). Not runnable as-is without those.
- `data/` — packaged datasets (`municipios_siafi_ibge.rda`, `metafaftab.rda`) plus raw downloaded CSV/XLS/ODS files used for analysis (not part of the built package data).
- `tests/testthat/` — currently a single test file `test-download_transferencias_uniao.R`.
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

### 1. `ler_*` / `get_*` — TransfereGov API (via postgrestR)

Access the Fundo a Fundo API: `https://api.transferegov.gestao.gov.br/fundoafundo` — **note the spelling "fundoafundo"** (a code comment warns against "fundafundo"; README prose also writes "FundoaFundo"; do not "fix" it).

Pattern (see `R/ler_programas.R`, `R/ler_empenho.R`):

1. Every API column becomes a parameter, all defaulting to `NULL`, named exactly after the API field (`id_plano_acao`, `ano_empenho`, ...).
2. Non-NULL params are appended to a `filters` character vector as `paste0("campo=eq.", valor)` (PostgREST `eq` filter syntax).
3. Single call at the end: `pg.get(url, table = "<endpoint>", filter = filters)` (some functions pass the URL via a `url` variable, others inline; `table` is the endpoint name).

All parameters are optional. There is no pagination handling inside these functions — `pg.get` is expected to handle it.

**Naming is inconsistent within this family**: most readers use the `ler_` prefix, but five exported functions use `get_` (`get_plano_acao`, `get_plano_acao_dado_bancario`, `get_plano_acao_historico`, `get_plano_acao_destinacao_recursos`, `get_termo_adesao`) with the identical `eq.`-filter implementation. Don't "normalize" one into the other without asking the maintainer.

The `metafaftab` packaged dataset is a list of API endpoint paths → parameter names, scraped from the API's own OpenAPI spec (`postgrestR::pg.get(domain = "https://api.transferegov.gestao.gov.br/fundoafundo/")` in `data-raw/metafaftab.R`). It can tell you the valid field names for filters.

### 2. Downloader/scraper functions (Portal da Transparência / Tesouro)

- `download_transferencias_uniao(ano, mes, codigo_ibge = TRUE, municipios_mapping = NULL)` — builds URL `https://dadosabertos-download.cgu.gov.br/PortalDaTransparencia/saida/transferencias/{YYYYMM}_Transferencias.zip`, downloads to a tempfile, unzips, reads the CSV with `readr::read_delim(delim = ";", locale(encoding = "ISO-8859-1", decimal_mark = ","))`, cleans names with `janitor::clean_names()`, and optionally left-joins the SIAFI→IBGE mapping. Returns `invisible(NULL)` (with `warning`) on any failure — **never throws** for download/parse errors. Uses `utils::download.file` (not httr) and `utils::unzip`. Emits `message()` progress lines on the happy path.
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

- Only one test file exists: `tests/testthat/test-download_transferencias_uniao.R` (testthat edition 3 via `Config/testthat/edition`). It contains 6 `test_that` blocks: argument validation, mocked happy paths (with and without IBGE join), and 4 mocked failure paths (download, unzip, missing CSV, read failure) all asserting `NULL`.
- Style: `mockery::stub(func, "name", mock(...))` to replace `download.file`, `unzip`, `read_delim` inside the target function; `utils::`-qualified calls are stubbed by bare name. Stubs use `cycle = TRUE` and the `mock()` functions must actually create the zip/csv files in `tempdir()` because the target checks `file.exists()`. Tests verify argument validation errors (`expect_error` with pt-BR message substring) — the current `stop()` text is "O parâmetro 'ano' deve ser um inteiro válido representando o ano." and tests match the prefix "O parâmetro 'ano' deve ser um inteiro válido", so keep that prefix stable if you change `stop()` texts.
- The test file contains stale placeholder comments ("Cole a sua função AQUI") and top-level `library()` calls — harmless, leave them.
- The git history (`git log`) shows the current main commit is "unit test" — the package is early-stage, so patterns are still settling.

## Gotchas / non-obvious

1. **Undeclared dependencies**: `dplyr::`, `janitor::`, and `jsonlite::` are used in `R/` but are missing from DESCRIPTION (which lists only `httr, postgrestR, readr, rvest` in `Depends`, plus `R (>= 4.1)`). If you add code using them, keep using `::` qualification or add them to DESCRIPTION/NAMESPACE. `mockery` and `tibble` are likewise undeclared but required by tests; `data.table`, `tidyr`, `glue`, `archive`, `readxl`, `geobr`, `stringi`, `lubridate`, `ggplot2` are used only in `data-raw/` analysis scripts.
2. **License mismatch**: `DESCRIPTION` says `MIT + file LICENSE`, README says GPL-3. Don't "correct" one without asking the maintainer.
3. **URL spelling**: `fundoafundo`, not `fundafundo`.
4. **Leading zeros**: SIAFI codes must stay character; any numeric coercion breaks joins. `codigo_ibge` is numeric by design (leading zeros aren't significant for IBGE codes but SIAFI are).
5. **Accented filenames** in repo (`data/transferências_para_municípios.csv`) and pt-BR encoding — be careful with non-ASCII handling when scripting around the repo. The renúncias files are also accent-inconsistent: URLs use `{ano}_RenunciasFiscais.zip` but extracted CSVs are named `{ano}_RenúnciasFiscais.csv` (the analysis script reconciles with `gsub("_Renun","_Renún", ...)`).
6. `.Rbuildignore` excludes `data-raw/` and `LICENSE.md`; `cache/` and loose CSVs at repo root are untracked clutter, not part of the package. `man/hello.Rd` is a stale skeleton doc (no `hello` function exists); `data/` holds several untracked raw files (`estimativa_dou_2025.ods/.xls`, UUID-named `.xlsx`, `link_baixada_transferencia.txt`, `transf_mun_ptransp.zip`) that are inputs/outputs of analysis, not package data.
7. Failures in download functions return `invisible(NULL)` + `warning()`, never `stop()`; validation errors (bad `ano`/`mes`) do `stop()`. Match this split in new code. Note the exception: `consultar_renuncias_fiscais` does `stop()` for missing API key and HTTP errors — it's a REST API call, not a file download.
8. `data(municipios_siafi_ibge, overwrite = TRUE)` inside a function is fragile (silently returns a string naming the dataset on newer R); prefer passing `municipios_mapping` explicitly.
