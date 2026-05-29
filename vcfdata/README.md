```process.sh``` is used to filter the raw vcf output from snparcher, creating various vcf files used for downstream analyses.

These include:

```Cyanocitta_clean.vcf.gz``` (only biallelic sites, maf = 0.01, no missing sites)

```Cyanocitta_Clean_Autosomal.vcf.gz``` (only biallelic sites, maf = 0.01, no missing sites, exlcluding known sex-linked and mtdna scaffolds)

```Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz``` 
