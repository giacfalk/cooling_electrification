######################

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

writeRaster(HHs_raster, "HHs_raster.tif", overwrite=T)

###########

crs(CDDs) = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

# loop over the three climate scenarios

scenarios <- c(overlay_current, overlay_245, overlay_370)

all_results=list()
k=1 

for (scenario_climate in scenarios){
  
  RCP <- ifelse(k==1, "baseline", ifelse(k==2, "245", "370"))  
  
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
  
  # Empirical scenarios
  # Get rdhs indicators list for wealth
  indicators <- rdhs::dhs_indicators() # https://api.dhsprogram.com/rest/dhs/dataupdates check here if server is down
  wealth <- indicators[3125:3129,]$IndicatorId
  
  # Get iso codes of SSA countries
  
  gadm0 <- read_sf('gadm_africa.shp')
  ext <- extent(gadm0)
  boundaries <- map('world', fill=TRUE,
                    xlim=ext[1:2], ylim=ext[3:4],
                    plot=FALSE)
  
  world <- st_as_sf(boundaries) %>% rename(geometry=geom)
  world$id = 1:nrow(world)
  world$ISO3 = countrycode(world$ID, "country.name", "iso3c")
  world <- dplyr::select(world, ISO3, id)
  world$continent = countrycode(world$ISO3, "iso3c", "continent")
  
  world = subset(world, world$continent=="Africa")
  
  world <- filter(world, ISO3!="DZA", ISO3!="EGY", ISO3!="LBY", ISO3!="TUN", ISO3!="MAR")
  
  cc <- countrycode(unique(world$ISO3), "iso3c", "iso2c")
  
  cc_dhs <- as.data.frame(dhs_countries(returnFields=c("CountryName","DHS_CountryCode")))
  cc_dhs$iso2c <- countrycode(cc_dhs$CountryName, 'country.name', 'iso2c')

  cc <- subset(cc_dhs, cc_dhs$iso2c %in% cc)
  cc[nrow(cc)+1,] <- c("SO", "Somalia", "SO")
  cc[nrow(cc)+1,] <- c("SS", "South Sudan", "SS")
  
  # Get data
  
  resp <- dhs_data(indicatorIds = wealth,countryIds = cc$DHS_CountryCode, breakdown="subnational",surveyYearStart = 1987)
 
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "BT"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_LOW"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "BT"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_2ND"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "BT"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_MID"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "BT"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_4TH"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "BT"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_HGH"
  
  #
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SD"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_LOW"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SD"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_2ND"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SD"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_MID"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SD"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_4TH"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SD"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_HGH"
  
  #
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "ER"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_LOW"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "ER"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_2ND"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "ER"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_MID"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "ER"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_4TH"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "ER"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_HGH"
  
  #
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SO"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_LOW"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SO"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_2ND"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SO"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_MID"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SO"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_4TH"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SO"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_HGH"
  
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SS"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_LOW"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SS"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_2ND"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SS"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_MID"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SS"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_4TH"
  
  resp[nrow(resp)+1,] <- resp[nrow(resp),]
  resp[nrow(resp),]$RegionId <- "SS"
  resp[nrow(resp),]$IndicatorId <- "HC_WIXQ_P_HGH"
  
  # Get geometries
  
  list_geo <- list()
  
  iter = 1
  
  for (id in unique(resp$SurveyId)){
    
    print(iter/length(unique(resp$SurveyId)))
    
    list_geo[[iter]] <- read_sf(dhs_geometry(f="geoJSON", surveyIds = id))
    
    iter <- iter + 1
    
  }
  
  list_geo_bind <- rbind_list(list_geo)
  

  list_geo_bind <- dplyr::select(list_geo_bind, geometry, RegionID)

    world_bwa_sdn <- filter(world, world$ISO3=="BWA" | world$ISO3=="SDN" | world$ISO3=="ERI" | world$ISO3=="SOM" | world$ISO3=="SSD") %>% dplyr::select(geometry) %>% mutate(RegionID=c("BT", "ER", "SD", "SS",  'SO'))
    
    list_geo_bind <- bind_rows(list_geo_bind, world_bwa_sdn)
  
  # merge data and geoms
  
  resp <- merge(resp, list_geo_bind[!duplicated(list_geo_bind$RegionID),], by.x = "RegionId", by.y="RegionID", all.x=T)
  
  resp_na <- resp[is.na(resp$geometry),]
  resp_nna <- resp[!is.na(resp$geometry),]
  
  geometry <- read_sf("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/dhs/sdr_exports.gdb")
  
  geometry <- subset(geometry, ISO %in% cc$iso2c)
  
  resp_na$geometry=NULL
  
  geometry$geometry <- geometry$Shape
  st_geometry(geometry) <- "geometry"
  geometry <- dplyr::select(geometry, geometry, REG_ID)
  
  resp_na <- st_as_sf(merge(resp_na, geometry, by.x="RegionId", by.y="REG_ID", all.x=T))
  
  resp_nna <- st_as_sf(resp_nna)
  
  st_crs(resp_nna) <- st_crs(resp_na)
  
  resp <- rbind(resp_nna, resp_na)
  
  resp <- st_as_sf(resp)
  
  # geometries to provinces: where unavailable find a solution e.g. country-level average or parsing by name 
  
  geometry <- read_sf("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/dhs/sdr_exports.gdb")
  
  geometry <- subset(geometry, ISO %in% cc$iso2c)
  
  geometry$REG_ID <- substr(geometry$REG_ID, 10, 15)
  resp$CharacteristicId <- as.character(resp$CharacteristicId)
  
  geometry <- geometry[!geometry$REG_ID %in% resp$CharacteristicId, ] 
  
  geometry <- gather(geometry, "IndicatorId", "Value", 30:34)
  
  geometry <- dplyr::select(geometry, Shape, REG_ID, DHSCC, IndicatorId, Value)
  
  geometry$CharacteristicId <- geometry$REG_ID
  geometry$REG_ID <- NULL
  geometry$DHS_CountryCode <- geometry$DHSCC
  geometry$DHSCC <- NULL
  
  for ( i in colnames(resp)[c(1:5, 7:12, 14:16, 18, 20:27)]){
    geometry[i] <- NA
  }
  
  geometry$geometry <- geometry$Shape
  geometry$Shape <- NULL
  geometry <- st_as_sf(geometry)
  
  resp <- st_as_sf(rbind(resp, geometry))
  
  # MISSING BOTSWANA AND SUDAN
  
  # Filter for countries with only >=2 data points (so that you can extrapolate trends)
  #resp <- resp[ave(1:nrow(resp), resp$CharacteristicId, FUN = length) >=2 , ]
  
  resp$year = as.numeric(substr(resp$SurveyId, 3, 6))
  resp$year <- ifelse(is.na(resp$year), 2019, resp$year)
  # Create, for each province, variables of most recent value of wealth and its mean growth rate over time
  
  resp$DHS_CountryCode[resp$RegionId=="BT"] <- "BT"
  resp$DHS_CountryCode[resp$RegionId=="SD"] <- "SD"
  resp$DHS_CountryCode[resp$RegionId=="ER"] <- "ER"
  resp$DHS_CountryCode[resp$RegionId=="SO"] <- "SO"
  resp$DHS_CountryCode[resp$RegionId=="SS"] <- "SS"
  
  resp_nogeo <- resp
  resp_nogeo$geometry=NULL
  
  resp_sum <- resp_nogeo %>% dplyr::group_by(DHS_CountryCode, CharacteristicId, IndicatorId) %>% arrange(year) %>%  mutate(Growth = ifelse(!is.na(lag(Value)), (Value - lag(Value))/100, Value/100), diff_yrs = ifelse(!is.na(lag(Value)), year - lag(year), 999)) %>% ungroup()
  
  resp_sum$diff_yrs <- ifelse(resp_sum$diff_yrs==0, 1, resp_sum$diff_yrs)
  
  resp_sum$Growth <- ifelse(resp_sum$diff_yrs!=999, resp_sum$Growth / resp_sum$diff_yrs, NA)
  
  resp_sum <- dplyr::group_by(resp_sum, DHS_CountryCode, CharacteristicId, IndicatorId) %>% arrange(year) %>%  summarise(Growth=mean(Growth, na.rm=T), Value=last(na.omit(Value))) %>% ungroup()
  
  
  # Plot the evolution
  # ggplot(resp, aes(x=SurveyYear,y=Value,colour=CountryName)) +
  #   geom_point() +
  #   geom_smooth(method = "glm") +
  #   theme(axis.text.x = element_text(angle = 90, vjust = .5)) +
  #   ylab(resp$Indicator[1]) +
  #   facet_wrap(~CountryName,ncol = 6)
  
  ######
  
  # Get country-level PPP per-capita from SSPs
  
  ##
  
  for (ssp_sce in c("SSP2", "SSP1", "SSP3")){
  
  gdp <- readxl::read_xlsx("ssp_ppp_gdp.xlsx")
  
  gdp <- filter(gdp, Scenario==ssp_sce) %>% dplyr::select(Region, `2020.0`, `2050.0`) %>% group_by(Region) %>% summarise(gdp=mean(`2020.0`*1e9), gdp2050=mean(`2050.0`*1e9)) %>% ungroup()
  
  pop <- readxl::read_xlsx("ssp_pop.xlsx")
  
  pop <- filter(pop, Scenario==ssp_sce) %>% dplyr::select(Region, `2020.0`, `2050.0`) %>% group_by(Region) %>% summarise(pop=mean(`2020.0`*1e6), pop2050=mean(`2050.0`*1e6)) %>% ungroup()
  
  merger <- merge(gdp, pop, by="Region")
  
  merger[nrow(merger)+1,] <- merger[nrow(merger),]
  merger[nrow(merger),]$Region <- "SSD"
  merger[nrow(merger),]$pop <- 11*1e6
  merger[nrow(merger),]$pop2050 <- 22.6*1e6
  merger[nrow(merger),]$gdp <- 12*1e9
  merger[nrow(merger),]$gdp2050 <- merger[nrow(merger),]$gdp*(1+0.025)^30
    
  merger$gdp_per_capita_ppp_2050 <- merger$gdp2050/merger$pop2050
  merger$gdp_per_capita_ppp <- merger$gdp/merger$pop
  
  adjfactor = wb(indicator = "NY.GDP.DEFL.ZS", startdate = 1995, enddate = 2005) %>% filter(iso3c=="USA")
  adjfactor2 = adjfactor %>% rename(adj=value) %>% summarise(adj=adj[1]/adj[11])

  merger$PPPGDP2050_1995 <- merger$gdp_per_capita_ppp_2050 / adjfactor2$adj
  merger$PPPGDP_1995 <- merger$gdp_per_capita_ppp / adjfactor2$adj
  
  merger <- merger %>% dplyr::select(Region, PPPGDP2050_1995, PPPGDP_1995)
  
  ####
  
  # From country level-distribution of wealth "derive/proxy" PPP GDP at each quintile in each country at each survey year
  
  # Country-level wealth distribution
  
  resp_country <- resp %>% mutate(geometry=NULL)
  resp_country <- as_tibble(resp_country)
  resp_country <- group_by(resp_country, DHS_CountryCode, IndicatorId) %>% summarise(Value=NA)
  
  resp_country <- merge(resp_country, cc, by="DHS_CountryCode", by.y="DHS_CountryCode", all.x=T)
  
  resp_country$iso3c <- countrycode(resp_country$iso2c, 'iso2c', 'iso3c')
  
  resp_country <- merge(resp_country, merger, by.x="iso3c", by.y="Region", all.x=T)
  
  # assume 4th wealth quintile GDP value to coincide with PPP per-capita GDP in survey year
  
  resp_country$PPPGDP = ifelse(resp_country$IndicatorId=="HC_WIXQ_P_4TH", 1.25*resp_country$PPPGDP_1995, NA)
  resp_country$PPPGDP = ifelse(resp_country$IndicatorId=="HC_WIXQ_P_MID", 1*resp_country$PPPGDP_1995, resp_country$PPPGDP)
  resp_country$PPPGDP = ifelse(resp_country$IndicatorId=="HC_WIXQ_P_2ND", 0.75*resp_country$PPPGDP_1995, resp_country$PPPGDP)
  resp_country$PPPGDP = ifelse(resp_country$IndicatorId=="HC_WIXQ_P_LOW", 0.5*resp_country$PPPGDP_1995, resp_country$PPPGDP)
  resp_country$PPPGDP = ifelse(resp_country$IndicatorId=="HC_WIXQ_P_HGH", 1.5*resp_country$PPPGDP_1995, resp_country$PPPGDP)
  
  resp_country$PPPGDP_2050 = ifelse(resp_country$IndicatorId=="HC_WIXQ_P_4TH", 1.25*resp_country$PPPGDP2050_1995, NA)
  resp_country$PPPGDP_2050 = ifelse(resp_country$IndicatorId=="HC_WIXQ_P_MID", 1*resp_country$PPPGDP2050_1995, resp_country$PPPGDP_2050)
  resp_country$PPPGDP_2050 = ifelse(resp_country$IndicatorId=="HC_WIXQ_P_2ND", 0.75*resp_country$PPPGDP2050_1995, resp_country$PPPGDP_2050)
  resp_country$PPPGDP_2050 = ifelse(resp_country$IndicatorId=="HC_WIXQ_P_LOW", 0.5*resp_country$PPPGDP2050_1995, resp_country$PPPGDP_2050)
  resp_country$PPPGDP_2050 = ifelse(resp_country$IndicatorId=="HC_WIXQ_P_HGH", 1.5*resp_country$PPPGDP2050_1995, resp_country$PPPGDP_2050)
  
  # create DF of gdp PPP values with wealth quintile values by country
  
  resp_country <- dplyr::select(resp_country, PPPGDP, PPPGDP_2050, IndicatorId, DHS_CountryCode, iso2c)
  
  # 2) Project linearly based on historical growth rate of both country PPP GDP and wealth quintiles distribtuion change in each province, but keep as baseline the current wealth distribution to explicitly account for improvement

  resp_sum <- merge(resp_sum, resp_country, by.x=c("IndicatorId", "DHS_CountryCode"), by.y=c("IndicatorId", "DHS_CountryCode"), all.x=T)
  
  resp_sum$CharacteristicId[resp_sum$DHS_CountryCode=="BT"] <- "BT"
  resp_sum$CharacteristicId[resp_sum$DHS_CountryCode=="SD"] <- "SD"
  resp_sum$CharacteristicId[resp_sum$DHS_CountryCode=="ER"] <- "ER"
  resp_sum$CharacteristicId[resp_sum$DHS_CountryCode=="SO"] <- "SO"
  resp_sum$CharacteristicId[resp_sum$DHS_CountryCode=="SS"] <- "SS"
  
  colnames(resp_sum) <- c("IndicatorId", "DHS_CountryCode", "ProvinceId", "WealthDistrtrShift", "WealthPopShare", "PPPGDP", "PPPGDP_2050", 'iso2c')
  
  resp_sum$WealthPopShare <- resp_sum$WealthPopShare / 100
  
  # 2050 wealth distribution
  
  resp_sum$WealthPopShare[resp_sum$DHS_CountryCode=="BT" | resp_sum$DHS_CountryCode=="SD"| resp_sum$DHS_CountryCode=="ER"| resp_sum$DHS_CountryCode=="SO"| resp_sum$DHS_CountryCode=="SS"] <- 0.25
  resp_sum$WealthPopShare2050[resp_sum$DHS_CountryCode=="BT" | resp_sum$DHS_CountryCode=="SD"| resp_sum$DHS_CountryCode=="ER"| resp_sum$DHS_CountryCode=="SO"| resp_sum$DHS_CountryCode=="SS"] <- 0.25
  
  resp_sum$WealthPopShare2050 <- resp_sum$WealthPopShare*(1+resp_sum$WealthDistrtrShift)^30
  resp_sum$WealthPopShare2050 <- ifelse(is.na(resp_sum$WealthPopShare2050), resp_sum$WealthPopShare, resp_sum$WealthPopShare2050)
  resp_sum$WealthPopShare2050 <- ifelse(resp_sum$WealthPopShare2050 >1, 1, resp_sum$WealthPopShare2050)
  
  # 2050 GDP PPP
  
  resp_sum_avg <- resp_sum %>% group_by(iso2c, ProvinceId) %>% summarise(PPPGDP2050=sum(PPPGDP_2050*WealthPopShare2050), PPPGDP=sum(PPPGDP*WealthPopShare))
  
  
  
  # Isaac and Van Vuuren 
  # Availability of air conditioners
  # income = GDP per capita, in purchasing power parity (PPP) adjusted US dollars (1995)
  
  resp_single <- st_as_sf(resp[!duplicated(resp$geometry), ])
  
  resp_single$CharacteristicId[resp_single$RegionId=="BT"] <- "BT"
  resp_single$CharacteristicId[resp_single$RegionId=="SD"] <- "SD"
  resp_single$CharacteristicId[resp_single$RegionId=="ER"] <- "ER"
  resp_single$CharacteristicId[resp_single$RegionId=="SO"] <- "SO"
  resp_single$CharacteristicId[resp_single$RegionId=="SS"] <- "SS"
  
  # Add the geometry
  resp_sum_avg_geo <- merge(resp_sum_avg, resp_single, by.x="ProvinceId", by.y="CharacteristicId", all.x=T)
  
  resp_sum_avg_geo <- st_as_sf(resp_sum_avg_geo)
  
  # 
  
  resp_sum_countrymax <- resp_sum %>% group_by(iso2c) %>% summarise(PPPGDP_2050=max(PPPGDP_2050, na.rm = T))
  
  gadm0 <- read_sf('gadm_africa.shp')
  
  gadm0 <- merge(gadm0, resp_sum_countrymax, by.x="ISO2", by.y="iso2c")
  
  max<-fasterize(st_collection_extract(gadm0, "POLYGON"), overlay_current[[1]], "PPPGDP_2050", fun="first")
  
  PPPGDP2050<-fasterize(st_collection_extract(resp_sum_avg_geo, "POLYGON"), overlay_current[[1]], "PPPGDP2050", fun="first")
  
  PPPGDP2050<-overlay(PPPGDP2050, urbrur, max, fun=Vectorize(function(x,y,z){
    x[y==0]<-x
    x[y==1]<-z
    return(x)
  }))
  
  
  #
  
  resp_sum_countrymax <- resp_sum %>% group_by(iso2c) %>% summarise(PPPGDP=max(PPPGDP, na.rm = T))
  
  gadm0 <- read_sf('gadm_africa.shp')
  
  gadm0 <- merge(gadm0, resp_sum_countrymax, by.x="ISO2", by.y="iso2c")
  
  max<-fasterize(st_collection_extract(gadm0, "POLYGON"), overlay_current[[1]], "PPPGDP", fun="first")
  
  PPPGDP<-fasterize(st_collection_extract(resp_sum_avg_geo, "POLYGON"), overlay_current[[1]], "PPPGDP", fun="first")
  
  PPPGDP<-overlay(PPPGDP, urbrur, max, fun=Vectorize(function(x,y,z){
    x[y==0]<-x
    x[y==1]<-z
    return(x)
  }))
  
  #
  
  availability <- 1 / (1 + exp(4.152)*exp(-0.237*(PPPGDP2050/1000)))

  values(availability) <- ifelse(is.na(values(availability)) & values(urbrur)==1, mean(values(availability)[values(urbrur==1)], na.rm=T), ifelse(is.na(values(availability)) & values(urbrur)==0, mean(values(availability)[values(urbrur==0)], na.rm=T), values(availability)))
  
  pop_urban<-overlay(noacc18, urbrur, fun=function(x,y){
    x[y==0]<-NA
    return(x)
  })
  
  pop_rural<-overlay(noacc18, urbrur, fun=function(x,y){
    x[y==1]<-NA
    return(x)
  })
  
  # Obtain yearly CDDs at each grid cell
  CDD_yearly <- calc(scenario_climate, sum)
  
  # McNeil and Letschert  
  climate_maximum_saturation <-  1.00-0.949 * exp(-0.00187*CDD_yearly)
  
  penetration <- availability * climate_maximum_saturation
  
  penetration<-overlay(penetration, urbrur, fun=Vectorize(function(x,y){
    x[y==1]<-ifelse(x<0.25, 0.25, x)
    x[y==0]<- x 
    return(x)
  }))
  
  penetration_plot <- penetration

  ssa <- read_sf("gadm_africa.shp")
  st_crs(ssa) <- 4326
  
  penetration_plot <- rgis::fast_mask(penetration_plot, ssa)
  
  st_crs(gadm0) <- 4326
  
  ee <- extent(gadm0)
  ee@ymax <- 40
  
  penetration_plot <- crop(penetration_plot, ee)
  
  # Plot penetration
  
  my.at <- c(0, 0.05, 0.1, 0.25, 0.5, 0.75, 1)
  
  my.at.l <- c(">0", "5%", "10%", "25%", "50%", "75%", "100%")
  
  
  myColorkey <- list(at=my.at, ## where the colors change
                     labels=list(
                       labels=my.at.l, ## labels
                       at=my.at ## where to print labels
                     ))
  
  pal <- brewer.pal(6,"YlOrRd")
  mapTheme <- rasterTheme(region = pal)
  
  ext <- ee
  boundaries <- map('world', fill=TRUE,
                    xlim=ext[1:2], ylim=ext[3:4],
                    plot=FALSE)
  
  IDs <- sapply(strsplit(boundaries$names, ":"), function(x) x[1])
  bPols <- map2SpatialPolygons(boundaries, IDs=IDs,
                               proj4string=CRS(projection(penetration_plot)))
  
  mapTheme$fontsize$text<-8
  
  png(paste0("penetration_plot", ssp_sce, ".png"), width=1000, height=1000, res=150)
  print(levelplot(penetration_plot, xlim=c(ee@xmin, ee@xmax), ylim=c(ee@ymin, ee@ymax),
                  main=paste0("Projected air conditioning penetration rate in 2050, ", ssp_sce, " \nbased on the empirical availability-saturation model"), at=my.at, colorkey=myColorkey,  par.settings = mapTheme, xlab="Longitude", ylab="Latitude") + layer(sp.polygons(bPols)))
  dev.off()
  
      # 4) Use income elasticity average and (future) income level change to estimate growth in consumption of electricity; assume baseline consumption of levels of tiers 2-3 without AC and from there estimate future consumption
  
  # Elasticities
  
  # Arthur et al. (2012), Energy Economics
  # https://sci-hub.se/https://www.sciencedirect.com/science/article/pii/S0140988311001666
  
  # Price elasticity of electricity (Mozambique)
  # ???0.60
  
  # Income elasticity of electricity (Mozambique)
  # 0.69
  
  ##
  
  # Filippini and Pachauri (2004), Energy Policy
  # https://sci-hub.se/https://www.sciencedirect.com/science/article/abs/pii/S0301421502003142#:~:text=Dwelling%20size%20seems%20to%20significantly,this%20elasticity%20is%20approximately%200.2.
  
  # Price elasticity of electricity (India)
  # -0.42
  
  # Income elasticity of electricity (India)
  # 0.637
  
  
  # Tiwari and Menegaki (2019), Energy 
  # https://sci-hub.se/https://www.sciencedirect.com/science/article/abs/pii/S0360544219311727
  
  # Price elasticity of electricity (India)
  # -0.21
  
  # Income elasticity of electricity (India)
  # 0.41
  
  
  # Household Consumption of Electricity: An estimation of the price and income elasticity for pre-paid users in South Africa
  # https://open.uct.ac.za/bitstream/handle/11427/5759/thesis_com_2004_anderson_p.pdf?sequence=1
  
  # Price elasticity of electricity (South Africa)
  # -0.35
  
  # Income elasticity of electricity (South Africa)
  # 0.32
  
  #https://sci-hub.se/https://www.sciencedirect.com/science/article/abs/pii/S0301421511002758
  #https://sci-hub.se/https://www.sciencedirect.com/science/article/abs/pii/S030142151100382X
  #https://mpra.ub.uni-muenchen.de/103403/1/MPRA_paper_103403.pdf
  
  inc_elas = c(0.69, 0.637, 0.41, 0.32)
  
  baseline_t2=73 
  baseline_t3=365  
  baseline_t4=1250 
  
  baseline_c <- urbrur
  values(baseline_c) <- ifelse(values(baseline_c)==0, 365, ifelse(values(baseline_c)==1, 1250, NA))
  
  proj_elec_cons <- list()

  PPPGDP2050 <- rgis::fast_mask(ras=PPPGDP2050, mask=gadm0)
  PPPGDP <- rgis::fast_mask(ras=PPPGDP, mask=gadm0)
  baseline_c <- rgis::fast_mask(ras=baseline_c, mask=PPPGDP2050)
  
  a <- values(baseline_c)[!is.na(values(baseline_c))]
  #a[6918:6933] <- (365+1250)/2
  b <-  values(PPPGDP2050)[!is.na(values(PPPGDP2050))]
  c <-  values(PPPGDP)[!is.na(values(PPPGDP))]
  
  b <- ifelse(b==-Inf, 1, b)
  c <- ifelse(c==-Inf, 1, c)
  
  q1 <- quantile(merger$PPPGDP2050, 0.25)
  q2 <- quantile(merger$PPPGDP2050, 0.5)
  q3 <- quantile(merger$PPPGDP2050, 0.75)

  for (i in 1:length(a)){
    print(i/length(a) * 100)
    proj_elec_cons[i] <- uniroot(function(d1) (((d1 - a[i]) / (d1 + a[i])) / ((b[i] - c[i]) / (b[i] + c[i]))) -   ifelse(b[i]<=q1, inc_elas[1], ifelse(b[i]<=q2 & b[i]>q1, inc_elas[2],ifelse(b[i]<=q3 & b[i]>q2, inc_elas[3],inc_elas[4]))), c(0, 1000000000))$root
  }
  
  proj_elec_cons <- unlist(proj_elec_cons)[1:6917]
  values(baseline_c)[!is.na(values(baseline_c))] <- proj_elec_cons

  # if future consumption (estimated) > ACC consumption, fully met electricity; otherwise use the share and 
  
  ACconsumption_i_mediated <- baseline_c
  
  values(ACconsumption_i_mediated) <- ifelse(values(baseline_c)>=values(ACconsumption_i), values(ACconsumption_i), (values(baseline_c)/values(ACconsumption_i)) * values(ACconsumption_i))
  
  # Scenario 0: empirical
  kwh_S0 = FANconsumption_i * (1-penetration) + (ACconsumption_i_mediated * HHs_raster * penetration)
  world$kwh_S0 = exact_extract(kwh_S0, world, 'sum')
  
  colnames(world[length(colnames(world))]) <- paste0(colnames(world[length(colnames(world))]), ssp_sce)
  
  writeRaster(kwh_S0, paste0("kwh_S0_", RCP, ssp_sce, ".tif"), overwrite=T)
  
    # Unmet cooling risk map
  cooling_risk <- (ACconsumption_i / HHs_raster) - ACconsumption_i_mediated
  ext <- as.vector(extent(cooling_risk))
  boundaries <- map('worldHires', fill=TRUE,
                    xlim=ext[1:2], ylim=ext[3:4],
                    plot=FALSE)
  IDs <- sapply(strsplit(boundaries$names, ":"), function(x) x[1])
  bPols <- map2SpatialPolygons(boundaries, IDs=IDs,
                               proj4string=CRS(projection(CDDs)))

  my.at <- c(125, 250, 375, 500, 750, 1000, 1250, 1500, 2000, Inf)

  myColorkey <- list(at=my.at, ## where the colors change
                     labels=list(
                       labels=my.at, ## labels
                       at=my.at ## where to print labels
                     ))

  pal <- brewer.pal(9,"YlOrRd")
  mapTheme <- rasterTheme(region = pal)

  png("cooling_risk.png", width=1200, height=1600, res=150)
  print(levelplot(cooling_risk, xlim=c(-100, 180), ylim=c(-40, 45),
                  main="AC electricity demand gap due to income constraints", at=my.at, colorkey=myColorkey,  par.settings = mapTheme, xlab="Longitude", ylab="Latitude") + layer(sp.polygons(bPols)))
  dev.off()
  
  }
  
  ######################
  # Arbitrary scenarios
  
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
  
  writeRaster(kwh_S1, paste0("kwh_S1_", RCP, ".tif"), overwrite=T)
  
  # # Scenario 2: AC to 100% urban households and 40% wealthiest households in rural
  AC_demanding_pop_S2 <- merge(pop_urban/hhsize_raster*(q1+q2+q3+q4+q5)/100, pop_rural/hhsize_raster*(q4+q5)/100)
  values(AC_demanding_pop_S2) <- ifelse(values(pop_urban)>0 & is.na(values(q3)), values(pop_urban/hhsize_raster*1), values(AC_demanding_pop_S2))
  values(AC_demanding_pop_S2) <- ifelse(values(pop_rural)>0 & is.na(values(q3)), values(pop_rural/hhsize_raster*0.4), values(AC_demanding_pop_S2))
  FAN_demanding_pop_S2 <- noacc18/hhsize_raster - AC_demanding_pop_S2
  AC_demanding_share_S2 <- AC_demanding_pop_S2 / (AC_demanding_pop_S2 + FAN_demanding_pop_S2)
  FAN_demanding_share_S2 <- FAN_demanding_pop_S2 / (AC_demanding_pop_S2 + FAN_demanding_pop_S2)
  kwh_S2 = FANconsumption_i * FAN_demanding_share_S2 + ACconsumption_i * AC_demanding_share_S2
  world$kwh_S2 = exact_extract(kwh_S2, world, 'sum')
  
  writeRaster(kwh_S2, paste0("kwh_S2_", RCP, ".tif"), overwrite=T)
  
  # # Scenario 3 (benchmark): all AC
  AC_demanding_pop_S3 <- merge(pop_urban/hhsize_raster*(q1+q2+q3+q4+q5)/100, pop_rural/hhsize_raster*(q1+q2+q3+q4+q5)/100)
  values(AC_demanding_pop_S3) <- ifelse(values(pop_urban)>0 & is.na(values(q3)), values(pop_urban/hhsize_raster*1), values(AC_demanding_pop_S3))
  values(AC_demanding_pop_S3) <- ifelse(values(pop_rural)>0 & is.na(values(q3)), values(pop_rural/hhsize_raster*1), values(AC_demanding_pop_S3))
  FAN_demanding_pop_S3 <- noacc18/hhsize_raster - AC_demanding_pop_S3
  AC_demanding_share_S3 <- AC_demanding_pop_S3 / (AC_demanding_pop_S3 + FAN_demanding_pop_S3)
  FAN_demanding_share_S3 <- FAN_demanding_pop_S3 / (AC_demanding_pop_S3 + FAN_demanding_pop_S3)
  kwh_S3 = FANconsumption_i * FAN_demanding_share_S3 + ACconsumption_i * AC_demanding_share_S3
  world$kwh_S3 = exact_extract(kwh_S3, world, 'sum')
  
  writeRaster(kwh_S3, paste0("kwh_S3_", RCP, ".tif"), overwrite=T)
  
  # # Scenario 4 (benchmark): all fan
  AC_demanding_pop_S4 <- merge(pop_urban/hhsize_raster*(0)/100, pop_rural/hhsize_raster*(0)/100)
  values(AC_demanding_pop_S4) <- ifelse(values(pop_urban)>0 & is.na(values(q3)), values(pop_urban/hhsize_raster*0), values(AC_demanding_pop_S4))
  values(AC_demanding_pop_S4) <- ifelse(values(pop_rural)>0 & is.na(values(q3)), values(pop_rural/hhsize_raster*0), values(AC_demanding_pop_S4))
  FAN_demanding_pop_S4 <- noacc18/hhsize_raster - AC_demanding_pop_S4
  AC_demanding_share_S4 <- AC_demanding_pop_S4 / (AC_demanding_pop_S4 + FAN_demanding_pop_S4)
  FAN_demanding_share_S4 <- FAN_demanding_pop_S4 / (AC_demanding_pop_S4 + FAN_demanding_pop_S4)
  kwh_S4 = FANconsumption_i * FAN_demanding_share_S4 + ACconsumption_i * AC_demanding_share_S4
  world$kwh_S4 = exact_extract(kwh_S4, world, 'sum')
  
  writeRaster(kwh_S4, paste0("kwh_S4_", RCP, ".tif"), overwrite=T)
  
  # add S0 for the different SSPS
  
  # melt by scenario
  world_out = gather(world, "scenario", "kwh", kwh_S0, kwh_S1, kwh_S2, kwh_S3, kwh_S4)
  
  world_out$geometry=NULL
  
  all_results[[k]] = world_out
  k = k+1
  gc()
}

