#Bash script while at Burrow to extract our CRM data and push it into our BigQuery database 
#!/bin/bash

getPage() {
curl --fail -X GET 'https://api.kustomerapp.com/v1/conversations?page='"$1"'&pageSize=1000&sort=desc' \
  -H 'Authorization: Bearer XXXX' \
  -H 'cache-control: no-cache'
}

getAllPages() {
  local page i=1
  while page=$(getPage "$i"); do
    printf '%s\n' "$page"
    if [[ $(jq '.links.next' <<<"$page") = null ]]; then
      break
    fi
    (( ++i ))
  done
}

getAllPages > conversations_log.json

cat conversations_log.json | jq -c '.data[]' > conversations_log_clean.json

bq load --source_format NEWLINE_DELIMITED_JSON --autodetect --replace --max_bad_records=1000000 burrow-test:kustomer.conversations conversations_log_clean.json
