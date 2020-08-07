##Script used to calcuate nearest distance between potential voters and voting precinct

library(geosphere)
library(dplyr)

df_early_vote <- sql("SELECT
                     *,
                     CASE WHEN saturday = 'Open' THEN 1 WHEN saturday = 'Closed' THEN 0 END + CASE WHEN sunday = 'Open' THEN 1 WHEN sunday = 'Closed' THEN 0 END +
                     CASE WHEN monday = 'Open' THEN 1 WHEN monday = 'Closed' THEN 0 END + CASE WHEN tuesday = 'Open' THEN 1 WHEN tuesday = 'Closed' THEN 0 END days_open
                     FROM (
                     SELECT DISTINCT
                     *,
                     CASE WHEN dates_hours LIKE 'Sa%' THEN 'Open' ELSE 'Closed' END saturday,
                     CASE WHEN dates_hours LIKE 'Su%' OR dates_hours LIKE '%Su%' THEN 'Open' ELSE 'Closed' END sunday,
                     CASE WHEN dates_hours LIKE 'Mo%' OR dates_hours LIKE '%Mo%' THEN 'Open' ELSE 'Closed' END monday,
                     CASE WHEN dates_hours LIKE 'Tu%' OR dates_hours LIKE '%Tu%' THEN 'Open' ELSE 'Closed' END tuesday
                     FROM
                     phoenix_voting_locations.early_vote_locations evl
                     WHERE evl.state_code = 'NV')") %>% read_civis()

df_universe <- sql("SELECT DISTINCT
                   us.person_id,
                   per.voting_address_longitude longitude,
                   per.voting_address_latitude latitude
                   FROM
                   bernie_zasman.master_universe us
                   JOIN bernie_data_commons.all_scores sco
                   ON us.person_id = sco.person_id
                   JOIN phoenix_analytics_nv.person per
                   ON sco.person_id = per.person_id
                   JOIN bernie_zasman.ss_precinct_xwalk xw
                   ON per.van_precinct_id = xw.van_precinct_id
                   JOIN phoenix_demssanders20_vansync.turf t
                   ON xw.van_precinct_id = t.van_precinct_id") %>% read_civis()

person_location <-
  structure(list(id = c(df_universe$person_id), 
                 longitude = c(df_universe$longitude), 
                 latitude = c(df_universe$latitude)), 
            class = "data.frame", row.names = c(NA, -235023L))

building_location <-
  structure(list(building_id = c(as.character(df_early_vote$early_vote_location_id)), 
                 longitude_building = c(df_early_vote$longitude), 
                 latitude_building = c(df_early_vote$latitude)), 
            class = "data.frame", row.names = c(NA, -79L))

all_locations <- base::merge(person_location, building_location, by=NULL)

all_locations$distance <- distHaversine( 
  all_locations[, c("longitude", "latitude")],
  all_locations[, c("longitude_building", "latitude_building")]
)

closest <- all_locations %>% 
  group_by(id) %>% 
  filter( distance == min(distance)  ) %>% 
  ungroup() %>% rename(person_id = id, early_vote_location_id = building_id)

df_ev <- df_early_vote %>% dplyr::select(early_vote_location_id, early_vote_location, address, city, zip, saturday, sunday, monday, tuesday, days_open) %>% mutate(early_vote_location_id = as.character(early_vote_location_id))

df_final <- closest %>% mutate(distance = round(distance/1609,4)) %>% left_join(df_ev, by = "early_vote_location_id")

write_civis(df_final, "bernie_zasman.early_voting_prox", if_exists="drop")
