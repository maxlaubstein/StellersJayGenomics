Estimating migration rates (Nm) between specified population groupings of Steller's Jays with DivMigrate.

In the directory ```full``` I use the full autosomal snp dataset to get point estimates of Nm, but dont estimate asymmetry.
In the directory ```directional``` I use a thinned snp dataset, and use bootstrapping in divmigrate to estimate asymmetrical migration.

```popmap``` is a text file specifying population assignments for individual samples.
```vcf2genepop.sh``` is something cobbled together (with the help of chatgpt) that uses vcftools and text editors like awk and sed to convert a vcf file into the GENEPOP format needed for divmigrate.

I had to make some small modifications (with the help of chatgpt) to the ```rgp()``` and ```divMigrate()``` functions in order to allow handling of larger datasets and to show a progress bar when doing the bootstrap replicates. These modified scripts are ```rgp_MODIFIED.R``` and ```divMigrate_MODIFIED.R```.

<img width="739" height="747" alt="Screenshot 2026-06-01 at 5 04 37 PM" src="https://github.com/user-attachments/assets/f90b17dc-2f09-437b-a9a9-124c9da58c49" />
