set.seed(16)
library(terra)
library(geodata)
library(readxl)
library(raster)
library(ggplot2)
library(dplyr)
library(psych)
library(usdm)

metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
metadata <- subset(metadata, metadata$isolate != "Middle America")

#At 2.5 arcminute resolution, it thinks this one sample from San Luis Obispo is in the ocean, and returns NA for envirem data. Here I just slightly nudge the latitude to push the point 'on land'
metadata[metadata$sample_name == "MVZCCGP-Cst97_I-B07",]$latitude <- 35.573797


#### Preparing Environmental Data:
message("Preparing Environmental Data...")

bio1 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_1.tif")
bio2 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_2.tif")
bio3 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_3.tif")
bio4 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_4.tif")
bio5 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_5.tif")
bio6 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_6.tif")
bio7 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_7.tif")
bio8 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_8.tif")
bio9 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_9.tif")
bio10 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_10.tif")
bio11 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_11.tif")
bio12 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_12.tif")
bio13 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_13.tif")
bio14 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_14.tif")
bio15 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_15.tif")
bio16 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_16.tif")
bio17 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_17.tif")
bio18 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_18.tif")
bio19 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_19.tif")

minTwarmest <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/NAmerica_current_2.5arcmin_geotiff/current_2-5arcmin_minTempWarmest.tif")
PETdriest <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/NAmerica_current_2.5arcmin_geotiff/current_2-5arcmin_PETDriestQuarter.tif")
PETseasonality <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/NAmerica_current_2.5arcmin_geotiff/current_2-5arcmin_PETseasonality.tif")


env <- data.frame(
  individual = metadata$sample_name
)

for(i in 1:nrow(env)){
  samp.now <- subset(metadata, metadata$sample_name == env$individual[i])
  env$long[i] <- samp.now$longitude
  env$lat[i] <- samp.now$latitude
  rm(samp.now)
}

env$bio1 <- raster::extract(bio1, cbind(env$long, env$lat))[,1]
env$bio2 <- raster::extract(bio2, cbind(env$long, env$lat))[,1]
env$bio3 <- raster::extract(bio3, cbind(env$long, env$lat))[,1]
env$bio4 <- raster::extract(bio4, cbind(env$long, env$lat))[,1]
env$bio5 <- raster::extract(bio5, cbind(env$long, env$lat))[,1]
env$bio6 <- raster::extract(bio6, cbind(env$long, env$lat))[,1]
env$bio7 <- raster::extract(bio7, cbind(env$long, env$lat))[,1]
env$bio8 <- raster::extract(bio8, cbind(env$long, env$lat))[,1]
env$bio9 <- raster::extract(bio9, cbind(env$long, env$lat))[,1]
env$bio10 <- raster::extract(bio10, cbind(env$long, env$lat))[,1]
env$bio11 <- raster::extract(bio11, cbind(env$long, env$lat))[,1]
env$bio12 <- raster::extract(bio12, cbind(env$long, env$lat))[,1]
env$bio13 <- raster::extract(bio13, cbind(env$long, env$lat))[,1]
env$bio14 <- raster::extract(bio14, cbind(env$long, env$lat))[,1]
env$bio15 <- raster::extract(bio15, cbind(env$long, env$lat))[,1]
env$bio16 <- raster::extract(bio16, cbind(env$long, env$lat))[,1]
env$bio17 <- raster::extract(bio17, cbind(env$long, env$lat))[,1]
env$bio18 <- raster::extract(bio18, cbind(env$long, env$lat))[,1]
env$bio19 <- raster::extract(bio19, cbind(env$long, env$lat))[,1]


env$minTwarmest <- raster::extract(minTwarmest, cbind(env$long, env$lat))[,1]
env$PETdriest <- raster::extract(PETdriest, cbind(env$long, env$lat))[,1]
env$PETseasonality <- raster::extract(PETseasonality, cbind(env$long, env$lat))[,1]

pdf("env_coor.pdf", width = 14, height = 14)  #

pairs.panels(env[,c("bio1", "bio2", "bio3", "bio4", "bio5", "bio6", 
		"bio7", "bio8", "bio9", "bio10", "bio11", "bio12", 
		"bio13", "bio14", "bio15", "bio16", "bio17", "bio18", 
		"bio19", "minTwarmest", "PETdriest", "PETseasonality")], scale = TRUE)

dev.off()

print(vifcor(env[,c("bio1", "bio2", "bio3", "bio4", "bio5", "bio6",
                "bio7", "bio8", "bio9", "bio10", "bio11", "bio12",
                "bio13", "bio14", "bio15", "bio16", "bio17", "bio18",
                "bio19", "minTwarmest", "PETdriest", "PETseasonality")], th = 0.65))
