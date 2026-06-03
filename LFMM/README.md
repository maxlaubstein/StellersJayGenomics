
Genotype-Environment Association analysis using Latent Factor Mixed Modeling (LFMM) with Steller's Jays.

The script ```envcoor.r``` looks at (and plots) correlations between all of the different bioclim and some envirem variables.

The script ```run_LFMM.r``` runs LFMM on a provided 012 genotype dosage matrix and tif raster file, with the usage ```Rscript run_LFMM.r <012_matrix> <tif>```.

I generated the dosage matrix from a vcf file as follows:

~~~
mkdir -p gtmatrix
vcftools --gzvcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz --012 --out Cyanocitta_Clean_Autosomal_No_Mesoamerica
mv Cyanocitta_Clean_Autosomal_No_Mesoamerica* gtmatrix/
cd gtmatrix
cut -f2- Cyanocitta_Clean_Autosomal_No_Mesoamerica.012 > tmp #get rid of rownumbers
mv tmp Cyanocitta_Clean_Autosomal_No_Mesoamerica.012
cd ../
~~~

algatr has a built in function to do this built around vcfR, but it is very slow compared to vcftools.

Because (as far as I can tell) LFMM runs single threaded, I wrote this so I could run LFMM separately for each variable of interest in a separate screen session. For example, in separate screen sessions:

~~~
Rscript run_LFMM.r \
  gtmatrix/Cyanocitta_Clean_Autosomal_No_Mesoamerica.012 \
  globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_5.tif 
~~~


Plot of correlations between different bioclim/envirem variables: 
<img width="766" height="757" alt="Screenshot 2026-06-02 at 5 51 48 PM" src="https://github.com/user-attachments/assets/989f269f-9ce1-4bc5-b074-8f7f5a2bd330" />
