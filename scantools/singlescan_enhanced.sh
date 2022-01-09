#!/usr/bin/env bash

# =============================================================================
# Usage:
#
# singlescan_enhanced.sh \
#    SCANNER_DEVICE TARGET_DIRECTORY DOCUMENT_ID PAGE_NUMBER \
#    SCAN_AREA_WIDTH SCAN_AREA_HEIGHT SCAN_AREA_TOP_LEFT_X SCAN_AREA_TOP_LEFT_Y
#
#    SCANNER_DEVICE ......... scanner device name used by 'scanimage' tool
#    TARGET_DIRECTORY ....... directory to put scanned document
#    DOCUMENT_ID ............ document base name, formatted as 'YYYYddmm_xx'
#                             example: '20211224_01'
#    PAGE_NUMBER ............ current page number, range 1 ... 999
#                             
#    SCAN_AREA_WIDTH ........ Width of scan-area
#                             Integer values 0 ... 215 mm, default: 215
#    SCAN_AREA_HEIGHT ....... Height of scan-area
#                             Integer values 0 ... 297 mm, default: 297
#    SCAN_AREA_TOP_LEFT_X ... Top-left x position of scan area
#                             Integer values 0 ... 215 mm, default: 0
#    SCAN_AREA_TOP_LEFT_Y ... Top-left y position of scan area
#                             Integer values 0 ... 297 mm, default: 0
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
if [[ $# -ne 8 ]]; then
	printf "ERROR: wrong number of command line parameters '%d'\n" "$#" > /dev/stderr
	sleep 5
	exit 1
fi

SCANNER_DEVICE="${1}"
TARGET_DIRECTORY="${2}"
DOCUMENT_ID="${3}"
PAGE_NUMBER="${4}"
SCAN_AREA_WIDTH="${5}"
SCAN_AREA_HEIGHT="${6}"
SCAN_AREA_TOP_LEFT_X="${7}"
SCAN_AREA_TOP_LEFT_Y="${8}"

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
   -l ${SCAN_AREA_TOP_LEFT_X} \
   -t ${SCAN_AREA_TOP_LEFT_Y} \
   -x ${SCAN_AREA_WIDTH} \
   -y ${SCAN_AREA_HEIGHT} \
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
