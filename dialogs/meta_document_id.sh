#!/usr/bin/env bash

# =============================================================================
# 
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-01-09
# =============================================================================

source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh


# --------------------------
# Settings
# --------------------------
CURRENT_YEAR="$(date +%Y)"
YEAR_LIST="$(seq --separator=' ' ${CURRENT_YEAR} -1 1970)"
CURRENT_MONTH="$(date +%m)"
MONTH_LIST="'01' 'Januar   ' '02' 'Februar  ' '03' 'März     ' '04' 'April    ' '05' 'Mai      ' '06' 'Juni     ' '07' 'Juli     ' '08' 'August   ' '09' 'September' '10' 'Oktober  ' '11' 'November ' '12' 'Dezember '"
CURRENT_DAY="$(date +%d)"


# --------------------------
# Dialog document-id year
# --------------------------
TITEL="Dokument-ID anlegen"
QUESTION="Jahr?"
# --default-item ${CURRENT_YEAR} 
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --no-items --scrollbar --menu '${QUESTION}' 0 0 8"
YEAR=$(eval $COMMAND ${YEAR_LIST} 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Dialog-Abbruch durch Benutzer!"
	exit 1
fi



# --------------------------
# Dialog document-id month
# --------------------------
TITEL="Dokument-ID anlegen"
QUESTION="Monat?"
DEFAULT=""
if [[ "${YEAR}" = "${CURRENT_YEAR}" ]] ; then
	DEFAULT="--default-item '${CURRENT_MONTH}'"
fi
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --scrollbar ${DEFAULT} --menu '${QUESTION}' 0 0 8"
MONTH=$(eval $COMMAND ${MONTH_LIST} 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Dialog-Abbruch durch Benutzer! (${DIALOG_EXIT_STATUS})"
	exit 1
fi

# --------------------------
# Dialog document-id day
# get max days of a given month
# --------------------------
MAX_DAYS=$(date --date="$YEAR/$MONTH/1 + 1 month - 1 day" +%d)
DAY_LIST="$(seq --separator=' ' 1 ${MAX_DAYS})"
TITEL="Dokument-ID anlegen"
QUESTION="Tag?"
DEFAULT=""
if [[ "${YEAR}" = "${CURRENT_YEAR}"  &&  "${MONTH}" = "${CURRENT_MONTH}" ]] ; then
	CURRENT_DAY="$(printf "%d" $(( 10#${CURRENT_DAY} )))" # without leading zeros
	DEFAULT="--default-item '${CURRENT_DAY}'"
fi
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --no-items --scrollbar ${DEFAULT} --menu '${QUESTION}' 0 0 8"
DAY=$(eval $COMMAND ${DAY_LIST} 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Dialog-Abbruch durch Benutzer!"
	exit 1
fi
DAY=$(printf "%02d" "$DAY")



# --------------------------
# check for next available DOCUMENT_ID directory
# --------------------------
current_date=$(printf "%s%s%s" "$YEAR" "$MONTH" "$DAY")

if [ ! -d "${SCAN_ARCHIVE_BASE_DIRECTORY}" ]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Das Verzeichnis 'SCAN_ARCHIVE_BASE_DIRECTORY' ist nicht verfügbar:\n${SCAN_ARCHIVE_BASE_DIRECTORY}"
	exit 1
fi

for counter in $(seq 1 99); do
	document_id=$(printf "%s_%02d" "${current_date}" "${counter}")
	if [[ ! -d "${SCAN_ARCHIVE_BASE_DIRECTORY}/${document_id}" ]]; then
		SCAN_DOCUMENT_ID="${document_id}"
		SCAN_DOCUMENT_FILE="${document_id}.pdf"
		write_config
		exit 0
	fi
done

show_message \
	"${BACKTITEL}" \
	"FEHLER" \
	"Es konnte kein passendes Archiv-Verzeichnis zur Ablage der Scans ermittelt werden!\nEine möglich Lösung wäre: ein anderes Dokumentdatum wählen."
exit 1
