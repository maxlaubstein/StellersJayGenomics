#!/bin/bash

awk '$2 >= 69 && $2 <= 79 {print $1}' populations.txt > intnw
awk '$2 >= 89 && $2 <= 102 {print $1}' populations.txt > rocky

#I took a random sample of 20 California/WNevada samples to represent the coastal lineage
echo -e "MVZCCGP-Cst89_I-F06
MVZ179160
MVZ179151
MVZCCGP-Cst130_I-E10
MVZ179133
MVZCCGP-Cst125_I-A10
MVZCCGP-Cst68_I-E05
MVZCCGP-Cst99_I-D07
MVZ180039
MVZCCGP-Cst140_I-B11
MVZCCGP-Cst98_I-C07
MVZCCGP-Cst145_I-F11
MVZCCGP-Cst122_I-G09
MVZCCGP-Cst150_II-A07
MVZCCGP-Cst3_I-C01
MVZ179132
MVZCCGP-Cst129_I-D10
MVZCCGP-Cst66_II-H03
MVZCCGP-Cst10_I-A02
MVZCCGP-Cst72_II-A04" > coastal

cat rocky intnw coastal > samples && echo BlueJay >> samples

#Generate a linkage disequilibrium pruned VCF from vcf with BLJA

vcftools --gzvcf All_Cyanocitta_Filtered.vcf.gz \
	--keep samples \
	--mac 1 \
	--recode \
	--recode-INFO-all \
	--out ABBABABA_unpruned

plink --vcf ABBABABA_unpruned.recode.vcf \
  --const-fid \
  --allow-extra-chr \
  --allow-no-sex \
  --set-missing-var-ids @:# \
  --indep-pairwise 50 10 0.1 \
  --out ABBABABA_pruned

plink --vcf ABBABABA_unpruned.recode.vcf  \
  --const-fid \
  --allow-extra-chr \
  --allow-no-sex \
  --set-missing-var-ids @:#  \
  --extract ABBABABA_pruned.prune.in \
  --recode vcf \
  --out ABBABABA_pruned

bcftools query -l ABBABABA_pruned.vcf > samplenames
awk '{print $1 "\t" substr($1, 3)}' samplenames > samplenamemap
bcftools reheader -s samplenamemap -o ABBABABA_pruned.vcf.tmp ABBABABA_pruned.vcf
rm ABBABABA_pruned.vcf
mv ABBABABA_pruned.vcf.tmp ABBABABA_pruned.vcf
bgzip ABBABABA_pruned.vcf
tabix -p vcf ABBABABA_pruned.vcf.gz
rm samplenames
rm samplenamemap

yes "rocky" | head -n "$(wc -l < rocky)" > lab1
yes "intnw" | head -n "$(wc -l < intnw)" > lab2
yes "coastal" | head -n "$(wc -l < coastal)" > lab3
cat lab1 lab2 lab3 > right && echo BlueJay >> right
paste samples right > popmap.txt

rm lab1 lab2 lab3 right intnw rocky coastal

echo "Parsing VCF"
conda activate genomics_general
python /media/maxlaubstein/data1/genomics_general/VCF_processing/parseVCF.py -i ABBABABA_pruned.vcf.gz | gzip > ABBABABA_pruned.geno.gz
echo "Calculating Frequencies"
python /media/maxlaubstein/data1/genomics_general/freq.py \
	-g ABBABABA_pruned.geno.gz \
	-p coastal \
	-p intnw \
	-p rocky \
	-p BlueJay \
	--popsFile popmap.txt \
	--target derived \
	--threads 6 \
	-o Cyanocitta.derFreq.tsv.gz

Rscript DStat.R > ABBABABA_output.txt

