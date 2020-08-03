library(civis)
library(sf)
library(sp)
library(MASS)
library(leaflet)
library(leaflet.extras)
library(dplyr)
library(stringr)

gotc <- sql("select
px.code,
            px.national_precinct_code,
            p.van_precinct_id,
            p.van_precinct_name,
            p.county_name,
            p.county_fips,
            px.us_cong_district congressional_district,
            px.senate_district,
            px.assembly_district,
            t.region_name region,
            t.fo_name turf,
            pv.delegates delegates,
            COUNT(distinct p.person_id) registered_active_voters,
            count(distinct(p.voting_address_id)) total_addresses,
            SUM(current_support_raw) current_support_raw,
            SUM(current_support_composite) current_support_composite,
            ROUND(SUM(turnout_current::FLOAT)/100,0) turnout_projections,
            SUM(biden_support) biden_support,
            SUM(warren_support) warren_suport,
            SUM(buttigieg_support) buttigieg_support,
            SUM(harris_support) harris_support,
            SUM(yang_support) yang_support,
            SUM(field_id_1_score) field_id_1_score,
            SUM(field_id_5_score) field_id_5_score,
            SUM(field_id_composite_score) field_id_composite_score,
            SUM(sanders_very_excited_score) sanders_very_excited_score,
            SUM(sanders_strong_support_score) sanders_strong_support_score,
            SUM(ctc_dem) ctc_dem,
            SUM(ctc_npp) ctc_npp,
            SUM(id_1_dem) id_1_dem,
            SUM(id_1_npp) id_1_npp,
            SUM(id_2_dem) id_2_dem,
            SUM(id_2_npp) id_2_npp,
            SUM(attended_1_event) attended_1_event,
            SUM(attended_3_events) attended_3_events,
            SUM(hosted_1_event) hosted_1_event,
            SUM(donated) donated,
            SUM(donated_multiple) donated_multiple,
            SUM(afam_age_under_35) afam_age_under_35,
            SUM(latino_all) latino_all,
            SUM(aapi_all) aapi_all,
            SUM(aapi_age_under_35) aapi_age_under_35,
            SUM(muslim_all) muslim_all,
            SUM(age_under_40_all) age_under_40_all,
            SUM(age_under_30_all) age_under_30_all,
            SUM(white_noncollege_women_under_35) white_noncollege_women_under_35,
            SUM(white_noncollege_men_under_35) white_noncollege_men_under_35,
            SUM(liberal_independents) liberal_independents,
            SUM(age_18_to_29) age_18_to_29,
            SUM(age_18_to_29_noncollege) age_18_to_29_noncollege,
            SUM(independents_18_to_49) independents_18_to_49,
            SUM(latina_women_18_to_49) latina_women_18_to_49,
            SUM(men_18_to_39) men_18_to_39,
            SUM(college_18_to_29) college_18_to_29,
            SUM(noncollege_men_18_to_49) noncollege_men_18_to_49,
            SUM(white_independents) white_independents,
            SUM(latinos_18_to_49) latinos_18_to_49,
            SUM(independent_men) independent_men,
            SUM(age_18_to_39) age_18_to_39,
            SUM(all_independents) all_independents,
            SUM(latinos_noncollege) latinos_noncollege,
            SUM(donut_core_bernie) donut_core_bernie,
            SUM(donut_soft_support) donut_soft_support,
            SUM(donut_shifter) donut_shifter,
            SUM(donut_potential_support) donut_potential_support,
            SUM(donut_no_opinion) donut_no_opinion,
            SUM(donut_anti_bernie) donut_anti_bernie,
            COUNT(DISTINCT CASE WHEN support_int = 1 AND unique_id_flag = 'true' THEN externalcontactid END) ones,
            COUNT(DISTINCT CASE WHEN support_int = 2 AND unique_id_flag = 'true' THEN externalcontactid END) twos,
            COUNT(DISTINCT CASE WHEN support_int = 3 AND unique_id_flag = 'true' THEN externalcontactid END) threes,
            COUNT(DISTINCT CASE WHEN support_int = 4 AND unique_id_flag = 'true' THEN externalcontactid END) fours,
            COUNT(DISTINCT CASE WHEN support_int = 5 AND unique_id_flag = 'true' THEN externalcontactid END) fives,
            sum(case when support_threshold_combined >= 25 then 1 else 0 end) as supp_25_count,
            sum(case when support_threshold_combined >= 30 then 1 else 0 end) as supp_30_count,
            sum(case when support_threshold_combined >= 35 then 1 else 0 end) as supp_35_count,
            sum(case when support_threshold_combined >= 40 then 1 else 0 end) as supp_40_count,
            sum(case when support_threshold_combined >= 45 then 1 else 0 end) as supp_45_count,
            sum(case when support_threshold_combined >= 50 then 1 else 0 end) as supp_50_count,
            sum(case when support_threshold_combined >= 55 then 1 else 0 end) as supp_55_count,
            sum(case when support_threshold_combined >= 60 then 1 else 0 end) as supp_60_count,
            sum(case when support_threshold_combined >= 65 then 1 else 0 end) as supp_65_count
            from haystaq_outgoing.nv_gotc_pops_temp nv
            join phoenix_analytics_nv.person p
            on p.person_id = nv.person_id
            left join bernie_data_commons.contactcontacts_joined ccj
            on ccj.person_id = p.person_id and unique_id_flag = true
            left join (select *, ntile(10) over (order by turnout_current) as to_decile
            from bernie_data_commons.all_scores where state_code = 'NV'
            and turnout_current is not null) scores
            on scores.person_id = nv.person_id
            left join bernie_zasman.ss_precinct_xwalk px
            ON p.van_precinct_id = px.van_precinct_id
            left join bernie_zasman.ss_precinct_viability pv
            ON px.van_precinct_id = pv.van_precinct_id
            left join phoenix_demssanders20_vansync.turf t
            ON px.van_precinct_id = t.van_precinct_id
            group by 1,2,3,4,5,6,7,8,9,10,11,12") %>% read_civis()

df <- gotc

county_fips <- read.csv('county_fips.csv') %>%  mutate(county_fips = case_when(county_name %in% c("CLARK", "CHURCHILL", "DOUGLAS", "ELKO", "ESMERALDA") ~ paste('00',county_fips, sep = ""),
                                                                               county_name %in% c("WASHOE","LYON","NYE","STOREY","HUMBOLDT","MINERAL","PERSHING","EUREKA","WHITE PINE","LANDER","LINCOLN") ~
                                                                                 paste('0',county_fips,sep=""), county_name == 'CARSON CITY' ~ paste(county_fips))) 

# Clark -------------------------------------------------------------------

clark_sf <- "./shapefiles/clark/precinct" %>% st_read() %>% mutate(national_precinct_code =  paste('NV_CLARK_',PREC, sep = "")) %>%
  dplyr::select(national_precinct_code,geometry) %>% left_join(df, by = "national_precinct_code")

clark <- clark_sf %>% dplyr::mutate(county_name = case_when(is.na(county_name) ~ paste('Clark'), county_name == 'Clark' ~ paste(county_name))) %>% st_as_sf()

clark_county <- st_transform(clark, ("+init=epsg:4326"))

# Washoe -------------------------------------------------------------------

washoe_sf <- "./shapefiles/washoe/precinct" %>% st_read() %>% mutate(PREC = paste(PRECINCT,'00', sep = ''), national_precinct_code = paste('NV_WASHOE_',PREC, sep = "")) %>% 
  dplyr::select(national_precinct_code,geometry) %>% left_join(df, by = "national_precinct_code")

washoe <- washoe_sf %>% mutate(county_name = case_when(is.na(county_name) ~ paste('Washoe'), county_name == 'Washoe' ~ paste(county_name))) %>% st_as_sf()

washoe_county <- st_transform(washoe, ("+init=epsg:4326"))

# White Pine -------------------------------------------------------------------

white_pine_sf <- "./shapefiles/other/precinct" %>% st_read() %>% ungroup() %>% rename(county_fips = COUNTYFP10) %>% left_join(county_fips, by = "county_fips") %>% filter(county_name == 'WHITE PINE') %>% 
  mutate(PREC = str_extract(NAME10, '\\d+'),PREC = case_when(str_detect(PREC, '^\\d$')~paste('0',PREC,sep=""), !str_detect(PREC, '^\\d$') ~ paste(PREC)), national_precinct_code =  paste('NV_WHITE PINE_',PREC, sep = "")) %>%
  dplyr::select(national_precinct_code,geometry) %>% left_join(df, by = "national_precinct_code") 

white_pine <- white_pine_sf %>% mutate(county_name = case_when(is.na(county_name) ~ paste('White Pine'), county_name == 'White Pine' ~ paste(county_name))) %>% st_as_sf()

white_pine_county <- st_transform(white_pine, ("+init=epsg:4326"))

# Humboldt -------------------------------------------------------------------

humboldt_sf <- "./shapefiles/humboldt/precinct" %>% st_read() %>% dplyr::select(LAYER) %>% mutate(PREC = str_extract(LAYER, '\\d+'), PREC = case_when(str_detect(PREC, '^\\d$')~paste('0',PREC,sep=""), !str_detect(PREC, '^\\d$') ~ paste(PREC)),
                                                                                           national_precinct_code =  paste('NV_HUMBOLDT_',PREC, sep = "")) %>% 
  dplyr::select(national_precinct_code,geometry) %>% left_join(df, by = "national_precinct_code") 

humboldt <- humboldt_sf %>% mutate(county_name = case_when(is.na(county_name) ~ paste('Humboldt'), county_name == 'Humboldt' ~ paste(county_name))) %>% st_as_sf()

humboldt_county <- st_transform(humboldt, ("+init=epsg:4326"))

# Other -------------------------------------------------------------------

other_sf <- "./shapefiles/other/precinct" %>% st_read() %>% mutate(PREC = VTDST10) %>% rename(county_fips = COUNTYFP10) %>% left_join(county_fips, by = "county_fips") %>% filter(!str_detect(VTDST10, "-")) %>% filter(!county_name %in% c("CLARK","WASHOE", "HUMBOLDT", "WHITE PINE")) %>%
  mutate(PREC = case_when(str_detect(PREC, '^\\d$')~paste('0',PREC,sep=""), !str_detect(PREC, '^\\d$') ~ paste(PREC)), national_precinct_code =  paste('NV_',county_name,'_',PREC, sep ='')) %>% dplyr::select(national_precinct_code,geometry)  %>% left_join(df, by = "national_precinct_code") %>%
  mutate(county_name = case_when(national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09') ~ paste('Storey'),
                            national_precinct_code %in% c('NV_CARSON CITY_213','NV_CARSON CITY_311') ~ paste('Carson'),
                            !national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09', 'NV_CARSON CITY_213','NV_CARSON CITY_311') ~ paste(county_name))) %>%
  mutate(region = case_when(national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09') ~ '2', 
                            national_precinct_code %in% c('NV_CARSON CITY_213','NV_CARSON CITY_311') ~ '2',
                            !national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09','NV_CARSON CITY_213','NV_CARSON CITY_311') ~ paste(region))) %>%
  mutate(congressional_district = case_when(national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09') ~ '2',
                                      national_precinct_code %in% c('NV_CARSON CITY_213','NV_CARSON CITY_311') ~ '2',
                            !national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09', 'NV_CARSON CITY_213','NV_CARSON CITY_311') ~ paste(congressional_district))) %>%
  mutate(senate_district = case_when(national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09') ~ '17',
                                     national_precinct_code %in% c('NV_CARSON CITY_213','NV_CARSON CITY_311') ~ '16',
                            !national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09', 'NV_CARSON CITY_213','NV_CARSON CITY_311') ~ paste(senate_district))) %>%
  mutate(assembly_district = case_when(national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09') ~ '39',
                                       national_precinct_code %in% c('NV_CARSON CITY_213','NV_CARSON CITY_311') ~ '40',
                                     !national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09', 'NV_CARSON CITY_213','NV_CARSON CITY_311') ~ paste(assembly_district))) %>%
  mutate(turf = case_when(national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09') ~ '2A',
                          national_precinct_code %in% c('NV_CARSON CITY_213','NV_CARSON CITY_311') ~ '2B',
                                     !national_precinct_code %in% c('NV_STOREY_10','NV_STOREY_13', 'NV_STOREY_14','NV_STOREY_07','NV_STOREY_08','NV_STOREY_09', 'NV_CARSON CITY_213','NV_CARSON CITY_311') ~ paste(turf)))

other <- other_sf %>% st_as_sf()

other_county <- st_transform(other, ("+init=epsg:4326"))
# Combined -------------------------------------------------------------------

final_sf <- rbind(clark_county,washoe_county,white_pine_county,humboldt_county,other_county) 

final <-final_sf %>%  sf::st_as_sf() %>% filter(national_precinct_code != 'NV_DOUGLAS_ZZZZZZ') %>% 
rename(Code=code,
       Precinct=national_precinct_code,
       `VAN Precinct ID`=van_precinct_id,
       `VAN Precinct Name`=van_precinct_name,
       County=county_name,
       `Congressional District`=congressional_district,
       `Senate District`=senate_district,
       `Assembly District`=assembly_district,
       Region=region,
       Turf=turf,
       Delegates=delegates,
       `Registered Active Voters`=registered_active_voters,
       `Total Unique Addresses`=total_addresses,
       `Current Support (Raw)`=current_support_raw,
       `Current Support (Composite)`=current_support_composite,
       `Turnout Projections`=turnout_projections,
       `Biden Support`=biden_support,
       `Warren Support`=warren_suport,
       `Buttigieg Support`=buttigieg_support,
       `Harris Support`=harris_support,
       `Yang Support`=yang_support,
       `Field ID 1 Score`=field_id_1_score,
       `Field ID 5 Score`=field_id_5_score,
       `Field ID Composite Score`=field_id_composite_score,
       `Sanders Very Excited Score`=sanders_very_excited_score,
       `Sanders Strong Support Score`=sanders_strong_support_score,
       `CTC Dem`=ctc_dem,
       `CTC NPP`=ctc_npp,
       `ID 1 Dem`=id_1_dem,
       `ID 1 NPP`=id_1_npp,
       `ID 2 Dem`=id_2_dem,
       `ID 2 NPP`=id_2_npp,
       `Attended 1 Event`=attended_1_event,
       `Attended 3 Events`=attended_3_events,
       `Hosted 1 Event`=hosted_1_event,
       `Donated`=donated,
       `Donated Multiple`=donated_multiple,
       `Afam Age Under 35`=afam_age_under_35,
       `Latino All`=latino_all,
       `Aapi All`=aapi_all,
       `Aapi Age Under 35`=aapi_age_under_35,
       `Muslim All`=muslim_all,
       `Age Under 40 All`=age_under_40_all,
       `Age Under 30 All`=age_under_30_all,
       `White Noncollege Women Under 35`=white_noncollege_women_under_35,
       `White Noncollege Men Under 35`=white_noncollege_men_under_35,
       `Liberal Independents`=liberal_independents,
       `Age 18 To 29`=age_18_to_29,
       `Age 18 To 29 Noncollege`=age_18_to_29_noncollege,
       `Independents 18 To 49`=independents_18_to_49,
       `Latina Women 18 To 49`=latina_women_18_to_49,
       `Men 18 To 39`=men_18_to_39,
       `College 18 To 29`=college_18_to_29,
       `Noncollege Men 18 To 49`=noncollege_men_18_to_49,
       `White Independents`=white_independents,
       `Latinos 18 To 49`=latinos_18_to_49,
       `Independent Men`=independent_men,
       `Age 18 To 39`=age_18_to_39,
       `All Independents`=all_independents,
       `Latinos Noncollege`=latinos_noncollege,
       `Donut Core Bernie`=donut_core_bernie,
       `Donut Soft Support`=donut_soft_support,
       `Donut Shifter`=donut_shifter,
       `Donut Potential Support`=donut_potential_support,
       `Donut No Opinion`=donut_no_opinion,
       `Donut Anti Bernie`=donut_anti_bernie,
       `1s`=ones,
       `2s`=twos,
       `3s`=threes,
       `4s`=fours,
       `5s`=fives,
       `Supp 25 Count`=supp_25_count,
       `Supp 30 Count`=supp_30_count,
       `Supp 35 Count`=supp_35_count,
       `Supp 40 Count`=supp_40_count,
       `Supp 45 Count`=supp_45_count,
       `Supp 50 Count`=supp_50_count,
       `Supp 55 Count`=supp_55_count,
       `Supp 60 Count`=supp_60_count,
       `Supp 65 Count`=supp_65_count) %>%
        mutate(Code=tidyr::replace_na(as.character(Code),0),
         Precinct=tidyr::replace_na(Precinct,0),
         `VAN Precinct ID`=tidyr::replace_na(as.character(`VAN Precinct ID`,0)),
         `VAN Precinct Name`=tidyr::replace_na(`VAN Precinct Name`,0),
         County=tidyr::replace_na(County,0),
         `Congressional District`=tidyr::replace_na(`Congressional District`,0),
         `Senate District`=tidyr::replace_na(as.character(`Senate District`),0),
         `Assembly District`=tidyr::replace_na(as.character(`Assembly District`),0),
         Region=tidyr::replace_na(Region,0),
         Turf=tidyr::replace_na(as.character(Turf),0),
         Delegates=tidyr::replace_na(Delegates,0),
         `Registered Active Voters`=tidyr::replace_na(`Registered Active Voters`,0),
         `Total Unique Addresses`=tidyr::replace_na(`Total Unique Addresses`,0),
         `Current Support (Raw)`=tidyr::replace_na(`Current Support (Raw)`,0),
         `Current Support (Composite)`=tidyr::replace_na(`Current Support (Composite)`,0),
         `Turnout Projections`=tidyr::replace_na(`Turnout Projections`,0),
         `Biden Support`=tidyr::replace_na(`Biden Support`,0),
         `Warren Support`=tidyr::replace_na(`Warren Support`,0),
         `Buttigieg Support`=tidyr::replace_na(`Buttigieg Support`,0),
         `Harris Support`=tidyr::replace_na(`Harris Support`,0),
         `Yang Support`=tidyr::replace_na(`Yang Support`,0),
         `Field ID 1 Score`=tidyr::replace_na(`Field ID 1 Score`,0),
         `Field ID 5 Score`=tidyr::replace_na(`Field ID 5 Score`,0),
         `Field ID Composite Score`=tidyr::replace_na(`Field ID Composite Score`,0),
         `Sanders Very Excited Score`=tidyr::replace_na(`Sanders Very Excited Score`,0),
         `Sanders Strong Support Score`=tidyr::replace_na(`Sanders Strong Support Score`,0),
         `CTC Dem`=tidyr::replace_na(`CTC Dem`,0),
         `CTC NPP`=tidyr::replace_na(`CTC NPP`,0),
         `ID 1 Dem`=tidyr::replace_na(`ID 1 Dem`,0),
         `ID 1 NPP`=tidyr::replace_na(`ID 1 NPP`,0),
         `ID 2 Dem`=tidyr::replace_na(`ID 2 Dem`,0),
         `ID 2 NPP`=tidyr::replace_na(`ID 2 NPP`,0),
         `Attended 1 Event`=tidyr::replace_na(`Attended 1 Event`,0),
         `Attended 3 Events`=tidyr::replace_na(`Attended 3 Events`,0),
         `Hosted 1 Event`=tidyr::replace_na(`Hosted 1 Event`,0),
         `Donated`=tidyr::replace_na(`Donated`,0),
         `Donated Multiple`=tidyr::replace_na(`Donated Multiple`,0),
         `Afam Age Under 35`=tidyr::replace_na(`Afam Age Under 35`,0),
         `Latino All`=tidyr::replace_na(`Latino All`,0),
         `Aapi All`=tidyr::replace_na(`Aapi All`,0),
         `Aapi Age Under 35`=tidyr::replace_na(`Aapi Age Under 35`,0),
         `Muslim All`=tidyr::replace_na(`Muslim All`,0),
         `Age Under 40 All`=tidyr::replace_na(`Age Under 40 All`,0),
         `Age Under 30 All`=tidyr::replace_na(`Age Under 30 All`,0),
         `White Noncollege Women Under 35`=tidyr::replace_na(`White Noncollege Women Under 35`,0),
         `White Noncollege Men Under 35`=tidyr::replace_na(`White Noncollege Men Under 35`,0),
         `Liberal Independents`=tidyr::replace_na(`Liberal Independents`,0),
         `Age 18 To 29`=tidyr::replace_na(`Age 18 To 29`,0),
         `Age 18 To 29 Noncollege`=tidyr::replace_na(`Age 18 To 29 Noncollege`,0),
         `Independents 18 To 49`=tidyr::replace_na(`Independents 18 To 49`,0),
         `Latina Women 18 To 49`=tidyr::replace_na(`Latina Women 18 To 49`,0),
         `Men 18 To 39`=tidyr::replace_na(`Men 18 To 39`,0),
         `College 18 To 29`=tidyr::replace_na(`College 18 To 29`,0),
         `Noncollege Men 18 To 49`=tidyr::replace_na(`Noncollege Men 18 To 49`,0),
         `White Independents`=tidyr::replace_na(`White Independents`,0),
         `Latinos 18 To 49`=tidyr::replace_na(`Latinos 18 To 49`,0),
         `Independent Men`=tidyr::replace_na(`Independent Men`,0),
         `Age 18 To 39`=tidyr::replace_na(`Age 18 To 39`,0),
         `All Independents`=tidyr::replace_na(`All Independents`,0),
         `Latinos Noncollege`=tidyr::replace_na(`Latinos Noncollege`,0),
         `Donut Core Bernie`=tidyr::replace_na(`Donut Core Bernie`,0),
         `Donut Soft Support`=tidyr::replace_na(`Donut Soft Support`,0),
         `Donut Shifter`=tidyr::replace_na(`Donut Shifter`,0),
         `Donut Potential Support`=tidyr::replace_na(`Donut Potential Support`,0),
         `Donut No Opinion`=tidyr::replace_na(`Donut No Opinion`,0),
         `Donut Anti Bernie`=tidyr::replace_na(`Donut Anti Bernie`,0),
         `1s`=tidyr::replace_na(`1s`,0),
         `2s`=tidyr::replace_na(`2s`,0),
         `3s`=tidyr::replace_na(`3s`,0),
         `4s`=tidyr::replace_na(`4s`,0),
         `5s`=tidyr::replace_na(`5s`,0),
         `Supp 25 Count`=tidyr::replace_na(`Supp 25 Count`,0),
         `Supp 30 Count`=tidyr::replace_na(`Supp 30 Count`,0),
         `Supp 35 Count`=tidyr::replace_na(`Supp 35 Count`,0),
         `Supp 40 Count`=tidyr::replace_na(`Supp 40 Count`,0),
         `Supp 45 Count`=tidyr::replace_na(`Supp 45 Count`,0),
         `Supp 50 Count`=tidyr::replace_na(`Supp 50 Count`,0),
         `Supp 55 Count`=tidyr::replace_na(`Supp 55 Count`,0),
         `Supp 60 Count`=tidyr::replace_na(`Supp 60 Count`,0),
         `Supp 65 Count`=tidyr::replace_na(`Supp 65 Count`,0)) %>% dplyr::select(-c(Code,`VAN Precinct Name`,county_fips))
  
df  <- final %>% st_drop_geometry() 

nv <- final

rm(list=ls()[! ls() %in% c("df")])

region <- final %>% st_buffer(0) %>% group_by(Region) %>% summarise_if(is.numeric, sum)

region_turf <- final %>% st_buffer(0) %>% group_by(Region,Turf) %>% summarise_if(is.numeric, sum)

region_turf_precinct <- final %>% st_buffer(0) %>% group_by(Region,Turf,Precinct) %>% summarise_if(is.numeric, sum)

county <- final %>% st_buffer(0) %>% group_by(County) %>% summarise_if(is.numeric, sum)

cong_district <- final %>% st_buffer(0) %>% group_by(`Congressional District`) %>% summarise_if(is.numeric, sum)

senate <- final %>% st_buffer(0) %>% group_by(`Senate District`) %>% summarise_if(is.numeric, sum)

assembly <- final %>% st_buffer(0) %>% group_by(`Assembly District`) %>% summarise_if(is.numeric, sum)

metrics_list <- c(final %>% st_drop_geometry() %>% dplyr::select_if(is.numeric) %>% colnames())

#save.image(file="df.RData")
