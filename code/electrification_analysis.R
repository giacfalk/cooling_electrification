setwd('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset')

#WB-MTF (kWh/hh/yr) to define baseline demand
#tier1=8
tier2=73 - 29.2 
tier3=365 - 87.6 
tier4=1250 - 175.2 
#tier5=598

HHs_raster <- raster::raster("HHs_raster.tif")

# Scenario t43_S0_base:

scenario_name <- "t43_S0_base"

kwh_S0 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S0_baseline.tif")
kwh_S0 = kwh_S0 / HHs_raster

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S0, onsset_ssa_input)
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


# Scenario t32_S0_base:

scenario_name <- "t32_S0_base"

kwh_S0 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S0_baseline.tif")
kwh_S0 = kwh_S0 / HHs_raster
values(kwh_S0) <- ifelse(values(kwh_S0)>3000, 0, values(kwh_S0))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S0, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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

# Scenario t43_S0_245:

scenario_name <- "t43_S0_245"

kwh_S0 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S0_245.tif")
kwh_S0 = kwh_S0 / HHs_raster
values(kwh_S0) <- ifelse(values(kwh_S0)>3000, 0, values(kwh_S0))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S0, onsset_ssa_input)
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


# Scenario t32_S0_245:

scenario_name <- "t32_S0_245"

kwh_S0 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S0_245.tif")
kwh_S0 = kwh_S0 / HHs_raster
values(kwh_S0) <- ifelse(values(kwh_S0)>3000, 0, values(kwh_S0))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S0, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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


# Scenario t43_S0_370:

scenario_name <- "t43_S0_370"

kwh_S0 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S0_370.tif")
kwh_S0 = kwh_S0 / HHs_raster
values(kwh_S0) <- ifelse(values(kwh_S0)>3000, 0, values(kwh_S0))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S0, onsset_ssa_input)
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


# Scenario t32_S0_370:

scenario_name <- "t32_S0_370"

kwh_S0 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S0_370.tif")
kwh_S0 = kwh_S0 / HHs_raster
values(kwh_S0) <- ifelse(values(kwh_S0)>3000, 0, values(kwh_S0))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S0, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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

# Scenario t43_S1_base:

scenario_name <- "t43_S1_base"

kwh_S1 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S1_baseline.tif")
kwh_S1 = kwh_S1 / HHs_raster
values(kwh_S1) <- ifelse(values(kwh_S1)>3000, 0, values(kwh_S1))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

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


# Scenario t32_S1_base:

scenario_name <- "t32_S1_base"

kwh_S1 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S1_baseline.tif")
kwh_S1 = kwh_S1 / HHs_raster
values(kwh_S1) <- ifelse(values(kwh_S1)>3000, 0, values(kwh_S1))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S1, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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

# Scenario t43_S1_245:

scenario_name <- "t43_S1_245"

kwh_S1 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S1_245.tif")
kwh_S1 = kwh_S1 / HHs_raster
values(kwh_S1) <- ifelse(values(kwh_S1)>3000, 0, values(kwh_S1))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

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


# Scenario t32_S1_245:

scenario_name <- "t32_S1_245"

kwh_S1 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S1_245.tif")
kwh_S1 = kwh_S1 / HHs_raster
values(kwh_S1) <- ifelse(values(kwh_S1)>3000, 0, values(kwh_S1))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S1, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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


# Scenario t43_S1_370:

scenario_name <- "t43_S1_370"

kwh_S1 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S1_370.tif")
kwh_S1 = kwh_S1 / HHs_raster
values(kwh_S1) <- ifelse(values(kwh_S1)>3000, 0, values(kwh_S1))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

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


# Scenario t32_S1_370:

scenario_name <- "t32_S1_370"

kwh_S1 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S1_370.tif")
kwh_S1 = kwh_S1 / HHs_raster
values(kwh_S1) <- ifelse(values(kwh_S1)>3000, 0, values(kwh_S1))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S1, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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

# Scenario t43_S2_base:

scenario_name <- "t43_S2_base"

kwh_S2 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S2_baseline.tif")
kwh_S2 = kwh_S2 / HHs_raster
values(kwh_S2) <- ifelse(values(kwh_S2)>3000, 0, values(kwh_S2))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S2, onsset_ssa_input)
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


