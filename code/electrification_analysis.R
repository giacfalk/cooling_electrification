setwd('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset')

#WB-MTF (kWh/capita/yr) to define baseline demand
tier1=8
tier2=44
tier3=160
tier4=423
tier5=598

# Scenario t43_S1_base:

scenario_name <- "t43_S1_base"

kwh_S1 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S1_baseline.tif")
kwh_S1 = kwh_S1 / HHs_raster
values(kwh_S1) <- ifelse(values(kwh_S1)>3000, 0, values(kwh_S1))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=raster::extract(kwh_S1, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier4 + onsset_ssa_input$PerHHD, tier3 + onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {
  Sys.sleep(0.1)
}

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {
  Sys.sleep(0.1)
}

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

######

# Scenario t43_noAC_base:

scenario_name <- "t43_noAC_base"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier4, tier3)
onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")


####

# Scenario t43_S1_245:

scenario_name <- "t43_S1_245"

kwh_S1 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S1_245.tif")
kwh_S1 = kwh_S1 / HHs_raster
values(kwh_S1) <- ifelse(values(kwh_S1)>3000, 0, values(kwh_S1))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=raster::extract(kwh_S1, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier4 + onsset_ssa_input$PerHHD, tier3 + onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

######

# Scenario t43_noAC_245:

scenario_name <- "t43_noAC_245"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier4, tier3)
onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")


###

# Scenario t43_S2_370:

scenario_name <- "t43_S2_370"

kwh_S2 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S2_370.tif")
kwh_S2 = kwh_S2 / HHs_raster
values(kwh_S2) <- ifelse(values(kwh_S2)>3000, 0, values(kwh_S2))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=raster::extract(kwh_S2, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier4 + onsset_ssa_input$PerHHD, tier3 + onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

######

# Scenario t43_noAC_370:

scenario_name <- "t43_noAC_370"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier4, tier3)
onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

# Scenario t32_S1_base:

scenario_name <- "t32_S1_base"

kwh_S1 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S1_baseline.tif")
kwh_S1 = kwh_S1 / HHs_raster
values(kwh_S1) <- ifelse(values(kwh_S1)>3000, 0, values(kwh_S1))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=raster::extract(kwh_S1, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

######

# Scenario t32_noAC_base:

scenario_name <- "t32_noAC_base"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3, tier2)
onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")


####

# Scenario t32_S1_245:

scenario_name <- "t32_S1_245"

kwh_S1 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S1_245.tif")
kwh_S1 = kwh_S1 / HHs_raster
values(kwh_S1) <- ifelse(values(kwh_S1)>3000, 0, values(kwh_S1))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=raster::extract(kwh_S1, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

######

# Scenario t32_noAC_245:

scenario_name <- "t32_noAC_245"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3, tier2)
onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")


###

# Scenario t32_S2_370:

scenario_name <- "t32_S2_370"

kwh_S2 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S2_370.tif")
kwh_S2 = kwh_S2 / HHs_raster
values(kwh_S2) <- ifelse(values(kwh_S2)>3000, 0, values(kwh_S2))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=raster::extract(kwh_S2, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

######

# Scenario t32_noAC_370:

scenario_name <- "t32_noAC_370"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3, tier2)
onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")


###

# Scenario t43_S3_370:

scenario_name <- "t43_S3_370"

kwh_S3 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S3_370.tif")
kwh_S3 = kwh_S3 / HHs_raster
values(kwh_S3) <- ifelse(values(kwh_S3)>3000, 0, values(kwh_S3))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=raster::extract(kwh_S3, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

######

# Scenario t43_noAC_370:

scenario_name <- "t43_noAC_370"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3, tier2)
onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

###

# Scenario t32_S3_370:

scenario_name <- "t32_S3_370"

kwh_S3 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S3_370.tif")
kwh_S3 = kwh_S3 / HHs_raster
values(kwh_S3) <- ifelse(values(kwh_S3)>3000, 0, values(kwh_S3))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=raster::extract(kwh_S3, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

######

# Scenario t32_noAC_370:

scenario_name <- "t32_noAC_370"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3, tier2)
onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

# Scenario t32_S4_370:

scenario_name <- "t32_S4_370"

