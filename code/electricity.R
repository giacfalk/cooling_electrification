#calculate kwh to meet CDDs #

# households that will gain access through decentralised solutions in each country

# grid_distance_km<-raster('C:/Users/GIACOMO/Google Drive/TD_grid_distance_km-0000000000-0000000000.tif')
# grid_distance_km2<-raster('C:/Users/GIACOMO/Google Drive/TD_grid_distance_km-0000000000-0000023296.tif')
# 
# grid_distance_km <-projectRaster(grid_distance_km, noacc18)
# grid_distance_km2 <-projectRaster(grid_distance_km2, noacc18)
# 
# grid_distance_km<-merge(grid_distance_km, grid_distance_km2)
# 
# no_access_through_decentralised <- overlay(noacc18, grid_distance_km, fun = function(x, y) {
#   x[y<50000] <- NA
#   return(x)
# })
# 
# no_access_through_grid <- overlay(noacc18, grid_distance_km, fun = function(x, y) {
#   x[y>=50000] <- NA
#   return(x)
# })

#https://www.sciencedirect.com/science/article/pii/S0378778818323958


# # define urban_rural
# urbrur = raster('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Inequal accessibility to services in sub-Saharan Africa/urbanrural_cut_1209.tif')
# 
# values(urbrur) <- ifelse(values(urbrur)>13, 1, 0)
# 
# getmode <- function(v, na.rm=TRUE) {
# ifelse(mean(v)>0.1, 1, 0)
#   }
# 
# #
# urbrur <- aggregate(urbrur, fact=60.0024, fun=getmode, na.rm=TRUE)
# sum(getValues(urbrur==1), na.rm = T)
# urbrur <-projectRaster(urbrur, noacc18)
# #
# writeRaster(urbrur, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/urbrur.tif", overwrite=T)

urbrur<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/urbrur.tif")

# calculate average number of people in each household based on country and urban/rural
hhsize <- readxl::read_xlsx("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/csvs/population_division_UN_Houseshold_Size_and_Composition_2019.xlsx", sheet="UN HH Size and Composition 2019")
hhsize <- hhsize %>% group_by(`Country or area`) %>% slice(which.max(as.Date(`Reference date (dd/mm/yyyy)`, '%d/%m/%Y'))) %>% ungroup()
hhsize$ISO = countrycode::countrycode(hhsize$`Country or area`, 'country.name', 'iso3c')
hhsize = hhsize %>% dplyr::select(ISO, `Average household size (number of members)`)
isos = unique(world$GID_0)
diff <-setdiff(isos, hhsize$ISO)
more.rows <- data.frame(ISO=diff, `Average household size (number of members)`=NA, stringsAsFactors=F)
colnames(more.rows)[2] <- "Average household size (number of members)"
hhsize<-bind_rows(hhsize, more.rows)
hhsize$`Average household size (number of members)` <- ifelse(hhsize$`Average household size (number of members)` =="..", NA, hhsize$`Average household size (number of members)`)
hhsize$`Average household size (number of members)`=as.numeric(hhsize$`Average household size (number of members)`)
hhsize$`Average household size (number of members)` <- ifelse(is.na(hhsize$`Average household size (number of members)`), mean(hhsize$`Average household size (number of members)`, na.rm=TRUE), hhsize$`Average household size (number of members)`)
world = merge(world, hhsize, by.x="GID_0", by.y="ISO")
world$hhsize = world$`Average household size (number of members)`
Sys.sleep(1.5)
hhsize_raster<-fasterize(world, overlay_current[[1]], "hhsize", fun="first")
hhsize_raster <- projectRaster(hhsize_raster, urbrur)

values(hhsize_raster) <- ifelse(values(urbrur)==1, values(hhsize_raster) * 0.75, values(hhsize_raster) * 1.25)

hhsize_raster <- projectRaster(hhsize_raster, noacc18)
HHs_raster = noacc18/hhsize_raster


###########

crs(CDDs) = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

# loop over the three climate scenarios

scenarios <- c(overlay_current, overlay_245, overlay_370)

all_results=list()
k=1 

