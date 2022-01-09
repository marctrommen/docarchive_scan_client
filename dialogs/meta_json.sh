#!/usr/bin/env bash

# =============================================================================
# 
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-01-03
# =============================================================================

source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh


# --------------------------------------------
# check for Scan Archive Directory
# --------------------------------------------
if [[ ! -d "${SCAN_ARCHIVE_BASE_DIRECTORY}" ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Das Verzeichnis 'SCAN_ARCHIVE_BASE_DIRECTORY' ist nicht verfügbar:\n${SCAN_ARCHIVE_BASE_DIRECTORY}"
	exit 1
fi


SCAN_WORKING_DIRECTORY="${SCAN_ARCHIVE_BASE_DIRECTORY}/${SCAN_DOCUMENT_ID}"


# --------------------------------------------
# check for working directory and document_id
# --------------------------------------------
if [[ -d "${SCAN_WORKING_DIRECTORY}" ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Es besteht bereits ein Verzeichnis mit gleichem Namen 'DOCUMENT_ID'!\n\n${SCAN_WORKING_DIRECTORY}"
	exit 1
fi


# --------------------------------------------
# check for all necessary variables
# --------------------------------------------
if [[ -z "${SCAN_DOCUMENT_ID}" || -z "${SCAN_DOCUMENT_TITLE}" || -z "${SCAN_DOCUMENT_ORIENTATION}" || -z "${SCAN_DOCUMENT_FILE}" || -z "${SCAN_DOCUMENT_KEYWORDS}" || -z "${SCAN_DOCUMENT_STORAGE_LOCATION}" ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Mindestens eine der erforderlichen Dokumentinformationen fehlt!\n\nDocument-ID, Titel, Ausrichtung,\nDateiname, Schlagwörter, Dokument-Ablage"
	exit 1
fi


# --------------------------------------------
# create new document directory
# --------------------------------------------
mkdir "${SCAN_WORKING_DIRECTORY}" 2> /dev/null
if [[ ! -d "${SCAN_WORKING_DIRECTORY}" ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Es konnte kein neues Verzeichnis für den Scan angelegt werden.\nEventuell fehled Schreibrechte?"
	exit 1
fi

# --------------------------------------------
# do JSON
# --------------------------------------------
JSON_FILE="${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}.json"
JSON_CONTENT=$(cat <<-EOF
{
	"id"          : "${SCAN_DOCUMENT_ID}",
	"title"       : "${SCAN_DOCUMENT_TITLE}",
	"orientation" : "${SCAN_DOCUMENT_ORIENTATION}",
	"file"        : "${SCAN_DOCUMENT_FILE}",
	"keywords"    : [ ${SCAN_DOCUMENT_KEYWORDS} ],
	"storage_location" : "${SCAN_DOCUMENT_STORAGE_LOCATION}"
}
EOF
)
printf "%s\n" "${JSON_CONTENT}" > ${JSON_FILE}

SCAN_DOCUMENT_FILE="${SCAN_ARCHIVE_BASE_DIRECTORY}/${SCAN_DOCUMENT_ID}.pdf"
write_config

exit 0
