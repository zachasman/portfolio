import requests
import json
import pandas as pd
from civis.io import dataframe_to_civis
from civis import APIClient

list_of_counties = [ 
    "ACCOMACK COUNTY", "ALBEMARLE COUNTY",    "ALEXANDRIA CITY",    "ALLEGHANY COUNTY",    "AMELIA COUNTY",    "AMHERST COUNTY",
    "APPOMATTOX COUNTY",    "ARLINGTON COUNTY",    "AUGUSTA COUNTY",    "BATH COUNTY",    "BEDFORD COUNTY",
    "BLAND COUNTY",    "BOTETOURT COUNTY",    "BRISTOL CITY",    "BRUNSWICK COUNTY",    "BUCHANAN COUNTY",
    "BUCKINGHAM COUNTY",    "BUENA VISTA CITY",    "CAMPBELL COUNTY",    "CAROLINE COUNTY",    "CARROLL COUNTY",
    "CHARLES CITY COUNTY",    "CHARLOTTE COUNTY",    "CHARLOTTESVILLE CITY",    "CHESAPEAKE CITY",    "CHESTERFIELD COUNTY",
    "CLARKE COUNTY",    "COLONIAL HEIGHTS CITY",    "COVINGTON CITY",    "CRAIG COUNTY",    "CULPEPER COUNTY",
    "CUMBERLAND COUNTY",    "DANVILLE CITY",    "DICKENSON COUNTY",    "DINWIDDIE COUNTY",    "EMPORIA CITY",
    "ESSEX COUNTY",    "FAIRFAX CITY",    "FAIRFAX COUNTY",    "FALLS CHURCH CITY",    "FAUQUIER COUNTY",
    "FLOYD COUNTY",    "FLUVANNA COUNTY",    "FRANKLIN CITY",    "FRANKLIN COUNTY",    "FREDERICK COUNTY",
    "FREDERICKSBURG CITY",    "GALAX CITY",    "GILES COUNTY",    "GLOUCESTER COUNTY",
    "GOOCHLAND COUNTY",    "GRAYSON COUNTY",    "GREENE COUNTY",    "GREENSVILLE COUNTY",
    "HALIFAX COUNTY",    "HAMPTON CITY",    "HANOVER COUNTY",    "HARRISONBURG CITY",
    "HENRICO COUNTY",    "HENRY COUNTY",    "HIGHLAND COUNTY",    "HOPEWELL CITY",
    "ISLE OF WIGHT COUNTY",    "JAMES CITY COUNTY",    "KING & QUEEN COUNTY",    "KING GEORGE COUNTY",
    "KING WILLIAM COUNTY",    "LANCASTER COUNTY",    "LEE COUNTY",    "LEXINGTON CITY",
    "LOUDOUN COUNTY",    "LOUISA COUNTY",    "LUNENBURG COUNTY",    "LYNCHBURG CITY",
    "MADISON COUNTY",    "MANASSAS CITY",    "MANASSAS PARK CITY",    "MARTINSVILLE CITY",
    "MATHEWS COUNTY",    "MECKLENBURG COUNTY",    "MIDDLESEX COUNTY",    "MONTGOMERY COUNTY",
    "NELSON COUNTY",    "NEW KENT COUNTY",    "NEWPORT NEWS CITY",    "NORFOLK CITY",
    "NORTHAMPTON COUNTY",    "NORTHUMBERLAND COUNTY",    "NORTON CITY",    "NOTTOWAY COUNTY",
    "ORANGE COUNTY",    "PAGE COUNTY",    "PATRICK COUNTY",    "PETERSBURG CITY",
    "PITTSYLVANIA COUNTY",    "POQUOSON CITY",    "PORTSMOUTH CITY",    "POWHATAN COUNTY",
    "PRINCE EDWARD COUNTY",    "PRINCE GEORGE COUNTY",    "PRINCE WILLIAM COUNTY",    "PULASKI COUNTY",
    "RADFORD CITY",    "RAPPAHANNOCK COUNTY",    "RICHMOND CITY",    "RICHMOND COUNTY",
    "ROANOKE CITY",    "ROANOKE COUNTY",    "ROCKBRIDGE COUNTY",    "ROCKINGHAM COUNTY",
    "RUSSELL COUNTY",    "SALEM CITY",    "SCOTT COUNTY",    "SHENANDOAH COUNTY",
    "SMYTH COUNTY",    "SOUTHAMPTON COUNTY",    "SPOTSYLVANIA COUNTY",    "STAFFORD COUNTY",
    "STAUNTON CITY",    "SUFFOLK CITY",    "SURRY COUNTY",    "SUSSEX COUNTY",
    "TAZEWELL COUNTY",    "VIRGINIA BEACH CITY",    "WARREN COUNTY",    "WASHINGTON COUNTY",
    "WAYNESBORO CITY",    "WESTMORELAND COUNTY",    "WILLIAMSBURG CITY",    "WINCHESTER CITY",    "WISE COUNTY",    "WYTHE COUNTY",    "YORK COUNTY",
    ]

list_of_counties = [i.replace(' ', '_') for i in list_of_counties]


def pull_and_format_va_county_data(county):
    civis_client = APIClient()
    url = "https://results.elections.virginia.gov/vaelections/2020%20November%20General/Json/Locality/{COUNTY}/President_and_Vice_President.json".format(COUNTY=county)
    r = requests.get(url)
    resp = r.json()
    arr = []
    for i in resp['Precincts']:
        for j in i['Candidates']:
            row = []
            row.append(resp['ElectionName'])
            row.append(resp['ElectionDate'])
            row.append(resp['CreateDate'])
            row.append(resp['Locality']['LocalityName'])
            row.append(resp['Locality']['LocalityCode'])
            row.append(resp['District'])
            row.append(resp['RaceName'])
            row.append(resp['NumberOfSeats'])
            row.append(i['PrecinctName'])
            row.append(j['BallotName'])
            row.append(j['BallotOrder'])
            row.append(j['Votes'])
            row.append(j['Percentage'])
            row.append(j['PoliticalParty'])
            arr.append(row)
    
    df = pd.DataFrame(arr)
    fut = dataframe_to_civis(
        df,
        database="NextGen America",
        table='reporting.va_precinct_results',
        client=civis_client,
        existing_table_rows='append',
        polling_interval=3,
        headers=True,
    )
    fut.result()
    print("Uploaded " + county + " to civis")
    print(df.head())
    # print(arr)

for i in list_of_counties:
    pull_and_format_va_county_data(i)
