## Steller's Jay Admixture Analysis

This directory contains all code used to run and plot the results of ADMIXTURE (Alexander et al., 2009).

I ran admixture separately for the whole 310 individual dataset, and the dataset of 306 non-Mesoamerican samples.

For each dataset, I ran admixture for K = 2 through 6 with cross validation error assessment from 3 different seeds.

In both the ```allsamples``` and ```nomeso``` directories the ```makeinput.sh``` scripts generate the necessary Plink-format input. Within eadch of these directories, there are also 3 subdirectories to run Admixture from 3 separate seeds, each with its own ```run.sh``` script.

The script ```admixturemap.r``` makes a pie chart map of ancestry proportions from the non-Mesoamerican seed1 output.

The script ```barplots.r``` makes the classic bar/column Admixture ancestry plots for K = 2 through 6, and also a row for mtDNA lineages

The script ```plot_cverror.r``` makes figures of cross-validation error across K values for the different seeds.
