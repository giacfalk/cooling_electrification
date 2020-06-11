Suriname
Bolivia (Plurinational State of)
Grenada
India
Peru
Philippines
Guatemala
Nepal
Cabo Verde
Gabon
Honduras
Guyana
Cambodia
South Africa
Nicaragua
Syrian Arab Republic
Timor-Leste
Bangladesh
Ghana
Micronesia (Federated States of)
Comoros
Eswatini
Kenya
Pakistan
Sao Tome and Principe
Congo
Equatorial Guinea
Libya
Côte d'Ivoire
Senegal
Myanmar
Botswana
Cameroon
Yemen
Vanuatu
Djibouti
Gambia
Sudan
Papua New Guinea
Nigeria
Namibia
Togo
Mali
Eritrea
Democratic People's Republic of Korea
Lesotho
Haiti
Ethiopia
Mauritania
Guinea
Angola
Uganda
Benin
Zimbabwe
Zambia
United Republic of Tanzania
Somalia
Rwanda
Central African Republic
Mozambique
Guinea-Bissau
South Sudan
Sierra Leone
Liberia
Madagascar
Democratic Republic of the Congo
Malawi
Niger
Burkina Faso
Chad
Burundi


vector <- readClipboard()

vector_ISO <- countrycode::countrycode(vector, "country.name", "iso3c")

paste(paste0("ee.Filter.eq('ISO3', '", vector_ISO, "')"), collapse = ', ')
