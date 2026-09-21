#' Encadear dois arquivos de despesas do Portal da Transparência
#'
#' @description
#' Junta um arquivo de despesas que traz o total por registro com o arquivo que
#' traz o detalhamento desse mesmo registro. No caso mais usado, o total por
#' ordem bancária (\code{pagamento}) e os beneficiários daquela ordem
#' (\code{pagamento_favorecidos_finais}).
#'
#' @param total Um \code{data.frame} com uma linha de total por registro. É o
#'   resultado de \code{download_despesas_ptransp()} para o tipo agregador
#'   (por exemplo \code{"pagamento"}).
#' @param detalhe Um \code{data.frame} com zero ou mais linhas de detalhe por
#'   registro. É o resultado de \code{download_despesas_ptransp()} para o
#'   tipo detalhado (por exemplo \code{"pagamento_favorecidos_finais"}).
#' @param chave Texto com o nome da coluna que identifica o registro nos dois
#'   data frames. O padrão \code{"codigo_pagamento"} serve ao par
#'   \code{pagamento} × \code{pagamento_favorecidos_finais}; use
#'   \code{"id_empenho"} no par \code{empenho} × \code{item_empenho}.
#' @param somente_detalhados Lógico. Com \code{FALSE} (o padrão) toda
#'   linha de \code{total} aparece no resultado, e as colunas de detalhe ficam
#'   \code{NA} onde não há detalhamento. Com \code{TRUE}, só as
#'   linhas de \code{total} que têm ao menos uma linha em \code{detalhe}
#'   são devolvidas.
#'
#' @return Um \code{data.frame} com as colunas de \code{total} seguidas das
#'   colunas exclusivas de \code{detalhe}, na ordem em que aparecem nas
#'   entradas. A coluna \code{detalhado} (lógica), inserida logo depois da
#'   coluna \code{chave}, indica quais linhas encontraram detalhamento.
#'   Colunas homônimas nos dois data frames recebem os sufixos
#'   \code{.total} e \code{.detalhe}. A ordem das linhas de \code{total} é
#'   preservada, e quando um registro tem mais de um detalhe as linhas ficam
#'   adjacentes. Um \code{detalhe} com zero linhas não é erro: o
#'   resultado sai com as colunas de detalhe em \code{NA} e
#'   \code{detalhado = FALSE}.
#'
#' @details
#' A junção é 1:N na coluna \code{chave}, como em \code{merge(..., all.x =
#' !somente_detalhados, sort = FALSE)}. Ela foi medida em 2024-01-15:
#' \code{pagamento} tinha 14.949 ordens bancárias e
#' \code{pagamento_favorecidos_finais} detalhava 162 delas, com 99 dessas 162
#' trazendo mais de um beneficiário. A soma dos detalhes fecha com
#' \code{valor_do_pagamento_convertido_pra_r} (maior diferença encontrada:
#' \code{3,6e-12}, tolerância \code{0,01}).
#'
#' O detalhamento é \strong{parcial}: no dia medido, apenas cerca de 1\% das
#' ordens bancárias tinham linha correspondente no arquivo de
#' beneficiários. Por isso o padrão é devolver todas as linhas de
#' \code{total}, e não tratar um dia sem detalhamento como erro.
#'
#' Os pares total/detalhe do ZIP diário e as chaves correspondentes são:
#' \code{liquidacao} com \code{liquidacao_empenhos_impactados},
#' \code{pagamento} com \code{pagamento_empenhos_impactados} e \code{pagamento}
#' com \code{pagamento_favorecidos_finais} (todos por \code{codigo_pagamento} ou
#' pela coluna de mesmo nome nos dois lados) e \code{empenho} com
#' \code{item_empenho} (por \code{id_empenho}).
#'
#' Os nomes das colunas de valor não coincidem entre os lados: o total por
#' ordem bancária usa \code{valor_do_pagamento_convertido_pra_r} e o
#' detalhamento usa \code{valor_do_pagamento_em_r}. A função não
#' compara valores; ela entrega as duas colunas lado a lado.
#'
#' @seealso \code{\link{download_despesas_ptransp}}
#'
#' @examples
#' total <- data.frame(
#'   codigo_pagamento = c("A", "B", "C"),
#'   valor_do_pagamento_convertido_pra_r = c(100, 50, 25)
#' )
#' detalhe <- data.frame(
#'   codigo_pagamento = c("A", "A", "B"),
#'   codigo_favorecido = c("F1", "F2", "F3"),
#'   valor_do_pagamento_em_r = c(60, 40, 50)
#' )
#' encadeia_despesas_ptransp(total, detalhe)
#' encadeia_despesas_ptransp(total, detalhe, somente_detalhados = TRUE)
#'
#' @export
encadeia_despesas_ptransp <- function(
    total,
    detalhe,
    chave = "codigo_pagamento",
    somente_detalhados = FALSE) {

  # --- 1. Valida\u00e7\u00e3o dos par\u00e2metros ---
  if (missing(total) || !is.data.frame(total)) {
    stop("O par\u00e2metro 'total' deve ser um data frame.")
  }
  if (missing(detalhe) || !is.data.frame(detalhe)) {
    stop("O par\u00e2metro 'detalhe' deve ser um data frame.")
  }
  if (!is.character(chave) || length(chave) != 1L || is.na(chave)) {
    stop("O par\u00e2metro 'chave' deve ser um texto v\u00e1lido.")
  }
  if (!is.logical(somente_detalhados) ||
      length(somente_detalhados) != 1L ||
      is.na(somente_detalhados)) {
    stop("O par\u00e2metro 'somente_detalhados' deve ser TRUE ou FALSE.")
  }
  if (!chave %in% names(total)) {
    stop("A coluna '", chave, "' n\u00e3o existe em 'total'.")
  }
  if (!chave %in% names(detalhe)) {
    stop("A coluna '", chave, "' n\u00e3o existe em 'detalhe'.")
  }

  # O merge coage tipos diferentes em sil\u00eancio, ent\u00e3o a checagem \u00e9 feita aqui.
  numerica <- is.numeric(total[[chave]]) && is.numeric(detalhe[[chave]])
  if (!numerica && !identical(class(total[[chave]]), class(detalhe[[chave]]))) {
    stop(
      "A coluna '", chave,
      "' deve ter o mesmo tipo nos dois data frames."
    )
  }

  # --- 2. Jun\u00e7\u00e3o 1:N ---
  resultado <- merge(
    x = total,
    y = detalhe,
    by = chave,
    all.x = !somente_detalhados,
    sort = FALSE,
    suffixes = c(".total", ".detalhe")
  )

  casados <- unique(detalhe[[chave]])
  resultado$detalhado <- resultado[[chave]] %in% casados

  posicao <- match(chave, names(resultado))
  colunas <- names(resultado)
  colunas <- append(colunas[colunas != "detalhado"], "detalhado", after = posicao)
  resultado <- resultado[, colunas, drop = FALSE]
  rownames(resultado) <- NULL

  if (nrow(total) > 0L && nrow(detalhe) > 0L && !any(resultado$detalhado)) {
    warning(
      "Nenhuma chave de 'total' foi encontrada em 'detalhe': ",
      "o resultado saiu sem detalhamento."
    )
  }

  resultado
}