for (scenario_climate in scenarios){

urbrur<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/urbrur.tif")

mean_CDDs <- calc(scenario_climate, fun = mean, na.rm = T)

hoursheatday_im <- (scenario_climate/mean_CDDs)*6

hoursheatday_im <- stack(hoursheatday_im)
hoursheatday_im = projectRaster(hoursheatday_im, scenario_climate)
hoursheatday_im = stack(hoursheatday_im)
values(hoursheatday_im) = ifelse(values(hoursheatday_im)>12, 12, values(hoursheatday_im))
values(hoursheatday_im) = ifelse(values(hoursheatday_im)<0, 0, values(hoursheatday_im))

DeltaT_im = scenario_climate
DeltaT_im = stack(DeltaT_im)

Q_im = list()
urbrur = projectRaster(urbrur, DeltaT_im)
values(urbrur) = ifelse(values(urbrur)<0.5, 0, values(urbrur))
values(urbrur) = ifelse(values(urbrur)>=0.5, 1, values(urbrur))

Q_im <- overlay(urbrur, DeltaT_im, fun=Vectorize(function(x,y){
  y[x==1] = 29*(avg_house_volume_urban * m3toliters /24)*y
  y[x==0] = 29*(avg_house_volume_rural* m3toliters /24)*y
}))

Q_im = stack(Q_im)

AChours_im = list()

urbrur = projectRaster(urbrur, Q_im)
values(urbrur) = ifelse(values(urbrur)<0.5, 0, values(urbrur))
values(urbrur) = ifelse(values(urbrur)>=0.5, 1, values(urbrur))

# hours of peak load of compressor 
AChours_im= overlay(urbrur, Q_im, fun=Vectorize(function(x,y){
  y[x==1] = (y/(CC_urban*cooling_ton_to_kw*kw_to_j_per_hour))*heating_loss_factor_urban
  y[x==0] = (y/(CC_rural*cooling_ton_to_kw*kw_to_j_per_hour))*heating_loss_factor_rural
}))

AChours_im = stack(AChours_im)

AChours2_im = AChours_im

values(AChours2_im) <- ifelse(values(AChours_im)<values(hoursheatday_im), values(hoursheatday_im) - values(AChours_im), 0)

ACconsumption_im_hh = list()

AChours_im = projectRaster(AChours_im, urbrur)
values(AChours_im) = ifelse(values(AChours_im)<0, 0, values(AChours_im))

AChours2_im = projectRaster(AChours2_im, urbrur)
values(AChours2_im) = ifelse(values(AChours2_im)<0, 0, values(AChours2_im))

# compressor runs 100% of the time when bringing temperature to desired temperature
# compressor runs 40% of the time when keeping temperature steady
ACconsumption_im_hh = overlay(urbrur, AChours_im, AChours2_im, fun=Vectorize(function(x,y, z){
  y[x==1] = (((CC_urban*cooling_ton_to_kw) / EER_urban) * (y) + ((CC_urban*cooling_ton_to_kw) / EER_urban) * (z) * 0.4)
  y[x==0] = (((CC_rural*cooling_ton_to_kw) / EER_urban) * (y) +  ((CC_rural*cooling_ton_to_kw) / EER_urban) * (z) * 0.4)
}))

ACconsumption_im_hh = stack(ACconsumption_im_hh)*30

ACconsumption_i_hh <- calc(ACconsumption_im_hh, fun = sum, na.rm = T)

ACconsumption_i = ACconsumption_i_hh * HHs_raster

###

# latent AC demand from HHs without electricity access
sum(values(ACconsumption_i), na.rm = T)/1000000000

###

mean_CDDs <- calc(scenario_climate, fun = sum, na.rm = T)

hoursfanuse_im <- (scenario_climate/mean_CDDs)* (max_hrs_permonth_fan_use - min_hrs_permonth_fan_use) + min_hrs_permonth_fan_use

FANconsumption_im_hh = Fan_power*hoursfanuse_im/1000

FANconsumption_i_hh <- calc(FANconsumption_im_hh, fun = sum, na.rm = T)

FANconsumption_i = FANconsumption_i_hh * HHs_raster

sum(values(FANconsumption_i), na.rm = T)/1000000000

##
# extract sum by group of ISO raster
world$FANconsumption = exact_extract(FANconsumption_i, world, 'sum')
world$ACconsumption = exact_extract(ACconsumption_i, world, 'sum')
world$TOTconsumption = world$FANconsumption + world$ACconsumption

world = st_as_sf(world)

#TWh
sum(world$ACconsumption, na.rm = T) / 1000000000
sum(world$FANconsumption, na.rm = T) / 1000000000
sum(world$TOTconsumption, na.rm = T) / 1000000000

# today about 2000 TWh of AC consumption worldwide: https://www.iea.org/reports/the-future-of-cooling

#########
# Simulate penetration of technologies based on CDDs, wealth, and urb/rur
##########
pop_urban<-overlay(noacc18, urbrur, fun=function(x,y){
  x[y==0]<-NA
  return(x)
})

pop_rural<-overlay(noacc18, urbrur, fun=function(x,y){
  x[y==1]<-NA
  return(x)
})

# # Scenario 1: AC to urban households and households 50% in rural
AC_demanding_pop_S1 <- merge(pop_urban/hhsize_raster, (pop_rural/hhsize_raster)*0.5)
FAN_demanding_pop_S1 <- noacc18/hhsize_raster - AC_demanding_pop_S1
AC_demanding_share_S1 <- AC_demanding_pop_S1 / (AC_demanding_pop_S1 + FAN_demanding_pop_S1)
FAN_demanding_share_S1 <- FAN_demanding_pop_S1 / (AC_demanding_pop_S1 + FAN_demanding_pop_S1)
kwh_S1 = FANconsumption_i * FAN_demanding_share_S1 + ACconsumption_i * AC_demanding_share_S1
world$kwh_S1 = exact_extract(kwh_S1, world, 'sum')

# # Scenario 2: AC to urban households and households above 80% in rural
AC_demanding_pop_S2 <- merge(pop_urban/hhsize_raster, pop_rural/hhsize_raster*0.2)
FAN_demanding_pop_S2 <- noacc18/hhsize_raster - AC_demanding_pop_S2
AC_demanding_share_S2 <- AC_demanding_pop_S2 / (AC_demanding_pop_S2 + FAN_demanding_pop_S2)
FAN_demanding_share_S2 <- FAN_demanding_pop_S2 / (AC_demanding_pop_S2 + FAN_demanding_pop_S2)
kwh_S2 = FANconsumption_i * FAN_demanding_share_S2 + ACconsumption_i * AC_demanding_share_S2
world$kwh_S2 = exact_extract(kwh_S2, world, 'sum')

# # Scenario 3: AC to households above 40% in urban and 80% in rural
AC_demanding_pop_S3 <- merge(pop_urban/hhsize_raster*0.6, pop_rural/hhsize_raster*0.2)
FAN_demanding_pop_S3 <- noacc18/hhsize_raster - AC_demanding_pop_S3
AC_demanding_share_S3 <- AC_demanding_pop_S3 / (AC_demanding_pop_S3 + FAN_demanding_pop_S3)
FAN_demanding_share_S3 <- FAN_demanding_pop_S3 / (AC_demanding_pop_S3 + FAN_demanding_pop_S3)
kwh_S3 = FANconsumption_i * FAN_demanding_share_S3 + ACconsumption_i * AC_demanding_share_S3
world$kwh_S3 = exact_extract(kwh_S3, world, 'sum')

# # Scenario 4 (benchmark): all AC
AC_demanding_pop_S4 <- merge(pop_urban/hhsize_raster, pop_rural/hhsize_raster)
FAN_demanding_pop_S4 <- noacc18/hhsize_raster - AC_demanding_pop_S4
AC_demanding_share_S4 <- AC_demanding_pop_S4 / (AC_demanding_pop_S4 + FAN_demanding_pop_S4)
FAN_demanding_share_S4 <- FAN_demanding_pop_S4 / (AC_demanding_pop_S4 + FAN_demanding_pop_S4)
kwh_S4 = FANconsumption_i * FAN_demanding_share_S4 + ACconsumption_i * AC_demanding_share_S4
world$kwh_S4 = exact_extract(kwh_S4, world, 'sum')

# melt by scenario
world_out = gather(world, "scenario", "kwh", kwh_S1, kwh_S2, kwh_S3, kwh_S4)

world_out$geometry=NULL

all_results[[k]] = world_out
k = k+1
gc()
}

