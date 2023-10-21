#!/usr/bin/env bash

# =============================================================================
# 
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-02-01
# =============================================================================

source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh

# --------------------------------------------
# check if preconditions are fulfilled
# --------------------------------------------
if [[ -z "${SCAN_WORKING_DIRECTORY}" || -z "${SCAN_DOCUMENT_ID}" ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Es wurden noch keine Dokumentdaten erfasst!\nBitte unbedingt nachholen!"
	exit 1
fi


if [[ ! -d "${SCAN_WORKING_DIRECTORY}" ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Es wurde noch kein valiedes Verzeichnis für 'DOCUMENT_ID' ausgewählt \noder es besteht noch nicht!"
	exit 1
fi


if [[ ! -e "${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}.json" ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Es existiert noch keine JSON-Datei mit den Dokument-Informationen!"
	exit 1
fi


# --------------------------------------------
# Dialog: select pdf file to copy via file selection, called as function
# --------------------------------------------
SOURCE_PDF_FILE=$(filtered_file_selection ${BACKTITEL} ${HOME} "*.[pP][dD][fF]")
DIALOG_EXIT_STATUS=$?

if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Dialog-Abbruch durch Benutzer!"
	exit 1
fi

if [[ -z ${SOURCE_PDF_FILE} ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Es wurde keine PDF-Datei zum Kopieren ausgewählt!"
	exit 1
fi

# --------------------------------------------
# copy pdf file into document archive
# --------------------------------------------
cp --force "${SOURCE_PDF_FILE}" "${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}.pdf"
ERROR_CODE=$?

if [[ $ERROR_CODE -gt 0 ]] ; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Beim Kopieren der PDF-Datei in das Zielverzeichnis\ntrat ein Problem auf!"
	exit 1
fi

# everything okay
exit 0
