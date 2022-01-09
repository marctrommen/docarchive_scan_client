#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# =============================================================================
# parse_json.py
# -------------------------------
# part of set of scripts to create the content of a JSON-file to hold 
# meta information for a scanned documents
# this script searches recursively down from a given base path, finds all 
# json data files (*.json) and searches for the value of "title" information.
# If the content of "title" information holds the filter criteria as substring,
# add it to the list of search results.
# Finally put all search result items as tilda delimited string to STDOUT.
# -------------------------------
# INPUT PARAMETER
#     $1 ... absolute path to start with the recursive search as base directory
#     $2 ... simple string (no regex) as filter criteria to mach with meta data
# OUTPUT (STDOUT)
#	Result list as Tilde (~) separated strings
# ERROR-CODE:
#     0 ... okay ....... STDOUT has valid values
#     1 ... not okay ... STDOUT is empty
# -------------------------------
# AUTHOR  marcus.trommen@gmx.net
# CREATED 2021-11-27
# =============================================================================

from pathlib import Path
import json
import sys

# --- initialize ---
MAX_ITEMS = 1000
output={}

# --- get CLI parameters ---
search_pattern = sys.argv[2].upper()
base_dir = sys.argv[1]

# --- search recursively for all *.json files ---
for json_file in Path(base_dir).rglob('*.json'):
	with open(str(json_file), 'r') as fileObject:
		json_data = json.load(fileObject)

	# search 'title' field for criteria
	title = json_data['title']
	if search_pattern in title.upper():
		# collect the search result in a dictionary to eleminate duplicates
		output[title]=""

# retrieve results vom dictionary keys
title_list = list(output.keys())

title_list_max_items = len(title_list)

# is no results for search criteria found retur ErrorCode=1
if title_list_max_items == 0:
	exit(1)

if title_list_max_items > MAX_ITEMS:
	title_list_max_items = MAX_ITEMS

# otherwise: reduce list to MAX_ITEMS
title_list=title_list[0:(title_list_max_items)]

for item in title_list:
    print("\"" + item + "\" ")
exit(0)
