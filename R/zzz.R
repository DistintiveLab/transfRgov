# Colunas dos dados de transferências usadas por avaliação não padrão (NSE)
# nas camadas de manipulação e nos exemplos da vinheta. Declará-las como
# variáveis globais evita falsos positivos de codetools sem alterar o
# comportamento do pacote.
utils::globalVariables(c(
  "ano_mes",
  "nome_modalidade_aplicacao_despesa",
  "codigo_ibge",
  "uf",
  "tipo_transferencia",
  "privadopub",
  "nome_funcao",
  "valor_transferido"
))
