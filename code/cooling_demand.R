library(utils)
library(tidyverse)
require(httr)
library(data.table)
library(raster)
library(RColorBrewer)
library(sp)
library(maps)
library(mapdata)
library(maptools)
library(rasterVis)
library(ncdf4)
library(sf)
library(rgdal)
library(lubridate)
library(reshape2)
library(exactextractr)
library(randomForestSRC)

#############
# Calculate CDDs #
############

# Base T for CDD calculation
base_temp = 26

# Scrape RCP 4.5 and 6 data (avg, max, min T in each month) at each 0.5° pixel in SSA
maxTimes <- 10

#
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/Raw")

# p = read_csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/csvs/ponts05ssa.csv")
# 
# minmax<-c("", "min", "max")
# rcps<-c("45", "60")
# 
# for (k in minmax){
#   for (i in rcps){
#     webscrape<-function(X,Y){
#       lol <- paste0('https://climateknowledgeportal.worldbank.org/api/data/get-download-data/projection/mavg/tas', k, '/rcp', i ,'/2040_2059/',Y,'$cckp$',X,'/',Y,'$cckp$',X)
#       destfile<-paste0('tas', k, '_2040_2059_mavg_rcp', i, '_', X ,'_', Y, ".csv")
#       #download.file(lol, destfile, method="wininet", quiet = FALSE)
#       GET(verb = "GET", write_disk(path=destfile, overwrite=TRUE), url = lol, times = maxTimes,
#           quiet = FALSE)
#     }
#     mapply(webscrape,as.character(p$X),as.character(p$Y))
#   }}
# 

####################
# Process the scraped data#
####################

fncols <- function(data, cname) {
  add <-cname[!cname%in%names(data)]
  
  if(length(add)!=0) data[add] <- NA
  data
}

processer <-function(X){
  file <- fread(X) %>% as_tibble(.)
  file <-fncols(file, "Monthly Min-Temperature - (Celsius)")
  file <-fncols(file, "Monthly Max-Temperature - (Celsius)")
  file <-fncols(file, "Monthly Temperature - (Celsius)")
  file <- file %>% group_by(Year, Statistics, Longitude, Latitude) %>%  summarise(avg = median(`Monthly Temperature - (Celsius)`, na.rm = TRUE), min = median(`Monthly Min-Temperature - (Celsius)`, na.rm = TRUE), max = median(`Monthly Max-Temperature - (Celsius)`, na.rm = TRUE))
  file <- file[,colSums(is.na(file))<nrow(file)]
  file$Longitude = round(file$Longitude, digits = 2)
  file$Latitude = round(file$Latitude, digits = 2)
  file$Variable<-colnames(as.data.frame(file)[5])
  file$RCP = ifelse(grepl("rcp45", X) == TRUE, "4.5", "6.0")
  file = dplyr::rename(file, "Measurement"=5)
  file
}

list <- list.files(path="D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/Raw", pattern = "*.csv")

processed <- lapply(list, processer)
processed2 <- do.call(rbind, processed)

processed3<- spread(processed2, Variable, Measurement)

processed3$CDD = 30 * ifelse(processed3$max<=base_temp, 0, ifelse( (processed3$avg<=base_temp) & (base_temp<processed3$max), (processed3$max-base_temp)/4, ifelse((processed3$min<=base_temp) & (base_temp<processed3$avg), ((processed3$max-base_temp)/2 - (base_temp-processed3$min)/4), processed3$avg-base_temp)))

processed3$Statistics = gsub(" Average", "", processed3$Statistics)

processed3$Statistics = match(processed3$Statistics,month.abb)


# Produce RCP 4.5 CDD raster
fun_raster <- function(X){
  matrix = processed3 %>% filter(Statistics==X) %>% filter(RCP=="4.5") %>% ungroup() %>% dplyr::select(Longitude, Latitude, CDD)
  raster = rasterFromXYZ(matrix ,res=c(0.5, 0.5), crs=4326, digits = 2)
  raster
}

raster <- lapply(c(1:12), fun_raster)
raster_rcp_45 <- stack(raster)

# my.at <- c(30, 60, 120, 240, 480)
# 
# myColorkey <- list(at=my.at, ## where the colors change
#                    labels=list(
#                      at=my.at ## where to print labels
#                    ))
# 
# 
 names(raster_rcp_45) <- month.abb
