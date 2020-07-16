library(foreign)

sf <- read.dbf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Prod_Uses_Agriculture/Repo/onsset/input/Assist2/Hydrodist_5.dbf')

sf$Hydropower <- sf$Hydropower * 1000

write.dbf(sf, 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Prod_Uses_Agriculture/Repo/onsset/input/Assist2/Hydrodist_5.dbf')

sf <- read.dbf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Prod_Uses_Agriculture/Repo/onsset/input/Assist2/iter8.dbf')

sf$Transforme = 0
sf$PL_MV = 0

sf$elrate <- 1 - (sf$noaccsum/sf$pop2015SSA)

sf$elrate <- ifelse(sf$elrate==-Inf, NA, sf$elrate)
sf$elrate <- ifelse(sf$elrate<0, 0, sf$elrate)

sf$traveltime= sf$traveltime / 60 # CHECK
sf$ElecPop= sf$pop2015SSA * sf$elrate # CHECK
sf$ElecPop = ifelse(sf$ElecPop < 0, 0, sf$ElecPop)

sf$Conflict= 0
sf$ResidentialDemandTierCustom= 0
sf$Country="SSA"
sf$ElectrificationOrder= 0
sf$traveltime = ifelse(sf$traveltime < 0, 0, sf$traveltime)

sf[is.na(sf)] <- 0

write.dbf(sf, 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Prod_Uses_Agriculture/Repo/onsset/input/Assist2/iter8.dbf')

sf <- read_sf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/polygons_ssa.shp')

# urbrur
urbrur<-raster("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/urbrur.tif")

sf$IsUrban <- exactextractr::exact_extract(urbrur, sf, 'majority')

# hh size
sf$NumPeoplePerHH <- exactextractr::exact_extract(hhsize_raster, sf, 'mean')

sf2 <- read.dbf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Prod_Uses_Agriculture/Repo/onsset/input/Assist2/iter8.dbf')

sf2$IsUrban <- sf$IsUrban
  
sf2$NumPeoplePerHH <- sf$NumPeoplePerHH

colnames(sf2)

sf2$fid = NULL
sf2$VALUE = NULL

colnames(sf2) <- c("Pop", "NoAccPop", "GridCellArea", "ID", "WindVel", "GHI", "TravelHours", "Elevation", "Slope", "LandCover", "NightLights", "SubstationDist", "CurrentHVLineDist", "PlannedHVLineDist", "CurrentMVLineDist", "RoadDist", "Hydropower", "HydropowerFID", "HydropowerDist", "X_deg", "Y_deg", "X", "Y", "TransformerDist", "PlannedMVLineDist", "Elrate", "ElecPop", "Conflict", "ResidentialDemandTierCustom", "Country", "ElectrificationOrder", "IsUrban", "NumPeoplePerHH")

sf2$AgriDemand <- 0
sf2$EducationDemand <- 0
sf2$HealthDemand <- 0
sf2$PerCapitaDemand <- 0
sf2$CropProcessingDemand <- 0

write.dbf(sf2, 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Prod_Uses_Agriculture/Repo/onsset/input/Assist2/iter8.dbf')

write.csv(sf2, 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv')

