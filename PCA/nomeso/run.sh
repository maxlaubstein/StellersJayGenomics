#!/bin/bash

plink --vcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_LDPruned_Autosomal_No_Mesoamerica.vcf.gz --const-fid --allow-extra-chr --allow-no-sex --set-missing-var-ids @:#  --pca  --out Cyanocitta_PCA_nomeso
