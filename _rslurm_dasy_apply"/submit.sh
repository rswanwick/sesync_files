#!/bin/bash
#
#SBATCH --array=0-5
#SBATCH --cpus-per-task=1
#SBATCH --job-name=DASY_apply
#SBATCH --output=slurm_%a.out
/usr/lib/R/bin/Rscript --vanilla slurm_run.R