world = rbindlist(all_results, idcol = T)
world$id = world$.id
world$id = ifelse(world$id==1, "Baseline", ifelse(world$id==2, "SSP245", "SSP370"))

world = subset(world, world$kwh!=0)

countries_without = world
countries_without$geometry=NULL

summary_electricity <- countries_without %>% dplyr::group_by(scenario, id) %>% dplyr::summarise(twh = sum(kwh, na.rm = T)/1000000000)

write.csv(summary_electricity, paste0("summary_power_consumpion_", base_temp, "_", EER_urban, "_", EER_rural, ".csv"))

world_plot = world %>% dplyr::group_by(id, scenario, continent) %>% dplyr::mutate(kwh=sum(kwh, na.rm = T))

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

ggsave(paste0("kwh_region_", base_temp, ".png"), kwh_country, device="png", height = 6, scale=0.8)

write.csv(world_plot, paste0("power_consumpion_", base_temp, "_", EER_urban, "_", EER_rural, ".csv"))

# my.at <- c(125, 250, 375, 500, 750, 1000, 1250, 1500, 2000, Inf)
# 
# myColorkey <- list(at=my.at, ## where the colors change
#                    labels=list(
#                      labels=my.at, ## labels
#                      at=my.at ## where to print labels
#                    ))
# 
# pal <- brewer.pal(9,"YlOrRd")
# mapTheme <- rasterTheme(region = pal)
# 
# 
# p <- raster("kwh_S2_baseline.tif") / HHs_raster
# 
# png("kwh_S2_baseline_plot.png", width=1200, height=1000, res=150)
# print(levelplot(p, xlim=c(-100, 180), ylim=c(-40, 45),
#                 main="Avg. yearly cooling electricity need / HH, base T 26° C, 2041-2060, baseline, S2", at=my.at, colorkey=myColorkey,  par.settings = mapTheme, xlab="Longitude", ylab="Latitude", ncol=2) + layer(sp.polygons(bPols)))
# dev.off()
# 
# p <- raster("kwh_S2_245.tif") / HHs_raster
# 
# png("kwh_S2_245_plot.png", width=1200, height=1000, res=150)
# print(levelplot(p, xlim=c(-100, 180), ylim=c(-40, 45),
#                 main="Avg. yearly cooling electricity need / HH, base T 26° C, 2041-2060, SSP245, S2", at=my.at, colorkey=myColorkey,  par.settings = mapTheme, xlab="Longitude", ylab="Latitude", ncol=2) + layer(sp.polygons(bPols)))
# dev.off()
# 
# 
# p <- raster("kwh_S2_370.tif") / HHs_raster
# 
# png("kwh_S2_370_plot.png", width=1200, height=1000, res=150)
# print(levelplot(p, xlim=c(-100, 180), ylim=c(-40, 45),
#                 main="Avg. yearly cooling electricity need / HH, base T 26° C, 2041-2060, SSP370, S2", at=my.at, colorkey=myColorkey,  par.settings = mapTheme, xlab="Longitude", ylab="Latitude", ncol=2) + layer(sp.polygons(bPols)))
# dev.off()


