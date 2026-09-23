# E. coli IHIT46532 Whole-Genome Sequencing Variant Analysis

## Overview

This project presents a reference-based whole-genome sequencing (WGS) analysis of the *Escherichia coli* isolate **IHIT46532** using Illumina paired-end sequencing data from **SRA run SRR22895617**.

The analysis was performed to identify genomic variants in the sequenced isolate relative to the **E. coli K-12 substr. MG1655 reference genome**, followed by variant filtering and functional effect prediction using SnpEff.

The workflow includes:

**Raw sequencing reads → Quality control → Read trimming → Reference alignment → BAM processing → Alignment QC → Haploid variant calling → Variant filtering → High-confidence variant set → Functional annotation → Protein-changing and high-impact variant extraction**

---

## Project Objective

The main objective was to perform a reproducible reference-based WGS variant analysis of *E. coli* IHIT46532.

Specifically, the analysis aimed to:

1. Assess the quality of the raw Illumina reads.
2. Remove low-quality bases and adapter-contaminated sequence.
3. Align sequencing reads to a complete *E. coli* reference genome.
4. Evaluate alignment quality and genome coverage.
5. Identify SNPs and small insertions/deletions (INDELs).
6. Apply quality, depth, mapping-quality and allele-support filters.
7. Annotate variants according to their predicted effects on genes and proteins.
8. Identify protein-changing and SnpEff HIGH-impact variants.
9. Produce a compact set of final results suitable for downstream interpretation.

---

# Dataset

| Property | Information |
|---|---|
| Organism | *Escherichia coli* |
| Isolate | IHIT46532 |
| SRA Run | SRR22895617 |
| Study | SRP414906 |
| BioProject | PRJNA916215 |
| BioSample | SAMN32414682 |
| Sequencing | Illumina paired-end WGS |
| Analysis type | Reference-based variant analysis |

The raw sequencing data were obtained from the Sequence Read Archive and converted into paired FASTQ files before analysis.

---

# Reference Genome

The primary reference used for variant calling was:

**E. coli K-12 substr. MG1655**

| Property | Information |
|---|---|
| RefSeq assembly | GCF_000005845.2 |
| Assembly name | ASM584v2 |
| Chromosome | NC_000913.3 |
| Genome size | 4,641,652 bp |
| Reference type | Complete reference genome |

K-12 MG1655 is a well-established complete *E. coli* reference genome. NCBI lists **GCF_000005845.2** as its RefSeq assembly and **NC_000913.3** as the chromosome accession.

### Why was K-12 MG1655 used?

A complete, well-annotated reference genome was required for reference-based alignment and variant calling.

K-12 MG1655 provides:

- a complete chromosome,
- stable reference coordinates,
- annotated genes,
- a standard reference for *E. coli* genomic analysis.

However, K-12 MG1655 is not the same strain as IHIT46532. Therefore, the variants reported in this project should be interpreted as:

> **Genomic differences between IHIT46532 and the K-12 MG1655 reference genome**

They should **not automatically be described as newly acquired or novel mutations**.

A lower mapping rate can occur when the sequenced isolate differs substantially from the selected reference. Therefore, reference choice is an important limitation of this analysis.

---

# Analysis Environment

The analysis was performed in Linux/WSL using a dedicated Conda environment:

