library(rstudioapi)
library(cowplot)

setwd('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset')

#WB-MTF (kWh/capita/yr)
tier1=8
tier2=44
tier3=160
tier4=423
tier5=598

kwh_S2 = kwh_S2 / HHs_raster
values(kwh_S2) <- ifelse(values(kwh_S2)>3000, 0, values(kwh_S2))

kwh_S1 = kwh_S1 / HHs_raster
values(kwh_S1) <- ifelse(values(kwh_S1)>3000, 0, values(kwh_S1))

# Scenario 43_acS2:
onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=extract(kwh_S2, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier4 + onsset_ssa_input$PerHHD, tier3 + onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

Sys.sleep(30)

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

Sys.sleep(120)

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c("43_acS2.csv", "43_acS2_summary.csv"))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

######

# Scenario 43_noac:
onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=extract(kwh_S2, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier4, tier3)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

Sys.sleep(30)

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

Sys.sleep(120)

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c("43_noac.csv", "43_noac_summary.csv"))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")


##

# Scenario 32_acS2:
onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=extract(kwh_S2, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

Sys.sleep(30)

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

Sys.sleep(120)

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c("32_acS2.csv", "32_acS2_summary.csv"))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

######

# Scenario 32_noac:
onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=extract(kwh_S2, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3, tier2)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

Sys.sleep(30)

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

Sys.sleep(120)

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c("32_noac.csv", "32_noac_summary.csv"))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")


####
# Produce plots that summarises results
files <- list.files(path = paste0(getwd(), "/results"), pattern = "summary.csv", full.names = T)

output <- do.call(rbind, (lapply(files, read.csv)))

output$Demand = unlist(lapply(1:length(files), function(i){rep(substr(files, 124, 130)[i], 42)}))

# Tech split among population
output_popslit <- filter(output, grepl("New_Connections",X))

output_popslit$X <- gsub("2.", "", output_popslit$X)
output_popslit$X <- gsub("New_Connections_", "", output_popslit$X)

a<- ggplot(output_popslit, aes(x=Demand, y=(X2025+X2030)/1000000, fill=X))+
  geom_col()+
  xlab("Demand scenario")+
  ylab("New connections (million)")+
  scale_fill_discrete(name="Technological set-up")

# Tech split among investment
output_invest <- filter(output, grepl("Investment",X))

output_invest$X <- gsub("4.", "", output_invest$X)
output_invest$X <- gsub("Investment_", "", output_invest$X)

b<- ggplot(output_invest, aes(x=Demand, y=(X2025+X2030)/1000000000, fill=X))+
  geom_col()+
  xlab("Demand scenario")+
  ylab("Investment requirement (billion USD)")+
  scale_fill_discrete(name="Technology split")+
  theme(legend.position = "bottom", legend.direction = "horizontal")

c <- plot_grid(plot_grid(a + theme(legend.position = "none"), b + theme(legend.position = "none"), ncol = 2), get_legend(b), ncol = 1, rel_heights = c(0.75, 0.1))

ggsave("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/supply_results.png", c, device="png", scale=1.1)
