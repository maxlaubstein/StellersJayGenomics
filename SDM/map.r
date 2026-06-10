library(terra)
library(readxl)
library(dplyr)
library(ggplot2)
library(ggstar)

metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
metadata$`Pop # rev` <- as.integer(metadata$`Pop # rev`)
interior_current_aicVarSelect_withLC <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/SDM/data/SDM/finalSDMmodels/interior_current_aicVarSelect_withLC.tif")
pacific_current_aicVarSelect_withLC <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/SDM/data/SDM/finalSDMmodels/pacific_current_aicVarSelect_withLC.tif")
rockies_current_aicVarSelect_withLC <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/SDM/data/SDM/finalSDMmodels/rockies_current_aicVarSelect_withLC.tif")

interior_current_aicVarSelect_withLC.df <- as.data.frame(interior_current_aicVarSelect_withLC, xy = TRUE) |> subset(x >= -126 & x<= -103.5 & y >= 30 & y<= 50)
pacific_current_aicVarSelect_withLC.df <- as.data.frame(pacific_current_aicVarSelect_withLC, xy = TRUE) |> subset(x >= -126 & x<= -103.5 & y >= 30 & y<= 50)
rockies_current_aicVarSelect_withLC.df <- as.data.frame(rockies_current_aicVarSelect_withLC, xy = TRUE) |> subset(x >= -126 & x<= -103.5 & y >= 30 & y<= 50)


NorAm <- rnaturalearth::ne_states(country = c("Canada", "United States of America", "Mexico"))
region <- subset(NorAm, NorAm$name %in% c("British Columbia","Alberta","Saskatchewan",
                                          "Washington","Idaho","Montana",
                                          "Oregon","Wyoming","California",
                                          "Nevada","Utah","Colorado",
                                          "Arizona","New Mexico","Baja California",
                                          "Sonora","Chihuahua", "Texas",
                                          "North Dakota", "South Dakota", "Nebraska"))
region <- region["geometry"]

localitysummary <- data.frame(pop = 1:102) %>%
  cbind(samplesize = NA, longitude = NA, latitude = NA)

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

plot <- ggplot()+
  geom_sf(data = region, fill = 'white', lwd = .6)+
  geom_raster(data = interior_current_aicVarSelect_withLC.df, aes(x=x, y=y, fill = interior_current_aicVarSelect_withLC))+
  geom_raster(data = pacific_current_aicVarSelect_withLC.df, aes(x=x, y=y, fill = pacific_current_aicVarSelect_withLC))+
  geom_raster(data = rockies_current_aicVarSelect_withLC.df, aes(x=x, y=y, fill = rockies_current_aicVarSelect_withLC))+
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
  scale_fill_gradient(low = NA ,high = "#3D6F2E")+
  scale_size_continuous("Sample Size", range = (c(2.5, 7))*.5, breaks = (c(2,5,10))*.5)+
  coord_sf(xlim = c(-126, -103.5), ylim = c(30, 50), expand = FALSE)+
  theme_minimal() + 
  xlab(NULL)+
  ylab(NULL)+
  theme(legend.position = "none")
ggsave("SDM_map_full.pdf", plot = plot, width = 3.5, height = 3.5, units = "in")

plot <- ggplot()+
  geom_sf(data = region, fill = 'white', lwd = .6)+
  geom_raster(data = interior_current_aicVarSelect_withLC.df, aes(x=x, y=y, fill = interior_current_aicVarSelect_withLC))+
  geom_raster(data = pacific_current_aicVarSelect_withLC.df, aes(x=x, y=y, fill = pacific_current_aicVarSelect_withLC))+
  geom_raster(data = rockies_current_aicVarSelect_withLC.df, aes(x=x, y=y, fill = rockies_current_aicVarSelect_withLC))+
  scale_fill_gradient(low = NA ,high = "#3D6F2E")+
  geom_point(data = teton, aes(x=longitude, y=latitude, size = samplesize), fill = alpha("#FFD23F", .75), color = 'black', pch = 24, stroke = 0.35)+
  geom_point(data = ncz, aes(x=longitude, y=latitude, size = samplesize), fill = alpha("#FFD23F", .75), color = 'black', pch = 23, stroke = 0.35)+
  geom_star(data = scz, aes(x=longitude, y=latitude, size = samplesize), fill = "#FFD23F", color = 'black', starshape = 29, alpha = 0.75, starstroke = 0.35)+
  scale_size_continuous("Sample Size", range = (c(4, 7))*.5, breaks = (c(2,5,10))*.5)+
  coord_sf(xlim = c(-114.15, -108.8), ylim = c(39, 44.1), expand = FALSE)+
  theme_minimal() + 
  xlab(NULL)+
  ylab(NULL)+
  theme(legend.position = "none")
ggsave("SDM_map_CZ.pdf", plot = plot, width = 3.5, height = 3.5, units = "in")

