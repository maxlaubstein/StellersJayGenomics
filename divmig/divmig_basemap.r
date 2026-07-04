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
library(ggrepel)
library(dplyr)
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
hillshade <- shade(slope, aspect, angle = 45, direction = 120)
hillshade.df <- as.data.frame(hillshade, xy = TRUE) %>% na.omit()
colnames(hillshade.df) <- c("Longitude", "Latitude", "hillshade")

range <- read_sf("/media/maxlaubstein/data1/STJARangewideGenomics/STJAMainRange.kml")


metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
metadata$`Pop # rev` <- as.numeric(metadata$`Pop # rev`)

localitysummary <- data.frame(pop = 1:102) %>%
  cbind(samplesize = NA, longitude = NA, latitude = NA, propcoastal = NA, proprocky = NA)

for (i in 1:102) {
  localitydata<-subset(metadata, metadata$`Pop # rev` == localitysummary$pop[i])
  localitysummary$samplesize[i]<-nrow(localitydata)
  localitysummary$longitude[i] <- median(localitydata$longitude)
  localitysummary$latitude[i]<-median(localitydata$latitude)
  rm(localitydata)
}

cascades_pnw <- subset(localitysummary, localitysummary$pop %in% c(1:4,37:46,51))
ncoastca <- subset(localitysummary, localitysummary$pop %in% c(5:19))
sierra <- subset(localitysummary, localitysummary$pop %in% c(47:50,52:68))
sfbay <- subset(localitysummary, localitysummary$pop %in% c(20:25,28))
cencoastca <- subset(localitysummary, localitysummary$pop %in% c(26,27,29,30))
scoastca <- subset(localitysummary, localitysummary$pop %in% c(31:36))
intnw <- subset(localitysummary, localitysummary$pop %in% c(69:79))
teton <- subset(localitysummary, localitysummary$pop %in% c(80:82))
ncz <- subset(localitysummary, localitysummary$pop %in% c(83:85))
scz <- subset(localitysummary, localitysummary$pop %in% c(86:88))
rockies <- subset(localitysummary, localitysummary$pop %in% c(89:102))


radii <- (localitysummary$samplesize*0.025)+0.1

library(ggstar)

plot <- ggplot()+
  ggrastr::rasterize(geom_tile(data = hillshade.df, aes(x=Longitude, y = Latitude, fill = hillshade), show.legend = FALSE), dev = "ragg")+
  scale_fill_distiller(palette = "Greys", direction = 1)+
  new_scale_fill()+
  ggrastr::rasterize(geom_tile(data = regionelev.df, aes(x=Longitude, y = Latitude, fill = Elevation), alpha = 0.5, show.legend = FALSE), dev = "ragg")+
  scale_fill_distiller(palette = "Greys", direction = 1)+
  geom_sf(data=range, fill=alpha('lightblue',0.5), color=NA)+
  geom_sf(data = region, fill = NA, lwd = .6)+
  coord_sf(xlim = c(-126, -103.5), ylim = c(30, 50), expand = FALSE)+
  new_scale_fill()+
  geom_point(data = cascades_pnw, aes(x=longitude, y=latitude, size = samplesize), fill = alpha("#7eb0d5", .75), color = 'black', pch = 21, stroke = 0.35)+
  geom_point(data = ncoastca, aes(x=longitude, y=latitude, size = samplesize), fill = alpha("#7eb0d5", .75), color = 'black', pch = 22, stroke = 0.35)+
  geom_star(data = sierra, aes(x=longitude, y=latitude, size = samplesize), fill = "#7eb0d5", color = 'black', starshape = 6, alpha = 0.75, starstroke = 0.35)+
  geom_point(data = sfbay, aes(x=longitude, y=latitude, size = samplesize), fill = alpha("#7eb0d5", .75), color = 'black', pch = 23, stroke = 0.35)+
  geom_point(data = cencoastca, aes(x=longitude, y=latitude, size = samplesize), fill = alpha("#7eb0d5", .75), color = 'black', pch = 24, stroke = 0.35)+
  geom_point(data = scoastca, aes(x=longitude, y=latitude, size = samplesize), fill = alpha("#7eb0d5", .75), color = 'black', pch = 25, stroke = 0.35)+
  geom_point(data = intnw, aes(x=longitude, y=latitude, size = samplesize), fill = alpha("#b2e061", .75), color = 'black', pch = 21, stroke = 0.35)+
  geom_point(data = teton, aes(x=longitude, y=latitude, size = samplesize), fill = alpha("#FFD23F", .75), color = 'black', pch = 24, stroke = 0.35)+
  geom_point(data = ncz, aes(x=longitude, y=latitude, size = samplesize), fill = alpha("#FFD23F", .75), color = 'black', pch = 23, stroke = 0.35)+
  geom_star(data = scz, aes(x=longitude, y=latitude, size = samplesize), fill = "#FFD23F", color = 'black', starshape = 29, alpha = 0.75, starstroke = 0.35)+
  geom_point(data = rockies, aes(x=longitude, y=latitude, size = samplesize), fill = alpha("#fd7f6f", .75), color = 'black', pch = 21, stroke = 0.35)+

  scale_size_continuous("Sample Size", range = (c(2.5, 7))*.5, breaks = (c(2,5,10))*.5)+
  theme_minimal()+
  theme(legend.position = "none")+
  xlab("Longitude")+
  ylab("Latitude")+
  labs(x=NULL, y = NULL)


ggsave("/media/maxlaubstein/data1/STJARangewideGenomics/plots/divmig_basemap.pdf", plot = plot, width = 3.5, height = 3.5, units = "in")

