
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



for s in MVZ182152 MVZ182157 MVZ182161 MVZ182163 MVZ182164 MVZ180625 MVZ180604 MVZ180613 MVZ191139 MVZ179910 MVZ179916 MVZ179918 MVZ179919 MVZ179925 MVZ179503 MVZ177640 MVZ178957 MVZ184733 MVZ184724 MVZ191140 MVZ191141 MVZ191142 MVZ191143 MVZ191144 MVZ188014 MVZ180079 MVZ180075 MVZ169368 MVZ180080 MVZ177678 UWBM103325 MVZ188034 MVZ188052 UWBM115511 MVZ179382 MSB26346 MVZ187983 MVZ188002
do
  rsync -avP ccgp-download.gi.ucsc.edu::ccgp/41-Cyanocitta_extended/gvcfs/${s}.g.vcf.gz .
  rsync -avP ccgp-download.gi.ucsc.edu::ccgp/41-Cyanocitta_extended/gvcfs/${s}.g.vcf.gz.tbi .
done

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
