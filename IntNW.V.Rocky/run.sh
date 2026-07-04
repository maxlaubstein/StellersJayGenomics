#!/bin/bash

#Make a vcf keeping only callable biallelic snps, no maf or missingness filtering
vcftools --gzvcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/41-Cyanocitta_raw.vcf.gz \
  --min-alleles 2 \
  --max-alleles 2 \
  --keep samples.txt \
  --bed /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/41-Cyanocitta_callable_sites.bed \
  --remove-indels \
  --remove-filtered-all \
  --recode \
  --recode-INFO-all \
  --out clam_snps_callable

bgzip clam_snps_callable.recode.vcf
tabix -p vcf clam_snps_callable.recode.vcf.gz

conda activate clam
#Run clam stat for fst, dxy, etc
clam stat -o results/ -w 25000 -t 10 -c callable.zarr/ --samples samples.tsv clam_snps_callable.recode.vcf.gz


#Windowed R2 scan
plink --vcf clam_snps_callable.recode.vcf.gz --r2 --ld-window-kb 25  --allow-extra-chr --out R2_25kb

bcftools view -h clam_snps_callable.recode.vcf.gz | grep contig | sed 's/.*ID=//;s/,length=/    /;s/>//' >  scaff_lengths.txt
