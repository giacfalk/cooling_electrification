for (base_temp in c(22, 24, 28, 26)){

# produce csv 

CDDs <- stack(paste0("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Manuscript/Submission ENB/Revision 1/New data Malcolm/gldas_0p25_deg_cdd_base_T_", base_temp ,"C_1970_2009_mth.nc4"))

indices<-rep(rep(1:12,each=1), 480/12)

CDDs<-stackApply(CDDs, indices, fun = mean)
writeRaster(CDDs, paste0("CDDs_2020_global_malcolm_", base_temp , ".tif"), overwrite=T)

#

CDDs_wetbulb <- stack(paste0("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Manuscript/Submission ENB/Revision 1/New data Malcolm/wetbulb/gldas_0p25_deg_wet_bulb_cdd_base_T_", base_temp ,"C_1970_2009_mth.nc4"))

indices<-rep(rep(1:12,each=1), 480/12)

CDDs_wetbulb<-stackApply(CDDs_wetbulb, indices, fun = mean)
writeRaster(CDDs_wetbulb, paste0("CDDs_2020_global_malcolm_wetbulb_", base_temp , ".tif"), overwrite=T)

# 

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
writeRaster(CDDs, paste0("CDDs_2020_global_", base_temp ,".tif"), overwrite=T)
}

##

# Summarise yearly / monthly CDDs within each country

CDDs_22<-stack("CDDs_2020_global.tif")
CDDs_malcolm_22<-stack("CDDs_2020_global_malcolm.tif")
CDDs_wetbulb_22<-stack("CDDs_2020_global_malcolm_wetbulb.tif")

noacc18<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/noacc18.tif")

noacc18[is.na(noacc18)] <- 0

crs(CDDs_22) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(CDDs_malcolm_22) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(CDDs_wetbulb_22) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDDs_22 <- projectRaster(CDDs_22, noacc18)

overlay_22 <- overlay(noacc18, CDDs_22, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_malcolm_22 <- projectRaster(CDDs_malcolm_22, noacc18)

overlay_malcolm_22 <- overlay(noacc18, CDDs_malcolm_22, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_wetbulb_22 <- projectRaster(CDDs_wetbulb_22, noacc18)

overlay_malcolm_wb_22 <- overlay(noacc18, CDDs_wetbulb_22, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})

#

CDDs_24<-stack("CDDs_2020_global.tif")
CDDs_malcolm_24<-stack("CDDs_2020_global_malcolm.tif")
CDDs_wetbulb_24<-stack("CDDs_2020_global_malcolm_wetbulb.tif")

noacc18<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/noacc18.tif")

noacc18[is.na(noacc18)] <- 0

crs(CDDs_24) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(CDDs_malcolm_24) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(CDDs_wetbulb_24) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDDs_24 <- projectRaster(CDDs_24, noacc18)

overlay_24 <- overlay(noacc18, CDDs_24, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_malcolm_24 <- projectRaster(CDDs_malcolm_24, noacc18)

overlay_malcolm_24 <- overlay(noacc18, CDDs_malcolm_24, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_wetbulb_24 <- projectRaster(CDDs_wetbulb_24, noacc18)

overlay_malcolm_wb_24 <- overlay(noacc18, CDDs_wetbulb_24, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})

#

CDDs_26<-stack("CDDs_2020_global.tif")
CDDs_malcolm_26<-stack("CDDs_2020_global_malcolm.tif")
CDDs_wetbulb_26<-stack("CDDs_2020_global_malcolm_wetbulb.tif")

noacc18<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/noacc18.tif")

noacc18[is.na(noacc18)] <- 0

crs(CDDs_26) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(CDDs_malcolm_26) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(CDDs_wetbulb_26) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDDs_26 <- projectRaster(CDDs_26, noacc18)

overlay_26 <- overlay(noacc18, CDDs_26, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_malcolm_26 <- projectRaster(CDDs_malcolm_26, noacc18)

overlay_malcolm_26 <- overlay(noacc18, CDDs_malcolm_26, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_wetbulb_26 <- projectRaster(CDDs_wetbulb_26, noacc18)

overlay_malcolm_wb_26 <- overlay(noacc18, CDDs_wetbulb_26, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})

#

CDDs_28<-stack("CDDs_2020_global.tif")
CDDs_malcolm_28<-stack("CDDs_2020_global_malcolm.tif")
CDDs_wetbulb_28<-stack("CDDs_2020_global_malcolm_wetbulb.tif")

noacc18<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/noacc18.tif")

noacc18[is.na(noacc18)] <- 0

crs(CDDs_28) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(CDDs_malcolm_28) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(CDDs_wetbulb_28) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDDs_28 <- projectRaster(CDDs_28, noacc18)

overlay_28 <- overlay(noacc18, CDDs_28, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_malcolm_28 <- projectRaster(CDDs_malcolm_28, noacc18)

overlay_malcolm_28 <- overlay(noacc18, CDDs_malcolm_28, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_wetbulb_28 <- projectRaster(CDDs_wetbulb_28, noacc18)

overlay_malcolm_wb_28 <- overlay(noacc18, CDDs_wetbulb_28, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})

#

gadm0<-read_sf("gadm_africa.shp")

tbase = 22
gadm0_CDDs<-exact_extract(overlay_22, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_worldclim (1970-2000 avg.)")
gadm0_CDDs <- bind_cols(gadm0_CDDs, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs))))

gadm0_CDDs_malcolm<-exact_extract(overlay_malcolm_22, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_GLDAS (1970-2009 avg.)")
gadm0_CDDs_malcolm <- bind_cols(gadm0_CDDs_malcolm, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs_malcolm))))

