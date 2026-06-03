library(ggplot2)
library(dplyr)
library(data.table)
library(ggrastr)

args <- commandArgs(trailingOnly = TRUE)
message("Reading Data...")
data <- fread(args[1])

message("Formatting Scaffolds...")
data$scaffold <- round(as.integer(substr(data$chr, 10, 15)))

message("Correcting p-values...")
data$p_adj <- p.adjust(data$p_var, method = "fdr")
data$log10p_adj <- -log10(data$p_adj)

message("Ordering Scaffolds...")
data <- data %>%
  arrange(scaffold, pos) %>%
  mutate(order = row_number())

message("Plotting...")

plot <- ggplot(data, aes(x=order, y=log10p_adj)) +
  geom_point_rast(size = 0.5, aes(color = as.factor(scaffold)), alpha = 0.5, raster.dpi = 100) +
  theme_minimal() +
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_blank()
  ) +
  scale_color_manual(values = rep(c('gray40','black'), 165)) +
  ylab("-log10(p)") +
  xlab("SNPs Ordered Across Scaffolds") +
  ylim(0,NA)

message(paste0("Saving Plot to ", args[1], "_manhattan.pdf..."))
ggsave(paste0(basename(args[1]), "_manhattan.png"), plot = plot, width = 7, height = 2, device = "png", dpi = 80)

message("Done!")
