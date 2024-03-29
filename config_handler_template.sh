#!/usr/bin/env bash

"""Sets up the local environment of the user for the script config_handler.sh

Sets up the local environment of the user for the script config_handler.sh
As it is a template, please copy it first to a file named 
"config_handler.sh"!

After copy, it is strongly recommended to check all necessary parameters and
to change them accordingly for the local environment!

This script is getting sourced by all other Bash scripts of this project!
"""
# =============================================================================
# IMPORTANT:
#
# This script is a module and should get sourced by each script!
#
# It is part of set of scripts to create the content of a JSON-file to hold 
# meta information for a scanned document.
# The file "config" in the same directory is written and holds all relevant
# variables for the current project. Be shure that all scripts of the project
# source the config data to use them.
#
# From the initializing script the function "reset_config" in sequence with 
# "write_config"
# The function "write_config" should get called to persist any variable changes.
# -----------------------------------------------------------------------------
# AUTHOR .... marcus.trommen@gmx.net
# CREATED ... 20210522
# -----------------------------------------------------------------------------
# EXPORTED FUNCTION(s):
#     write_config
#     reset_config
# AFFECTS FILE(s):
#     config
# =============================================================================

# -----------------------------------------------------------------------------
# FUNCTION write_config ()
# write current variables to a config file for further use by other scripts
# INPUT
#     none
# RETURN:
#     none
# -----------------------------------------------------------------------------
function write_config {

	CONFIG_CONTENT=$(cat <<-EOF
#!/usr/bin/env bash

# IMPORTANT:
# This file is generated by config_handler.sh. 
# Do not make manual changes!
# 
# These symbols are intentionally not exported
# for not being visible in any subprocesses
# unless beeing sourced

BASH="$(command -v bash)"
PYTHON="$(command -v python3)"
DIALOG="$(command -v dialog)"
CONVERT="$(command -v convert)"
MOGRIFY="$(command -v mogrify)"
BC="$(command -v bc)"

export DIALOGRC=${SCAN_SCRIPT_BASE_DIRECTORY}/dialogrc
BACKTITEL="Dokumentarchivierung"
SCAN_SCRIPT_BASE_DIRECTORY="${SCAN_SCRIPT_BASE_DIRECTORY}"
SCAN_DEVICE="${SCAN_DEVICE}"
SCAN_DEVICE_TYPE="${SCAN_DEVICE_TYPE}"
SCAN_PDF_FONT="${SCAN_PDF_FONT}"
SCAN_ARCHIVE_BASE_DIRECTORY="${SCAN_ARCHIVE_BASE_DIRECTORY}"
SCAN_WORKING_DIRECTORY="${SCAN_WORKING_DIRECTORY}"
SCAN_DOCUMENT_ID="${SCAN_DOCUMENT_ID}"
SCAN_DOCUMENT_TITLE="${SCAN_DOCUMENT_TITLE}"
SCAN_DOCUMENT_ORIENTATION="${SCAN_DOCUMENT_ORIENTATION}"
SCAN_DOCUMENT_KEYWORDS='${SCAN_DOCUMENT_KEYWORDS}'
SCAN_DOCUMENT_FILE="${SCAN_DOCUMENT_FILE}"
SCAN_DOCUMENT_STORAGE_LOCATION="${SCAN_DOCUMENT_STORAGE_LOCATION}"
EOF
)
	printf "%s\n" "${CONFIG_CONTENT}" > "${SCAN_CONFIG_DIRECTORY}/config"
}


# -----------------------------------------------------------------------------
# FUNCTION reset_config ()
# resets some variables of the config file to 
#     *   empty strings (if string variables)
#     *   zero (if numeric variables)
#     *   default values (if variables should have values)
#
# Be aware of configuration is not written to file by this function!
#
# INPUT
#     none
# RETURN:
#     none
# -----------------------------------------------------------------------------
function reset_config {
	#SCAN_SCRIPT_BASE_DIRECTORY=$(dirname $(realpath $0))
	SCAN_SCRIPT_BASE_DIRECTORY="${SCAN_SCRIPT_BASE_DIRECTORY}"
	
	# --------------------------------------------
	# SET Archive Base Directory
	# --------------------------------------------
	SCAN_ARCHIVE_BASE_DIRECTORY="/path/to/docarchive"
	
	SCAN_DEVICE=""
	SCAN_DEVICE_TYPE=""

	SCAN_DOCUMENT_ID=""
	SCAN_DOCUMENT_ORIENTATION=""
	SCAN_DOCUMENT_TITLE=""
	SCAN_DOCUMENT_KEYWORDS=""
	SCAN_DOCUMENT_FILE=""
	SCAN_DOCUMENT_STORAGE_LOCATION=""
}

if [[ -z "${SCAN_SCRIPT_BASE_DIRECTORY}" ]]; then
	printf "ERROR: environment variable 'SCAN_SCRIPT_BASE_DIRECTORY' need to be set!\n" > /dev/stderr
	return 1
fi

SCAN_CONFIG_DIRECTORY="${HOME}/.config/scanarchive"
if [[ ! -d "${SCAN_CONFIG_DIRECTORY}" ]]; then
	mkdir --parents ${SCAN_CONFIG_DIRECTORY}
fi

if [[ -e "${SCAN_CONFIG_DIRECTORY}/config" ]]; then
	source "${SCAN_CONFIG_DIRECTORY}/config"
else
	printf "=== create config file and initialize variables with default values  ===\n" > /dev/stderr
	reset_config
	write_config
	source "${SCAN_CONFIG_DIRECTORY}/config"
fi

return 0

