#Figures 1-2-3

#Figure 1
#1A map of current CDDs among unelectrified

names(overlay_current) <- month.abb
names(overlay_245) <- month.abb
names(overlay_370) <- month.abb

png("CDD_today.png", width=1600, height=800, res=150)
print(levelplot(overlay_current, xlim=c(-100, 180), ylim=c(-40, 45),
                main="CDDs in areas without electr. access, base T 26° C, 1970-2000", at=my.at, colorkey=myColorkey,  par.settings = YlOrRdTheme, xlab="Longitude", ylab="Latitude") + layer(sp.polygons(bPols)))
dev.off()



#1B map of RCP2.6 CDDs among unelectrified
png("CDD_245.png", width=1600, height=800, res=150)
print(levelplot(overlay_245, xlim=c(-100, 180), ylim=c(-40, 45),
                main="CDDs in areas without electr. access, base T 26° C, 2041-2060, SSP245", at=my.at, colorkey=myColorkey,  par.settings = YlOrRdTheme, xlab="Longitude", ylab="Latitude") + layer(sp.polygons(bPols)))
dev.off()

#1C map of RCP4.5 CDDs among unelectrified
png("CDD_370.png", width=1600, height=800, res=150)
print(levelplot(overlay_370, xlim=c(-100, 180), ylim=c(-40, 45),
                main="CDDs in areas without electr. access, base T 26° C, 2041-2060, SSP370", at=my.at, colorkey=myColorkey,  par.settings = YlOrRdTheme, xlab="Longitude", ylab="Latitude") + layer(sp.polygons(bPols)))
dev.off()

###

png("CDD_density.png", width=1600, height=800, res=150)
bwplot(overlay_current, main="Distribution of CDDs, base T 26° C, 1970-2000", xlab="Month", ylab="Monthly CDDs")
dev.off()

png("CDD_density_245.png", width=1600, height=800, res=150)
bwplot(overlay_245, main="Distribution of CDDs, base T 26° C, 2041-2060, SSP245", xlab="Month", ylab="Monthly CDDs")
dev.off()

png("CDD_density_370.png", width=1600, height=800, res=150)
bwplot(overlay_370, main="Distribution of CDDs, base T 26° C, 2041-2060, SSP370", xlab="Month", ylab="Monthly CDDs")
dev.off()

# Figure 2 
global_shape<-read_sf('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/CLEXREL/Data/gadm36_levels_shp/gadm36_0.shp')
CDDs_extract<-exact_extract(overlay_current, global_shape, weights=noacc18, 'weighted_sum', progress=TRUE)
CDDs_245_extract<-exact_extract(overlay_245, global_shape, weights=noacc18, 'weighted_sum', progress=TRUE)
CDDs_370_extract<-exact_extract(overlay_370, global_shape, weights=noacc18, 'weighted_sum', progress=TRUE)
noacc_extract<-exact_extract(noacc18, global_shape, 'sum', progress=TRUE)

global = as.data.frame(global_shape)
global$geometry=NULL
global = cbind(global, CDDs_extract, CDDs_245_extract, CDDs_370_extract, noacc_extract)
global$continent = countrycode(global$GID_0, "iso3c", "region")

global = subset(global, global$noacc_extract>500000)

#2A country-level

global$CDDs_baseline = rowSums(global[,3:14])

deficit_bar_abs = ggplot() + 
  theme_classic()+
  geom_col(data = global, aes(x = GID_0 , y = CDDs_baseline/1000000, fill = continent)) +
  theme(axis.text.x = element_text(angle = 90, size=8), legend.position="none", plot.title = element_text(hjust = 0.5))+
  scale_fill_discrete(name = "Region")+
  #ggtitle("")+
  ylab("Million CDDs (weighted \n by pop. without electr. access)")+
  xlab("")

deficit_bar_rel = ggplot() + 
  theme_classic()+
  geom_col(data = global, aes(x = GID_0 , y = CDDs_baseline/noacc_extract, fill = continent)) +
  theme(axis.text.x = element_text(angle = 90, size=8), legend.position="none", plot.title = element_text(hjust = 0.5))+
  scale_fill_discrete(name = "Region")+
  #ggtitle("")+
  ylab("CDDs per person \nwithout access")+
  xlab("")

#2C country-level relative change in CDDs per capita for unelectrified due to climate change

global$CDDs_370 = rowSums(global[,27:38])

change_bar_abs = ggplot() + 
  theme_classic()+
  geom_col(data = global, aes(x = GID_0 , y = (CDDs_370 - CDDs_baseline)/1000000, fill = continent)) +
  theme(axis.text.x = element_text(angle = 90, size=8), legend.position="bottom", legend.direction = "horizontal", plot.title = element_text(hjust = 0.5))+
  scale_fill_discrete(name = "Region")+
  #ggtitle("")+
  ylab("Change in million \nCDDs (current-SSP370)")+
  xlab("")

legend = cowplot::get_legend(change_bar_abs)

ggsave("Figure 2.png", cowplot::plot_grid(cowplot::plot_grid(deficit_bar_abs, deficit_bar_rel, change_bar_abs + theme(legend.position = "none"), labels = "AUTO", ncol = 1), legend, ncol = 1, rel_heights = c(1, 0.1)), device = "png", scale=1.7, height = 5, width = 4)

# Figue 3: lorenz curve
CDDs_year <-sum(overlay_current, na.rm = T)
lorenz_data <- stack(noacc18, CDDs_year, world_raster)

lorenz_data <- as.data.frame(getValues(lorenz_data))

lorenz_data = group_by(lorenz_data, layer.2) %>% mutate(layer.1 = layer.1*(noacc18/sum(noacc18, na.rm=T)))

# parse country numbers to ISO codes

world_merger <- world %>%  dplyr::select(id, GID_0)
world_merger$geometry = NULL
lorenz_data<-merge(lorenz_data, world_merger, by.x="layer.2", by.y="id", all.x=T)

# select key countries
lorenz_data_global <- lorenz_data
lorenz_data_global$GID_0 <- "Global"

lorenz_data <- rbind(lorenz_data, lorenz_data_global)

lorenz_data$continent = countrycode(lorenz_data$GID_0, "iso3c", "continent")
lorenz_data$continent = ifelse(lorenz_data$GID_0 == "Global", "Global", lorenz_data$continent)

lorenz_data$global <- ifelse(lorenz_data$continent == "Global", 1, 0)

lorenz_data = lorenz_data[!is.na(lorenz_data$continent), ]

lorenz = ggplot(subset(lorenz_data, lorenz_data$layer.1>0)) + 
  theme_classic()+ 
  gglorenz::stat_lorenz(aes(layer.1, group=as.factor(continent), colour=as.factor(continent)), size=1, alpha=0.75)+
  xlab("Cumulative fraction of the population without access")+
  ylab("Cumulative fraction of the total CDDs \n (weighted by pop. without access)")+
  geom_abline(linetype = "dashed") +
  theme_minimal()+
  scale_x_continuous(labels = scales::percent_format())+
  scale_y_continuous(labels = scales::percent_format())+
  scale_color_brewer(name="Region", palette = "Set1")

ggsave("Figure 3.png", lorenz, device = "png", scale=1)


