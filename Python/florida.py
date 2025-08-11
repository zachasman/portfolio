import requests
import json
import pandas as pd
import regex as re
from civis.io import csv_to_civis
from civis import APIClient


url = "https://enr.electionsfl.org/BAY/2754/Reports/"

# url2 = "https://s3.amazonaws.com/results.voterfocus.com/enr/exports/reports/BAY/2754/CandidateResultsbyPrecinctandParty_2020-11-14T00:31:30_505f3e9e-2dc4-4432-ad86-931f3f39dfd6.csv"

# r = requests.get(url2)

# print(r.text)

# https://enr.electionsfl.org/CAL/2123/Summary/

pattern = "The requested material is not published"

re_bad_link = re.compile(pattern)


for i in range(2139,3000):
    url = "https://enr.electionsfl.org/CAL/{}/Summary/".format(str(i))
    r = requests.get(url)
    bad_link = re_bad_link.search(r.text)
    
    if bad_link:
        print('bad link' + url)
    else:
        print(url)
# print(r.text)
