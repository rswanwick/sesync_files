#Must run this once after each new installation of R

if(0){
  if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
  BiocManager::install(version = "3.10")
}

#I don't think next three lines are necessary any more
#source("http://bioconductor.org/biocLite.R")
#biocLite("geneplotter")
#library(geneplotter)


require("RColorBrewer")
library(sf)
library(sp)

#change this next line if you move this R script
setwd("/research-home/rswanwick/neon-workshop-data/")

#change the if(0) to if(1) if you want to rerun the intersection of the global climate data with the shapefile of the US states.
#it takes a while to run on a laptop.
if(0){
  climate <- read.csv("./equalarea_wlandcoverclass.csv",header=TRUE)
  good.rows = which(!is.na(as.numeric(climate$lat)))
  lat = as.numeric(climate$lat[good.rows])
  lon = as.numeric(climate$lon[good.rows])
  xy = cbind(lon,lat)
  
  
  statesfile = "./cb_2014_us_state_500k/cb_2014_us_state_500k.shp"
  states <- st_read(statesfile)
  plot(states["STATEFP"],add = TRUE)
  
  #I know this is not the way to do it but I couldn't find an sf function to do it
  xy.spdf = SpatialPointsDataFrame(xy,climate)
  plot(xy.spdf)
  xy.sf = as(xy.spdf,"sf")
  st_crs(xy.sf) <- st_crs(states)
  o = st_intersection(xy.sf,states)
  st_write(o,"./USA_equalarea_wlandcoverclass.csv")
  st_write(o,"./USA_equalarea_wlandcoverclass.shp")
}
#read in just the USA climate data
usaclimate = st_read("./USA_equalarea_wlandcoverclass.shp")

climate = usaclimate

#call the pdf command to start the plot 
pdf(file = "/nfs/public-data/NEON_workshop_data/NEON/NEONClimateSpace.pdf",   # The directory you want to save the file in
    width = 7, # The width of the plot in inches
    height = 7) # The height of the plot in inches

#make the plot

#if you want to print to a postscript file uncomment the next two lines and the dev.off() line at the bottom.
#psfile <- paste("/Users/aelmore/Documents/a soilN15/climatespace.ps",sep="")
#postscript(psfile,horizontal=FALSE,bg="white",width=7,height=7,pointsize=12)

par(mfrow = c(1,1),cex=1.0, lwd=1, mai=c(.8,.8,.18,.15), mgp=c(2,.7,0))

#par(mfrow = c(1,1),cex=0.1, lwd=1, mai=c(1.45,1.48,.05,.25))

#These next two lines are the meat of the color density feature

#newcols was being used to show the density of climate space but was removed for simplicity 
#newcols = densCols(climate$temp,(climate$precip)*10,colramp=colorRampPalette(brewer.pal(9,"Greys")[-(1:3)]))
plot(climate$temp,(climate$precip)*10,pch=16,xlab=expression(paste(plain("Mean Annual Temperature (")*degree,"C)")),ylab="Mean Annual Precipitation (mm)",
     axes=FALSE,cex=.5,col="grey")

#finish the plot by drawing the axis labels
axis(2,at=c(500,1000,1500,2500,3000,3500,4500,5000,5500,6500,7000,7500),labels=FALSE,tck=-.01)
axis(2,at=c(0,2000,4000,6000,8000))
axis(1)
axis(1,at=c(-25,-15,-5,5,15,25),labels=FALSE,tck=-.01)

box()

#neon = read.csv("MeanNEONData.csv")
#points(neon$mean_temp,neon$mean_precip,col = "red",pch = 16)

#Add different colors and larger dots for any state
#View(unique(climate$STUSPS))
if(0){
  statetoplot = "WA"
  rcols = rainbow(20)
  points(climate$temp[climate$STUSPS == statetoplot],(climate$precip[climate$STUSPS == statetoplot])*10,
         pch=16,cex=.7,col = sample(rcols,1)) #col=climate$STATEFP[climate$STUSPS == statetoplot]
}

#"../NEON /NEON_Climate_Land_Cover_Types_Updated.csv"
#dev.off()
#####

#reading in the csv files that contain data for the land use type, climate space and long/lat for
#each site and merging 
data = read.csv("/nfs/public-data/NEON_workshop_data/NEON/NEON_Site_NLCD_XY.csv")

data2 = subset(data, select = -c(all_developed , Agriculture, Minimally_Managed))

lc = read.csv("./NEON_Climate_Land_Cover_Types_Updated.csv")

data3 = merge(data2,lc,by=c("site"))

#if you want to see how large each of the circles are for the scale bar--use this to isolate and 
#plot one row at a time 
#data4 = lc[1, ]


#plotting point for all developed 
points(lc$mean_temp,(lc$mean_precip),
       pch=19,cex=2.5 + log(lc$all_developed+1),
       col = rgb(red=223, green=57, blue=47,alpha=120, maxColorValue=255))

#plotting point for agriculture 
points(lc$mean_temp,(lc$mean_precip),
       pch=19,cex=2.5 + log(lc$Agriculture+1),
       col = rgb(red=46, green=84, blue=239,alpha=60, maxColorValue=255))

#col = rgb(red=244, green=22, blue=27,alpha=100, maxColorValue=255))

#plotting point for all developed 
points(lc$mean_temp,(lc$mean_precip),
       pch=19,cex=2.5 + log(lc$all_developed+1),
       col = rgb(red=223, green=57, blue=47,alpha=65, maxColorValue=255))



#plotting point for agriculture 
points(lc$mean_temp,(lc$mean_precip),
       pch=19,cex=2.5 + log(lc$Agriculture+1),
       col = rgb(red=46, green=84, blue=239,alpha=65, maxColorValue=255))
       
       #col = rgb(red=244, green=22, blue=27,alpha=100, maxColorValue=255))

#plotting point for all developed 
points(lc$mean_temp,(lc$mean_precip),
       pch=19,cex=2.5 + log(lc$all_developed+1),
       col = rgb(red=223, green=57, blue=47,alpha=120, maxColorValue=255))
        

       #col = rgb(red=4, green=51, blue=255,alpha=70, maxColorValue=255))
     
#plotting point for each site 
points(data3$mean_temp,(data3$mean_precip),
       pch=19,cex=.5 + log(data3$Y+1)/70,
       col = "green")

dev.off()

#no longer using-this was for old parts of the code 
#plotting point for agriculture 
points(lc$mean_temp,(lc$mean_precip),
       pch=19,cex=.5 + log(lc$Agriculture+1)/1.5,
       col = rgb(red=58, green=193, blue=254, alpha=100, maxColorValue=255))

#plotting point for all developed 
points(lc$mean_temp,(lc$mean_precip),
       pch=19,cex=.5 + log(lc$all_developed+1)/1.3,
       col = rgb(red=41, green=28, blue=254, alpha=60, maxColorValue=255))

#plotting point for each site 
points(data3$mean_temp,(data3$mean_precip),
       pch=19,cex=.1 + log(data3$Y+1)/70,
       col = "black")


#not currently using anything below here 

#legend(-18, 3800, legend=c("All Developed > 0.5", "All Developed < 0.5"),
       #col=c("red", "green"), pch=1, cex=0.5, text.font=2)



