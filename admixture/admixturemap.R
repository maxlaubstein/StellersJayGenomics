setwd("/media/maxlaubstein/data1/STJARangewideGenomics/admixture_nomeso2")
library(readr)
library(ggplot2)
library(raster)
library(rnaturalearth)
library(elevatr)
library(terra)
library(ggnewscale)
library(readxl)
library(sf)
library(ggfun)
library(ggspatial)
library(mapmixture)
library(ggrastr)

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
regionelev <- elevatr::get_elev_raster(locations = region, z = 5, clip = "locations")
regionelev <- rast(regionelev)
regionelev.df <- raster::as.data.frame(regionelev, xy = TRUE) %>% na.omit()
colnames(regionelev.df) <- c("Longitude", "Latitude", "Elevation")

#Shaded relief layer:
slope <- terrain(regionelev, "slope", unit = "radians")
aspect <- terrain(regionelev, "aspect", unit = "radians")
hillshade <- shade(slope, aspect, angle = 45, direction = 120)
hillshade.df <- as.data.frame(hillshade, xy = TRUE) %>% na.omit()
colnames(hillshade.df) <- c("Longitude", "Latitude", "hillshade")

range <- read_sf("/media/maxlaubstein/data1/STJARangewideGenomics/STJAMainRange.kml")



#Prepare k = 4 admixture results to be mapped as pie charts:
k4 <- read.table("/media/maxlaubstein/data1/STJARangewideGenomics/admixture_nomeso2/seed1/Cyanocitta_LDPruned_Autosomal_nomeso.4.Q")
k4$ID <- read.table("/media/maxlaubstein/data1/STJARangewideGenomics/admixture_nomeso2/Cyanocitta_LDPruned_Autosomal_nomeso.fam")$V2

metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
metadata <- subset(metadata, metadata$isolate != "Middle America")
metadata$`Pop # rev` <- as.numeric(metadata$`Pop # rev`)

metadata <- cbind(metadata, k4V1=NA, k4V2=NA, k4V3=NA, k4V4=NA)
#add k4 props to metadata for later mapping stuff:

for (i in 1:nrow(metadata)) {
  metadata$k4V1[i]<-subset(k4, k4$ID ==  metadata$sample_name[i])$V1
  metadata$k4V2[i]<-subset(k4, k4$ID ==  metadata$sample_name[i])$V2
  metadata$k4V3[i]<-subset(k4, k4$ID ==  metadata$sample_name[i])$V3
  metadata$k4V4[i]<-subset(k4, k4$ID ==  metadata$sample_name[i])$V4
}


localitysummary <- data.frame(pop = 1:102) %>%
  cbind(samplesize = NA, averageV1 = NA, averageV2 = NA, averageV3 = NA, averageV4 = NA, longitude = NA, latitude = NA)

for (i in 1:102) {
  localitydata<-subset(metadata, metadata$`Pop # rev` == localitysummary$pop[i])
  localitysummary$samplesize[i]<-nrow(localitydata)
  localitysummary$averageV1[i]<-mean(localitydata$k4V1)
  localitysummary$averageV2[i]<-mean(localitydata$k4V2)
  localitysummary$averageV3[i]<-mean(localitydata$k4V3)
  localitysummary$averageV4[i]<-mean(localitydata$k4V4)
  localitysummary$longitude[i] <- median(localitydata$longitude)
  localitysummary$latitude[i]<-median(localitydata$latitude)
  rm(localitydata)
}


#ADMIXTURE MAP K = 4

df <- data.frame(
  site=as.character(localitysummary$pop),
  lat=localitysummary$latitude,
  lon=localitysummary$longitude,
  Cluster1 = localitysummary$averageV1,
  Cluster2 = localitysummary$averageV2,
  Cluster3 = localitysummary$averageV3,
  Cluster4 = localitysummary$averageV4)

radii <- (localitysummary$samplesize*0.025)+0.3

plot <- ggplot()+
  ggrastr::rasterize(geom_tile(data = hillshade.df, aes(x=Longitude, y = Latitude, fill = hillshade), show.legend = FALSE), dev = "ragg")+
  scale_fill_distiller(palette = "Greys", direction = 1)+
  new_scale_fill()+
  ggrastr::rasterize(geom_tile(data = regionelev.df, aes(x=Longitude, y = Latitude, fill = Elevation), alpha = 0.5, show.legend = FALSE), dev = "ragg")+
  scale_fill_distiller(palette = "Greys", direction = 1)+
  geom_sf(data=range, fill=alpha('white',0.2), color=NA)+
  geom_sf(data = region, fill = NA, lwd = .6)+
  coord_sf(xlim = c(-126, -103.5), ylim = c(30, 50), expand = FALSE)+
  add_pie_charts(df,
                 admix_columns = 4:7,
                 lat_column = "lat",
                 lon_column = "lon",
                 pie_colours = alpha(c("#7eb0d5", "#ffee65", "#b2e061", "#fd7f6f"), 0.7),
                 border=0.3,
                 opacity = 0.6,
                 pie_size = radii)+
  theme_minimal()+
  annotation_north_arrow(location="bl")

ggsave("/media/maxlaubstein/data1/STJARangewideGenomics/plots/K4ADMX_map.pdf", plot = plot, width = 5, height = 5, units = "in")
