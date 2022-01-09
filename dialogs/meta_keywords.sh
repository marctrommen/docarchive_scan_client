#!/usr/bin/env bash

# =============================================================================
# 
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-01-03
# =============================================================================

source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh


# -------------------------------
# read keywords from file
# -------------------------------
ITEM_LIST=""
declare -a ITEM_LIST_ARRAY
let "counter=0"
while read -r item; do
	# ignore empty lines
	if [ -z "${item}" ]; then continue; fi
	
	# ignore lines starting with '#' for coments
	if [ $( expr index "${item}" "#" ) -eq 1 ]; then continue; fi
	
	ITEM_LIST=$(printf "%s '%s' '%s' 'off'" "$ITEM_LIST" "${counter}" "${item}")
	ITEM_LIST_ARRAY[counter]="${item}"
	let "counter++"
done <"${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/keywords.txt"

if [[ $counter -eq 0 ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Es konnten keine Vorgaben für \"Schlagworte des Dokuments\" aus der Datei gelesen werden!"
	exit 1
fi



# -------------------------------
# dialog keywords
# -------------------------------
TITEL="Schlagworte des Dokuments"
QUESTION="Bitte auswählen:"

let "USER_EXIT=0"
while [[ ${USER_EXIT} -eq 0 ]]; do
	COMMAND="dialog --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --visit-items --scrollbar --buildlist '${QUESTION}' 0 0 8"
	ANSWER=$(eval $COMMAND $ITEM_LIST 3>&1 1>&2 2>&3)
	# Get the exit status
	DIALOG_EXIT_STATUS=$?

	if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
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
			"\"Schlagworte des Dokuments\" ist ein Muss-Feld und darf nicht leer sein!"
	else
		SCAN_DOCUMENT_KEYWORDS=""
		
		for item in ${ANSWER}; do
			if [[ -z "${SCAN_DOCUMENT_KEYWORDS}" ]]; then
				SCAN_DOCUMENT_KEYWORDS=$(printf "\"%s\"" "${ITEM_LIST_ARRAY[$item]}")
			else
				SCAN_DOCUMENT_KEYWORDS=$(printf "%s , \"%s\"" "${SCAN_DOCUMENT_KEYWORDS}" "${ITEM_LIST_ARRAY[$item]}")
			fi
		done
		
		let "USER_EXIT=1"
		write_config
	fi
done

exit 0
