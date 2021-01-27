# sens over base t 

for (temp_sens in T_base_sens){
  
  print(paste("Running", temp_sens))
  
  base_temp <- temp_sens
  
  # process the CDD and noaccess data (to produce variants with different base T)
  source("code/data_process_2.R", echo=F)
  
  # calculate heat entering houses from windows
  source("code/window_heat_gain.R", echo=F)
  
  # estimate power requirements
  source("code/electricity_new_ssp.R", echo=F)
  
  # estimate co2 emissions
  source("code/emissions.R", echo=F)
  
}

# sens over AC unit efficiency

for (eer_sens in 1:3){
  
  print(paste("Running", eer_sens))
  
  base_temp <- 26
  
  EER_urban <- EER_urban_sens[eer_sens]
  
  EER_rural <- EER_rural_sens[eer_sens]
  
  # process the CDD and noaccess data (to produce variants with different base T)
  source("code/data_process_2.R", echo=F)
  
  # calculate heat entering houses from windows
  source("code/window_heat_gain.R", echo=F)
  
  # estimate power requirements
  source("code/electricity_new_ssp.R", echo=F)
  
  # estimate co2 emissions
  source("code/emissions.R", echo=F)
  
}
