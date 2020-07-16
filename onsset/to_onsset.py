# Working directory
import datetime
import time
then = time.time()

input_folder = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Prod_Uses_Agriculture/PrElGen_database/input_folder/'
processed_folder = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Prod_Uses_Agriculture/PrElGen_database/processed_folder/'
home_repo_folder = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Prod_Uses_Agriculture/Repo/'
pythonfolder = 'C:/OSGeo4W64/apps/Python37'

gadm0 = QgsVectorLayer('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Inequal accessibility to services in sub-Saharan Africa/gadm_africa.shp',"","ogr")

clusters_final = QgsVectorLayer('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/polygons_ssa.shp',"","ogr")

# Define input files for the supply side (energy)
elevation = QgsRasterLayer(home_repo_folder + r'/onsset/input/elevation.tif')
ghi = QgsRasterLayer(home_repo_folder + r'/onsset/input/ghi.tif')
travel = QgsRasterLayer(home_repo_folder + r'/onsset/input/travel.tif')
windvel = QgsRasterLayer(home_repo_folder + r'/onsset/input/windvel.tif')
land_cover = QgsRasterLayer(home_repo_folder + r'/onsset/input/land_cover.tif')
night_ligths = QgsRasterLayer(home_repo_folder + r'/onsset/input/nightlights.tif')
urban_rural = QgsRasterLayer(home_repo_folder + r'/onsset/input/ghs_layer_smod_2015.tif')
slope = QgsRasterLayer(home_repo_folder + r'/onsset/input/slope.tif')

substations = QgsVectorLayer(home_repo_folder + r'/onsset/input/substations.shp', "", "ogr")
#transformers = QgsVectorLayer(home_repo_folder + r'/onsset/input/transformers.shp', "", "ogr")
existing_HV = QgsVectorLayer(home_repo_folder + r'/onsset/input/existing_HV.shp', "", "ogr")
existing_MV = QgsVectorLayer(home_repo_folder + r'/onsset/input/existing_MV.shp', "", "ogr")
planned_HV = QgsVectorLayer(home_repo_folder + r'/onsset/input/planned_HV.shp', "", "ogr")
#planned_MV = QgsVectorLayer(home_repo_folder + r'/onsset/input/planned_MV.shp', "", "ogr")
roads = QgsVectorLayer(home_repo_folder + r'/onsset/input/roads.shp', "", "ogr")
hydro_points = QgsVectorLayer(home_repo_folder + r'/onsset/input/hydro_points.shp', "", "ogr")

# None layers
transformers = None
planned_MV = None

workspace = home_repo_folder + r'/onsset/input/'
settlements_fc = "SSA"
countryiso3 = settlements_fc
projCord = 'EPSG:4326'
hydropowerField = 'PowerMW'
hydropowerFieldUnit = 'MW'  # ["W", "kW", "MW"]

# Run data preparation script (credits to Babak Khavari, KTH https://github.com/KTH-dESA/Cluster-based_extraction_OnSSET)

sys.path.insert(0, './onsset/prepare')

# Prepare data for OnSSET
import os.path

# Create folder structure
if not os.path.exists(workspace + r"/Assist"):
    os.makedirs(workspace + r"/Assist")

if not os.path.exists(workspace + r"/Assist2"):
    os.makedirs(workspace + r"/Assist2")

if not os.path.exists(workspace + r"/DEM"):
    os.makedirs(workspace + r"/DEM")

if not os.path.exists(workspace + r"/Hydropower"):
    os.makedirs(workspace + r"/Hydropower")

if not os.path.exists(workspace + r"/Land_Cover"):
    os.makedirs(workspace + r"/Land_Cover")

if not os.path.exists(workspace + r"/Customimized demand"):
    os.makedirs(workspace + r"/Customimized demand")

if not os.path.exists(workspace + r"/Population_2015"):
    os.makedirs(workspace + r"/Population_2015")

if not os.path.exists(workspace + r"/Roads"):
    if roads != None:
        os.makedirs(workspace + r"/Roads")

if not os.path.exists(workspace + r"/Slope"):
    os.makedirs(workspace + r"/Slope")

if not os.path.exists(workspace + r"/Solar"):
    os.makedirs(workspace + r"/Solar")

if not os.path.exists(workspace + r"/Transformers"):
    if transformers != None:
        os.makedirs(workspace + r"/Transformers")

if not os.path.exists(workspace + r"/Substations"):
    if substations != None:
        os.makedirs(workspace + r"/Substations")

if not os.path.exists(workspace + r"/HV_Network"):
    if planned_HV or existing_HV != None:
        os.makedirs(workspace + r"/HV_Network")

if not os.path.exists(workspace + r"/MV_Network"):
    if planned_MV or existing_MV != None:
        os.makedirs(workspace + r"/MV_Network")

if not os.path.exists(workspace + r"/Travel_time"):
    os.makedirs(workspace + r"/Travel_time")

if not os.path.exists(workspace + r"/Wind"):
    os.makedirs(workspace + r"/Wind")

if not os.path.exists(workspace + r"/Night_lights"):
    os.makedirs(workspace + r"/Night_lights")

# Define assisting folder
assistingFolder = workspace + r"/Assist"
assistingFolder2 = workspace + r"/Assist2"

# Administrative boundaries
admin = gadm0

# Population clusters
Pop = clusters_final

