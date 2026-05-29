setwd("/media/maxlaubstein/data1/STJARangewideGenomics/admixture_nomeso2/seed1")
library(dplyr)
library(tidyr)
library(readxl)
library(ggh4x)
library(gridExtra)

metadata <- read_excel("../../1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")

metadata <- subset(metadata, metadata$`Pop # rev` %in% c(1:102))

samplename <- read.table("../Cyanocitta_LDPruned_Autosomal_nomeso.fam")$V2

samplepopnum <- data.frame(samplename = samplename, popnumber = rep(NaN, length(samplename)))
colnames(samplepopnum) <- c("samplename", "popnumber")


for (i in 1:nrow(samplepopnum)) {
  samplepopnum$popnumber[i] <- as.numeric(subset(metadata, metadata$sample_name == samplepopnum$samplename[i])$`Pop # rev`)
}

files <- c("Cyanocitta_LDPruned_Autosomal_nomeso.2.Q",
           "Cyanocitta_LDPruned_Autosomal_nomeso.3.Q",
           "Cyanocitta_LDPruned_Autosomal_nomeso.4.Q",
           "Cyanocitta_LDPruned_Autosomal_nomeso.5.Q",
           "Cyanocitta_LDPruned_Autosomal_nomeso.6.Q")

cat_admx <- do.call("rbind", lapply(files,
                                    FUN = function(files){
                                      #FUN reads in the .Q file from admixture
                                      #names() extracts the column names from .Q file.  
                                      #gsub replaces "V" with "pop" so we have pop1 and pop2
                                      
                                      x <- read.table(files, header = F)
                                      names(x) <- gsub("V", "pop", names(x))
                                      x$sampleID <- samplename
                                      x$popnumber <- samplepopnum$popnumber
                                      x$k <- gsub(".Q","",substr(files, nchar(files)-3+1,nchar(files)))
                                      x.long<-x%>%
                                        pivot_longer(names_to = "popGroup", values_to = "proportion", cols = -c(sampleID,popnumber, k))
                                      x.long
                                      
                                    }))


cat_admx$k <- as.numeric(cat_admx$k)

cat_admx$pop_sample <- paste(cat_admx$sampleID, "&", cat_admx$popnumber)

