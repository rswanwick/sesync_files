devtools::install_github("ropensci/FedData")

#install.packages("fasterize")

library(tidycensus)
census_api_key("9445a72c7c9ebc64c409d140ce678927c9a25937")
library(FedData) #has to be dev version or won't dl 2016 data
library(tidyverse)
library(raster)
library(sf)
library(dplyr)
library(glue)
library(fasterize)
v16 <- load_variables(2016, "acs5", cache = TRUE)
v10 <- load_variables(2010, "sf1", cache = TRUE)
#set the id's for the county we want

#setwd("/nfs/rswanwick-data/DASY/1datadownload")

stid <- "24" #this is maryland; you can use fips_codes[fips_codes$state=="MD",] to list state and county codesjust change MD
ctyid <- "001"


#downoload block-group population for 2016 double check to make sure this is the correct ACS data
pop <- get_acs(geography = "block group", , variables = "B00001_001", 
               year = 2016, state= stid, county = ctyid, 
               geometry = TRUE)   


#download land use data NEED TO MAKE SURE WE DON"T HAVE TO HAVE PROJECTIONS MATCHING BEFOREHAND
lu <- get_nlcd(template = pop, label = paste0(stid, ctyid),year = 2016, dataset = "Impervious")

#download 2010 block-level data, filter for only the blocks with 0 pop
zero.pop <- get_decennial(geography = "block", variables = "P001001", 
                          year = 2010, state = stid, county = ctyid, 
                          geometry = TRUE) %>% filter(value == 0) %>% st_transform(., proj4string(lu))

save(pop, lu, zero.pop, file=glue("/nfs/rswanwick-data/DASY/datadownload/data_neon{stid}-{ctyid}.rdata"))


#next steps would be to write this as a function so it will run through all the county and state ids and then
#run the rest of the code through slurm 


#for the second half of the function you would use load(glue(/nsf/rswanwick-data....))