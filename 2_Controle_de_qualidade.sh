#!/bin/bash

# ============================================================
# CONTROLE DE QUALIDADE
# FastQC + MultiQC + Cutadapt
# ============================================================

# Interrompe o script se ocorrer algum erro:
set -e

# Número de threads:
THREADS=8

# Primers da região V4 do gene 16S rRNA:
FWD_PRIMER="GTGCCAGCMGCCGCGGTAA" 
REV_PRIMER="GGACTACHVGGGTWTCTAAT"

# Diretórios de saída:
BASE_DIR="$(pwd)"
RAW_DIR="$BASE_DIR/16S_FASTQ/RAW_FASTQ"
QC_DIR="$BASE_DIR/16S_FASTQ/QUALITY_CONTROL"
FASTQC_RAW_DIR="$QC_DIR/FastQC_RAW"
MULTIQC_RAW_DIR="$QC_DIR/MultiQC_RAW"
TRIMMED_DIR="$BASE_DIR/16S_FASTQ/TRIMMED_FASTQ"
CUTADAPT_REPORT_DIR="$QC_DIR/Cutadapt_REPORTS"
FASTQC_TRIMMED_DIR="$QC_DIR/FastQC_TRIMMED"
MULTIQC_TRIMMED_DIR="$QC_DIR/MultiQC_TRIMMED"
SAMPLE_LIST="$BASE_DIR/all_sample.txt"

# Criando os diretórios:
mkdir -p "$QC_DIR"
mkdir -p "$FASTQC_RAW_DIR"
mkdir -p "$MULTIQC_RAW_DIR"
mkdir -p "$TRIMMED_DIR"
mkdir -p "$CUTADAPT_REPORT_DIR"
mkdir -p "$FASTQC_TRIMMED_DIR"
mkdir -p "$MULTIQC_TRIMMED_DIR"

# Verificando o diretório de entrada:
if [ ! -d "$RAW_DIR" ]; then
    echo "ERRO: diretório RAW_FASTQ não encontrado:"
    echo "$RAW_DIR"
    exit 1
fi

# Criando a lista de amostras:
echo ">>> Criando a lista de amostras..."

find "$RAW_DIR" \
    -maxdepth 1 \
    -type f \
    -name "*_1.fastq.gz" \
    -exec basename {} \; \
    | sed 's/_1.fastq.gz//' \
    | sort -u \
    > "$SAMPLE_LIST"

echo ">>> Número de amostras:"
wc -l < "$SAMPLE_LIST"

# Verificando os arquivos paired-end:
echo ">>> Verificando os arquivos paired-end..."

while read -r SAMPLE; do

    R1="$RAW_DIR/${SAMPLE}_1.fastq.gz"
    R2="$RAW_DIR/${SAMPLE}_2.fastq.gz"

    if [ ! -f "$R1" ]; then
        echo "ERRO: R1 não encontrado para $SAMPLE"
        exit 1
    fi

    if [ ! -f "$R2" ]; then
        echo "ERRO: R2 não encontrado para $SAMPLE"
        exit 1
    fi

done < "$SAMPLE_LIST"

echo ">>> Todos os arquivos paired-end foram encontrados."

# Controle de qualidade inicial com FastQC:
echo ">>> Executando o FastQC nas leituras brutas..."

fastqc \
    --threads "$THREADS" \
    --outdir "$FASTQC_RAW_DIR" \
    "$RAW_DIR"/*.fastq.gz

# MultiQC das leituras brutas:
echo ">>> Executando o MultiQC das leituras brutas..."

multiqc \
    "$FASTQC_RAW_DIR" \
    --outdir "$MULTIQC_RAW_DIR" \
    --force

# Remoção dos primers com Cutadapt:
echo ">>> Removendo os primers 515F e 806R com Cutadapt..."

while read -r SAMPLE; do

    R1="$RAW_DIR/${SAMPLE}_1.fastq.gz"
    R2="$RAW_DIR/${SAMPLE}_2.fastq.gz"

    OUT_R1="$TRIMMED_DIR/${SAMPLE}_1_trimmed.fastq.gz"
    OUT_R2="$TRIMMED_DIR/${SAMPLE}_2_trimmed.fastq.gz"

    REPORT="$CUTADAPT_REPORT_DIR/${SAMPLE}_cutadapt.txt"

    echo ">>> Processando $SAMPLE..."

    cutadapt \
        -g "^${FWD_PRIMER}" \
        -G "^${REV_PRIMER}" \
        -e 0.1 \
        --minimum-length 50 \
        --cores "$THREADS" \
        -o "$OUT_R1" \
        -p "$OUT_R2" \
        "$R1" \
        "$R2" \
        > "$REPORT"

done < "$SAMPLE_LIST"

echo ">>> Remoção dos primers concluída."

# FastQC após remoção dos primers:
echo ">>> Executando o FastQC nas leituras após Cutadapt..."

fastqc \
    --threads "$THREADS" \
    --outdir "$FASTQC_TRIMMED_DIR" \
    "$TRIMMED_DIR"/*.fastq.gz

# MultiQC após remoção dos primers:
echo ">>> Executando o MultiQC das leituras após Cutadapt..."

multiqc \
    "$FASTQC_TRIMMED_DIR" \
    "$CUTADAPT_REPORT_DIR" \
    --outdir "$MULTIQC_TRIMMED_DIR" \
    --force

echo ">>> Controle de qualidade de 16S rRNA concluído com sucesso!"