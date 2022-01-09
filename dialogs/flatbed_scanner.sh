#!/usr/bin/env bash
# =============================================================================
# Handle scanning of pages for one document with an single sided flatbed
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
# LAST CHANGE ... 2022-01-03
# =============================================================================

source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh


USER_EXIT="false"
while [ "${USER_EXIT}" = "false" ]; do
	# --------------------------
	# DIALOG go on with scanning?
	# --------------------------
	TITEL="Scannen"
	QUESTION="Jetzt mit Flachbett-Scanner eine Seite scannen?"
	ITEM_LIST='"1" "ja" "2" "fertig mit scannen"'
	COMMAND="dialog --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --menu '${QUESTION}' 0 0 5"
	ANSWER=$(eval $COMMAND "$ITEM_LIST" 3>&1 1>&2 2>&3)
	
	case "${ANSWER}" in
		1)
			# --------------------------
			# scan
			# find next available page number
			# --------------------------
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
				"Scannen\n\nScanner scannt Dokument ..."

			${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/scantools/singlescan.sh \
				"${SCAN_DEVICE}" \
				"${SCAN_WORKING_DIRECTORY}" \
				"${SCAN_DOCUMENT_ID}" \
				"${PAGE_NUMBER}"
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
			USER_EXIT="true"
			;;
	esac			
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

exit 0
