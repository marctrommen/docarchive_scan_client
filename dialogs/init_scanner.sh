#!/usr/bin/env bash

# =============================================================================
# Search for scanner devices available at local system. Lets the user select
# the scan device for further use and collects further characteristics about
# the scan device from the user.
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


# --------------------------
# DIALOG scan-device search
# --------------------------
show_info \
	"${BACKTITEL}" \
	"Scanner initialisieren\n\nSuche nach angeschlossene Scanner ..."

# save IFS and set it to NewLine
IFS_SAVE="${IFS}"
IFS=$'\n'

declare -a SCAN_DEVICE_INTERFACE_ARRAY
declare -a SCAN_DEVICE_DESCRIPTION_ARRAY
let "counter=0"
ITEM_LIST=""

# --------------------------
# search for scan devices
# --------------------------
for SCAN_DEVICE_ENTRY in $(scanimage -L); do
	SCAN_DEVICE_INTERFACE=$(echo "${SCAN_DEVICE_ENTRY}" | awk -F\` '{print $2}' | awk -F\' '{print $1}')
	
	# no scanner ?
	if [[ -n "${SCAN_DEVICE_INTERFACE}" ]]; then
		SCAN_DEVICE_INTERFACE_ARRAY[counter]="${SCAN_DEVICE_INTERFACE}"
	
		SCAN_DEVICE_DESCRIPTION=$(echo "${SCAN_DEVICE_ENTRY}" | sed "s/.*is\ a\ //")
		SCAN_DEVICE_DESCRIPTION_ARRAY[counter]="${SCAN_DEVICE_DESCRIPTION}"
	
		ITEM_LIST=$(printf "%s '%d' '%s'" "${ITEM_LIST}" "${counter}" "${SCAN_DEVICE_DESCRIPTION}")
	
		let "counter++"
	fi
done 

# restore IFS
IFS="${IFS_SAVE}"

# -- ERROR ? --
if [[ ${counter} -eq 0 ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Es wurde kein Scanner gefunden!"
	exit 1
fi


# --------------------------
# DIALOG scan-device
# --------------------------
TITEL="Scanner initialisieren"
QUESTION="Welchen Scanner möchtest du nutzen?"
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --menu '${QUESTION}' 0 0 5"
ANSWER=$(eval $COMMAND "$ITEM_LIST" 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if  [[ $DIALOG_EXIT_STATUS -gt 0 ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Dialog-Abbruch durch Benutzer!"
	exit 1
fi

SCAN_DEVICE="${SCAN_DEVICE_INTERFACE_ARRAY[$ANSWER]}"


# --------------------------
# DIALOG scan-device-type
# --------------------------
TITEL="Scanner initialisieren"
QUESTION="Welche Art ist\n${SCAN_DEVICE_DESCRIPTION_ARRAY[$ANSWER]}?"
ITEM_LIST='"1" "Scanner mit automatischen Einzug (ADF)" "2" "Flachbett-Scanner"'
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --menu '${QUESTION}' 0 0 5"
ANSWER=$(eval $COMMAND "$ITEM_LIST" 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if  [[ $DIALOG_EXIT_STATUS -gt 0 ]]; then
	show_message \
		"${BACKTITEL}" \
		"FEHLER" \
		"Dialog-Abbruch durch Benutzer!"
	exit 1
fi

case "${ANSWER}" in
	1)
	SCAN_DEVICE_TYPE="adf"
	;;
	2)
	SCAN_DEVICE_TYPE="flatbed"
	;;
esac			

write_config
exit 0
