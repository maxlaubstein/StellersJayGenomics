plink --vcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_LDPruned_Autosomal_No_Mesoamerica.vcf.gz \
  --const-fid \
  --allow-extra-chr \
  --allow-no-sex \
  --no-sex \
  --no-parents \
  --no-pheno \
  --set-missing-var-ids @:# \
  --recode \
  --out EEMS

#From https://github.com/mcaitlinv/cawa-breeding/blob/main/04_esu/scripts/11.conda.eems.sbatch:
##Dummy code scaffold # as 1, since plink/bed2diffs don't like scaffolds
awk 'BEGIN { FS = "\t"};{ OFS="\t" } ; {print 1, $2, $3, $4, $5}' EEMS.map > temp.map
mv temp.map EEMS.map
##Get the bed/bim files
plink --file EEMS --out EEMS --make-bed

/media/maxlaubstein/data1/STJARangewideGenomics/eems/bed2diffs/src/bed2diffs_v1 --bfile EEMS --nthreads 6
