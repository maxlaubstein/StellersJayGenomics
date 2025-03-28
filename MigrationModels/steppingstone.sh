cd /media/data2/STJARangewideGenomics/BA3

../vcf2phylip/vcf2phylip.py -i ../VCFdata/pops80-102/pops80-102_LD_Pruned_noinvariant.recode.vcf
perl phy2str.pl -p pops80-102_LD_Pruned_noinvariant.recode.min4.phy
