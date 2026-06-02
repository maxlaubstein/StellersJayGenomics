setwd("/media/maxlaubstein/data1/STJARangewideGenomics/EEMS")
library(reemsplots2)
library(ggplot2)
library(scales)
library(ggrastr)
library(ggnewscale)
library(terra)
library(dplyr)
library(ggfun)
plot <- reemsplots2::make_eems_plots(mcmcpath = c("output_350_1/", 
                                                  "output_350_2/", 
                                                  "output_350_3/"), 
                                     longlat = TRUE, 
                                     add_grid = TRUE, 
                                     add_demes = TRUE)

ggsave("traceplot.png", plot = plot$pilogl01, width = 11, height = 8.5, units = "in")

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

topo <- ggplot()+
  ggrastr::rasterize(geom_tile(data = hillshade.df, aes(x=Longitude, y = Latitude, fill = hillshade), show.legend = FALSE), dev = "ragg")+
  scale_fill_distiller(palette = "Greys", direction = 1)+
  new_scale_fill()+
  ggrastr::rasterize(geom_tile(data = regionelev.df, aes(x=Longitude, y = Latitude, fill = Elevation), alpha = 0.5, show.legend = FALSE), dev = "ragg")+
  scale_fill_distiller(palette = "Greys", direction = 1)+
  geom_sf(data = region, fill = NA, lwd = .6)+
  coord_sf(xlim = c(-126, -103.5), ylim = c(30, 50), expand = FALSE)+
  theme_minimal()+
  xlab("Longitude")+
  ylab("Latitude")




eems_colors <- c(
  "#FF8C00",
  "#FFB04D",
  "#F7DD97",
  "#DBD5AB",
  "#BFCDC0",
  "#A3C5D4",
  "#87CEEB"
)




out <- topo+
  new_scale_fill()+
  geom_tile(data = plot$mrates01$data, aes(x=x,y=y, fill = z))+
  scale_fill_gradientn(
    "Effective Migration \n Rate (m)",
    colors = alpha(eems_colors, 0.8),
    values = scales::rescale(seq(min(plot$mrates01$data$z), max(plot$mrates01$data$z), length.out = length(eems_colors))),
    guide = "colorbar"
  ) +
  geom_segment(data = plot$mrates01$layers$geom_segment$data, 
               aes(x = x, y = y, xend = xend, yend = yend),
               color = alpha("grey60",0.5))+
  geom_point(data = plot$mrates01$layers$geom_point$data, aes(x = x, y = y, size = n),
             color = "black", shape = 21, fill = NA, stroke = 0.7, show.legend = FALSE) +
  scale_size_continuous(range = c(0.4, 3.5)) +
  ylab("Latitude")+
  theme(legend.position = c(0.83,0.895),
        legend.title = element_text(size = 6),
        legend.text  = element_text(size = 6),
        legend.background = element_roundrect(fill=alpha('white', 0.65),color = NA))+
  guides(
    fill = guide_colorbar(
      barwidth = 2.8,
      barheight = 0.5,
      title.position = "top", 
      direction = "horizontal",  
      title.hjust = 0.5,
      title.theme = element_text(margin = margin(b=3))))+
  labs(x=NULL, y = NULL)


ggsave("eems_mrates_plot.pdf", plot = out, width = 3.5, height = 3.5, units = "in")
