# CO2 emissions

# households that will gain access through decentralised solutions in each country

# grid_distance_km<-raster('C:/Users/GIACOMO/Google Drive/TD_grid_distance_km-0000000000-0000000000.tif')
# grid_distance_km2<-raster('C:/Users/GIACOMO/Google Drive/TD_grid_distance_km-0000000000-0000023296.tif')
# 
# grid_distance_km <- aggregate(grid_distance_km, fact=60, fun=mean, na.rm=T)
# grid_distance_km2 <- aggregate(grid_distance_km2, fact=60, fun=mean, na.rm=T)
# 
# grid_distance_km <-projectRaster(grid_distance_km, noacc18)
# grid_distance_km2 <-projectRaster(grid_distance_km2, noacc18)
# #
# grid_distance_km<-merge(grid_distance_km, grid_distance_km2)
# 
# writeRaster(grid_distance_km, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/grid_distance_km.tif", overwrite=T)

grid_distance_km <- raster('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/grid_distance_km.tif')

no_access_through_decentralised <- overlay(noacc18, grid_distance_km, fun = function(x, y) {
  x[!is.na(y)] <- NA
  return(x)
})
#
no_access_through_grid <- overlay(noacc18, grid_distance_km, fun = function(x, y) {
  x[is.na(y)] <- NA
  return(x)
})

# Minigrid emissions

# mg <- xlsx::read.xlsx('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/MCC/dynamic minigrid/all_minigrids_SSA.xlsx', sheetIndex = "Sheet1")
# 
# mg %>% mutate_if(is.factor, as.character) -> mg
# mg$Year.commisioned = as.numeric(mg$Year.commisioned)
# 
# mg <- subset(mg, mg$Operating.status=="Operating" & mg$Year.commisioned>2009)
# 
# unique(mg$Technology)
# 
# #https://www.ipcc-nggip.iges.or.jp/public/mtdocs/pdfiles/EFDB_India_A7.pdf
# #http://www.provincia.bz.it/agricoltura/download/Bilancio_ecologico_di_impianti_a_biogas.pdf
# 
# mg$ef = NA
# mg$ef = ifelse(mg$Technology=="Diesel", 650, mg$ef)
# mg$ef = ifelse(mg$Technology=="Hybrid Solar PV / Diesel", 325, mg$ef)
# mg$ef = ifelse(mg$Technology=="Solar PV", 0, mg$ef)
# mg$ef = ifelse(mg$Technology=="Biogas", 13, mg$ef)
# mg$ef = ifelse(mg$Technology=="Biomass cogeneration", 50, mg$ef)
# mg$ef = ifelse(mg$Technology=="Biomass palm oil", 100, mg$ef)
# mg$ef = ifelse(mg$Technology=="Hybrid Solar PV / Wind", 0, mg$ef)
# mg$ef = ifelse(mg$Technology=="Hybrid Wind / Diesel", 325, mg$ef)
# mg$ef = ifelse(mg$Technology=="Hybrid Straight Vegetable Oil / Diesel", 375, mg$ef)
# mg$ef = ifelse(mg$Technology=="Biomass gasification", 50, mg$ef)
# mg$ef = ifelse(mg$Technology=="Hybrid Solar PV / Wind / Diesel", 250, mg$ef)
# 
# mean(mg$ef, na.rm=T)

mg_emissions = 339.7385

# Import IEA emission factors
iea_efs<- read.csv('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/energy/emission_factors_iea.csv')

# Merge with dataframe
world <- merge(world, iea_efs, by.x="GID_0", by.y="ï..COUNTRY", all.x=T)

# For countries with missing IEA data, use EIA data on power mix and assume standard 
# emission factors to estimate total ef
power <- read.csv('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/energy/INT-Export-05-24-2020_15-57-02.csv')

