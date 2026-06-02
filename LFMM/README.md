
Genotype-Environment Association analysis using Latent Factor Mixed Modeling (LFMM) with Steller's Jays.

The script ```envcoor.r``` looks at (and plots) correlations between all of the different bioclim and some envirem variables.

The script ```run_LFMM.r``` runs LFMM on a provided vcf and tif raster file, with the usage ```Rscript run_LFMM.r <vcf> <tif>```.

Because (as far as I can tell) LFMM runs single threaded, I wrote this so I could run LFMM separately for each variable of interest in a separate screen session. For example, in separate screens:

~~~
Rscript run_LFMM.r \
  /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz \
  globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_5.tif 
~~~

~~~
Rscript run_LFMM.r \
  /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz \
  globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_7.tif 
~~~

~~~
Rscript run_LFMM.r \
  /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz \
  globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_15.tif 
~~~

Plot of correlations between different bioclim/envirem variables: 
<img width="766" height="757" alt="Screenshot 2026-06-02 at 5 51 48 PM" src="https://github.com/user-attachments/assets/989f269f-9ce1-4bc5-b074-8f7f5a2bd330" />
