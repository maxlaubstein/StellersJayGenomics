library(terra)
library(geodata)
library(readxl)
library(raster)
library(ggplot2)
library(dplyr)
library(LEA)
library(data.table)
library(readr)

args <- commandArgs(trailingOnly = TRUE)

# Check that we got arguments
if(length(args) != 2){
  stop("Usage: Rscript run_LFMM.r <gt_matrix> <env_tif>")
}

gt_matrix <- args[1]
#gt_matrix is dosage matrix from vcftools --012, with first column (row numbers) removed
tif <- args[2]


metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
metadata <- subset(metadata, metadata$isolate != "Middle America")

#At 2.5 arcminute resolution, it thinks this one sample from San Luis Obispo is in the ocean, and returns NA for envirem data. Here I just slightly nudge the latitude to push the point 'on land'
metadata[metadata$sample_name == "MVZCCGP-Cst97_I-B07",]$latitude <- 35.573797

#### Preparing Environmental Data:
message("Preparing Environmental Data...")
message(paste0("Variable: ", basename(tif)))
env_var_rast <- rast(tif)

#create env dataframe with the variable values for each coordinate
env <- data.frame(
  individual = readr::read_lines(paste0(gt_matrix, ".indv"))
)

for(i in 1:nrow(env)){
  samp.now <- subset(metadata, metadata$sample_name == env$individual[i])
  env$long[i] <- samp.now$longitude
  env$lat[i] <- samp.now$latitude
  rm(samp.now)
}

env$var <- raster::extract(env_var_rast, cbind(env$long, env$lat))[,1]
#write env data to file:
write.table(env$var, file = paste0(basename(tif), ".env"), row.names = FALSE, col.names = FALSE, quote = FALSE)

message("Running LFMM...")
ridge_results <- LEA::lfmm2(input = gt_matrix, env = paste0(basename(tif), ".env"), K = 4)

message("Saving Output...")
save(ridge_results, file = paste0(basename(tif), "_ridge_results.RData"))

