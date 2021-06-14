#install.packages("mapplots")

require("RColorBrewer")
library(sf)
library(sp)
library(ggplot2)
library(tidyverse)
library(mapplots)

setwd("/research-home/rswanwick/neon-workshop-data/")

values = read.csv("./NEON_Climate_Land_Cover_Types_Updated.csv")

values$mean_precip <- NULL 

values$mean_temp <- NULL

values$X <- NULL

data = read.csv("/research-home/rswanwick/neon-workshop-data/NEON site_centroids 2.csv")
good.rows = which(!is.na(as.numeric(data$X)))
lat = as.numeric(data$Y[good.rows])
lon = as.numeric(data$X[good.rows])

data = data[1:72, ]

data$sitename = substr(data$sitename, 1,8)

#rename the column to match with the values table 
names(data)[names(data) == "sitename"] <- "site"

data1 <- cbind.data.frame(data$X, data$Y, data$site)

names(data1) <- c("X","Y","site")

data2 = data1[!duplicated(data1$site), ]

data3 = merge(data2,values,by=c("site"))

write.csv(data3, "/nfs/public-data/NEON_workshop_data/NEON/NEON_Site_NLCD_XY.csv")