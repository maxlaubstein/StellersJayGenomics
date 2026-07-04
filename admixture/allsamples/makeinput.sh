#!/bin/bash

plink --vcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_LDPruned_Autosomal.vcf.gz \
    --const-fid \
    --allow-extra-chr \
    --allow-no-sex \
    --set-missing-var-ids @:#  \
    --make-bed  \
    --out Cyanocitta_LDPruned_Autosomal

plink --bfile Cyanocitta_LDPruned_Autosomal --const-fid --allow-extra-chr --allow-no-sex --recode 12 --out Cyanocitta_LDPruned_Autosomal

