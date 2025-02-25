## code to prepare `metafaftab` dataset goes here

library(postgrestR)


metafaftab <-
  postgrestR::pg.get(domain = "https://api.transferegov.gestao.gov.br/fundoafundo/")

caminhos <-
  names(metafaftab$paths)

parametros <- lapply(caminhos,\(x){
  gsub(paste0("#/parameters/(rowFilter\\.)*",
              gsub("/","(",x),"\\.)*"),"",metafaftab$paths[[x]]$get$parameters$`$ref`)
})


names(parametros) <- caminhos

metafaftab <- parametros
usethis::use_data(metafaftab, overwrite = TRUE)
