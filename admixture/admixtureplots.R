setwd("/Users/maxlaubstein/Desktop/STJA")
library(dplyr)
library(tidyverse)
library(readxl)
library(ggh4x)
library(gridExtra)


k2<-"plink_STJA_forAdmix.2.Q"
k3<-"plink_STJA_forAdmix.3.Q"
k4<-"plink_STJA_forAdmix.4.Q"
k5<-"plink_STJA_forAdmix.5.Q"
k6<-"plink_STJA_forAdmix.6.Q"
k7<- "plink_STJA_forAdmix.7.Q"
k8 <- "plink_STJA_forAdmix.8.Q"
k9 <- "plink_STJA_forAdmix.9.Q"

metadata <- read_excel("1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")

metadata$`Pop # rev`[307] <- 103
metadata$`Pop # rev`[308] <- 104
metadata$`Pop # rev`[309] <- 105
metadata$`Pop # rev`[310] <- 106

samplename<-read.table("plink.fam")$V2

samplepopnum <- data.frame(samplename = samplename, popnumber = rep(NaN, length(samplename)))
colnames(samplepopnum) <- c("samplename", "popnumber")


for (i in 1:nrow(samplepopnum)) {
  samplepopnum$popnumber[i] <- as.numeric(subset(metadata, metadata$sample_name == samplepopnum$samplename[i])$`Pop # rev`)
}

