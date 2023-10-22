#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# =============================================================================
# get_item_from_json.py
# -------------------------------
# part of set of scripts to handle JSON-file as meta information for a scanned 
# document.
# this script loads json data from a given files (*.json)
# searches for the given key and returns its value as string to STDOUT.
# -------------------------------
# INPUT PARAMETER
#     $1 ... absolute path to JSON-file
#     $2 ... simple string (no regex) as key name
# OUTPUT (STDOUT)
#	value of JSON key as strings
# ERROR-CODE:
#     0 ... okay ....... STDOUT has valid values
#     1 ... not okay ... STDOUT is empty
# -------------------------------
# AUTHOR  marcus.trommen@gmx.net
# CREATED 2022-02-19
# =============================================================================

import json
import sys

# --- get CLI parameters ---
json_file = sys.argv[1]
search_json_key = sys.argv[2]

try:
	with open(str(json_file), 'r') as fileObject:
		json_data = json.load(fileObject)

	value = json_data[search_json_key]

except:
	value = ""

if value == "":
	print("")
	exit(1)

print(value)
exit(0)
