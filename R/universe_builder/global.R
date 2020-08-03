library(dplyr)
library(DT)
library(shinydashboard)
library(shiny)
library(shinyWidgets)
library(shinyjs)
library(civis)
library(highcharter)
library(rpivotTable)
library(pivottabler)
library(leaflet)
library(plotly)

##Canonical dataset

df <- sql("SELECT * FROM bernie_zasman.universe_explorer sf") %>% read_civis()

##Manipulate canonical dataset

df_sample <- df %>% mutate(county = as.character(county), zip = as.character(zip), city = as.character(city), precinct = as.character(precinct),
  turf = as.character(turf), region = as.character(region), ethnicity = as.character(ethnicity), gender = as.character(gender), party = as.character(party),
  college_status = as.character(college_status), income = as.character(income), third_party_first_choice = as.character(third_party_first_choice), third_party_second_choice = as.character(third_party_second_choice),
  union_flag = as.character(union_flag), legacy_support = as.character(legacy_support), target_categories = as.character(target_categories), donut_segment = as.character(donut_segment), density = as.character(density),  early_voting_propensity = round(early_voting_propensity*100,0),
  social_media_user_score = round(social_media_user_score*100,0), tv_viewer_watch_live_score = round(tv_viewer_watch_live_score*100,0), ctc = ctc_dem + ctc_npp, legacy_support = as.integer(legacy_support), contact_made = case_when(door_contact_made == 1 | dialer_contact_made == 1 ~ 1,
                                                                                                 door_contact_made == 0 & dialer_contact_made == 0 ~ 0), person_id =as.character(person_id), congressional_district = as.character(congressional_district)) %>%filter(region != '0')  %>% replace(is.na(.), 0)


rm(list=setdiff(ls(), c("df_sample")))

save.image("df_frame.RData")