# Define the extent of the clusters shapefile

ext = admin.extent()

xmin = ext.xMinimum() - 1
xmax = ext.xMaximum() + 1
ymin = ext.yMinimum() - 1
ymax = ext.yMaximum() + 1

coords = '{},{},{},{}'.format(xmin, xmax, ymin, ymax)

#########################
# Centroids and points stuff
########################
Pop = QgsVectorLayer('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/polygons_ssa_reprojected_area.gpkg',"","ogr")

print('Creating point layer for clusters larger than one sq. km. (100 ha)', 'Time:', datetime.datetime.now().time())
processing.run("qgis:selectbyexpression", {
    'INPUT': Pop, 'EXPRESSION': '"Area">=1', 'METHOD': 0})

processing.run("native:saveselectedfeatures", {
    'INPUT': Pop,
    'OUTPUT': workspace + r'/Population_2015/pop2015_large.shp'})

processing.run("qgis:pointsalonglines", {
    'INPUT': workspace + r'/Population_2015/pop2015_large.shp',
    'DISTANCE': 1000, 'START_OFFSET': 0, 'END_OFFSET': 0,
    'OUTPUT': assistingFolder + r"/virtualpoints1.shp"})

settlement_points = QgsVectorLayer(assistingFolder + r'/virtualpoints1.shp', '', 'ogr')

#########################
# Rasters processing
########################
print('Processing the DEM and slope maps.', 'Time:', datetime.datetime.now().time())
processing.run("gdal:fillnodata",
               {'INPUT': slope, 'BAND': 1,
                'DISTANCE': 50, 'ITERATIONS': 0, 'NO_MASK': False, 'MASK_LAYER': None,
                'OUTPUT': assistingFolder2 + r'/slope.tif'})
processing.run("gdal:fillnodata",
               {'INPUT': elevation, 'BAND': 1,
                'DISTANCE': 50, 'ITERATIONS': 0, 'NO_MASK': False, 'MASK_LAYER': None,
                'OUTPUT': assistingFolder2 + r'/elevation.tif'})
print('Processing the GHI map.', 'Time:', datetime.datetime.now().time())
processing.run("gdal:fillnodata",
               {'INPUT': ghi, 'BAND': 1,
                'DISTANCE': 50, 'ITERATIONS': 0, 'NO_MASK': False, 'MASK_LAYER': None,
                'OUTPUT': assistingFolder2 + r'/ghi.tif'})
print('Processing the traveltime map.', 'Time:', datetime.datetime.now().time())
processing.run("gdal:fillnodata",
               {'INPUT': travel,
                'BAND': 1, 'DISTANCE': 50, 'ITERATIONS': 0, 'NO_MASK': False, 'MASK_LAYER': None,
                'OUTPUT': assistingFolder2 + r'/travel.tif'})
print('Processing the wind speed map.', 'Time:', datetime.datetime.now().time())
processing.run("gdal:fillnodata",
               {'INPUT': windvel, 'BAND': 1,
                'DISTANCE': 50, 'ITERATIONS': 0, 'NO_MASK': False, 'MASK_LAYER': None,
                'OUTPUT': assistingFolder2 + r'/windvel.tif'})
print('Processing the landcover map.', 'Time:', datetime.datetime.now().time())
parameters = {'INPUT_A': land_cover,
              'BAND_A': 1,
              'FORMULA': '(A/(A>-1))',
              'OUTPUT': workspace + r'/Land_Cover/land_cover_' + countryiso3 + '2.tif'}
processing.run('gdal:rastercalculator', parameters)
print('Processing the night ligths map.', 'Time:', datetime.datetime.now().time())
processing.run("gdal:fillnodata",
               {'INPUT': night_ligths, 'BAND': 1,
                'DISTANCE': 50, 'ITERATIONS': 0, 'NO_MASK': False, 'MASK_LAYER': None,
                'OUTPUT': assistingFolder2 + r'/nightlights.tif'})

traveltime = QgsRasterLayer(assistingFolder2 + r'/travel.tif', 'traveltime')
windvel = QgsRasterLayer(assistingFolder2 + r'/windvel.tif', 'windvel')
solar = QgsRasterLayer(assistingFolder2 + r'/ghi.tif', 'solar')
elevation = QgsRasterLayer(assistingFolder2 + r'/elevation.tif', 'elevation')
slope = QgsRasterLayer(assistingFolder2 + r'/slope.tif', 'slope')
landcover = QgsRasterLayer(workspace + r'/Land_Cover/land_cover_' + countryiso3 + '2.tif', 'landcover')
night_ligths = QgsRasterLayer(assistingFolder2 + r'/nightlights.tif', 'nightlights')

print('Add wind speeds to the clusters.', 'Time:', datetime.datetime.now().time())
processing.run("qgis:zonalstatistics", {'INPUT_RASTER': windvel, 'RASTER_BAND': 1, 'INPUT_VECTOR': Pop,
                                        'COLUMN_PREFIX': 'windveloci', 'STATS': [2]})
print('Add GHI to the clusters.', 'Time:', datetime.datetime.now().time())
processing.run("qgis:zonalstatistics", {'INPUT_RASTER': solar, 'RASTER_BAND': 1, 'INPUT_VECTOR': Pop,
                                        'COLUMN_PREFIX': 'ghisolarad', 'STATS': [2]})
