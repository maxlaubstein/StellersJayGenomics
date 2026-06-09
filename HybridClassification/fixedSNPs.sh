awk '$2 >= 69 && $2 <= 79 {print $1}' /media/maxlaubstein/data1/STJARangewideGenomics/populations > IntNW
awk '$2 >= 89 && $2 <= 102 {print $1}' /media/maxlaubstein/data1/STJARangewideGenomics/populations > Rocky

#Calculate per SNP FST between rocky and pops 89-102 (pure macrolopha)
vcftools --gzvcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz  --mac 1  --weir-fst-pop IntNW --weir-fst-pop Rocky --out persnpfst_IntNW_Rocky_unpruned

#Subset original vcf to only sites that are fixed (FST = 1.0) between the pure parental populations.  These will be our ancestry-informative SNPs.
#fixed.snps.txt includes only fixed SNPs.

awk '$3 == 1 {print}' persnpfst_IntNW_Rocky_unpruned.weir.fst > fixed_IntNW_Rocky_unpruned

#some reformatting
awk '{print $1 "  " $2}' fixed_IntNW_Rocky_unpruned > fixed_IntNW_Rocky_unpruned.coords.txt

awk '$2 >= 69 && $2 <= 102 {print $1}' /media/maxlaubstein/data1/STJARangewideGenomics/populations > keep

#subset the original vcf:
vcftools --gzvcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz  \
  --positions fixed_IntNW_Rocky_unpruned.coords.txt \
  --recode \
  --mac 1 \
  --keep keep \
  --out fixed_IntNW_Rocky_unpruned

plink --vcf  fixed_IntNW_Rocky_unpruned.recode.vcf \
  --const-fid \
  --allow-extra-chr \
  --allow-no-sex \
  --set-missing-var-ids @:# \
  --indep-pairwise 50 10 0.1 \
  --out fixed_IntNW_Rocky_unpruned_NOWPRUNED

plink --vcf fixed_IntNW_Rocky_unpruned.recode.vcf  \
  --const-fid \
  --allow-extra-chr \
  --allow-no-sex \
  --set-missing-var-ids @:#  \
  --extract fixed_IntNW_Rocky_unpruned_NOWPRUNED.prune.in \
  --recode vcf \
  --out fixed_IntNW_Rocky_unpruned_NOWPRUNED

bcftools query -l fixed_IntNW_Rocky_unpruned_NOWPRUNED.vcf > samplenames

awk '{print $1 "\t" substr($1, 3)}' samplenames > samplenamemap

bcftools reheader -s samplenamemap -o fixed_IntNW_Rocky_unpruned_NOWPRUNED.vcf.tmp fixed_IntNW_Rocky_unpruned_NOWPRUNED.vcf

rm fixed_IntNW_Rocky_unpruned_NOWPRUNED.vcf

mv fixed_IntNW_Rocky_unpruned_NOWPRUNED.vcf.tmp fixed_IntNW_Rocky_unpruned_NOWPRUNED.vcf
