#!/usr/bin/env bash

# =============================================================================
# Usage:
#
# 02_multiscan.sh SCANNER_DEVICE TARGET_DIRECTORY DOCUMENT_ID START_PAGE_NUMBER
#
#    SCANNER_DEVICE ...... scanner device name used by 'scanimage' tool
#    TARGET_DIRECTORY .... directory to put scanned document
#    DOCUMENT_ID ......... document base name, formatted as 'YYYYddmm_xx'
#                          example: '20211224_01'
#    START_PAGE_NUMBER ... start page number, range 1 ... 999
#
# Scan double sided documents with auto-feed scanner (SCANNER_DEVICE)
# and save them as TIFF files into TARGET_DIRECTORY
# 
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-01-03
# =============================================================================


# --------------------------------------------
# validate command line parameter
# --------------------------------------------
if [[ $# -ne 4 ]]; then
	printf "ERROR: wrong number of command line parameters '%d'\n" "$#" > /dev/stderr
	sleep 5
	exit 1
fi

SCANNER_DEVICE="${1}"
TARGET_DIRECTORY="${2}"
DOCUMENT_ID="${3}"
START_PAGE_NUMBER="${4}"

if [ ! -d "${TARGET_DIRECTORY}" ]; then
	printf "ERROR: target directory '%s' does not exist!\n" "${TARGET_DIRECTORY}" > /dev/stderr
	sleep 5
	exit 1
fi


# --------------------------------------------
# scann all pages in tray of auto-feed scanner
# --------------------------------------------
scanimage \
   --device-name=${SCANNER_DEVICE} \
   --batch="${TARGET_DIRECTORY}/${DOCUMENT_ID}_%03d.tiff" \
   --batch-start=${START_PAGE_NUMBER} \
   --format=tiff \
   --source 'ADF Duplex' \
   --mode 'Color' \
   --resolution 300 \
   --brightness 0 \
   --contrast 0 \
   -t 0 \
   --page-width 205 \
   --page-height 296

if [[ "$?" -gt "0" ]]; then
	printf "ERROR: during scan!\n" > /dev/stderr
	sleep 5
	exit 1
fi

# redirect 'stdout' and 'stderr' to '/dev/null' as it is of no interest
ls ${TARGET_DIRECTORY}/${DOCUMENT_ID}_???.tiff 1>/dev/null 2>/dev/null
ERROR_CODE=$?

if [[ $ERROR_CODE -gt 0 ]]; then
	printf "ERROR: no scan saved as document!\n" > /dev/stderr
	sleep 5
	exit 1
fi

exit 0
