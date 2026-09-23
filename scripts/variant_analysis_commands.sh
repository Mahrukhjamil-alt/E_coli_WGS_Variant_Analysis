#!/bin/bash

# ============================================================
# E. coli IHIT46532 WGS Variant Analysis
# SRA: SRR22895617
# Reference: E. coli K-12 MG1655
# ============================================================

# Activate environment
conda activate ecoli_dna


# ============================================================
# 1. Quality Control
# ============================================================

fastqc \
/mnt/f/ecoli_ngs/raw_data/SRR22895617_1.fastq \
/mnt/f/ecoli_ngs/raw_data/SRR22895617_2.fastq \
-o /mnt/f/ecoli_ngs/qc/raw_fastqc \
-t 4


# ============================================================
# 2. Adapter and Quality Trimming
# ============================================================

fastp \
-i /mnt/f/ecoli_ngs/raw_data/SRR22895617_1.fastq \
-I /mnt/f/ecoli_ngs/raw_data/SRR22895617_2.fastq \
-o /mnt/f/ecoli_ngs/trimmed/SRR22895617_1.trimmed.fastq \
-O /mnt/f/ecoli_ngs/trimmed/SRR22895617_2.trimmed.fastq \
-h /mnt/f/ecoli_ngs/trimmed/fastp_report.html \
-j /mnt/f/ecoli_ngs/trimmed/fastp_report.json


# ============================================================
# 3. Reference Genome Indexing
# ============================================================

bwa-mem2 index \
/mnt/f/ecoli_ngs/reference/ecoli_K12_MG1655.fasta


# ============================================================
# 4. Read Alignment
# ============================================================

bwa-mem2 mem -t 4 \
/mnt/f/ecoli_ngs/reference/ecoli_K12_MG1655.fasta \
/mnt/f/ecoli_ngs/trimmed/SRR22895617_1.trimmed.fastq \
/mnt/f/ecoli_ngs/trimmed/SRR22895617_2.trimmed.fastq \
> /mnt/f/ecoli_ngs/alignment/SRR22895617.sam


# ============================================================
# 5. Convert SAM to BAM
# ============================================================

samtools view -@ 4 -b \
/mnt/f/ecoli_ngs/alignment/SRR22895617.sam \
> /mnt/f/ecoli_ngs/alignment/SRR22895617.bam


# ============================================================
# 6. Sort BAM
# ============================================================

samtools sort -@ 4 \
-o /mnt/f/ecoli_ngs/alignment/SRR22895617_sorted.bam \
/mnt/f/ecoli_ngs/alignment/SRR22895617.bam


# ============================================================
# 7. Index BAM
# ============================================================

samtools index \
/mnt/f/ecoli_ngs/alignment/SRR22895617_sorted.bam


# ============================================================
# 8. Alignment QC
# ============================================================

samtools flagstat \
/mnt/f/ecoli_ngs/alignment/SRR22895617_sorted.bam

samtools coverage \
/mnt/f/ecoli_ngs/alignment/SRR22895617_sorted.bam


# ============================================================
# 9. Haploid Variant Calling
# ============================================================

bcftools mpileup \
-f /mnt/f/ecoli_ngs/reference/ecoli_K12_MG1655.fasta \
-d 1000 \
-Ou \
/mnt/f/ecoli_ngs/alignment/SRR22895617_sorted.bam \
| bcftools call \
-mv \
--ploidy 1 \
-Oz \
-o /mnt/f/ecoli_ngs/variants/SRR22895617_haploid_raw.vcf.gz


# ============================================================
# 10. Variant Filtering
# ============================================================

bcftools filter \
-i 'QUAL>=30 && INFO/DP>=10 && INFO/MQ>=30' \
/mnt/f/ecoli_ngs/variants/SRR22895617_haploid_raw.vcf.gz \
-Oz \
-o /mnt/f/ecoli_ngs/variants/SRR22895617_test_filtered.vcf.gz


# ============================================================
# 11. Extract High-Confidence Variants
# ============================================================

bcftools query \
-f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t%INFO/DP\t%INFO/MQ\t[%AD]\n' \
/mnt/f/ecoli_ngs/variants/SRR22895617_test_filtered.vcf.gz \
| awk -F'\t' '
{
    split($8,a,",")
    ref=a[1]
    alt=a[2]
    total=ref+alt

    if (total > 0 && alt/total >= 0.90)
        print
}' \
> /mnt/f/ecoli_ngs/variants/SRR22895617_high_confidence.tsv


# ============================================================
# 12. Create High-Confidence VCF
# ============================================================

awk -F'\t' '{print $1"\t"$2"\t"$2}' \
/mnt/f/ecoli_ngs/variants/SRR22895617_high_confidence.tsv \
| sort -k1,1 -k2,2n \
> /mnt/f/ecoli_ngs/variants/SRR22895617_high_confidence_regions.tsv

bcftools view \
-R /mnt/f/ecoli_ngs/variants/SRR22895617_high_confidence_regions.tsv \
-Oz \
-o /mnt/f/ecoli_ngs/variants/SRR22895617_high_confidence.vcf.gz \
/mnt/f/ecoli_ngs/variants/SRR22895617_test_filtered.vcf.gz

bcftools index \
/mnt/f/ecoli_ngs/variants/SRR22895617_high_confidence.vcf.gz


# ============================================================
# 13. SnpEff Annotation
# ============================================================

snpEff \
-c "$CONDA_PREFIX/share/snpeff-4.5covid19-2/snpEff.config" \
ecoli_K12 \
/mnt/f/ecoli_ngs/variants/SRR22895617_high_confidence.vcf.gz \
> /mnt/f/ecoli_ngs/variants/SRR22895617_snpeff_annotated.vcf


# ============================================================
# 14. Extract Protein-Changing Variants
# ============================================================

awk -F'\t' '
BEGIN {
    print "CHROM\tPOS\tREF\tALT\tQUAL\tDP\tMQ\tEFFECT\tIMPACT\tGENE\tGENE_ID\tHGVS_C\tHGVS_P\tAA_POSITION"
}
!/^#/ {
    split($0, f, "\t")
}
' /mnt/f/ecoli_ngs/variants/SRR22895617_snpeff_annotated.vcf
