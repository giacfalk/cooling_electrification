# Calculate current CDDs

img <- list.files(pattern='\\.tif$', path = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/wc2.1_5m_tavg', full.names = T)
avg <- stack(img)

img <- list.files(pattern='\\.tif$', path = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/wc2.1_5m_tmin', full.names = T)
min <- stack(img)

img <- list.files(pattern='\\.tif$', path = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/wc2.1_5m_tmax', full.names = T)
max <- stack(img)

## p = read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/csvs/ponts05global.csv") %>% dplyr::select(id, left, right, bottom, top)
## 
## p$Y = (p$bottom + p$top)/2
## p$X = (p$left + p$right)/2

##st_as_sf(p, coords=c("X", "Y"), crs=4326) %>% write_sf(., "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/ponts05global.shp")

#
sf<-readOGR("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/ponts05global.shp")

#
avg<-raster::extract(avg, sf, fun=mean, na.rm=TRUE)
max<-raster::extract(max, sf, fun=mean, na.rm=TRUE)
min<-raster::extract(min, sf, fun=mean, na.rm=TRUE)
gc()

avg=as.data.frame(avg)
id = sf$id
avg = cbind(avg, id)
avg<-melt(avg,measure.vars=names(avg)[1:length(names(avg))-1], id.vars ="id")
avg$month = as.numeric(sub('.*\\_', '',avg$variable))
avg$variable=NULL
gc()

max=as.data.frame(max)
id = sf$id
max = cbind(max, id)
max<-melt(max,measure.vars=names(max)[1:length(names(max))-1], id.vars ="id")
max$month = as.numeric(sub('.*\\_', '',max$variable))
max$variable=NULL
gc()

min=as.data.frame(min)
id = sf$id
min = cbind(min, id)
min<-melt(min,measure.vars=names(min)[1:length(names(min))-1], id.vars ="id")
min$month = as.numeric(sub('.*\\_', '',min$variable))
min$variable=NULL
gc()

gc()
all = Reduce(function(x,y) merge(x,y,by=c("id", "month")) ,list(avg, max, min))
colnames(all) <- c("id", "month", "avg", "max", "min")

all$CDD = 30 * ifelse(all$max<=base_temp, 0, ifelse( (all$avg<=base_temp) & (base_temp<all$max), (all$max-base_temp)/4, ifelse((all$min<=base_temp) & (base_temp<all$avg), ((all$max-base_temp)/2 - (base_temp-all$min)/4), all$avg-base_temp)))

p = read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/csvs/ponts05global.csv") %>% dplyr::select(id, left, right, bottom, top)

p$Y = (p$bottom + p$top)/2
p$X = (p$left + p$right)/2

all_m = merge(all, p, by="id")

all_m = split(all_m, all$month)

for (i in 1:12){
all_m[[i]] <- data.frame(all_m[[i]]$X, all_m[[i]]$Y, all_m[[i]]$CDD)
}

CDDs <- list()

#convert to raster
for (i in 1:12){
CDDs[i] <- rasterFromXYZ(all_m[[i]], res=c(0.5, 0.5), crs = 4326)
}

CDDs <- stack(CDDs)

setwd('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA')
writeRaster(CDDs, "CDDs_2020_global.tif", overwrite=T)

CDDs <- stack('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/CDDs_2020_global.tif')

ext <- as.vector(extent(CDDs))
boundaries <- map('worldHires', fill=TRUE,
                  xlim=ext[1:2], ylim=ext[3:4],
                  plot=FALSE)
IDs <- sapply(strsplit(boundaries$names, ":"), function(x) x[1])
bPols <- map2SpatialPolygons(boundaries, IDs=IDs,
                             proj4string=CRS(projection(CDDs)))

my.at <- c(15, 30, 60, 120, 240, 480, 960)

myColorkey <- list(at=my.at, ## where the colors change
                   labels=list(
                     at=my.at ## where to print labels
                   ))

names(CDDs) <- month.abb

png("CDD_today.png", width=1600, height=800, res=150)
print(levelplot(CDDs,
                 main="CDDs, base T 26° C, 1970-2000", at=my.at, colorkey=myColorkey,  par.settings = YlOrRdTheme, xlab="Longitude", ylab="Latitude") + layer(sp.polygons(bPols)))
 dev.off()

#calculate future CDDs based on CMIP6

max245<-stack("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/wc2.1_5m_tmax_CNRM-ESM2-1_ssp245_2041-2060.tif")
#
min245<-stack("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/wc2.1_5m_tmin_CNRM-ESM2-1_ssp245_2041-2060.tif")
#
max370<-stack("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/wc2.1_5m_tmax_CNRM-ESM2-1_ssp370_2041-2060.tif")
#
min370<-stack("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/wc2.1_5m_tmin_CNRM-ESM2-1_ssp370_2041-2060.tif")
#
avg370<-stack(lapply(1:12,
function(i){ (max370[[i]]+min370[[i]])/2
}))
#
avg245<-stack(lapply(1:12,
                     function(i){ (max245[[i]]+min245[[i]])/2
                     }))
#
#
sf<-readOGR("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/ponts05global.shp")
#
avg245<-raster::extract(avg245, sf, fun=mean, na.rm=TRUE)
max245<-raster::extract(max245, sf, fun=mean, na.rm=TRUE)
min245<-raster::extract(min245, sf, fun=mean, na.rm=TRUE)
gc()
#
avg370<-raster::extract(avg370, sf, fun=mean, na.rm=TRUE)
max370<-raster::extract(max370, sf, fun=mean, na.rm=TRUE)
min370<-raster::extract(min370, sf, fun=mean, na.rm=TRUE)
gc()
#
avg245=as.data.frame(avg245)
id = sf$id
avg245 = cbind(avg245, id)
avg245<-melt(avg245,measure.vars=names(avg245)[1:length(names(avg245))-1], id.vars ="id")
avg245$month = as.numeric(sub('.*\\.', '',avg245$variable))
avg245$variable=NULL
gc()
#
min245=as.data.frame(min245)
id = sf$id
min245 = cbind(min245, id)
min245<-melt(min245,measure.vars=names(min245)[1:length(names(min245))-1], id.vars ="id")
min245$month = as.numeric(sub('.*\\.', '',min245$variable))
min245$variable=NULL
gc()
#
max245=as.data.frame(max245)
id = sf$id
max245 = cbind(max245, id)
max245<-melt(max245,measure.vars=names(max245)[1:length(names(max245))-1], id.vars ="id")
max245$month = as.numeric(sub('.*\\.', '',max245$variable))
max245$variable=NULL
gc()
#
#
avg370=as.data.frame(avg370)
id = sf$id
avg370 = cbind(avg370, id)
avg370<-melt(avg370,measure.vars=names(avg370)[1:length(names(avg370))-1], id.vars ="id")
avg370$month = as.numeric(sub('.*\\.', '',avg370$variable))
avg370$variable=NULL
gc()
#
min370=as.data.frame(min370)
id = sf$id
min370 = cbind(min370, id)
min370<-melt(min370,measure.vars=names(min370)[1:length(names(min370))-1], id.vars ="id")
min370$month = as.numeric(sub('.*\\.', '',min370$variable))
min370$variable=NULL
gc()
#
max370=as.data.frame(max370)
id = sf$id
max370 = cbind(max370, id)
max370<-melt(max370,measure.vars=names(max370)[1:length(names(max370))-1], id.vars ="id")
max370$month = as.numeric(sub('.*\\.', '',max370$variable))
max370$variable=NULL
gc()
#
#
all_245 = Reduce(function(x,y) merge(x,y,by=c("id", "month")) ,list(avg245, max245, min245))
all_370 = Reduce(function(x,y) merge(x,y,by=c("id", "month")) ,list(avg370, max370, min370))
#
#reshape
colnames(all_245) <- c("id", "month", "avg", "max", "min")
colnames(all_370) <- c("id", "month", "avg", "max", "min")
#
#calculate CDDs

all_245$CDD_245 = 30 * ifelse(all_245$max<=base_temp, 0, ifelse( (all_245$avg<=base_temp) & (base_temp<all_245$max), (all_245$max-base_temp)/4, ifelse((all_245$min<=base_temp) & (base_temp<all_245$avg), ((all_245$max-base_temp)/2 - (base_temp-all_245$min)/4), all_245$avg-base_temp)))
#
all_370$CDD_370 = 30 * ifelse(all_370$max<=base_temp, 0, ifelse( (all_370$avg<=base_temp) & (base_temp<all_370$max), (all_370$max-base_temp)/4, ifelse((all_370$min<=base_temp) & (base_temp<all_370$avg), ((all_370$max-base_temp)/2 - (base_temp-all_370$min)/4), all_370$avg-base_temp)))
#

p = read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/csvs/ponts05global.csv") %>% dplyr::select(id, left, right, bottom, top)
#
p$Y = (p$bottom + p$top)/2
p$X = (p$left + p$right)/2
#
all_m_245 = merge(all_245, p, by="id")
#
all_m_245 = split(all_m_245, all_245$month)
#
for (i in 1:12){
  all_m_245[[i]] <- data.frame(all_m_245[[i]]$X, all_m_245[[i]]$Y, all_m_245[[i]]$CDD_245)
}
#
CDDs_245 <- list()
#convert to raster
for (i in 1:12){
  CDDs_245[i] <- rasterFromXYZ(all_m_245[[i]], res=c(0.5, 0.5), crs = 4326)
}
#
CDDs_245 <- stack(CDDs_245)
#
setwd('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA')
writeRaster(CDDs_245, "CDDs_2040_2060_245_global.tif", overwrite=T)
#
#
#
all_m_370 = merge(all_370, p, by="id")
#
all_m_370 = split(all_m_370, all_370$month)
#
for (i in 1:12){
  all_m_370[[i]] <- data.frame(all_m_370[[i]]$X, all_m_370[[i]]$Y, all_m_370[[i]]$CDD_370)
}
#
CDDs_370 <- list()
#convert to raster
for (i in 1:12){
  CDDs_370[i] <- rasterFromXYZ(all_m_370[[i]], res=c(0.5, 0.5), crs = 4326)
}
#
CDDs_370 <- stack(CDDs_370)
#
setwd('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA')
writeRaster(CDDs_370, "CDDs_2040_2060_370_global.tif", overwrite=T)

CDDs_370 <- stack('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/CDDs_2040_2060_370_global.tif')
CDDs_245 <- stack('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/CDDs_2040_2060_245_global.tif')

#################

#read el. access
# noacc18 <- raster('C:/Users/GIACOMO/Google Drive/pop_noaccess (2).tif')
# 
# noacc18<-aggregate(noacc18, fact=5.565974, fun=sum, na.rm=TRUE)
# 
# writeRaster(noacc18, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/noacc18.tif", overwrite=T)

noacc18<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/noacc18.tif")

noacc18[is.na(noacc18)] <- 0

# read pop
# pop18 <- raster(' C:/Users/GIACOMO/Google Drive/pop_wp (1).tif')
# 
# pop18<-aggregate(pop18, fact=5.565974, fun=sum, na.rm=TRUE)
# 
# writeRaster(noacc18, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/pop18.tif", overwrite=T)

#  
pop18<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/pop18.tif")

pop18[is.na(pop18)] <- 0

##
crs(CDDs) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(noacc18) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDD_current <- projectRaster(CDDs, noacc18)

overlay_current <- overlay(noacc18, CDD_current, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})

overlay_current<-stack(overlay_current)

#
crs(CDDs_245) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(noacc18) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDD_245 <- projectRaster(CDDs_245, noacc18)

overlay_245 <- overlay(noacc18, CDD_245, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})

overlay_245<-stack(overlay_245)

#
crs(CDDs_370) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(noacc18) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDD_370 <- projectRaster(CDDs_370, noacc18)

overlay_370 <- overlay(noacc18, CDD_370, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


overlay_370<-stack(overlay_370)

world <- read_sf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/CLEXREL/Data/gadm36_levels_shp/gadm36_0.shp')
world$id = 1:nrow(world)
world <- dplyr::select(world, GID_0, id)
world$continent = countrycode(world$GID_0, "iso3c", "region")
world_raster <- fasterize::fasterize(world, overlay_current[[1]], "id", fun="first")
