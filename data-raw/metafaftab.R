## code to prepare `metafaftab` dataset goes here

resposta <-
  httr::GET("https://api.transferegov.gestao.gov.br/fundoafundo/")

metafaftab <-
  jsonlite::fromJSON(
    httr::content(resposta, "text", encoding = "UTF-8")
  )

caminhos <-
  names(metafaftab$paths)

parametros <- lapply(caminhos,\(x){
  gsub(paste0("#/parameters/(rowFilter\\.)*",
              gsub("/","(",x),"\\.)*"),"",metafaftab$paths[[x]]$get$parameters$`$ref`)
})


names(parametros) <- caminhos

metafaftab <- parametros
usethis::use_data(metafaftab, overwrite = TRUE)
