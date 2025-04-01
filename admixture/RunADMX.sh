#!/bin/bash
cd /media/data2/STJARangewideGenomics/VCFdata
vcftools --vcf 41-Cyanocitta_annotated_pruned_0.6.vcf  --not-chr JANXIP010000003.1 --not-chr JANXIP010000028.1 --not-chr JANXIP010000352.1 --not-chr JANXIP010000079.1 --recode --out autosomal_annotated_pruned

cd /media/data2/STJARangewideGenomics/admixture_analyses/allsamples
plink --vcf ../../VCFdata/autosomal_annotated_pruned.recode.vcf --make-bed --out autosomal_annotated_pruned --allow-extra-chr 
plink --bfile autosomal_annotated_pruned --recode12 --out autosomal_annotated_pruned --allow-extra-chr

for K in 2 3 4 5 6 7 8 9 ; do admixture --cv autosomal_annotated_pruned.ped $K | tee ADMX.all.log${K}.out; done
