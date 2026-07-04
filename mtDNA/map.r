setwd("/media/maxlaubstein/data1/STJARangewideGenomics/mtDNA")
library(readr)
library(ggplot2)
library(dplyr)
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



mtdna <- read.table("/media/maxlaubstein/data1/STJARangewideGenomics/mtDNA/mtdna_PCA.eigenvec")

metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
metadata$`Pop # rev` <- as.numeric(metadata$`Pop # rev`)
metadata$pc1 <- NA
metadata$haplotype <- NA 
for(i in 1:nrow(metadata)) {
  dat.now <- subset(mtdna, mtdna$V2 == metadata$sample_name[i])
  metadata$pc1[i] <- dat.now$V3
}

metadata[metadata$pc1 >= 0,]$haplotype <- "Coastal"
metadata[metadata$pc1 < 0,]$haplotype <- "Rocky"

localitysummary <- data.frame(pop = 1:102) %>%
  cbind(samplesize = NA, longitude = NA, latitude = NA, propcoastal = NA, proprocky = NA)

for (i in 1:102) {
  localitydata<-subset(metadata, metadata$`Pop # rev` == localitysummary$pop[i])
  localitysummary$samplesize[i]<-nrow(localitydata)
  localitysummary$longitude[i] <- median(localitydata$longitude)
  localitysummary$latitude[i]<-median(localitydata$latitude)
  localitysummary$propcoastal[i] <- ((nrow(localitydata[localitydata$haplotype == "Coastal",]))/localitysummary$samplesize[i])
  localitysummary$proprocky[i] <- (1 - localitysummary$propcoastal[i])
  rm(localitydata)
}



df <- data.frame(
  site=as.character(localitysummary$pop),
  lat=localitysummary$latitude,
  lon=localitysummary$longitude,
  Cluster1 = localitysummary$propcoastal,
  Cluster2 = localitysummary$proprocky
  )

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
                 admix_columns = 4:5,
                 lat_column = "lat",
                 lon_column = "lon",
                 pie_colours = c('#fd7f6f', '#7eb0d5'),
                 border=0.3,
                 opacity = 0.8,
                 pie_size = radii)+
  theme_minimal()+
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )
ggsave(plot = plot, filename = "/media/maxlaubstein/data1/STJARangewideGenomics/plots/mtdna_map.pdf", device = "pdf", height = 2.625, width = 2.625, units = "in")
