import os
from onsset import *
import pandas as pd
import tkinter as tk
from tkinter import filedialog, messagebox
from openpyxl import load_workbook

root = tk.Tk()
root.withdraw()
root.attributes("-topmost", True)

home_repo_folder = 'D:/OneDrive - FONDAZIONE ENI ENRICO MATTEI/Current papers/Latent demand air cooling/cooling_electricity_SSA/onsset/'
specs_path = home_repo_folder + 'specs_SSA.xlsx'
countries = ['SSA']
SpecsData = pd.read_excel(specs_path, sheet_name='SpecsData')
base_dir = home_repo_folder + 'SSA.csv'
output_dir = home_repo_folder + 'cali_SSA'

print('\n --- Calibrating --- \n')

for country in countries:
	print(country)
	settlements_in_csv = base_dir
	settlements_out_csv = output_dir + '.csv'

	sett = pd.read_csv(base_dir)
	
	sett['PerCapitaDemand'] = sett['PerHHD']

	sett.to_csv(base_dir)

	onsseter = SettlementProcessor(settlements_in_csv)

	start_year = int(SpecsData.loc[0, SPE_START_YEAR])
	end_year = int(SpecsData.loc[0, SPE_END_YEAR])
	project_life = end_year - start_year
	
	pop_future_high = int(SpecsData.loc[0, 'PopEndYearHigh'])
	pop_future_low = int(SpecsData.loc[0, 'PopEndYearLow'])
	pop_actual = int(SpecsData.loc[0, SPE_POP])
	
	urban_growth_high = pop_future_high / pop_actual
	rural_growth_high = pop_future_high / pop_actual

	yearly_urban_growth_rate_high = urban_growth_high ** (1 / project_life)
	yearly_rural_growth_rate_high = rural_growth_high ** (1 / project_life)

	urban_growth_low = pop_future_low / pop_actual
	rural_growth_low = pop_future_low / pop_actual

	yearly_urban_growth_rate_low = urban_growth_low ** (1 / project_life)
	yearly_rural_growth_rate_low = rural_growth_low ** (1 / project_life)

	onsseter.condition_df()
	onsseter.grid_penalties()
	onsseter.calc_wind_cfs()

	pop_actual = SpecsData.loc[0, SPE_POP]
	pop_future_high = SpecsData.loc[0, SPE_POP_FUTURE + 'High']
	pop_future_low = SpecsData.loc[0, SPE_POP_FUTURE + 'Low']
	urban_current = SpecsData.loc[0, SPE_URBAN]
	urban_future = SpecsData.loc[0, SPE_URBAN_FUTURE]
	start_year = int(SpecsData.loc[0, SPE_START_YEAR])
	end_year = int(SpecsData.loc[0, SPE_END_YEAR])

	elec_actual = SpecsData.loc[0, SPE_ELEC]
	elec_actual_urban = SpecsData.loc[0, SPE_ELEC_URBAN]
	elec_actual_rural = SpecsData.loc[0, SPE_ELEC_RURAL]
	pop_tot = SpecsData.loc[0, SPE_POP]

	num_people_per_hh_rural = float(SpecsData.iloc[0][SPE_NUM_PEOPLE_PER_HH_RURAL])
	num_people_per_hh_urban = float(SpecsData.iloc[0][SPE_NUM_PEOPLE_PER_HH_URBAN])

	# In case there are limitations in the way grid expansion is moving in a country, this can be reflected through gridspeed.

	# In this case the parameter is set to a very high value therefore is not taken into account.
	urban_modelled = SpecsData.loc[0, SPE_URBAN_MODELLED]
	elec_modelled = SpecsData.loc[0, SPE_ELEC_MODELLED] 
	rural_elec_ratio = SpecsData.loc[0, 'rural_elec_ratio_modelled']
	urban_elec_ratio = SpecsData.loc[0, 'urban_elec_ratio_modelled'] 

	book = load_workbook(specs_path)
	writer = pd.ExcelWriter(specs_path, engine='openpyxl')
	writer.book = book
	# RUN_PARAM: Here the calibrated "specs" data are copied to a new tab called "SpecsDataCalib". This is what will later on be used to feed the model
	SpecsData.to_excel(writer, sheet_name='SpecsDataCalib', index=False)
	writer.save()
	writer.close()

	logging.info('Calibration finished. Results are transferred to the csv file')
	onsseter.df.to_csv(settlements_out_csv, index=False)