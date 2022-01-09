#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# =============================================================================
# parse_json_keywords.py
# -------------------------------
# part of set of scripts to create the content of a JSON-file to hold 
# meta information for a scanned documents
# this script traverses recursively down from a given base path, finds all 
# json data files (*.json) and searches for the value of "keywords" information.
# As of "keywords" is a list, each item get added to the result list, but all
# duplicates get filtered out.
# Finally sort the list of keywords alphabetically and print it to STDOUT.
# -------------------------------
# INPUT PARAMETER
#     $1 ... absolute path to start with the recursive search as base directory
# OUTPUT (STDOUT)
#	Result list
# ERROR-CODE:
#     0 ... okay ....... STDOUT has valid values
#     1 ... not okay ... STDOUT is empty
# -------------------------------
# AUTHOR  marcus.trommen@gmx.net
# CREATED 2021-12-28
# =============================================================================

from pathlib import Path
import json
import sys

# --- initialize ---
output={}

# --- get CLI parameters ---
base_dir = sys.argv[1]

# --- search recursively for all *.json files ---
for json_file in Path(base_dir).rglob('*.json'):
	with open(str(json_file), 'r') as fileObject:
		json_data = json.load(fileObject)

	# search 'keywords' field
	keywords = json_data['keywords']
	for keyword in keywords:
		keyword = keyword.lower()
		keyword = keyword.replace("_", " ")
		keyword = keyword.replace("-", " ")
		# collect the keyword in a dictionary to eleminate duplicates
		output[keyword]=""
		

# retrieve results vom dictionary keys
keyword_list = list(output.keys())

keyword_list_max_items = len(keyword_list)

# is no results return ErrorCode=1
if keyword_list_max_items == 0:
	exit(1)
	
keyword_list.sort()

for item in keyword_list:
    print(item)
exit(0)
