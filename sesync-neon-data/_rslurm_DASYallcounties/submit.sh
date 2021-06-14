#!/bin/bash
#
#SBATCH --array=0-0
#SBATCH --cpus-per-task=8
#SBATCH --job-name=DASYallcounties
#SBATCH --output=slurm_%a.out
/usr/lib/R/bin/Rscript --vanilla slurm_run.R
