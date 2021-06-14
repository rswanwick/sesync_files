install.packages("devtools")
devtools::install_github("ropensci/FedData")

library(tigris)
library(tidycensus) #need to generate your own Census API key
library(sf)
library(tidyverse)
library(devtools)
library(FedData) #NLCD Data 
# NLCD data for NEON AOP footprints

data_dir <- "/nfs/public-data/NEON_workshop_data/NEON" 
NEONgeoids <-  readr::read_csv(file.path(data_dir, "NEON-AOP-CensusGEOIDs.csv"), col_types = "cccccccc")

## Prepping the population data
#Download the census block data - tidycensus has an option for geometry = true, but that can fail in some geographies

#loading the variable types for the 5 year estimates of ACS 
#v17 <- load_variables(2016, "acs5", cache = TRUE)

Test_ACS = get_acs(geography = "block group", variables = "B01003_001", state = "NH", county = "003", geometry = TRUE )


#Creating Census API Key and loading that key into the code 
## Not run: 
 census_api_key("9445a72c7c9ebc64c409d140ce678927c9a25937", install = TRUE)
# First time, reload your environment so you can use the key without restarting R.
readRenviron("~/.Renviron")
# You can check it with:
Sys.getenv("CENSUS_API_KEY")


#Load nlcd data to ensure that you have the right resolutions and projections in the data below

NLCD = get_nlcd(Test_ACS, label = "TestNLCD", year = 2016, dataset = "Impervious")


#Convert into block group raster (probably use fasterize)

##
