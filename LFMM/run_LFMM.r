set.seed(16)
library(terra)
library(geodata)
library(readxl)
library(raster)
library(ggplot2)
library(dplyr)
library(algatr)
library(vcfR)

args <- commandArgs(trailingOnly = TRUE)

# Check that we got arguments
if(length(args) != 2){
  stop("Usage: Rscript run_LFMM.r <vcf> <env_tif>")
}

vcf <- args[1]
tif <- args[2]

metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
metadata <- subset(metadata, metadata$isolate != "Middle America")

#At 2.5 arcminute resolution, it thinks this one sample from San Luis Obispo is in the ocean, and returns NA for envirem data. Here I just slightly nudge the latitude to push the point 'on land'
metadata[metadata$sample_name == "MVZCCGP-Cst97_I-B07",]$latitude <- 35.573797

#convert vcf to dosage matrix
gen <- vcf_to_dosage(vcf)

#becauce vcf has already been filtered to only non-missing sites, I don't need to impute with simple_impute(gen)

#### Preparing Environmental Data:
message("Preparing Environmental Data...")
message(paste0("Variable: ", basename(tif)))
env_var_rast <- rast(tif)

#create env dataframe with the variable values for each coordinate
env <- data.frame(
  individual = rownames(gen)
)

for(i in 1:nrow(env)){
  samp.now <- subset(metadata, metadata$sample_name == env$individual[i])
  env$long[i] <- samp.now$longitude
  env$lat[i] <- samp.now$latitude
  rm(samp.now)
}

env$var <- raster::extract(env_var_rast, cbind(env$long, env$lat))[,1]

message("Environmental and Genomic Data Match Up?")
identical(rownames(gen), env[,1])

message("Running LFMM...")
ridge_results <- lfmm_run(gen, env$var, K = 4, lfmm_method = "ridge") 

message("Saving Output...")

write.table(ridge_results$df, file = paste0(vcf,"_", basename(tif), "_ridge_results.txt"))

