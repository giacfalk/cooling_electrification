CDDs <- stack(paste0("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Manuscript/Submission ENB/Revision 1/New data Malcolm/gldas_0p25_deg_cdd_base_T_", base_temp ,"C_1970_2009_mth.nc4"))

indices<-rep(rep(1:12,each=1), 480/12)

CDDs<-stackApply(CDDs, indices, fun = mean)

writeRaster(CDDs, "CDDs_2020_global_malcolm.tif", overwrite=T)

CDDs <- stack("CDDs_2020_global_malcolm.tif")

##

CDDs_wetbulb <- stack(paste0("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Manuscript/Submission ENB/Revision 1/New data Malcolm/wetbulb/gldas_0p25_deg_wet_bulb_cdd_base_T_", base_temp ,"C_1970_2009_mth.nc4"))

indices<-rep(rep(1:12,each=1), 480/12)

CDDs_wetbulb<-stackApply(CDDs_wetbulb, indices, fun = mean)

writeRaster(CDDs_wetbulb, "CDDs_2020_global_malcolm_wetbulb.tif", overwrite=T)

CDDs_wetbulb <- stack("CDDs_2020_global_malcolm_wetbulb.tif")



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

names(overlay_current) <- month.abb

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

png("sensitivity_cdds_malcolm/CDD_today_malcolm.png", width=1200, height=1600, res=150)
print(levelplot(overlay_current, xlim=c(-100, 180), ylim=c(-40, 45),
                main="CDDs in areas without electr. access, base T 26° C, 1970-2000", at=my.at, colorkey=myColorkey,  par.settings = YlOrRdTheme, xlab="Longitude", ylab="Latitude", ncol=2) + layer(sp.polygons(bPols)))
dev.off()

# Calculate relative difference
CDDs <- stack("CDDs_2020_global.tif")
CDDs_malcolm <- stack("CDDs_2020_global_malcolm.tif")

crs(CDDs) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(noacc18) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDD_current <- projectRaster(CDDs, noacc18)

overlay_current <- overlay(noacc18, CDD_current, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})

overlay_current<-stack(overlay_current)


crs(CDDs_malcolm) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDDs_malcolm <- projectRaster(CDDs_malcolm, noacc18)

overlay_malcolm <- overlay(noacc18, CDDs_malcolm, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_diff <- stack(overlay_current / overlay_malcolm) 

my.at <- c(0.5, 1, 1.5, 2, 2.5, 3, 3.5)

myColorkey <- list(at=my.at, ## where the colors change
                   labels=list(
                     labels=c("-50%", "0%", "+50%", "+100%", "+150%", "+200%", "+250%"), ## labels
                     at=my.at ## where to print labels
                   ))


pal <- brewer.pal(6,"YlOrRd")
pal[1] <- "#a1ebed"
pal[2] <- "#f2f5f5"
mapTheme <- rasterTheme(region = pal)

png("sensitivity_cdds_malcolm/CDD_today_malcolm_reldiff.png", width=1200, height=1600, res=150)
print(levelplot(CDDs_diff, xlim=c(-100, 180), ylim=c(-40, 45),
                main="% change in CDDs, base T 26° C, historical climate", at=my.at, colorkey=myColorkey,  par.settings = mapTheme, xlab="Longitude", ylab="Latitude", ncol=2) + layer(sp.polygons(bPols)))
dev.off()

# Comparison with wetbulb
crs(CDDs_wetbulb) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(noacc18) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDD_current <- projectRaster(CDDs_wetbulb, noacc18)

overlay_current <- overlay(noacc18, CDD_current, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})

overlay_current<-stack(overlay_current)

names(overlay_current) <- month.abb

ext <- as.vector(extent(CDDs_wetbulb))
boundaries <- map('worldHires', fill=TRUE,
                  xlim=ext[1:2], ylim=ext[3:4],
                  plot=FALSE)
IDs <- sapply(strsplit(boundaries$names, ":"), function(x) x[1])
bPols <- map2SpatialPolygons(boundaries, IDs=IDs,
                             proj4string=CRS(projection(CDDs_wetbulb)))

my.at <- c(15, 30, 60, 120, 240, 480, 960)

myColorkey <- list(at=my.at, ## where the colors change
                   labels=list(
                     at=my.at ## where to print labels
                   ))

png("sensitivity_cdds_malcolm/CDD_today_malcolm_wb.png", width=1200, height=1600, res=150)
print(levelplot(overlay_current, xlim=c(-100, 180), ylim=c(-40, 45),
                main="CDDs wet-bulb in areas without electr. access, base T 26° C, 1970-2000", at=my.at, colorkey=myColorkey,  par.settings = YlOrRdTheme, xlab="Longitude", ylab="Latitude", ncol=2) + layer(sp.polygons(bPols)))
dev.off()

# Calculate relative difference
CDDs <- stack("CDDs_2020_global.tif")
CDDs_wetbulb <- stack("CDDs_2020_global_malcolm_wetbulb.tif")

crs(CDDs) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(noacc18) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDD_current <- projectRaster(CDDs, noacc18)

overlay_current <- overlay(noacc18, CDD_current, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})

overlay_current<-stack(overlay_current)


crs(CDDs_wetbulb) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDDs_wetbulb <- projectRaster(CDDs_wetbulb, noacc18)

