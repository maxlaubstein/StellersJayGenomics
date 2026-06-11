
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
#PETDriest
cd input
Rscript ../make_env_data.r ../NAmerica_current_2.5arcmin_geotiff/current_2-5arcmin_PETDriestQuarter.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
cd ../
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/current_2-5arcmin_PETDriestQuarter.tif.tsv \
    -k 4 \
    --verbose \
    --out output/PETDriest \
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
<img width="7000" height="2000" alt="bio5 tsv_manhattan" src="https://github.com/user-attachments/assets/4277aec3-de9e-4e7e-b3df-34d7550fbe22" />

## BIO15
<img width="7000" height="2000" alt="bio15 tsv_manhattan" src="https://github.com/user-attachments/assets/9b4aec18-5ffe-49cd-a2cd-cc3915a90a57" />

## BIO18
<img width="7000" height="2000" alt="bio18 tsv_manhattan" src="https://github.com/user-attachments/assets/f96fee19-cd35-4fc0-a332-b2e73b249bb1" />

## Min. Temperature Warmest Quarter
<img width="7000" height="2000" alt="minTwarmest tsv_manhattan" src="https://github.com/user-attachments/assets/64d63313-a815-4241-ba33-9df631b4d83b" />

## PET Seasonality
<img width="7000" height="2000" alt="PETSeasonality tsv_manhattan" src="https://github.com/user-attachments/assets/201bd4be-6081-4f66-920c-9d0a358d21c9" />

## PET Driest Quarter
<img width="7000" height="2000" alt="PETDriest tsv_manhattan" src="https://github.com/user-attachments/assets/8dc1ddd3-ff69-4785-a376-726eac049105" />

## BIO15 Peak Plots:
<img width="2800" height="2000" alt="Scaffold_2_LFMM" src="https://github.com/user-attachments/assets/223e7ca6-17b5-4ee0-b091-62c971d9acb6" />
<img width="2800" height="2000" alt="Scaffold_19_LFMM" src="https://github.com/user-attachments/assets/37c2158b-fba5-4cd7-a079-268691b7482f" />