struct_files <- c(k2, k3, k4, k5, k6, k7, k8, k9)
cat_admx <- do.call("rbind", lapply(struct_files,
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




plotk2 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = subset(cat_admx, cat_admx$k == 2)) +
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
  scale_fill_manual(name = "grp",values = c("#fd7f6f", "#7eb0d5", "#b2e061", "#bd7ebe", "#ffb55a", "#ffee65", "#beb9db", "#fdcce5", "#8bd3c7"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")


plotk3 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = subset(cat_admx, cat_admx$k == 3)) +
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
  scale_fill_manual(name = "grp",values = c("#b2e061","#fd7f6f","#7eb0d5"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")

plotk4 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = subset(cat_admx, cat_admx$k == 4)) +
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
  scale_fill_manual(name = "grp",values = c("#b2e061","#7eb0d5","#fd7f6f","#bd7ebe"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")


plotk5 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = subset(cat_admx, cat_admx$k == 5)) +
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
  scale_fill_manual(name = "grp",values = c("#7eb0d5","#fd7f6f","#ffb55a","#b2e061","#ffee65"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")


plotk6 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = subset(cat_admx, cat_admx$k == 6)) +
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
  scale_fill_manual(name = "grp",values = c("#fd7f6f","#bd7ebe","#ffb55a","#b2e061","#7eb0d5","#ffee65"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")


plotk7 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = subset(cat_admx, cat_admx$k == 7)) +
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
  scale_fill_manual(name = "grp",values = c("#bd7ebe","#fd7f6f","#7eb0d5","#ffb55a","#fdcce5","#ffee65","#b2e061"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")

plotk8 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = subset(cat_admx, cat_admx$k == 8)) +
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
  scale_fill_manual(name = "grp",values = c("#7eb0d5","#b2e061","#8bd3c7","#bd7ebe","#fd7f6f","#ffb55a","#ffee65","#fdcce5"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")

plotk9 <- ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = subset(cat_admx, cat_admx$k == 9)) +
  geom_col(aes(fill = factor(popGroup)), linewidth = 0.1) +
  labs(x=NULL, y = "Ancestry") +
  scale_y_continuous(expand = c(0,0)) +
  theme(
    panel.spacing.x = unit(0.0, "lines"),
    axis.text.x=element_text(angle=90, size = 5),
    axis.text.y=element_blank(),
    panel.grid = element_blank(),
    strip.text.x = element_text(angle = 90, size = 6),
    legend.position = "none",
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_blank()
  ) + 
  guides(x = ggh4x::guide_axis_nested(delim = "&"))+
  scale_fill_manual(name = "grp",values = c("#b2e061","#8bd3c7","#bd7ebe","#ffb55a","#fdcce5","#fd7f6f","#ffee65","#beb9db","#7eb0d5"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")


admxplot<-gridExtra::grid.arrange(plotk2, plotk3, plotk4, 
                                  plotk5, plotk6, plotk7, 
                                  plotk8, plotk9, 
                                  ncol = 1, 
                                  bottom = "Sample ID #", 
                                  heights = c(1,1,1,1,1,1,1,2.5), 
                                  right = "K")

gridExtra::grid.arrange(ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = subset(cat_admx, cat_admx$k == 2)) +
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
               scale_fill_manual(name = "grp",values = c("#fd7f6f", "#7eb0d5", "#b2e061", "#bd7ebe", "#ffb55a", "#ffee65", "#beb9db", "#fdcce5", "#8bd3c7"), guide = F) +xlab(NULL)+ylab(NULL)+
               theme(legend.position = "none"), 
               
               ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = subset(cat_admx, cat_admx$k == 3)) +
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
                 scale_fill_manual(name = "grp",values = c("#b2e061","#fd7f6f","#7eb0d5"), guide = F) +xlab(NULL)+ylab(NULL)+
                 theme(legend.position = "none"),
               
ggplot(aes(x = reorder(pop_sample, popnumber), y = proportion, fill = factor(popGroup)), data = subset(cat_admx, cat_admx$k == 4)) +
                 geom_col(aes(fill = factor(popGroup)), linewidth = 0.1) +
                 labs(x=NULL, y = "Ancestry") +
                 scale_y_continuous(expand = c(0,0)) +
                 theme(
                   panel.spacing.x = element_blank(),
                   axis.text.x=element_text(angle=90, size = 3),
                   axis.text.y=element_blank(),
                   panel.grid = element_blank(),
                   strip.text.x = element_text(angle = 90, size = 6),
                   legend.position = "none",
                   axis.ticks.x = element_blank(),
                   axis.ticks.y = element_blank()
                 ) + 
                 guides(x = ggh4x::guide_axis_nested(delim = "&"))+
                 scale_fill_manual(name = "grp",values = c("#b2e061","#7eb0d5","#fd7f6f","#bd7ebe"), guide = F) +xlab(NULL)+ylab(NULL)+
                 theme(legend.position = "none"),
               ncol = 1, 
               bottom = "Sample ID #", 
               heights = c(1,1,1.5), 
               right = "K")


k6data <- subset(cat_admx, cat_admx$k==6)

for (i in 1:nrow(k6data)) {
  if(k6data$popnumber[i] %in% 1:19) {k6data$region[i] <- "N. Coast"}
  if(k6data$popnumber[i] %in% 20:25) {k6data$region[i] <- "SF Bay"}
  if(k6data$popnumber[i] %in% 26:30) {k6data$region[i] <- "MTY-SB"}
  if(k6data$popnumber[i] %in% 31:36) {k6data$region[i] <- "SoCal"}
  if(k6data$popnumber[i] %in% 37:68) {k6data$region[i] <- "Cascades-Sierra"}
  if(k6data$popnumber[i] %in% 69:79) {k6data$region[i] <- "Int. NW"}
  if(k6data$popnumber[i] %in% 80:82) {k6data$region[i] <- "Teton"}
  if(k6data$popnumber[i] %in% 83:88) {k6data$region[i] <- "Contact"}
  if(k6data$popnumber[i] %in% 89:102) {k6data$region[i] <- "Rockies"}
  if(k6data$popnumber[i] %in% 103:106) {k6data$region[i] <- "."}
}

k6data$regpop <- paste(k6data$sampleID, "&", k6data$region)
  

ggplot(aes(x = reorder(regpop, popnumber), y = proportion, fill = factor(popGroup)), data = k6data) +
  geom_col(aes(fill = factor(popGroup)), linewidth = 0.1) +
  labs(x=NULL, y = "Ancestry") +
  scale_y_continuous(expand = c(0,0)) +
  theme(
    panel.spacing.x = unit(0.0, "lines"),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    panel.grid = element_blank(),
    ggh4x.axis.nestline.x = element_line(size = 2),
    ggh4x.axis.nesttext.x = element_text(size = 11, angle = 0),
    legend.position = "none",
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_blank()
  ) + 
  guides(x = ggh4x::guide_axis_nested(delim = "&", check.overlap = F, extend = -0.5), angle = 0)+
  scale_fill_manual(name = "grp",values = c("#fd7f6f","#bd7ebe","#ffb55a","#b2e061","#7eb0d5","#ffee65"), guide = F) +xlab(NULL)+ylab(NULL)+
  theme(legend.position = "none")