print('Add travel time to the clusters.', 'Time:', datetime.datetime.now().time())
processing.run("qgis:zonalstatistics", {'INPUT_RASTER': traveltime, 'RASTER_BAND': 1, 'INPUT_VECTOR': Pop,
                                        'COLUMN_PREFIX': 'traveltime', 'STATS': [2]})
print('Add elevation to the clusters.', 'Time:', datetime.datetime.now().time())
processing.run("qgis:zonalstatistics", {'INPUT_RASTER': elevation, 'RASTER_BAND': 1, 'INPUT_VECTOR': Pop,
                                        'COLUMN_PREFIX': 'elevationm', 'STATS': [2]})
print('Add slope to the clusters.', 'Time:', datetime.datetime.now().time())
processing.run("qgis:zonalstatistics", {'INPUT_RASTER': slope, 'RASTER_BAND': 1, 'INPUT_VECTOR': Pop,
                                        'COLUMN_PREFIX': 'terraslope', 'STATS': [9]})
print('Add land cover to the clusters.', 'Time:', datetime.datetime.now().time())
processing.run("qgis:zonalstatistics", {'INPUT_RASTER': landcover, 'RASTER_BAND': 1, 'INPUT_VECTOR': Pop,
                                        'COLUMN_PREFIX': 'landcoverm', 'STATS': [9]})
print('Add night lights to the clusters.', 'Time:', datetime.datetime.now().time())
processing.run("qgis:zonalstatistics", {'INPUT_RASTER': night_ligths, 'RASTER_BAND': 1, 'INPUT_VECTOR': Pop,
                                        'COLUMN_PREFIX': 'nightlight', 'STATS': [6]})
input = Pop

########################
# Vectors
########################

#########
# Substations
#########
if substations != None:
print('Processing the substations.', 'Time:', datetime.datetime.now().time())
processing.run("native:clip", {'INPUT': substations, 'OVERLAY': admin, 'OUTPUT': workspace + r'/Substations/Substations' + countryiso3 + '.shp'})
processing.run("qgis:fieldcalculator", {'INPUT': workspace + r'/Substations/Substations' + countryiso3 + '.shp', 'FIELD_NAME': 'AUTO', 'FIELD_TYPE': 1, 'FIELD_LENGTH': 10, 'NEW_FIELD': True, 'FORMULA': ' $id', 'OUTPUT': workspace + r'/Substations/Substations_with_ID.shp'})
processing.run("native:reprojectlayer", {'INPUT': workspace + r'/Substations/Substations_with_ID.shp', 'TARGET_CRS': projCord, 'OUTPUT': workspace + r'/Substations/Substations' + countryiso3 + '_Proj.shp'})
# Give all intersecting polygon distance 0
processing.run("native:selectbylocation", {'INPUT': Pop, 'PREDICATE': [0],
                                           'INTERSECT': workspace + r'/Substations/Substations' + countryiso3 + '_Proj.shp', 'METHOD': 0})
processing.run("native:saveselectedfeatures", {'INPUT': Pop, 'OUTPUT': assistingFolder2 + r'/sub_int.shp'})
processing.run("qgis:fieldcalculator", {'INPUT': assistingFolder2 + r'/sub_int.shp', 'FIELD_NAME': 'Substation', 'FIELD_TYPE': 0, 'FIELD_LENGTH': 10, 'FIELD_PRECISION': 3, 'NEW_FIELD': True, 'FORMULA': '0', 'OUTPUT': assistingFolder2 + r'/Substations_intersect.shp'})
processing.run("native:joinattributestable", {
    'INPUT': Pop, 'FIELD': 'id', 'INPUT_2': assistingFolder2 + r'/Substations_intersect.shp', 'FIELD_2': 'id', 'FIELDS_TO_COPY': ['Substation'], 'METHOD': 1, 'DISCARD_NONMATCHING': False, 'PREFIX': '', 'OUTPUT': assistingFolder2 + r'/Substationdist_intersecting.shp'})
# Give all polygons larger than 1 km2 the right distance and merge with intersecting
processing.run("qgis:distancetonearesthubpoints", {'INPUT': settlement_points,
                                                   'HUBS': workspace + r'/Substations/Substations' + countryiso3 + '_Proj.shp', 'FIELD': 'AUTO', 'UNIT': 3, 'OUTPUT': assistingFolder2 + r"/Substationdist.shp"})
processing.run("qgis:statisticsbycategories", {
    'INPUT': assistingFolder2 + r"/Substationdist.shp", 'VALUES_FIELD_NAME': 'HubDist', 'CATEGORIES_FIELD_NAME': ['id'], 'OUTPUT': assistingFolder2 + r'/Substationdist_largerThanOne_sta.shp'})
processing.run("native:joinattributestable", {
    'INPUT': assistingFolder2 + r'/Substationdist_intersecting.shp', 'FIELD': 'id',
    'INPUT_2': assistingFolder2 + r'/Substationdist_largerThanOne_sta.dbf',
    'FIELD_2': 'id', 'FIELDS_TO_COPY': ['min'], 'METHOD': 1, 'DISCARD_NONMATCHING': False, 'PREFIX': '', 'OUTPUT': assistingFolder2 + r'/Substationdist_largerThanOne.shp'})

sub_dist = QgsVectorLayer(assistingFolder2 + r'/Substationdist_largerThanOne.shp', '', 'ogr')
input = sub_dist