kwh_S4 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S4_370.tif")
kwh_S4 = kwh_S4 / HHs_raster
values(kwh_S4) <- ifelse(values(kwh_S4)>3000, 0, values(kwh_S4))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

rasValue=raster::extract(kwh_S4, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")

######

# Scenario t32_noAC_370:

scenario_name <- "t32_noAC_370"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ Y_deg + X_deg

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3, tier2)
onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

write.csv(onsset_ssa_input, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")

# Calibrate model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_cali.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

sf <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")
sf[is.na(sf)] <- 0
sf$NumPeoplePerHH <- ifelse(sf$NumPeoplePerHH==0, mean(sf$NumPeoplePerHH[sf$NumPeoplePerHH!=0]), sf$NumPeoplePerHH)
write.csv(sf, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/cali_SSA.csv")

# Run model
a <- rstudioapi::terminalExecute('python "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/runner_run.py"')

while (is.null(rstudioapi::terminalExitCode(a))) {   Sys.sleep(0.1) }

# rename result files

setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/results")
file.rename(c("ssa-1-0_0_0_0_0_0.csv", "ssa-1-0_0_0_0_0_0_summary.csv"), c(paste0(scenario_name, ".csv"), paste0(scenario_name, "_summary.csv")))
setwd("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset")


####
# Produce plots that summarises results


files <- list.files(path = paste0(getwd(), "/results"), pattern = ".csv", full.names = T)
files <- files[!grepl('summary', files)]

output <- lapply(files, read.csv)

for (i in 1:length(output)){
  output[[i]] <- output[[i]] %>% dplyr::select(-starts_with("Unnamed"), -starts_with("X."), -starts_with("Optional"))
}

output <- do.call(rbind, output)

output$Demand = unlist(lapply(1:length(files), function(i){rep(gsub(".csv", "", sub('.*\\/', '', files[i])), 8101)}))

output <- filter(output, Demand=="t32_noAC_base" | Demand=="t32_S1_base" | Demand=="t32_S1_245" | Demand=="t32_S2_370" | Demand=="t43_noAC_base" | Demand=="t43_S1_base" | Demand=="t43_S1_245" | Demand=="t43_S2_370")


##

output_p <- group_by(output, Demand, MinimumOverall2030, Elec_Initial_Status_Grid2018) %>% summarise(conections= sum(NewConnections2030))

output_p$MinimumOverall2030 <- as.character(output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("2030", "", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("Grid", "Grid expansion", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- ifelse(output_p$Elec_Initial_Status_Grid2018==1, "Grid densification", output_p$MinimumOverall2030)

output_p$Demand <- factor(output_p$Demand, levels = c("t32_noAC_base", "t43_noAC_base", "t32_S1_base", "t32_S1_245", "t32_S2_370", "t43_S1_base", "t43_S1_245", "t43_S2_370"))

# Tech split among population

a<- ggplot(output_p, aes(x=Demand, y=conections/1000000, fill=MinimumOverall2030))+
  theme_classic()+
  geom_col()+
  xlab("2030 universal electrification, demand scenarios")+
  ylab("New electricity connections \n(million people)")+
  scale_fill_brewer(name="Technology set-up", palette = "Set1")+
  theme(legend.position = "bottom", legend.direction = "horizontal", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))




# Tech split among investment
output_p <- group_by(output, Demand, MinimumOverall2030, Elec_Initial_Status_Grid2018) %>% summarise(investment=sum(InvestmentCost2025) + sum(InvestmentCost2030))

output_p$MinimumOverall2030 <- as.character(output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("2030", "", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("Grid", "Grid expansion", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- ifelse(output_p$Elec_Initial_Status_Grid2018==1, "Grid densification", output_p$MinimumOverall2030)

output_p$Demand <- factor(output_p$Demand, levels = c("t32_noAC_base", "t43_noAC_base", "t32_S1_base", "t43_S1_base", "t32_S1_245", "t43_S1_245", "t32_S2_370", "t43_S2_370"))

b<- ggplot(output_p, aes(x=Demand, y=investment/1000000000, fill=MinimumOverall2030))+
  theme_classic()+
  geom_col()+
  xlab("")+
  ylab("Cumulative investment \nrequirements (billion USD)")+
  scale_fill_brewer(name="Technology set-up", palette = "Set1")+
  theme(legend.position = "bottom", legend.direction = "horizontal", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

c <- plot_grid(plot_grid(b + theme(legend.position = "none"), a + theme(legend.position = "none"), ncol = 1, labels="AUTO"), get_legend(b), ncol = 1, rel_heights = c(1, 0.1))

ggsave("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/supply_results.png", c, device="png", scale=1.1, height = 7.5, width = 6)

# plot maps

base <- read_sf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/polygons_ssa_reprojected_area.gpkg')

list_results <- list.files(path = paste0(getwd(), "/results"), pattern = ".csv", full.names = F)
list_results <- list_results[!grepl('summary', list_results)]

path <- paste0(getwd(), "/results/")

for (scen in list_results){

t43_S1_245 <- read.csv(paste0(path, scen))

t43_S1_245 <- bind_cols(base, t43_S1_245)

t43_S1_245$MinimumOverall2030 <- gsub("2030", "", as.character(t43_S1_245$MinimumOverall2030))

t43_S1_245$MinimumOverall2030 <- ifelse(t43_S1_245$noaccsum>10000, t43_S1_245$MinimumOverall2030, NA)

t43_S1_245$MinimumOverall2030 <- sub("\\_.*", "", t43_S1_245$MinimumOverall2030)

bPols <- rnaturalearth::ne_countries(continent = "Africa", returnclass = "sf")

map1 <- ggplot()+
  theme_classic()+
  geom_sf(data=bPols, fill=NA, colour="black")+
  geom_sf(data=t43_S1_245, aes(fill=as.factor(MinimumOverall2030)), colour=NA)+
  theme(legend.position = "bottom", legend.direction = "horizontal")+
  xlab("Longitude")+
  ylab("Latitude")+
  scale_fill_brewer(name="Technology set-up", palette = "Set1")+#, na.value="grey50")+
  ggtitle(gsub(".csv", "", scen))

ggsave(paste0(gsub(".csv", "", scen), "_map.png"), map1, device="png", scale=1.75)
}

## Map of change 

t43_noAC_245$AC="NO"
t43_S1_245$AC="YES"

t43_S1_245$geom=NULL

t43_S1_245 <- dplyr::select(t43_S1_245, AC, MinimumOverall2030)
t43_noAC_245 <- dplyr::select(t43_noAC_245, AC, MinimumOverall2030)

merger <- bind_cols(t43_noAC_245, t43_S1_245)

merger$MinimumOverall2030_change <- ifelse(merger$MinimumOverall20301!=merger$MinimumOverall2030 & merger$MinimumOverall20301=="Grid", 1, ifelse(merger$MinimumOverall20301!=merger$MinimumOverall2030 & merger$MinimumOverall20301=="MG", 2, 3))


merger$MinimumOverall2030_change <- ifelse(merger$MinimumOverall2030_change == 1, "Grid expansion displaces SA/MG", ifelse(merger$MinimumOverall2030_change == 2, "Minigrids displace SA", ifelse(merger$MinimumOverall2030_change ==3, "No technology shift", NA)))
  
map3 <- ggplot()+
  theme_classic()+
  geom_sf(data=bPols, fill=NA, colour="black")+
  geom_sf(data=merger, aes(fill=as.factor(MinimumOverall2030_change)), colour=NA)+
  theme(legend.position = "bottom", legend.direction = "horizontal")+
  xlab("Longitude")+
  ylab("Latitude")+
  scale_fill_brewer(name="Technology set-up change", palette = "Set1")+#, na.value="grey50")+
  ggtitle("Shift in optimal electrification system (t32_noAC to t32_S2_370)")

ggsave("map3.png", map3, device="png", scale=1.5)

## produce summary of results

#  t32_noAC_base with t32_S1_base and t32_S2_370

# t43_noAC_base t43_S1_base and t43_S2_370

# connections
output_p <- group_by(output, Demand, MinimumOverall2030, Elec_Initial_Status_Grid2018) %>% summarise(conections= sum(NewConnections2030))

output_p$MinimumOverall2030 <- as.character(output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("2030", "", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("Grid", "Grid expansion", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- ifelse(output_p$Elec_Initial_Status_Grid2018==1, "Grid densification", output_p$MinimumOverall2030)

output_p <- filter(output_p,  Demand == "t32_noAC_base" | Demand == "t43_noAC_base" | Demand ==  "t32_S1_base" | Demand ==  "t32_S2_370" | Demand ==  "t43_S1_base" | Demand ==  "t43_S2_370")

one <- 1-(sum(output_p$conections[output_p$Demand=="t32_S1_base" & (output_p$MinimumOverall2030!="Grid expansion" & output_p$MinimumOverall2030!="Grid densification")]) / sum(output_p$conections[output_p$Demand=="t32_noAC_base"& (output_p$MinimumOverall2030!="Grid expansion" & output_p$MinimumOverall2030!="Grid densification")]))

two <- 1-(sum(output_p$conections[output_p$Demand=="t32_S2_370" & (output_p$MinimumOverall2030!="Grid expansion" & output_p$MinimumOverall2030!="Grid densification")]) / sum(output_p$conections[output_p$Demand=="t32_noAC_base"& (output_p$MinimumOverall2030!="Grid expansion" & output_p$MinimumOverall2030!="Grid densification")]))

three <- 1-(sum(output_p$conections[output_p$Demand=="t43_S1_base" & (output_p$MinimumOverall2030!="Grid expansion" & output_p$MinimumOverall2030!="Grid densification")]) / sum(output_p$conections[output_p$Demand=="t43_noAC_base"& (output_p$MinimumOverall2030!="Grid expansion" & output_p$MinimumOverall2030!="Grid densification")]))

four <- 1-(sum(output_p$conections[output_p$Demand=="t43_S2_370" & (output_p$MinimumOverall2030!="Grid expansion" & output_p$MinimumOverall2030!="Grid densification")]) / sum(output_p$conections[output_p$Demand=="t43_noAC_base"& (output_p$MinimumOverall2030!="Grid expansion" & output_p$MinimumOverall2030!="Grid densification")]))

round(summary(c(one, two, three, four)))


###

output_p <- group_by(output, Demand) %>% summarise(conections= sum(NewCapacity2025+NewCapacity2030))

output_p <- filter(output_p,  Demand == "t32_noAC_base" | Demand == "t43_noAC_base" | Demand ==  "t32_S1_base" | Demand ==  "t32_S2_370" | Demand ==  "t43_S1_base" | Demand ==  "t43_S2_370")

one <- (sum(output_p$conections[output_p$Demand=="t32_S1_base"]) / sum(output_p$conections[output_p$Demand=="t32_noAC_base"])) -1

two <- (sum(output_p$conections[output_p$Demand=="t32_S2_370"]) / sum(output_p$conections[output_p$Demand=="t32_noAC_base"])) -1

three <- (sum(output_p$conections[output_p$Demand=="t43_S1_base"]) / sum(output_p$conections[output_p$Demand=="t43_noAC_base"])) -1
 
four <- (sum(output_p$conections[output_p$Demand=="t43_S2_370"]) / sum(output_p$conections[output_p$Demand=="t43_noAC_base"])) -1

summary(c(one, two, three, four))

###


output_p <- group_by(output, Demand) %>% summarise(conections= sum(InvestmentCost2025+InvestmentCost2030))

output_p <- filter(output_p,  Demand == "t32_noAC_base" | Demand == "t43_noAC_base" | Demand ==  "t32_S1_base" | Demand ==  "t32_S2_370" | Demand ==  "t43_S1_base" | Demand ==  "t43_S2_370")

one <- (sum(output_p$conections[output_p$Demand=="t32_S1_base"]) / sum(output_p$conections[output_p$Demand=="t32_noAC_base"])) -1

two <- (sum(output_p$conections[output_p$Demand=="t32_S2_370"]) / sum(output_p$conections[output_p$Demand=="t32_noAC_base"])) -1

three <- (sum(output_p$conections[output_p$Demand=="t43_S1_base"]) / sum(output_p$conections[output_p$Demand=="t43_noAC_base"])) -1

four <- (sum(output_p$conections[output_p$Demand=="t43_S2_370"]) / sum(output_p$conections[output_p$Demand=="t43_noAC_base"])) -1

summary(c(one, two, three, four))

