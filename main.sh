#!/usr/bin/env bash

# =============================================================================
# 
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2022-01-03
# =============================================================================

export SCAN_SCRIPT_BASE_DIRECTORY=$(dirname $(realpath $0))
source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh


# --- Main Menu ---
let "USER_EXIT=0"
while [[ ${USER_EXIT} -eq 0 ]]; do
	TITEL="Hauptmenü"
	QUESTION="Deine Auswahl?"
	ITEM_LIST='"1" "Scanner auswählen und initialisieren" "2" "Dokumentdaten erfassen" "3" "PDF zum Archiv hinzufügen" "4" "Dokument scannen" "5" "Buch scannen mit Flachbett-Scanner" "6" "PDF aktualisieren (ohne Scan)" "7" "Alle neu gescannten Dokumente in PDF umwandeln" "8" "Ende"'
	COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --menu '${QUESTION}' 15 60 8"
	ANSWER=$(eval $COMMAND $ITEM_LIST 3>&1 1>&2 2>&3)
	DIALOG_EXIT_STATUS=$?

	if [[ ${DIALOG_EXIT_STATUS} -eq 0 ]] ; then
		case "${ANSWER}" in
			1)
				# Scanner auswählen und initialisieren
				# ggf. Auswahl des Scanners, sofern mehrere parallel verfügbar sind
				${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/init_scanner.sh
				ERROR_CODE=$?

				if [[ $ERROR_CODE -gt 0 ]]; then
					show_message \
						"${BACKTITEL}" \
						"FEHLER" \
						"Es trat ein Fehler bei der Auswahl und Initialisierung des Scanners auf,\nso dass kein Scanner genutzt werden kann.\nBitte nochmal wiederholen."
				fi;
				;;
			2)
				# Dokumentdaten erfassen ==> Meta-Daten anlegen
				${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/meta_document_id.sh
				ERROR_CODE=$?
				
				if [[ $ERROR_CODE -eq 0 ]]; then
					${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/meta_title.sh
					ERROR_CODE=$?
				fi;
				
				if [[ $ERROR_CODE -eq 0 ]]; then
					${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/meta_keywords.sh
					ERROR_CODE=$?
				fi;

				if [[ $ERROR_CODE -eq 0 ]]; then
					${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/meta_storage_location.sh
					ERROR_CODE=$?
				fi;

				if [[ $ERROR_CODE -eq 0 ]]; then
					${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/meta_orientation.sh
					ERROR_CODE=$?
				fi;

				if [[ $ERROR_CODE -eq 0 ]]; then
					${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/meta_json.sh
					ERROR_CODE=$?
				fi;

				if [[ $ERROR_CODE -gt 0 ]]; then
					show_message \
						"${BACKTITEL}" \
						"FEHLER" \
						"Es trat ein Fehler bei der Erfassung der Dokumentdaten auf,\nso dass diese nicht angelegt werden konnten.\nBitte nochmal wiederholen."
						# TODO: evtl. JSON-Datei wieder löschen!!!
				fi;
				;;
			3)
				# PDF zum Archiv hinzufügen
				# bestehendes PDF (z.B. Anleitung, Kontoauszug) umbenennen auf Document_ID
				${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/copy_pdf.sh
				;;
			4)
				# Dokument scannen und als TIFF-Dateien ablegen, 
				# Duplikate löschen und ggf. optimieren
				if [[ ! -d "${SCAN_WORKING_DIRECTORY}" ]] ; then
					show_message \
						"${BACKTITEL}" \
						"FEHLER" \
						"Eine Vorbedingung für den Scan-Vorgang ist noch nicht erfüllt:\nKeine JSON-Datei mit Informationen zum Dokument gefunden!\nSo dass der Vorgang nicht durchgeführt werden kann.\nBitte erfasse erst die Meta-Informationen zum Dokument."
				else
					if [[ "${SCAN_DEVICE_TYPE}" = "flatbed" ]] ; then
						${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/flatbed_scanner.sh
						ERROR_CODE=$?
					elif [[ "${SCAN_DEVICE_TYPE}" = "adf" ]] ; then
						${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/adf_scanner.sh
						ERROR_CODE=$?
					else
						show_message \
							"${BACKTITEL}" \
							"FEHLER" \
							"Der ausgewählte Scanner wird derzeit nicht unterstützt!\n\n${SCAN_DEVICE_TYPE}\n\nBitte wähle einen anderen Scanner aus."
							
						continue
					fi
					
					if [[ $ERROR_CODE -eq 0 ]]; then
						show_message \
							"${BACKTITEL}" \
							"INFO" \
							"Dokument-ID: ${SCAN_DOCUMENT_ID}"
					else
						show_message \
							"${BACKTITEL}" \
							"FEHLER" \
							"Es trat ein Fehler beim Scannen der Dokumente auf."
							# TODO: evtl. JSON-Datei wieder löschen!!!
					fi;
				fi
				;;
			5)
				# Buch scannen mit Flachbett-Scanner
				${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/book_scanning.sh
				EXIT_CODE=$?
				
				if [[ $EXIT_CODE -gt 0 ]]; then
					show_message \
						"${BACKTITEL}" \
						"FEHLER" \
						"Abbruch durch Benutzer!"
				fi
				;;
			6)
				# PDF neu erstellen, indem JSON-Datei und alle PNG-Dateien nochmals gelesen werden
				${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/update_pdf.sh
				;;				
			7)
				# PDF aus Scans erstellen
				# TIFF-Dateien komprimieren
				# TIFF-Dateien als PNG-Dateien speichern
				# PNG-Dateien rotieren falls erforderlich (landscape)
				# aus PNG-Dateien und JSON-Metadaten PDF-Datei erstellen
				# TIFF-Dateien löschen
				TITEL="PDF aus Scans erstellen"
				show_info \
					"${BACKTITEL}" \
					"${TITEL}\n\nTIFF-Dateien komprimieren\nTIFF-Dateien als PNG-Dateien speichern\nPNG-Dateien rotieren falls erforderlich (landscape)\naus PNG-Dateien und JSON-Metadaten PDF-Datei erstellen\nTIFF-Dateien löschen"

				${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/tools/bulk_tiff_optimizer.sh
				;;
			8)
				# Ende
				let "USER_EXIT=1"
				reset_config
				write_config
				clear
				exit 0
				;;
		esac
	fi
	
	# reload config file for any changes by subscripts
	source ${SCAN_CONFIG_DIRECTORY}/config
done

write_config
clear
show_message \
	"${BACKTITEL}" \
	"FEHLER" \
	"Irgendetwas war nicht in Ordnung!"
exit 1