#########
# Existing HV lines
#########
print('Processing the exisitng high-voltage tranmission lines.', 'Time:', datetime.datetime.now().time())
processing.run("native:clip", {'INPUT': existing_HV, 'OVERLAY': admin,
                               'OUTPUT': workspace + r'/HV_Network/Existing_HV' + countryiso3 + '.shp'})
processing.run("saga:convertlinestopoints", {'LINES': workspace + r'/HV_Network/Existing_HV' + countryiso3 + '.shp',
                                             'ADD': True, 'DIST': 0.000833333333,
                                             'POINTS': workspace + r'/HV_Network/Existing_HV' + countryiso3 + 'Point.shp'})
processing.run("qgis:fieldcalculator",
               {'INPUT': workspace + r'/HV_Network/Existing_HV' + countryiso3 + 'Point.shp',
                'FIELD_NAME': 'AUTO', 'FIELD_TYPE': 1, 'FIELD_LENGTH': 10, 'NEW_FIELD': True,
                'FORMULA': ' $id', 'OUTPUT': workspace + r'/HV_Network/Existing_HV_with_ID.shp'})
processing.run("native:reprojectlayer",
               {'INPUT': workspace + r'/HV_Network/Existing_HV_with_ID.shp', 'TARGET_CRS': projCord,
                'OUTPUT': workspace + r'/HV_Network/Existing_HV' + countryiso3 + '_Proj.shp'})
# Give all polygons larger than 1 km2 the right distance and merge with intersecting
processing.run("qgis:distancetonearesthubpoints", {'INPUT': settlement_points,
                                                   'HUBS': workspace + r'/HV_Network/Existing_HV' + countryiso3 + '_Proj.shp',
                                                   'FIELD': 'AUTO', 'UNIT': 3,
                                                   'OUTPUT': assistingFolder2 + r"/EX_HV_dist.shp"})
processing.run("qgis:statisticsbycategories", {
    'INPUT': assistingFolder2 + r"/EX_HV_dist.shp", 'VALUES_FIELD_NAME': 'HubDist', 'CATEGORIES_FIELD_NAME': ['id'],
    'OUTPUT': assistingFolder2 + r'/EX_HV_dist_largerThanOne_sta.shp'})

processing.run("native:joinattributestable", {
    'INPUT': input, 'FIELD': 'id',
    'INPUT_2': assistingFolder2 + r'/EX_HV_dist_largerThanOne_sta.dbf',
    'FIELD_2': 'id', 'FIELDS_TO_COPY': ['min'], 'METHOD': 1, 'DISCARD_NONMATCHING': False, 'PREFIX': '',
    'OUTPUT': assistingFolder2 + r'/EX_HV_dist_largerThanOne.shp'})
ex_hv = QgsVectorLayer(assistingFolder2 + r'/EX_HV_dist_largerThanOne.shp', '', 'ogr')
input = ex_hv

#########
# Planned HV lines
#########
print('Processing the planned high-voltage tranmission lines.', 'Time:', datetime.datetime.now().time())
processing.run("native:clip",
               {'INPUT': planned_HV, 'OVERLAY': admin,
                'OUTPUT': workspace + r'/HV_Network/Planned_HV' + countryiso3 + '.shp'})
merged_HV = QgsVectorLayer(workspace + r'/HV_Network/Planned_HV' + countryiso3 + '.shp', '', 'ogr')
processing.run("saga:convertlinestopoints", {
    'LINES': merged_HV,
    'ADD': True, 'DIST': 0.000833333333,
    'POINTS': workspace + r'/HV_Network/Planned_HV' + countryiso3 + 'Point.shp'})
processing.run("qgis:fieldcalculator",
               {'INPUT': workspace + r'/HV_Network/Planned_HV' + countryiso3 + 'Point.shp',
                'FIELD_NAME': 'AUTO',
                'FIELD_TYPE': 1, 'FIELD_LENGTH': 10, 'NEW_FIELD': True,
                'FORMULA': ' $id',
                'OUTPUT': workspace + r'/HV_Network/Planned_HV_with_ID.shp'})
processing.run("native:reprojectlayer",
               {'INPUT': workspace + r'/HV_Network/Planned_HV_with_ID.shp',
                'TARGET_CRS': projCord,
                'OUTPUT': workspace + r'/HV_Network/Planned_HV' + countryiso3 + '_Proj.shp'})
# Give all polygons larger than 1 km2 the right distance and merge with intersecting
processing.run("qgis:distancetonearesthubpoints", {'INPUT': settlement_points,
                                                   'HUBS': workspace + r'/HV_Network/Planned_HV' + settlements_fc[0:3] + '_Proj.shp',
                                                   'FIELD': 'AUTO', 'UNIT': 3,
                                                   'OUTPUT': assistingFolder2 + r"/PL_HV_dist.shp"})
processing.run("qgis:statisticsbycategories", {
    'INPUT': assistingFolder2 + r"/PL_HV_dist.shp", 'VALUES_FIELD_NAME': 'HubDist',
    'CATEGORIES_FIELD_NAME': ['id'],
    'OUTPUT': assistingFolder2 + r'/PL_HV_dist_largerThanOne_sta.shp'})
