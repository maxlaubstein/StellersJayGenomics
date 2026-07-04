#!/bin/bash

plink --vcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_clean.vcf.gz --chr JANXIP010000352.1 --const-fid --allow-extra-chr --allow-no-sex --set-missing-var-ids @:#  --pca  --out mtdna_PCA