overlay_malcolm_wb <- overlay(noacc18, CDDs_wetbulb, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_diff <- stack(overlay_current / overlay_malcolm_wb) 

my.at <- c(0.5, 1, 1.5, 2, 2.5, 3, 3.5)

myColorkey <- list(at=my.at, ## where the colors change
                   labels=list(
                     labels=c("-50%", "0%", "+50%", "+100%", "+150%", "+200%", "+250%"), ## labels
                     at=my.at ## where to print labels
                   ))


pal <- brewer.pal(6,"YlOrRd")
pal[1] <- "#a1ebed"
pal[2] <- "#f2f5f5"
mapTheme <- rasterTheme(region = pal)

png("sensitivity_cdds_malcolm/CDD_today_malcolm_reldiff_wetbulb.png", width=1200, height=1600, res=150)
print(levelplot(CDDs_diff, xlim=c(-100, 180), ylim=c(-40, 45),
                main="% change in CDDs (wet-bulb), base T 26° C, historical climate", at=my.at, colorkey=myColorkey,  par.settings = mapTheme, xlab="Longitude", ylab="Latitude", ncol=2) + layer(sp.polygons(bPols)))
dev.off()


# Summarise yearly / monthly CDDs within each country

CDDs<-stack("CDDs_2020_global.tif")
CDDs_malcolm<-stack("CDDs_2020_global_malcolm.tif")
CDDs_wetbulb<-stack("CDDs_2020_global_malcolm_wetbulb.tif")

noacc18<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/noacc18.tif")

noacc18[is.na(noacc18)] <- 0

crs(CDDs) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(CDDs_malcolm) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
crs(CDDs_wetbulb) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

CDDs <- projectRaster(CDDs, noacc18)

overlay <- overlay(noacc18, CDDs, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_malcolm <- projectRaster(CDDs_malcolm, noacc18)

overlay_malcolm <- overlay(noacc18, CDDs_malcolm, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})


CDDs_wetbulb <- projectRaster(CDDs_wetbulb, noacc18)

overlay_malcolm_wb <- overlay(noacc18, CDDs_wetbulb, fun = function(x, y) {
  y[x<100] <- NA
  return(y)
})

#

gadm0<-read_sf("gadm_africa.shp")

gadm0_CDDs<-exact_extract(overlay, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_worldclim (1970-2000 avg.)")
gadm0_CDDs <- bind_cols(gadm0_CDDs, as.data.frame(rep(gadm0$ISO3, 12)))

gadm0_CDDs_malcolm<-exact_extract(overlay_malcolm, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_GLDAS (1970-2009 avg.)")
gadm0_CDDs_malcolm <- bind_cols(gadm0_CDDs_malcolm, as.data.frame(rep(gadm0$ISO3, 12)))

gadm0_CDDs_wb<-exact_extract(overlay_malcolm_wb, gadm0, fun="sum") %>% gather(key="month", value="value") %>% mutate(source="CDDs_wetbulb_GLDAS (1970-2009 avg.)")
gadm0_CDDs_wb <- bind_cols(gadm0_CDDs_wb, as.data.frame(rep(gadm0$ISO3, 12)))

bind <- rbind(gadm0_CDDs, gadm0_CDDs_malcolm, gadm0_CDDs_wb)

colnames(bind)[4]<-"ISO3"
bind$month <- gsub("sum.layer.", "", bind$month)

bind$month <- factor(month.abb[as.numeric(bind$month)],levels=month.abb)

write.csv(bind, "CDDs_countrylevel.csv")

bind = dplyr::group_by(bind, source, month) %>% summarise(value=sum(value, na.rm = T))

ggplot(bind, aes(x=source, y=value/1000, fill=source))+
  geom_col(position = "dodge")+
  coord_flip()+
  theme_classic()+
  ylab("Monthly total experienced CDD (thousands, Tbase=26 °C) \n in areas without electricity access")+
  xlab("Source")+
  scale_fill_discrete("Source")+
  theme(legend.position = "none", legend.direction = "horizontal", axis.text.x = element_text(angle = 90))+ facet_wrap(vars(month), ncol = 3)

ggsave("monthy_sensitivity.png", last_plot(),  device="png", scale=2, width =  11/2.5, height = (6.62/2)*0.75)

bind = dplyr::group_by(bind, source) %>% summarise(value=sum(value, na.rm = T))

ggplot(bind, aes(x=source, y=value/1000, fill=source))+
  geom_col(position = "dodge")+
  theme_classic()+
  coord_flip()+
  ylab("Annual total experienced CDD (thousands, Tbase=26 °C) \n in areas without electricity access")+
  xlab("Source")+
  scale_fill_discrete("Source")+
  theme(legend.position = "none", legend.direction = "horizontal", axis.text.x = element_text(angle = 90))

ggsave("year_sensitivity.png", last_plot(),  device="png", scale=1.2)

st_crs(gadm0) <- crs(noacc18)
noacc18_plot <- rgis::fast_mask(noacc18, gadm0)

noacc18_plot <- as.data.frame(noacc18_plot, xy=T)
colnames(noacc18_plot)[1:2] <-c("long", "lat")

library(scales)

ggplot() +
  geom_tile(data = na.exclude(noacc18_plot), aes(x = long, y = lat, fill = ifelse(layer+1>10000, layer+1, NA)))+
  geom_sf(data= gadm0, fill=NA, colour="black")+
  scale_fill_viridis(name="People w/out electr.", trans = 'log10')+
  ggtitle("Distribution of population without electricity access")+
  xlab("")+
  ylab("")+
  xlim(c(-20, 60))+
  ylim(c(-40, 30))+
  theme_classic()

ggsave("map_access.png", last_plot(),  device="png", scale=1)

######

CDDs_245 <- stack('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/CDDs_2040_2060_245_global.tif')

CDDs_370 <- stack('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/CDDs_2040_2060_370_global.tif')


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


##

world <- read_sf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/CLEXREL/Data/gadm36_levels_shp/gadm36_0.shp')
world$id = 1:nrow(world)
world <- dplyr::select(world, GID_0, id)
world$continent = countrycode(world$GID_0, "iso3c", "region")
world_raster <- fasterize::fasterize(world, overlay_current[[1]], "id", fun="first")