processing.run("native:joinattributestable", {
    'INPUT': input, 'FIELD': 'id',
    'INPUT_2': assistingFolder2 + r'/PL_HV_dist_largerThanOne_sta.dbf',
    'FIELD_2': 'id', 'FIELDS_TO_COPY': ['min'], 'METHOD': 1, 'DISCARD_NONMATCHING': False, 'PREFIX': '',
    'OUTPUT': assistingFolder2 + r'/PL_HV_dist_largerThanOne.shp'})
pl_hv = QgsVectorLayer(assistingFolder2 + r'/PL_HV_dist_largerThanOne.shp', '', 'ogr')
input = pl_hv

#########
# Existing MV lines
#########
print('Processing the exisitng medium-voltage tranmission lines.', 'Time:', datetime.datetime.now().time())
# Existing_MV_lines
processing.run("native:clip",
               {'INPUT': existing_MV, 'OVERLAY': admin,
                'OUTPUT': workspace + r'/MV_Network/Existing_MV' + countryiso3 + '.shp'})
processing.run("saga:convertlinestopoints", {
    'LINES': workspace + r'/MV_Network/Existing_MV' + countryiso3 + '.shp',
    'ADD': True, 'DIST': 0.000833333333,
    'POINTS': workspace + r'/MV_Network/Existing_MV' + countryiso3 + 'Point.shp'})
processing.run("qgis:fieldcalculator",
               {'INPUT': workspace + r'/MV_Network/Existing_MV' + countryiso3 + 'Point.shp',
                'FIELD_NAME': 'AUTO',
                'FIELD_TYPE': 1, 'FIELD_LENGTH': 10, 'NEW_FIELD': True,
                'FORMULA': ' $id',
                'OUTPUT': workspace + r'/MV_Network/Existing_MV_with_ID.shp'})
processing.run("native:reprojectlayer",
               {'INPUT': workspace + r'/MV_Network/Existing_MV_with_ID.shp',
                'TARGET_CRS': projCord,
                'OUTPUT': workspace + r'/MV_Network/Existing_MV' + countryiso3 + '_Proj.shp'})
# Give all polygons larger than 1 km2 the right distance and merge with intersecting
processing.run("qgis:distancetonearesthubpoints", {'INPUT': settlement_points,
                                                   'HUBS': workspace + r'/MV_Network/Existing_MV' + settlements_fc[0:3] + '_Proj.shp',
                                                   'FIELD': 'AUTO', 'UNIT': 3,
                                                   'OUTPUT': assistingFolder2 + r"/EX_MV_dist.shp"})
processing.run("qgis:statisticsbycategories", {
    'INPUT': assistingFolder2 + r"/EX_MV_dist.shp", 'VALUES_FIELD_NAME': 'HubDist',
    'CATEGORIES_FIELD_NAME': ['id'],
    'OUTPUT': assistingFolder2 + r'/EX_MV_dist_largerThanOne_sta.shp'})
processing.run("native:joinattributestable", {
    'INPUT': input, 'FIELD': 'id',
    'INPUT_2': assistingFolder2 + r'/EX_MV_dist_largerThanOne_sta.dbf',
    'FIELD_2': 'id', 'FIELDS_TO_COPY': ['min'], 'METHOD': 1, 'DISCARD_NONMATCHING': False, 'PREFIX': '',
    'OUTPUT': assistingFolder2 + r'/EX_MV_dist_largerThanOne.shp'})
ex_mv = QgsVectorLayer(assistingFolder2 + r'/EX_MV_dist_largerThanOne.shp', '', 'ogr')
input = ex_mv

#########
# Roads
#########
print('Processing the roads.', 'Time:', datetime.datetime.now().time())
processing.run("native:clip",
               {'INPUT': roads, 'OVERLAY': admin,
                'OUTPUT': workspace + r'/Roads/Roads' + countryiso3 + '.shp'})
processing.run("saga:convertlinestopoints", {
    'LINES': workspace + r'/Roads/Roads' + countryiso3 + '.shp',
    'ADD': True, 'DIST': 0.000833333333,
    'POINTS': workspace + r'/Roads/Roads' + countryiso3 + 'Point.shp'})
processing.run("qgis:fieldcalculator",
               {'INPUT': workspace + r'/Roads/Roads' + countryiso3 + 'Point.shp',
                'FIELD_NAME': 'AUTO',
                'FIELD_TYPE': 1, 'FIELD_LENGTH': 10, 'NEW_FIELD': True,
                'FORMULA': ' $id',
                'OUTPUT': workspace + r'/Roads/Roads_with_ID.shp'})
processing.run("native:reprojectlayer",
               {'INPUT': workspace + r'/Roads/Roads_with_ID.shp',
                'TARGET_CRS': projCord,
                'OUTPUT': workspace + r'/Roads/Roads' + countryiso3 + '_Proj.shp'})
# Give all polygons larger than 1 km2 the right distance and merge with intersecting
processing.run("qgis:distancetonearesthubpoints", {'INPUT': settlement_points,
                                                   'HUBS': workspace + r'/Roads/Roads' + settlements_fc[
                                                                                         0:3] + '_Proj.shp',
                                                   'FIELD': 'AUTO', 'UNIT': 3,
                                                   'OUTPUT': assistingFolder2 + r"/Roads_dist.shp"})