power <- split(power,rep(1:400,each=232))
power <- power[1:12]
power_bk = power
for (i in 1:12){
  a<-as.character(power[[i]]$ï..Country[1])
  colnames(power[[i]])[2] <- a
  power[[i]] <- power[[i]][-1,]
  power[[i]] <- as.data.frame(power[[i]])
  power[[i]][,2] <- as.character(power[[i]][,2])
  power[[i]][,2] = ifelse(power[[i]][,2]=="--", 0, power[[i]][,2])
  power[[i]][,2] = as.numeric(unlist(power[[i]][,2]))
  power[[i]] <- power[[i]][,-1]
}
power2 <- as.data.frame(do.call(cbind, power))
for (i in 1:12) {
  colnames(power2)[i] <- as.character(power_bk[[i]]$ï..Country[1])
}
power2 = cbind(as.character(power_bk$`1`$ï..Country[-1]), power2)

# calculate share of each tech over total by country
colnames(power2) <- c("Country", "Total_gen", "Nuclear", "Fossil", "RES", "Hydro", "Non_hydro_res", "Geothermal", "VRES", "Tidal", "Solar", "Wind", "Biomass_waste")
power2 = group_by(power2, Country) %>% mutate(share_fossil = Fossil/Total_gen  , share_res = RES/Total_gen, share_biomass = Biomass_waste/Total_gen, share_nuclear = Nuclear/Total_gen)

# import emission factors (kg co2 per kwh) from https://www.mdpi.com/1996-1073/13/10/2527/htm
ef_oil <- 0.545
ef_gas <- 0.368
ef_res <- 0
ef_waste <- 0.555
ef_coal <- 0.870
ef_diesel_200kw <-0.730
ef_diesel_2mw <-0.587
ef_nuclear <- 0

world_bk <- read_sf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/CLEXREL/Data/gadm36_levels_shp/gadm36_0.shp')
world_bk <- dplyr::select(world_bk, GID_0, geometry)
world <- merge(world, world_bk, by="GID_0")
world <- st_as_sf(world)

# extract country-level share of people gaining through grid and through decentralised
world$through_grid = exactextractr::exact_extract(no_access_through_grid, world, 'sum')
world$through_mg = exactextractr::exact_extract(no_access_through_decentralised, world, 'sum')
world$share_grid = world$through_grid/(world$through_grid + world$through_mg)
world$share_mg = world$through_mg/(world$through_grid + world$through_mg)

world$geometry=NULL
power2$ISO3 = countrycode(power2$Country, "country.name", "iso3c")

countries = merge(world, power2, by.x="GID_0", by.y="ISO3", all.x=T)

# calculate emission factor / kwh by country
countries = group_by(countries, GID_0) %>% mutate(ef = (share_res * ef_res + share_fossil * mean(c(ef_coal,  ef_oil, ef_gas)) + share_biomass * ef_waste + share_nuclear * ef_nuclear)*share_grid + mg_emissions*share_mg) %>% ungroup()

# for each country, multiply power requirement by emission factor
countries$ef = countries$ef * 100

countries$ef = ifelse(is.na(countries$Value), countries$ef, countries$Value)
countries$co2= countries$ef * countries$kwh
#countries$co2 = ifelse(countries$noacc18<100000, NA, countries$co2)

# Print results
countries_without = countries
countries_without$geometry=NULL
summary_co2 <- countries_without %>% group_by(scenario, id) %>% summarise(co2 = sum(co2, na.rm = T)/1000000000000)
write.csv(summary_co2, paste0("summary_co2_emissions_", base_temp, "_", EER_urban, "_", EER_rural, ".csv"))

world_plot = countries %>% group_by(id, scenario, continent) %>% mutate(co2=sum(co2, na.rm = T))

# Plot results
co2_region = ggplot() +
  theme_classic()+
  geom_bar(data = world_plot[which(world_plot$co2>1000000000),], aes(x = continent , y = co2/1000000000000, fill=id), stat="sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="Scenario", palette = "Set1")+
  ylab("Potential emissions for air cooling \nfrom households without electricty")+
  xlab("Region")+
  ggtitle("Yearly CO2 emissions (Mt CO2)")+
  facet_wrap(~ scenario, ncol=2)

ggsave(paste0("co2_region_", base_temp, ".png"), co2_region, device="png")

write.csv(world_plot, paste0("co2_emissions_", base_temp, "_", EER_urban, "_", EER_rural, ".csv"))