# 
# 
# ext <- as.vector(extent(raster_rcp_45))
# boundaries <- map('worldHires', fill=TRUE,
#                   xlim=ext[1:2], ylim=ext[3:4],
#                   plot=FALSE)
# IDs <- sapply(strsplit(boundaries$names, ":"), function(x) x[1])
# bPols <- map2SpatialPolygons(boundaries, IDs=IDs,
#                              proj4string=CRS(projection(raster_rcp_45)))
# 
# # Save plot
# 
# png("CDD_2040_2060_45.png", width=1600, height=800, res=150)
# print(levelplot(raster_rcp_45,
#                 main="CDDs, base T 26° C, RCP 4.5, year 2050", at=my.at, colorkey=myColorkey,  par.settings = YlOrRdTheme, xlab="Longitude", ylab="Latitude") + layer(sp.polygons(bPols)))
# dev.off()


# Produce RCP 6.0 CDD raster
fun_raster <- function(X){
  matrix = processed3 %>% filter(Statistics==X) %>% filter(RCP=="6.0") %>% ungroup() %>% dplyr::select(Longitude, Latitude, CDD)
  raster = rasterFromXYZ(matrix ,res=c(0.5, 0.5), crs=4326, digits = 2)
  raster
}

raster <- lapply(c(1:12), fun_raster)
raster_rcp_60 <- stack(raster)

my.at <- c(30, 60, 120, 240, 480)

myColorkey <- list(at=my.at, ## where the colors change
                   labels=list(
                     at=my.at ## where to print labels
                   ))


names(raster_rcp_60) <- month.abb

# 
# ext <- as.vector(extent(raster_rcp_60))
# boundaries <- map('worldHires', fill=TRUE,
#                   xlim=ext[1:2], ylim=ext[3:4],
#                   plot=FALSE)
# IDs <- sapply(strsplit(boundaries$names, ":"), function(x) x[1])
# bPols <- map2SpatialPolygons(boundaries, IDs=IDs,
#                              proj4string=CRS(projection(raster_rcp_60)))
# 
# 
# # Save plot
# png("CDD_2040_2060_60.png", width=1600, height=800, res=150)
# print(levelplot(raster_rcp_60,
#                 main="CDDs, base T 26° C, RCP 6.0, year 2050", at=my.at, colorkey=myColorkey,  par.settings = YlOrRdTheme, xlab="Longitude", ylab="Latitude") + layer(sp.polygons(bPols)))
# dev.off()


###########
# Compare future with with historical RCPs #
###########

