D.stat <- function(p1, p2, p3) {
  ABBA <- (1 - p1) * p2 * p3
  BABA <- p1 * (1 - p2) * p3
  (sum(ABBA, na.rm=T) - sum(BABA, na.rm=T)) / (sum(ABBA, na.rm=T) + sum(BABA, na.rm=T))
}

freq_table = read.table("Cyanocitta.derFreq.tsv.gz", header=T, as.is=T)

#assume topology (((P1, P2),P3),O);

P1 <- "coastal"
P2 <- "intnw"
P3 <- "rocky"

D <- D.stat(freq_table[,P1], freq_table[,P2], freq_table[,P3])

print(paste("D =", round(D,4)))

source("jackknife.r")

block_indices <- get.block.indices(block_size=1e7,
                                   positions=freq_table$position,
                                   chromosomes=freq_table$scaffold)

n_blocks <- length(block_indices)

print(paste("Genome divided into", n_blocks, "blocks."))



D_jackknife <- block.jackknife(block_indices=block_indices,
                               FUN=D.stat,
                               freq_table[,P1], freq_table[,P2], freq_table[,P3])

print(paste("D jackknife mean =", round(D_jackknife$mean,4)))



D_Z <- D_jackknife$mean / D_jackknife$standard_error

print(paste("D Z score = ", round(D_Z,3)))



print(paste("D SE = ", D_jackknife$standard_error))
