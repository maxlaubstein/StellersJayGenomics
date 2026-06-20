
~~~
mkdir -p gvcfs
cd gvcfs
sed '1d' ../samples.tsv | awk '{print $1}' > samples.txt

cat samples.txt | parallel -j 8 '
rsync -a --info=progress2 --partial --inplace \
ccgp-download.gi.ucsc.edu::ccgp/41-Cyanocitta_extended/gvcfs/{}.g.vcf.gz .

rsync -a --info=progress2 --partial --inplace \
ccgp-download.gi.ucsc.edu::ccgp/41-Cyanocitta_extended/gvcfs/{}.g.vcf.gz.tbi .
'
 bcftools view -R /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/41-Cyanocitta_callable_sites.bed -Oz -o callable.vcf.gz /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/41-Cyanocitta_raw.vcf.gz




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
