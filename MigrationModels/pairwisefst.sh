#!/bin/bash
cd /media/data2/STJARangewideGenomics/pairwiseFSTs
#FST 83 - 84
awk '$2 == 83' ../populations > pop83
awk '$2 == 84' ../populations > pop84
awk '$2 == 85' ../populations > pop85
awk '$2 == 86' ../populations > pop86
awk '$2 == 87' ../populations > pop87

vcftools --vcf ../VCFdata/autosomal_annotated_pruned.recode.vcf --weir-fst-pop pop83 --weir-fst-pop pop84 --out fst83_84
vcftools --vcf ../VCFdata/autosomal_annotated_pruned.recode.vcf --weir-fst-pop pop84 --weir-fst-pop pop85 --out fst84_85
vcftools --vcf ../VCFdata/autosomal_annotated_pruned.recode.vcf --weir-fst-pop pop85 --weir-fst-pop pop86 --out fst85_86
vcftools --vcf ../VCFdata/autosomal_annotated_pruned.recode.vcf --weir-fst-pop pop86 --weir-fst-pop pop87 --out fst86_87

