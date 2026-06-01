set.seed(16)
#thin the vcf:
system("vcftools /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_LDPruned_Autosomal_No_Mesoamerica.vcf.gz --thin 9000 --out thinned_nomeso --recode")
system("bgzip -c thinned_nomeso.recode.vcf > thinned_nomeso.vcf.gz") #bgzip the thinned vcf
system(" ./vcf2genepop.sh --vcf thinned_nomeso.vcf.gz") #convert vcf to GENEPOP
library(parallel)
library(diveRsity)
source("../divMigrate_MODIFIED.R")
source("../rgp_MODIFIED.R")
message("Running DivMigrate...")
output <- divMigrate("GENEPOP", boots = 1000, para = TRUE, stat = "Nm")
message("Writing Output...")
write.table(output$nmRelMig, "nmRelMig.txt")
write.table(output$nmRelMigSig, "nmRelMigSig.txt")
message("Done!")