processing.run("qgis:statisticsbycategories", {
    'INPUT': assistingFolder2 + r"/Roads_dist.shp", 'VALUES_FIELD_NAME': 'HubDist',
    'CATEGORIES_FIELD_NAME': ['id'],
    'OUTPUT': assistingFolder2 + r'/Roads_dist_largerThanOne_sta.shp'})
processing.run("native:joinattributestable", {
    'INPUT': input, 'FIELD': 'id',
    'INPUT_2': assistingFolder2 + r'/Roads_dist_largerThanOne_sta.dbf',
    'FIELD_2': 'id', 'FIELDS_TO_COPY': ['min'], 'METHOD': 1, 'DISCARD_NONMATCHING': False, 'PREFIX': '',
    'OUTPUT': assistingFolder2 + r'/Roads_dist_largerThanOne.shp'})
roads = QgsVectorLayer(assistingFolder2 + r'/Roads_dist_largerThanOne.shp', '', 'ogr')
input = roads

###############
# Hydro
###############
print('Processing the hydro points.', 'Time:', datetime.datetime.now().time())
processing.run("native:clip",
               {'INPUT': hydro_points, 'OVERLAY': admin,
                'OUTPUT': workspace + r'/Hydropower/Hydro' + countryiso3 + '.shp'})
processing.run("qgis:fieldcalculator",
               {'INPUT': workspace + r'/Hydropower/Hydro' + countryiso3 + '.shp', 'FIELD_NAME': 'AUTO',
                'FIELD_TYPE': 1, 'FIELD_LENGTH': 10, 'NEW_FIELD': True, 'FORMULA': ' $id',
                'OUTPUT': workspace + r'/Hydropower/Hydro_with_ID.shp'})
processing.run("native:reprojectlayer",
               {'INPUT': workspace + r'/Hydropower/Hydro_with_ID.shp', 'TARGET_CRS': projCord,
                'OUTPUT': assistingFolder2 + r'/Hydro' + countryiso3 + '_Proj.shp'})
processing.run("native:multiparttosingleparts", {
    'INPUT': assistingFolder2 + r'/Hydro' + countryiso3 + '_Proj.shp',
    'OUTPUT': workspace + r'/Hydropower/Hydro' + countryiso3 + '_Proj.shp'})
# Give all intersecting polygon distance 0
processing.run("native:selectbylocation",
               {'INPUT': Pop, 'PREDICATE': [0],
                'INTERSECT': workspace + r'/Hydropower/Hydro' + countryiso3 + '_Proj.shp', 'METHOD': 0})
processing.run("native:saveselectedfeatures", {'INPUT': Pop, 'OUTPUT': assistingFolder2 + r'/Hydro_int.shp'})
processing.run("qgis:fieldcalculator",
               {'INPUT': assistingFolder2 + r'/Hydro_int.shp',
                'FIELD_NAME': 'HydroDist', 'FIELD_TYPE': 2, 'FIELD_LENGTH': 255, 'FIELD_PRECISION': 3,
                'NEW_FIELD': True, 'FORMULA': '0', 'OUTPUT': assistingFolder2 + r'/Hydro_intersect1.shp'})
processing.run("native:joinattributestable",
               {'INPUT': input, 'FIELD': 'id', 'INPUT_2': assistingFolder2 + r'/Hydro_intersect1.shp',
                'FIELD_2': 'id', 'FIELDS_TO_COPY': ['HydroDist'], 'METHOD': 1, 'DISCARD_NONMATCHING': False,
                'PREFIX': '', 'OUTPUT': assistingFolder2 + r'/Hydro_dist_intersecting1.shp'})
processing.run("saga:pointstatisticsforpolygons", {
    'POINTS': workspace + r'/Hydropower/Hydro' + countryiso3 + '_Proj.shp',
    'POLYGONS': assistingFolder2 + r'/Hydro_dist_intersecting1.shp',
    'FIELDS': hydropowerField, 'FIELD_NAME': 3, 'SUM             ': True, 'AVG             ': False,
    'VAR             ': False, 'DEV             ': False, 'MIN             ': False,
    'MAX             ': False, 'NUM             ': False,
    'STATISTICS': assistingFolder2 + r'/Hydro_intersect2.shp'})
time.sleep(60)
processing.run("saga:pointstatisticsforpolygons", {
    'POINTS': workspace + r'/Hydropower/Hydro' + countryiso3 + '_Proj.shp',
    'POLYGONS': assistingFolder2 + r'/Hydro_intersect2.shp',
    'FIELDS': 'AUTO', 'FIELD_NAME': 3, 'SUM             ': False, 'AVG             ': False,
    'VAR             ': False, 'DEV             ': False, 'MIN             ': False,
    'MAX             ': True, 'NUM             ': False,
    'STATISTICS': assistingFolder2 + r'/Hydro_intersect3.shp'})
hydro_dist = QgsVectorLayer(assistingFolder2 + r'/Hydro_intersect3.shp', "", "ogr")
for field in hydro_dist.fields():
    if field.name() == 'SUM':
        with edit(hydro_dist):
            idx = hydro_dist.fields().indexFromName(field.name())
            hydro_dist.renameAttribute(idx, 'Hydropower')

for field in hydro_dist.fields():
    if field.name() == 'MAX':
        with edit(hydro_dist):
            idx = hydro_dist.fields().indexFromName(field.name())
            hydro_dist.renameAttribute(idx, 'HydroFID')

