for K in 2 3 4 5 6;
        do
                admixture -s 333 -j6 --cv ../Cyanocitta_LDPruned_Autosomal_nomeso.ped $K | tee log${K}.out;
        done
