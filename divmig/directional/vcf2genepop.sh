#!/bin/bash

numsnps=""
VCF=""

if [ "$1" == "--vcf" ] && [ -n "$2" ]; then
  VCF="$2"  # Assign the second argument (file path) to the VCF variable
  echo "Converting File $VCF to GENEPOP Format"
else
  echo "No Input File Detected. Use Flag --vcf to Specify Path to VCF File"
  exit 1
fi



echo "Extracting Genotype Matrix from VCF File"

vcftools --gzvcf $VCF --012 --out gtmat > /dev/null 2>&1

cut -f2- gtmat.012 > gtmat.noindx

rm gtmat.012
mv gtmat.noindx gtmat.012


sed -e 's/-1/000000/g' \
    -e 's/\b0\b/100100/g' \
    -e 's/\b1\b/100200/g' \
    -e 's/\b2\b/200200/g' gtmat.012 > tmp && mv tmp gtmat.012

awk '{print $1 "."  $2}' gtmat.012.pos > locinames

numsnps=$(awk 'END { print NR }' locinames)

echo "Creating GENEPOP Header"

awk '{printf "%s,\t", $0} END {print ""}' locinames > genepopheader

echo "Creating Population Genotype Tables"

awk '{print $2}' popmap | sort | uniq > pops


n=$(awk 'END{print NR}' pops)
for i in $(seq 1 $n); do

    popnow=$(sed -n "${i}p" pops)

    echo "Processing Population" $i

    awk -v p="$popnow" '$2 == p {print $1}' popmap > "pop_${i}";
    
    > "popindxs${i}"
    
    indx=1
    while IFS= read -r sample; do
        if grep -Fxq "$sample" "pop_${i}"; then
            echo "$indx" >> "popindxs${i}"
        fi
        ((indx++))
    done < gtmat.012.indv

	awk 'NR==FNR {indices[$1]; next} FNR in indices' "popindxs${i}" gtmat.012 > "gtmatpop${i}"

done

echo "Assembling GENEPOP File"


# Paste pop number names on left, tab, commma, then gt matrix on right for each pop

sed -i 's/$/ ,/' pop_*

for i in $(seq 1 "$(wc -l < pops)"); do
    paste  "pop_${i}" "gtmatpop${i}" > "bodypop_${i}"
done

> GENEPOPbody


for i in $(seq 1 "$(wc -l < pops)"); do
	echo "Pop" >> GENEPOPbody
	cat "bodypop_${i}" >> GENEPOPbody
done


echo "GENEPOP" > tmp


cat genepopheader GENEPOPbody >> tmp

mv tmp GENEPOP

rm locinames
rm body*
rm GENEPOPbody
rm genepopheader
rm pop_*
rm popi*
rm gt*

echo "Done!"
echo "# SNPs = " $numsnps


numsnps=""
VCF=""
