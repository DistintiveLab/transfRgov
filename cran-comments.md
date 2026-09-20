## R CMD check results

0 errors | 0 warnings | 0 notes

The only NOTE seen locally when incoming checks are enabled is CRAN's standard
"New submission" NOTE.

## Comments

* This is a new submission.
* All exported functions are documented and have examples. Examples that need
  network access are wrapped in `\dontrun{}`.
* Two tests in `tests/testthat/test-pg_get.R` are marked `skip_on_cran()`: they
  exercise the live TransfereGov API and would be flaky on CRAN's machines.
* In `man/metafaftab.Rd` the API base URL is written as `\code{}` instead of
  `\url{}` on purpose. The server at
  https://api.transferegov.gestao.gov.br/fundoafundo/ answers `GET` requests but
  replies `403` to `HEAD` requests, and the URL checks use `HEAD`.
