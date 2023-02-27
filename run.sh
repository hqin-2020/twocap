#! /bin/bash

Deltaarray=(1000)
# fractionarray=(0.1 0.05 0.01 0.005 0.001 0.0005 0.0001)
fractionarray=(0.0005)

actiontime=1

julia_name="newsets_twocapitals_modif.jl"

rhoarray=(1.00001)

gammaarray=(8.0)


for Delta in ${Deltaarray[@]}; do
    for fraction in "${fractionarray[@]}"; do
        for rho in "${rhoarray[@]}"; do
            for gamma in "${gammaarray[@]}"; do
                    count=0

                    action_name="TwoCapital_julia"

                    dataname="${action_name}_${Delta}_frac_${fraction}"

                    mkdir -p ./job-outs/${action_name}/Delta_${Delta}_frac_${fraction}/

                    if [ -f ./bash/${action_name}/Delta_${Delta}_frac_${fraction}/rho_${rho}_gamma_${gamma}.sh ]; then
                        rm ./bash/${action_name}/Delta_${Delta}_frac_${fraction}/rho_${rho}_gamma_${gamma}.sh
                    fi

                    mkdir -p ./bash/${action_name}/Delta_${Delta}_frac_${fraction}/

                    touch ./bash/${action_name}/Delta_${Delta}_frac_${fraction}/rho_${rho}_gamma_${gamma}.sh

                    tee -a ./bash/${action_name}/Delta_${Delta}_frac_${fraction}/rho_${rho}_gamma_${gamma}.sh <<EOF
#!/bin/bash

#SBATCH --account=pi-lhansen
#SBATCH --job-name=${Delta}_${fraction}
#SBATCH --output=./job-outs/$job_name/${action_name}/Delta_${Delta}_frac_${fraction}/rho_${rho}_gamma_${gamma}.out
#SBATCH --error=./job-outs/$job_name/${action_name}/Delta_${Delta}_frac_${fraction}/rho_${rho}_gamma_${gamma}.err
#SBATCH --time=0-12:00:00
#SBATCH --partition=caslake
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G

module load julia/1.7.3
srun julia /home/hqin/twist/$julia_name  --Delta ${Delta} --fraction ${fraction} --gamma ${gamma} --rho ${rho} --dataname ${dataname}
EOF
                count=$(($count + 1))
                sbatch ./bash/${action_name}/Delta_${Delta}_frac_${fraction}/rho_${rho}_gamma_${gamma}.sh
            done
        done
    done
done