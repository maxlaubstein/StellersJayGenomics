library(data.table)
library(dplyr)
library(ggplot2)
library(ggrastr)
scaff_lengths <- read.table("scaff_lengths.txt")
scaff_lengths$V2 <- as.numeric(gsub(",assembly=unknown", "", scaff_lengths$V2))
scaff_lengths$V1 <- as.character(scaff_lengths$V1)

scaffs <- scaff_lengths %>%
  filter(V2 >= 2500000,
         V1 != "JANXIP010000003.1",
         V1 != "JANXIP010000028.1") %>%
  pull(V1)
scaff_lengths_filt <- scaff_lengths %>%
  filter(V1 %in% scaffs) %>%
  arrange(V1) %>%
  mutate(offset = lag(cumsum(V2), default = 0))

offset_map <- setNames(scaff_lengths_filt$offset,
                       scaff_lengths_filt$V1)

#Dxy data
dxy_data <- fread("results/dxy.tsv")
dxy_data$scaffold <- round(as.integer(substr(dxy_data$chrom, 10, 15)))
dxy_data <- subset(dxy_data, dxy_data$chrom %in% scaffs)
dxy_data <- dxy_data %>%
  arrange(scaffold, start) %>%
  mutate(order = row_number())
dxy_data$x <- dxy_data$start + offset_map[dxy_data$chrom]

#fst data
fst_data <- fread("results/fst.tsv")
fst_data$scaffold <- round(as.integer(substr(fst_data$chrom, 10, 15)))
fst_data <- subset(fst_data, fst_data$chrom %in% scaffs)
fst_data <- fst_data %>%
  arrange(scaffold, start) %>%
  mutate(order = row_number())
fst_data$x <- fst_data$start + offset_map[fst_data$chrom]

#R2 data

R2data <- fread("R2_25kb.ld")
R2data$scaffold <- round(as.integer(substr(R2data$chrom, 10, 15)))
sum(R2data$CHR_A != R2data$CHR_B) #all pairs are on the same chromosome. good
R2data <- subset(R2data, R2data$CHR_A %in% scaffs)


windowed_r2 <- data.frame()
for(scaff in scaffs){
  cat("\r", scaff)
  cat("\n")
  this_scaff <- subset(R2data, R2data$CHR_A == scaff)
  tmp <- data.frame(chr = scaff, window_start = seq(1, max(this_scaff$BP_B,na.rm = T), 25000))
  tmp$window_end <- tmp$window_start + (25000-1)
  tmp$mean_R2 <- NA
  for(j in 1:nrow(tmp)){
    cat(paste0("\r",j))
    tmp$mean_R2[j] <- mean(this_scaff[this_scaff$BP_A >= tmp$window_start[j] & this_scaff$BP_B < tmp$window_end[j],]$R2, na.rm = T)
  }
  windowed_r2 <- rbind(windowed_r2, tmp)
}

windowed_r2$scaffold <- round(as.integer(substr(windowed_r2$chr, 10, 15)))
windowed_r2 <- windowed_r2 %>%
  arrange(scaffold, window_start) %>%
  mutate(order = row_number())
windowed_r2$x <- windowed_r2$window_start + offset_map[windowed_r2$chr]

windowed_r2$window_name <- paste0(windowed_r2$chr,"_", windowed_r2$window_start)
dxy_data$window_name <- paste0(dxy_data$chrom,"_", dxy_data$start)
fst_data$window_name <- paste0(fst_data$chrom,"_", fst_data$start)

#none of these statistics shouldn't be negative. Get rid of those erroneous windows, and NAs
range(dxy_data$dxy, na.rm = T)
dxy_data <- dxy_data[!is.na(dxy_data$dxy)]

range(fst_data$fst, na.rm = T)
fst_data <- subset(fst_data, fst_data$fst <= 1 & fst_data$fst >= 0)
fst_data <- fst_data[!is.na(fst_data$fst),]

