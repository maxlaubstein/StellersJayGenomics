library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)
library(ggh4x)
library(legendry)

metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
metadata$`Pop # rev` <- as.numeric(metadata$`Pop # rev`) 
metadata[metadata$sample_name == "UWBM103325",]$`ND2 clade` <- "Rocky Mts." #as informed by the mtDNA PCA
metadata <- subset(metadata, metadata$`Pop # rev` %in% 69:102)

k4.Q<-read.table("/media/maxlaubstein/data1/STJARangewideGenomics/admixture/nomeso/seed1/Cyanocitta_LDPruned_Autosomal_nomeso.4.Q")
sampstable<-read.table("/media/maxlaubstein/data1/STJARangewideGenomics/admixture/nomeso/Cyanocitta_LDPruned_Autosomal_nomeso.fam")
samplename<-sampstable$V2


metadata$k4V1 <- rep(NaN, nrow(metadata))
metadata$k4V2 <- rep(NaN, nrow(metadata))
metadata$k4V3 <- rep(NaN, nrow(metadata))
metadata$k4V4 <- rep(NaN, nrow(metadata))

k4wpop<-cbind(k4.Q, sampstable$V2)
colnames(k4wpop)[5] <- "ID"

for (i in 1:nrow(metadata)) {
  metadata$k4V1[i]<-subset(k4wpop ,k4wpop$ID ==  metadata$sample_name[i])$V1
  metadata$k4V2[i]<-subset(k4wpop ,k4wpop$ID ==  metadata$sample_name[i])$V2
  metadata$k4V3[i]<-subset(k4wpop ,k4wpop$ID ==  metadata$sample_name[i])$V3
  metadata$k4V4[i]<-subset(k4wpop ,k4wpop$ID ==  metadata$sample_name[i])$V4
 
}

data <- data.frame(ID = metadata$sample_name,
                   ND2 = metadata$`ND2 clade`,
                   K4Coast = metadata$k4V2,
                   K4IntNW = metadata$k4V4,
                   K4Rocky = metadata$k4V1,
                   K4SFBay = metadata$k4V3,
                   pop = metadata$`Pop # rev`,
                   FScolor = metadata$`frontal streak`)



data.long <- data %>%
  pivot_longer(
    cols = starts_with("K4"),
    names_to = "Pop",
    values_to = "Prop"
  )

data <- data[order(data$pop), ]

data$ID <- factor(data$ID, levels = data$ID)

data.long$ID <- factor(data.long$ID, levels = levels(data$ID))



ND2 <- ggplot()+
  geom_col(data = data, aes(x= ID, y = 1, fill = ND2), color = NA)+
  theme_void()+
  theme(legend.position = "none")+
  scale_fill_manual(values = c('#7eb0d5', '#fd7f6f'))+
  coord_fixed(ratio = 1)



ADMX <- ggplot()+
  geom_col(data = data.long, aes(x=ID, y = Prop, fill = Pop), color = NA)+
  theme_void()+
  theme(legend.position = "none")+
  scale_fill_manual(values = c('white',"#fd7f6f",'#7eb0d5',"#b2e061"))+
  coord_fixed(ratio = 4)

data$ID_nested <- paste0(data$ID, "&", data$pop)
data$ID_nested <- factor(data$ID_nested, levels = data$ID_nested)
data$label_nested <- gsub("^[^&]+&", "&", data$ID_nested)


samples <- data %>%
  arrange(pop, ID) %>% 
  mutate(pos = row_number())
# group these, just to prevent overlaps on the plot:
samples[samples$pop %in% c(89:102),]$pop <- "89 - 102"
samples[samples$pop %in% c(70:73),]$pop <- "70 - 73"
samples[samples$pop %in% c(75:78),]$pop <- "75 - 78"


pop_positions <- samples %>% 
  group_by(pop) %>% 
  summarise( start = min(pos), end = max(pos), .groups = "drop" ) %>%
  mutate(
    start_0 = start,
    end_0 = end,
    start = ifelse(start_0 == end_0, start_0 - 0.5, start_0 - 0.125),
    end = ifelse(start_0 == end_0, end_0 + 0.5, end_0 + 0.125)) %>%
  select(-start_0, -end_0)

axis <- ggplot() +
  geom_blank(data = samples, aes(x = ID, y = 0))+
  geom_segment(data = pop_positions, 
               aes(x = start, xend = end, y = 0, yend = 0), 
               inherit.aes = FALSE, linewidth = 2) +
  geom_text(data = pop_positions, 
            aes(x = (start + end) / 2, y = -0.001, label = pop), 
            inherit.aes = FALSE, vjust = 2, size = 2) +
  theme_minimal() +
  scale_y_continuous(limits = c(-0.05, 0.001), expand = c(0,0))+
  labs(x = NULL, y = NULL) + 
  theme( axis.text = element_blank(), 
         axis.ticks = element_blank(), 
         panel.grid = element_blank(), 
         panel.spacing.x = unit(0.0, "lines") )+ 
  xlab(NULL)


ND2 <- ND2 + theme(plot.margin = margin(0,0,0,0))
ADMX <- ADMX + theme(plot.margin = margin(0,0,0,0))
axis <- axis + theme(plot.margin = margin(0,0,0,0))

ggsave("/media/maxlaubstein/data1/STJARangewideGenomics/plots/ADMX_CZ.pdf", plot = ADMX, width = 6, height = 0.3, units = "in", scale = 1)
ggsave("/media/maxlaubstein/data1/STJARangewideGenomics/plots/ND2_CZ.pdf", plot = ND2, width = 6, height = 0.08, units = "in", scale = 1)
ggsave("/media/maxlaubstein/data1/STJARangewideGenomics/plots/axis_CZ.pdf", plot = axis, width = 6, height = 0.2, units = "in", scale = 1)

