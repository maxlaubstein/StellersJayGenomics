library(vcfR)
library(readxl)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(plotly)
library(htmlwidgets)
library(ggstar)
library(triangulaR)



#read in metadata and the sample IDs in the fixed SNP vcf
metadata <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
sample_IDs <- read.table("keep", header = F)
metadata$`Pop # rev` <- as.numeric(metadata$`Pop # rev`)

#create a population map for the samples in this SNP dataset
popmap <- data.frame(id = sample_IDs$V1, pop = NA)
for (i in 1:nrow(popmap)){
  current <- subset(metadata, metadata$sample_name == popmap$id[i])
  if (current$`Pop # rev` %in% c(0:79)) {popmap$pop[i] <- "Northwest Interior (Pops. 69-79)"}
  if (current$`Pop # rev` %in% c(89:150)) {popmap$pop[i] <- "Rocky Mountains (Pops. 89-102)"}
  if (current$`Pop # rev` %in% c(80:82)) {popmap$pop[i] <- "Teton (Pops. 80-82)"} 
  if (current$`Pop # rev` %in% c(83:85)) {popmap$pop[i] <- "N. Contact Zone (Pops. 83-85)"}
  if (current$`Pop # rev` %in% c(86:88)) {popmap$pop[i] <- "S. Contact Zone (Pops. 86-88)"}
}



#read in the vcf of SNPs fixed between annectens and macrolopha populations.
VCF <- read.vcfR("fixed_IntNW_Rocky_unpruned_NOWPRUNED.vcf")

#Running alleleFreqDiff is redundant here, as in prior processing I filtered it down to only fixed differences.
#However, running this (and seeing all sites pass allele frequency difference threshold) validates the vcf filtering worked.
STJA.vcfR.diff <- alleleFreqDiff(vcfR = VCF, pm = popmap, p1 = "Northwest Interior (Pops. 69-79)", p2 = "Rocky Mountains (Pops. 89-102)" , difference = 1.0)

#Calculate hybrid index and heterozygosities for all contact zone individuals
hi.het.STJA <- hybridIndex(vcfR = STJA.vcfR.diff, pm = popmap, p1 = "Northwest Interior (Pops. 69-79)", p2 = "Rocky Mountains (Pops. 89-102)")

#add population numbers for plotting
hi.het.STJA$popnum <- NA
for (i in 1:nrow(hi.het.STJA)){
  hi.het.STJA$popnum[i] <- subset(metadata, metadata$sample_name == hi.het.STJA$id[i])$`Pop # rev`
}

hi.het.STJA$pop <- factor(
  hi.het.STJA$pop,
  levels = c(
    "Northwest Interior (Pops. 69-79)",
    "Teton (Pops. 80-82)",
    "N. Contact Zone (Pops. 83-85)",
    "S. Contact Zone (Pops. 86-88)",
    "Rocky Mountains (Pops. 89-102)"
  )
)


plot <- ggplot()+
        geom_segment(aes(x = 0.5, xend = 1, y = 1, yend = 0), color = "black") + geom_segment(aes(x = 0, xend = 0.5, y = 0, yend = 1), color = "black") +
        geom_segment(aes(x = 0, xend = 1, y = 0, yend = 0), color = "black") + stat_function(fun = function(hi) 2 * hi * (1 - hi), xlim = c(0, 1), color = "black", linetype = "dashed") +
        geom_star(data=subset(hi.het.STJA, hi.het.STJA$pop == "S. Contact Zone (Pops. 86-88)"), aes(hybrid.index, heterozygosity), color = NA, fill = "#FFD23F", alpha = 0.8, starshape = 29, size = 4)+
        geom_point(data= hi.het.STJA, aes(hybrid.index, heterozygosity, shape = pop, fill = pop, color = pop), size = 4)+
        xlab("Hybrid Index") +
        ylab("Heterozygosity")+
        scale_fill_manual("Group", values = alpha(c("#b2e061","#FFD23F","#FFD23F",NA,"#fd7f67"), 0.8)) +
        scale_color_manual("Group", values = alpha(c("#b2e061","#FFD23F","#FFD23F",NA,"#fd7f67"), 0.8)) +
        scale_shape_manual("Group", values = c(21,24,23,21,21))+
        theme_minimal()+
        coord_equal(clip = "off")+
        theme(legend.position = c(0.89,0.83), legend.title.position = "top", legend.title = element_text(face="bold"))+
        theme(
                legend.text = element_text(size = 6),
                legend.title = element_text(size = 7.5),
                legend.key.size = unit(0.4, "cm"),    # smaller boxes
                legend.spacing.y = unit(0.1, "cm"),    # tighter vertical spacing
                plot.margin = margin(5, 17, 5, 0, "pt")  # top, right, bottom, left
                )+
        guides(shape = guide_legend(override.aes = list(size = c(4, 3, 3.5, 4, 4))))


ggsave(plot = plot, filename = "/media/maxlaubstein/data1/STJARangewideGenomics/plots/triangleplot.pdf", device = "pdf", height = 3.5, width = 4.2, units = "in")


