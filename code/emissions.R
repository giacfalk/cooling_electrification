# CO2 emissions

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

# calculate emission factor / kwh by country
power2 = group_by(power2, Country) %>% mutate(ef = share_res * ef_res + share_fossil * mean(c(ef_coal,  ef_oil, ef_gas)) + share_biomass * ef_waste + share_nuclear * ef_nuclear) %>% ungroup()
power2 <- dplyr::select(power2, Country, ef)

# for each country, multiply power requirement by emission factor
power2$ISO3 = countrycode(power2$Country, "country.name", "iso3c")
power2$ef = power2$ef * 100

countries = merge(world, power2, by.x="GID_0", by.y="ISO3", all.x=T)
countries$ef = ifelse(is.na(countries$Value), countries$ef, countries$Value)
countries$co2= countries$ef * countries$kwh
#countries$co2 = ifelse(countries$noacc18<100000, NA, countries$co2)

# Print results
countries_without = countries
countries_without$geometry=NULL
countries_without %>% group_by(scenario, id) %>% summarise(co2 = sum(co2, na.rm = T)/1000000000000)

world_plot = countries %>% group_by(id, scenario, continent) %>% mutate(co2=sum(co2, na.rm = T))

# Plot results
co2_region = ggplot() +
  theme_classic()+
  geom_bar(data = world_plot[which(world_plot$co2>0),], aes(x = continent , y = co2/1000000000000, fill=id), stat="sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="Scenario", palette = "Set1")+
  ylab("Potential emissions for air cooling \nfrom households without electricty")+
  xlab("Region")+
  ggtitle("Yearly CO2 emissions (Mt CO2)")+
  facet_wrap(~ scenario, ncol=2)

ggsave(paste0("co2_region_", base_temp, ".png"), co2_region, device="png")
