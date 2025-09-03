# 📘 Guia: Usando os Scripts R para Análise de Eficiência do Projeto

[![R](https://img.shields.io/badge/R-Script-blue?logo=r)](https://www.r-project.org/)
[![RStudio](https://img.shields.io/badge/RStudio-IDE-blue?logo=rstudio)](https://posit.co/)

## 1. Introdução
Este documento resume como utilizar o pipeline de dois scripts em R para processar os dados brutos do Projeto Final da disciplina de Redes de Computadores e gerar a análise de eficiência.

O processo está dividido em duas etapas principais: Preparação dos Dados e Análise de Eficiência.

Fluxo de trabalho:
Dados Brutos (270 Pastas) → Script 1: Preparação → Planilha dados.xlsx → Script 2: Análise → Resultados Finais

## 2. Pré-requisitos
Antes de começar, garanta que você tem:
- R e RStudio instalados.
- Os pacotes R necessários instalados: Benchmarking, openxlsx, ggplot2, pracma, fractaldim, poweRlaw.
- Medições realizadas e arquivos tratados conforme os vídeos:
  - Medições: https://www.youtube.com/watch?v=yaH6p7l8Ll4
  - Tratando arquivos: https://www.youtube.com/watch?v=fSTPFIx-Uj8
- A pasta contendo os dados brutos dos 270 testes.
- Os dois arquivos de script: script1_proj_labRedes.R e script_DEA.R.

## 3. Etapa 1: Preparação e Limpeza dos Dados
Script: script1_proj_labRedes.R

Objetivo:
- Ler os dados brutos das 270 pastas de teste.
- Calcular métricas adicionais (FractalDim e Hurst).
- Consolidar tudo em uma única planilha Excel chamada dados.xlsx.

Como usar:
1. Abra o arquivo script1_proj_labRedes.R no RStudio.
2. Verifique a variável BASE_DIR e ajuste para o local onde estão seus dados.
   Exemplo: BASE_DIR <- file.path("C:", "Users", "Maria Alyce", "Desktop", "DADOS_TRATADOS_TEAM1_LAB_REDES")
3. Execute o script inteiro.
4. Ao final, será criado o arquivo dados.xlsx contendo:
   - Aba Dados_DEA: tabela consolidada com os dados numéricos.
   - Aba Descricao_Completa: tabela de referência que mapeia cada DMU à sua configuração.

## 4. Etapa 2: Análise de Eficiência por Escalonamento
Script: script_DEA.R

Objetivo:
Ler a planilha dados.xlsx (gerada na Etapa 1), aplicar a Análise Envoltória de Dados (DEA) e apresentar os resultados. A principal função deste script é realizar a análise separadamente para cada um dos 3 níveis de carga (escalonamentos), em vez de uma única análise global.

Como usar:
- Abra o arquivo script_DEA.R no RStudio.
- Verifique o diretório de trabalho (setwd): Ajuste o caminho para o local exato onde o arquivo dados.xlsx foi salvo na etapa anterior.
      - Exemplo: setwd(file.path("C:", "Users", "Maria Alyce", "Desktop", "DADOS_TRATADOS_TEAM1_LAB_REDES"))
- Execute o script inteiro.
  
Resultados esperados:
- Impressão no Console:
    - O console irá mostrar uma análise em loop, uma para cada nível de carga.
    - Para cada carga, ele identificará a DMU mais eficiente e a menos eficiente dentro daquele cenário específico.

- Geração de Gráficos (Arquivos de Imagem):

    - O script irá gerar e salvar três arquivos de imagem (.png) no seu diretório de trabalho.
    - Cada imagem conterá o gráfico da fronteira de eficiência para uma das cargas (Carga Baixa, Média e Alta), exatamente como solicitado pelo professor.

## 5. Conclusão
Após seguir estas duas etapas, você terá processado os dados brutos e obtido os resultados finais da análise de eficiência, prontos para discussão e apresentação.

## Créditos
Este guia foi desenvolvido por:
- Maria Alyce Barreto
- João Victor Batista
- João Paulo Oliveira