# avg<- brick("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/cru_ts4.03.1901.2018.tmp.dat.nc")
# max<- brick("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/cru_ts4.03.1901.2018.tmx.dat.nc")
# min<- brick("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/cru_ts4.03.1901.2018.tmn.dat.nc")
#   
# st_as_sf(read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/ponts05ssa.csv"), coords=c("X", "Y"), crs=4326) %>% write_sf(., "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/ponts05ssa.shp")
# 
# sf<-readOGR("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/ponts05ssa.shp")
# 
# avg<-raster::extract(avg, sf, fun=mean, na.rm=TRUE)
# max<-raster::extract(max, sf, fun=mean, na.rm=TRUE)
# min<-raster::extract(min, sf, fun=mean, na.rm=TRUE)
# 
# 
# avg=as.data.frame(avg)
# id = sf$id
# avg = cbind(avg, id)
# avg<-melt(avg,measure.vars=names(avg)[1:length(names(avg))], id.vars ="id")
# avg$date<-substr(avg$variable,2,11)
# avg$date = as.Date(avg$date, format="%Y.%m.%d")
# avg$month = month(avg$date)
# avg$year = year(avg$date)
# avg = subset(avg, avg$year>1999)
# avg = dplyr::group_by(avg, id, month) %>% dplyr::summarise(value=mean(value, na.rm=TRUE)) %>% dplyr::ungroup()
# avg = avg[complete.cases(avg), ]
# 
# max=as.data.frame(max)
# id = sf$id
# max = cbind(max, id)
# max<-melt(max,measure.vars=names(max)[1:length(names(max))], id.vars ="id")
# max$date<-substr(max$variable,2,11)
# max$date = as.Date(max$date, format="%Y.%m.%d")
# max$month = month(max$date)
# max$year = year(max$date)
# max = subset(max, max$year>1999)
# max = dplyr::group_by(max, id, month) %>% dplyr::summarise(value=mean(value, na.rm=TRUE)) %>% dplyr::ungroup()
# max = max[complete.cases(max), ]
# 
# min=as.data.frame(min)
# id = sf$id
# min = cbind(min, id)
# min<-melt(min,measure.vars=names(min)[1:length(names(min))], id.vars ="id")
# min$date<-substr(min$variable,2,11)
# min$date = as.Date(min$date, format="%Y.%m.%d")
# min$month = month(min$date)
# min$year = year(min$date)
# min = subset(min, min$year>1999)
# min = dplyr::group_by(min, id, month) %>% dplyr::summarise(value=mean(value, na.rm=TRUE)) %>% dplyr::ungroup()
# min = max[complete.cases(min), ]
# 
# gc()
# all = Reduce(function(x,y) merge(x,y,by=c("id", "month")) ,list(avg, max, min))
# 
# colnames(all) <- c("id", "month", "avg", "max", "min")
# 
# all$CDD = 30 * ifelse(all$max<=base_temp, 0, ifelse( (all$avg<=base_temp) & (base_temp<all$max), (all$max-base_temp)/4, ifelse((all$min<=base_temp) & (base_temp<all$avg), ((all$max-base_temp)/2 - (base_temp-all$min)/4), all$avg-base_temp)))
# 
# all$RCP="Historical"
# 
# all = merge(all, read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/Climate data/ponts05ssa.csv"), by="id")
# all$X = round(all$X, digits = 2)
# all$Y = round(all$Y, digits = 2)
# 
# prova_merge = merge(processed3, all, by.x=c("Statistics", "Longitude", "Latitude"), by.y=c("month", "X", "Y"), all=TRUE)
# 
# 
# ##
# #Plot historical
# ##
# 
# fun_raster <- function(X){
#   matrix = prova_merge %>% filter(Statistics==X) %>% filter(RCP.x=="6.0") %>% ungroup() %>% dplyr::select(Longitude, Latitude, CDD.y)
#   raster = rasterFromXYZ(matrix ,res=c(0.5, 0.5), crs=4326, digits = 2)
#   raster
# }
# 
# raster <- lapply(c(1:12), fun_raster)
# raster <- stack(raster)
# 
# my.at <- c(30, 60, 120, 240, 480)
# 
# myColorkey <- list(at=my.at, ## where the colors change
#                    labels=list(
#                      at=my.at ## where to print labels
#                    ))
# 
# 
# names(raster) <- month.abb
# 
# 
# ext <- as.vector(extent(raster))
# boundaries <- map('worldHires', fill=TRUE,
#                   xlim=ext[1:2], ylim=ext[3:4],
#                   plot=FALSE)
# IDs <- sapply(strsplit(boundaries$names, ":"), function(x) x[1])
# bPols <- map2SpatialPolygons(boundaries, IDs=IDs,
#                              proj4string=CRS(projection(raster)))
# 
# png("CDD_historical.png", width=1600, height=800, res=150)
# print(levelplot(raster,
#                 main="CDDs, base T 26° C, 1901-2018", at=my.at, colorkey=myColorkey,  par.settings = YlOrRdTheme, xlab="Longitude", ylab="Latitude") + layer(sp.polygons(bPols)))
# dev.off()
# 
# 
# ##
# #Plot % difference with rcp6
# ##
# 
# fun_raster <- function(X){
#   matrix = prova_merge %>% filter(Statistics==X) %>% filter(RCP.x=="6.0") %>% ungroup() %>% dplyr::select(Longitude, Latitude, CDD.y, CDD.x) %>% mutate(CDD.x=(CDD.x-CDD.y)) %>% dplyr::select(Longitude, Latitude, CDD.x)
#   raster = rasterFromXYZ(matrix ,res=c(0.5, 0.5), crs=4326, digits = 2)
#   raster
# }
# 
# raster <- lapply(c(1:12), fun_raster)
# raster <- stack(raster)
# 
# my.at <- c(0, 30, 60, 120, 240, 480)
# 
# myColorkey <- list(at=my.at, ## where the colors change
#                    labels=list(
#                      at=my.at ## where to print labels
#                    ))
# 
# names(raster) <- month.abb
# 
# 
# ext <- as.vector(extent(raster))
# boundaries <- map('worldHires', fill=TRUE,
#                   xlim=ext[1:2], ylim=ext[3:4],
#                   plot=FALSE)
# IDs <- sapply(strsplit(boundaries$names, ":"), function(x) x[1])
# bPols <- map2SpatialPolygons(boundaries, IDs=IDs,
#                              proj4string=CRS(projection(raster)))
# 
# png("CDD_historical_rcp6_diff.png", width=1600, height=800, res=150)
# print(levelplot(raster,
#                 main="CDDs, base T 26° C, diff. RCP 6 - 2000-2018", at=my.at, colorkey=myColorkey,  par.settings = YlOrRdTheme, xlab="Longitude", ylab="Latitude") + layer(sp.polygons(bPols)))
# dev.off()


