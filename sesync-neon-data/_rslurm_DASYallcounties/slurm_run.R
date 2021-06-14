library(tidycensus, quietly = TRUE)
library(raster, quietly = TRUE)
library(tidyverse, quietly = TRUE)
library(sf, quietly = TRUE)
library(dplyr, quietly = TRUE)
library(glue, quietly = TRUE)
library(gdalUtils, quietly = TRUE)

load('add_objects.RData')

.rslurm_func <- readRDS('f.RDS')
.rslurm_x <- readRDS('x.RDS')
.rslurm_more_args <- readRDS('more_args.RDS')
.rslurm_id <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))
.rslurm_istart <- .rslurm_id * 8 + 1
.rslurm_iend <- min((.rslurm_id + 1) * 8, length(.rslurm_x))
.rslurm_result <- do.call(parallel::mclapply, c(list(
    X = .rslurm_x[.rslurm_istart:.rslurm_iend],
    FUN = .rslurm_func),
    .rslurm_more_args,
    mc.cores = 8,
    mc.preschedule = TRUE
    ))

saveRDS(.rslurm_result, file = paste0('results_', .rslurm_id, '.RDS'))
