library(tidyverse)
library(survival)

# Read Data ----
df_nopd_climate_merged <- read_fst("D:/Arnab/git/manuscripts/pap-nola-climate-domestic-violence/data/processed-data/3.1-nopd-climate-merged.fst", 
                                   as.data.table = TRUE)
colnames(df_nopd_climate_merged)

# Conditional Logit Model ----
model_1 <- clogit(dv_case ~ hotday_30 + strata(ID_grp), 
                  weights = DV_count,
                  data=df_nopd_climate_merged, 
                  method="approximate")
summary(model_1)

## Old codes

## Dataset preparation-uploading data
Example dataset is time series dataset in which each day and municipality is a row includes the number of hospitalizations and whether or not that day was a heat wave. The dataset includes every day from January 1st 2008 to December 31st, 2018. If there was no hospitalization in a municipality on any given day, it will be listed as 0. If there was a heatwave, hw = 1, and if no heatwave, hw = 0. First, in order to change our dataset to case-crossover format, we will need to create a variable for weekday, month, year, week and day. We will then separate our data into an exposure dataset and a outcome dataset. A new date variable called case_date is created and kept only in the outcome dataset to differentiate between the exposure date and case date.

```{r}
Baja_data <- read.csv("../data/BC_hosp_temp_08_18_clean.csv")

Baja_data$wday<-wday(Baja_data$date)
Baja_data$month<-month(Baja_data$date)
Baja_data$year<-year(Baja_data$date)
Baja_data$week<-week(Baja_data$date)
Baja_data$day<-format(as.Date(Baja_data$date,format="%Y-%m-%d"), "%d")

Baja_data$date<- as.numeric(as.character(as.Date(Baja_data$date, format = "%Y-%m-%d"), format="%Y%m%d"))
Baja_data$case_date<- Baja_data$date

Baja_hosp = subset(Baja_data, select = c("munic", "case_date", "adm2_es", "month", "year", "day", "wday", "all_hosp")     ) 
Baja_temp = subset(Baja_data, select = c("munic", "date", "month", "year", "wday", "max_temp_era5", "min_temp_era5", "hw")     ) 


```
## Let's take a quick look at our data format and exposure over time
```{r}
head(Baja_hosp)

Baja_temp %>% 
  group_by(month, munic) %>% 
  summarise(hw_by_month = sum(hw))
```

## Preparing outcome dataset
We can delete any missing data as any row which does not have any hospitalization as this day will not be considered in our analysis. We will also need a unique identifier for each row which will represent each case-control combination in our final dataset. 
```{r}
Baja_hosp<-Baja_hosp[which(  Baja_hosp$all_hosp>0), ]

Baja_hosp$ID_grp<-seq.int(nrow(Baja_hosp)) 

```
## Preparing exposure dataset
As we are interested in looking at the lagged effect of heat waves, we create a new variables that indicates if a heat wave occurred 1 day before.

```{r}

Baja_temp <- Baja_temp[order(Baja_temp$date), ]

Baja_temp <-Baja_temp %>% 
  dplyr::mutate(Baja_temp, hw_lag1=lag(hw)) %>%
  dplyr::group_by(munic) 

```
## Restructuring dataset to time-stratified case crossover format
Here we merge in every row from the heat wave dataset that matches the case information in our outcome dataset for municipality, year, month and weekday. By doing this, we will have 3-4 additional rows for each original data line in our health data, with information about whether or not there was a heat wave that day. Then, we create a new variable, called case, which will be 1 when the date variable in our outcome dataset and exposure dataset are the same. These represent the original case days in our outcome dataset. The ID_grp variable which we created above will be the same across case and control matches, and will be used to indicate each strata of case and controls which the analysis will be matched on.

```{r}

Baja_data_cc <- Baja_hosp %>%       
  dplyr::left_join(Baja_temp, by = c("munic","year", "month", "wday")) %>%  #add the temperature data
  dplyr::mutate(case = if_else(case_date==date, 1, 0))            #generate case and control observations
  
```

## Association between hospitalizations and same day heatwave for entire region
We then run a conditional logistic model with fixed effect for each strata or ID_grp on the newly structured data. Since our original data was formatted in which the health variable was a total number of hospitalizations for each municipality-date, we then weight our regression by this variable of the number of hospitalizations. To understand the association in the whole region, we don't specify any subregion and it will provide us with an overall effect. 

```{r}

model_region<-clogit(case~ hw + strata(ID_grp), data=Baja_data_cc, weights=all_hosp, method="approximate")
summary(model_region)

```

## Association between hospitalizations and same day heatwave for each municipality
If we are interested in looking at subregions, we can conduct stratified analyses by municipality and compare results. 


```{r}
model_Tijuana<-clogit(case~ hw + strata(ID_grp), data=Baja_data_cc[Baja_data_cc$munic==4,], weights=all_hosp, method="approximate")
summary(model_Tijuana)


model_Tecate<-clogit(case~ hw + strata(ID_grp), data=Baja_data_cc[Baja_data_cc$munic==3,], weights=all_hosp, method="approximate")
summary(model_Tecate)


model_Rosarito<-clogit(case~ hw + strata(ID_grp), data=Baja_data_cc[Baja_data_cc$munic==5,], weights=all_hosp, method="approximate")
summary(model_Rosarito)
```

# Association between hospitalizations and previous day heat wave
To look at lagged effect, we can use the lagged exposure variable which we created above in the model.

```{r}

model_Tijuana_lag<-clogit(case~ hw_lag1 + strata(ID_grp), data=Baja_data_cc[Baja_data_cc$munic==4,], weights=all_hosp, method="approximate")
summary(model_Tijuana_lag)


model_Tecate_lag<-clogit(case~ hw_lag1 + strata(ID_grp), data=Baja_data_cc[Baja_data_cc$munic==3,], weights=all_hosp, method="approximate")
summary(model_Tecate_lag)


model_Rosarito_lag<-clogit(case~ hw_lag1 + strata(ID_grp), data=Baja_data_cc[Baja_data_cc$munic==5,], weights=all_hosp, method="approximate")
summary(model_Rosarito_lag)



model_Region_lag<-clogit(case~ hw_lag1 + strata(ID_grp), data=Baja_data_cc, weights=all_hosp, method="approximate")
summary(model_Region_lag)
```
