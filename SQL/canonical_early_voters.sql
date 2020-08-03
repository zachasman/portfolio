--Building a canocial dataset for identifying potential early voters

SELECT DISTINCT
'dnc_'||gotc.person_id Voterid,
gotc.voters_firstname Voters_firstname,
gotc.voters_lastname Voters_lastname,
apcd.phone Votertelephones_fullphone,
gotc.voters_residence_address Residence_address,
per.voting_city Residence_addresses_city,
gotc.voters_residence_address_zip Residence_addresses_zip,
gotc.voters_age Voters_age,
gotc.voters_gender Voters_gender,
gotc.voters_party Parties_description,
gotc.early_vote_location customer_field_1,
gotc.ev_location_hours custom_field_2,
evl.address || ' ' || evl.city || ' ' || evl.state_code || ' ' || evl.zip custom_field_4,
et.tier,
CASE WHEN (si.support_int = 1 AND evp.saturday = 1 OR evp.sunday = 1 OR evp.monday = 1 OR evp.tuesday = 1) THEN 1
WHEN (si.support_int = 2 AND evp.saturday = 1 OR evp.sunday = 1 OR evp.monday = 1 OR evp.tuesday = 1) THEN 2
WHEN (si.support_int = 1 AND evp.saturday = 0 OR evp.sunday = 0 OR evp.monday = 0 OR evp.tuesday = 0) THEN 3
WHEN (si.support_int = 2 AND evp.saturday = 0 OR evp.sunday = 0 OR evp.monday = 0 OR evp.tuesday = 0) THEN 4 ELSE 5 END support_ev,
gotc.support_score * gotc.turnout_score sbs_rank
FROM
gotv_universes.nv_gotc_master_universe gotc
LEFT JOIN phoenix_analytics.person per
ON gotc.person_id = per.person_id
LEFT JOIN bernie_data_commons.all_phones_comprehensive_details apcd 
ON gotc.person_id = apcd.person_id AND apcd.phone_rank_for_person = 1
LEFT JOIN bernie_zasman.support_ids si
ON gotc.person_id = si.person_id::VARCHAR
LEFT JOIN bernie_zasman.ev_person evp
ON gotc.person_id = evp.person_id
LEFT JOIN bernie_zasman.ev_tiers et
ON gotc.voters_county = et.county
JOIN  phoenix_voting_locations.early_vote_locations evl
ON gotc.early_vote_location = evl.early_vote_location
WHERE apcd.phone IS NOT NULL
ORDER BY tier ASC, support_ev ASC, sbs_rank DESC
