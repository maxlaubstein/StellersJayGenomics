#Calculate per SNP FST between pops80-82 (pure annectens) and pops 89-102 (pure macrolopha)
vcftools --vcf pops80-102_LD_Pruned.vcf --weir-fst-pop pops80-82 --weir-fst-pop pops89-102 

#Subset original vcf to only sites that are fixed (FST = 1.0) between the pure parental populations.  These will be our ancestry-informative SNPs.
#fixed.snps.txt includes only fixed SNPs.
awk '$3 == 1 {print}' pops80-102_LD_Pruned_perSNPFST.weir.fst > fixed.snps.txt

#some reformatting
awk '{print $1 "  " $2}' fixed.snps.txt > fixed.snps.coords.txt

#subset the original vcf:
vcftools --vcf pops80-102_LD_Pruned.vcf --positions fixed.snps.coords.txt --recode --out pops80-102_LD_Pruned_fixed

#get the sample names:
bcftools query -l pops80-102_LD_Pruned_fixed.recode.vcf > pops80-102_LD_Pruned_fixed_sample_names.txt
