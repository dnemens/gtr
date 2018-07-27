library(rgdal)
library(rgeos)
library(raster)
library(tidyverse)
library(DescTools)

setwd("C:/Users/dnemens/Dropbox/salvage")

### read in shapefiles ###
can <- shapefile("~/shapefiles/CAN_Provinces/PROVINCE.SHP")
usa <- shapefile("~/shapefiles/US_States/states.shp")

### join and discard irrelevant stuff ###
northam <- union(usa, can) %>% .[1:64,]

### merge state and province names ###
northam$NAME <- coalesce(northam$STATE_NAME, northam$NAME)
### fix name ###
northam$NAME[52] <- "Newfoundland and Labrador"

### save shapefile ###
# shapefile(northam, filename = 'C:/Users/dnemens/Dropbox/salvage/shapefiles/States and Provinces.shp')

### read in fire data ###
dat <- read.csv("C:/Users/dnemens/Dropbox/salvage/studies2.csv", stringsAsFactors = F)
### fix names ###
dat$NAME_1[6] <- "Quebec"
dat$NAME_1[11] <- "Yukon Territory"
datsub <- dat[1:10,]

### merge spatial data with fire counts ###
test <- merge(northam, dat, by.x = "NAME", by.y = "NAME_1", duplicateGeoms = T)

### geographic extent of object ###
extent(test)

### make color ramp ###
cols <- c(colorRampPalette(c("steelblue1", "steelblue4"))(16))

### set color palette ###
palette(cols)     

### save pdf ###
pdf(file="studies_map.pdf", width = 5, height = 4)

#make map
par(mar = c(.5, .5, .5, .5))
plot(test, col = test$studies, xlim = c(-135, -90), ylim = c(35, 55), border = "white")
tsub <- test[test$studies == 0, ]
plot(tsub, col = "grey70", border = "white", add = T)
gold_t <- adjustcolor("gold", alpha.f = .8)
symbols(datsub$long, datsub$lat, circles=c(1,1,1,1,1,9,1,1,1,1), bg=gold_t, add=TRUE, fg=NA)
text (datsub$long, datsub$lat, labels=c(16,7,7,5,5,2,1,1,1,1), col="grey40", font=2, cex=.6)
box()
dev.off()