gadm0_CDDs_wb<-exact_extract(overlay_malcolm_wb_22, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_wetbulb_GLDAS (1970-2009 avg.)")
gadm0_CDDs_wb <- bind_cols(gadm0_CDDs_wb, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs_wb))))

colnames(gadm0_CDDs) <- colnames(gadm0_CDDs_malcolm) <- colnames(gadm0_CDDs_wb) <- c("month", "value", "source", "iso3", "tbase")

bind_22 <- rbind(gadm0_CDDs, gadm0_CDDs_malcolm, gadm0_CDDs_wb)

tbase = 24
gadm0_CDDs<-exact_extract(overlay_24, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_worldclim (1970-2000 avg.)")
gadm0_CDDs <- bind_cols(gadm0_CDDs, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs))))

gadm0_CDDs_malcolm<-exact_extract(overlay_malcolm_24, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_GLDAS (1970-2009 avg.)")
gadm0_CDDs_malcolm <- bind_cols(gadm0_CDDs_malcolm, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs_malcolm))))

gadm0_CDDs_wb<-exact_extract(overlay_malcolm_wb_24, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_wetbulb_GLDAS (1970-2009 avg.)")
gadm0_CDDs_wb <- bind_cols(gadm0_CDDs_wb, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs_wb))))

colnames(gadm0_CDDs) <- colnames(gadm0_CDDs_malcolm) <- colnames(gadm0_CDDs_wb) <- c("month", "value", "source", "iso3", "tbase")

bind_24 <- rbind(gadm0_CDDs, gadm0_CDDs_malcolm, gadm0_CDDs_wb)

tbase = 26
gadm0_CDDs<-exact_extract(overlay_26, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_worldclim (1970-2000 avg.)")
gadm0_CDDs <- bind_cols(gadm0_CDDs, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs))))

gadm0_CDDs_malcolm<-exact_extract(overlay_malcolm_26, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_GLDAS (1970-2009 avg.)")
gadm0_CDDs_malcolm <- bind_cols(gadm0_CDDs_malcolm, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs_malcolm))))

gadm0_CDDs_wb<-exact_extract(overlay_malcolm_wb_26, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_wetbulb_GLDAS (1970-2009 avg.)")
gadm0_CDDs_wb <- bind_cols(gadm0_CDDs_wb, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs_wb))))

colnames(gadm0_CDDs) <- colnames(gadm0_CDDs_malcolm) <- colnames(gadm0_CDDs_wb) <- c("month", "value", "source", "iso3", "tbase")

bind_26 <- rbind(gadm0_CDDs, gadm0_CDDs_malcolm, gadm0_CDDs_wb)

tbase = 28
gadm0_CDDs<-exact_extract(overlay_28, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_worldclim (1970-2000 avg.)")
gadm0_CDDs <- bind_cols(gadm0_CDDs, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs))))

gadm0_CDDs_malcolm<-exact_extract(overlay_malcolm_28, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_GLDAS (1970-2009 avg.)")
gadm0_CDDs_malcolm <- bind_cols(gadm0_CDDs_malcolm, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs_malcolm))))

gadm0_CDDs_wb<-exact_extract(overlay_malcolm_wb_28, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_wetbulb_GLDAS (1970-2009 avg.)")
gadm0_CDDs_wb <- bind_cols(gadm0_CDDs_wb, as.data.frame(rep(gadm0$ISO3, 12)), as.data.frame(rep(tbase, nrow(gadm0_CDDs_wb))))

colnames(gadm0_CDDs) <- colnames(gadm0_CDDs_malcolm) <- colnames(gadm0_CDDs_wb) <- c("month", "value", "source", "iso3", "tbase")

bind_28 <- rbind(gadm0_CDDs, gadm0_CDDs_malcolm, gadm0_CDDs_wb)

#
bind <- rbind(bind_22, bind_24, bind_26, bind_28)
bind$month <- gsub("sum.layer.", "", bind$month)
bind$month <- factor(month.abb[as.numeric(bind$month)],levels=month.abb)

# Re-arrange the columns to be as
# Month, Country, T_base, CDDs_total, Method,  Temperature_source 
# The Methods will be ASHRAE for the GLDAS, and UKMO for your dataset.

bind$method[bind$source=="CDDs_GLDAS (1970-2009 avg.)" | bind$source=="CDDs_wetbulb_GLDAS (1970-2009 avg.)" ] <- "ASHRAE"
bind$method[bind$source=="CDDs_worldclim (1970-2000 avg.)"] <- "UKMO"

write.csv(bind, "CDDs_countrylevel.csv")

