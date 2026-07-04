#!/bin/bash
Rscript envcoor.r

mkdir -p input
cd input
plink --vcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz \
    --const-fid \
    --allow-extra-chr \
    --allow-no-sex \
    --set-missing-var-ids @:#  \
    --make-bed  \
    --out Cyanocitta_Clean_Autosomal_No_Mesoamerica


Rscript ../make_env_data.r ../globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_5.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
Rscript ../make_env_data.r ../globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_15.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
Rscript ../make_env_data.r ../globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_18.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
Rscript ../make_env_data.r ../NAmerica_current_2.5arcmin_geotiff/current_2-5arcmin_PETDriestQuarter.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
Rscript ../make_env_data.r ../NAmerica_current_2.5arcmin_geotiff/current_2-5arcmin_PETseasonality.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam
Rscript ../make_env_data.r ../NAmerica_current_2.5arcmin_geotiff/current_2-5arcmin_minTempWarmest.tif Cyanocitta_Clean_Autosomal_No_Mesoamerica.fam

cd ../
mkdir -p output

echo running BIO5...
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/wc2.1_2.5m_bio_5.tif.tsv \
    -k 4 \
    --verbose \
    --out output/bio5 \
    --threads 4 \
    --seed 1

echo running BIO15...
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/wc2.1_2.5m_bio_15.tif.tsv \
    -k 4 \
    --verbose \
    --out output/bio15 \
    --threads 4 \
    --seed 1

echo running BIO18...
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/wc2.1_2.5m_bio_18.tif.tsv \
    -k 4 \
    --verbose \
    --out output/bio18 \
    --threads 4 \
    --seed 1

echo running PET Driest...
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/current_2-5arcmin_PETDriestQuarter.tif.tsv \
    -k 4 \
    --verbose \
    --out output/PETDriest \
    --threads 4 \
    --seed 1

echo running PET Seasonality...
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/current_2-5arcmin_PETseasonality.tif.tsv \
    -k 4 \
    --verbose \
    --out output/PETSeasonality \
    --threads 4 \
    --seed 1

echo running Min T Warmest...
schnellfmm --bed input/Cyanocitta_Clean_Autosomal_No_Mesoamerica.bed \
    --cov input/current_2-5arcmin_minTempWarmest.tif.tsv \
    -k 4 \
    --verbose \
    --out output/minTwarmest \
    --threads 4 \
    --seed 1
