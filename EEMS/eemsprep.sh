#!/bin/bash  
#https://github.com/mcaitlinv/cawa-breeding/blob/main/04_esu/scripts/11.conda.eems.sbatch was helpful for data preparation
#Unlinked vcf converted to PLINK format
plink --vcf 41-Cyanocitta_annotated_pruned_0.6.vcf --recode --out unlinkedforEEMS --allow-extra-chr --allow-no-sex --no-sex --no-parents --no-fid --no-pheno 

#Scaffolds reformatted to be compatible with eems pre-processing:
awk 'BEGIN { FS = "\t"};{ OFS="\t" } ; {print 1, $2, $3, $4, $5}' unlinkedforEEMS.map > temp.map
mv temp.map unlinkedforEEMS.map

#Convert to .bed
plink --file unlinkedforEEMS --make-bed --out unlinkedforEEMS

#Use bed2diffs to create genetic (dis)similarity matrix
../eems/bed2diffs/src/bed2diffs_v1 --bfile unlinkedforEEMS --nthreads 2
