#calculate kwh to meet CDDs #
# 
# urbrur = raster('GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V2_0.tif')
# 
# template <- raster('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Anteneh/nodatamask_1.ASC')
# 
# template_pol <- rasterToPolygons(template)
# template_pol = st_as_sf(template_pol)
# st_crs(template_pol)<-4326
# 
# template_pol$urbrur = exactextractr::exact_extract(urbrur, template_pol, fun="mean")
# 
# template_pol$urbrur = ifelse(template_pol$urbrur>11.5, 1, 0)
# 
# library(fasterize)
# urbrur <- fasterize(template_pol, template, field="urbrur", fun="first")
# 
# plot(urbrur)
# crs(urbrur)<-"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
# 
# writeRaster(urbrur, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/urbrur.tif", overwrite=T)
# 

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
values(hoursheatday_im) = ifelse(values(hoursheatday_im)>10, 10, values(hoursheatday_im))
values(hoursheatday_im) = ifelse(values(hoursheatday_im)<0, 0, values(hoursheatday_im))

DeltaT_im = scenario_climate

Q_im = list()
urbrur = projectRaster(urbrur, DeltaT_im, method = "ngb")

Q_im <- overlay(urbrur, DeltaT_im, fun=Vectorize(function(x,y){
  y[x==0] <- 29*(avg_house_volume_rural* m3toliters /24)*y
  y[x==1] <- 29*(avg_house_volume_urban * m3toliters /24)*y
  return(y)
}))

Q_im = stack(Q_im)

AChours_im = list()

urbrur = projectRaster(urbrur, Q_im, method = "ngb")

# hours of peak load of compressor in each month i  
AChours_im= overlay(urbrur, Q_im, fun=Vectorize(function(x,y){
  y[x==1] = (y/(CC_urban*cooling_ton_to_kw*kw_to_j_per_hour))
  y[x==0] = (y/(CC_rural*cooling_ton_to_kw*kw_to_j_per_hour))
  return(y)
}))

AChours_im = stack(AChours_im)

ACconsumption_im_hh = list()

AChours_im = projectRaster(AChours_im, urbrur)
values(AChours_im) = ifelse(values(AChours_im)<0, 0, values(AChours_im))

