import os
import csv
import boto3
import re
# from civis.io import csv_to_civis
from civis.io import dataframe_to_civis
from civis import APIClient
from datetime import datetime
from datetime import timedelta 
import numpy as np
import pandas as pd
import logging

# TODO: Clean up the function to make it more usable, rename file and save variables in one spot

# Setting up Loggin
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

# Setting up the connection to s3
s3 = boto3.resource(
    's3',
    aws_access_key_id=os.environ['THRUTALK_AWS_ACCESS_KEY_ID'],
    aws_secret_access_key= os.environ['THRUTALK_AWS_SECRET_ACCESS_KEY']
)

# Setting up a variable for the s3 Bucket
tt_bucket = s3.Bucket(name='nga-thrutalk')

# Putting all the bucket object summaries into a list to iterate through
tt_bucket_objects =  [i.key for i in tt_bucket.objects.all()]

def upload_raw_report(state, report_type, list_of_bucket_objects, is_today):
    logger.info('Committee to be Uploaded')
    logger.info(state)
    state_report_type = state + "-" + report_type
    # Defining the file pattern for nc script results
    file_pattern = "\d{8}-nextgen-" + state_report_type + "-\d{2}-\d{1,2}-2020-\d{9}\.csv"
    ea_file_pattern = "\d{8}-nga-" + state_report_type + "-\d{2}-\d{1,2}-2020-\d{9}\.csv"
    results_pattern = "\d{8}-nextgen-" + state_report_type + "-\d{2}-\d{1,2}-2020--\d{2}-\d{1,2}-2020-\d{9}\.csv"
    doub_upl_file = "\d{8}-nextgen-" + state_report_type + "-\d{2}-\d{1,2}-2020" 
    doub_upl_ea = "\d{8}-nga-" + state_report_type + "-\d{2}-\d{1,2}-2020" 
    doub_upl_res = "\d{8}-nextgen-" + state_report_type + "-\d{2}-\d{1,2}-2020--\d{2}-\d{1,2}-2020"  
    # Defining the date extraction pattern so that we only pull the latest files
    date_extraction_pattern = "\d{8}"

    # Precompiling Regexp pattern match to make more efficient
    re_file_prog = re.compile(file_pattern + "|" + ea_file_pattern + "|" + results_pattern)
    re_date_extract_prog = re.compile(date_extraction_pattern)
    re_no_dupes = re.compile(doub_upl_file + '|' + doub_upl_ea + '|' + doub_upl_res)
    yesterday = datetime.strftime(datetime.now() - timedelta(days = 1), "%m%d%Y")
    keys = []
    dates = []
    for i in tt_bucket_objects:
        key_match = re_file_prog.match(i)
        if key_match and is_today == False:
            keys.append(key_match.group())
            raw_date = re_date_extract_prog.match(i).group()
            dates.append(raw_date)
        elif key_match and is_today == True:
            raw_date = re_date_extract_prog.match(i).group()       
            if raw_date == yesterday:
               keys.append(key_match.group())
               dates.append(raw_date)
        elif key_match and is_today != True and is_today != False:
            raw_date = re_date_extract_prog.match(i).group()
            if raw_date == is_today:
                keys.append(key_match.group())
                dates.append(is_today)        
    logger.info("Keys to be uploaded")
    logger.info(keys)
    civis_client = APIClient()
    for key in keys: 
        s3.Bucket('nga-thrutalk').download_file("{}".format(key),"{}".format(key))    
        state = state.replace('-', '_')
        table_name = f"nextgen_thrutalk.staging_{report_type}_import" 

        if report_type == 'callers':
            caller_columns =['Date', 'Login', 'Name','Email', 'Phone', 'Minutes in Call', 
                      'Minutes in Wrap Up', 'Minutes in Ready', 'Minutes in Not Ready', 
                      'No Contact', 'Remove number from list', 'Talked to Correct Person'] 
            df_callers = pd.read_csv(key, usecols=caller_columns)[caller_columns]
            aws_key_match = re_no_dupes.match(key).group()
            logger.info(aws_key_match)
            aws_file_key = [aws_key_match for i in range(df_callers.shape[0])]            
            df_callers['aws_file_key'] = pd.Series(aws_file_key)
            fut = dataframe_to_civis(
                df_callers,
                database="TMC",
                table=table_name,
                client=civis_client,
                existing_table_rows='append',
                polling_interval=3,
                headers=True,
            )
            fut.result()
            logger.info(key + " uploaded to " + table_name)    
        
        elif report_type == 'results':
            result_columns =['Voter ID', 'Voter ID Type', 'Voter First Name', 'Voter Last Name',
                      'Voter Phone', 'Date Called', "Time Called (EST)", 'Caller Login',
                      'Result']
            df_results = pd.read_csv(key, usecols=result_columns)[result_columns]
            aws_key_match = re_no_dupes.match(key).group()
            logger.info(aws_key_match)
            aws_file_key = [aws_key_match for i in range(df_results.shape[0])]            
            df_results['aws_file_key'] = pd.Series(aws_file_key)
            fut = dataframe_to_civis(
                df_results,
                database="TMC",
                table=table_name,
                client=civis_client,
                existing_table_rows='append',
                polling_interval=3,
                headers=True,
            )
            fut.result()
            logger.info(key + " uploaded to " + table_name)

        elif report_type == 'script_results':
            try:
                script_result_columns = [
                    'Voter ID', 'Voter ID Type', 'Voter First Name', 'Voter Last Name',
                    'Voter Phone', 'Date Called', "Time Called (EST)", 'starting_question'
                ]
                df_script_results = pd.read_csv(key, usecols=script_result_columns)[script_result_columns]
            except:
                pass

            try:
                script_result_columns = [
                    'Voter ID', 'Voter ID Type', 'Voter First Name', 'Voter Last Name',
                    'Voter Phone', 'Date Called', "Time Called (EST)", 'Introduction'
                ]
                df_script_results = pd.read_csv(key, usecols=script_result_columns)[script_result_columns] 
            except:
                pass            

            try:
                script_result_columns = [
                    'Voter ID', 'Voter ID Type', 'Voter First Name', 'Voter Last Name',
                    'Voter Phone', 'Date Called', "Time Called (EST)", '1. starting_question'
                ]
                df_script_results = pd.read_csv(key, usecols=script_result_columns)[script_result_columns] 
            except:
                pass   

            try:
                script_result_columns = [
                    'Voter ID', 'Voter ID Type', 'Voter First Name', 'Voter Last Name',
                    'Voter Phone', 'Date Called', "Time Called (EST)", 'Introduction1'
                ]
                df_script_results = pd.read_csv(key, usecols=script_result_columns)[script_result_columns] 
            except:
                pass

            aws_key_match = re_no_dupes.match(key).group()
            logger.info(aws_key_match)
            aws_file_key = [aws_key_match for i in range(df_script_results.shape[0])]            
            df_script_results['aws_file_key'] = pd.Series(aws_file_key)
            fut = dataframe_to_civis(
                df_script_results,
                database="TMC",
                table=table_name,
                client=civis_client,
                existing_table_rows='append',
                polling_interval=3,
                headers=True,
            )
            fut.result()
            logger.info(key + " uploaded to " + table_name)    

# Pulling all the reports
states_list = [
    'michigan',
    'michigan-ea',
    'america-distributed-a', 
    'america-distributed-b',
    'america-distributed',
    'virginia',
    'virginia-ea', 
    'nevada',
    'nevada-ea', 
    'iowa',
    'ia-everyaction',
    'iowa-ea',
    'new-hampshire',
    'new-hampshire-ea',
    'nh-myvoters',
    'arizona',
    'arizona-ea',
    'maine',
    'maine-ea'
    'pennsylvania',
    'pennsylvania-ea',
    'wisconsin',
    'wisconsin-ea',
    'florida',
    'florida-ea',
    'north-carolina',
    'north-carolina-ea'
]

# For Daily Pull
for state in states_list:
    upload_raw_report(state, 'callers', tt_bucket_objects, True)
    upload_raw_report(state, 'results', tt_bucket_objects, True)
    upload_raw_report(state, 'script_results', tt_bucket_objects, True)

# For Full Refresh
# for state in states_list:
#     upload_raw_report(state, 'callers', tt_bucket_objects, False)
#     upload_raw_report(state, 'results', tt_bucket_objects, False)



