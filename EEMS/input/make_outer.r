setwd("/media/maxlaubstein/data1/STJARangewideGenomics/EEMS/input")
library(sf)
kml <- st_read("EEMS_Outer.kml")

coords <- st_coordinates(kml)
coords <- coords[,c(1,2)]
head(coords)
write.table(coords, col.names = F, row.names = F, file = "EEMS.outer")