k2dat <- subset(cat_admx, cat_admx$k == 2)
k2dat[k2dat$popGroup=="pop1",]$popGroup <- "rocky"
k2dat[k2dat$popGroup=="pop2",]$popGroup <- "coastal"
k2dat$popGroup <- factor(k2dat$popGroup, levels = c("coastal", "rocky"))
plotk2 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = k2dat) +
  geom_col(aes(fill = factor(popGroup)), linewidth = 0.1) +
  theme_minimal() +
  labs(x=NULL, y = "Ancestry") +
  scale_y_continuous(expand = c(0,0)) +
  theme(
    panel.spacing.x = unit(0.0, "lines"),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    panel.grid = element_blank(),
    strip.text.x = element_text(angle = 90, size = 6),
    legend.position = "none"
  ) + 
  scale_fill_manual(name = "grp",values = c(rocky = "#fd7f6f", coastal = "#7eb0d5"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")+
  annotate("text", x = 9, y = 0.5, label = "K = 2", size = 3)

k3dat <- subset(cat_admx, cat_admx$k == 3)
k3dat[k3dat$popGroup=="pop3",]$popGroup <- "coastal"
k3dat[k3dat$popGroup=="pop2",]$popGroup <- "intnw"
k3dat[k3dat$popGroup=="pop1",]$popGroup <- "rocky"
k3dat$popGroup <- factor(k3dat$popGroup, levels = c("coastal", "rocky", "intnw"))
plotk3 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = k3dat) +
  geom_col(aes(fill = factor(popGroup)), linewidth = 0.1) +
  theme_minimal() +
  labs(x=NULL, y = "Ancestry") +
  scale_y_continuous(expand = c(0,0)) +
  theme(
    panel.spacing.x = unit(0.0, "lines"),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    panel.grid = element_blank(),
    strip.text.x = element_text(angle = 90, size = 6),
    legend.position = "none"
  ) + 
  scale_fill_manual(name = "grp",values = c(rocky = "#fd7f6f", coastal = "#7eb0d5", intnw = "#b2e061"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")+
    annotate("text", x = 9, y = 0.5, label = "K = 3", size = 3)

k4dat <- subset(cat_admx, cat_admx$k == 4)
k4dat[k4dat$popGroup=="pop3",]$popGroup <- "intnw"
k4dat[k4dat$popGroup=="pop2",]$popGroup <- "ncarb"
k4dat[k4dat$popGroup=="pop1",]$popGroup <- "coastal"
k4dat[k4dat$popGroup=="pop4",]$popGroup <- "rocky"
k4dat$popGroup <- factor(k4dat$popGroup, levels = c("coastal", "rocky", "intnw", "ncarb"))

plotk4 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = k4dat) +
  geom_col(aes(fill = factor(popGroup)), linewidth = 0.1) +
  theme_minimal() +
  labs(x=NULL, y = "Ancestry") +
  scale_y_continuous(expand = c(0,0)) +
  theme(
    panel.spacing.x = unit(0.0, "lines"),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    panel.grid = element_blank(),
    strip.text.x = element_text(angle = 90, size = 6),
    legend.position = "none"
  ) + 
  scale_fill_manual(name = "grp",values = c(rocky = "#fd7f6f", coastal = "#7eb0d5", intnw = "#b2e061", ncarb = "#ffee65"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")+
    annotate("text", x = 9, y = 0.5, label = "K = 4", size = 3)


k5dat <- subset(cat_admx, cat_admx$k == 5)
k5dat[k5dat$popGroup=="pop3",]$popGroup <- "ncarb"
k5dat[k5dat$popGroup=="pop2",]$popGroup <- "rocky"
k5dat[k5dat$popGroup=="pop1",]$popGroup <- "intnw"
k5dat[k5dat$popGroup=="pop4",]$popGroup <- "scarb"
k5dat[k5dat$popGroup=="pop5",]$popGroup <- "coastal"
k5dat$popGroup <- factor(k5dat$popGroup, levels = c("coastal", "rocky", "intnw", "ncarb", "scarb"))
plotk5 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = k5dat) +
  geom_col(aes(fill = factor(popGroup)), linewidth = 0.1) +
  theme_minimal() +
  labs(x=NULL, y = "Ancestry") +
  scale_y_continuous(expand = c(0,0)) +
  theme(
    panel.spacing.x = unit(0.0, "lines"),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    panel.grid = element_blank(),
    strip.text.x = element_text(angle = 90, size = 6),
    legend.position = "none"
  ) + 
  scale_fill_manual(name = "grp",values = c(rocky = "#fd7f6f", coastal = "#7eb0d5", intnw = "#b2e061", ncarb = "#ffee65", scarb = "#ffb55a"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")+
  annotate("text", x = 9, y = 0.5, label = "K = 5", size = 3)



k6dat <- subset(cat_admx, cat_admx$k == 6)
for (i in 1:nrow(k6dat)) {
  if(k6dat$popnumber[i] %in% 1:19) {k6dat$region[i] <- "1 - 19"}
  if(k6dat$popnumber[i] %in% 20:25) {k6dat$region[i] <- "20 - 25"}
  if(k6dat$popnumber[i] %in% 26:30) {k6dat$region[i] <- "26 - 30"}
  if(k6dat$popnumber[i] %in% 31:36) {k6dat$region[i] <- "31 - 36"}
  if(k6dat$popnumber[i] %in% 37:46) {k6dat$region[i] <- "37 - 46"}
  if(k6dat$popnumber[i] %in% 47:68) {k6dat$region[i] <- "47 - 68"}
  if(k6dat$popnumber[i] %in% 69:79) {k6dat$region[i] <- "69 - 79"}
  if(k6dat$popnumber[i] %in% 80:82) {k6dat$region[i] <- "80 - 82"}
  if(k6dat$popnumber[i] %in% 83:85) {k6dat$region[i] <- "83 - 85"}
  if(k6dat$popnumber[i] %in% 86:88) {k6dat$region[i] <- "86 - 88"}
  if(k6dat$popnumber[i] %in% 89:102) {k6dat$region[i] <- "89 - 102"}
  if(k6dat$popnumber[i] %in% 103:106) {k6dat$region[i] <- "."}
}

k6dat$regpop <- paste(k6dat$sampleID, "&", k6dat$region)

k6dat[k6dat$popGroup=="pop3",]$popGroup <- "rocky"
k6dat[k6dat$popGroup=="pop2",]$popGroup <- "scarb"
k6dat[k6dat$popGroup=="pop1",]$popGroup <- "otherthing"
k6dat[k6dat$popGroup=="pop4",]$popGroup <- "ncarb"
k6dat[k6dat$popGroup=="pop5",]$popGroup <- "coastal"
k6dat[k6dat$popGroup=="pop6",]$popGroup <- "intnw"
k6dat$popGroup <- factor(k6dat$popGroup, levels = c("coastal", "rocky", "intnw", "ncarb", "scarb", "otherthing"))

plotk6 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = k6dat) +
  geom_col(aes(fill = factor(popGroup)), linewidth = 0.1) +
  theme_minimal() +
  labs(x=NULL, y = "Ancestry") +
  scale_y_continuous(expand = c(0,0)) +
  theme(
    panel.spacing.x = unit(0.0, "lines"),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    panel.grid = element_blank(),
    strip.text.x = element_text(angle = 90, size = 6),
    legend.position = "none"
  ) + 
  scale_fill_manual(name = "grp",values = c(rocky = "#fd7f6f", coastal = "#7eb0d5", intnw = "#b2e061", ncarb = "#ffee65", scarb = "#ffb55a", otherthing = "#bd7ebe"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")

df <- k6dat  


df <- k6dat
samples <- df %>%
  distinct(sampleID, popnumber, region) %>%
  arrange(popnumber, sampleID) %>%
  mutate(pos = row_number())  

region_positions <- samples %>%
  group_by(region) %>%
  summarise(
    start = min(pos),
    end   = max(pos),
    .groups = "drop"
  )

axis <- ggplot() +
  # ensure same x positions as admixture bars
  geom_blank(data = samples,
             aes(x = reorder(sampleID, popnumber), y = 0)) +
  
  # draw brackets
  geom_segment(data = region_positions,
               aes(x = start, xend = end, y = 0, yend = 0),
               inherit.aes = FALSE, linewidth = 2) +
  
  # add labels just under the line
  geom_text(data = region_positions,
            aes(x = (start + end) / 2, y = -0.001, label = region),
            inherit.aes = FALSE, vjust = 2, size = 2) +
  
  theme_minimal() +
  # expand y scale downward so labels aren't clipped
  scale_y_continuous(limits = c(-0.05, 0.001), expand = c(0,0))+
  
  labs(x = NULL, y = NULL) +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    panel.spacing.x = unit(0.0, "lines")
  )+
  xlab("Individual Samples, Ordered by Population #")


#########################
#Adding mtDNA
pca <- read.table("/media/maxlaubstein/data1/STJARangewideGenomics/PCA2/mtdna/mtdna_PCA.eigenvec")
eigenval <- scan("/media/maxlaubstein/data1/STJARangewideGenomics/PCA2/mtdna/mtdna_PCA.eigenval")
pca <- pca[, -1]
pca <- subset(pca, !(V2 %in% c("MVZ188144", "MVZ189266", "MVZ189267", "UWBM106814")))

pca$popnumber <- numeric(nrow(pca))
for(i in 1:nrow(pca)){
  pca$popnumber[i] <- as.numeric(subset(metadata, metadata$sample_name == pca$V2[i])$`Pop # rev`)
  if(pca$V3[i] < 0) {pca$mtdna[i] <- "Coastal"}
  if(pca$V3[i] > 0) {pca$mtdna[i] <- "Rocky"}  
}

pca$pop_sample <- paste(pca$V2, "&", pca$popnumber)
mtdna <- ggplot(aes(x = reorder(pop_sample, popnumber), y = 1, fill = factor(mtdna)), data = pca) +
  geom_col()+
  theme_minimal() +
  scale_y_continuous(expand = c(0,0)) +
  labs(x=NULL, y = NULL) +
  theme(
    panel.spacing.x = unit(0.0, "lines"),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    panel.grid = element_blank(),
    strip.text.x = element_text(angle = 90, size = 6),
    legend.position = "none"
  )+
  scale_fill_manual(name = "grp",values = c(Rocky = "#fd7f6f", Coastal = "#7eb0d5"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")+
  annotate("text", x = 11, y = 0.5, label = "mtDNA", size = 3)
#########################



library(patchwork)

plotk2 <- plotk2 + theme(plot.margin = margin(t = 1, r = 0, b = 1, l = 0))
plotk3 <- plotk3 + theme(plot.margin = margin(t = 1, r = 0, b = 1, l = 0))
plotk4 <- plotk4 + theme(plot.margin = margin(t = 1, r = 0, b = 1, l = 0))
plotk5 <- plotk5 + theme(plot.margin = margin(t = 1, r = 0, b = 1, l = 0))
axis   <- axis   + theme(plot.margin = margin(t = 1, r = 0, b = 1, l = 0))
mtdna   <- mtdna   + theme(plot.margin = margin(t = 1, r = 0, b = 1, l = 0))



library(patchwork)

admxplot <- (mtdna / plotk2 / plotk3 / plotk4 / plotk5 / axis) +
  plot_layout(heights = c(0.5, 1,1,1,1,0.45))


ggsave(plot = admxplot, filename = "../../plots/admxplotseed1.pdf", device = "pdf", height = 2, width = 7, units = "in")