# Give all polygons larger than 1 km2 the right distance and merge with intersecting
processing.run("qgis:distancetonearesthubpoints", {
    'INPUT': settlement_points,
    'HUBS': workspace + r'/Hydropower/Hydro' + countryiso3 + '_Proj.shp',
    'FIELD': 'AUTO', 'UNIT': 3, 'OUTPUT': assistingFolder2 + r"/Hydrodist_1.shp"})
processing.run("qgis:statisticsbycategories",
               {'INPUT': assistingFolder2 + r"/Hydrodist_1.shp", 'VALUES_FIELD_NAME': 'HubDist',
                'CATEGORIES_FIELD_NAME': ['id', 'HubName'],
                'OUTPUT': assistingFolder2 + r'/Hydrodist_largerThanOne1_sta.shp'})
processing.run("native:joinattributestable", {
    'INPUT': hydro_dist, 'FIELD': 'id',
    'INPUT_2': assistingFolder2 + r'/Hydrodist_largerThanOne1_sta.dbf',
    'FIELD_2': 'id', 'FIELDS_TO_COPY': ['min'], 'METHOD': 1, 'DISCARD_NONMATCHING': False, 'PREFIX': '',
    'OUTPUT': assistingFolder2 + r'/Hydrodist_largerThanOne1.shp'})
processing.run("qgis:distancetonearesthubpoints", {
    'INPUT': settlement_points,
    'HUBS': workspace + r'/Hydropower/Hydro' + countryiso3 + '_Proj.shp',
    'FIELD': hydropowerField, 'UNIT': 0, 'OUTPUT': assistingFolder2 + r"/Hydrodist_4.shp"})
processing.run("native:joinattributestable", {
    'INPUT': assistingFolder2 + r"/Hydrodist_largerThanOne1.shp", 'FIELD': 'id',
    'INPUT_2': assistingFolder2 + r"/Hydrodist_4.shp",
    'FIELD_2': 'id', 'FIELDS_TO_COPY': ['HubName'], 'METHOD': 1, 'DISCARD_NONMATCHING': False, 'PREFIX': '',
    'OUTPUT': assistingFolder2 + r"/Hydrodist_5.shp"})
    
hydro_dist = QgsVectorLayer(assistingFolder2 + r"/Hydrodist_5.shp", '', 'ogr')
assistingFolder2 = workspace + r"/Assist2"

if hydropowerFieldUnit == "W":
    processing.run("qgis:fieldcalculator",
                   {'INPUT': hydro_dist, 'FIELD_NAME': 'Hydropower',
                    'FIELD_TYPE': 0, 'FIELD_LENGTH': 10, 'FIELD_PRECISION': 3, 'NEW_FIELD': False,
                    'FORMULA': ' /"Hydropower/" /1000',
                    'OUTPUT': assistingFolder + r'/' + settlements_fc + '.shp'})
elif hydropowerFieldUnit == "MW":
    processing.run("qgis:fieldcalculator",
                   {'INPUT': hydro_dist, 'FIELD_NAME': 'Hydropower',
                    'FIELD_TYPE': 0, 'FIELD_LENGTH': 10, 'FIELD_PRECISION': 3, 'NEW_FIELD': False,
                    'FORMULA': ' /"Hydropower/" *1000',
                    'OUTPUT': assistingFolder + r'/' + settlements_fc + '.shp'})
else:
    processing.run("qgis:fieldcalculator",
                   {'INPUT': hydro_dist, 'FIELD_NAME': 'Hydropower',
                    'FIELD_TYPE': 0, 'FIELD_LENGTH': 10, 'FIELD_PRECISION': 3, 'NEW_FIELD': False,
                    'FORMULA': ' /"Hydropower/" *1',
                    'OUTPUT': assistingFolder + r'/' + settlements_fc + '.shp'})

input = QgsVectorLayer(assistingFolder2 + r"/Hydrodist_5.shp", "", "ogr")

##################
# Last adjustments
##################
# Add missing fields with the appropriate name, and set them to 0 if NULL

iter5 = processing.run("native:centroids", {'INPUT': input,
                                            'ALL_PARTS': False, 'OUTPUT': assistingFolder2 + r"/iter5.shp"})

iter5b = processing.run("saga:addcoordinatestopoints", {'INPUT':assistingFolder2 + r"/iter5.shp",
                                                        'OUTPUT':assistingFolder2 + r"/iter5b.shp"})

iter5c = processing.run("native:joinattributestable", {
    'INPUT': assistingFolder2 + r"/iter5b.shp", 'FIELD': 'id',
    'INPUT_2': input,'FIELD_2': 'id',
    'FIELDS_TO_COPY': ['X','Y'], 'METHOD': 1, 'DISCARD_NONMATCHING': False, 'PREFIX': 'worldmer_',
    'OUTPUT': assistingFolder2 + r'/iter5c.shp'})

iter6 = processing.run("native:reprojectlayer",{'INPUT': assistingFolder2 + r"/iter5.shp",'TARGET_CRS': 'EPSG:4326',
                                                'OUTPUT': assistingFolder2 + r"/iter6.shp"})

iter7 = processing.run("saga:addcoordinatestopoints", {'INPUT':assistingFolder2 + r"/iter6.shp",
                                                       'OUTPUT':assistingFolder2 + r"/iter7.shp"})

