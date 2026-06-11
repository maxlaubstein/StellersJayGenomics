
## Genotype-Environment Association analysis using Latent Factor Mixed Modeling (LFMM) with Steller's Jays.

The script ```envcoor.r``` looks at (and plots) correlations between all of the different bioclim and some envirem variables.

I'm using the new implementation of LFMM in **schnelLFMM** (https://github.com/kdm9/schnelLFMM), which works much better for big SNP datasets.

First I have to convert the vcf into a plink bed file for input:
~~~
mkdir -p input
cd input
plink --vcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz \
    --const-fid \
    --allow-extra-chr \
    --allow-no-sex \
    --set-missing-var-ids @:#  \
    --make-bed  \
    --out Cyanocitta_Clean_Autosomal_No_Mesoamerica
~~~

Then, for bio5 as an example, I use ```make_env_data.r``` to make a tsv with environmental values for each sample (in the same order as the plink bed file): 
~~~
Rscript ../make_env_data.r ../globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_5.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
~~~

Now, actually running it:
~~~
cd ../
mkdir -p output
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/wc2.1_2.5m_bio_5.tif.tsv \
    -k 4 \
    --verbose \
    --out output/bio5 \
    --threads 4 \
    --seed 1
~~~

For the rest:

~~~
#BIO15
cd input
Rscript ../make_env_data.r ../globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_15.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
cd ../
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/wc2.1_2.5m_bio_15.tif.tsv \
    -k 4 \
    --verbose \
    --out output/bio15 \
    --threads 4 \
    --seed 1
~~~

~~~
#BIO18
cd input
Rscript ../make_env_data.r ../globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_18.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
cd ../
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/wc2.1_2.5m_bio_18.tif.tsv \
    -k 4 \
    --verbose \
    --out output/bio18 \
    --threads 4 \
    --seed 1
~~~

~~~
#PETWettest
cd input
Rscript ../make_env_data.r ../NAmerica_current_2.5arcmin_geotiff/current_2-5arcmin_PETWettestQuarter.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
cd ../
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/current_2-5arcmin_PETWettestQuarter.tif.tsv \
    -k 4 \
    --verbose \
    --out output/PETWettest \
    --threads 4 \
    --seed 1
~~~

~~~
#PETSeasonality
cd input
Rscript ../make_env_data.r ../NAmerica_current_2.5arcmin_geotiff/current_2-5arcmin_PETseasonality.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
cd ../
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/current_2-5arcmin_PETseasonality.tif.tsv \
    -k 4 \
    --verbose \
    --out output/PETSeasonality \
    --threads 4 \
    --seed 1
~~~

~~~
#minTwarmest
cd input
Rscript ../make_env_data.r ../NAmerica_current_2.5arcmin_geotiff/current_2-5arcmin_minTempWarmest.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
cd ../
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/current_2-5arcmin_minTempWarmest.tif.tsv \
    -k 4 \
    --verbose \
    --out output/minTwarmest \
    --threads 4 \
    --seed 1
~~~

## Plot of correlations between different bioclim/envirem variables: 
<img width="882" height="882" alt="Screenshot 2026-06-11 at 1 36 20 AM" src="https://github.com/user-attachments/assets/be89be07-78f0-4ec5-80bc-4ee5be3ca174" />


## BIO5
<img width="5600" height="1600" alt="bio5 tsv_manhattan" src="https://github.com/user-attachments/assets/7bf88b92-8710-4dc1-8f79-d02f6c808c4b" />

## BIO15
<img width="5600" height="1600" alt="bio15 tsv_manhattan" src="https://github.com/user-attachments/assets/ee7ffbc8-f9e7-4d85-8a2f-5c1d3d4c9ba5" />

## BIO18
<img width="5600" height="1600" alt="bio18 tsv_manhattan" src="https://github.com/user-attachments/assets/4f744e94-c15e-4cc9-aa06-a3eee5d3d320" />

## Min. Temperature Warmest Quarter
<img width="5600" height="1600" alt="minTwarmest tsv_manhattan" src="https://github.com/user-attachments/assets/85d3eda0-b8da-41e4-851e-e6348f418501" />

## PET Seasonality
<img width="5600" height="1600" alt="PETSeasonality tsv_manhattan" src="https://github.com/user-attachments/assets/c518e10c-263f-49b3-9342-a4e80b56c5de" />

## PET Wettest Quarter
<img width="5600" height="1600" alt="PETWettest tsv_manhattan" src="https://github.com/user-attachments/assets/f209b77f-1c97-4ab0-a422-48c9d2c10992" />

## BIO15 Peak Plots:
<img width="2800" height="2000" alt="Scaffold_2_LFMM" src="https://github.com/user-attachments/assets/223e7ca6-17b5-4ee0-b091-62c971d9acb6" />
<img width="2800" height="2000" alt="Scaffold_19_LFMM" src="https://github.com/user-attachments/assets/37c2158b-fba5-4cd7-a079-268691b7482f" />




