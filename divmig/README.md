## Relative Migration Networks of North American Steller's Jays using DivMigrate

The directory ```full``` runs DivMigrate on the full LD-pruned SNP dataset to get point estimates of relative migration rates without any bootstrapping asymmetry analysis.

The directory ```directional``` runs on a downsampled VCF with bootstrapping to infer asymmetries in migration rates.

In both directories, ```run.r``` will run the whole thing. Also in both, the script ```vcf2genepop.sh``` is something I (with help from ChatGTPT) put together using command line text editors like awk to convert vcf files into GENEPOP format.

```divMigrate_MODIFIED.r``` is from the divMigrate package, only slightly modified to handle reading in large files and to show a progress bar for longer runs.
