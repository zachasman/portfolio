--Table building process for caucus day reporting

CREATE TABLE bernie_zasman.temp_pipelines AS (
SELECT DISTINCT
CASE WHEN cvv.email IS NOT NULL OR cvv.phone IS NOT NULL THEN 1 ELSE 0 END volunteer_validation,
CASE WHEN duplicate_validation IS NULL THEN 1 WHEN duplicate_validation = 1 THEN 1 ELSE 0 END duplicate_validation,
CASE WHEN spv.code IS NOT NULL THEN 1 ELSE 0 END precinct_validation,
spv.van_precinct_id,
cdm.county,
cdm.email_address,
cdm.precinct_number,
cdm."timestamp",
cdm.phone,
cdm.caucus_location
FROM
nv_caucus_night.caucus_day_master cdm
LEFT JOIN nv_caucus_night.caucus_vols_validation cvv
ON cdm.email_address = cvv.email
OR cdm.phone = cvv.phone
LEFT JOIN (SELECT
precinct_code,
CASE WHEN check1 = 1 AND check2 = 1 AND check3 = 1 AND check4 = 1 THEN 1 ELSE 0 END duplicate_validation
FROM (
SELECT
county||precinct_number precinct_code,
COUNT(DISTINCT total_attendance) check1,
COUNT(DISTINCT sanders_present_first_count) check2,
COUNT(DISTINCT sanders_present_realignment) check3,
COUNT(DISTINCT sanders_delegates_awarded) check4
FROM
nv_caucus_night.caucus_day_master
WHERE county||precinct_number IN (
SELECT
precinct_code
FROM (
SELECT DISTINCT
county||precinct_number precinct_code,
COUNT(*) unique_precinct_check
FROM
nv_caucus_night.caucus_day_master cdm
WHERE precinct_code IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC)
WHERE unique_precinct_check > 1)
GROUP BY 1)) dupe
ON cdm.county||cdm.precinct_number = dupe.precinct_code
LEFT JOIN bernie_zasman.ss_precinct_viability spv
ON cdm.county||cdm.precinct_number = spv.code
WHERE cdm.first_name IS NOT NULL

);

