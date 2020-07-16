This repository contains the code and the data to replicate the analysis of the paper 'Latent residential air cooling demand and universal household electrification' by Giacomo Falchetta

The code includes:

- A wrapper to call all pieces of the code and define parameters (wrapper.R)
- A module to estimate cooling degree days based on climate scenarios and custom parameters (data_process.R)
- A module to estimate hourly building heat gain from windows in any location of the world under custom parameters (window_heat_gain.R)
- A module to estimate electricity requirements for air circulation and cooling (electricity.R)
- A module to estimate CO2 emissions from electricity consumption for air circulation and cooling (emissions.R)
- A module to carry out electricity access planning analysis with the OnSSET tool to evaluate different demand scenarios (AC/no AC) (electrification_analysis.R)

Both R and Python are required on the local machine.

Questions and queries to: giacomo.falchetta@gmail.com