world = rbindlist(all_results, idcol = T)
world$id = world$.id
world$id = ifelse(world$id==1, "Baseline", ifelse(world$id==2, "RCP245", "RCP370"))

world = subset(world, world$kwh!=0)

world_plot = world %>% group_by(id, scenario, continent) %>% mutate(kwh=sum(kwh, na.rm = T))

# plot
kwh_country = ggplot() +
  theme_classic()+
  geom_bar(data = world_plot, aes(x = continent , y = kwh/1000000000, fill=id), stat = "sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="Scenario", palette = "Set1")+
  ylab("Latent power demand for air cooling \nfrom households without electricty")+
  xlab("Region")+
  ggtitle("Yearly electricity consumption (TWh)")+
  facet_wrap(~ scenario, ncol=2)

ggsave(paste0("kwh_region_", base_temp, ".png"), kwh_country, device="png")

# world$noacc18 = exact_extract(noacc18, world, 'sum')
# world$kwhcapita = world$kwh/world$noacc18
# 
# kwh_map = ggplot() +
#   theme_classic()+
#   geom_sf(data = world, aes(fill = kwh/noacc18)) +
#   theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
#   scale_fill_viridis_b(name = "kWh/person without electricity access", trans="log")+
#   #ggtitle("")+
#   ylab("Latitude")+
#   xlab("Longitude")+
#   facet_wrap(~ scenario, ncol=2)

#ggsave("kwh_map.png", kwh_map, device="png")