#############
# Produce cooling demand drivers file #
############

# import 1*1 km gird for entire SSA
grid<- read_sf("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/shapefiles/grid_1km_SSA.shp")
grid <-dplyr::select(grid, id, geometry) %>% st_as_sf(.)

# import HRSL population layer for 2015
pop<-raster('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Inequal accessibility to services in sub-Saharan Africa/population_cropped_1209.tif')

# simulate pop. growth and migration until 2030
# urbrur = raster('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Inequal accessibility to services in sub-Saharan Africa/urbanrural_cut_1209.tif')
# 
# pop <- aggregate(pop, fact=5, fun=sum, na.rm=TRUE)
# urbrur <- aggregate(urbrur, fact=5, fun=modal, na.rm=TRUE)
# 
# merged = stack(pop, urbrur)
# merger = as.data.frame(rasterToPoints(merged))
# 
# # Population in 2030 #
# pop2030= 1396853255
# pop2018 = sum(merger$population_cropped_1209, na.rm = TRUE)
# 
# popr = pop2030/pop2018
# 
# urb2030 = 0.5
# rur2030 = 0.5
# 
# # 42% urb, which is consistent with world bank urban population
# urb2018 = sum(merger$population_cropped_1209[merger$urbanrural_cut_1209>=30], na.rm = TRUE)/sum(merger$population_cropped_1209, na.rm = TRUE)
# rur2018 = sum(merger$population_cropped_1209[merger$urbanrural_cut_1209>=11 & merger$urbanrural_cut_1209<=23], na.rm = TRUE)/sum(merger$population_cropped_1209, na.rm = TRUE)
# 
# uu = urb2030/urb2018
# rr = rur2030/rur2018
# 
# #only allow population to grow in cells which are already populated
# merger$id = seq.int(nrow(merger))
# merger2 = subset(merger, merger$population_cropped_1209>0)
# 
# merger2$pop=ifelse(merger2$urbanrural_cut_1209>=30, popr*merger2$population_cropped_1209*uu, ifelse(merger2$urbanrural_cut_1209>=11 & merger2$urbanrural_cut_1209<=23, popr*merger2$population_cropped_1209*rr, 0))
# 
# # check consistency
# if(sum(merger2$pop, na.rm = TRUE)==1396853255){
#   print("Matching!")
# } else print("No matching!")
# 
# merger2 = merger2 %>% dplyr::select(pop, id) %>% as.data.frame()
# 
# #rm(list = ls()[!ls() %in% c("merger", "merger2", "pop")])
# 
# merger = as.data.table(merger)
# merger2 = as.data.table(merger2)
# 
# merger = merge(merger, merger2, by="id", all = TRUE)
# merger = as.data.frame(merger)
# merger$pop[ is.na(merger$pop) | merger$pop==0 ] <- merger$population_cropped_1209[ is.na(merger$pop) | merger$pop==0]
# 
# merger$pop[is.na(merger$pop)]<-0
# 
# pop_bk = rasterize(x=data.matrix(merger[2:3]), y=pop, field=as.vector(merger$pop), background=NA, filename="pop2030.tif")
# rm(list = ls()[!ls() %in% c("pop_bk")])

