library(terra)
library(geodata)
library(readxl)
library(raster)
library(ggplot2)
library(dplyr)
library(sf)
library(vcfR)
library(mapmixture)

range <- read_sf("/media/maxlaubstein/data1/STJARangewideGenomics/STJAMainRange.kml")

metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
metadata <- subset(metadata, metadata$isolate != "Middle America")
#At 2.5 arcminute resolution, it thinks this one sample from San Luis Obispo is in the ocean, and returns NA for envirem data. Here I just slightly nudge the latitude to push the point 'on land'
metadata[metadata$sample_name == "MVZCCGP-Cst97_I-B07",]$latitude <- 35.573797


bio15 <- rast("/media/maxlaubstein/data1/STJARangewideGenomics/GEA/globalworldclim/climate/wc2.1_2.5m/wc2.1_2.5m_bio_15.tif")
bio15 <- crop(bio15, ext(-126, -103.5, 30, 50))

message("Mapping...")

NorAm <- rnaturalearth::ne_states(country = c("Canada", "United States of America", "Mexico"))
region <- subset(NorAm, NorAm$name %in% c("British Columbia","Alberta","Saskatchewan",
                                          "Washington","Idaho","Montana",
                                          "Oregon","Wyoming","California",
                                          "Nevada","Utah","Colorado",
                                          "Arizona","New Mexico","Baja California",
                                          "Sonora","Chihuahua", "Texas",
                                          "North Dakota", "South Dakota", "Nebraska"))
region <- region["geometry"]

r <- bio15
# Convert to data frame for ggplot
r_df <- as.data.frame(r, xy = TRUE)  # xy = TRUE adds coordinates
colnames(r_df) <- c("x", "y", "BIO7")  # optional, rename columns

system("bcftools view -r JANXIP010000002.1:34182127 ../vcfdata/Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz > scaff2snp.vcf")
#genotypes at scaff2 peak:
vcf <- read.vcfR("scaff2snp.vcf")
gt <-as.data.frame(t(extract.gt(vcf)))
colnames(gt) <- "gt"
gt$sample <- rownames(gt)
metadata <- subset(metadata, metadata$isolate != "Middle America")
metadata$`Pop # rev` <- as.numeric(metadata$`Pop # rev`)
metadata$gt <- NA
for(i in 1:nrow(metadata)) {
  metadata$gt[i] <- gt[gt$sample == metadata$sample_name[i],]$gt

}



localitysummary <- data.frame(pop = 1:102) %>%
  cbind(samplesize = NA, zerozero = NA, het = NA, oneone = NA, longitude = NA, latitude = NA)

for (i in 1:102) {
  localitydata<-subset(metadata, metadata$`Pop # rev` == localitysummary$pop[i])
  localitysummary$samplesize[i]<-nrow(localitydata)
  localitysummary$zerozero[i] <- nrow(localitydata[localitydata$gt == "0/0",])
  localitysummary$het[i] <- nrow(localitydata[localitydata$gt == "0/1",])
  localitysummary$oneone[i] <- nrow(localitydata[localitydata$gt == "1/1",])
  localitysummary$longitude[i] <- median(localitydata$longitude)
  localitysummary$latitude[i]<-median(localitydata$latitude)
  rm(localitydata)
}

localitysummary$allelefreq <- (localitysummary$het + 2*localitysummary$oneone) /
  (2 * localitysummary$samplesize)
localitysummary$altfreq <- 1 - localitysummary$allelefreq

df <- data.frame(
  site=as.character(localitysummary$pop),
  lat=localitysummary$latitude,
  lon=localitysummary$longitude,
  Cluster1 = localitysummary$allelefreq,
  Cluster2 = localitysummary$altfreq)




radii <- (localitysummary$samplesize*0.025)+0.3


# Plot with ggplot
plot <- ggplot(r_df) +
  geom_raster(aes(x = x, y = y, fill = BIO7)) +
  scale_fill_gradientn(
    colors = rev(c("#4575b4","#91bfdb","#e0f3f8","#fee090","#fc8d59","#d73027")),
  )+
  geom_sf(data = region, fill = NA, lwd = .45)+
  geom_sf(data=range, fill=alpha('white',0.5), color=NA)+
  coord_sf(xlim = c(-126, -103.5), ylim = c(30, 50), expand = FALSE)+
  theme_void() +
  xlab("")+
  ylab("")+
  labs(fill = "BIO15")+
   theme(
    legend.position = c(0.07, 0.2),
    legend.key.size = unit(0.3, "cm"),   # smaller legend boxes
    legend.title = element_text(size = 6), # smaller legend title
    legend.text = element_text(size = 5)   # smaller legend labels
  )+
  add_pie_charts(df,
                 admix_columns = 4:5,
                 lat_column = "lat",
                 lon_column = "lon",
                 pie_colours = c("gray20", "gray90"),
                 border=0.3,
#                 opacity = 0.6,
                 pie_size = radii)

ggsave("plots/BIO15_Scaff2_Map.pdf", plot = plot, width = 2.5, height = 2.5, units = "in")

