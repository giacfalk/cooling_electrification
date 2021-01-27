library(cowplot)

kwh_sens <- list.files(path = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/sensitivity_kwh/tbase', full.names = T)
kwh_sens <- lapply(kwh_sens, read.csv)
kwh_sens <- data.table::rbindlist(kwh_sens, idcol = T)

kwh_sens$Scenario=NA
kwh_sens$Scenario <- ifelse(kwh_sens$.id==1, "22", kwh_sens$Scenario)
kwh_sens$Scenario <- ifelse(kwh_sens$.id==2, "24", kwh_sens$Scenario)
kwh_sens$Scenario <- ifelse(kwh_sens$.id==3, "26", kwh_sens$Scenario)
kwh_sens$Scenario <- ifelse(kwh_sens$.id==4, "28", kwh_sens$Scenario)

levels(kwh_sens$id) <- c("Baseline", "SSP245", "SSP370")

levels(kwh_sens$scenario) <- c("S0", "S1", "S2", "S3", "S4")

kwh_sens <- filter(kwh_sens, scenario!="S3", scenario!="S4")

a =ggplot(kwh_sens)+
  theme_classic()+
  geom_bar(data = kwh_sens, aes(x = id, y = twh, fill=Scenario), stat = "sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="Tbase", palette = "Set1")+
  ylab('TWh/year')+
  xlab("Warming scenario")+
  facet_wrap(~ scenario)+
  ggtitle("Constant EERs: 2.9 urban, 2.2 rural")

kwh_sens <- list.files(path = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/sensitivity_kwh/eer', full.names = T)
kwh_sens <- lapply(kwh_sens, read.csv)
kwh_sens <- data.table::rbindlist(kwh_sens, idcol = T)

kwh_sens$Scenario=NA
kwh_sens$Scenario <- ifelse(kwh_sens$.id==1, "2.2U, 2R", kwh_sens$Scenario)
kwh_sens$Scenario <- ifelse(kwh_sens$.id==2, "2.9U, 2.2R", kwh_sens$Scenario)
kwh_sens$Scenario <- ifelse(kwh_sens$.id==3, "3.2U, 2.9R", kwh_sens$Scenario)

levels(kwh_sens$id) <- c("Baseline", "SSP245", "SSP370")

levels(kwh_sens$scenario) <- c("S0", "S1", "S2", "S3", "S4")

kwh_sens <- filter(kwh_sens, scenario!="S3", scenario!="S4")

b =ggplot(kwh_sens)+
  theme_classic()+
  geom_bar(data = kwh_sens, aes(x = id, y = twh, fill=Scenario), stat = "sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="EERs", palette = "Set2")+
  ylab('TWh/year')+
xlab("Warming scenario")+
  facet_wrap(~ scenario)+
  ggtitle("Constant Tbase: 26 C°")

##

co2_sens <- list.files(path = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/sensitivity_co2/tbase', full.names = T)
co2_sens <- lapply(co2_sens, read.csv)
co2_sens <- data.table::rbindlist(co2_sens, idcol = T)

co2_sens$Scenario=NA
co2_sens$Scenario <- ifelse(co2_sens$.id==1, "22", co2_sens$Scenario)
co2_sens$Scenario <- ifelse(co2_sens$.id==2, "24", co2_sens$Scenario)
co2_sens$Scenario <- ifelse(co2_sens$.id==3, "26", co2_sens$Scenario)
co2_sens$Scenario <- ifelse(co2_sens$.id==4, "28", co2_sens$Scenario)

levels(co2_sens$id) <- c("Baseline", "SSP245", "SSP370")

levels(co2_sens$scenario) <- c("S0", "S1", "S2", "S3", "S4")

co2_sens <- filter(co2_sens, scenario!="S3", scenario!="S4")

c =ggplot(co2_sens)+
  theme_classic()+
  geom_bar(data = co2_sens, aes(x = id, y = co2, fill=Scenario), stat = "sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="Tbase", palette = "Set1")+
  ylab("Mt CO2/year")+
  xlab("Warming scenario")+
  facet_wrap(~ scenario)+
  ggtitle("Constant EERs: 2.9 urban, 2.2 rural")

co2_sens <- list.files(path = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/sensitivity_co2/eer', full.names = T)
co2_sens <- lapply(co2_sens, read.csv)
co2_sens <- data.table::rbindlist(co2_sens, idcol = T)

co2_sens$Scenario=NA
co2_sens$Scenario <- ifelse(co2_sens$.id==1, "2.2U, 2R", co2_sens$Scenario)
co2_sens$Scenario <- ifelse(co2_sens$.id==2, "2.9U, 2.2R", co2_sens$Scenario)
co2_sens$Scenario <- ifelse(co2_sens$.id==3, "3.2U, 2.9R", co2_sens$Scenario)

levels(co2_sens$id) <- c("Baseline", "SSP245", "SSP370")

levels(co2_sens$scenario) <- c("S0", "S1", "S2", "S3", "S4")

co2_sens <- filter(co2_sens, scenario!="S3", scenario!="S4")

d =ggplot(co2_sens)+
  theme_classic()+
  geom_bar(data = co2_sens, aes(x = id, y = co2, fill=Scenario), stat = "sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="EERs", palette = "Set2")+
  ylab("Mt CO2/year")+
  xlab("Warming scenario")+
  facet_wrap(~ scenario)+
  ggtitle("Constant Tbase: 26 C°")


cowplot::plot_grid(a, b, ncol = 1, labels = "AUTO")
ggsave("kwh.png", last_plot(), scale=1.5, height = 5, width = 4)

cowplot::plot_grid(c, d, ncol = 1, labels = "AUTO")
ggsave("co2.png", last_plot(), scale=1.5, height = 5, width = 4)
  
###

all_kwh <- read.csv('power_consumpion_26_2.9_2.2.csv')

world <- rnaturalearth::ne_countries(returnclass = "sf")

noacc18<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/noacc18.tif")

noacc18[is.na(noacc18)] <- 0

world$noacc <- exactextractr::exact_extract(noacc18, world, "sum")

all_kwh <- merge(world, all_kwh, by.y="GID_0", by.x="adm0_a3", all=T) %>% st_as_sf()

all_kwh = filter(all_kwh, id=="Baseline" & scenario=="kwh_S2")

library(viridis)

all_kwh <- subset(all_kwh, all_kwh$noacc > 100000)

all_kwh$TOTconsumption = all_kwh$TOTconsumption/(all_kwh$noacc/all_kwh$Average.household.size..number.of.members.)

map <- ggplot()+
  theme_classic()+
  geom_sf(data=world, fill="gray", lwd=0.01)+
  geom_sf(data=all_kwh, aes(fill=TOTconsumption), lwd=0.001)+
  ggtitle("kWh/household without electricity access/year (S2, baseline")+
  scale_fill_binned(name="", type = "viridis", breaks = c(250, 500, 1000, 1500, 2000, 2500))+
  theme(legend.position = "bottom", legend.direction = "horizontal", legend.key.width = unit(2.5, "cm"))

ggsave("kwh_map.png", map, scale=0.4, height = 10, width = 16)


##

all_kwh <- read.csv('co2_emissions_26_2.9_2.2.csv')

world <- rnaturalearth::ne_countries(returnclass = "sf")

noacc18<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/noacc18.tif")

noacc18[is.na(noacc18)] <- 0

world$noacc <- exactextractr::exact_extract(noacc18, world, "sum")

all_kwh <- merge(world, all_kwh, by.y="GID_0", by.x="adm0_a3", all=T) %>% st_as_sf()

all_kwh = filter(all_kwh, id=="Baseline" & scenario=="kwh_S2")

library(viridis)

all_kwh <- subset(all_kwh, all_kwh$noacc > 100000)

all_kwh$co2 = (all_kwh$co2/(all_kwh$noacc/all_kwh$Average.household.size..number.of.members.))/1000000

p <- ggplot()+
  theme_classic()+
  geom_sf(data=world, fill="gray", lwd=0.01)+
  geom_sf(data=all_kwh, aes(fill=co2), lwd=0.001)+
  ggtitle("Ton CO2/household without electricity access/year (S3, RCP 370)")+
  scale_fill_binned(name="", type = "viridis", breaks = c(1, 15, 30, 45, 60), trans="log")+
  theme(legend.position = "bottom", legend.direction = "horizontal", legend.key.width = unit(2.5, "cm"))

ggsave("co2_map.png", p, scale=0.4, height = 10, width = 16)

# Print numbers for the abstract

stack(CDD_current*HHs_raster)

# baseline average CDDs per household without electricity
(sum(values(sum(stack(CDD_current*HHs_raster))), na.rm = T)) / sum(values(HHs_raster), na.rm = T)

# baseline average CDDs per household without electricity (2050 climate change scenarios)
((sum(values(sum(stack(CDD_245*HHs_raster))), na.rm = T)) / sum(values(HHs_raster), na.rm = T) + (sum(values(sum(stack(CDD_370*HHs_raster))), na.rm = T)) / sum(values(HHs_raster), na.rm = T))/2

# how many HH experience more than 500, million
sum(values((sum(CDD_current)>500)*HHs_raster), na.rm = T) / 1e6

# range power consumption
summary(kwh_sens$twh)

# range emissions
summary(co2_sens$co2)





