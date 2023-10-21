#!/usr/bin/env bash

# =============================================================================
# IMPORTANT:
#
# This script is a module to deliver some helper functions. Therefore it 
# should get sourced by any parent script!
#
# -----------------------------------------------------------------------------
# Available functions are:
#
# FUNCTIION dir_has_files()
# checks, if in the given 'directory' has files with file-extension 'filetype' 
#
# FUNCTION filtered_file_selection()
# Offers a configuratble, interactive dialog for file-selection.
# Navigation from a 'starting directory' is available.
# In any given directory only visible files matching to a given 'file_pattern' 
# are listed. The selected file will get returned as fully qualified filename.
#
# FUNCTION directory_selection()
# Offers a configuratble, interactive dialog for directory-selection.
# Navigation from a 'starting directory' is available.
# In any given directory only visible directories are listed
# shown. Selected directory will get returned as fully qualified filename.
#
# FUNCTION show_message()
# Offers a configuratble, interactive dialog for showing messages, e.g. 
# error messages. There is just an okay button for acknowledge or 
# selfacknowledge happens after 10 seconds.
#
# FUNCTION show_info()
# Offers a configuratble dialog for showing information messages, e.g. 
# about a process in the background. There is no interaction.
# The message disappears when the background process finishes and any new
# content get shown on the screen.
#
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2023-10-21
# =============================================================================



# -----------------------------------------------------------------------------
# FUNCTIION dir_has_files()
# checks, if in the given 'directory' has files with file-extension 'filetype' 
#
# INPUT
#     $1 ... directory : fully qualified directory name
#     $2 ... filetype : file extension as string without dot, e.g. 'tiff' or 'png'
# RETURN:
#     0 ... okay, if 'directory' has files with file-extension 'filetype'
#    >0 ... 'directory' has no files with file-extension 'filetype'
# 
# HINT:
# The return value of the function can get retrieved from the error code '$?'!
# -----------------------------------------------------------------------------
function dir_has_files() {
	directory=$(realpath $1)
	filetype=$2
	
	search_pattern=$(printf "%s/*%s" "$directory" "$filetype")
	
	# redirect 'stdout' and 'stderr' to '/dev/null' as it is of no interest
	ls ${search_pattern} 1>/dev/null 2>/dev/null
	
	# check for error-code
	return $?
}



