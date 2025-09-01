# -----------------------------------------------------------------------------
# Script de Análise de Eficiência (DEA) - Versão com Correção de Erro
# -----------------------------------------------------------------------------

# 1. CARREGANDO OS PACOTES NECESSÁRIOS
# Se ainda não os tiver, instale-os com: install.packages(c("Benchmarking", "openxlsx"))
library("Benchmarking")
library("openxlsx")

# 2. DEFININDO O DIRETÓRIO DE TRABALHO
# O caminho para a sua pasta de trabalho no Windows.
setwd("C:/Users/Maria Alyce/Desktop/dados_tratados_team1_lab_redes")

# 3. LEITURA DOS DADOS
# CORREÇÃO: Usando openxlsx::read.xlsx() para evitar conflito com outros pacotes.
# Esta é a linha que causava o erro.
data <- openxlsx::read.xlsx("dados.xlsx", sheet = 1, colNames = TRUE)

# 4. ORGANIZAÇÃO DOS DADOS
# Extraindo as colunas da planilha para variáveis individuais.
Names <- as.character(data[["DMUs"]])
FractalDim <- data[["FractalDim"]]
TimeTakenForTests <- data[["TimeTakenForTests"]]
TimePerRequest <- data[["TimePerRequest"]]
TransferRate <- data[["TransferRate"]]
Hurst <- data[["Hurst"]]
RequestsPerSecond <- data[["RequestsPerSecond"]]

# Criando a matriz de dados principal.
dataMatrix <- cbind(FractalDim, TimeTakenForTests, TimePerRequest, TransferRate, Hurst, RequestsPerSecond)
rownames(dataMatrix) <- Names # Atribuindo os nomes das DMUs às linhas.

# 5. LIMPEZA DE DADOS
# Função para remover linhas que contêm valores ausentes (NA).
delete.na <- function(DF, n = 0) {
  DF[rowSums(is.na(DF)) <= n, ]
}
data_dea <- delete.na(dataMatrix)

# Mensagem para o usuário saber quantas DMUs restaram após a limpeza.
cat("Análise iniciada com", nrow(data_dea), "DMUs após a remoção de dados ausentes.\n\n")

# 6. DEFININDO ENTRADAS (INPUTS) E SAÍDAS (OUTPUTS)
# Selecionando as colunas pelos nomes para evitar erros.
inputs <- data_dea[, c("FractalDim", "RequestsPerSecond", "TimeTakenForTests", "TimePerRequest")]
outputs <- data_dea[, c("TransferRate", "Hurst")]

# 7. EXECUÇÃO DA ANÁLISE DEA
# Modelo CCR com orientação para entrada (eficiência técnica).
CCR_I <- dea(inputs, outputs, RTS = "CRS", ORIENTATION = "IN", SLACK = TRUE)

# Modelo CCR com orientação para saída.
CCR_O <- dea(inputs, outputs, RTS = "CRS", ORIENTATION = "OUT", SLACK = TRUE)

# Modelo de Super-eficiência para diferenciar as DMUs eficientes (escore > 1).
SCCR_I <- sdea(inputs, outputs, RTS = "CRS", ORIENTATION = "IN")

# 8. APRESENTAÇÃO DOS RESULTADOS
# Encontrando o índice (a posição) da melhor e da pior DMU.
bestDMU_index <- which.max(SCCR_I$eff)
badDMU_index <- which.min(SCCR_I$eff)

# Usando o índice para obter o NOME da DMU e seu escore de eficiência.
bestDMU_name <- rownames(data_dea)[bestDMU_index]
badDMU_name <- rownames(data_dea)[badDMU_index]

bestDMU_score <- SCCR_I$eff[bestDMU_index]
badDMU_score <- SCCR_I$eff[badDMU_index]

# Imprimindo os resultados de forma clara.
print("--- RESULTADOS DA ANÁLISE DEA ---")
print(paste("A DMU mais eficiente é:", bestDMU_name, "com um escore de", round(bestDMU_score, 4)))
print(paste("A DMU menos eficiente é:", badDMU_name, "com um escore de", round(badDMU_score, 4)))
print("-----------------------------------")

# 9. VISUALIZAÇÃO E EXPORTAÇÃO
# Gera um gráfico da fronteira de eficiência.
dea.plot(inputs, outputs, RTS = "crs", ORIENTATION = "in")

# Para exportar os resultados para um arquivo Excel:
# 1. Cria um data.frame com os nomes e os escores de eficiência.
resultados_df <- data.frame(
  DMU = rownames(data_dea),
  Eficiencia = SCCR_I$eff
)
# 2. Ordena do mais eficiente para o menos eficiente.
resultados_df <- resultados_df[order(resultados_df$Eficiencia, decreasing = TRUE), ]

# 3. Escreve para um arquivo .xlsx no mesmo diretório.
# Remova o '#' da linha abaixo para executar a exportação.
# write.xlsx(resultados_df, file = 'resultados_eficiencia.xlsx', rowNames = FALSE)

cat("\nScript finalizado. Para salvar os resultados, remova o '#' da última linha do código.\n")
