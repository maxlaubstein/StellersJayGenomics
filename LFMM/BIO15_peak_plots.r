library(data.table)
library(ape)
library(ggplot2)
library(ggrepel)
data <- fread("output/bio15.tsv")
gff <- read.gff("../GCA_026167965.1_bCyaSte1.0.p_liftoff.gff.gz")
gff <- subset(gff, gff$type == "gene")
repeats <- read.gff("../bCyaSte1.NCBI.p_ctg.fasta.out.gff")


data$scaffold <- round(as.integer(substr(data$chr, 10, 15)))
data$log10p_raw <- -1*log10(data$p_var)

message("Where are the 2 main peaks?:")
message("Top 10 SNPs:")
data[order(data$log10p_raw, decreasing = TRUE)[1:10],c("chr", "pos", "log10p_raw")]

candidates <- function(lfmmoutput, windowsize, threshold, gff) {
  genesofinterest <- list()
  snpsofinterest <- subset(lfmmoutput, lfmmoutput$log10p_raw >= threshold)
  for(i in 1:nrow(snpsofinterest)) {
    gff.tmp <- subset(gff, gff$seqid == snpsofinterest$chr[i])
    gff.tmp <- subset(gff.tmp, gff.tmp$start <= (snpsofinterest$pos[i] + windowsize) &
                        gff.tmp$end >= (snpsofinterest$pos[i] - windowsize))
    if(nrow(gff.tmp) > 0) {genesofinterest[[snpsofinterest$snp[i]]] <- gff.tmp}
  }
  for(j in 1:length(genesofinterest)) {
    genesofinterest[[j]]$gene <- sapply(strsplit(genesofinterest[[j]]$attributes, "ID=gene-"), `[`, 2)
    genesofinterest[[j]]$gene <- sapply(strsplit(genesofinterest[[j]]$gene, ";Dbxref"), `[`, 1)
  }
  return(genesofinterest)
}


out <- candidates(data, 499000, 3, gff)

scaff2 <- subset(data, data$chr == "JANXIP010000002.1" & data$pos >= (34182127- 263845) & data$pos <= (34182127+ 263845))
scaff2annotated <- out[["JANXIP010000002.1:34182127"]]
scaff2annotated$gene <- gsub("^LOC", "", scaff2annotated$gene)

scaff2plot <- ggplot()+
  geom_rect(data = scaff2annotated, 
            fill = "#3A74A1",
            aes(xmin = start, 
                xmax = end, 
                ymin=rep(c(0,-.6,-1.2, -1.8), length.out = nrow(scaff2annotated)) - .15, 
                ymax=rep(c(-.3,-.9,-1.5, -2.1), length.out = nrow(scaff2annotated)) - .15))+
  geom_text_repel(data = scaff2annotated, size = 1.4,
                  aes(label = gene,
                      x = ((start + end)/2), 
                      y = rep(c(0,-.6, -1.2, -1.8), length.out = nrow(scaff2annotated)) - .6), point.size = NA, direction = "x",  force = 0.1, box.padding = 0.1)+
  geom_point(data = scaff2, aes(x=pos, y = log10p_raw), size = 0.5)+
  geom_segment(data = scaff2annotated,
               aes(x = ifelse(strand == "+", start, end),
                   xend = ifelse(strand == "+", end, start),
                   y = rep(c(0,-.6,-1.2,-1.8), length.out = nrow(scaff2annotated)) - .3,
                   yend = rep(c(0,-.6,-1.2,-1.8), length.out = nrow(scaff2annotated)) - .3),
               arrow = arrow(length = unit(0.02, "inches"),
                             ends = "last", type = "closed"),
               color = "black", size = 0.2) +
  xlim((34182127- 263845), (34182127+ 263845))+
  coord_cartesian(ylim = c(-3, 6.5)) +  # force y-axis limits without clipping data
  xlab("Position on Scaffold 2 (Mb)")+
  ylab("-log10(p)")+
  scale_x_continuous(
    limits = c(34182127 - 263845, 34182127 + 263845),
    labels = function(x) sprintf("%.1f", x / 1e6),
    expand = expansion(mult = c(0.01, 0.08))
  ) +
  scale_y_continuous(breaks = c(0, 2, 4, 6),  minor_breaks = NULL,
                     labels = c("0", "2", "4", "6"))+
  theme_minimal()
ggsave("Scaffold_2_LFMM.pdf", plot = scaff2plot, width = 3.5, height = 2.5, device = "pdf")


scaff19 <- subset(data, data$chr == "JANXIP010000019.1"& data$pos >= (14013369- 263845) & data$pos <= (14013369+ 263845))
scaff19annotated <- out[["JANXIP010000019.1:14013369"]]
scaff19annotated$gene <- gsub("^LOC", "", scaff19annotated$gene)

scaff19plot <- ggplot()+
  geom_rect(data = scaff19annotated, 
            fill = "#3A74A1",
            aes(xmin = start, 
                xmax = end, 
                ymin=rep(c(0,-.6,-1.2), length.out = nrow(scaff19annotated)) - .5, 
                ymax=rep(c(-.3,-.9,-1.5), length.out = nrow(scaff19annotated)) - .5))+
  geom_text(data = scaff19annotated, size = 1.4,
            aes(label = gene,
                x = ((start + end)/2), 
                y = rep(c(0,-.6,-1.2), length.out = nrow(scaff19annotated)) - .95))+
  geom_rect(data = subset(repeats, repeats$seqid == "SCAF_19"),
            fill = 'darkred',
            aes(xmin = start, xmax = end, ymin = -.45, ymax = -.15))+
  geom_point(data = scaff19, size = 0.5, aes(x=pos, y = log10p_raw))+
  geom_segment(data = scaff19annotated,
               aes(x = ifelse(strand == "+", start, end),
                   xend = ifelse(strand == "+", end, start),
                   y = rep(c(0,-.6,-1.2), length.out = nrow(scaff19annotated)) - .65,
                   yend = rep(c(0,-.6,-1.2), length.out = nrow(scaff19annotated)) - .65),
               arrow = arrow(length = unit(0.02, "inches"),
                             ends = "last", type = "closed"),
               color = "black", size = 0.2) +
  xlim((14013845- 263845), (14013845+ 263845))+
  coord_cartesian(ylim = c(-3, 6.5)) +  # force y-axis limits without clipping data
  xlab("Position on Scaffold 19 (Mb)")+
  ylab("-log10(p)")+
  scale_x_continuous(
    limits = c(14013845 - 263845, 14013845 + 263845),
    labels = function(x) sprintf("%.1f", x / 1e6),
    expand = expansion(mult = c(0.01, 0.08))
  ) +
  scale_y_continuous(breaks = c(0, 2, 4, 6),  minor_breaks = NULL,
                     labels = c("0", "2", "4", "6"))+
  annotate("text", x = 13900000, y = 0.5, label = "Repeat Dense Region", color = 'darkred', size = 1.4)+
  theme_minimal()
#  theme(panel.grid.minor = element_blank(), 
#        panel.grid.major = element_blank(),
#        axis.ticks = element_line(color = "black"))
ggsave("Scaffold_19_LFMM.pdf", plot = scaff19plot, width = 3.5, height = 2.5, device = "pdf")
