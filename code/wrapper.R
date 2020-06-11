#Wrapper

library(tidyverse)
library(reshape2)
library(lubridate)
library(raster)
library(sf)
library(exactextractr)
library(countrycode)
library(rasterVis)
library(maps)
library(mapdata)
library(maptools)
library(rgdal)
library(gglorenz)
library(fasterize)
library(viridis)
library(data.table)

setwd('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA')

# parameters

base_temp = 26

########

avg_house_area_urban <- 60 #sq m.
avg_house_area_rural <- 100 #sq m.
share_house_cooled_urban = 0.80
share_house_cooled_rural = 0.35
avg_house_volume_urban <- avg_house_area_urban * 2.5 * share_house_cooled_urban #m3
avg_house_volume_rural <- avg_house_area_rural * 3 * share_house_cooled_rural #m3
m2_per_Cton = 45
CC_urban = avg_house_area_urban*share_house_cooled_urban/m2_per_Cton
CC_rural = avg_house_area_rural*share_house_cooled_rural/m2_per_Cton
cooling_ton_to_kw = 3.51685
kw_to_j_per_hour = 3600000
m3toliters = 1000
EER_rural = 2.2
EER_urban = 2.9

heating_loss_factor_urban = 1.15 
heating_loss_factor_rural = 1.25

#####

Fan_power = 70
min_hrs_permonth_fan_use = 0
max_hrs_permonth_fan_use = 480

# process the CDD and noaccess data (default base T)
#source("code/data_process.R", echo=T)

# process the CDD and noaccess data (to produce variants with different base T)
source("code/data_process_2.R", echo=T)

# generate Figures 1-2-3
source("code/figures123.R", echo=T)

# estimate power requirements
source("code/electricity.R", echo=T)

# estimate co2 emissions
source("code/emissions.R", echo=T)

# Sensitivity analysis
source("code/sensitivity.R", echo=T)


