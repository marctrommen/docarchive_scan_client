#!/usr/bin/env bash

# =============================================================================
# Wrapper script to start the dialog based wizzard for scanning documents on
# Linux. Manage and organize these documents within a document archive.
# Therefore it is needed to start a Python virtual environment.
#
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-01-03
# =============================================================================

PROJECT_DIR=/home/marco/Scratchbook/docarchiv/scan_client

	cd ${PROJECT_DIR}
	source ${PROJECT_DIR}/bin/activate
	ERROR_CODE=$?
	
	if [[ $ERROR_CODE -gt 0 ]]; then
		printf "%s\n" "ERROR: problem with starting Python virtual environment!"
		sleep 10
		exit 1
fi

${PROJECT_DIR}/main.sh