# import HRSL population layer for 2030 (pop growth and migration)
pop2030<-raster('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Inequal accessibility to services in sub-Saharan Africa/pop2030.tif')

# extract 2030 pop. into grid
pop2030 <- aggregate(pop2030, fact=2, fun=sum, na.rm=TRUE)
grid$pop2030 <- exact_extract(pop2030, grid, 'sum', progress=TRUE)

#save the environment
save.image(file="grid_with_pop.Rdata")

# extract country of belonging and wealth distribution in each cell
dhs_wealth <- read_sf("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Prod_Uses_Agriculture/PrElGen_database_SSA/statcompiler_subnational_data_2020-03-17/shapefiles/sdr_subnational_data_dhs_2015.shp")

# how to cope with countries with lack of data? 

dhs_wealth <- dplyr::select(dhs_wealth, ISO, geometry, HCWIXQPLOW, HCWIXQP2ND, HCWIXQPMID, HCWIXQP4TH, HCWIXQPHGH) %>% st_as_sf(.)

colnames(dhs_wealth) <- c("ISO", "geometry", "n1", "n2", "n3", "n4", "n5")

grid_2 <- st_join(grid, dhs_wealth, join = st_intersects)

# import rural/urban
urbrur = raster('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Inequal accessibility to services in sub-Saharan Africa/urbanrural_cut_1209.tif')

grid_2$urbrur <- exact_extract(urbrur, grid_2, 'mode', progress=TRUE)
grid_2$urban <- ifelse(grid_2$urbrur>13, 1, 0)
grid_2$urban <- ifelse(grid_2$urbrur==-1, NA, grid_2$urban)

# multinomial ML with urb/rur and traveltime to predict values
traveltime <- raster('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Regulatory quality/Gridded sources/Traveltime/2015_accessibility_to_cities_v1.0.tif')

grid_2$traveltime_city <- exact_extract(traveltime, grid_2, 'mean', progress=TRUE)

save.image(file="grid_bk.Rdata")

# grid_2_reg = dplyr::select(grid_2, traveltime_city, urban, n1, n2, n3, n4, n5, pop2030) %>% as.data.frame()
# grid_2_reg$geometry = NULL
# grid_2_reg = grid_2_reg[complete.cases(grid_2_reg), ]
# 
# summary(lm(formula=cbind(n1, n2, n3, n4, n5)  ~ ., data=train.hex))
# 
# # Partition data
# splitSample <- sample(1:2, size=nrow(grid_2_reg), prob=c(0.7,0.3), replace = TRUE)
# train.hex <- grid_2_reg[splitSample==1,]
# test.hex <- grid_2_reg[splitSample==2,]
# 
# rm(list=setdiff(ls(), c("train.hex", "test.hex")))
# gc()
# 
# # Find a way to run this effectively
# pr = rfsrc(Multivar(n1, n2, n3, n4, n5)~ . ,data = train.hex, importance=T)
# 
# prediction <- predict.rfsrc(pr, test.hex)
# 
# test.hex$n1_forecasted = prediction$regrOutput$n1$predicted
# test.hex$n2_forecasted = prediction$regrOutput$n2$predicted
# test.hex$n3_forecasted = prediction$regrOutput$n3$predicted
# test.hex$n4_forecasted = prediction$regrOutput$n4$predicted
# test.hex$n5_forecasted = prediction$regrOutput$n5$predicted
# 
# # R2 for test (= test accuracy)
# formula<-"n1 ~ n1_forecasted"
# ols1<-lm(formula,data=test.hex)
# summary(ols1, robust=TRUE)  
# formula<-"n2 ~ n2_forecasted"
# ols1<-lm(formula,data=test.hex)
# summary(ols1, robust=TRUE)  
# formula<-"n3 ~ n3_forecasted"
# ols1<-lm(formula,data=test.hex)
# summary(ols1, robust=TRUE)  
# formula<-"n4 ~ n4_forecasted"
# ols1<-lm(formula,data=test.hex)
# summary(ols1, robust=TRUE)  
# formula<-"n5 ~ n5_forecasted"
# ols1<-lm(formula,data=test.hex)
# summary(ols1, robust=TRUE)  
# 
# # use predicted values for obs where you have NA
# 
# grid_2$n1 = ifelse(is.na(grid_2$n1), prediction$regrOutput$n1$predicted, grid_2$n1)
# grid_2$n2 = ifelse(is.na(grid_2$n2), prediction$regrOutput$n1$predicted, grid_2$n2)
# grid_2$n3 = ifelse(is.na(grid_2$n3), prediction$regrOutput$n1$predicted, grid_2$n3)
# grid_2$n4 = ifelse(is.na(grid_2$n4), prediction$regrOutput$n1$predicted, grid_2$n4)
# grid_2$n5 = ifelse(is.na(grid_2$n5), prediction$regrOutput$n1$predicted, grid_2$n5)

