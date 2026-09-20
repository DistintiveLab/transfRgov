## R CMD check results

0 errors | 0 warnings | 0 notes

The only NOTE seen locally when incoming checks are enabled is CRAN's standard
"New submission" NOTE.

## Comments

* This is a new submission.
* All exported functions are documented and have examples. Examples that need
  network access are wrapped in `\dontrun{}`.
* The test suite is fully offline: network calls are diverted with
  `httr2::local_mocked_responses()`, `mockery::stub()`, `webmockr` and six
  recorded `vcr` cassettes. No test calls the live API, so `skip_on_cran()` is
  not used anywhere and the suite also passes on machines without internet
  access.
* The vignette builds without network access as well: every chunk that would
  reach the internet is `eval = FALSE`, and the executable chunks run against a
  small synthetic data frame that carries the column names the pipeline
  produces at runtime.
* In `man/metafaftab.Rd` the API base URL is written as `\code{}` instead of
  `\url{}` on purpose. The server at
  https://api.transferegov.gestao.gov.br/fundoafundo/ answers `GET` requests but
  replies `403` to `HEAD` requests, and the URL checks use `HEAD`.
