# sens over base t 

for (i in T_base_sens){
  
  print(paste("Running", i))
  
  base_temp <- i
  
  # process the CDD and noaccess data (to produce variants with different base T)
  source("code/data_process_gldas.R", echo=F)
  
  # estimate power requirements
  source("code/electricity.R", echo=F)
  
  # estimate co2 emissions
  source("code/emissions.R", echo=F)
  
}

# sens over AC unit efficiency

for (i in 1:3){
  
  print(paste("Running", i))
  
  base_temp <- 26
  
  EER_urban <- EER_urban_sens[i]
  
  EER_rural <- EER_rural_sens[i]
  
  # process the CDD and noaccess data (to produce variants with different base T)
  source("code/data_process_gldas.R", echo=F)
  
  # estimate power requirements
  source("code/electricity.R", echo=F)
  
  # estimate co2 emissions
  source("code/emissions.R", echo=F)
  
}
