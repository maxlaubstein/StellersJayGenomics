#!/bin/bash
cd /media/data2/STJARangewideGenomics/pairwiseFSTs

awk '$2 == 83' ../populations > pop83
awk '$2 == 84' ../populations > pop84
awk '$2 == 85' ../populations > pop85
awk '$2 == 86' ../populations > pop86
awk '$2 == 87' ../populations > pop87
awk '$2 >= 69 && $2 <= 82' ../populations > pops69_82
awk '$2 >= 88 && $2 <= 102' ../populations > pops89_102
awk '$2 >= 83 && $2 <= 87' ../populations > pops83_87

vcftools --vcf ../VCFdata/autosomal_annotated_pruned.recode.vcf --weir-fst-pop pop83 --weir-fst-pop pop84 --out fst83_84
vcftools --vcf ../VCFdata/autosomal_annotated_pruned.recode.vcf --weir-fst-pop pop84 --weir-fst-pop pop85 --out fst84_85
vcftools --vcf ../VCFdata/autosomal_annotated_pruned.recode.vcf --weir-fst-pop pop85 --weir-fst-pop pop86 --out fst85_86
vcftools --vcf ../VCFdata/autosomal_annotated_pruned.recode.vcf --weir-fst-pop pop86 --weir-fst-pop pop87 --out fst86_87
vcftools --vcf ../VCFdata/autosomal_annotated_pruned.recode.vcf --weir-fst-pop pops69_82 --weir-fst-pop pops89_102 --out fst_ann_rock
vcftools --vcf ../VCFdata/autosomal_annotated_pruned.recode.vcf --weir-fst-pop pops69_82 --weir-fst-pop pops83_87 --out fst_ann_cz
vcftools --vcf ../VCFdata/autosomal_annotated_pruned.recode.vcf --weir-fst-pop pops89_102 --weir-fst-pop pops83_87 --out fst_rock_cz

awk '{if ($3 < 0) $3=0; print}' fst83_84.weir.fst > tmp && mv tmp fst83_84.weir.fst
awk '{if ($3 < 0) $3=0; print}' fst84_85.weir.fst > tmp && mv tmp fst84_85.weir.fst
awk '{if ($3 < 0) $3=0; print}' fst85_86.weir.fst > tmp && mv tmp fst85_86.weir.fst
awk '{if ($3 < 0) $3=0; print}' fst86_87.weir.fst > tmp && mv tmp fst86_87.weir.fst
awk '{if ($3 < 0) $3=0; print}' fst_ann_rock.weir.fst > tmp && mv tmp fst_ann_rock.weir.fst
awk '{if ($3 < 0) $3=0; print}' fst_ann_cz.weir.fst > tmp && mv tmp fst_ann_cz.weir.fst
awk '{if ($3 < 0) $3=0; print}' fst_rock_cz.weir.fst > tmp && mv tmp fst_rock_cz.weir.fst

awk '!/-nan/'  fst83_84.weir.fst > tmp && mv tmp fst83_84.weir.fst
awk '!/-nan/'  fst84_85.weir.fst > tmp && mv tmp fst84_85.weir.fst
awk '!/-nan/'  fst85_86.weir.fst > tmp && mv tmp fst85_86.weir.fst
awk '!/-nan/'  fst86_87.weir.fst > tmp && mv tmp fst86_87.weir.fst
awk '!/-nan/'  fst_ann_rock.weir.fst > tmp && mv tmp fst_ann_rock.weir.fst
awk '!/-nan/'  fst_ann_cz.weir.fst > tmp && mv tmp fst_ann_cz.weir.fst
awk '!/-nan/'  fst_rock_cz.weir.fst > tmp && mv tmp fst_rock_cz.weir.fst


awk '{sum += $3; count++} END {if (count > 0) print sum / count}' fst83_84.weir.fst
awk '{sum += $3; count++} END {if (count > 0) print sum / count}' fst84_85.weir.fst
awk '{sum += $3; count++} END {if (count > 0) print sum / count}' fst85_86.weir.fst
awk '{sum += $3; count++} END {if (count > 0) print sum / count}' fst86_87.weir.fst
awk '{sum += $3; count++} END {if (count > 0) print sum / count}' fst_ann_rock.weir.fst
awk '{sum += $3; count++} END {if (count > 0) print sum / count}' fst_ann_cz.weir.fst
awk '{sum += $3; count++} END {if (count > 0) print sum / count}' fst_rock_cz.weir.fst
