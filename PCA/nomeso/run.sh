#!/bin/bash


echo -e "MVZ188144\nMVZ189266\nMVZ189267\nUWBM106814" > names
echo -e "0\n0\n0\n0" > fid
paste fid names > meso

plink --vcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_LDPruned_Autosomal.vcf.gz --remove meso --const-fid --allow-extra-chr --allow-no-sex --set-missing-var-ids @:#  --pca  --out Cyanocitta_PCA_nomeso


rm fid
rm meso
rm names
