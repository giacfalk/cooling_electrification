# Wrapper for:
# The role of residential air circulation and cooling demand for electrification planning: implications of climate change over sub-Saharan Africa
# Giacomo Falchetta, gldas Mistry
# 27/01/2021

# install.packages(c("tidyverse", "reshape2", "lubridate", "raster", "sf", "exactextractr", "countrycode", "rasterVis", "maps", "mapdata", "maptools", "rgdal", "gglorenz", "fasterize", "viridis", "data.table", "oce", "osc", "lutz", "suncalc", "rstudioapi", "cowplot", "rdhs", "wbstats", "pracma"))

library(tidyverse)
library(tidyr)
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
library(oce)
library(osc)
library(lutz)
library(suncalc)
library(rstudioapi)
library(cowplot)
library(rdhs)
library(wbstats)
library(pracma)

setwd('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA')

# DHS API configuration

set_rdhs_config(email = "giacomo.falchetta@feem.it", timeout = 120)


# parameters

base_temp = 26 # Celsius degres, confort temperature

########

# Building parameters
avg_house_area_urban <- 60 #sq m.
avg_house_area_rural <- 100 #sq m.
share_house_cooled_urban = 0.80 #%
share_house_cooled_rural = 0.35 #%
m2_windows_urban <- 10 # area of windows in cooled space
m2_windows_rural <- 15 # area of windows in cooled space
k_solar_heat_gain  <- 0.4 # coefficient
avg_house_volume_urban <- avg_house_area_urban * 2.5 * share_house_cooled_urban #m3
avg_house_volume_rural <- avg_house_area_rural * 3 * share_house_cooled_rural #m3

# AC parameters
m2_per_Cton = 45
CC_urban = avg_house_area_urban*share_house_cooled_urban/m2_per_Cton
CC_rural = avg_house_area_rural*share_house_cooled_rural/m2_per_Cton
cooling_ton_to_kw = 3.51685
kw_to_j_per_hour = 3600000
m3toliters = 1000
EER_rural = 2.2
EER_urban = 2.9

# Fan parameters
Fan_power = 70
min_hrs_permonth_fan_use = 0
max_hrs_permonth_fan_use = 480

# process the CDD and noaccess data (to produce variants with different base T)
source("code/data_process_2.R", echo=T)

# sensitivity analysis: process the CDDs based on gldas's data
#source("code/data_process_gldas.R", echo=T)

# generate Figures 1-2-3
#source("code/figures123.R", echo=T)

# calculate heat entering houses from windows
source("code/window_heat_gain.R", echo=T)

# estimate power requirements
#source("code/electricity.R", echo=T)

# estimate power requirements (also with empirical demand)
source("code/electricity_new_ssp.R", echo=T)

# estimate co2 emissions
#source("code/emissions.R", echo=T)

# Supply-side electrification analysis for SSA
source("code/electrification_analysis.R", echo=T)

# Sensitivity analysis
T_base_sens = c(22, 24, 28, 26)
EER_urban_sens = c(2.2, 3.2, 2.9)
EER_rural_sens = c(2, 2.9, 2.2)

source("code/sensitivity.R", echo=T)

source("code/sensitivity_gldas.R", echo=T)

source("code/sensitivity_summary_figure.R", echo=T)


