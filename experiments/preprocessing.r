library(fst)
library(data.table)
library(tidyverse)

# Load Medicare
setwd("/n/dominici_nsaph_l3/projects/analytic/aggregate_medicare_data_2010to2016")
medicare_us <- as.data.frame(read_fst("aggregate_medicare_data_2010to2016.fst",
                                      as.data.table = TRUE))
binary <- FALSE

for (regionname in c("northeast","south","midwest","west")) {
  
  northeast <- c("ME", "VT", "NH", "MA", "CT", "RI", "NY", "NJ", "PA", "DE", "MD", "DC")
  south <- c("WV", "VA", "KY", "TN", "NC", "SC", "GA", "AL", "MS", "AR", "LA", "OK", "TX")
  midwest <- c("ND", "SD", "NE", "KS", "MO", "IA", "MN", "WI", "IL", "MI", "IN", "OH")
  west <- c("MT", "WY", "CO", "NM", "ID", "UT", "NV", "AZ", "WA", "OR", "CA", "AK", "HI")
  statecodes <- get(regionname)
  medicare <- filter(medicare_us, statecode %in% statecodes) 
  
  path_folder <-paste("/n/home_fasse/rcadei/medicare/",regionname,sep="")
  if (!file.exists(path_folder)) dir.create(path_folder)
  
  # Discard useless variable
  medicare <- select(medicare, -qid, -statecode, -year, -zip, -entry_age_break,
                     -followup_year, -followup_year_plus_one, -dead)
  
  # Treatment
  medicare$pm25 <- (medicare$pm25_ens_2010+medicare$pm25_ens_2011)/2
  medicare <- select(medicare, -pm25_ens_2010, -pm25_ens_2011, -pm25_avg, -pm25_10, -pm25_12)
  
  # Outcome
  medicare <- medicare %>% mutate(dead_in_5 = as.integer(dead_in_5))
  
  if (binary) {
    # Covariates - County level
    medicare$county_bmi <- ifelse((medicare$mean_bmi <= median(medicare$mean_bmi)), 0, 1)
    medicare$county_smoke <- ifelse((medicare$smoke_rate <= median(medicare$smoke_rate)), 0, 1)
    medicare <- select(medicare, -mean_bmi, -smoke_rate)
    
    # Covariates - Zip-Code level
    medicare$zc_black <- ifelse((medicare$pct_blk <= median(medicare$pct_blk)), 0, 1)
    medicare$zc_hispanic <- ifelse((medicare$hispanic <= median(medicare$hispanic)), 0, 1)
    medicare$zc_household_income <- ifelse((medicare$medhouseholdincome <= median(medicare$medhouseholdincome)), 0, 1)
    medicare$zc_house_value <- ifelse((medicare$medianhousevalue <= median(medicare$medianhousevalue)), 0, 1)
    medicare$zc_owner_occupancy <- ifelse((medicare$pct_owner_occ <= median(medicare$pct_owner_occ)), 0, 1)
    medicare$zc_nodiploma <- ifelse((medicare$education <= median(medicare$education)), 0, 1)
    medicare$zc_poverty <- ifelse((medicare$poverty <= median(medicare$poverty)), 0, 1)
    medicare$zc_density <- ifelse((medicare$popdensity <= median(medicare$popdensity)), 0, 1)
    medicare <- select(medicare, -pct_blk, -hispanic, -medhouseholdincome, -medianhousevalue, -education, -poverty, -pct_owner_occ, -popdensity)
    
    # Covariates - Individual Level
    medicare$white <- as.integer((medicare$race == 1))
    medicare$black <- as.integer((medicare$race == 2))
    medicare$hispanic <- as.integer((medicare$race == 4))
    medicare$other_race <- as.integer((medicare$race == 0 |
                                         medicare$race == 3 |
                                         medicare$race == 5 |
                                         medicare$race == 6))
    medicare$male <- as.integer(medicare$sex == 2)
    medicare$old <- ifelse((medicare$age <= median(medicare$age)), 0, 1)
    medicare <- medicare %>% mutate(medicaid = as.integer(dual))
    medicare <- select(medicare, -sex, -race, -age, -dual)
    
    # Save preprocessed Medicare
    save(medicare, file = paste(path_folder,"medicare_bin.RData", sep="/"))
  } else {
    # Covariates - County level
    medicare$county_bmi <- medicare$mean_bmi 
    medicare$county_smoke <- medicare$smoke_rate 
    medicare <- select(medicare, -mean_bmi, -smoke_rate)
    
    # Covariates - Zip-Code level
    medicare$zc_black <- medicare$pct_blk 
    medicare$zc_hispanic <- medicare$hispanic 
    medicare$zc_household_income <- medicare$medhouseholdincome 
    medicare$zc_house_value <- medicare$medianhousevalue 
    medicare$zc_owner_occupancy <- medicare$pct_owner_occ 
    medicare$zc_nodiploma <- medicare$education 
    medicare$zc_poverty <- medicare$poverty 
    medicare$zc_density <- medicare$popdensity 
    medicare <- select(medicare, -pct_blk, -hispanic, -medhouseholdincome, -medianhousevalue, -education, -poverty, -pct_owner_occ, -popdensity)
    
    # Covariates - Individual Level
    medicare$white <- as.integer((medicare$race == 1))
    medicare$black <- as.integer((medicare$race == 2))
    medicare$hispanic <- as.integer((medicare$race == 4))
    medicare$other_race <- as.integer((medicare$race == 0 |
                                         medicare$race == 3 |
                                         medicare$race == 5 |
                                         medicare$race == 6))
    medicare$male <- as.integer(medicare$sex == 2)
    medicare <- medicare %>% mutate(medicaid = as.integer(dual))
    medicare <- select(medicare, -sex, -race, -dual)
    
    # Save preprocessed Medicare
    save(medicare, file = paste(path_folder,"medicare.RData", sep="/"))
  }
}