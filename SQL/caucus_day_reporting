--Used in tandem with Google Sheets data to build caucus day reporting based on what on-site volunteers were entering into Google Form

SELECT DISTINCT
CASE WHEN cvv.email IS NOT NULL OR cvv.phone IS NOT NULL THEN 1 ELSE 0 END volunteer_validation,
CASE WHEN duplicate_validation IS NULL THEN 1 WHEN duplicate_validation = 1 THEN 1 ELSE 0 END duplicate_validation,
CASE WHEN spv.code IS NOT NULL THEN 1 ELSE 0 END precinct_validation,
spv.van_precinct_id,
cdm.*
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
