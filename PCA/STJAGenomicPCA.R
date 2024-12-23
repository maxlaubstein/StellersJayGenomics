setwd("~/Desktop/STJA/scripts")
library(tidyverse)
library(readxl)
library(ggrepel)

pca <- read_table("../PCA/STJAPCA.eigenvec", col_names = FALSE)
eigenval <- scan("../PCA/STJAPCA.eigenval")
pca$id <- rep(NA, nrow(pca))

metadata <- read_excel("../1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")


for (i in 1:150) {
  pca$id[i] <- paste(pca$X1[i], pca$X2[i], sep = "_")
}

for (i in 151:nrow(pca)) {
  pca$id[i] <- pca$X1[i]
}

pca <- pca[, -1]
pca <- pca[, -1]

pca$Group <- rep(NA, nrow(pca))
pca$popnumber <- rep(NA, nrow(pca))


for (i in 1:nrow(pca)) {
  pca$Group[i] <- subset(metadata, metadata$sample_name == pca$id[i])$isolate
  pca$popnumber[i] <- subset(metadata, metadata$sample_name == pca$id[i])$`Pop # rev`
  if(pca$popnumber[i] %in% 80:82) {pca$Group[i] <- "Interior"}
  if(pca$popnumber[i] == 87) {pca$Group[i] <- "Rocky"}
}


pve <- data.frame(PC = 1:20, pve = eigenval/sum(eigenval)*100)


ggplot(pca, aes(X3, X4, col = Group, label = popnumber))+
  geom_point(size = 4)+
  theme_light()+
  scale_colour_manual(values = alpha(c("#7eb0d5","gold" , "#b2e061", "#bd7ebe","#fd7f6f"), 0.5))+
  xlab("PC1 (37.55%)")+
  ylab("PC2 (11.53%)")+
  geom_text_repel(col = 'black', size = 2, max.overlaps = 100)


#without labels
ggplot(pca, aes(X3, X4, col = Group, label = popnumber))+
  geom_point(size = 5)+
  theme_light()+
  scale_colour_manual(values = alpha(c("#7eb0d5","gold" , "#b2e061", "#bd7ebe","#fd7f6f"), 0.5))+
  xlab("PC1 (37.55%)")+
  ylab("PC2 (11.53%)")
