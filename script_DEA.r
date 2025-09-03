# --- Script de Análise DEA (Data Envelopment Analysis) ---

# 1. Carregando os pacotes necessários
library("Benchmarking")
library("openxlsx")
library("ggplot2")

# 2. Definindo o Diretório de Trabalho
# Garanta que este caminho aponta para a pasta onde o 'dados.xlsx' está salvo.
setwd(file.path("C:", "Users", "Maria Alyce", "Desktop", "DADOS_TRATADOS_TEAM1_LAB_REDES"))

# 3. Leitura dos Dados
# ---------------------------------------------------------------------------------
# 'data_numerico' contém os valores para o cálculo.
# 'data_descritivo' contém as informações de cada DMU (CPU, Servidor, Escala).
# ---------------------------------------------------------------------------------
data_numerico <- openxlsx::read.xlsx(xlsxFile = "dados.xlsx", sheet = "Dados_DEA", colNames = TRUE)
data_descritivo <- openxlsx::read.xlsx(xlsxFile = "dados.xlsx", sheet = "Descricao_Completa", colNames = TRUE)


# 4. Limpeza e Preparação dos Dados
# Junta as duas tabelas em uma só para facilitar a filtragem.
# Primeiro, renomeia a coluna de ID na tabela descritiva para ser igual.
colnames(data_descritivo)[colnames(data_descritivo) == "DMU_ID"] <- "DMUs"
# Agora, junta as duas tabelas usando a coluna "DMUs" como chave.
full_data <- merge(data_numerico, data_descritivo, by = "DMUs")

# Limpeza de NAs (dados faltantes).
linhas_com_na <- which(rowSums(is.na(full_data)) > 0)
if (length(linhas_com_na) > 0) {
  dmus_removidas_na <- full_data[linhas_com_na, "DMUs"]
  print(paste("Aviso: Removendo as seguintes DMUs por dados faltantes (NA):", paste(dmus_removidas_na, collapse=", ")))
  full_data <- full_data[-linhas_com_na, ]
}

# Remove linhas com valores zero ou negativos (por segurança).
# Seleciona apenas as colunas numéricas para esta verificação
colunas_numericas <- c("FractalDim", "TimeTakenForTests", "TimePerRequest", "TransferRate", "Hurst", "RequestsPerSecond")
indices_validos <- apply(full_data[, colunas_numericas], 1, function(row) all(row > 0 & is.finite(row)))
full_data <- full_data[indices_validos, ]

print(paste("Análise final será realizada com", nrow(full_data), "DMUs válidas, divididas por escala."))


# 5. Análise DEA por Escalonamento (LOOP)
# ---------------------------------------------------------------------------------
# Pega os nomes únicos das escalas (ex: "2000_rq_100_c", "10000_rq_500_c", etc.)
escalas_unicas <- unique(full_data$Escala)

for (escala_atual in escalas_unicas) {
  
  cat(paste("\n--- INICIANDO ANÁLISE PARA A ESCALA:", escala_atual, "---\n"))
  
  # Filtra os dados para conter apenas as DMUs da escala atual.
  data_subset <- subset(full_data, Escala == escala_atual)
  
  # Prepara a matriz de dados apenas para este subconjunto.
  rownames(data_subset) <- data_subset$DMUs
  data_dea <- as.matrix(data_subset[, colunas_numericas])
  
  # Define inputs e outputs.
  inputs  <- data_dea[,c("FractalDim", "RequestsPerSecond", "TimeTakenForTests", "TimePerRequest")]
  outputs <- data_dea[,c("TransferRate", "Hurst")]
  
  # Roda o modelo de super-eficiência para a escala atual.
  SCCR_I <- sdea(inputs, outputs, RTS="CRS", ORIENTATION="in")
  
  # Encontra a melhor e a pior DMU DENTRO desta escala.
  bestDMU_index <- which.max(SCCR_I$eff)
  badDMU_index  <- which.min(SCCR_I$eff)
  bestDMU_name <- rownames(data_dea)[bestDMU_index]
  badDMU_name  <- rownames(data_dea)[badDMU_index]
  
  # Imprime os resultados para esta escala.
  print(paste("DMU mais eficiente para esta escala:", bestDMU_name, "com eficiência de", round(SCCR_I$eff[bestDMU_index], 4)))
  print(paste("DMU menos eficiente para esta escala:", badDMU_name, "com eficiência de", round(SCCR_I$eff[badDMU_index], 4)))
  
  # Gera e SALVA o gráfico da fronteira de eficiência para esta escala.
  # O nome do arquivo será, por exemplo, "Fronteira_de_Eficiencia_2000_rq_100_c.png"
  nome_arquivo_grafico <- paste0("Fronteira_de_Eficiencia_", escala_atual, ".png")
  png(nome_arquivo_grafico, width=800, height=600) # Prepara o arquivo PNG para salvar
  
  # Cria o gráfico
  dea.plot(inputs, outputs, RTS="crs", ORIENTATION="in", main=paste("Fronteira de Eficiência - Carga:", escala_atual))
  
  dev.off() # Fecha e salva o arquivo de imagem.
  
  print(paste("Gráfico salvo como:", nome_arquivo_grafico))
}

cat("\n--- ANÁLISE COMPLETA --- \n")