iter8 = processing.run("native:joinattributestable", {
    'INPUT': assistingFolder2 + r"/iter7.shp", 'FIELD': 'id',
    'INPUT_2': assistingFolder2 + r'/iter5c.shp', 'FIELD_2': 'id',
    'FIELDS_TO_COPY': ['X','Y'], 'METHOD': 1, 'DISCARD_NONMATCHING': False, 'PREFIX': 'latlon_',
    'OUTPUT': assistingFolder2 + r"/iter8.shp"})

# Define new version
placeholder = QgsVectorLayer(assistingFolder2 + r'/iter8.shp')

# Add fields when optional inputs are missing
processing.run("qgis:fieldcalculator", {'INPUT': placeholder, 'FIELD_NAME':
    'Transforme', 'FIELD_TYPE': 0, 'FIELD_LENGTH': 10, 'FIELD_PRECISION': 3, 'NEW_FIELD': True,
                                        'FORMULA': '0', 'OUTPUT': assistingFolder2 + r"/iter10.shp"})

placeholder = QgsVectorLayer(assistingFolder2 + r'/iter10.shp')

processing.run("qgis:fieldcalculator", {'INPUT': placeholder, 'FIELD_NAME':
    'PL_MV', 'FIELD_TYPE': 0, 'FIELD_LENGTH': 10, 'FIELD_PRECISION': 3, 'NEW_FIELD': True,
                                        'FORMULA': '0', 'OUTPUT': assistingFolder2 + r"/iter16.shp"})

placeholder = QgsVectorLayer(assistingFolder2 + r'/iter16.shp',"","ogr")

# travel time


# elrate



# ...

QgsVectorFileWriter.writeAsVectorFormat(placeholder, home_repo_folder +'SSA.csv', 'CP1250', placeholder.crs(), 'CSV')

# Selct fields to keep, rename them, and export to csv
final = pandas.read_csv(home_repo_folder +'SSA.csv')

final['Area']= final['Area'] / 100
final['traveltime']= final['traveltime'] / 60 # CHECK
final['ElecPop']= final['pop2015KEN'] * final['elrate'] # CHECK
final['ElecPop'][final['ElecPop'] < 0] = 0

final['Conflict']= 0
final['ResidentialDemandTierCustom']= 0

# CHECK
final2 = final[['pop2015KEN', 'kwh_proc_c', 'id', 'Area', 'er_kwh', 'el_dem_sch', 'el_dem_hc', 'windveloci', 'ghisolarad', 'traveltime', 'elevationm', 'terraslope', 'landcoverm', 'nightlight', 'Substation', 'EX_HV', 'PL_HV', 'EX_MV', 'PL_MV', 'Roads', 'HydroDist', 'Hydropower', 'HydroFID', 'ElecPop', 'Conflict', 'ResidentialDemandTierCustom', 'PerHHD', 'isurbanmaj', 'X', 'Y', 'latlon_X', 'latlon_Y', 'Transforme']]

# CHECK
final2 = final2.rename({'kwh_proc_c' : 'CropProcessingDemand', 'X':'X_deg', 'Y':'Y_deg', 'latlon_X':'X', 'latlon_Y':'Y', 'pop2015KEN':'Pop', 'EX_HV':'CurrentHVLineDist', 'PL_HV':'PlannedHVLineDist', 'EX_MV':'CurrentMVLineDist', 'PL_MV':'PlannedMVLineDist', 'Roads':'RoadDist', 'nightlight':'NightLights', 'traveltime':'TravelHours', 'ghisolarad':'GHI', 'windveloci':'WindVel', 'Hydropower':'Hydropower', 'HydroFID':'HydropowerFID', 'HydroDist':'HydropowerDist', 'Substation':'SubstationDist', 'elevationm':'Elevation', 'terraslope':'Slope', 'landcoverm':'LandCover', 'isurbanmaj':'IsUrban', 'Conflict':'Conflict', 'ResidentialDemandTierCustom':'ResidentialDemandTierCustom', 'er_kwh':'AgriDemand', 'el_dem_hc':'HealthDemand', 'el_dem_sch':'EducationDemand', 'Area':'GridCellArea', 'ElecPop':'ElecPop', 'Transforme':'TransformerDist', 'id':'ID', 'PerHHD_low':'PerHHD_low', 'PerHHD_ref':'PerHHD_reference', 'PerHHD_vis':'PerHHD_vision', 'Productive':'CommercialDemand'}, axis='columns')


final2['Country']=countryiso3
final2['ElectrificationOrder']= 0
final2['TravelHours'][final2['TravelHours'] < 0] = 0
final2 = final2.fillna(0)
final2 = final2.round(2)

import numpy
# CHECK
final2['IsUrban'] = numpy.where((final2['IsUrban'] >= 11) & (final2['IsUrban'] <= 23), 0, numpy.where(final2['IsUrban'] >= 30, 1, 0))

# CHECK
final2['NumPeoplePerHH'] = numpy.where(final2['IsUrban'] == 1, 3.5, 4.5)

final2['LandCover'] = numpy.where(final2['LandCover'] == 2147483647, 0, final2['LandCover'])

final2.to_csv('D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/SSA.csv')

#QgsApplication.exitQgis()
#qgs.exit()

#shutil.rmtree(workspace + r"/Assist2")
#os.makedirs(workspace + r"/Assist2")

print('Finished!.', 'Time:', datetime.datetime.now().time())

####