```bash
conda activate ecoli_dna
Main tools used:

FastQC
fastp
BWA-MEM2
SAMtools
BCFtools
SnpEff

                    Raw Illumina FASTQ
                           │
                           ▼
                      FastQC
                           │
                           ▼
                         fastp
                 Quality + adapter trimming
                           │
                           ▼
                    BWA-MEM2
                  Reference alignment
                           │
                           ▼
                       SAM file
                           │
                           ▼
                    BAM conversion
                           │
                           ▼
                    BAM sorting
                           │
                           ▼
                    BAM indexing
                           │
                           ▼
                  SAMtools QC
                           │
                           ▼
                  BCFtools mpileup
                           │
                           ▼
                 BCFtools variant calling
                       Haploid model
                           │
                           ▼
                  Quality filtering
                           │
                           ▼
              High-confidence variant set
                           │
                           ▼
                       SnpEff
                 Functional annotation
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
   Protein-changing variants      HIGH-impact variants

1. Raw Read Quality Control

FastQC was used to evaluate the original paired-end FASTQ files.

FastQC summary

Most important observations:

QC metric	Result
Per-base sequence quality	PASS
Per-sequence quality	PASS
Per-sequence GC content	PASS
Per-base N content	PASS
Adapter content	PASS
Per-base sequence content	WARN
Sequence length distribution	WARN
Duplication levels	WARN
Interpretation

The most important quality indicators were satisfactory.

Both reads showed:

good per-base quality,
good per-sequence quality,
acceptable GC distribution,
no concerning N content,
PASS for adapter content.

Warnings in sequence composition, length distribution and duplication were retained as QC observations rather than automatically treating the dataset as unusable.

2. Read Trimming and Filtering

The paired reads were processed using fastp.

Before filtering

Read 1:

Total reads: 2,997,563
Q20: 97.20%
Q30: 93.71%

Read 2:

Total reads: 2,997,563
Q20: 96.46%
Q30: 92.22%
After filtering
Read pairs retained: 2,979,656
Read pairs removed: approximately 17,907
Low-quality reads removed: 35,112 individual reads
Reads with too many Ns removed: 702
Adapter-trimmed reads: 16,268
Reads removed because they were too short: 0
Adapter dimers detected: 0

The retained reads therefore represented approximately 99.4% of the original read pairs.

Interpretation

Only a small proportion of reads required removal or correction, indicating that the sequencing dataset was already of relatively good quality.

The Q30 percentages were above 92% for both read directions before filtering and improved slightly after processing.

3. Reference Alignment

The cleaned paired-end reads were aligned to the K-12 MG1655 reference genome using BWA-MEM2.

The resulting SAM file was converted to BAM, sorted and indexed using SAMtools.

Why BWA-MEM2?

BWA-MEM2 is designed for mapping sequencing reads to a reference genome and is appropriate for short-read DNA sequencing data.

The workflow was:

FASTQ
  ↓
BWA-MEM2
  ↓
SAM
  ↓
BAM
  ↓
Sorted BAM
  ↓
BAM index
4. Alignment Quality

SAMtools flagstat was used to evaluate the final sorted BAM file.

Actual alignment results
Metric	Result
Total alignment records	5,974,897
Primary reads	5,959,312
Primary mapped reads	4,587,010
Primary mapped percentage	76.97%
Properly paired reads	4,535,812
Properly paired percentage	76.11%
Singletons	23,646
Singleton percentage	0.40%
Mates on different chromosomes	0
Reported duplicates	0
Interpretation

Approximately 76.97% of primary reads mapped to the K-12 reference.

Approximately 76.11% of reads were properly paired.

The absence of reads whose mates mapped to another chromosome is consistent with the reference containing a single chromosome sequence for this analysis.

The reported duplicate count is zero because duplicate marking was not performed in this workflow. Therefore, this value should not be interpreted as proof that the biological library contained no duplicate molecules.

5. Genome Coverage

SAMtools coverage was used to summarize reference coverage.

Actual result
Metric	Result
Reference length	4,641,652 bp
Bases covered	4,202,484 bp
Genome coverage	90.54%
Mean depth	133.81×
Mean base quality	33.1
Mean mapping quality	58.5
Interpretation

The mapped reads provided a high average sequencing depth of approximately 133.8×.

Approximately 90.54% of the K-12 reference genome had at least one mapped base.

It is important to distinguish:

Coverage = proportion of the reference genome covered by at least one read.
Depth = average number of reads covering a genomic position.

Therefore, the dataset had high sequencing depth over most of the reference, although approximately 9.46% of the reference had no mapped read coverage.

6. Variant Calling

Because E. coli is haploid, variant calling was performed using a haploid model in BCFtools.

The main calling workflow was:

Sorted BAM
    ↓
bcftools mpileup
    ↓
bcftools call
    ↓
Haploid variant calls

A maximum depth of 1000 was used during mpileup to avoid excessive depth-related filtering while retaining the high-depth data.

7. Variant Filtering

The raw haploid variant calls were filtered using:

QUAL >= 30
DP >= 10
MQ >= 30
ALT allele fraction >= 90%
Meaning of the filters

QUAL ≥ 30

Retains variants with stronger statistical support from the variant caller.

DP ≥ 10

Requires at least 10 reads covering the position.

MQ ≥ 30

Requires adequate mapping quality.

ALT allele fraction ≥ 90%

For this haploid isolate, the alternate allele was required to represent at least 90% of the observed allele-supporting reads.

This final criterion was used to reduce calls that looked inconsistent with a predominantly haploid genotype.

8. Final High-Confidence Variant Set

The final high-confidence VCF contained:

Variant type	Number
Total variants	89,800
SNPs	89,416
INDELs	384

Therefore, the final variant set consisted predominantly of SNPs.

Important interpretation

These 89,800 variants are not automatically 89,800 novel mutations.

They represent sequence differences detected between:

IHIT46532

and

E. coli K-12 MG1655

under the filtering criteria used in this analysis.

Because the selected reference is a different strain, many differences may represent normal strain-level genomic variation.

The relatively high number of differences, together with approximately 77% primary mapping, also indicates that reference relatedness should be considered when interpreting the final variant set.

9. Functional Annotation with SnpEff

The high-confidence variants were functionally annotated using SnpEff.

SnpEff assigns predicted effects to variants based on their genomic location and annotated genes. Its ANN field reports information such as:

variant effect,
predicted impact,
gene,
gene ID,
coding consequence,
amino-acid change,
HGVS notation.

SnpEff categorizes predicted impacts as HIGH, MODERATE, LOW or MODIFIER.

These categories are computational predictions and should not be interpreted as experimental proof of functional consequences.

10. SnpEff Functional Effect Results

The major annotation categories were:

Effect	Annotation records
Downstream gene variant	445,125
Upstream gene variant	432,081
Synonymous variant	68,538
Missense variant	10,984
Intergenic region	7,940
Non-coding transcript variant	1,849
Non-coding transcript exon variant	426
Stop gained	68
Frameshift variant	31
Stop lost + splice-region variant	16
Start lost	7

Additional less frequent effects were also detected.

Why are these numbers larger than 89,800?

The SnpEff counts are annotation records, not necessarily unique genomic variants.

One genomic variant can produce more than one annotation because:

a variant can affect multiple genomic features,
a variant can be associated with different annotations,
SnpEff can report multiple effects for the same variant.

Therefore, annotation-record counts should not be added together and interpreted as independent mutations.

11. Protein-Changing Variants

A subset of the SnpEff results was extracted to focus on predicted protein-changing consequences.

Result

11,133 protein-changing annotation records

The major categories were:

Effect	Count
Missense variant	10,984
Stop gained	68
Frameshift variant	31
Stop lost + splice-region variant	16
Conservative in-frame deletion	9
Start lost	7
Frameshift + stop lost + splice-region	5
Frameshift + splice-region	4
Disruptive in-frame deletion	4
Frameshift + start lost	2
Disruptive in-frame insertion	2
Conservative in-frame insertion	1

These annotations indicate that a subset of the detected genomic differences is predicted to alter protein sequences.

12. HIGH-Impact Variants

SnpEff classified 133 annotation records as HIGH impact.

These corresponded to 119 unique genes.

Examples of HIGH-impact consequences included:

stop_gained
frameshift_variant
start_lost
stop_lost
Examples
mbiA

A stop_gained variant was annotated as:

p.Trp146*

This means the predicted protein contains a premature stop at amino acid 146.

The K-12 reference protein is annotated as 161 amino acids long.

yabQ

A frameshift variant was predicted around amino acid 36:

p.Lys36fs

A frameshift can alter the downstream reading frame.

lacZ

A stop_gained variant was annotated as:

p.Tyr254*

The reference protein is annotated as 1024 amino acids long.

ybdL

A variant was annotated as:

frameshift_variant&start_lost
p.Met1fs

This affects the beginning of the predicted coding sequence.

Interpretation

These variants are useful candidates for further biological investigation.

However:

A SnpEff HIGH-impact annotation does not prove that a gene is experimentally non-functional.

SnpEff itself describes HIGH as a putative impact category intended for prioritization. Functional consequences require additional evidence or experimental validation.

13. Unique HIGH-Impact Genes

The analysis identified:

119 unique genes

with at least one SnpEff HIGH-impact annotation.

The complete list is available from the analysis output and can be used for downstream investigation such as:

gene function analysis,
pathway analysis,
literature review,
resistance-associated gene investigation,
comparative genomics,
experimental validation.
14. Gene-Level Variant Summary

The file:

results/SRR22895617_gene_variant_counts.txt

contains counts of protein-changing annotation records associated with each gene.

The highest counts included:

ypjA   77
yehI   73
yfaL   70
yeeJ   70
yghJ   58
yjgL   55
flu    50
yccE   48
ybgQ   42
yabP   41

These counts should be interpreted carefully.

For example, a gene having 77 annotation records does not necessarily mean that the gene contains 77 independent biological mutations. SnpEff can produce multiple annotation records for the same genomic variant.

15. Results Directory

The results/ directory contains the main final outputs of the project.

results/
│
├── SRR22895617_high_confidence.vcf.gz
├── SRR22895617_high_confidence.vcf.gz.csi
├── SRR22895617_high_confidence.tsv
├── SRR22895617_protein_changing_variants.tsv
├── SRR22895617_high_impact_variants.tsv
└── SRR22895617_gene_variant_counts.txt
SRR22895617_high_confidence.vcf.gz

The main compressed VCF containing the final high-confidence variant set.

This is the primary machine-readable variant result.

It contains the genomic coordinates, reference alleles, alternate alleles and variant-level information.

SRR22895617_high_confidence.vcf.gz.csi

Index file for the compressed VCF.

It allows software to access genomic regions efficiently without reading the entire compressed VCF.

SRR22895617_high_confidence.tsv

Human-readable tabular representation of the high-confidence variant information.

This is convenient for directly inspecting variant coordinates, alleles, quality, depth, mapping quality and allele-support information.

SRR22895617_protein_changing_variants.tsv

Contains variants with predicted protein-changing effects, including missense, stop-gained, frameshift and related consequences.

SRR22895617_high_impact_variants.tsv

Contains SnpEff annotations classified as HIGH impact.

This is the main file for reviewing potentially disruptive predicted effects.

SRR22895617_gene_variant_counts.txt

Provides a gene-level summary of protein-changing annotation records.

16. QC Directory
qc/
└── alignment_flagstat.txt
alignment_flagstat.txt

Contains the SAMtools flagstat alignment summary.

It records:

total reads,
mapped reads,
properly paired reads,
singletons,
supplementary/secondary alignments,
duplicate status,
cross-chromosome mapping.
17. Scripts Directory
scripts/
├── variant_analysis_commands.sh
└── variant_summary_commands.sh
variant_analysis_commands.sh

Contains the main commands used for:

FastQC
fastp
BWA-MEM2
SAMtools
BCFtools
SnpEff
variant_summary_commands.sh

Contains commands used to summarize:

total variants,
SNPs,
INDELs,
unique HIGH-impact genes.
18. Files Deliberately Excluded

Large intermediate files such as:

*.fastq
*.sam
*.bam

were not included in the GitHub repository.

This keeps the repository lightweight while retaining the most important final outputs and the complete analysis workflow.

The original sequencing data remain publicly available through the SRA accession:

SRR22895617
19. Important Limitations
Reference relatedness

The primary limitation is the use of K-12 MG1655 as the reference for the IHIT46532 isolate.

The sample and reference are different E. coli strains.

Therefore:

not every detected variant represents a newly acquired mutation;
many variants may represent strain-level differences;
the relatively high number of variants should be interpreted in the context of reference relatedness;
the ~76.97% primary mapping rate indicates that a substantial fraction of reads did not map to the selected reference.

A closer, independently generated reference genome could potentially improve alignment and reduce reference-related variant inflation.

No duplicate marking

Duplicate marking was not performed.

Therefore, the 0 duplicates reported by SAMtools flagstat means that duplicate reads were not marked as duplicates in the BAM, rather than proving that no duplicate sequencing molecules exist.

SnpEff predictions

SnpEff annotations are computational predictions.

A HIGH-impact annotation does not by itself prove:

loss of gene function,
loss of protein function,
altered phenotype,
antibiotic resistance,
pathogenicity,
or a causal mutation.

Further comparative, experimental or literature-based evidence would be required.

Variant count interpretation

The final 89,800 variants should not be described as 89,800 novel mutations.

The appropriate description is:

89,800 high-confidence genomic variants relative to the E. coli K-12 MG1655 reference under the filtering criteria used in this analysis.

20. Reproducibility

The analysis workflow is documented in:

scripts/variant_analysis_commands.sh

and

scripts/variant_summary_commands.sh

The final results are stored in:

results/

and alignment QC is stored in:

qc/alignment_flagstat.txt

The analysis used a dedicated Conda environment:

ecoli_dna

with the major tools:

FastQC
fastp
BWA-MEM2
SAMtools
BCFtools
SnpEff
21. Final Results Summary
Category	Result
Primary mapped reads	76.97%
Properly paired reads	76.11%
Genome covered	90.54%
Mean sequencing depth	133.81×
Mean mapping quality	58.5
High-confidence variants	89,800
SNPs	89,416
INDELs	384
Protein-changing annotation records	11,133
HIGH-impact annotation records	133
Unique HIGH-impact genes	119
Conclusion

A complete reference-based WGS variant analysis was performed for E. coli IHIT46532 using Illumina paired-end sequencing data from SRR22895617.

The workflow progressed from raw-read quality assessment through read preprocessing, BWA-MEM2 alignment, SAMtools alignment QC, haploid BCFtools variant calling, quality filtering and SnpEff functional annotation.

The final analysis identified 89,800 high-confidence genomic variants relative to the K-12 MG1655 reference, including 89,416 SNPs and 384 INDELs.

Functional annotation identified 11,133 protein-changing annotation records, including 10,984 missense variants, 68 stop-gained variants, and 31 frameshift variants. SnpEff classified 133 annotation records affecting 119 unique genes as HIGH impact.

These results provide a computationally prioritized set of genomic differences for further investigation. Because the analysis compares IHIT46532 with a different E. coli strain, the detected variants should be interpreted as reference-relative genomic differences rather than automatically as novel mutations.

Project Structure
E_coli_WGS_Variant_Analysis/
│
├── README.md
│
├── scripts/
│   ├── variant_analysis_commands.sh
│   └── variant_summary_commands.sh
│
├── qc/
│   └── alignment_flagstat.txt
│
└── results/
    ├── SRR22895617_high_confidence.vcf.gz
    ├── SRR22895617_high_confidence.vcf.gz.csi
    ├── SRR22895617_high_confidence.tsv
    ├── SRR22895617_protein_changing_variants.tsv
    ├── SRR22895617_high_impact_variants.tsv
    └── SRR22895617_gene_variant_counts.txt
