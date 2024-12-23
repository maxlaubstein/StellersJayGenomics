#https://dominicroye.github.io/en/2022/hillshade-effects/
setwd("~/Desktop/STJA/scripts/")
library(tidyverse)
library(raster)
library(rnaturalearth)
library(elevatr)
library(terra)
library(ggnewscale)
library(readxl)
library(scatterpie)
library(sf)

#Preparing shapefile for states of focal region in North America
NorAm <- rnaturalearth::ne_states(country = c("Canada", "United States of America", "Mexico"))
region <- subset(NorAm, NorAm$name %in% c("British Columbia","Alberta","Saskatchewan",
                                          "Washington","Idaho","Montana",
                                          "Oregon","Wyoming","California",
                                          "Nevada","Utah","Colorado",
                                          "Arizona","New Mexico","Baja California",
                                          "Sonora","Chihuahua", "Texas",
                                          "North Dakota", "South Dakota", "Nebraska"))
region <- region["geometry"]

#region <- st_transform(region, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lon_0=-111.5 +datum=WGS84")

#Retrieve elevation data from within this shapefile:
regionelev <- elevatr::get_elev_raster(locations = region, z = 4, clip = "locations")
regionelev <- rast(regionelev)
regionelev.df <- raster::as.data.frame(regionelev, xy = TRUE) %>% na.omit()
colnames(regionelev.df) <- c("Longitude", "Latitude", "Elevation")

#Shaded relief layer:
slope <- terrain(regionelev, "slope", unit = "radians")
aspect <- terrain(regionelev, "aspect", unit = "radians")
hillshade <- shade(slope, aspect, angle = 45, direction = 300)
hillshade.df <- as.data.frame(hillshade, xy = TRUE) %>% na.omit()
colnames(hillshade.df) <- c("Longitude", "Latitude", "hillshade")

#Prepare k = 6 admixture results to be mapped as pie charts:
k6 <- read.table("../admixture/plink_STJA_forAdmix.6.Q")
k6$ID <- read.table("../plink.fam")$V2

metadata <- read_excel("../1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
metadata <- cbind(metadata, k6V1=NA, k6V2=NA, k6V3=NA, k6V4=NA, k6V5=NA, k6V6=NA)
#add k6 props to metadata for later mapping stuff:
for (i in 1:nrow(metadata)) {
  metadata$k6V1[i]<-subset(k6, k6$ID ==  metadata$sample_name[i])$V1
  metadata$k6V2[i]<-subset(k6, k6$ID ==  metadata$sample_name[i])$V2
  metadata$k6V3[i]<-subset(k6, k6$ID ==  metadata$sample_name[i])$V3
  metadata$k6V4[i]<-subset(k6, k6$ID ==  metadata$sample_name[i])$V4
  metadata$k6V5[i]<-subset(k6, k6$ID ==  metadata$sample_name[i])$V5
  metadata$k6V6[i]<-subset(k6, k6$ID ==  metadata$sample_name[i])$V6
}


localitysummary<-data.frame(pop = rep(NA, 102), samplesize = rep(NA, 102), averageV1 = rep(NA, 102), averageV2 = rep(NA, 102), averageV3 = rep(NA, 102), averageV4 = rep(NA, 102), averageV5 = rep(NA, 102), averageV6 = rep(NA, 102), longitude = rep(NA, 102), latitude = rep(NA, 102))
localitysummary <- data.frame(pop = 1:102) %>%
  cbind(samplesize = NA, averageV1 = NA, averageV2 = NA, averageV3 = NA, averageV4 = NA, averageV5 = NA, averageV6 = NA, longitude = NA, latitude = NA)

for (i in 1:102) {
  localitydata<-subset(metadata, metadata$`Pop # rev` == localitysummary$pop[i])
  localitysummary$samplesize[i]<-nrow(localitydata)
  localitysummary$averageV1[i]<-mean(localitydata$k6V1)
  localitysummary$averageV2[i]<-mean(localitydata$k6V2)
  localitysummary$averageV3[i]<-mean(localitydata$k6V3)
  localitysummary$averageV4[i]<-mean(localitydata$k6V4)
  localitysummary$averageV5[i]<-mean(localitydata$k6V5)
  localitysummary$averageV6[i]<-mean(localitydata$k6V6)
  localitysummary$longitude[i] <- median(localitydata$longitude)
  localitysummary$latitude[i]<-median(localitydata$latitude)
}

#ADMIXTURE MAP K = 6
ggplot()+
  geom_tile(data = hillshade.df, aes(x=Longitude, y = Latitude, fill = hillshade), show.legend = FALSE)+
  scale_fill_distiller(palette = "Greys", direction = 1)+
  new_scale_fill()+
  geom_tile(data = regionelev.df, aes(x=Longitude, y = Latitude, fill = Elevation), alpha = 0.5)+
  scale_fill_distiller(palette = "Greys", direction = 1)+
  geom_sf(data = region, fill = NA, lwd = .6)+
  coord_sf(xlim = c(-130, -103.5), ylim = c(30, 50), expand = FALSE)+
  new_scale_fill()+
  geom_scatterpie(data = localitysummary, aes(x=longitude,y=latitude, r = .3), cols = c("averageV1", "averageV2", "averageV3", "averageV4", "averageV5", "averageV6"), show.legend = FALSE)+
  scale_fill_manual(values = alpha(c("#fd7f6f", "cyan","#ffb55a", "#b2e061", "#7eb0d5", "#ffee65"), 0.6))+
  theme_minimal()
