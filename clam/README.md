Clam MS
" We filtered VCFs by excluding indels, retaining only biallelic SNPs, and setting genotypes to missing when depth <2 or reference genotype quality (RGQ) < 10"
..."with the following modifications to the filtering thresholds: depth of ≥10, genotype quality ≥10, as well as applying GATK hard filters to variant sites."
~~~
clam stat -o results/ -w 25000 -t 10 -c /media/maxlaubstein/data1/STJARangewideGenomics/clam/41-Cyanocitta_extended_core/callable.zarr/ --samples samples.tsv --force-samples  /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_clean.vcf.gz
~~~

Recombination:
~~~
sed '1d' samples.tsv | awk '{print $1}' > tmp
paste tmp tmp > keep
rm tmp
plink --vcf /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_clean.vcf.gz \
  --mac 1 --r2 --ld-window-kb 25 --keep keep --allow-extra-chr
~~~
