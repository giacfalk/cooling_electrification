library(cowplot)

kwh_sens <- list.files(path = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/sensitivity_kwh/tbase', full.names = T)
kwh_sens <- lapply(kwh_sens, read.csv)
kwh_sens <- data.table::rbindlist(kwh_sens, idcol = T)

kwh_sens$Scenario=NA
kwh_sens$Scenario <- ifelse(kwh_sens$.id==1, "22", kwh_sens$Scenario)
kwh_sens$Scenario <- ifelse(kwh_sens$.id==2, "24", kwh_sens$Scenario)
kwh_sens$Scenario <- ifelse(kwh_sens$.id==3, "26", kwh_sens$Scenario)
kwh_sens$Scenario <- ifelse(kwh_sens$.id==4, "28", kwh_sens$Scenario)

a =ggplot(kwh_sens)+
  theme_classic()+
  geom_bar(data = kwh_sens, aes(x = id, y = twh, fill=Scenario), stat = "sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="Tbase", palette = "Set1")+
  ylab('TWh/year')+
  xlab("Warming scenario")+
  facet_wrap(~ scenario, ncol=2)

kwh_sens <- list.files(path = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/sensitivity_kwh/eer', full.names = T)
kwh_sens <- lapply(kwh_sens, read.csv)
kwh_sens <- data.table::rbindlist(kwh_sens, idcol = T)

kwh_sens$Scenario=NA
kwh_sens$Scenario <- ifelse(kwh_sens$.id==1, "2.2U, 2R", kwh_sens$Scenario)
kwh_sens$Scenario <- ifelse(kwh_sens$.id==2, "2.9U, 2.2R", kwh_sens$Scenario)
kwh_sens$Scenario <- ifelse(kwh_sens$.id==3, "3.2U, 2.9R", kwh_sens$Scenario)

b =ggplot(kwh_sens)+
  theme_classic()+
  geom_bar(data = kwh_sens, aes(x = id, y = twh, fill=Scenario), stat = "sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="EERs", palette = "Set1")+
  ylab('TWh/year')+
xlab("Warming scenario")+
  facet_wrap(~ scenario, ncol=2)

##


co2_sens <- list.files(path = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/sensitivity_co2/tbase', full.names = T)
co2_sens <- lapply(co2_sens, read.csv)
co2_sens <- data.table::rbindlist(co2_sens, idcol = T)

co2_sens$Scenario=NA
co2_sens$Scenario <- ifelse(co2_sens$.id==1, "22", co2_sens$Scenario)
co2_sens$Scenario <- ifelse(co2_sens$.id==2, "24", co2_sens$Scenario)
co2_sens$Scenario <- ifelse(co2_sens$.id==3, "26", co2_sens$Scenario)
co2_sens$Scenario <- ifelse(co2_sens$.id==4, "28", co2_sens$Scenario)

c =ggplot(co2_sens)+
  theme_classic()+
  geom_bar(data = co2_sens, aes(x = id, y = co2, fill=Scenario), stat = "sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="Tbase", palette = "Set1")+
  ylab("Mt CO2/year")+
  xlab("Warming scenario")+
  facet_wrap(~ scenario, ncol=2)

co2_sens <- list.files(path = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/sensitivity_co2/eer', full.names = T)
co2_sens <- lapply(co2_sens, read.csv)
co2_sens <- data.table::rbindlist(co2_sens, idcol = T)

co2_sens$Scenario=NA
co2_sens$Scenario <- ifelse(co2_sens$.id==1, "2.2U, 2R", co2_sens$Scenario)
co2_sens$Scenario <- ifelse(co2_sens$.id==2, "2.9U, 2.2R", co2_sens$Scenario)
co2_sens$Scenario <- ifelse(co2_sens$.id==3, "3.2U, 2.9R", co2_sens$Scenario)

d =ggplot(co2_sens)+
  theme_classic()+
  geom_bar(data = co2_sens, aes(x = id, y = co2, fill=Scenario), stat = "sum", position = "dodge", show.legend=c(size=FALSE)) +
  theme(axis.text.x = element_text(angle = 90, size=8), plot.title = element_text(hjust = 0.5))+
  scale_fill_brewer(name="EERs", palette = "Set1")+
  ylab("Mt CO2/year")+
  xlab("Warming scenario")+
  facet_wrap(~ scenario, ncol=2)

cowplot::plot_grid(a, b, ncol = 2, labels = "AUTO")
ggsave("kwh.png", last_plot(), scale=1.5, height = 2.5)

cowplot::plot_grid(c, d, ncol = 2, labels = "AUTO")
ggsave("co2.png", last_plot(), scale=1.5, height = 2.5)
