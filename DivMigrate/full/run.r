set.seed(16)
system(" ./vcf2genepop.sh --vcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_LDPruned_Autosomal_No_Mesoamerica.vcf.gz") #convert vcf to GENEPOP
library(parallel)
library(diveRsity)
source("../divMigrate_MODIFIED.R")
source("../rgp_MODIFIED.R")
message("Running DivMigrate...")
output <- divMigrate("GENEPOP", para = TRUE, stat = "Nm")
message("Writing Output...")
write.table(output$nmRelMig, "nmRelMig.txt")
write.table(output$nmRelMigSig, "nmRelMigSig.txt")
message("Done!")


#Now create a table with the mean bidirectional rates:
pops <- readLines("pops")
nm <- read.table("nmRelMig.txt")
colnames(nm) <- rownames(nm) <- pops

means <- (nm + t(nm))/2
means == t(means)
write.table(means, "mean_bidirectional_nm.txt")