# Scenario t32_S2_base:

scenario_name <- "t32_S2_base"

kwh_S2 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S2_baseline.tif")
kwh_S2 = kwh_S2 / HHs_raster
values(kwh_S2) <- ifelse(values(kwh_S2)>3000, 0, values(kwh_S2))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S2, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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

# Scenario t43_S2_245:

scenario_name <- "t43_S2_245"

kwh_S2 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S2_245.tif")
kwh_S2 = kwh_S2 / HHs_raster
values(kwh_S2) <- ifelse(values(kwh_S2)>3000, 0, values(kwh_S2))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S2, onsset_ssa_input)
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


# Scenario t32_S2_245:

scenario_name <- "t32_S2_245"

kwh_S2 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S2_245.tif")
kwh_S2 = kwh_S2 / HHs_raster
values(kwh_S2) <- ifelse(values(kwh_S2)>3000, 0, values(kwh_S2))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S2, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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


# Scenario t43_S2_370:

scenario_name <- "t43_S2_370"

kwh_S2 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S2_370.tif")
kwh_S2 = kwh_S2 / HHs_raster
values(kwh_S2) <- ifelse(values(kwh_S2)>3000, 0, values(kwh_S2))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S2, onsset_ssa_input)
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


# Scenario t32_S2_370:

scenario_name <- "t32_S2_370"

kwh_S2 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S2_370.tif")
kwh_S2 = kwh_S2 / HHs_raster
values(kwh_S2) <- ifelse(values(kwh_S2)>3000, 0, values(kwh_S2))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S2, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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

# Scenario t43_S3_base:

scenario_name <- "t43_S3_base"

kwh_S3 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S3_baseline.tif")
kwh_S3 = kwh_S3 / HHs_raster
values(kwh_S3) <- ifelse(values(kwh_S3)>3000, 0, values(kwh_S3))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S3, onsset_ssa_input)
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


# Scenario t32_S3_base:

scenario_name <- "t32_S3_base"

kwh_S3 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S3_baseline.tif")
kwh_S3 = kwh_S3 / HHs_raster
values(kwh_S3) <- ifelse(values(kwh_S3)>3000, 0, values(kwh_S3))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S3, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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

# Scenario t43_S3_245:

scenario_name <- "t43_S3_245"

kwh_S3 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S3_245.tif")
kwh_S3 = kwh_S3 / HHs_raster
values(kwh_S3) <- ifelse(values(kwh_S3)>3000, 0, values(kwh_S3))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S3, onsset_ssa_input)
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


# Scenario t32_S3_245:

scenario_name <- "t32_S3_245"

kwh_S3 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S3_245.tif")
kwh_S3 = kwh_S3 / HHs_raster
values(kwh_S3) <- ifelse(values(kwh_S3)>3000, 0, values(kwh_S3))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S3, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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


# Scenario t43_S3_370:

scenario_name <- "t43_S3_370"

kwh_S3 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S3_370.tif")
kwh_S3 = kwh_S3 / HHs_raster
values(kwh_S3) <- ifelse(values(kwh_S3)>3000, 0, values(kwh_S3))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S3, onsset_ssa_input)
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


# Scenario t32_S3_370:

scenario_name <- "t32_S3_370"

kwh_S3 <- raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/kwh_S3_370.tif")
kwh_S3 = kwh_S3 / HHs_raster
values(kwh_S3) <- ifelse(values(kwh_S3)>3000, 0, values(kwh_S3))

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

rasValue=raster::extract(kwh_S3, onsset_ssa_input)
onsset_ssa_input$PerHHD <- rasValue

onsset_ssa_input$PerHHD <- ifelse(is.na(onsset_ssa_input$PerHHD), 0, onsset_ssa_input$PerHHD)

onsset_ssa_input$PerHHD = ifelse(onsset_ssa_input$IsUrban==1, tier3 + onsset_ssa_input$PerHHD, tier2 + onsset_ssa_input$PerHHD)

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

# Scenario t43_noAC_base:

scenario_name <- "t43_noAC_base"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

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


# Scenario t32_noAC_base:

scenario_name <- "t32_noAC_base"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

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

# Scenario t43_noAC_245:

scenario_name <- "t43_noAC_245"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

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

# Scenario t32_noAC_245:

