#https://dominicroye.github.io/en/2022/hillshade-effects/
setwd("~/Desktop/STJA/scripts/")
library(tidyverse)
library(raster)
library(rnaturalearth)
library(elevatr)
library(terra)
library(ggnewscale)

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
hillshade <- shade(slope, aspect, angle = 45, direction = 300)
hillshade.df <- as.data.frame(hillshade, xy = TRUE) %>% na.omit()
colnames(hillshade.df) <- c("Longitude", "Latitude", "hillshade")

ggplot()+
  geom_raster(data = hillshade.df, aes(x=Longitude, y = Latitude, fill = hillshade), show.legend = FALSE)+
  scale_fill_distiller(palette = "Greys", direction = 1)+
  new_scale_fill()+
  geom_raster(data = regionelev.df, aes(x=Longitude, y = Latitude, fill = Elevation), alpha = 0.5)+
  scale_fill_distiller(palette = "Greys", direction = 1)+
  geom_sf(data = region, fill = NA, lwd = .6)+
  coord_sf(xlim = c(-130, -103.5), ylim = c(30, 50), expand = FALSE)+
  theme_minimal()
