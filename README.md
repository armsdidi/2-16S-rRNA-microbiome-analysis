# Pipeline de Análise de Dados de Amplicons do Gene 16S rRNA

## Visão geral

Este repositório contém scripts em **Shell** e **R** desenvolvidos para a análise de dados de sequenciamento de amplicons do gene **16S rRNA** e a caracterização de comunidades bacterianas em tecidos gástricos tumorais e não tumorais.

O fluxo de trabalho abrange desde a obtenção dos dados brutos em repositórios públicos até a inferência de variantes de sequência de amplicon (**ASVs**), atribuição taxonômica, reconstrução filogenética e análises ecológicas da comunidade microbiana.

As etapas incluem download do conjunto de dados, controle de qualidade, processamento das leituras, remoção de erros, união das leituras paired-end, remoção de quimeras, inferência de ASVs, classificação taxonômica, construção da árvore filogenética, composição taxonômica, diversidade alfa e beta e abundância diferencial.

---

## Fluxo de trabalho

O fluxo analítico está organizado em cinco etapas sequenciais:

- **Dados brutos de amplicons do gene 16S rRNA** ↓
- **1. Download do conjunto de dados** ↓
- **2. Controle de qualidade e pré-processamento** ↓
- **3. Inferência de ASVs e atribuição taxonômica** ↓
- **4. Alinhamento múltiplo e análise filogenética** ↓
- **5. Caracterização da comunidade microbiana**

---

## Estrutura do repositório

### `1_Download_do_dataset_PRJEB21497.sh`

Realiza o download das leituras paired-end de sequenciamento do gene 16S rRNA disponíveis no **European Nucleotide Archive (ENA)**.

O script utiliza os números de acesso das amostras para obter os arquivos FASTQ correspondentes às leituras forward e reverse.

**Principal resultado:** arquivos FASTQ paired-end brutos para cada amostra.

---

### `2_Controle_de_qualidade.sh`

Realiza o controle de qualidade e o pré-processamento das leituras brutas.

O script utiliza o **FastQC** para avaliar a qualidade das sequências, o **Cutadapt** para detectar e remover primers e adaptadores e o **MultiQC** para integrar os relatórios de qualidade de todas as amostras.

**Principal resultado:** leituras paired-end processadas e relatórios consolidados de controle de qualidade.

---

### `3_Inferência_de_ASVs.Rmd`

Realiza o processamento das sequências e a inferência de ASVs utilizando o pacote **DADA2**.

As análises incluem inspeção dos perfis de qualidade, filtragem e truncamento das leituras, estimativa das taxas de erro, desreplicação, inferência de ASVs, união das leituras forward e reverse, construção da tabela de sequências e remoção de quimeras.

As sequências representativas são posteriormente submetidas à atribuição taxonômica utilizando um banco de dados de referência, como o **SILVA**.

**Principais resultados:** tabela de abundância de ASVs, sequências representativas, classificação taxonômica e resumo das leituras mantidas em cada etapa do processamento.

---

### `4_Análise_filogenética.Rmd`

Realiza o alinhamento múltiplo das sequências representativas e a reconstrução da árvore filogenética das ASVs.

As sequências são alinhadas utilizando o pacote **DECIPHER**, e a árvore filogenética é estimada com o pacote **phangorn**.

A tabela de ASVs, a classificação taxonômica, os metadados das amostras e a árvore filogenética são integrados em um objeto **phyloseq**.

**Principais resultados:** alinhamento múltiplo, árvore filogenética e objeto `phyloseq` para as análises ecológicas subsequentes.

---

### `5_Caracterização_da_comunidade_microbiana.Rmd`

Realiza a caracterização taxonômica e ecológica da comunidade microbiana.

As análises incluem prevalência e abundância dos táxons, composição taxonômica, abundância relativa, diversidade alfa, diversidade beta, ordenação por Análise de Coordenadas Principais (**PCoA**) e abundância diferencial.

A diversidade alfa foi avaliada por métricas como **Riqueza observada**, **Chao1**, e os índices de **Shannon** e **Simpson**.

A diversidade beta foi estimada utilizando **Bray–Curtis**, **Jaccard**, **Weighted UniFrac** e **Unweighted UniFrac**. Diferenças na estrutura das comunidades foram testadas por **PERMANOVA**, enquanto os táxons diferencialmente abundantes foram identificados por **LEfSe (Linear Discriminant Analysis Effect Size)**.

