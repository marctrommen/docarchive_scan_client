#!/usr/bin/env bash

# =============================================================================
#
# Get list of directories directly below the SCAN_ARCHIVE_BASE_DIRECTORY
# each of these directories should contain one archive document and all the
# related files to it (e.g. JSON, TIFF, PNG, PDF files)
#
# 1) optimize all TIFF files in respect to quality and file size and convert 
#    into PNG files of same name
# 2) rotate PNG files if previously chosen by user
# 3) put all PNG files into a PDF file and add necessary meta information from
#    JSON file
#
# This script is a is part of set of scripts to offer an easy and comfortable
# way to scan documents with Linux.
# Manually collect some meta information for each scanned document, optimize
# each page of the scanned document (due to quality and minimal file size)
# and add it finally into a file structure of a document archive to manage
# all documents.
# 
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-01-03
# =============================================================================

source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh


# --------------------------------------------
# get list of directories directly below the SCAN_ARCHIVE_BASE_DIRECTORY
# each of these directories should contain one archive document and all the
# related files to it (e.g. JSON, TIFF, PNG, PDF files)
# --------------------------------------------
DIRECTORY_LIST=$(ls -d ${SCAN_ARCHIVE_BASE_DIRECTORY}/*/)

for directory_item in ${DIRECTORY_LIST}; do

	dir_has_files "$directory_item" "tiff"; has_tiff=$?
	dir_has_files "$directory_item" "json"; has_json=$?
	dir_has_files "$directory_item" "png"; has_png=$?
	dir_has_files "$directory_item" "pdf"; has_pdf=$?

	# JSON and TIFF files are available, but no PNG and PDF files
	if [[ $has_json -eq 0 && $has_tiff -eq 0 && $has_png -gt 0 && $has_pdf -gt 0 ]] ; then
		printf "%s\n" "$directory_item" >/dev/stderr
		printf "   - optimize TIFF files while transforming them to PNG files\n" >/dev/stderr
		# optimize TIFF files while transforming them to PNG files
		export SCAN_WORKING_DIRECTORY="$directory_item"
		# SCAN_DOCUMENT_ID: see id-parameter of JSON in Working-Directory
		${PYTHON} ${SCAN_SCRIPT_BASE_DIRECTORY}/scantools/optimize_scans.py >/dev/stderr
	fi
	
	dir_has_files "$directory_item" "tiff"; has_tiff=$?
	dir_has_files "$directory_item" "json"; has_json=$?
	dir_has_files "$directory_item" "png"; has_png=$?
	dir_has_files "$directory_item" "pdf"; has_pdf=$?

	# JSON and PNG files are available, but no PDF files
	if [[ $has_json -eq 0 && $has_png -eq 0 && $has_pdf -gt 0 ]] ; then
		printf "   - create PDF file\n" >/dev/stderr

		# check if PNG files need 90 degrees clockwise rotation
		cat $directory_item/*json | grep 'landscape' 1> /dev/null 2> /dev/null
		if [[ $? -eq 0 ]] ; then
			for png_file in ${directory_item}/*png ; do
				${MOGRIFY} -rotate 90 $png_file 2>/dev/null
			done
		fi
		
		# create a PDF file out of the PNG files
		export SCAN_WORKING_DIRECTORY="$directory_item"
		export SCAN_DOCUMENT_ID=$(basename $directory_item)
		${PYTHON} ${SCAN_SCRIPT_BASE_DIRECTORY}/scantools/create_pdf.py 1> /dev/null 2> /dev/null
	fi
	
	dir_has_files "$directory_item" "tiff"; has_tiff=$?
	dir_has_files "$directory_item" "json"; has_json=$?
	dir_has_files "$directory_item" "png"; has_png=$?
	dir_has_files "$directory_item" "pdf"; has_pdf=$?

	# JSON, PNG, PDF, TIFF files are available
	if [[ $has_json -eq 0 && $has_tiff -eq 0 && $has_png -eq 0 && $has_pdf -eq 0 ]] ; then
		printf "   - delete TIFF files\n" >/dev/stderr

		# delete all TIFF files
		for tiff_file in $ ${directory_item}/*tiff ; do
			rm --force $tiff_file
		done
	fi
done
sleep 20
exit 0