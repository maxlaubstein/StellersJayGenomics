setwd("/media/maxlaubstein/data1/STJARangewideGenomics/EEMS/input")
library(readxl)
data <- read_excel("/media/maxlaubstein/data1/STJARangewideGenomics/1_Cyanocitta_stelleri_WGS_metadata_allsamples_fulldata_v2.xlsx")
data <- subset(data, data$isolate != "Middle America")
coords <- as.data.frame(data[,c("longitude","latitude")])

head(coords)
write.table(coords, col.names = F, row.names = F, file = "EEMS.coord")