SELECT DISTINCT
van_precinct_id,
precinct_name,
county,
congressional_district,
total_participants,
delegates,
viability_threshold,
preference_threshold,
bennet_total_first_count,
bennet_total_realignment,
biden_total_first_count,
biden_total_realignment,
buttigieg_total_first_count,
buttigieg_total_realignment,
delaney_total_first_count,
delaney_total_realignment,
gabbard_total_first_count,
gabbard_total_realignment,
klobuchar_total_first_count,
klobuchar_total_realignment,
patrick_total_first_count,
patrick_total_realignment,
sanders_total_first_count,
sanders_total_realignment,
steyer_total_first_count,
steyer_total_realignment,
warren_total_first_count,
warren_total_realignment,
yang_total_first_count,
yang_total_realignment,
uncommitted_total_first_count,
uncommitted_total_realignment,
bennet_delegates_awarded,
biden_delegates_awarded,
buttigieg_delegates_awarded,
delaney_delegates_awarded,
gabbard_delegates_awarded,
klobuchar_delegates_awarded,
patrick_delegates_awarded,
sanders_delegates_awarded,
steyer_delegates_awarded,
warren_delegates_awarded,
yang_delegates_awarded,
uncommitted_delegates_awarded
FROM (
SELECT DISTINCT
van_precinct_id,
first_name,
last_name,
phone,
email_address,
code precinct_name,
county,
us_cong_district congressional_district,
delegates,
viability_threshold,
total_attendance in_person_attendance,
early_vote_count,
total_attendance + early_vote_count total_participants,
(total_attendance::FLOAT + early_vote_count::FLOAT) * viability_threshold::FLOAT preference_threshold,
bennet_present_first_count,
bennet_early_vote_count,
bennet_present_first_count + bennet_early_vote_count bennet_total_first_count,
biden_present_first_count,
biden_early_vote_count,
biden_present_first_count + biden_early_vote_count biden_total_first_count,
buttigieg_present_first_count,
buttigieg_early_vote_count,
buttigieg_present_first_count + buttigieg_early_vote_count buttigieg_total_first_count,
delaney_present_first_count,
delaney_early_vote_count,
delaney_present_first_count + delaney_early_vote_count delaney_total_first_count,
gabbard_present_first_count,
gabbard_early_vote_count,
gabbard_present_first_count + gabbard_early_vote_count gabbard_total_first_count,
klobuchar_present_first_count,
klobuchar_early_vote_count,
klobuchar_present_first_count + klobuchar_early_vote_count klobuchar_total_first_count,
patrick_present_first_count,
patrick_early_vote_count,
patrick_present_first_count + patrick_early_vote_count patrick_total_first_count,
sanders_present_first_count,
sanders_early_vote_count,
sanders_present_first_count + sanders_early_vote_count sanders_total_first_count,
steyer_present_first_count,
steyer_early_vote_count,
steyer_present_first_count + steyer_early_vote_count steyer_total_first_count,
warren_present_first_count,
warren_early_vote_count,
warren_present_first_count + warren_early_vote_count warren_total_first_count,
yang_present_first_count,
yang_early_vote_count,
yang_present_first_count + yang_early_vote_count yang_total_first_count,
uncommitted_present_first_count,
uncommitted_early_vote_count,
uncommitted_present_first_count + uncommitted_early_vote_count uncommitted_total_first_count,
bennet_present_realignment,
bennet_early_vote_realignment,
bennet_present_realignment + bennet_early_vote_realignment bennet_total_realignment,
biden_present_realignment, 
biden_early_vote_realignment,
biden_present_realignment + biden_early_vote_realignment biden_total_realignment,
buttigieg_present_realignment, 
buttigieg_early_vote_realignment,
buttigieg_present_realignment + buttigieg_early_vote_realignment buttigieg_total_realignment,
delaney_present_realignment,
delaney_early_vote_realignment,
delaney_present_realignment + delaney_early_vote_realignment delaney_total_realignment,
gabbard_present_realignment, 
gabbard_early_vote_realignment,
gabbard_present_realignment + gabbard_early_vote_realignment gabbard_total_realignment,
klobuchar_present_realignment, 
klobuchar_early_vote_realignment,
klobuchar_present_realignment + klobuchar_early_vote_realignment klobuchar_total_realignment,
patrick_present_realignment,
patrick_early_vote_realignment,
patrick_present_realignment + patrick_early_vote_realignment patrick_total_realignment,
sanders_present_realignment, 
sanders_early_vote_realignment,
sanders_present_realignment + sanders_early_vote_realignment sanders_total_realignment,
steyer_present_realignment, 
steyer_early_vote_realignment,
steyer_present_realignment + steyer_early_vote_realignment steyer_total_realignment,
warren_present_realignment, 
warren_early_vote_realignment,
warren_present_realignment + warren_early_vote_realignment warren_total_realignment,
yang_present_realignment,
yang_early_vote_realignment,
yang_present_realignment + yang_early_vote_realignment yang_total_realignment,
uncommitted_present_realignment, 
uncommitted_early_vote_realignment,
uncommitted_present_realignment + uncommitted_early_vote_realignment uncommitted_total_realignment,
bennet_delegates_awarded,
biden_delegates_awarded,
buttigieg_delegates_awarded,
delaney_delegates_awarded,
gabbard_delegates_awarded,
klobuchar_delegates_awarded,
patrick_delegates_awarded,
sanders_delegates_awarded,
steyer_delegates_awarded,
warren_delegates_awarded,
yang_delegates_awarded,
uncommitted_delegates_awarded
FROM (
SELECT
cdm.*,
pv.van_precinct_id,
pv.code,
pv.delegates,
pv.us_cong_district,
pv.viability_threshold
FROM
nv_caucus_night.caucus_day_master cdm
LEFT JOIN bernie_zasman.ss_precinct_viability pv
ON cdm.county||cdm.precinct_number = pv.code
LEFT JOIN bernie_zasman.temp_pipelines tp
ON pv.van_precinct_id = tp.van_precinct_id::VARCHAR
WHERE volunteer_validation = 1 AND duplicate_validation = 1 AND precinct_validation = 1))

CREATE TABLE nv_caucus_night.ss_precinct_viability AS (SELECT * FROM bernie_zasman.ss_precinct_viability spv)
