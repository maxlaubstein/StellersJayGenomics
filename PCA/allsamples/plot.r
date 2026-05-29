setwd("/media/maxlaubstein/data1/STJARangewideGenomics/PCA2/allsamples")
library(ggplot2)
library(readr)
library(readxl)
library(ggrepel)
#library(ggfun)
library(cowplot)

pca <- read_table("/media/maxlaubstein/data1/STJARangewideGenomics/PCA2/allsamples/Cyanocitta_PCA.eigenvec", col_names = FALSE)
eigenval <- scan("/media/maxlaubstein/data1/STJARangewideGenomics/PCA2/allsamples/Cyanocitta_PCA.eigenval")

metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
metadata[metadata$isolate == "Middle America",]$`Pop # rev` <- "103"

pca <- pca[, -1]

pca$Group <- rep(NA, nrow(pca))
pca$popnumber <- rep(NA, nrow(pca))


for (i in 1:nrow(pca)) {
  pca$popnumber[i] <- as.numeric(subset(metadata, metadata$sample_name == pca$X2[i])$`Pop # rev`)
  if(pca$popnumber[i] %in% 0:68) {pca$Group[i] <- "Coastal (Pops. 1-68)"}
  if(pca$popnumber[i] %in% 69:79) {pca$Group[i] <- "Interior Northwest (Pops. 69-79)"}
  if(pca$popnumber[i] %in% 80:82) {pca$Group[i] <- "Teton (Pops. 80-82)"}
  if(pca$popnumber[i] %in% 83:85) {pca$Group[i] <- "N. Contact Zone (Pops. 83-85)"}
  if(pca$popnumber[i] %in% 86:88) {pca$Group[i] <- "S. Contact Zone (Pops. 86-88)"}
  if(pca$popnumber[i] %in% 89:102) {pca$Group[i] <- "Rocky Mountains (Pops. 89-102)"}
  if(pca$popnumber[i] == 103) {pca$Group[i] <- "Mesoamerica"}

}

pve <- data.frame(PC = 1:20, pve = eigenval/sum(eigenval)*100)

pca$Group <- factor(pca$Group, levels = c("Coastal (Pops. 1-68)", "Interior Northwest (Pops. 69-79)", "Teton (Pops. 80-82)", "N. Contact Zone (Pops. 83-85)", "S. Contact Zone (Pops. 86-88)", "Rocky Mountains (Pops. 89-102)", "Mesoamerica"))

scz <- subset(pca, pca$Group == "S. Contact Zone (Pops. 86-88)")

library(ggstar)

plot <- ggplot(pca, aes((-1)*X3, (-1)*X4, col = Group, label = popnumber, shape = Group))+
  geom_point(size = 3)+
  theme_minimal()+
  scale_colour_manual(values = alpha(c("#7eb0d5","#b2e061", "#FFD23F" , "#FFD23F", NA, "#fd7f6f", "#bd7ebe"), 0.5))+
  scale_shape_manual(values = c(19, 19, 17, 18, 4, 19, 19))+
  geom_star(data = scz, aes(x=(-1)*X3, y=(-1)*X4), fill = "#FFD23F", color = NA, starshape = 29, alpha = 0.5, size = 3.5)+
  xlab(paste0("PC1 (", round(pve$pve[1], 2), "%)"))+
  ylab(paste0("PC2 (", round(pve$pve[2], 2), "%)"))+
  #geom_text_repel(data = subset(pca, pca$Group == "Contact Zone"), col = 'black', size = 2, max.overlaps = 100)+
  theme(legend.position = "inside", legend.title.position = "top", legend.title = element_text(face="bold"))+
  guides(
    color = guide_legend(override.aes = list(size = 5), ncol = 3),
    shape = guide_legend(override.aes = list(size = 5), ncol = 3)
  )
#  theme(legend.position = "inside",
#        legend.position.inside =  c(.2, .7),
#        legend.title.position = "top",
#        legend.title = element_text(face="bold"),
#        legend.background = element_rect(fill=alpha('white', 0.6),color = NA))

ggsave(plot = plot + theme(legend.position = "none"), filename = "/media/maxlaubstein/data1/STJARangewideGenomics/plots/PCA_all.pdf", device = "pdf", height = 3.5, width = 3.5, units = "in")


# Extract legend as a grob
legend <- cowplot::get_legend(plot)

# Convert to a plot object
legend_plot <- cowplot::plot_grid(legend)

# Save to file
ggsave(plot = legend_plot, filename = "/media/maxlaubstein/data1/STJARangewideGenomics/plots/PCA_legend.pdf", width = 7, height = 1.2, units = "in")

library(plotly)
library(htmlwidgets)

plot_interactive <- ggplot(pca, aes(
  x = (-1) * X3,
  y = (-1) * X4,
  col = Group,
  shape = Group,
  text = paste("Sample:", X2, "<br>Pop:", popnumber, "<br>Group:", Group)
)) +
  geom_point(size = 3) +
  theme_minimal() +
  scale_colour_manual(values = alpha(c("#7eb0d5","#b2e061", "#FFD23F" , "#FFD23F", "#FFD23F", "#fd7f6f", "#bd7ebe"), 0.5)) +
  scale_shape_manual(values = c(19, 19, 17, 18, 4, 19, 19)) +
  xlab(paste0("PC1 (", round(pve$pve[1], 2), "%)")) +
  ylab(paste0("PC2 (", round(pve$pve[2], 2), "%)")) +
  theme(
    legend.position = "inside",
    legend.title.position = "top",
    legend.title = element_text(face="bold")
  )

# Convert to interactive Plotly object
plotly_plot <- ggplotly(plot_interactive, tooltip = "text")

# Save as HTML
saveWidget(as_widget(plotly_plot), file = "/media/maxlaubstein/data1/STJARangewideGenomics/PCA2/allsamples/PCA_all.html")
