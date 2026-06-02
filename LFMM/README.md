Genotype-Environment Association analysis using Latent Factor Mixed Modeling (LFMM) with Steller's Jays.
The script ```run_LFMM.r``` runs LFMM on a provided vcf and tif raster file, with the usage ```Rscript run_LFMM.r <vcf> <tif>```.

Because (as far as I can tell) LFMM runs single threaded, I wrote this so I could run LFMM separately for each variable of interest in a separate screen session.