range(windowed_r2$mean_R2, na.rm = T)
windowed_r2 <- windowed_r2[!is.na(windowed_r2$mean_R2),]
windowed_r2$mean_R2 <- as.numeric(windowed_r2$mean_R2)

autosomal_dxy_mean <- mean(dxy_data$dxy, na.rm = T)
autosomal_fst_mean <- mean(fst_data$fst, na.rm = T)
autosomal_R2_mean <- mean(windowed_r2$mean_R2, na.rm = T)
message(paste("Autosomal Mean DXY:",autosomal_dxy_mean))
message(paste("Autosomal Mean FST:",autosomal_fst_mean))
message(paste("Autosomal Mean meanR2:",autosomal_R2_mean))

message("Autosomal DXY Quantiles:")
print(quantile(dxy_data$dxy, c(0.025, .975)))

message("Autosomal FST Quantiles:")
print(quantile(fst_data$fst, c(0.025, .975)))

message("Autosomal meanR2 Quantiles:")
print(quantile(windowed_r2$mean_R2, c(0.025, .975)))

################################################################################################################
################################################################################################################
#DXY
################################################################################################################
################################################################################################################
dxy_ylim <- range(dxy_data$dxy, na.rm = TRUE)
dxyplot <- ggplot()+
  geom_point_rast(data = dxy_data, 
              aes(x=x, y = dxy, color = as.factor(scaffold)), size = 0.1, alpha = 0.5, raster.dpi = 1000)+
  theme_minimal()+
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_blank()
  )+
  geom_segment(aes(x=0, xend = max(dxy_data$x), y = autosomal_dxy_mean, yend = autosomal_dxy_mean), color = '#3A74A1', linetype = 'dashed')+
  xlab("Sliding Windows Ordered Across Autosomal Scaffolds")+
  ylab("Dxy")+
  scale_color_manual(values = rep(c('gray40','black'), 200))+
  scale_x_continuous(expand = expansion(mult = 0.01))+
  scale_y_continuous(labels = function(x) sprintf("%.3f", x))

ggsave("/media/maxlaubstein/data1/STJARangewideGenomics/plots/DXY_plot.pdf", plot = dxyplot, width = 9, height = 2, device = "pdf")
################################################################################################################
################################################################################################################
#FST
################################################################################################################
################################################################################################################
fst_ylim <- range(fst_data$fst, na.rm = TRUE)
fstplot <- ggplot()+
  geom_point_rast(data = fst_data, 
             aes(x=x, y = fst, color = as.factor(scaffold)), size = 0.1, alpha = 0.5, raster.dpi = 1000)+
  theme_minimal()+
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_blank()
  )+
  geom_segment(aes(x=0, xend = max(fst_data$x), y = autosomal_fst_mean, yend = autosomal_fst_mean), color = '#3A74A1', linetype = 'dashed')+
  xlab("Sliding Windows Ordered Across Autosomal Scaffolds")+
  #ylab(bquote(F[st]))+
  ylab("FST")+
  scale_color_manual(values = rep(c('gray40','black'), 200))+
  scale_x_continuous(expand = expansion(mult = 0.01))+
  scale_y_continuous(limits = c(0,1), labels = function(x) sprintf("%.3f", x))

ggsave("/media/maxlaubstein/data1/STJARangewideGenomics/plots/FST_plot.pdf", plot = fstplot, width = 9, height = 2, device = "pdf")

################################################################################################################
################################################################################################################
#R2
################################################################################################################
################################################################################################################

R2_ylim <- range(windowed_r2$mean_R2, na.rm = TRUE)

