This repository contains the code to replicate the analysis of the paper 'The role of residential air circulation and cooling demand for electrification planning: implications of climate change over sub-Saharan Africa' by Giacomo Falchetta

Required replication data is found at: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4010319.svg)](https://doi.org/10.5281/zenodo.4010319). The Zenodo archive content must be extracted in the home folder of this repository. 

The code includes:

- A wrapper to call all pieces of the code and define parameters (wrapper.R)
- A module to estimate cooling degree days based on climate scenarios and custom parameters (data_process.R)
- A module to estimate hourly building heat gain from windows in any location of the world under custom parameters (window_heat_gain.R)
- A module to estimate electricity requirements for air circulation and cooling (electricity.R)
- A module to estimate CO2 emissions from electricity consumption for air circulation and cooling (emissions.R)
- A module to carry out electricity access planning analysis with the OnSSET tool to evaluate different demand scenarios (AC/no AC) (electrification_analysis.R)

Both R and Python are required on the local machine.

Questions and queries to: giacomo.falchetta@gmail.com