grid = grid_2

# extract CDDs for 4.5 and 6 in each pixel
for (i in c(1:12)){
grid[,paste0("CDDs45_2050_", i)] <- exact_extract(raster_rcp_45[[i]], grid, 'mean', progress=TRUE)
grid[,paste0("CDDs60_2050_", i)] <- exact_extract(raster_rcp_60[[i]], grid, 'mean', progress=TRUE)
}

save.image(file="grid_bk2.Rdata")

# calculate average number of people in each household based on country and urban/rural
hhsize <- readxl::read_xlsx("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/csvs/population_division_UN_Houseshold_Size_and_Composition_2019.xlsx", sheet="UN HH Size and Composition 2019")

hhsize <- hhsize %>% group_by(`Country or area`) %>% slice(which.max(as.Date(`Reference date (dd/mm/yyyy)`, '%d/%m/%Y'))) %>% ungroup()

hhsize$ISO = countrycode::countrycode(hhsize$`Country or area`, 'country.name', 'iso3c')

hhsize = hhsize %>% dplyr::select(ISO, `Average household size (number of members)`)

isos_ssa = unique(dhs_wealth$ISO)
isos_ssa = countrycode::countrycode(isos_ssa, 'iso2c', 'iso3c')

diff <-setdiff(isos_ssa, hhsize$ISO)

more.rows <- data.frame(ISO=diff, `Average household size (number of members)`=NA, stringsAsFactors=F)

colnames(more.rows)[2] <- "Average household size (number of members)"

hhsize<-bind_rows(hhsize, more.rows)

hhsize$`Average household size (number of members)` <- ifelse(hhsize$`Average household size (number of members)` =="..", NA, hhsize$`Average household size (number of members)`)

hhsize$`Average household size (number of members)`=as.numeric(hhsize$`Average household size (number of members)`)

hhsize = hhsize[hhsize$ISO %in% isos_ssa, ]

hhsize$`Average household size (number of members)` <- ifelse(is.na(hhsize$`Average household size (number of members)`), mean(hhsize$`Average household size (number of members)`, na.rm=TRUE), hhsize$`Average household size (number of members)`)

hhsize$ISO = countrycode::countrycode(isos_ssa, 'iso3c', 'iso2c')

grid = merge(grid, hhsize, by.x="ISO", by.y="ISO")

grid$hhs = grid$pop2030/grid$`Average household size (number of members)`

#save the environment
save.image(file="processed_CDDs_drivers.Rdata")
rm(list=setdiff(ls(), c("grid")))
gc()

#########
# Simulate penetration of technologies based on CDDs, wealth, and urb/rur
##########

# Scenario 1: households above 50th percentile of wealth in the country and all urban households -> air conditioning; rural households below 50th percentile -> fan

grid$AC_demanding_pop_S1 = ifelse(grid$urban==1, grid$hhs, (grid$n3/100/2 + grid$n4/100 + grid$n5/100)* grid$hhs)
grid$FAN_demanding_pop_S1 = grid$hhs - grid$AC_demanding_pop_S1

grid$AC_demanding_share_S1 = grid$AC_demanding_pop_S1 / (grid$AC_demanding_pop_S1 + grid$FAN_demanding_pop_S1)

grid$FAN_demanding_share_S1 = grid$FAN_demanding_pop_S1 / (grid$AC_demanding_pop_S1 + grid$FAN_demanding_pop_S1)


# Scenario 2: ...





######
# Theoretical model of tech unit sizing for CDD demand by AC/FAN
#####





######
# Empirical model of energy demand to meet CDD demand by AC/FAN
#####