scenario_name <- "t32_noAC_245"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

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

# Scenario t43_noAC_245:

scenario_name <- "t43_noAC_370"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

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

# Scenario t32_noAC_245:

scenario_name <- "t32_noAC_370"

onsset_ssa_input <- read.csv("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv")
coordinates(onsset_ssa_input)= ~ X_deg + Y_deg

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

# Bar plots 

output_p <- group_by(output, Demand, MinimumOverall2030, Elec_Initial_Status_Grid2018) %>% summarise(conections= sum(NewConnections2030), investment=sum(InvestmentCost2025) + sum(InvestmentCost2030))

output_p$MinimumOverall2030 <- as.character(output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("2030", "", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("Grid", "Grid expansion", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- ifelse(output_p$Elec_Initial_Status_Grid2018==1, "Grid densification", output_p$MinimumOverall2030)

output_p$Adoption <- stringr::str_match(output_p$Demand, "_\\s*(.*?)\\s*_")[,2]
output_p$Climate <- sub('.*\\_', '', output_p$Demand)
output_p$BaseCons <- substr(output_p$Demand, 2, 3)

output_p$MinimumOverall2030_short <- substr(output_p$MinimumOverall2030, 1, 2)

output_p$MinimumOverall2030_short <- ifelse(output_p$MinimumOverall2030_short=="Gr", "Grid Expansion", ifelse(output_p$MinimumOverall2030_short=="MG", "Mini-grid", "Standalone system"))

output_p <- group_by(output_p, Demand, MinimumOverall2030_short, Adoption, BaseCons) %>% summarise(conections=sum(conections), investment=sum(investment))

output_p <- filter(output_p, Adoption=="noAC" | Adoption=="S0" | Adoption=="S1" | Adoption=="S2")

output_p$Adoption <- factor(output_p$Adoption, levels = c("noAC", "S0", "S1", "S2"))

levels(output_p$Adoption) <- c("No ACC", "S0 (empirical)", "S1", "S2")

output_p <- group_by(output_p, MinimumOverall2030_short, Adoption, BaseCons) %>% summarise(conections=mean(conections), investment=mean(investment))

output_p$BaseCons<-ifelse(output_p$BaseCons=="43", "Tiers 4 and 3", "Tiers 3 and 2")

a<- ggplot(output_p, aes(x=Adoption, y=conections/1000000, fill=MinimumOverall2030_short))+
  theme_classic()+
  geom_col()+
  xlab("")+
  ylab("New electricity connections \n(million people)")+
  ggtitle("Universal electrification by 2030, sensitivity of tech. set-up to ACC adoption")+
  scale_fill_brewer(name="Technology set-up", palette = "Set1")+
  theme(legend.position = "bottom", legend.direction = "horizontal", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  facet_wrap(vars(BaseCons), scales = "free")

a2<- ggplot(output_p, aes(x=Adoption, y=conections/1000000/2, fill=MinimumOverall2030_short))+
  theme_classic()+
  geom_col()+
  xlab("")+
  ylab("New electricity connections \n(million people)")+
  ggtitle("Universal electrification by 2030, sensitivity of tech. set-up to ACC adoption")+
  scale_fill_brewer(name="Technology set-up", palette = "Set1")+
  theme(legend.position = "bottom", legend.direction = "horizontal", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

output_p <- output_p %>% group_by(MinimumOverall2030_short, Adoption) %>%
  summarise(investment = mean(investment))

output_p <- output_p %>% group_by(Adoption) %>%
  mutate(Percent = investment/sum(investment))

a3<- ggplot(output_p, aes(x=Adoption, y=investment/1000000000, fill=MinimumOverall2030_short))+
  theme_classic()+
  geom_col()+
  xlab("")+
  ylab("Investment requirements \n(billion USD)")+
  ggtitle("Universal electrification by 2030, sensitivity of investments to ACC adoption")+
  scale_fill_brewer(name="Technology set-up", palette = "Set1")+
  theme(legend.position = "bottom", legend.direction = "horizontal", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))#+
  #geom_text(aes(label = scales::percent(Percent, accuracy = 1)), position = position_stack(0.5))

output_p <- group_by(output_p, Adoption) %>% summarise(investment=sum(investment))

output_p <- summarise(output_p, investmentS0=investment[2]/investment [1], investmentS1=investment[3]/investment [1], investmentS2=investment[4]/investment[1])

output_p <- melt(output_p)

output_p$value <- output_p$value -1

####

# Tech split among investmentc
output_p <- group_by(output, Demand, MinimumOverall2030, Elec_Initial_Status_Grid2018) %>% summarise(investment=sum(InvestmentCost2025) + sum(InvestmentCost2030))

output_p$MinimumOverall2030 <- as.character(output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("2030", "", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("Grid", "Grid expansion", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- ifelse(output_p$Elec_Initial_Status_Grid2018==1, "Grid densification", output_p$MinimumOverall2030)

output_p$Adoption <- stringr::str_match(output_p$Demand, "_\\s*(.*?)\\s*_")[,2]
output_p$Climate <- sub('.*\\_', '', output_p$Demand)
output_p$BaseCons <- substr(output_p$Demand, 2, 3)

output_p$MinimumOverall2030_short <- substr(output_p$MinimumOverall2030, 1, 2)
output_p$MinimumOverall2030_short <- ifelse(output_p$MinimumOverall2030_short=="Gr", "Grid Expansion", ifelse(output_p$MinimumOverall2030_short=="MG", "Mini-grid", "Standalone system"))

output_p = filter(output_p, Adoption!="noAC" & Adoption!="S3")

output_p <- group_by(output_p, Demand, Climate, Adoption, BaseCons) %>% summarise(investment=sum(investment))

output_p$Climate <- factor(output_p$Climate, levels = c("base", "245", "370"))

levels(output_p$Climate) <- c("Hist. climate", "SSP245", "SSP370")

b<- ggplot(output_p, aes(x=Adoption, y=investment/1000000000, fill=Adoption))+
  theme_classic()+
  geom_boxplot()+
  xlab("")+
  ylab("Investment requirements mark-up (%)")+
  ggtitle("Universal electrification by 2030, sensitivity of investments to climate change")+
  scale_fill_brewer(name="Climate scenario", palette = "Set2")+
  theme(legend.position = "bottom", legend.direction = "horizontal", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  facet_wrap(vars(Climate), scales = "free")

output_p <- group_by(output_p, Adoption, BaseCons) %>% summarise(investment245=investment[1]/investment [3], investment370=investment[2]/investment[3])

output_p <- melt(output_p, key=c(1:2))

output_p$variable <- as.character(output_p$variable)
output_p$variable[1:6] <- "SSP245"
output_p$variable[7:12] <- "SSP370"

b2<- ggplot(output_p, aes(x=variable, y=value-1, fill=variable))+
  theme_classic()+
  geom_boxplot()+
  xlab("")+
  ylab("Investment markup compared \nto historical climate)")+
  ggtitle("Universal electrification by 2030, sensitivity of investments to climate change")+
  scale_fill_brewer(name="Climate scenario", palette = "Set2")+
  scale_y_continuous(labels=scales::label_percent(accuracy = 0.1))+
  theme(legend.position = "bottom", legend.direction = "horizontal", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  facet_wrap(vars(Adoption))

c <- plot_grid(a2, a3, b2, ncol = 1, labels="AUTO", rel_heights = c(1, 1, 1))

ggsave("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/supply_results.png", c, device="png", scale=0.95, height = 12, width = 7.5)

output_p <- group_by(output, Demand, MinimumOverall2030, Elec_Initial_Status_Grid2018) %>% summarise(investment=sum(InvestmentCost2025) + sum(InvestmentCost2030))

output_p$MinimumOverall2030 <- as.character(output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("2030", "", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("Grid", "Grid expansion", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- ifelse(output_p$Elec_Initial_Status_Grid2018==1, "Grid densification", output_p$MinimumOverall2030)

output_p$Adoption <- stringr::str_match(output_p$Demand, "_\\s*(.*?)\\s*_")[,2]
output_p$Climate <- sub('.*\\_', '', output_p$Demand)
output_p$BaseCons <- substr(output_p$Demand, 2, 3)

output_p$MinimumOverall2030_short <- substr(output_p$MinimumOverall2030, 1, 2)
output_p$MinimumOverall2030_short <- ifelse(output_p$MinimumOverall2030_short=="Gr", "Grid Expansion", ifelse(output_p$MinimumOverall2030_short=="MG", "Mini-grid", "Standalone system"))

output_p = filter(output_p, Adoption!="S3")

output_p <- group_by(output_p, Demand, Climate, Adoption) %>% summarise(investment=sum(investment))

output_p$Climate <- factor(output_p$Climate, levels = c("base", "245", "370"))

levels(output_p$Climate) <- c("Hist. climate", "SSP245", "SSP370")

View(output_p %>% group_by(Demand) %>% summarise(investment=sum(investment)/1e9))

# plot maps for each scenario 

base <- read_sf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/polygons_ssa_reprojected_area.gpkg')

list_results <- list.files(path = paste0(getwd(), "/results"), pattern = ".csv", full.names = F)
list_results <- list_results[!grepl('summary', list_results)]

path <- paste0(getwd(), "/results/")

for (scen in list_results){
  
  t43_S1_245 <- read.csv(paste0(path, scen))
  
  t43_S1_245 <- st_as_sf(t43_S1_245, coords = c("X_deg", "Y_deg"), crs=4326)
  
  t43_S1_245$MinimumOverall2030 <- gsub("2030", "", as.character(t43_S1_245$MinimumOverall2030))
  
  t43_S1_245$MinimumOverall2030 <- sub("\\_.*", "", t43_S1_245$MinimumOverall2030)
  
  bPols <- rnaturalearth::ne_countries(continent = "Africa", returnclass = "sf")
  
  grid <- st_make_grid(t43_S1_245, cellsize = .5, offset=c(min(t43_S1_245$X), min(t43_S1_245$Y)), crs=4326, what="polygons") %>% st_as_sf() %>% st_cast("POLYGON")
  
  grid <- st_join(grid, t43_S1_245) 
  
  grid <- grid[!duplicated(grid$geometry),]
  
  #grid$MinimumOverall2030 <- ifelse(grid$NoAccPop>10000, grid$MinimumOverall2030, NA)
  
 map1 <- ggplot()+
    theme_classic()+
    geom_sf(data=bPols, fill=NA, colour="black")+
    geom_sf(data=grid, aes(fill=as.factor(MinimumOverall2030)), colour=NA)+
    theme(legend.position = "bottom", legend.direction = "horizontal")+
    xlab("Longitude")+
    ylab("Latitude")+
    scale_fill_brewer(name="Technology set-up", palette = "Set1")+#, na.value="grey50")+
    ggtitle(gsub(".csv", "", scen))
  
  ggsave(paste0(gsub(".csv", "", scen), "_map.png"), map1, device="png", scale=1.75)
}

############
# Match scenarios
files <- list.files(path = paste0(getwd(), "/results"), pattern = ".csv", full.names = T)
files <- files[!grepl('summary', files)]

output <- lapply(files, read.csv)

for (i in 1:length(output)){
  output[[i]] <- output[[i]] %>% dplyr::select(-starts_with("Unnamed"), -starts_with("X."), -starts_with("Optional"))
}

output <- do.call(rbind, output)

output$Demand = unlist(lapply(1:length(files), function(i){rep(gsub(".csv", "", sub('.*\\/', '', files[i])), 8101)}))

output_p <- group_by(output, Demand) %>% summarise(investment=sum(InvestmentCost2025) + sum(InvestmentCost2030)) %>% ungroup()

output_p$Adoption <- stringr::str_match(output_p$Demand, "_\\s*(.*?)\\s*_")[,2]
output_p$Climate <- sub('.*\\_', '', output_p$Demand)
output_p$BaseCons <- substr(output_p$Demand, 2, 3)

# Calculate statistics of Delta
# Effect of tech adoption
output_p <- group_by(output, Demand, MinimumOverall2030, Elec_Initial_Status_Grid2018) %>% summarise(investment=sum(InvestmentCost2025) + sum(InvestmentCost2030))

output_p$MinimumOverall2030 <- as.character(output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("2030", "", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("Grid", "Grid expansion", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- ifelse(output_p$Elec_Initial_Status_Grid2018==1, "Grid densification", output_p$MinimumOverall2030)

output_p$Adoption <- stringr::str_match(output_p$Demand, "_\\s*(.*?)\\s*_")[,2]
output_p$Climate <- sub('.*\\_', '', output_p$Demand)
output_p$BaseCons <- substr(output_p$Demand, 2, 3)

output_p$MinimumOverall2030_short <- substr(output_p$MinimumOverall2030, 1, 2)
output_p$MinimumOverall2030_short <- ifelse(output_p$MinimumOverall2030_short=="Gr", "Grid Expansion", ifelse(output_p$MinimumOverall2030_short=="MG", "Mini-grid", "Standalone system"))

output_p = filter(output_p, Adoption!="S3")

output_p <- group_by(output_p, Demand, Climate, Adoption, BaseCons) %>% summarise(investment=sum(investment))

output_p$Climate <- factor(output_p$Climate, levels = c("base", "245", "370"))

levels(output_p$Climate) <- c("Hist. climate", "SSP245", "SSP370")


output_p <- group_by(output_p, Adoption, BaseCons) %>% summarise(investment=mean(investment))

output_p <- group_by(output_p, BaseCons) %>% summarise(investmentS0=investment[2]/investment [1], investmentS1=investment[3]/investment [1], investmentS2=investment[4]/investment[1])

output_p <- melt(output_p, key=c(1))

output_p$value <- output_p$value -1

output_p <- group_by(output_p, variable) %>% summarise(value=mean(value))

summary(output_p$value)


# Effect of climate
output_p$conc_group <-paste0(output_p$Adoption, output_p$BaseCons)

output_p %>% filter(Adoption!="noAC") %>%  group_by(conc_group, Climate) %>% summarise(a=mean(investment)) %>% group_by(conc_group) %>% mutate(b=(a/min(a))-1) %>% filter(b!=0) %>% group_by(conc_group) %>% summarise(min=min(b), max=max(b), mean=mean(b)) %>% ungroup() %>% summarise(min=mean(min), mean=mean(mean), max=mean(max))

#

output_p <- group_by(output, Demand, MinimumOverall2030) %>% summarise(connections=sum(NewConnections2030)) %>% ungroup()

output_p$MinimumOverall2030 <- as.character(output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("2030", "", output_p$MinimumOverall2030)
output_p$MinimumOverall2030 <- gsub("Grid", "Grid expansion", output_p$MinimumOverall2030)
#output_p$MinimumOverall2030 <- ifelse(output_p$Elec_Initial_Status_Grid2018==1, "Grid densification", output_p$MinimumOverall2030)

output_p$Adoption <- stringr::str_match(output_p$Demand, "_\\s*(.*?)\\s*_")[,2]
output_p$Climate <- sub('.*\\_', '', output_p$Demand)
output_p$BaseCons <- substr(output_p$Demand, 2, 3)

output_p$MinimumOverall2030_short <- substr(output_p$MinimumOverall2030, 1, 2)
output_p$MinimumOverall2030_short <- ifelse(output_p$MinimumOverall2030_short=="Gr", "Grid Expansion", ifelse(output_p$MinimumOverall2030_short=="MG", "Mini-grid", "Standalone system"))

output_p$conc_group <-paste0(output_p$Climate, output_p$BaseCons)

output_p %>% filter(Adoption!="S3") %>% group_by(conc_group, Adoption, MinimumOverall2030_short) %>% summarise(a=mean(connections)) %>% mutate(share=a/sum(a))%>% ungroup() %>%  group_by(conc_group, MinimumOverall2030_short) %>% mutate(b= share - share[Adoption=="noAC"]) %>% filter(MinimumOverall2030_short!="Grid Expansion") %>% ungroup() %>% group_by(conc_group, Adoption) %>% summarise(b=sum(b)) %>% filter(b!=0) %>% ungroup() %>%  summarise(min=min(b), mean=mean(b), max=max(b))*100


## Map of average change 

base <- read_sf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/polygons_ssa_reprojected_area.gpkg')

list_results <- list.files(path = paste0(getwd(), "/results"), pattern = ".csv", full.names = F)
list_results <- list_results[!grepl('summary', list_results)]

path <- paste0(getwd(), "/results/")

t32_noAC_245 <- read.csv(paste0(path, "t32_noAC_245.csv"))
#t32_noAC_245 <- bind_cols(base, t32_noAC_245)
t32_noAC_245$MinimumOverall2030 <- gsub("2030", "", as.character(t32_noAC_245$MinimumOverall2030))
t32_noAC_245$MinimumOverall2030 <- ifelse(t32_noAC_245$NoAccPop>5000, t32_noAC_245$MinimumOverall2030, NA)
t32_noAC_245$MinimumOverall2030 <- sub("\\_.*", "", t32_noAC_245$MinimumOverall2030)

t32_S2_370 <- read.csv(paste0(path, "t32_S2_370.csv"))
#t32_S2_370 <- bind_cols(base, t32_S2_370)
t32_S2_370$MinimumOverall2030 <- gsub("2030", "", as.character(t32_S2_370$MinimumOverall2030))
t32_S2_370$MinimumOverall2030 <- ifelse(t32_S2_370$NoAccPop>5000, t32_S2_370$MinimumOverall2030, NA)
t32_S2_370$MinimumOverall2030 <- sub("\\_.*", "", t32_S2_370$MinimumOverall2030)

t32_noAC_245$AC="NO"
t32_S2_370$AC="YES"

#t32_S2_370$geom=NULL

t32_S2_370 <- dplyr::select(t32_S2_370, AC, MinimumOverall2030, X_deg, Y_deg, X, Y)
t32_noAC_245 <- dplyr::select(t32_noAC_245, AC, MinimumOverall2030)

merger <- bind_cols(t32_noAC_245, t32_S2_370)

merger <- st_as_sf(merger, coords = c("X_deg", "Y_deg"), crs=4326)

grid <- st_make_grid(merger, cellsize = .5, offset=c(min(merger$X), min(merger$Y)), crs=4326, what="polygons") %>% st_as_sf() %>% st_cast("POLYGON")
grid <- st_join(grid, merger) 
merger <- grid[!duplicated(grid$geometry),]

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

#

## Map of average change 

base <- read_sf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/polygons_ssa_reprojected_area.gpkg')

list_results <- list.files(path = paste0(getwd(), "/results"), pattern = ".csv", full.names = F)
list_results <- list_results[!grepl('summary', list_results)]

path <- paste0(getwd(), "/results/")

t43_noAC_245 <- read.csv(paste0(path, "t43_noAC_245.csv"))
#t43_noAC_245 <- bind_cols(base, t43_noAC_245)
t43_noAC_245$MinimumOverall2030 <- gsub("2030", "", as.character(t43_noAC_245$MinimumOverall2030))
t43_noAC_245$MinimumOverall2030 <- ifelse(t43_noAC_245$NoAccPop>5000, t43_noAC_245$MinimumOverall2030, NA)
t43_noAC_245$MinimumOverall2030 <- sub("\\_.*", "", t43_noAC_245$MinimumOverall2030)

t43_S2_370 <- read.csv(paste0(path, "t43_S2_370.csv"))
#t43_S2_370 <- bind_cols(base, t43_S2_370)
t43_S2_370$MinimumOverall2030 <- gsub("2030", "", as.character(t43_S2_370$MinimumOverall2030))
t43_S2_370$MinimumOverall2030 <- ifelse(t43_S2_370$NoAccPop>5000, t43_S2_370$MinimumOverall2030, NA)
t43_S2_370$MinimumOverall2030 <- sub("\\_.*", "", t43_S2_370$MinimumOverall2030)

t43_noAC_245$AC="NO"
t43_S2_370$AC="YES"

#t43_S2_370$geom=NULL

t43_S2_370 <- dplyr::select(t43_S2_370, AC, MinimumOverall2030, X_deg, Y_deg, X, Y)
t43_noAC_245 <- dplyr::select(t43_noAC_245, AC, MinimumOverall2030)

merger <- bind_cols(t43_noAC_245, t43_S2_370)

merger <- st_as_sf(merger, coords = c("X_deg", "Y_deg"), crs=4326)

grid <- st_make_grid(merger, cellsize = .5, offset=c(min(merger$X), min(merger$Y)), crs=4326, what="polygons") %>% st_as_sf() %>% st_cast("POLYGON")
grid <- st_join(grid, merger) 
merger <- grid[!duplicated(grid$geometry),]

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
  ggtitle("Shift in optimal electrification system (t43_noAC to t43_S2_370)")

ggsave("map3b.png", map3, device="png", scale=1.5)
