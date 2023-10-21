#!/usr/bin/env bash

# =============================================================================
# Handle scanning of pages for one document with an automated double sided
# scan device.
#
# User interaction is text dialog based on Linux terminal.
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
# LAST CHANGE ... 2022-02-20
# =============================================================================

source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh

let "UI_LOOP_BREAK=0"
while [[ ${UI_LOOP_BREAK} -eq 0 ]]; do
	# --------------------------
	# DIALOG go on with scanning?
	# --------------------------
	TITEL="Scannen"
	QUESTION="Jetzt mit Automatischen Dokumenteneinzug mehrere Seiten scannen?"
	ITEM_LIST='"1" "ja                " "2" "fertig mit scannen"'
	COMMAND="dialog --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --menu '${QUESTION}' 0 0 5"
	ANSWER=$(eval $COMMAND "$ITEM_LIST" 3>&1 1>&2 2>&3)

	case "${ANSWER}" in
		1)
			# scan
			# find next available page number
			let "PAGE_NUMBER=1"
			let "LOOP_BREAK=0"
			while [[ ${PAGE_NUMBER} -le 999 && ${LOOP_BREAK} -eq 0 ]]; do
				TARGET_TIFF_FILENAME=$(printf "${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_%03d.tiff" "$PAGE_NUMBER")
			
				if [[ ! -e "${TARGET_TIFF_FILENAME}" ]] ; then
					# next available TIFF file name found, ready to scan
					let "LOOP_BREAK=1"
				else
					let "PAGE_NUMBER++"
				fi
			done
		
			# --------------------------
			# DIALOG busy with scanning
			# --------------------------
			show_info \
				"${BACKTITEL}" \
				"Scannen\n\nScanner scannt Dokumente ..."

			${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/scantools/multiscan.sh \
				"${SCAN_DEVICE}" \
				"${SCAN_WORKING_DIRECTORY}" \
				"${SCAN_DOCUMENT_ID}" \
				"${PAGE_NUMBER}" \
				"${SCAN_DOCUMENT_ORIENTATION}"
			EXIT_STATUS=$?
			
			if [[ ${EXIT_STATUS} -gt 0 ]]; then
				show_message \
					"${BACKTITEL}" \
					"FEHLER" \
					"Während des Scannens trat ein Fehler auf!"
				exit 1
			fi
			;;
		2)
			# finished
			let "UI_LOOP_BREAK=1"
			;;
	esac			
done

# --------------------------------------------
# post-scan improvements
# --------------------------------------------
TITEL="Scan-Dateien aufbereiten"


# --------------------------------------------
# cut borders
# --------------------------------------------
show_info \
	"${BACKTITEL}" \
	"${TITEL}\n\nRänder zuschneiden ..."
SHAVE_VALUE="55x2"
if [[ "${SCAN_DOCUMENT_ORIENTATION}" = "special_sparda_kontoauszug" ]] ; then
	SHAVE_VALUE="660x0"
fi
for tiff_file in ${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_???.tiff; do
	${MOGRIFY} -shave ${SHAVE_VALUE} "${tiff_file}"
done


# --------------------------------------------
# improve contrast on scans
# --------------------------------------------
show_info \
	"${BACKTITEL}" \
	"${TITEL}\n\nKontrast verbessern ..."
for tiff_file in ${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_???.tiff; do
	${MOGRIFY} -sigmoidal-contrast 3,0% "${tiff_file}"
done


# --------------------------------------------
# delete blank pages
# http://philipp.knechtges.com/?p=190
# --------------------------------------------
show_info \
	"${BACKTITEL}" \
	"${TITEL}\n\nleere Seiten löschen ..."
for tiff_file in ${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_???.tiff; do
	histogram=$(${CONVERT} "${tiff_file}" -threshold 50% -format %c histogram:info:-)
	
	white=$(printf "%s\n" "${histogram}" | grep "#FFFFFF" | sed -n 's/^ *\(.*\):.*$/\1/p')
	if [[ -z "${white}" ]]; then white="0";fi
	
	black=$(printf "%s\n" "${histogram}" | grep "#000000" | sed -n 's/^ *\(.*\):.*$/\1/p')
	if [[ -z "${black}" ]]; then black="0";fi
	
	blank=$(printf "%s\n" "scale=4; ${black}/${white} < 0.005" | ${BC})

	if [[ ${blank} -eq 1 ]]; then
		rm --force "${tiff_file}"
	fi
done



# --------------------------------------------
# renumber files
# --------------------------------------------
show_info \
	"${BACKTITEL}" \
	"${TITEL}\n\nSeiten ggf. neu nummerieren ..."
MESSAGE="Seiten sortieren"
let "PAGE_NUMBER=1"
for tiff_file in ${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_???.tiff; do
	new_tiff_file=$(printf "${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_%03d.tiff" ${PAGE_NUMBER})
	if [[ ! "${tiff_file}" = "${new_tiff_file}" ]]; then
		mv --force ${tiff_file} ${new_tiff_file}
	fi
	
	let "PAGE_NUMBER++"
done



exit 0
