--Used as canocial underlying dataset for RShiny map based reporting

SELECT
  p.van_precinct_id,
  p.van_precinct_name,
  p.county,
  COUNT(DISTINCT
    CASE
      WHEN ev_votes.sos_id IS NOT NULL THEN ev_votes.sos_id END) AS early_voters, SUM(s_all.expected_vote) AS all_expected_vote, SUM(s_all.expected_sanders_vote) AS all_expected_sanders_vote, SUM(s_all.expected_buttigieg_vote) AS all_expected_buttigieg_vote, SUM(s_all.expected_biden_vote) AS all_expected_biden_vote, SUM(s_all.expected_warren_vote) AS all_expected_warren_vote, SUM(s_all.expected_yang_vote) AS all_expected_yang_vote, SUM(s_all.expected_other_candidate_vote) AS all_expected_other_candidate_vote, COUNT(DISTINCT CASE
      WHEN ev_votes.sos_id IS NOT NULL
    AND id_1 = 1 THEN ev_votes.sos_id END) AS early_voter_id1,
  COUNT(DISTINCT
    CASE
      WHEN ev_votes.sos_id IS NOT NULL AND id_2 = 1 THEN ev_votes.sos_id END) AS early_voter_id2, COUNT(DISTINCT CASE
      WHEN ev_votes.sos_id IS NOT NULL
    AND id_3 = 1 THEN ev_votes.sos_id END) AS early_voter_id3,
  COUNT(DISTINCT
    CASE
      WHEN ev_votes.sos_id IS NOT NULL AND id_4 = 1 THEN ev_votes.sos_id END) AS early_voter_id4, COUNT(DISTINCT CASE
      WHEN ev_votes.sos_id IS NOT NULL
    AND id_5 = 1 THEN ev_votes.sos_id END) AS early_voter_id5,
  COUNT(DISTINCT
    CASE
      WHEN myv.survey_response_id = 1431747 OR myv.survey_response_id = 1431747 THEN ev_votes.sos_id END) AS early_voter_CTC_yes, COUNT(DISTINCT CASE
      WHEN id_1 = 1 THEN p.person_id END) AS total_id1s,
  COUNT(DISTINCT
    CASE
      WHEN id_2 = 1 THEN p.person_id END) AS total_id2s, COUNT(DISTINCT CASE
      WHEN id_3 = 1 THEN p.person_id END) AS total_id3s,
  COUNT(DISTINCT
    CASE
      WHEN id_4 = 1 THEN p.person_id END) AS total_id4s, COUNT(DISTINCT CASE
      WHEN id_5 = 1 THEN p.person_id END) AS total_id5s,
  COUNT(DISTINCT
    CASE
      WHEN myv.survey_response_id = 1431747 OR myv.survey_response_id = 1431747 THEN p.person_id END) AS total_CTC_yes, COUNT(DISTINCT CASE
      WHEN nct.flag_latinx = 1
    AND ev_votes.sos_id IS NOT NULL THEN ev_votes.sos_id END) AS ev_latinx,
  COUNT(DISTINCT
    CASE
      WHEN nct.flag_muslim = 1 AND ev_votes.sos_id IS NOT NULL THEN ev_votes.sos_id END) AS ev_muslim, COUNT(DISTINCT CASE
      WHEN nct.flag_aapi = 1
    AND ev_votes.sos_id IS NOT NULL THEN ev_votes.sos_id END) AS ev_pct_aapi,
  COUNT(DISTINCT
    CASE
      WHEN nct.flag_union = 1 AND ev_votes.sos_id IS NOT NULL THEN ev_votes.sos_id END) AS ev_pct_union, COUNT(DISTINCT CASE
      WHEN nct.flag_afam_under35 = 1
    AND ev_votes.sos_id IS NOT NULL THEN ev_votes.sos_id END) AS ev_pct_afam_under35,
  COUNT(DISTINCT
    CASE
      WHEN nct.flag_latinx = 1 THEN p.person_id END) AS all_latinx, COUNT(DISTINCT CASE
      WHEN nct.flag_muslim = 1 THEN p.person_id END) AS all_muslim,
  COUNT(DISTINCT
    CASE
      WHEN nct.flag_aapi = 1 THEN p.person_id END) AS all_aapi, COUNT(DISTINCT CASE
      WHEN nct.flag_union = 1 THEN p.person_id END) AS all__union,
  COUNT(DISTINCT
    CASE
      WHEN nct.flag_afam_under35 = 1 THEN p.person_id END) AS all__afam_under35, COUNT(DISTINCT CASE
      WHEN raf.age_5way = '1 - 18-34'
    AND ev_votes.first_name IS NOT NULL THEN ev_votes.sos_id END) AS age_18_34,
  COUNT(DISTINCT
    CASE
      WHEN raf.age_5way = '2 - 35-49' AND ev_votes.first_name IS NOT NULL THEN ev_votes.sos_id END) AS age_35_49, COUNT(DISTINCT CASE
      WHEN raf.age_5way = '3 - 50-64'
    AND ev_votes.first_name IS NOT NULL THEN ev_votes.sos_id END) AS age_50_64,
  COUNT(DISTINCT
    CASE
      WHEN raf.age_5way = '4 - 65+' AND ev_votes.first_name IS NOT NULL THEN ev_votes.sos_id END) AS age_over_65, COUNT(DISTINCT CASE
      WHEN raf.age_5way = '1 - 18-34' THEN p.person_id END) AS age_18_34,
  COUNT(DISTINCT
    CASE
      WHEN raf.age_5way = '2 - 35-49' THEN p.person_id END) AS age_35_49, COUNT(DISTINCT CASE
      WHEN raf.age_5way = '3 - 50-64'THEN p.person_id END) AS age_50_64,
  COUNT(DISTINCT
    CASE
      WHEN raf.age_5way = '4 - 65+' THEN p.person_id END) AS age_over_65,
  ROUND(AVG(s_ev.turnout_score::FLOAT),2) AS all_turnout_score_avg,
  ROUND(AVG(s_ev.sanders_support_score_scaled::FLOAT),2) AS all_sanders_support_score_avg,
  ROUND(AVG(s_ev.biden_support_score_scaled::FLOAT),2) AS all_biden_support_score_avg,
  ROUND(AVG(s_ev.warren_support_score_scaled::FLOAT),2) AS all_warren_support_score_avg,
  ROUND(AVG(s_ev.buttigieg_support_score_scaled::FLOAT),2) AS all_buttigieg_support_score_avg,
  ROUND(AVG(s_all.turnout_score::FLOAT),2) AS all_turnout_score_avg,
  ROUND(AVG(s_all.sanders_support_score_scaled::FLOAT),2) AS all_sanders_support_score_avg,
  ROUND(AVG(s_all.biden_support_score_scaled::FLOAT),2) AS all_biden_support_score_avg,
  ROUND(AVG(s_all.warren_support_score_scaled::FLOAT),2) AS all_warren_support_score_avg,
  ROUND(AVG(s_all.buttigieg_support_score_scaled::FLOAT),2) AS all_buttigieg_support_score_avg
