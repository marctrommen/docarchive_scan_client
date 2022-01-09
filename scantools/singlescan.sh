#!/usr/bin/env bash

# =============================================================================
# Usage:
#
# singlescan.sh SCANNER_DEVICE TARGET_DIRECTORY DOCUMENT_ID PAGE_NUMBER
#
#    SCANNER_DEVICE ..... scanner device name used by 'scanimage' tool
#    TARGET_DIRECTORY ... directory to put scanned document
#    DOCUMENT_ID ........ document base name, formatted as 'YYYYddmm_xx'
#                         example: '20211224_01'
#    PAGE_NUMBER ........ current page number, range 1 ... 999
#
# Scan one single sided document with a flatbed scanner (SCANNER_DEVICE)
# and save it as TIFF file into TARGET_DIRECTORY
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
PAGE_NUMBER="${4}"

if [ ! -d "${TARGET_DIRECTORY}" ]; then
	printf "ERROR: target directory '%s' does not exist!\n" "${TARGET_DIRECTORY}" > /dev/stderr
	sleep 5
	exit 1
fi

TARGET_TIFF_FILENAME=$(printf "%s_%03d.tiff" "${DOCUMENT_ID}" "${PAGE_NUMBER}")
if [[ -f "${TARGET_DIRECTORY}/${TARGET_TIFF_FILENAME}" ]]; then
	printf "ERROR: target file '%s' for scan does already exist!\n" "${TARGET_TIFF_FILENAME}" > /dev/stderr
	sleep 5
	exit 1
fi



# --------------------------------------------
# scann single page from flatbed
# --------------------------------------------
scanimage \
   --device-name=${SCANNER_DEVICE} \
   --format=tiff \
   --source 'Flatbed' \
   --mode 'Color' \
   --resolution 300 \
   --brightness 1000 \
   --contrast 1000 \
   --compression None \
> "${TARGET_DIRECTORY}/${TARGET_TIFF_FILENAME}"



if [[ "$?" -gt "0" ]]; then
	printf "ERROR: during scan!\n" > /dev/stderr
	sleep 5
	exit 1
fi


if [[ ! -e "${TARGET_DIRECTORY}/${TARGET_TIFF_FILENAME}" ]]; then
	printf "ERROR: no scan saved as document('%s')!\n" "${TARGET_TIFF_FILENAME}" > /dev/stderr
	sleep 5
	exit 1
fi

exit 0
