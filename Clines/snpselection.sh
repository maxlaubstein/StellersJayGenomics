#We want to get sites that are polymorphic within the core contact zone (pops 83, 84, 85)
vcftools --vcf pops80-89_LD_Pruned.recode.vcf --keep pops83-84-85 --freq --out pops83-84-85_SNPfreqs

#Get a list of all SNPs with MAF frequency between 0.3 and 0.7 within the core contact zone
awk '$5 >= 0.3 && $5 <= 0.7 {print $1 ":" $2}' pops83-84-85_SNPfreqs.frqs > clineSNPs.txt
