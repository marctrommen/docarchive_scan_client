#!/usr/bin/env bash

# =============================================================================
# Let the user choose a directory with an existing PDF document.
# Update meta data of existing PDF document from JSON file, therfore in the
# background do ...
# ... check if PDF file exists and delete it
# ... add all PNG files as single pages to the PDF file
# ... set meta data of PDF file with content from JSON file
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-01-03
# =============================================================================

source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh



# --------------------------
# Dialog: directory selection via function call
# --------------------------
UPDATE_PDF_DIRPATH=$(directory_selection "${BACKTITEL}" "${SCAN_ARCHIVE_BASE_DIRECTORY}")
DIALOG_EXIT_STATUS=$?

if [[ $DIALOG_EXIT_STATUS -gt 0 ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Dialog-Abbruch durch Benutzer!"
	exit 1
fi


dir_has_files "$UPDATE_PDF_DIRPATH" "tiff"; has_tiff=$?
dir_has_files "$UPDATE_PDF_DIRPATH" "json"; has_json=$?
dir_has_files "$UPDATE_PDF_DIRPATH" "png"; has_png=$?
dir_has_files "$UPDATE_PDF_DIRPATH" "pdf"; has_pdf=$?


# ----------------------------
# check if preconditions are fulfilled
# ----------------------------

# TIFF files are available, other file types are of no interest yet
if [[ $has_tiff -eq 0 ]] ; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"TIFF-Dateien müssen erst optimiert und zu PNG-Dateien transformiert werden!"
	exit 1
fi

SCAN_WORKING_DIRECTORY=${UPDATE_PDF_DIRPATH}
SCAN_DOCUMENT_ID=$(basename ${UPDATE_PDF_DIRPATH})

# PDF, JSON and PNG files are available
if [[ $has_pdf -eq 0 && $has_json -eq 0 &&  $has_png -eq 0 ]] ; then
	# delete the PDF file
	rm --force ${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_???.pdf

	# PDF files are still available?
	dir_has_files "$UPDATE_PDF_DIRPATH" "pdf"; has_pdf=$?
	if [[ $has_pdf -eq 0 ]]; then
		show_message \
			"${BACKTITEL}" \
			"FEHLER" \
			"PDF-Datei konnte nicht gelöscht werden werden!"
		exit 1
	fi
fi

# JSON and PNG files are available
if [[ $has_json -eq 0 &&  $has_png -eq 0 ]] ; then
	export SCAN_WORKING_DIRECTORY
	export SCAN_DOCUMENT_ID
	${PYTHON} ${SCAN_SCRIPT_BASE_DIRECTORY}/scantools/create_pdf.py 1> /dev/null 2> /dev/null

	dir_has_files "$UPDATE_PDF_DIRPATH" "pdf"; has_pdf=$?
	if [[ $has_pdf -gt 0 ]]; then
		show_message \
			"${BACKTITEL}" \
			"FEHLER" \
			"PDF-Datei konnte nicht erstellt werden werden!"
		exit 1
	fi

	# everything is okay
	exit 0
fi


# no new PDF file got created
show_message \
	"${BACKTITEL}" \
	"FEHLER" \
	"Etwas funktionierte nicht beim Neu-Erstellen der PDF-Datei!"
exit 1
