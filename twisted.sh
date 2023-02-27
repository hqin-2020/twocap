#! /bin/bash

for symmetric_returns in 1
do
    for state_dependent_xi in 0
    do
        for optimize_over_ell in 0
        do  
            for ell_ex in 0.14285714285714285 
            do
                for alpha_z_tilde_ex in 0.0
                do
                    job_name=symmetric_returns_${symmetric_returns}_state_dependent_xi_${state_dependent_xi}_optimize_over_ell_${optimize_over_ell}_ell_ex_${ell_ex}_alpha_z_tilde_ex_${alpha_z_tilde_ex}
                    mkdir -p ./job-outs/$job_name
                    mkdir -p ./bash/$job_name
                    mkdir -p ./output
                    touch ./bash/$job_name/run.sh
                    tee ./bash/$job_name/run.sh << EOF
#!/bin/bash

#SBATCH --account=pi-lhansen
#SBATCH --job-name=run
#SBATCH --output=./job-outs/$job_name/run.out
#SBATCH --error=./job-outs/$job_name/run.err
#SBATCH --time=0-12:00:00
#SBATCH --partition=caslake
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G

module load julia/1.7.3
srun julia newsets_twocapitals.jl  --symmetric_returns ${symmetric_returns} --state_dependent_xi ${state_dependent_xi} --optimize_over_ell ${optimize_over_ell} --ell_ex ${ell_ex} --alpha_z_tilde_ex ${alpha_z_tilde_ex}

EOF
                    sbatch ./bash/$job_name/run.sh
                done
            done
        done
    done
done