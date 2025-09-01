# ------------------------------------------------------------------------------------
# Título: Script de Preparação de Dados para Análise DEA
# ------------------------------------------------------------------------------------
# Descrição: Este script lê a estrutura de pastas de testes, extrai todas as
#            métricas e gera uma única planilha consolidada ("dados.xlsx").
#
# Autor Original: Marcondes Junior (github.com/marcondesnjr)
# Script Adaptado e Depurado em colaboração com Maria Alyce.
# ------------------------------------------------------------------------------------


# --- 1. CARREGAMENTO DOS PACOTES ---
library("pracma")
library("fractaldim")
library("poweRlaw")
library("openxlsx")


# --- 2. CONFIGURAÇÃO DOS CAMINHOS ---
BASE_DIR <- file.path("C:", "Users", "Maria Alyce", "Desktop", "DADOS_TRATADOS_TEAM1_LAB_REDES")
RESULT_FILE <- file.path(BASE_DIR, "dados.xlsx")


# --- 3. FUNÇÃO AUXILIAR DE LEITURA (VERSÃO "TRADUTOR UNIVERSAL") ---
# Esta função foi totalmente reescrita para ser extremamente robusta.
# Ela lê os arquivos como texto, corrige o separador decimal e depois converte para número.
readValue <- function(file){
  if (!file.exists(file)) {
    return(NA)
  }
  lines <- try(readLines(file, warn = FALSE, encoding = "UTF-8"), silent = TRUE)
  if (inherits(lines, "try-error") || length(lines) == 0) {
    return(NA)
  }
  lines <- lines[lines != ""]
  lines_cleaned <- gsub(",", ".", lines, fixed = TRUE)
  lines_trimmed <- trimws(lines_cleaned)
  numbers <- as.numeric(lines_trimmed)
  if (length(numbers) == 0 || all(is.na(numbers))) {
    return(NA)
  }
  return(numbers)
}


# --- 4. LÓGICA PRINCIPAL DE PROCESSAMENTO ---
all_dirs <- list.dirs(path = BASE_DIR, recursive = TRUE, full.names = TRUE)
stats_dirs <- grep("/stats/?$", all_dirs, value = TRUE)

dea_data_frame <- data.frame()
desc_data_frame <- data.frame()
dmuindex <- 1

cat("--- INICIANDO PROCESSAMENTO PARA GERAR dados.xlsx ---\n")

for(current_stats_dir in stats_dirs){
  
  path_parts <- strsplit(current_stats_dir, .Platform$file.sep)[[1]]
  algoritmo  <- path_parts[length(path_parts) - 1]
  servidor   <- path_parts[length(path_parts) - 2]
  escala     <- path_parts[length(path_parts) - 3]
  config_cpu <- path_parts[length(path_parts) - 4] 
  dmu_id_base <- paste("DMU", dmuindex, sep="")
  
  # Lógica de nomes de arquivo 
  if (servidor == "nginx_quic") {
    if (escala == "2000_rq_100_c" && config_cpu == "1vCPU") {
      fname_timeseries    <- paste0(servidor, "_", algoritmo, ".csv_timeseries.txt")
      fname_req_per_sec   <- paste0("req_per_sec_", servidor, "_", algoritmo, ".out")
      fname_time_per_req  <- paste0("time_per_req_", servidor, "_", algoritmo, ".out")
      fname_time_taken    <- paste0("time_taken_for_tests_", servidor, "_", algoritmo, ".out")
      fname_transfer_rate <- paste0("transfer_rate_", servidor, "_", algoritmo, ".out")
    } else {
      fname_timeseries    <- paste0("nginx_", algoritmo, "_quic.csv_timeseries.txt")
      fname_req_per_sec   <- paste0("req_per_sec_nginx_", algoritmo, "_quic.out")
      fname_time_per_req  <- paste0("time_per_req_nginx_", algoritmo, "_quic.out")
      fname_time_taken    <- paste0("time_taken_for_tests_nginx_", algoritmo, "_quic.out")
      fname_transfer_rate <- paste0("transfer_rate_nginx_", algoritmo, "_quic.out")
    }
  } else {
    # BLOCO CORRIGIDO - GARANTINDO QUE AS STRINGS ESTÃO COMPLETAS
    fname_timeseries    <- paste0(servidor, "_", algoritmo, ".csv_timeseries.txt")
    fname_req_per_sec   <- paste0("req_per_sec_", servidor, "_", algoritmo, ".txt")
    fname_time_per_req  <- paste0("time_per_req_", servidor, "_", algoritmo, ".txt")
    fname_time_taken    <- paste0("time_taken_for_tests_", servidor, "_", algoritmo, ".txt")
    fname_transfer_rate <- paste0("transfer_rate_", servidor, "_", algoritmo, ".txt")
  }
  
  # Leitura dos arquivos
  timeToTest       <- readValue(file.path(current_stats_dir, fname_time_taken))
  transferRate     <- readValue(file.path(current_stats_dir, fname_transfer_rate))
  TimePerRequest   <- readValue(file.path(current_stats_dir, fname_time_per_req))
  requestPerSecond <- readValue(file.path(current_stats_dir, fname_req_per_sec))
  timeSeries       <- readValue(file.path(current_stats_dir, fname_timeseries))
  
  # Cálculos
  if(all(is.na(timeSeries))){
    fdim <- NA; hurst <- NA
  } else {
    fdim  <- fd.estimate(timeSeries, method="rodogram")[["fd"]]
    hurst <- hurstexp(timeSeries, display=FALSE)[["Hs"]]
  }
  
  # Montagem da linha de dados
  new_row <- data.frame(
    DMUs              = dmu_id_base,
    FractalDim        = fdim,
    TimeTakenForTests = timeToTest,
    TimePerRequest    = TimePerRequest,
    TransferRate      = transferRate,
    Hurst             = hurst,
    RequestsPerSecond = requestPerSecond
  )
  
  dea_data_frame <- rbind(dea_data_frame, new_row)
  
  # A coluna agora se chama 'vRAM' em vez de 'CPU'.
  desc_row <- data.frame(DMU_ID = dmu_id_base, vRAM = config_cpu, Servidor = servidor, Algoritmo = algoritmo, Escala = escala)
  desc_data_frame <- rbind(desc_data_frame, desc_row)
  
  dmuindex <- dmuindex + 1
}


# --- 5. GERAÇÃO DA PLANILHA EXCEL FINAL ---
if(nrow(dea_data_frame) > 0){
  
  wb <- createWorkbook()
  
  addWorksheet(wb, "Dados_DEA")
  writeData(wb, "Dados_DEA", dea_data_frame)
  
  addWorksheet(wb, "Descricao_Completa")
  # O nome da coluna no arquivo Excel agora será 'vRAM'.
  colnames(desc_data_frame) <- c("DMU_ID", "vRAM", "Servidor", "Algoritmo", "Escala")
  writeData(wb, "Descricao_Completa", desc_data_frame)
  
  saveWorkbook(wb, RESULT_FILE, overwrite = TRUE)
  print(paste("Planilha 'dados.xlsx' para análise DEA salva com sucesso em:", RESULT_FILE))
  
} else {
  print("Nenhum dado foi processado.")
}
# --- FIM DO SCRIPT ---