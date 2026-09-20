#!/bin/bash

# ============================================================
# DOWNLOAD DO DATASET PRJEB21497
# ============================================================

# Interrompe o script se ocorrer algum erro:
set -e

# Número de threads:
THREADS=8

# Diretórios de saída:
BASE_DIR="$(pwd)"
RAW_DIR="$BASE_DIR/16S_FASTQ/RAW_FASTQ"

# Criando os diretórios:
mkdir -p "$RAW_DIR"

# Lista de acessos:
ACCESSIONS=(
ERR2014724
ERR2014725
ERR2014726
ERR2014727
ERR2014728
ERR2014729
ERR2014730
ERR2014731
ERR2014732
ERR2014733
ERR2014734
ERR2014735
ERR2014736
ERR2014737
ERR2014738
ERR2014739
ERR2014740
ERR2014741
ERR2014742
ERR2014743
ERR2014744
ERR2014745
ERR2014746
ERR2014747
ERR2014748
ERR2014749
ERR2014750
ERR2014751
ERR2014752
ERR2014753
ERR2014754
ERR2014755
ERR2014756
ERR2014757
ERR2014758
ERR2014759
)

# Download dos arquivos do ENA:
echo ">>> Download direto do ENA"
echo ">>> Total de amostras: ${#ACCESSIONS[@]}"

for ACC in "${ACCESSIONS[@]}"
do

    echo "------------------------------------------"
    echo "Processando: $ACC"
    echo "------------------------------------------"

    URLS=$(curl -s \
        "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${ACC}&result=read_run&fields=fastq_ftp&format=tsv" \
        | tail -n +2 \
        | cut -f2 \
        | tr -d '\r\n')

    if [ -z "$URLS" ]; then
        echo "Nenhum FASTQ encontrado para $ACC"
        continue
    fi

    IFS=';' read -ra FILES <<< "$URLS"

    for FILE in "${FILES[@]}"
    do

        FILE=$(echo "$FILE" | xargs)

        if [ -z "$FILE" ]; then
            continue
        fi

        URL="https://$FILE"
        NAME=$(basename "$FILE")

        echo "Baixando: $NAME"

        curl -L \
            --fail \
            --retry 5 \
            --retry-delay 3 \
            -C - \
            "$URL" \
            -o "$RAW_DIR/$NAME"

        echo "Concluído: $NAME"

    done

done

echo ">>> Download do conjunto de dados concluído com sucesso!"