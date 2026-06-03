suppressWarnings(suppressMessages({
  library(dplyr)
  library(terra)
  library(geodata)
  library(readxl)
  library(raster)
  library(data.table)
  library(readr)
}))

args <- commandArgs(trailingOnly = TRUE)

# Check that we got arguments
if(length(args) != 2){
  stop("Usage: Rscript make_env_data.r <env_tif> <plink_fam>")
}

tif <- args[1]
fam <- args[2]


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
  individual = read.table(fam)$V2
)

for(i in 1:nrow(env)){
  samp.now <- subset(metadata, metadata$sample_name == env$individual[i])
  env$long[i] <- samp.now$longitude
  env$lat[i] <- samp.now$latitude
  rm(samp.now)
}

env$var <- raster::extract(env_var_rast, cbind(env$long, env$lat))[,1]

#write env data to file:
env <- env %>% dplyr::select("individual", "var")
write.table(env, file = paste0(basename(tif), ".tsv"), row.names = FALSE, col.names = TRUE, quote = FALSE)


