

#Download the raw Blue Jay reads
conda activate sra_tools
prefetch SRR31732106 --max-size 100000000000
prefetch SRR31732103 --max-size 100000000000

#Get the fastq files
fasterq-dump SRR31732106/SRR31732106.sra  -e 6 -v -v -v
fasterq-dump SRR31732103/SRR31732103.sra  -e 6 -v -v -v

#Concatenate them:
cat SRR31732103.fastq SRR31732106.fastq > BLJA_Reads.fastq

#Remove the precursor files for organization's sake:
rm SRR31732103.fastq SRR31732106.fastq

conda deactivate
conda activate minimap2

#Map to Steller's Jay Reference
minimap2 -ax map-hifi -t 8 /media/maxlaubstein/data1/STJARangewideGenomics/STJA_RefGenome/GCA_026167965.1_bCyaSte1.0.p_genomic.fna  BLJA_Reads.fastq > Cyanocitta_aligned.sam

#Generate BED file of coordinates of all SNP sites in the Steller's Jay VCF:
bcftools query -f '%CHROM\t%POS0\t%POS\n' /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz > STJA_SNP_SITES.bed

#Convert SAM to BAM:
samtools view -b -S Cyanocitta_aligned.sam > Cyanocitta_aligned.bam

#Sort and index BAM:
samtools sort -o Cyanocitta_aligned_sorted.bam Cyanocitta_aligned.bam
samtools index Cyanocitta_aligned_sorted.bam

conda deactivate
conda activate gatk

#Get read groups for gatk:
gatk AddOrReplaceReadGroups -I Cyanocitta_aligned_sorted.bam -O Cyanocitta_aligned_sorted_rg.bam \
	--RGLB lib1 --RGPL PACBIO --RGPU PACBIO1 --RGSM BlueJay --CREATE_INDEX

# Call genotypes

gatk --java-options "-Xmx99g -Xss4m" HaplotypeCaller \
	-R /media/maxlaubstein/data1/STJARangewideGenomics/STJA_RefGenome/GCA_026167965.1_bCyaSte1.0.p_genomic.fna \
        -I Cyanocitta_aligned_sorted_rg.bam --output-mode EMIT_ALL_CONFIDENT_SITES --emit-ref-confidence GVCF \
	-O BlueJayGenotyped.g.vcf.gz -L STJA_SNP_SITES.bed --pairHMM AVX_LOGLESS_CACHING --native-pair-hmm-threads 7



gatk --java-options "-Xmx99g" GenotypeGVCFs \
	-R /media/maxlaubstein/data1/STJARangewideGenomics/STJA_RefGenome/GCA_026167965.1_bCyaSte1.0.p_genomic.fna \
	-V BlueJayGenotyped.g.vcf.gz -O BlueJay_Genotyped.vcf.gz --standard-min-confidence-threshold-for-calling 8 --include-non-variant-sites


conda deactivate
# Merge

bcftools merge -R STJA_SNP_SITES.bed -O z -o Cyanocitta_Merged.vcf.gz BlueJay_Genotyped.vcf.gz  /media/maxlaubstein/data1/STJARangewideGenomics/vcfdata/Cyanocitta_Clean_Autosomal_No_Mesoamerica.vcf.gz
tabix -p vcf Cyanocitta_Merged.vcf.gz

#Exclude sites that are missing or variable within Blue Jay:
bcftools view -i 'GT[*] = "mis" || GT[*] = "het"' BlueJay_Genotyped.vcf.gz | bcftools query -f '%CHROM\t%POS\n' > BLJA_exclude
bcftools view -T ^BLJA_exclude -m2 -M2 -v snps -O z -o All_Cyanocitta_Filtered.vcf.gz Cyanocitta_Merged.vcf.gz
tabix -p vcf All_Cyanocitta_Filtered.vcf.gz
