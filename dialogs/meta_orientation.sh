#!/usr/bin/env bash

# =============================================================================
# 
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-02-19
# =============================================================================

source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh


# --------------------------
# DIALOG document orientation of scan
# --------------------------
TITEL="Details zum Scan"
QUESTION="Wie sind die Seiten des Dokuments ausgerichtet?"
ITEM_LIST='"1" "Hochformat" "2" "Querformat" "3" "Spezial: Sparda-Kontoauszug"'
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --menu '${QUESTION}' 0 0 5"
ANSWER=$(eval $COMMAND "$ITEM_LIST" 3>&1 1>&2 2>&3)
# Get the exit status
DIALOG_EXIT_STATUS=$?

if [[ "${DIALOG_EXIT_STATUS}" -gt 0 ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Dialog-Abbruch durch Benutzer!"
	exit 1
fi

case "${ANSWER}" in
	1)
	SCAN_DOCUMENT_ORIENTATION="portrait"
	;;
	2)
	SCAN_DOCUMENT_ORIENTATION="landscape"
	;;
	3)
	SCAN_DOCUMENT_ORIENTATION="special_sparda_kontoauszug"
	;;
esac			

write_config
exit 0
