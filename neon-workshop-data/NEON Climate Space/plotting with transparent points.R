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
#make the plot

#if you want to print to a postscript file uncomment the next two lines and the dev.off() line at the bottom.
#psfile <- paste("/Users/aelmore/Documents/a soilN15/climatespace.ps",sep="")
#postscript(psfile,horizontal=FALSE,bg="white",width=7,height=7,pointsize=12)



par(mfrow = c(1,1),cex=1.7,lwd=1.5,mai=c(1.45,1.48,.18,.25)) 


#These next two lines are the meat of the color density feature
newcols <- densCols(climate$temp,(climate$precip)*10,colramp=colorRampPalette(brewer.pal(9,"Greys")[-(1:3)]))
plot(climate$temp,(climate$precip)*10,pch=16,xlab=expression(paste(plain("MAT (")*degree,"C)")),ylab="MAP(mm)",
     axes=FALSE,cex=.3,col=newcols)

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

lc = read.csv("./NEON_Climate_Land_Cover_Types_Updated.csv")


points(lc$mean_temp,(lc$mean_precip),
       pch=19,cex=.5 + log(lc$Minimally_Managed+1)/1.5,col=rgb(red=45, green=31, blue=255, alpha=20, maxColorValue=255))
#points(lc$mean_temp[lc$Minimally_Managed < 0.5],lc$mean_precip[lc$Minimally_Managed < 0.5],
       #pch=1,cex=.5, col = "green")

legend(-18, 3800, legend=c("All Developed > 0.5"),
       col=c("orange"), pch=1, cex=0.5, text.font=2)


points(lc$mean_temp,(lc$mean_precip),
       pch=1,cex=.5 + log(lc$all_developed+1)/1.5, col=rgb(red=239, green=29, blue=42, alpha=100, maxColorValue=255))
       
       col = "red")
#points(lc$mean_temp[lc$all_developed < 2],lc$mean_precip[lc$all_developed < 2],
       #pch=1,cex=.5, col = "green")

legend(-18, 3800, legend=c("All Developed > 0.5", "All Developed < 0.5"),
       col=c("red", "green"), pch=1, cex=0.5, text.font=2)


points(lc$mean_temp,(lc$mean_precip),
       pch=1,cex=.01 + log(lc$Agriculture+1)/1.5,col=rgb(red=71, green=239, blue=82, alpha=100, maxColorValue=255))
#points(lc$mean_temp[lc$Agriculture < 0.5],lc$mean_precip[lc$Agriculture < 0.5],
       #pch=1,cex=.01, col = "green")

blue = rgb(red=45, green=31, blue=255, alpha=20, maxColorValue=255)
red = rgb(red=239, green=29, blue=42, alpha=100, maxColorValue=255)
green = rgb(red=71, green=239, blue=82, alpha=100, maxColorValue=255)


