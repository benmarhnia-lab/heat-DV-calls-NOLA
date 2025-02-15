# Impact of extreme heat on domestic violence related calls for services: Findings from a case-crossover study in New Orleans
Authors: Arnab K. Dey, Namratha Rao, Edwin Elizabeth Thomas, Yiqun Ma, Grace Riley, Tarik Benmarhnia, Anita Raj

This repository contains scripts used to analyze the impact of extreme heat on domestic violence related calls for services in New Orleans between 2011 and 2021. The following sections describe data sources and scripts needed to replicate the analysis.

# Data Sources

Data for this analysis comes from multiple sources:

* Daily gridded Universal Thermal Climate Index (UTCI) data was derived from ERA5 reanalysis, from the European Centre for Medium-Range Weather Forecasts (ECMWF)
* Calls for Service records made to the New Orleans Police Department (NOPD) from 2011 to 2021 were provided by the Orleans Parish Communication District (accessed on 30 January 2024 from https://datadriven.nola.gov/home/)

# Data Dictionary

This section describes the processed datasets used in the study. We use two datasets [0.1_UTCI_NOLA_zip.rds](Data/) and [0.2_DV_cases_agg](Data/). 
These datasets correspond to the daily zip-code specific values of mean UTCI and the number of domestic violence related calls aggregated by Zip codes.

`0.1_UTCI_NOLA_zip.rds` includes the following variables:
* date: daily dates
* Zip: zip codes
* utci_mean: daily means of UTCI corresponding to the zip codes

`0.2_DV_cases_agg` includes the following variables:
* case_date: date corresponding to the DV case
* Zip: Zip code from NOPD data
* DV_count: Number of DV cases
* ID_grp: ID group for each zip-date
* year: year corresponding to the date
* month: month corresponding to the date
* weekday: weekday corresponding to the date

# Data Analysis Scripts

## 1. Data Preparation

### [1.1-data-prep-long-term-cutoffs-utci.R](R/1.1-data-prep-long-term-cutoffs-utci.R)
This script creates long-term cutoffs for the 90th percentile of UTCI for each zip code.

### [1.2-data-prep-create-exposures-utci.R](R/1.2-data-prep-create-exposures-utci.R)
This script creates exposure variables for extreme heat for each zip code.

### [1.3-data-prep-days-exposed.R](R/1.3-data-prep-dats-exposed.R)
This script calculates the total number of cases and average number of domestic violence related calls for each exposure variable.

### [1.4-data-prep-DV-cco.R](R/1.4-data-prep-DV-cco.R)
This script prepares the data for the case crossover analysis.

## 2. Models and outputs 

### [2.1-models-run-cco-utci.R](R/2.1-models-run-cco-utci.R)
This script runs the models for the case crossover analysis.

### [2.2-models-extract-coefs.R](R/2.2-models-extract-coefs.R)
This script extracts the coefficients from the models for the case crossover analysis.

### [2.3-models-attributable-fraction.R](R/2.3-models-attributable-fraction.R)
This script generates the attributable fraction and attributable numbers for the case crossover analysis.

Note: This repository is part of ongoing research at Scripps Institution of Oceanography, UC San Diego. Additional scripts and documentation will be added as the analysis progresses.