# compressor runs 100% of the time when bringing temperature to desired temperature
# compressor runs x% of the time when keeping temperature steady (see window_heat_gain.R)
ACconsumption_im_hh = overlay(urbrur, AChours_im, hoursheatday_im, compressor_share_time_on_urban, compressor_share_time_on_rural, fun=Vectorize(function(x,y, z, k, l){
  y[x==1] = (((CC_urban*cooling_ton_to_kw) / EER_urban) * (y)) + (((CC_urban*cooling_ton_to_kw) / EER_urban) * (z) * k)
  y[x==0] = (((CC_rural*cooling_ton_to_kw) / EER_rural) * (y)) +  (((CC_rural*cooling_ton_to_kw) / EER_rural) * (z) * l)
  return(y)
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


# wealth quintiles (sub-national data); where unavailable use a fixed share of urb/rur population
wealth <- read_sf("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/dhs/sdr_exports.gdb")

wealth <- dplyr::select(wealth, 30:34, Shape)

q1<-fasterize(wealth, overlay_current[[1]], "HCWIXQPLOW", fun="first")
q2<-fasterize(wealth, overlay_current[[1]], "HCWIXQP2ND", fun="first")
q3<-fasterize(wealth, overlay_current[[1]], "HCWIXQPMID", fun="first")
q4<-fasterize(wealth, overlay_current[[1]], "HCWIXQP4TH", fun="first")
q5<-fasterize(wealth, overlay_current[[1]], "HCWIXQPHGH", fun="first")

# # Scenario 1: AC to 60% wealthiest urban households and 20% wealthiest households above in rural
AC_demanding_pop_S1 <- merge(pop_urban/hhsize_raster*(q3+q4+q5)/100, pop_rural/hhsize_raster*(q5)/100)
values(AC_demanding_pop_S1) <- ifelse(values(pop_urban)>0 & is.na(values(q3)), values(pop_urban/hhsize_raster*0.6), values(AC_demanding_pop_S1))
values(AC_demanding_pop_S1) <- ifelse(values(pop_rural)>0 & is.na(values(q3)), values(pop_rural/hhsize_raster*0.2), values(AC_demanding_pop_S1))
FAN_demanding_pop_S1 <- noacc18/hhsize_raster - AC_demanding_pop_S1
AC_demanding_share_S1 <- AC_demanding_pop_S1 / (AC_demanding_pop_S1 + FAN_demanding_pop_S1)
FAN_demanding_share_S1 <- FAN_demanding_pop_S1 / (AC_demanding_pop_S1 + FAN_demanding_pop_S1)
kwh_S1 = FANconsumption_i * FAN_demanding_share_S1 + ACconsumption_i * AC_demanding_share_S1
world$kwh_S1 = exact_extract(kwh_S1, world, 'sum')

# # Scenario 2: AC to 100% urban households and 40% wealthiest households in rural
AC_demanding_pop_S2 <- merge(pop_urban/hhsize_raster*(q1+q2+q3+q4+q5)/100, pop_rural/hhsize_raster*(q4+q5)/100)
values(AC_demanding_pop_S2) <- ifelse(values(pop_urban)>0 & is.na(values(q3)), values(pop_urban/hhsize_raster*1), values(AC_demanding_pop_S2))
values(AC_demanding_pop_S2) <- ifelse(values(pop_rural)>0 & is.na(values(q3)), values(pop_rural/hhsize_raster*0.4), values(AC_demanding_pop_S2))
FAN_demanding_pop_S2 <- noacc18/hhsize_raster - AC_demanding_pop_S2
AC_demanding_share_S2 <- AC_demanding_pop_S2 / (AC_demanding_pop_S2 + FAN_demanding_pop_S2)
FAN_demanding_share_S2 <- FAN_demanding_pop_S2 / (AC_demanding_pop_S2 + FAN_demanding_pop_S2)
kwh_S2 = FANconsumption_i * FAN_demanding_share_S2 + ACconsumption_i * AC_demanding_share_S2
world$kwh_S2 = exact_extract(kwh_S2, world, 'sum')

# # Scenario 3 (benchmark): all AC
AC_demanding_pop_S3 <- merge(pop_urban/hhsize_raster*(q1+q2+q3+q4+q5)/100, pop_rural/hhsize_raster*(q1+q2+q3+q4+q5)/100)
values(AC_demanding_pop_S3) <- ifelse(values(pop_urban)>0 & is.na(values(q3)), values(pop_urban/hhsize_raster*1), values(AC_demanding_pop_S3))
values(AC_demanding_pop_S3) <- ifelse(values(pop_rural)>0 & is.na(values(q3)), values(pop_rural/hhsize_raster*1), values(AC_demanding_pop_S3))
FAN_demanding_pop_S3 <- noacc18/hhsize_raster - AC_demanding_pop_S3
AC_demanding_share_S3 <- AC_demanding_pop_S3 / (AC_demanding_pop_S3 + FAN_demanding_pop_S3)
FAN_demanding_share_S3 <- FAN_demanding_pop_S3 / (AC_demanding_pop_S3 + FAN_demanding_pop_S3)
kwh_S3 = FANconsumption_i * FAN_demanding_share_S3 + ACconsumption_i * AC_demanding_share_S3
world$kwh_S3 = exact_extract(kwh_S3, world, 'sum')

# # Scenario 4 (benchmark): all fan
AC_demanding_pop_S4 <- merge(pop_urban/hhsize_raster*(0)/100, pop_rural/hhsize_raster*(0)/100)
values(AC_demanding_pop_S4) <- ifelse(values(pop_urban)>0 & is.na(values(q3)), values(pop_urban/hhsize_raster*0), values(AC_demanding_pop_S4))
values(AC_demanding_pop_S4) <- ifelse(values(pop_rural)>0 & is.na(values(q3)), values(pop_rural/hhsize_raster*0), values(AC_demanding_pop_S4))
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

countries_without = world
countries_without$geometry=NULL
summary_electricity <- countries_without %>% group_by(scenario, id) %>% summarise(twh = sum(kwh, na.rm = T)/1000000000)

write.csv(summary_electricity, paste0("summary_power_consumpion_", base_temp, "_", EER_urban, "_", EER_rural, ".csv"))

world_plot = world %>% group_by(id, scenario, continent) %>% mutate(kwh=sum(kwh, na.rm = T))

# plot
kwh_country = ggplot() +
  theme_classic()+
  geom_bar(data = world_plot[which(world_plot$kwh>1000000),], aes(x = continent , y = kwh/1000000000, fill=id), stat = "sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="Scenario", palette = "Set1")+
  ylab("Latent power demand for air cooling \nfrom households without electricty")+
  xlab("Region")+
  ggtitle("Yearly electricity consumption (TWh)")+
  facet_wrap(~ scenario, ncol=2)

ggsave(paste0("kwh_region_", base_temp, ".png"), kwh_country, device="png")

write.csv(world_plot, paste0("power_consumpion_", base_temp, "_", EER_urban, "_", EER_rural, ".csv"))


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