# -----------------------------------------------------------------------------
# FUNCTION directory_selection()
# Offers a configuratble, interactive dialog for directory-selection.
# Navigation from a 'starting directory' is available.
# In any given directory only visible directories are listed
# shown. Selected directory will get returned as fully qualified filename.
#
# INPUT
#     $1 ... backtitle : backtitle of dialog
#     $2 ... directory : fully qualified directory name to start search and view
#
# RETURN:
#    0 ... OKAY: on STDOUT get fully qualified directory, selected by user
#    1 ... ERROR: possibly a user exit with ESC-key
#    2 ... ERROR: single quote in filename or dirname detected
# 
# HINT:
# The return value of the function can get retrieved from the error code '$?'!
# -----------------------------------------------------------------------------
function directory_selection() {
	local BACKTITEL=${1}
	local CURRENT_DIRECTORY=${2}
	TITEL="Verzeichnisauswahl"

	let "UI_LOOP_BREAK=0"
	while [[ ${UI_LOOP_BREAK} -eq 0 ]]; do

		# -------------------------------
		# filter directory entries
		# -------------------------------
		CURRENT_DIRECTORY=$(realpath ${CURRENT_DIRECTORY})
		local ITEM_LIST="'0' '.' '1' '..'"
		local DIRECTORY_LIST=$(ls -1 --directory ${CURRENT_DIRECTORY}/*/ 2>/dev/null)
		local ERROR_CODE=$?

		declare -a ITEM_LIST_ARRAY
		let "counter=2"
		if [[ $ERROR_CODE -eq 0 ]]; then
			for item in ${DIRECTORY_LIST}; do
				# ignore empty lines
				if [ -z "${item}" ]; then continue; fi
	
				# as of problem with single quotes in dirnames, detect them
				if [[ "${item}" == *\'* ]]; then
					show_message \
						"${BACKTITEL}" \
						"FEHLER" \
						"Nichterlaubte Zeichen (Hochkommata bzw. single quotes)\nin Verzeichnisnamen gefunden!"
					return 2
				fi
			
				ITEM_LIST_ARRAY[counter]="${item}"
				item=$(basename "${item}")
				ITEM_LIST=$(printf "%s '%s' '%s'" "$ITEM_LIST" "${counter}" "${item}/")
				let "counter++"
			done
		else
			show_message \
				"${BACKTITEL}" \
				"FEHLER" \
				"Keine Verzeichnisse listbar in\n${CURRENT_DIRECTORY}"
			return 1
		fi


		# ----------------------------
		# Dialog choose a directory
		# ----------------------------
		local QUESTION="Aktuelles Verzeichnis:\n${CURRENT_DIRECTORY}\n\nwähle ein Verzeichnis aus:"
		local COMMAND="dialog --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --menu '${QUESTION}' 0 0 8"
		local ANSWER=$(eval $COMMAND "$ITEM_LIST" 3>&1 1>&2 2>&3)
		# Get the exit status
		local DIALOG_EXIT_STATUS=$?

		if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
			printf "\n" 1>/dev/stdout
			return 1
		else
			if [[ ${ANSWER} -eq 1 ]]; then
				# one directory level up
				CURRENT_DIRECTORY=$(dirname ${CURRENT_DIRECTORY})
			elif [[ ${ANSWER} -eq 0 ]]; then
				# directory selected
				let "UI_LOOP_BREAK=1"
			else
				CURRENT_DIRECTORY=${ITEM_LIST_ARRAY[$ANSWER]}
			fi
		fi
	done
	
	# return 'directory name'
	printf "%s\n" "${CURRENT_DIRECTORY}" 1>/dev/stdout
	return 0
}



# -----------------------------------------------------------------------------
# FUNCTION filtered_file_selection()
# Offers a configuratble, interactive dialog for file-selection.
# Navigation from a 'starting directory' is available.
# In any given directory only files matching to a given 'file_pattern'
# are listed. The selected file will get returned as fully qualified filename.
#
# INPUT
#     $1 ... backtitle : backtitle of dialog
#     $2 ... directory : fully qualified directory name to start search and view
#     $3 ... file_pattern : file pattern as string to search for,
#                           examples:
#                           '*.tiff' or '*.pdf'
#                           or '*' for any filename
# RETURN:
#    0 ... OKAY: on STDOUT get fully qualified filename, selected by user
#    1 ... ERROR: possibly a user exit with ESC-key
#    2 ... ERROR: single quote in filename or dirname detected
# 
# HINT:
# The return value of the function can get retrieved from the error code '$?'!
# -----------------------------------------------------------------------------
function filtered_file_selection() {
	local BACKTITEL=${1}
	local CURRENT_DIRECTORY=${2}
	local FILE_PATTERN=${3}

	local TITEL="Dateifilter \"${FILE_PATTERN}\""
	local SELECTED_FILE=""

	let "UI_LOOP_BREAK=0"
	while [[ ${UI_LOOP_BREAK} -eq 0 ]]; do

		declare -a ITEM_LIST_ARRAY

		# -------------------------------
		# add directory entries
		# -------------------------------
		CURRENT_DIRECTORY=$(realpath ${CURRENT_DIRECTORY})
		local ITEM_LIST="'0' '..'"
		local DIRECTORY_LIST=$(ls -1 --directory ${CURRENT_DIRECTORY}/*/ 2>/dev/null)
		local ERROR_CODE=$?
		if [[ $ERROR_CODE -eq 0 ]]; then
			let "counter=1"
			for item in ${DIRECTORY_LIST}; do
				# ignore empty lines
				if [[ -z "${item}" ]]; then continue; fi
				
				# as of problem with single quotes in dirnames, detect them
				if [[ "${item}" == *\'* ]]; then
					show_message \
						"${BACKTITEL}" \
						"FEHLER" \
						"Nichterlaubte Zeichen (Hochkommata bzw. single quotes)\nin Verzeichnisnamen gefunden!"
					return 2
				fi
			
				ITEM_LIST_ARRAY[counter]="${item}"
				item=$(basename "${item}")
				ITEM_LIST=$(printf "%s '%s' '%s'" "$ITEM_LIST" "${counter}" "${item}/")
				let "counter++"
			done
		fi

		# -------------------------------
		# add filtered file entries
		# -------------------------------
		FILE_LIST=$(ls -1 ${CURRENT_DIRECTORY}/${FILE_PATTERN} 2>/dev/null)
		ERROR_CODE=$?
		if [[ $ERROR_CODE -eq 0 ]]; then
			for item in ${FILE_LIST}; do
				# ignore empty lines
				if [[ -z "${item}" ]]; then continue; fi
			
				# as of problem with single quotes in filenames, detect them
				if [[ "${item}" == *\'* ]]; then
					show_message \
						"${BACKTITEL}" \
						"FEHLER" \
						"Nichterlaubte Zeichen (Hochkommata bzw. single quotes)\nin Dateinamen gefunden!"
					return 2
				fi
			
				if [[ -f "${item}" ]]; then
					ITEM_LIST_ARRAY[counter]="${item}"
					item=$(basename ${item})
					ITEM_LIST=$(printf "%s '%s' '%s'" "$ITEM_LIST" "${counter}" "${item}")
					let "counter++"
				fi
			done
		fi


		# ----------------------------
		# Dialog choose a file
		# ----------------------------
		QUESTION="Aktuelles Verzeichnis:\n${CURRENT_DIRECTORY}\n\nwähle eine Datei aus:"
		COMMAND="dialog --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --menu '${QUESTION}' 0 0 8"
		ANSWER=$(eval $COMMAND $ITEM_LIST 3>&1 1>&2 2>&3)
		# Get the exit status
		local DIALOG_EXIT_STATUS=$?
		SELECTED_FILE=""

		if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
			printf "\n" 1>/dev/stdout
			return 1
		else
			if [[ ${ANSWER} -eq 0 ]]; then
				# one directory level up
				CURRENT_DIRECTORY=$(dirname ${CURRENT_DIRECTORY})
			else
				if [[ -f ${ITEM_LIST_ARRAY[$ANSWER]} ]]; then
					# file selected
					SELECTED_FILE=${ITEM_LIST_ARRAY[$ANSWER]}
					let "UI_LOOP_BREAK=1"
				elif [[ -d ${ITEM_LIST_ARRAY[$ANSWER]} ]]; then
					CURRENT_DIRECTORY=${ITEM_LIST_ARRAY[$ANSWER]}
				else
					# selected item is neither of type 'file' nor of type 'directory'
					continue
				fi
			fi
		fi
	done

	printf "%s\n" "${SELECTED_FILE}" 1>/dev/stdout
	return 0
}



# -----------------------------------------------------------------------------
# FUNCTION show_message()
# Offers a configurable, interactive dialog for showing messages, e.g. 
# error messages. There is just an okay button for acknowledge or 
# selfacknowledge happens after 10 seconds.
#
# INPUT
#     $1 ... backtitle : backtitle of dialog
#     $2 ... title     : title of dialog
#     $3 ... message   : message of dialog, can contain '\n' for newline
#     $4 ... timeout   : in seconds, 
#                        optional parameter, if missing default is 10 seconds
#                        if value is '0' then no 'timeout' will be set
#
# RETURN:
#    0 ... OKAY
#    1 ... ERROR: possibly a user exit with ESC-key
# 
# HINT:
# The return value of the function can get retrieved from the error code '$?'!
# -----------------------------------------------------------------------------
function show_message() {
	local backtitle=${1}
	local title=${2}
	local message="\n${3}\n"
	local seconds=10
	if [[ -n "${4}" ]]; then
		seconds=${4}
	fi

	DIALOG_EXIT_CODE=0

	if [[ $seconds -eq 0 ]]; then
		dialog --backtitle "${backtitle}" --title "${title}" --no-cancel \
			--no-shadow --colors --msgbox "${message}" 15 65 \
			3>&1 1>&2 2>&3
		DIALOG_EXIT_CODE=$?
	else
		dialog --backtitle "${backtitle}" --title "${title}" --no-cancel \
			--no-shadow --colors --pause "${message}" 15 65 ${seconds} \
			3>&1 1>&2 2>&3
		DIALOG_EXIT_CODE=$?
	fi

	return ${DIALOG_EXIT_CODE}
}



# -----------------------------------------------------------------------------
# FUNCTION show_info()
# Offers a configuratble dialog for showing information messages, e.g. 
# about a process in the background. There is no interaction.
# The message disappears when the background process finishes and any new
# content get shown on the screen.
#
# INPUT
#     $1 ... backtitle : backtitle of dialog
#     $2 ... message   : message of dialog, can contain '\n' for newline
#
# RETURN:
#    0 ... OKAY
#    1 ... ERROR: possibly a user exit with ESC-key
# 
# HINT:
# The return value of the function can get retrieved from the error code '$?'!
# -----------------------------------------------------------------------------
function show_info() {
	local backtitle=${1}
	local message="\n${2}\n"

	dialog --backtitle "${backtitle}" --title "INFO" --no-cancel \
		--no-shadow --colors --infobox "${message}" \
		15 65 3>&1 1>&2 2>&3
	DIALOG_EXIT_CODE=$?

	return ${DIALOG_EXIT_CODE}
}



# -----------------------------------------------------------------------------
# FUNCTION is_integer_in_limits()
# Offers a test of string if its an integer value and additionally checks, if
# the numerical value is between the lower_limit and upper_limit.
#
# INPUT
#     $1 ... string_to_test
#     $2 ... lower_limit to test
#     $3 ... upper_limit to test
#
# ERROR_CODE:
#    0 ... OKAY : string_to_test is an integer value and
#                 lower_limit <= string_to_test <= upper_limit
#    1 ... ERROR: string_to_test is neither an integer, nor inside given limits
#
# EXAMPLEs:
#    is_integer_in_limits "a4" 0 20   --> ERROR_CODE=1
#    is_integer_in_limits "44" 0 200  --> ERROR_CODE=0
#    is_integer_in_limits "44" 50 200 --> ERROR_CODE=1
# 
# HINT:
# The return value of the function can get retrieved from the error code '$?'!
# -----------------------------------------------------------------------------
function is_integer_in_limits() {
	local string_to_test="${1}"
	local lower_limit="${2}"
	local upper_limit="${3}"

	if [[ $string_to_test =~ ^[0-9]+$ ]]; then
		if [[ $string_to_test -ge $lower_limit ]]; then
			if [[ $string_to_test -le $upper_limit ]]; then
				return 0
			fi
		fi
	fi

	return 1
}
