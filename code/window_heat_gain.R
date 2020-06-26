#http://www.marmottenergies.com/much-sun-heat-house/

# import solar radiation monthly raster stack
sol_rad <- stack('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/solar_irr/monthy_global_solar_radiation.tif')

# calculate solar altitude and azimuth angle at four time steps per day

# coords <- data.frame(rasterToPoints(overlay_current[[1]]))
# 
# times <- as.POSIXct(seq(ISOdate(2019,1,1, tz="UTC"), by = "1 hour", length.out = 8760))
# 
# times <- times[grepl("16:00:00", times) & grepl("-15", times)]
# azimuth_list <- list()
# 
# for (i in 1:length(times)){
# f <-function(lat, lon){
#   one<-180 + getSunlightPosition(times[i] - tz_offset(times[i], tz_lookup_coords(lat, lon, method = "fast"))$utc_offset_h * 3600, lat, lon, keep = c("azimuth"))$azimuth/(pi/180)
#   return(one)
# }
# 
# azimuth <- mapply(f, coords$y, coords$x)
# 
# azimuth_list[[i]] <- azimuth
# 
# }
# 
# #
# 
# k = list()
# 
# for (i in 1:length(azimuth_list)){
# 
#   k[[i]] <-  overlay_current[[1]]
#   values(k[[i]])[!is.na(values(k[[i]]))]<-azimuth_list[[i]]
# 
# }
# 
# azimuth = stack(k)
# 
# #
# 
# altitude_list <- list()
# 
# for (i in 1:length(times)){
#   f <-function(lat, lon){
#     one<-getSunlightPosition(times[i] - tz_offset(times[i], tz_lookup_coords(lat, lon, method = "fast"))$utc_offset_h * 3600, lat, lon, keep = c("altitude"))$altitude/(pi/180)
#     return(one)
#   }
# 
#   altitude <- mapply(f, coords$y, coords$x)
# 
#   altitude_list[[i]] <- altitude
# 
# }
# 
# #
# 
# k = list()
# 
# for (i in 1:length(altitude_list)){
# 
#   k[[i]] <-  overlay_current[[1]]
#   values(k[[i]])[!is.na(values(k[[i]]))]<-altitude_list[[i]]
# 
# }
# 
# altitude = stack(k)
# 
# writeRaster(altitude, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/solar_irr/altitude.tif", overwrite=T)
# writeRaster(azimuth, "D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/solar_irr/azimuth.tif", overwrite=T)

altitude <- stack("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/solar_irr/altitude.tif")
azimuth <- stack("D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/solar_irr/azimuth.tif")

# minimum threhold to avoid dividing by 0
values(altitude) <- ifelse(values(altitude)<2, NA, values(altitude))

altitude <- stack(altitude)
azimuth <- stack(azimuth)

#The conversion factors which convert data for sun intensity on the horizontal to data for sun intensity falling directly on a particular vertical face.

altitude = resample(altitude, sol_rad, method='bilinear')

values(sol_rad) <- ifelse(values(sol_rad)<0, 0, values(sol_rad))

tan_altitude = stack(altitude)

degrees_to_radians <- pi/180

Iv=stack(sol_rad/(tan(altitude*degrees_to_radians)/degrees_to_radians))

#The angle which determines what proportion of the sun will fall on each wall is the angle between the sun's azimuthal direction and the face of the wall.

angle_diff <- function(theta1, theta2){
  theta <- abs(theta1 - theta2) %% 360 
  return(ifelse(theta > 180, 360 - theta, theta))
}

d1 <- calc(azimuth, fun=function(X){ angle_diff(180, X)})
d2 <- calc(azimuth, fun=function(X){ angle_diff(270, X)})
d3 <- calc(azimuth, fun=function(X){ angle_diff(360, X)})
d4 <- calc(azimuth, fun=function(X){ angle_diff(90, X)})

# North
I1=stack(sin(((d1))*degrees_to_radians)/degrees_to_radians)
values(I1) <- ifelse(values(I1<0), 0, values(I1))

# East
I2=stack(sin((d2)*degrees_to_radians)/degrees_to_radians)
values(I2) <- ifelse(values(I2<0), 0, values(I2))

# South
I3=stack(sin((d3)*degrees_to_radians)/degrees_to_radians)
values(I3) <- ifelse(values(I3)<0, 0, values(I3))

# West
I4=stack(sin((d4)*degrees_to_radians)/degrees_to_radians)
values(I4) <- ifelse(values(I4<0), 0, values(I4))

#We now multiply the 'solar intensity on the horizontal' data by the conversion factors calculated above to get data for 'solar intensity on each face of the house'

Iv <- projectRaster(Iv, I1)

sol_rad_1 <- stack(Iv * I1)
sol_rad_2 <- stack(Iv * I2)
sol_rad_3 <- stack(Iv * I3)
sol_rad_4 <- stack(Iv * I4)

#We then convert those intensities to the powers and energies that we are really interested in. To go from the intensity of the light falling on the wall (W/m²) to the power of the sunlight hitting the windows, we multiply the intensity by the window areas. Only a fraction of the sunlight that hits the window will pass through it. The proportion of the sunlight that will pass through the window is defined by the solar heat gain coefficient. It is a property of the window itself. So to get the solar power passing through the windows, we just multiply the values for the power hitting the windows by the solar heat gain coefficient.

kw_imh_1 <- stack(sol_rad_1*m2_windows_urban*k_solar_heat_gain/1000)
kw_imh_2 <- stack(sol_rad_2*m2_windows_urban*k_solar_heat_gain/1000)
kw_imh_3 <- stack(sol_rad_3*m2_windows_urban*k_solar_heat_gain/1000)
kw_imh_4 <- stack(sol_rad_4*m2_windows_urban*k_solar_heat_gain/1000)

#Finally we need to integrate the powers with respect to time to get the energies. The plot below shows the solar energy entering the house through the windows on each face of a building each day

# average joule from the window every hour of the day of month m at location i
j_imh_1 <- stack(3600000 * kw_imh_1)
j_imh_2 <- stack(3600000 * kw_imh_2)
j_imh_3 <- stack(3600000 * kw_imh_3)
j_imh_4 <- stack(3600000 * kw_imh_4)

# when keeping cold, the compressor is on every hour the fraction j_imh / j_per_hour
compressor_share_time_on_urban <- stack(j_imh_2 / (CC_urban*cooling_ton_to_kw*kw_to_j_per_hour)) # j/hour / j removed in one hour
values(compressor_share_time_on_urban) <- ifelse(values(compressor_share_time_on_urban)>1, 1, values(compressor_share_time_on_urban))

compressor_share_time_on_rural <- stack(j_imh_2 / (CC_rural*cooling_ton_to_kw*kw_to_j_per_hour)) # j/hour / j removed in one hour
values(compressor_share_time_on_rural) <- ifelse(values(compressor_share_time_on_rural)>1, 1, values(compressor_share_time_on_rural))

