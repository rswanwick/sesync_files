install.packages("tidycensus")
install.packages("fasterize")
install.packages("raster")
install.packages("downloader")

library(rgdal)
library(sf)

library(downloader)
library(tidycensus)
census_api_key("90b94953d2f24e81e890229e0128174f5ba80d3f", install = TRUE)
library(FedData)
library(tidyverse)
library(raster)
#checking codes for the census data types 
#v16 <- load_variables(2016, "acs5", cache = TRUE)
#v10 <- load_variables(2010, "sf1", cache = TRUE)
#set the id's for the county we want

#sets the temp directory into the user directory 
rasterOptions(tmpdir = "/research-home/rswanwick/rastertemp/")

stid <- 24 #this is maryland; you can use fips_codes[fips_codes$state=="MD",] to list state and county codesjust change MD
ctyid <- 001
#ctyid this is the city id? 

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


pop.projected <- st_transform(pop, crs = proj4string(lu))
##crop lu to county
lu.crop <- crop(lu, pop.projected)
lu.mask <- mask(lu.crop, pop.projected)
#Remove NLCD data <=1%
lu.mask[lu.mask <= 1] <- NA

#create lu ratio
lu.ratio <- lu.mask/100

#mask out zero pop blocks
lu.ratio.zp <- mask(lu.ratio, as(zero.pop, "Spatial"), inverse=TRUE)

#get the impervious surface descriptor dataset from: https://www.mrlc.gov/data?f%5B0%5D=category%3ALand%20Cover&f%5B1%5D=category%3AUrban%20Imperviousness&f%5B2%5D=year%3A2016
#Ideally we'll figure out a way to download this once, bring it in, and crop to the appropriate geometry

#download data for impervious descriptor layer 
url <- "https://s3-us-west-2.amazonaws.com/mrlc/NLCD_2016_Impervious_descriptor_L48_20190405.zip"

download(url, dest="dataset.zip", mode="wb")
unzip ("dataset.zip", exdir = "./")


#mask out primary, secondary, and urban tertiary roads
imp.surf.desc <- raster("/research-home/rswanwick/NLCD_2016_Impervious_descriptor_L48_20190405.img") 
imp.surf.crop <- raster::crop(imp.surf.desc, spTransform(as(pop.projected, "Spatial"), CRSobj = proj4string(imp.surf.desc))) #crop imp surface to county
#plot(imp.surf.crop)
imp.surf.mask <- raster::mask(imp.surf.crop, spTransform(as(pop.projected, "Spatial"), CRSobj = proj4string(imp.surf.desc))) #mask all non-county values to NA
#get codes to mask out
z <- deratify(imp.surf.mask)[[5]] #need to get the actual values
reclass.table <- matrix(c(1,6,NA,7,14,1), ncol=3) #reclassify values 1-6 into 1 for keep drop the rest, anything from 7-14 gets NA

#taking impervious surface area and masking census population without data--anywhere where roads data is na-we are not showing on the plot 
imp.roads <- reclassify(z, reclass.table)
imp.roads.p <- projectRaster(imp.roads, lu.ratio.zp)#have to reproject the descriptor file
#Mask oout roads (i.e, all NonNA values in imp.roadss.p)
RISA <- overlay(lu.ratio.zp, imp.roads.p, fun = function(x, y) {
  x[is.na(y[])] <- NA
  return(x)
})

#plot(RISA)

#get the block-group level sum of the remaining impervious surface pixels
RISA.sum <- raster::extract(RISA, as(pop.projected,"Spatial"), fun=sum, na.rm=TRUE,df=TRUE)

#total population within each block group 
pop.df <- cbind(pop.projected, RISA.sum$layer)
bg.sum.pop <- fasterize::fasterize(pop.projected, RISA, field = "estimate")
bg.sum.RISA <- fasterize::fasterize(pop.df, RISA, field = "RISA.sum.layer")

#generate density (people/30 m pixel)
dasy.pop <- (bg.sum.pop/bg.sum.RISA) * RISA

#test to make sure that the summarized raster is roughtly equivalent to the original estimates
tst <- raster::extract(dasy.pop, as(pop.projected,"Spatial"), fun=sum, na.rm=TRUE,df=TRUE)
#difference between the sum of the tst extraction and block values should be 0 
diffs <- pop.projected$estimate - tst$layer ##Values should be zero (or very, very small)

#summary(diffs)

##TODO: Convert to a function that will allow us to feed lists of states and counties
##TODO: Figure out a way to avoid downloading and reloading the impervious surface descriptor file 
##TODO: Profile for unnecessary slow-downs
##TODO: Figure out how to make sure that errors get thrown if a county is missing some data
##TODO: Compare to Steven's results
