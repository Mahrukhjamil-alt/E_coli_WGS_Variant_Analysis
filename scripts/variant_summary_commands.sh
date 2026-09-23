#!/bin/bash

# Variant summary

# Total variants
bcftools view -H \
/mnt/f/ecoli_ngs/variants/SRR22895617_high_confidence.vcf.gz | wc -l

# SNPs
bcftools view -H -v snps \
/mnt/f/ecoli_ngs/variants/SRR22895617_high_confidence.vcf.gz | wc -l

# INDELs
bcftools view -H -v indels \
/mnt/f/ecoli_ngs/variants/SRR22895617_high_confidence.vcf.gz | wc -l

# Number of unique HIGH-impact genes
awk -F'\t' 'NR>1 {print $10}' \
/mnt/f/ecoli_ngs/results/SRR22895617_high_impact_variants.tsv \
| sort -u \
> /mnt/f/ecoli_ngs/results/SRR22895617_high_impact_genes.txt

wc -l \
/mnt/f/ecoli_ngs/results/SRR22895617_high_impact_genes.txt
