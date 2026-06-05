## Assessing Population Structure and Divergence on the Z Chromosome:

Creating a Z only vcf file:
~~~
vcftools --gzvcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_clean.vcf.gz \
  --chr JANXIP010000003.1 \
  --min-alleles 2 \
  --max-alleles 2 \
  --max-missing 1.0 \
  --maf 0.01 \
  --remove-indels \
  --recode \
  --recode-INFO-all \
  --out Cyanocitta_Clean_Z

mv Cyanocitta_Clean_Z.recode.vcf Cyanocitta_Clean_Z.vcf

bgzip Cyanocitta_Clean_Z.vcf

tabix -p vcf Cyanocitta_Clean_Z.vcf.gz
~~~

A version of the file without the 4 Mesoamerican samples:
~~~
vcftools --gzvcf Cyanocitta_Clean_Z.vcf.gz \
  --min-alleles 2 \
  --max-alleles 2 \
  --mac 1 \
  --maf 0.01 \
  --remove-indv MVZ188144 \
  --remove-indv MVZ189266 \
  --remove-indv MVZ189267 \
  --remove-indv UWBM106814 \
  --recode \
  --recode-INFO-all \
  --out Cyanocitta_Clean_Z_No_Mesoamerica
mv Cyanocitta_Clean_Z_No_Mesoamerica.recode.vcf Cyanocitta_Clean_Z_No_Mesoamerica.vcf
bgzip Cyanocitta_Clean_Z_No_Mesoamerica.vcf
tabix -p vcf Cyanocitta_Clean_Z_No_Mesoamerica.vcf.gz
~~~

Prune for Linkage Disequilibrium:
~~~
plink --vcf Cyanocitta_Clean_Z.vcf.gz \
  --const-fid \
  --allow-extra-chr \
  --allow-no-sex \
  --set-missing-var-ids @:# \
  --indep-pairwise 50 10 0.1 \
  --out Cyanocitta_LDPruned_Z

plink --vcf Cyanocitta_Clean_Z.vcf.gz  \
  --const-fid \
  --allow-extra-chr \
  --allow-no-sex \
  --set-missing-var-ids @:#  \
  --extract Cyanocitta_LDPruned_Z.prune.in \
  --recode vcf \
  --out Cyanocitta_LDPruned_Z

bcftools query -l Cyanocitta_LDPruned_Z.vcf > samplenames

awk '{print $1 "\t" substr($1, 3)}' samplenames > samplenamemap

bcftools reheader -s samplenamemap -o Cyanocitta_LDPruned_Z.vcf.tmp Cyanocitta_LDPruned_Z.vcf

rm Cyanocitta_LDPruned_Z.vcf
mv Cyanocitta_LDPruned_Z.vcf.tmp Cyanocitta_LDPruned_Z.vcf

bgzip Cyanocitta_LDPruned_Z.vcf

tabix -p vcf Cyanocitta_LDPruned_Z.vcf.gz

rm samplenames
rm samplenamemap

vcftools --gzvcf Cyanocitta_LDPruned_Z.vcf.gz \
  --min-alleles 2 \
  --max-alleles 2 \
  --mac 1 \
  --maf 0.01 \
  --remove-indv MVZ188144 \
  --remove-indv MVZ189266 \
  --remove-indv MVZ189267 \
  --remove-indv UWBM106814 \
  --recode \
  --recode-INFO-all \
  --out Cyanocitta_LDPruned_Z_No_Mesoamerica
mv Cyanocitta_LDPruned_Z_No_Mesoamerica.recode.vcf Cyanocitta_LDPruned_Z_No_Mesoamerica.vcf
bgzip Cyanocitta_LDPruned_Z_No_Mesoamerica.vcf
tabix -p vcf Cyanocitta_LDPruned_Z_No_Mesoamerica.vcf.gz
~~~

Run PCA on the LD pruned files, with and without the 4 Mesoamerican samples:
~~~
plink --vcf Cyanocitta_LDPruned_Z.vcf.gz  --const-fid --allow-extra-chr --allow-no-sex --set-missing-var-ids @:#  --pca  --out Z_PCA
plink --vcf Cyanocitta_LDPruned_Z_No_Mesoamerica.vcf.gz  --const-fid --allow-extra-chr --allow-no-sex --set-missing-var-ids @:#  --pca  --out Z_PCA_nomeso
~~~

Plot them:
~~~
Rscript Z_pca_plot.r
Rscript Z_pca_plot_nomeso.r
~~~

Now look at FST in sliding windows:
~~~
awk '$2 >= 69 && $2 <= 79 {print $1}' /media/maxlaubstein/data1/STJARangewideGenomics/populations > IntNW
awk '$2 >= 89 && $2 <= 102 {print $1}' /media/maxlaubstein/data1/STJARangewideGenomics/populations > Rocky

wc -l IntNW
wc -l Rocky

vcftools --gzvcf Cyanocitta_Clean_Z_No_Mesoamerica.vcf.gz \
        --fst-window-size 25000 \
        --fst-window-step 10000 \
        --mac 1 \
        --weir-fst-pop IntNW \
        --weir-fst-pop Rocky \
        --out Z_IntNW.V.Rocky
~~~
