for file in log*.out; do
    line=$(grep "CV error" "$file")
    k_val=$(echo "$line" | grep -oP 'K=\K\d+')
    cv_val=$(echo "$line" | awk -F": " '{print $2}')
    echo -e "$k_val\t$cv_val"
done | sort -n > cverrors.seed3