FROM (
  SELECT
    person.person_id,
    sos_id,
    us_cong_district_latest,
    van_precinct_id,
    van_precinct_name,
    county_name,
    voting_address_id,
    state_code
  FROM
    phoenix_analytics.person
  WHERE
    is_deceased = FALSE
    AND reg_voter_flag = TRUE
    AND state_code = 'NV') p
INNER JOIN (
  SELECT
    rainbow_analytics_frame.person_id
  FROM
    bernie_data_commons.rainbow_analytics_frame
  WHERE
    party_3way != '3 - Republican' ) raf
ON
  raf.person_id=p.person_id
LEFT JOIN
  phoenix_demsnvsp_caucus.early_vote_turnout ev_votes
ON
  ev_votes.sos_id=p.sos_id
LEFT JOIN
  bernie_cslayton.nv_staging_locations sl
ON
  p.van_precinct_id=sl.van_precinct_id
LEFT JOIN
  haystaq.nv_scores_scaled_to_polling_20200213_2 s_all
ON
  p.person_id=s_all.person_id
LEFT JOIN (
  SELECT
    DISTINCT p1.person_id,
    s.*
  FROM (
    SELECT
      person.person_id,
      person.sos_id
    FROM
      phoenix_analytics.person
    WHERE
      is_deceased = FALSE
      AND reg_voter_flag = TRUE
      AND state_code = 'NV') p1
  INNER JOIN (
    SELECT
      sos_id
    FROM
      phoenix_demsnvsp_caucus.early_vote_turnout) ev_votes
  ON
    p1.sos_id=ev_votes.sos_id
  LEFT JOIN
    haystaq.nv_scores_scaled_to_polling_20200213_2 s
  ON
    p1.person_id=s.person_id ) s_ev
ON
  s_ev.person_id=p.person_id
GROUP BY 1, 2, 3
