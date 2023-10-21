#!/usr/bin/env bash

# =============================================================================
# Usage:
#
# singlescan.sh SCANNER_DEVICE TARGET_DIRECTORY DOCUMENT_ID PAGE_NUMBER
#
#    SCANNER_DEVICE ......... scanner device name used by 'scanimage' tool
#    TARGET_DIRECTORY ....... directory to put scanned document
#    DOCUMENT_ID ............ document base name, formatted as 'YYYYddmm_xx'
#                             example: '20211224_01'
#    PAGE_NUMBER ............ current page number, range 1 ... 999
#    DOCUMENT_ORIENTATION ... orientation of the document; one of:
#                             'portrait',
#                             'landscape', 
#                             'special_sparda_kontoauszug'
#
# Scan one single sided document with a flatbed scanner (SCANNER_DEVICE)
# and save it as TIFF file into TARGET_DIRECTORY
# 
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-02-20
# =============================================================================


# --------------------------------------------
# validate command line parameter
# --------------------------------------------
if [[ $# -ne 5 ]]; then
	printf "ERROR: wrong number of command line parameters '%d'\n" "$#" > /dev/stderr
	sleep 5
	exit 1
fi

SCANNER_DEVICE="${1}"
TARGET_DIRECTORY="${2}"
DOCUMENT_ID="${3}"
PAGE_NUMBER="${4}"
DOCUMENT_ORIENTATION="${5}"

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
if [[ "${DOCUMENT_ORIENTATION}" = "special_sparda_kontoauszug" ]]; then
	SCAN_AREA_WIDTH=106
	SCAN_AREA_HEIGHT=211
	SCAN_AREA_TOP_LEFT_X=0
	SCAN_AREA_TOP_LEFT_Y=0

	scanimage \
	   --device-name=${SCANNER_DEVICE} \
	   --format=tiff \
	   --source 'Flatbed' \
	   --mode 'Color' \
	   --resolution 300 \
	   --brightness 1000 \
	   --contrast 1000 \
	   --compression None \
	   -l ${SCAN_AREA_TOP_LEFT_X} \
	   -t ${SCAN_AREA_TOP_LEFT_Y} \
	   -x ${SCAN_AREA_WIDTH} \
	   -y ${SCAN_AREA_HEIGHT} \
	> "${TARGET_DIRECTORY}/${TARGET_TIFF_FILENAME}"
	ERROR_CODE=$?
else
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
	ERROR_CODE=$?
fi




if [[ "${ERROR_CODE}" -gt "0" ]]; then
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
