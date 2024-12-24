setwd("/Users/maxlaubstein/Desktop/STJA/scripts")
library(triangulaR)
library(vcfR)
library(SNPfiltR)
library(readxl)
library(ggrepel)
library(plotly)
library(dplyr)

#read in metadata and the sample IDs in the fixed SNP vcf
metadata <- read_excel("../1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
sample_IDs <- read.csv("../pops80-102_LD_Pruned_fixed_sample_names.txt", header = F)

#create a population map for the samples in this SNP dataset
popmap <- data.frame(id = sample_IDs$V1, pop = NA)
for (i in 1:nrow(popmap)){
  current <- subset(metadata, metadata$sample_name == popmap$id[i])
  if (current$`Pop # rev` %in% c(0:82)) {popmap$pop[i] <- "P1"} # pure annectens individuals assigned to "P1"
  if (current$`Pop # rev` %in% c(89:150)) {popmap$pop[i] <- "P2"} # pure Rockies individuals assigned to "P2"
  if (current$`Pop # rev` %in% c(83:88)) {popmap$pop[i] <- "CZ"} # pure Rockies individuals assigned to "CZ"
}

#read in the vcf of 8479 SNPs fixed between annectens and macrolopha populations.
VCF <- read.vcfR("../pops80-102_LD_Pruned_fixed.recode.vcf") #8479 SNPs

#Running alleleFreqDiff is redundant here, as in prior processing I filtered it down to only fixed differences.
#However, running this (and seeing all sites pass allele frequency difference threshold) validates the vcf filtering worked.
STJA.vcfR.diff <- triangulaR::alleleFreqDiff(vcfR = VCF, pm = popmap, p1 = "P1", p2 = "P2", difference = 1.0)

#Calculate hybrid index and heterozygosities for all contact zone individuals
hi.het.STJA <- triangulaR::hybridIndex(vcfR = STJA.vcfR.diff, pm = popmap, p1 = "P1", p2 = "P2")

#add population numbers for plotting
hi.het.STJA$popnum <- NA
for (i in 1:nrow(hi.het.STJA)){
  hi.het.STJA$popnum[i] <- subset(metadata, metadata$sample_name == hi.het.STJA$id[i])$`Pop # rev`
}


plot <- ggplot(hi.het.STJA, aes(hybrid.index, heterozygosity, label = popnum, color = as.factor(pop))) + 
  geom_point(size = 4) + 
  theme_classic() + 
  geom_text_repel(data = subset(hi.het.STJA, hi.het.STJA$pop=="CZ"), col = 'black', size = 3, max.overlaps = 100) +
  geom_segment(aes(x = 0.5, xend = 1, y = 1, yend = 0), color = "black") + geom_segment(aes(x = 0, xend = 0.5, y = 0, yend = 1), color = "black") +
  geom_segment(aes(x = 0, xend = 1, y = 0, yend = 0), color = "black") + stat_function(fun = function(hi) 2 * hi * (1 - hi), xlim = c(0, 1), color = "black", linetype = "dashed") +
  xlab("Hybrid Index") +
  ylab("Heterozygosity") +
  scale_colour_manual(values = alpha(c("#ffb55a","#b2e061","#fd7f67"), 0.8), 
                      breaks = c("CZ", "P1", "P2"), 
                      labels = c("Contact Zone", "annectens", "macrolopha"),
                      name = "Group")

#for an interactive plot
ggplotly(plot)
