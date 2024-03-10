#!/usr/bin/env bash

# =============================================================================
# 
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-01-03
# =============================================================================

source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh


# --------------------------
# Dialog: pattern to search in existing document_titles
# --------------------------
TITEL="Textmuster in Metadaten suchen"
QUESTION="Suchmuster? (leer lassen für keine Suche)\n"
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --inputbox '${QUESTION}' 9 75"
SEARCH_PATTERN=$(eval $COMMAND 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?

if [[ "${DIALOG_EXIT_STATUS}" -gt 0 ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Dialog-Abbruch durch Benutzer!"
	exit 1
fi


# --------------------------
# filter JSON data with search pattern by calling python script
# --------------------------
ANSWER=""
if [[ -n "${SEARCH_PATTERN}" ]]; then
	ITEM_LIST=$(${PYTHON} ${SCAN_SCRIPT_BASE_DIRECTORY}/tools/parse_json_title.py "${SCAN_ARCHIVE_BASE_DIRECTORY}" "${SEARCH_PATTERN}")
	EXIT_STATUS=$?
	if [[ $EXIT_STATUS -eq 0 ]] ; then
		# --------------------------
		# Dialog: select from search results
		# --------------------------
		QUESTION="Suchergebnisse für Dokumenttitel:"
		COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --no-items --scrollbar --menu '${QUESTION}' 0 0 8"
		ANSWER=$(eval $COMMAND $ITEM_LIST 3>&1 1>&2 2>&3)
		# Get the exit status
		DIALOG_EXIT_STATUS=$?
		
		if [[ "${DIALOG_EXIT_STATUS}" -gt 0 ]]; then
			# handle user exit just as an empty value
			ANSWER=""
		fi
	fi
fi


# --------------------------
# Dialog: document_title
# --------------------------
let "ANSWER_DONE=0"
while [[ ${ANSWER_DONE} -eq 0 ]]; do
	QUESTION="Dokumenttitel / Betreff?"
	INPUT=$(printf '"%s"' '$ANSWER')
	COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --inputbox '${QUESTION}' 8 75"
	ANSWER=$(eval $COMMAND $INPUT 3>&1 1>&2 2>&3)
	# Get the exit status
	DIALOG_EXIT_STATUS=$?

	if [[ "${DIALOG_EXIT_STATUS}" -gt 0 ]]; then
		show_message \
			"${BACKTITEL}" \
			"FEHLER" \
			"Dialog-Abbruch durch Benutzer!"
		exit 1
	fi

	if [[ -z "${ANSWER}" ]]; then
		show_message \
			"${BACKTITEL}" \
			"FEHLER" \
			"Dokumenttitel ist ein Muss-Feld und darf nicht leer sein!"
	else
		SCAN_DOCUMENT_TITLE="${ANSWER}"
		let "ANSWER_DONE=1"
		write_config
	fi
done

exit 0
