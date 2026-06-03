
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

Plot of correlations between different bioclim/envirem variables: 
<img width="766" height="757" alt="Screenshot 2026-06-02 at 5 51 48 PM" src="https://github.com/user-attachments/assets/989f269f-9ce1-4bc5-b074-8f7f5a2bd330" />
