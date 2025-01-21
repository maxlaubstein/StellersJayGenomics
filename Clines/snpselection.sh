#We want to get sites that are polymorphic within the core contact zone (pops 83, 84, 85)
#Get sites with MAF greater than 0.3 and 0.7
vcftools --vcf pops80-89_LD_Pruned.recode.vcf --keep pops83-84-85 --maf 0.3 --out pops83-84-85_0.3MAF --recode

#Get the the site coords
awk 'BEGIN {OFS="\t"} !/^#/ {print $1 "  " $2}' pops83-84-85_0.3MAF.recode.vcf > clineSNPs.txt

#Keep only these sites in our vcf with samples from across the whole contact zone transect (pops 80 - 89)
vcftools --vcf pops80-89_LD_Pruned.recode.vcf --positions clineSNPs.txt --out pops80-89_ClineSNPs --recode