**Principais resultados:** estatísticas descritivas, testes estatísticos e visualizações da composição, diversidade e abundância diferencial da comunidade microbiana.

---

## Principais análises

O repositório contempla os seguintes componentes analíticos:

- Download de dados públicos de sequenciamento 16S rRNA
- Controle de qualidade das leituras
- Detecção e remoção de primers e adaptadores
- Filtragem e truncamento de sequências
- Modelagem das taxas de erro
- Desreplicação das leituras
- Inferência de ASVs
- União de leituras paired-end
- Detecção e remoção de quimeras
- Atribuição taxonômica com banco de referência
- Alinhamento múltiplo de sequências
- Reconstrução filogenética
- Construção de objeto `phyloseq`
- Composição e abundância relativa dos táxons
- Diversidade alfa
- Diversidade beta e ordenação
- PERMANOVA e PERMDISP
- Abundância diferencial utilizando LEfSe

---

## Requisitos e dependências

### Ferramentas de linha de comando

As etapas de download, controle de qualidade e pré-processamento requerem:

- **curl** ou **wget**
- **FastQC**
- **Cutadapt**
- **MultiQC**

### R

As análises posteriores são realizadas no **R** utilizando pacotes que incluem:

- `dada2`
- `Biostrings`
- `DECIPHER`
- `phangorn`
- `ape`
- `phyloseq`
- `microbiome`
- `vegan`
- `microbiomeMarker`
- `ggplot2`
- `dplyr`
- `tidyr`
- `ComplexHeatmap`

Pacotes adicionais utilizados para manipulação, análise estatística e visualização dos dados estão especificados nos respectivos scripts.

### Bancos de dados

A atribuição taxonômica requer um banco de referência compatível com o DADA2, como:

- **SILVA**

A versão e os arquivos do banco de dados **SILVA** utilizados neste fluxo de trabalho foram obtidos no repositório [Zenodo](https://zenodo.org/records/20955974).

---

## Dados de entrada

O fluxo de trabalho foi desenvolvido para dados de sequenciamento **paired-end de amplicons do gene 16S rRNA**.

Os principais arquivos de entrada incluem:

- Arquivos FASTQ paired-end brutos
- Números de acesso das amostras disponíveis no [European Nucleotide Archive (ENA)](https://www.ebi.ac.uk/ena/browser/home)
- Sequências dos primers utilizados no sequenciamento
- Banco de referência taxonômica
- Metadados das amostras contendo os grupos biológicos e as variáveis de interesse

Os dados brutos de sequenciamento e os metadados não estao incluídos neste repositório.

Para reproduzir o fluxo, os usuários devem adaptar os números de acesso, caminhos dos arquivos, parâmetros de filtragem, sequências dos primers, banco taxonômico e recursos computacionais ao seu conjunto de dados e ambiente local.

---

## Reprodutibilidade

Os scripts estão numerados de acordo com a ordem recomendada de execução.

Os scripts Shell (`.sh`) contêm as etapas de download, controle de qualidade e pré-processamento inicial. Os scripts R Markdown (`.Rmd`) contêm a inferência de ASVs, atribuição taxonômica, reconstrução filogenética, análises estatísticas, análises ecológicas e visualizações.

Os parâmetros de filtragem e truncamento do DADA2 devem ser definidos após a inspeção dos perfis de qualidade das leituras. Esses parâmetros não devem ser aplicados automaticamente a conjuntos de dados produzidos com diferentes regiões do gene 16S rRNA, plataformas de sequenciamento ou comprimentos de leitura.

Para garantir a reprodutibilidade, recomenda-se registrar as versões do R, dos pacotes, das ferramentas de linha de comando e do banco taxonômico utilizados.

---

## Contexto da análise

Este fluxo foi desenvolvido para a análise reprodutível de dados de amplicons do gene 16S rRNA e pode ser adaptado a diferentes conjuntos de dados e perguntas biológicas.

A abordagem permite caracterizar a composição taxonômica e a diversidade das comunidades bacterianas, investigar diferenças entre grupos biológicos e identificar táxons potencialmente associados às condições avaliadas.

---

## Licença

Este projeto é distribuído sob a **Licença MIT**. Consulte o arquivo `LICENSE` para mais informações.

---

## Autor

**Diego Pereira**

Bioinformatics Scientist | PhD in Genetics and Molecular Biology | Metagenomic and Metatranscriptomic Data Analysis
