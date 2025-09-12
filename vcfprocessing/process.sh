#!/bin/bash

cd /media/maxlaubstein/data1/STJARangewideGenomics/data

#Process the raw vcf file to include only biallelic SNPs with a minor allele frequency of 0.05 and maximum missingness of 0.25

vcftools --gzvcf /media/maxlaubstein/data1/STJARangewideGenomics/data/41-Cyanocitta_raw.vcf.gz \
  --bed 41-Cyanocitta_callable_sites.bed \
  --min-alleles 2 \
  --max-alleles 2 \
  --max-missing 1.0 \
  --maf 0.05 \
  --remove-indels \
  --recode \
  --recode-INFO-all \
  --out Cyanocitta_clean

mv Cyanocitta_clean.recode.vcf Cyanocitta_clean.vcf

bgzip Cyanocitta_clean.vcf

tabix -p vcf Cyanocitta_clean.vcf.gz

#Generate a version of the 'clean' vcf file with only autosomal SNPs, removing the known sex-linked and mitochondrial scaffolds:

vcftools --gzvcf /media/maxlaubstein/data1/STJARangewideGenomics/data/Cyanocitta_clean.vcf.gz \
  --not-chr JANXIP010000003.1 \
  --not-chr JANXIP010000028.1 \
  --not-chr JANXIP010000079.1 \
  --not-chr JANXIP010000352.1 \
  --recode \
  --recode-INFO-all \
  --out Cyanocitta_Clean_Autosomal

mv Cyanocitta_Clean_Autosomal.recode.vcf Cyanocitta_Clean_Autosomal.vcf

bgzip Cyanocitta_Clean_Autosomal.vcf

tabix -p vcf Cyanocitta_Clean_Autosomal.vcf.gz

#Generate a version of the 'clean' autosomal VCF excluding the Mesoamerican samples

vcftools --gzvcf /media/maxlaubstein/data1/STJARangewideGenomics/data/Cyanocitta_Clean_Autosomal.vcf.gz \
  --min-alleles 2 \
  --max-alleles 2 \
  --remove-indv MVZ188144 \
  --remove-indv MVZ189266 \
  --remove-indv MVZ189267 \
  --remove-indv UWBM106814 \
  --recode \
  --recode-INFO-all \
  --out Cyanocitta_Clean_Autosomal_No_Mesoamerica

mv Cyanocitta_Clean_Autosomal_No_Mesoamerica.recode.vcf Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf

bgzip Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf

tabix -p vcf Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz

#Generate a linkage disequilibrium pruned VCF from the clean autosomal data:

plink --vcf /media/maxlaubstein/data1/STJARangewideGenomics/data/Cyanocitta_Clean_Autosomal.vcf.gz \
  --const-fid \
  --allow-extra-chr \
  --allow-no-sex \
  --set-missing-var-ids @:# \
  --indep-pairwise 50 10 0.1 \
  --out Cyanocitta_LDPruned_Autosomal

plink --vcf /media/maxlaubstein/data1/STJARangewideGenomics/data/Cyanocitta_Clean_Autosomal.vcf.gz  \
  --const-fid \
  --allow-extra-chr \
  --allow-no-sex \
  --set-missing-var-ids @:#  \
  --extract Cyanocitta_LDPruned_Autosomal.prune.in \
  --recode vcf \
  --out Cyanocitta_LDPruned_Autosomal

bcftools query -l Cyanocitta_LDPruned_Autosomal.vcf > samplenames

awk '{print $1 "\t" substr($1, 3)}' samplenames > samplenamemap

bcftools reheader -s samplenamemap -o Cyanocitta_LDPruned_Autosomal.vcf.tmp Cyanocitta_LDPruned_Autosomal.vcf

rm Cyanocitta_LDPruned_Autosomal.vcf
mv Cyanocitta_LDPruned_Autosomal.vcf.tmp Cyanocitta_LDPruned_Autosomal.vcf

bgzip Cyanocitta_LDPruned_Autosomal.vcf

tabix -p vcf Cyanocitta_LDPruned_Autosomal.vcf.gz

rm samplenames
rm samplenamemap

#Generate a version of the LD-pruned autosomal VCF excluding the Mesoamerican samples:

vcftools --gzvcf /media/maxlaubstein/data1/STJARangewideGenomics/data/Cyanocitta_LDPruned_Autosomal.vcf.gz  \
  --min-alleles 2 \
  --max-alleles 2 \
  --remove-indv MVZ188144 \
  --remove-indv MVZ189266 \
  --remove-indv MVZ189267 \
  --remove-indv UWBM106814 \
  --recode \
  --recode-INFO-all \
  --out Cyanocitta_LDPruned_Autosomal_No_Mesoamerica

mv Cyanocitta_LDPruned_Autosomal_No_Mesoamerica.recode.vcf Cyanocitta_LDPruned_Autosomal_No_Mesoamerica.vcf

bgzip Cyanocitta_LDPruned_Autosomal_No_Mesoamerica.vcf

tabix -p vcf Cyanocitta_LDPruned_Autosomal_No_Mesoamerica.vcf.gz



