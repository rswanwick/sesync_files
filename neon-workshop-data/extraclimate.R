library(raster)
library(rgdal)
library(foreign)
library(openxlsx)
library(dplyr)


setwd("/research-home/rswanwick/neon-workshop-data/") 
      
#/nfs/public-data/NEON_workshop_data/NEON"
  
#"/Volumes/GoogleDrive/Shared drives/Research Coordination Network Proposal /Climate_landcover_figure/climatedata/Global")

"/nfs/public-data/NEON_workshop_data/NEON"

precip = readGDAL("/research-home/rswanwick/neon-workshop-data/aveprecip.tif")
precip0 = raster(precip)

temp = readGDAL("/research-home/rswanwick/neon-workshop-data/avetemp.tif")
temp0 = raster(temp)

precip = precip0
temp = temp0

precip[precip0 == 0 & temp0 == 0] <- NA
temp[precip0 == 0 & temp0 == 0] = NA

#input the neon csv file for centroids showing the site name, long, lat 
data = read.csv("/research-home/rswanwick/neon-workshop-data/NEON Centroids.csv")
good.rows = which(!is.na(as.numeric(data$X)))
lat = as.numeric(data$Y[good.rows])
lon = as.numeric(data$X[good.rows])



#plot(temp)
#points(lon,lat,pch = 16, cex = .2)

xy = cbind(lon,lat)
p = extract(precip,xy)
t = extract(temp,xy)

data$MAP_new = NA
data$MAT_new = NA 

#Don't forget to multiply precip by 10 to convert between centemeters and millimeters
data$MAP_new[good.rows] = p*10
data$MAT_new[good.rows] = t

#only run if having issues with sites that are near the coast 
xy.coastal = xy[is.na(t),]
#w = which(xy.coastal[,1] == 84)
#xy.coastal[w,1] = -84.0
pc = seq(dim(xy.coastal)[1])*0
tc = seq(dim(xy.coastal)[1])*0

p2 = extract(precip,xy.coastal, buffer = 50000)
t2 = extract(temp,xy.coastal, buffer = 50000)
for(i in seq(length(p2))){
  gd = !is.na(p2[[i]])
  pc[i] = median(p2[[i]][gd])
  
  gd = !is.na(t2[[i]])
  tc[i] = median(t2[[i]][gd])
}

doit = which(is.na(t))
data$MAP_new[good.rows][doit] = pc*10
data$MAT_new[good.rows][doit] = tc

#reducing the rows to 70 rows rather than having all NAs 
data = data[1:70, ]

#creating site name with only needed characters 
data$site = substr(data$sitename, 1,11)

#Group data by site and summarize the mean precipitation and temperature 
data_1 = data %>%
  group_by(site) %>%
  summarize(mean_precip = mean(MAP_new, na.rm = TRUE))

data_2 = data %>%
  group_by(site) %>%
  summarize(mean_temp = mean(MAT_new, na.rm = TRUE))

Mean_NEON <- merge(data_1,data_2,by=c("site"))

# creating a scatter plot for data 
Mean_Precipitation = Mean_NEON$mean_precip # the mean precip 
Mean_Temperature = Mean_NEON$mean_temp # the mean temp 
head(cbind(Mean_Precipitation, Mean_Temperature))

Mean_Precipitation = Mean_NEON$mean_precip # the mean precip 
Mean_Temperature = Mean_NEON$mean_temp # the mean temp 
plot(Mean_Temperature, Mean_Precipitation, main="Mean NEON Site Climate Space", #plot the variables and name the plot 
     xlab = "Temperature",        # x−axis label 
     ylab = "Precipitation")              # y−axis label


# other way to creating a scatter plot for data 
#attach(Mean_NEON)
#plot(mean_precip, mean_temp, col=c("red", "blue"), main="Mean NEON Site Climate Space",
#xlab="Precip ", ylab="Temp", pch=19)
  
#creating excel sheet for data output 
write.xlsx(data,"Outputclimatedata.xlsx")
write.xlsx(Mean_NEON, "Meanoutputforclimatedata.xlsx")
write.csv(Mean_NEON, "MeanNEONData.csv")
