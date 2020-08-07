#Another Bash script to extract data from our CRM API

set -x

curl 'https://api.typeform.com/forms/Te8Fy9/responses?page_size=1000' -H 'Authorization: Bearer XXX' -H 'Postman-Token: 123456789' -H 'cache-control: no-cache' > csat_raw.json

page_parameter=`cat csat_raw.json | jq -c '.items | last | .token' | tr -d '"'`

items_parameter=`cat csat_raw.json | jq -c '.total_items'`

cat csat_raw.json | jq -c '.items[]' > csat_clean.json

bq load --source_format NEWLINE_DELIMITED_JSON --autodetect burrow-test:typeform.responses_csat csat_clean.json

while [[ ${#items_parameter} -gt 1 ]]
do

    curl 'https://api.typeform.com/forms/Te8Fy9/responses?page_size=1000&after='${page_parameter} -H 'Authorization: Bearer XXX' -H 'Postman-Token: 123456789' -H 'cache-control: no-cache' > csat_raw.json
        
    page_parameter=`cat csat_raw.json | jq -c '.items | last | .token' | tr -d '"'`

	items_parameter=`cat csat_raw.json | jq -c '.total_items'`

    cat csat_raw.json | jq -c '.items[]' > csat_clean.json

if [[  ${#items_parameter} -gt 1 ]]; then

bq load --source_format NEWLINE_DELIMITED_JSON --autodetect --replace --max_bad_records=1000000 burrow-test:typeform.responses_csat csat_clean.json

else cat csat_clean.json > csat_exit.json

fi
        
done
