#!/bin/bash
cd /media/data2/STJARangewideGenomics/VCFdata
vcftools --vcf autosomal_annotated_pruned.recode.vcf  --remove ../admixture_analyses/nomeso/meso --recode --out autosomal_annotated_pruned_nomeso

cd /media/data2/STJARangewideGenomics/admixture_analyses/nomeso
plink --vcf ../../VCFdata/autosomal_annotated_pruned_nomeso.recode.vcf --make-bed --out autosomal_annotated_pruned_nomeso --allow-extra-chr 
plink --bfile autosomal_annotated_pruned_nomeso --recode12 --out autosomal_annotated_pruned_nomeso --allow-extra-chr

for K in 2 3 4 5 6 7 8 9 ; do admixture --cv autosomal_annotated_pruned_nomeso.ped $K | tee ADMX.all.log${K}.out; done
