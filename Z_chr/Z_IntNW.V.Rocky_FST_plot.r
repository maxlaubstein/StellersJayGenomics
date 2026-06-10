library(readxl)
library(tidyverse)
library(ape)
library(ggrastr)

#Load metadata:
metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")


##################################################################################################################################
#Contact Zone FST:

FST <- read.table("Z_IntNW.V.Rocky.windowed.weir.fst", header = TRUE)

#remove any missing data
FST <- FST[complete.cases(FST),]

#add scaffold numbers
FST$SCAFFOLD <- as.numeric(substr(FST$CHROM, 13, 17)) - 0.1

#Filter out windows with too few variants
FST <- subset(FST, FST$N_VARIANTS > 10)

#order by scaffold
FST <- FST[order(FST$SCAFFOLD),]

#add window #
FST$WINDOW <- c(1:(nrow(FST)))


#Manhattan Plot showing WEIGHTED FST
plot <- ggplot(data = FST, aes(x= WINDOW, y = WEIGHTED_FST)) +
  geom_point_rast(color = 'black' alpha = .5, raster.dpi = 1000, size = 0.5)+
  xlab("Sliding Windows Across Z Scaffold")+
  ylab(bquote(F[st]))+
  geom_hline(yintercept = mean(subset(FST, FST$WEIGHTED_FST >=0)$WEIGHTED_FST), color = '#3A74A1', linetype="dashed")+
  annotate("label",
         x = median(FST$WINDOW),
         y = mean(subset(FST, FST$WEIGHTED_FST >= 0)$WEIGHTED_FST) + 0.1,
         label = paste("Interior NW vs. Rocky Mtns. Mean Z FST =", round(mean(subset(FST, FST$WEIGHTED_FST >= 0)$WEIGHTED_FST), digits = 3)),
         fill = alpha("white", 0.75))+
  ylim(0,1)+
  theme_minimal()+
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_blank()
  )

ggsave(plot = plot, filename = "Z_FST_IntNW.V.Rocky.pdf", device = "pdf", height = 2, width = 7, units = "in")


#print(paste("Mean FST ="), mean(subset(FST, FST$WEIGHTED_FST >=0)$WEIGHTED_FST))

quantile(subset(FST, FST$WEIGHTED_FST >=0)$WEIGHTED_FST, c(0.025, 0.975))

mean(subset(FST, FST$WEIGHTED_FST >=0)$WEIGHTED_FST)

