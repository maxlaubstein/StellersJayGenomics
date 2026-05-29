#!/bin/bash

vcf="$1"

out="$2"

plink --vcf "$vcf"  --double-id --allow-extra-chr --allow-no-sex --set-missing-var-ids @:#  --make-bed  --out "$out"

plink --bfile "$out" --double-id --allow-extra-chr --allow-no-sex --recode 12 --out "$out"