R2plot <- ggplot()+
  geom_point_rast(data = windowed_r2, aes(x=x, y = mean_R2, color = chr), size = 0.1, alpha = 0.5, raster.dpi = 1000)+
  theme_minimal()+
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_blank()
  )+
  geom_segment(aes(x=0, xend = max(windowed_r2$x), y = autosomal_R2_mean, yend = autosomal_R2_mean), color = '#3A74A1', linetype = 'dashed')+
  xlab("Sliding Windows Ordered Across Autosomal Scaffolds")+
  #ylab(bquote(Mean ~ R^2))+
  ylab("Mean R2")+
  scale_color_manual(values = rep(c('gray40','black'), 200))+
  scale_x_continuous(expand = expansion(mult = 0.01))+
  scale_y_continuous(labels = function(x) sprintf("%.3f", x))

ggsave("/media/maxlaubstein/data1/STJARangewideGenomics/plots/R2_plot.pdf", plot = R2plot, width = 9, height = 2, device = "pdf")



################################################################################################################
################################################################################################################
#Now plot the Z chr:
################################################################################################################
################################################################################################################
scaff_lengths <- read.table("scaff_lengths.txt")
scaff_lengths$V2 <- as.numeric(gsub(",assembly=unknown", "", scaff_lengths$V2))
scaff_lengths$V1 <- as.character(scaff_lengths$V1)

scaffs <- scaff_lengths %>%
  filter(V1 == "JANXIP010000003.1") %>%
  pull(V1)
scaff_lengths_filt <- scaff_lengths %>%
  filter(V1 %in% scaffs) %>%
  arrange(V1) %>%
  mutate(offset = lag(cumsum(V2), default = 0))

offset_map <- setNames(scaff_lengths_filt$offset,
                       scaff_lengths_filt$V1)



#Dxy data
dxy_data <- fread("results/dxy.tsv")
dxy_data$scaffold <- round(as.integer(substr(dxy_data$chrom, 10, 15)))
dxy_data <- subset(dxy_data, dxy_data$chrom %in% scaffs)
dxy_data <- dxy_data %>%
  arrange(scaffold, start) %>%
  mutate(order = row_number())
dxy_data$x <- dxy_data$start + offset_map[dxy_data$chrom]

#fst data
fst_data <- fread("results/fst.tsv")
fst_data$scaffold <- round(as.integer(substr(fst_data$chrom, 10, 15)))
fst_data <- subset(fst_data, fst_data$chrom %in% scaffs)
fst_data <- fst_data %>%
  arrange(scaffold, start) %>%
  mutate(order = row_number())
fst_data$x <- fst_data$start + offset_map[fst_data$chrom]

#R2 data

R2data <- fread("R2_25kb.ld")
R2data$scaffold <- round(as.integer(substr(R2data$chrom, 10, 15)))
sum(R2data$CHR_A != R2data$CHR_B) #all pairs are on the same chromosome. good
R2data <- subset(R2data, R2data$CHR_A %in% scaffs)


windowed_r2 <- data.frame()
for(scaff in scaffs){
  cat("\r", scaff)
  cat("\n")
  this_scaff <- subset(R2data, R2data$CHR_A == scaff)
  tmp <- data.frame(chr = scaff, window_start = seq(1, max(this_scaff$BP_B,na.rm = T), 25000))
  tmp$window_end <- tmp$window_start + (25000-1)
  tmp$mean_R2 <- NA
  for(j in 1:nrow(tmp)){
    cat(paste0("\r",j))
    tmp$mean_R2[j] <- mean(this_scaff[this_scaff$BP_A >= tmp$window_start[j] & this_scaff$BP_B < tmp$window_end[j],]$R2, na.rm = T)
  }
  windowed_r2 <- rbind(windowed_r2, tmp)
}

windowed_r2$scaffold <- round(as.integer(substr(windowed_r2$chr, 10, 15)))
windowed_r2 <- windowed_r2 %>%
  arrange(scaffold, window_start) %>%
  mutate(order = row_number())
windowed_r2$x <- windowed_r2$window_start + offset_map[windowed_r2$chr]

windowed_r2$window_name <- paste0(windowed_r2$chr,"_", windowed_r2$window_start)
dxy_data$window_name <- paste0(dxy_data$chrom,"_", dxy_data$start)
fst_data$window_name <- paste0(fst_data$chrom,"_", fst_data$start)

