cd /media/data2/STJARangewideGenomics/admixture_analyses/nomeso
plink --vcf ../VCFdata/41-Cyanocitta_annotated_pruned_0.6.vcf --make-bed --allow-extra-chr 

vcftools --vcf ../VCFdata/41-Cyanocitta_annotated_pruned_0.6.vcf --make-bed --allow-extra-chr --remove-indv MVZ188144 --remove-indv MVZ189266 --remove-indv MVZ189267 --remove-indv UWBM106814 --out nomesoamerica
