for K in 2 3 4 5 6;
        do
                admixture -s 222 -j3 --cv ../Cyanocitta_LDPruned_Autosomal_nomeso.ped $K | tee log${K}.out;
        done