range(dxy_data$dxy, na.rm = T)
dxy_data <- dxy_data[!is.na(dxy_data$dxy)]

range(fst_data$fst, na.rm = T)
fst_data <- subset(fst_data, fst_data$fst <= 1 & fst_data$fst >= 0)
fst_data <- fst_data[!is.na(fst_data$fst),]

range(windowed_r2$mean_R2, na.rm = T)
windowed_r2 <- windowed_r2[!is.na(windowed_r2$mean_R2),]
windowed_r2$mean_R2 <- as.numeric(windowed_r2$mean_R2)

Z_dxy_mean <- mean(dxy_data$dxy, na.rm = T)
Z_fst_mean <- mean(fst_data$fst, na.rm = T)
Z_R2_mean <- mean(windowed_r2$mean_R2, na.rm = T)

message(paste("Z Mean DXY:",Z_dxy_mean))
message(paste("Z Mean FST:",Z_fst_mean))
message(paste("Z Mean meanR2:",Z_R2_mean))

message("Z DXY Quantiles:")
print(quantile(dxy_data$dxy, c(0.025, .975)))

message("Z FST Quantiles:")
print(quantile(fst_data$fst, c(0.025, .975)))

message("Z meanR2 Quantiles:")
print(quantile(windowed_r2$mean_R2, c(0.025, .975)))

Z_dxyplot <- ggplot()+
  geom_point_rast(data = dxy_data, 
                  aes(x=x, y = dxy), size = 0.1, alpha = 0.5, raster.dpi = 1000, color = 'black')+
  theme_minimal()+
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.line.y = element_blank()
  )+
  geom_segment(aes(x=0, xend = max(dxy_data$x), y = Z_dxy_mean, yend = Z_dxy_mean), color = '#3A74A1', linetype = 'dashed')+
  xlab("Z")+
  ylab(NULL)+
  scale_x_continuous(expand = expansion(mult = 0.01))+
  scale_y_continuous(limits = dxy_ylim)

ggsave("/media/maxlaubstein/data1/STJARangewideGenomics/plots/Z_DXY_plot.pdf", plot = Z_dxyplot, width = 0.75, height = 2, device = "pdf")

Z_fstplot <- ggplot()+
  geom_point_rast(data = fst_data, 
                  aes(x=x, y = fst), size = 0.1, alpha = 0.5, raster.dpi = 1000, color = 'black')+
  theme_minimal()+
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.line.y = element_blank()
  )+
  geom_segment(aes(x=0, xend = max(fst_data$x), y = Z_fst_mean, yend = Z_fst_mean), color = '#3A74A1', linetype = 'dashed')+
  xlab("Z")+
  #ylab(bquote(F[st]))+
  ylab(NULL)+
  scale_x_continuous(expand = expansion(mult = 0.01))+
  scale_y_continuous(limits = c(0,1))

ggsave("/media/maxlaubstein/data1/STJARangewideGenomics/plots/Z_FST_plot.pdf", plot = Z_fstplot, width = 0.75, height = 2, device = "pdf")

Z_R2plot <- ggplot()+
  geom_point_rast(data = windowed_r2, aes(x=x, y = mean_R2), size = 0.1, alpha = 0.5, raster.dpi = 1000, color = 'black')+
  theme_minimal()+
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.line.y = element_blank()
  )+
  geom_segment(aes(x=0, xend = max(windowed_r2$x), y = Z_R2_mean, yend = Z_R2_mean), color = '#3A74A1', linetype = 'dashed')+
  xlab("Z")+
  ylab(NULL)+
  scale_x_continuous(expand = expansion(mult = 0.01))+
  scale_y_continuous(limits = R2_ylim)

ggsave("/media/maxlaubstein/data1/STJARangewideGenomics/plots/Z_R2_plot.pdf", plot = Z_R2plot, width = 0.75, height = 2, device = "pdf")
