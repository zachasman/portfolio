--Used to create a list of best potential contacts for campaign volunteers to phonebank against

SELECT DISTINCT
'dnc_'||xw.person_id person_id,
CASE WHEN ccj.support_int IS NOT NULL THEN ccj.support_int ELSE 0 END support_id,
CASE WHEN dialer_rank_order IS NOT NULL THEN dialer_rank_order ELSE 0 END dialer_rank_order,
CASE WHEN dial_attempts IS NOT NULL THEN dial_attempts ELSE 0 END dial_attempts
FROM
  phoenix_analytics_nv.person ps
JOIN
  bernie_data_commons.master_xwalk_dnc xw
ON
  ps.person_id = xw.person_id
LEFT JOIN
  bernie_data_commons.all_phones_comprehensive_details apcd
ON
  apcd.person_id = xw.person_id
  AND apcd.phone_rank_for_person = 1
LEFT JOIN
  bernie_zasman.legacybase lb --Adding in a group of legacy SQs and ACs
ON xw.myv_van_id = lb.myv_van_id
LEFT JOIN
  (SELECT * FROM bernie_data_commons.contactcontacts_joined WHERE voter_state = 'NV') ccj
ON ps.person_id = ccj.person_id
LEFT JOIN (
  SELECT
person_id,
COUNT(*) dial_attempts
FROM
bernie_data_commons.contactcontacts_joined
WHERE
voter_state = 'NV'
AND contacttype = 'getthru_dialer'
AND resultcode = 'Not Available'
GROUP BY 1
HAVING(COUNT(*)) > 7) dials_threshold --Removing everyone with 7+ unsuccessful attempts
ON ps.person_id = dials_threshold.person_id
LEFT JOIN (
SELECT
    person_id,
    current_date - MAX(contactdate)
  FROM
    bernie_data_commons.contactcontacts_joined cc
  WHERE
    voter_state = 'NV'
    AND support_int IN (1,2)
    AND unique_id_flag = TRUE
    AND contacttype = 'getthru_dialer'
    GROUP BY 1
    HAVING(current_date - MAX(contactdate)) < 31) support_recent
 ON ps.person_id = support_recent.person_id --Removing all 1s+2s who have been ID'd in the past month
LEFT JOIN (
	SELECT
    *
  FROM
    haystaq_outgoing.nv_donut_flags_haystaq_draft_10292019) donut
ON ps.person_id = donut.person_id
LEFT JOIN (
  SELECT
    lalvoterid
  FROM
    contacts.contactscontact
  WHERE
    resultcode = 'Do Not Contact'
  GROUP BY
    1 ) do_not_contact
  ON do_not_contact.lalvoterid = xw.lalvoterid
  WHERE 
  ps.state_code = 'NV'
  AND apcd.phone IS NOT NULL -- With phones
  AND do_not_contact.lalvoterid IS NULL -- do not contact
  AND support_recent.person_id IS NULL -- Remove 1s/2s contacted within the past month
  AND dials_threshold.person_id IS NULL --Remove all with more than seven attempt
  AND (donut_segment = '1_core_bernie' --All Core Bernie
  OR (donut_segment = '2_soft_support' --Soft Support, Turnout Percentile >= 25
  AND turnout_percentile_10292019 >= 25)
  OR (donut_segment = '3_shifter'
  AND turnout_percentile_10292019 >= 25)) --Shifters, Turnout Percentile >= 25
  OR (nv_caucus_turnout_adjusted_score >= 15
  AND sanders_support_raw_score >= 30) --Turnout >= 10 + Support >= 37 
  ORDER BY 2,4 ASC, 3 DESC)
