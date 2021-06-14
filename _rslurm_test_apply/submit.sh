#!/bin/bash
#
#SBATCH --array=0-9
#SBATCH --cpus-per-task=1
#SBATCH --job-name=test_apply
#SBATCH --output=slurm_%a.out
#SBATCH --time=1:00:00
#SBATCH --partition=sesyncshared
/usr/lib/R/bin/Rscript --vanilla slurm_run.R
