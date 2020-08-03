--Used to help identify which early voting location was closest to voters

CREATE TABLE bernie_zasman.ev_rank AS (
SELECT DISTINCT
dis.van_precinct_id,
dis.early_vote_location_id,
loc.early_vote_location,
dis.distance,
saturday,
sunday,
monday,
tuesday
FROM
bernie_mjohnson2.nv_voters_ev_sites ev
JOIN (SELECT
*,
CASE WHEN dates_hours LIKE 'Sa%' THEN 1 ELSE 0 END saturday,
CASE WHEN dates_hours LIKE 'Su%' OR dates_hours LIKE '%Su%' THEN 1 ELSE 0 END sunday,
CASE WHEN dates_hours LIKE 'Mo%' OR dates_hours LIKE '%Mo%' THEN 1 ELSE 0 END monday,
CASE WHEN dates_hours LIKE 'Tu%' OR dates_hours LIKE '%Tu%' THEN 1 ELSE 0 END tuesday
FROM 
phoenix_voting_locations.early_vote_locations evl 
WHERE evl.state_code = 'NV') loc
ON ev.ev_site_1_id = loc.early_vote_location_id
JOIN (SELECT DISTINCT 
*
FROM (
SELECT DISTINCT
van_precinct_id,
early_vote_location_id,
distance,
RANK() over (PARTITION BY van_precinct_id ORDER BY distance) dist_rnk
FROM phoenix_voting_locations.precinct_to_ev_location ev 
WHERE ev.state_code = 'NV' )
WHERE dist_rnk = 1) dis
ON ev.ev_site_1_id = dis.early_vote_location_id
JOIN phoenix_analytics_nv.person per
ON ev.person_id = per.person_id
JOIN gotv_universes.nv_gotc_master_universe gotc
ON per.person_id = gotc.person_id
ORDER BY 1)
