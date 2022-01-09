#!/usr/bin/env bash

# =============================================================================
# Handle scanning of pages for one document with a single sided flatbed
# scan device. 
#
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
# LAST CHANGE ... 2022-01-04
# =============================================================================

source ${SCAN_SCRIPT_BASE_DIRECTORY}/config_handler.sh
source ${SCAN_SCRIPT_BASE_DIRECTORY}/dialogs/library.sh


# --------------------------
# define script global constants
# --------------------------
PAGE_ODD="PAGE_ODD"
PAGE_EVEN="PAGE_EVEN"
SCAN_AREA_WIDTH_DEFAULT="215"
SCAN_AREA_HEIGHT_DEFAULT="297"
SCAN_AREA_TOP_LEFT_X_DEFAULT="0"
SCAN_AREA_TOP_LEFT_Y_DEFAULT="0"
TITEL="Buch scannen mit Flachbett-Scanner"


# --------------------------
# define script global variables
# --------------------------
EVEN_SCAN_AREA_WIDTH=""
EVEN_SCAN_AREA_HEIGHT=""
EVEN_SCAN_AREA_TOP_LEFT_X=""
EVEN_SCAN_AREA_TOP_LEFT_Y=""

ODD_SCAN_AREA_WIDTH=""
ODD_SCAN_AREA_HEIGHT=""
ODD_SCAN_AREA_TOP_LEFT_X=""
ODD_SCAN_AREA_TOP_LEFT_Y=""

WAITING_TIME_BETWEEN_SCANS=""


# --------------------------
# DIALOG waiting time for 'continuous scan'
# HINT: due to "scanner busy" problem, 
# no shorter WAITING_TIME_BETWEEN_SCANS than 10 seconds possible!
# --------------------------
QUESTION=$(printf "%s%s%s" \
    "\nEs wird zwischen aufeinanderfolgende Scan-Durchläufe gewartet. " \
    "Die Wartezeit kann eingestellt werden.\n\n" \
    "Deine Auswahl?\n")
ITEM_LIST='"10" "10 Sekunden     " "15" "15 Sekunden     "'
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --menu '${QUESTION}' 15 65 2"
ANSWER=$(eval $COMMAND $ITEM_LIST 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
    exit 1
fi
WAITING_TIME_BETWEEN_SCANS=$ANSWER


# --------------------------
# DIALOG EVEN_SCAN_AREA_WIDTH
# --------------------------
PRESET=${SCAN_AREA_WIDTH_DEFAULT}
QUESTION=$(printf "%s%s%s%s" \
    "\n\Zb\Z7Breite des zu scannenden Bereichs in 'mm' für gerade Seiten?\Zn\n\n" \
    "Zulässige Werte: 0 ... 215 mm\n" \
    "Vorgabewert ist ${PRESET} mm\n\n" \
    "HINWEIS: Es sind nur ganzzahlige Werte erlaubt!\n")
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --colors --inputbox '${QUESTION}' 15 65"
ANSWER=$(eval $COMMAND $PRESET 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
    exit 1
fi

is_integer_in_limits "$ANSWER" 0 215
EXIT_STATUS=$?
if [[ ${EXIT_STATUS} -eq 0 ]]; then
    EVEN_SCAN_AREA_WIDTH=$ANSWER
else
    EVEN_SCAN_AREA_WIDTH=$SCAN_AREA_WIDTH_DEFAULT
fi


# --------------------------
# DIALOG EVEN_SCAN_AREA_HEIGHT
# --------------------------
PRESET=${SCAN_AREA_HEIGHT_DEFAULT}
QUESTION=$(printf "%s%s%s%s" \
    "\n\Zb\Z7Höhe des zu scannenden Bereichs in 'mm' für gerade Seiten?\Zn\n\n" \
    "Zulässige Werte: 0 ... 297 mm\n" \
    "Vorgabewert ist ${PRESET} mm\n\n" \
    "HINWEIS: Es sind nur ganzzahlige Werte erlaubt!\n")
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --colors --inputbox '${QUESTION}' 15 65"
ANSWER=$(eval $COMMAND $PRESET 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
    exit 1
fi

is_integer_in_limits "$ANSWER" 0 297
EXIT_STATUS=$?
if [[ ${EXIT_STATUS} -eq 0 ]]; then
    EVEN_SCAN_AREA_HEIGHT=$ANSWER
else
    EVEN_SCAN_AREA_HEIGHT=$SCAN_AREA_HEIGHT_DEFAULT
fi


# --------------------------
# DIALOG EVEN_SCAN_AREA_TOP_LEFT_X
# --------------------------
PRESET=${SCAN_AREA_TOP_LEFT_X_DEFAULT}
QUESTION=$(printf "%s%s%s%s%s" \
    "\n\Zb\Z7Abstand der oberen linken Ecke des zu scannenden Bereichs\n" \
    "in X-Richtung in 'mm' für gerade Seiten?\Zn\n\n" \
    "Zulässige Werte: 0 ... 215 mm\n" \
    "Vorgabewert ist ${PRESET} mm\n\n" \
    "HINWEIS: Es sind nur ganzzahlige Werte erlaubt!\n")
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --colors --inputbox '${QUESTION}' 15 65"
ANSWER=$(eval $COMMAND $PRESET 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
    exit 1
fi

is_integer_in_limits "$ANSWER" 0 215
EXIT_STATUS=$?
if [[ ${EXIT_STATUS} -eq 0 ]]; then
    EVEN_SCAN_AREA_TOP_LEFT_X=$ANSWER
else
    EVEN_SCAN_AREA_TOP_LEFT_X=$SCAN_AREA_TOP_LEFT_X_DEFAULT
fi


# --------------------------
# DIALOG EVEN_SCAN_AREA_TOP_LEFT_Y
# --------------------------
PRESET=${SCAN_AREA_TOP_LEFT_Y_DEFAULT}
QUESTION=$(printf "%s%s%s%s%s" \
    "\n\Zb\Z7Abstand der oberen linken Ecke des zu scannenden Bereichs\n" \
    "in Y-Richtung in 'mm' für gerade Seiten?\Zn\n\n" \
    "Zulässige Werte: 0 ... 297 mm\n" \
    "Vorgabewert ist ${PRESET} mm\n\n" \
    "HINWEIS: Es sind nur ganzzahlige Werte erlaubt!\n")
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --colors --inputbox '${QUESTION}' 15 65"
ANSWER=$(eval $COMMAND $PRESET 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
    exit 1
fi

is_integer_in_limits "$ANSWER" 0 297
EXIT_STATUS=$?
if [[ ${EXIT_STATUS} -eq 0 ]]; then
    EVEN_SCAN_AREA_TOP_LEFT_Y=$ANSWER
else
    EVEN_SCAN_AREA_TOP_LEFT_Y=$SCAN_AREA_TOP_LEFT_Y_DEFAULT
fi


# --------------------------
# DIALOG ODD_SCAN_AREA_WIDTH
# --------------------------
PRESET=${SCAN_AREA_WIDTH_DEFAULT}
QUESTION=$(printf "%s%s%s%s" \
    "\n\Zb\Z7Breite des zu scannenden Bereichs in 'mm' für ungerade Seiten?\Zn\n\n" \
    "Zulässige Werte: 0 ... 215 mm\n" \
    "Vorgabewert ist ${PRESET} mm\n\n" \
    "HINWEIS: Es sind nur ganzzahlige Werte erlaubt!\n")
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --colors --inputbox '${QUESTION}' 15 65"
ANSWER=$(eval $COMMAND $PRESET 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
    exit 1
fi

is_integer_in_limits "$ANSWER" 0 215
EXIT_STATUS=$?
if [[ ${EXIT_STATUS} -eq 0 ]]; then
    ODD_SCAN_AREA_WIDTH=$ANSWER
else
    ODD_SCAN_AREA_WIDTH=$SCAN_AREA_WIDTH_DEFAULT
fi


# --------------------------
# DIALOG ODD_SCAN_AREA_HEIGHT
# --------------------------
PRESET=${SCAN_AREA_HEIGHT_DEFAULT}
QUESTION=$(printf "%s%s%s%s" \
    "\n\Zb\Z7Höhe des zu scannenden Bereichs in 'mm' für ungerade Seiten?\Zn\n\n" \
    "Zulässige Werte: 0 ... 297 mm\n" \
    "Vorgabewert ist ${PRESET} mm\n\n" \
    "HINWEIS: Es sind nur ganzzahlige Werte erlaubt!\n")
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --colors --inputbox '${QUESTION}' 15 65"
ANSWER=$(eval $COMMAND $PRESET 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
    exit 1
fi

is_integer_in_limits "$ANSWER" 0 297
EXIT_STATUS=$?
if [[ ${EXIT_STATUS} -eq 0 ]]; then
    ODD_SCAN_AREA_HEIGHT=$ANSWER
else
    ODD_SCAN_AREA_HEIGHT=$SCAN_AREA_HEIGHT_DEFAULT
fi


# --------------------------
# DIALOG ODD_SCAN_AREA_TOP_LEFT_X
# --------------------------
PRESET=${SCAN_AREA_TOP_LEFT_X_DEFAULT}
QUESTION=$(printf "%s%s%s%s%s" \
    "\n\Zb\Z7Abstand der oberen linken Ecke des zu scannenden Bereichs\n" \
    "in X-Richtung in 'mm' für ungerade Seiten?\Zn\n\n" \
    "Zulässige Werte: 0 ... 215 mm\n" \
    "Vorgabewert ist ${PRESET} mm\n\n" \
    "HINWEIS: Es sind nur ganzzahlige Werte erlaubt!\n")
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --colors --inputbox '${QUESTION}' 15 65"
ANSWER=$(eval $COMMAND $PRESET 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
    exit 1
fi

is_integer_in_limits "$ANSWER" 0 215
EXIT_STATUS=$?
if [[ ${EXIT_STATUS} -eq 0 ]]; then
    ODD_SCAN_AREA_TOP_LEFT_X=$ANSWER
else
    ODD_SCAN_AREA_TOP_LEFT_X=$SCAN_AREA_TOP_LEFT_X_DEFAULT
fi


# --------------------------
# DIALOG ODD_SCAN_AREA_TOP_LEFT_Y
# --------------------------
PRESET=${SCAN_AREA_TOP_LEFT_Y_DEFAULT}
QUESTION=$(printf "%s%s%s%s%s" \
    "\Zb\Z7Abstand der oberen linken Ecke des zu scannenden Bereichs\n" \
    "in Y-Richtung in 'mm' für ungerade Seiten?\Zn\n\n" \
    "Zulässige Werte: 0 ... 297 mm\n" \
    "Vorgabewert ist ${PRESET} mm\n" \
    "Es sind nur ganzzahlige Werte erlaubt!\n")
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --colors --inputbox '${QUESTION}' 15 65"
ANSWER=$(eval $COMMAND $PRESET 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
    exit 1
fi

is_integer_in_limits "$ANSWER" 0 297
EXIT_STATUS=$?
if [[ ${EXIT_STATUS} -eq 0 ]]; then
    ODD_SCAN_AREA_TOP_LEFT_Y=$ANSWER
else
    ODD_SCAN_AREA_TOP_LEFT_Y=$SCAN_AREA_TOP_LEFT_Y_DEFAULT
fi


# --------------------------
# DIALOG start scan with EVEN_PAGE or ODD_PAGE
# --------------------------
QUESTION=$(printf "%s%s%s" \
    "\nNach diesem Dialog beginnt der Scan-Vorgang.\n" \
    "Mit welcher Seite möchtest du den Scan-Vorgang beginnen?\n\n" \
    "HINWEIS: Bitte Dokument richtig auflegen!\n")
ITEM_LIST='"1" "gerade Seite (Vorlage auf dem Kopf stehend)" "2" "ungerade Seite                              "'
COMMAND="${DIALOG} --backtitle '${BACKTITEL}' --title '${TITEL}' --no-cancel --no-shadow --colors --menu '${QUESTION}' 15 65 2"
ANSWER=$(eval $COMMAND $ITEM_LIST 3>&1 1>&2 2>&3)
DIALOG_EXIT_STATUS=$?
if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
    exit 1
fi

CURRENT_PAGE="${PAGE_ODD}"
if [[ $ANSWER -eq 1 ]]; then
    CURRENT_PAGE="${PAGE_EVEN}"
fi


# --------------------------
# LOOP for document scan
# --------------------------
let "UI_LOOP_BREAK=0"
while [[ ${UI_LOOP_BREAK} -eq 0 ]]; do


    # --------------------------
    # find next available page number
    # --------------------------
    TARGET_TIFF_FILENAME=""
    let "PAGE_NUMBER=1"
    let "LOOP_BREAK=0"
    while [[ ${PAGE_NUMBER} -le 999 && ${LOOP_BREAK} -eq 0 ]]; do
        TARGET_TIFF_FILENAME=$(printf "${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_%03d.tiff" "$PAGE_NUMBER")
    
        if [[ ! -e "${TARGET_TIFF_FILENAME}" ]] ; then
            # next available TIFF file name found, ready to scan
            let "LOOP_BREAK=1"
        else
            let "PAGE_NUMBER++"
        fi
    done

    
    if [[ "${CURRENT_PAGE}" = "${PAGE_EVEN}" ]]; then
        # handle PAGE_EVEN
        CURRENT_PAGE="${PAGE_ODD}"


        # --------------------------
        # DIALOG busy with scanning
        # --------------------------
        message=$(printf "%s%s%s" \
            "Scannen\n\nScanner scannt auf dem Kopf stehende \Zb\Z7Gerade Seite\Zn.\n" \
            "Seite wird nach dem Scan gedreht.\n\n" \
            "Prozess läuft ...")
        show_info \
            "${BACKTITEL}" \
            "${message}"
        

        # --------------------------
        # scan EVEN page with flatbed scan device
        # --------------------------
        ${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/scantools/singlescan_enhanced.sh \
            "${SCAN_DEVICE}" \
            "${SCAN_WORKING_DIRECTORY}" \
            "${SCAN_DOCUMENT_ID}" \
            "${PAGE_NUMBER}" \
            "${EVEN_SCAN_AREA_WIDTH}" \
            "${EVEN_SCAN_AREA_HEIGHT}" \
            "${EVEN_SCAN_AREA_TOP_LEFT_X}" \
            "${EVEN_SCAN_AREA_TOP_LEFT_Y}"
        EXIT_STATUS=$?


        # --------------------------
        # rotate EVEN page by 180 degrees
        # --------------------------
        if [[ ${EXIT_STATUS} -eq 0 ]]; then
            ${MOGRIFY} -rotate 180 ${TARGET_TIFF_FILENAME} 2>/dev/null
            EXIT_STATUS=$?
        fi


        if [[ ${EXIT_STATUS} -gt 0 ]]; then
            show_message \
                "${BACKTITEL}" \
                "FEHLER" \
                "Während des Scannens trat ein Fehler auf!"
            exit 1
        fi


        # --------------------------
        # DIALOG wait between scans
        # --------------------------
        message=$(printf "%s%s%s" \
            "Wartezeit zwischen zwei Scans\n" \
            "Nächste Vorlage (ungerade Seite) in Scanner einlegen.\n\n" \
            "Für Scan-Abbruch ESC-Teste drücken.\n")
        show_message \
            "${BACKTITEL}" \
            "INFO" \
            "${message}" \
            ${WAITING_TIME_BETWEEN_SCANS}
        DIALOG_EXIT_STATUS=$?

        if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
            let "UI_LOOP_BREAK=1"
        fi

    else
        # handle PAGE_ODD
        CURRENT_PAGE="${PAGE_EVEN}"


        # --------------------------
        # DIALOG busy with scanning
        # --------------------------
        message=$(printf "%s%s" \
            "Scannen\n\nScanner scannt \Zb\Z7Ungerade Seite\Zn.\n\n" \
            "Prozess läuft ...")
        show_info \
            "${BACKTITEL}" \
            "${message}"
        

        # --------------------------
        # scan EVEN page with flatbed scan device
        # --------------------------
        ${BASH} ${SCAN_SCRIPT_BASE_DIRECTORY}/scantools/singlescan_enhanced.sh \
            "${SCAN_DEVICE}" \
            "${SCAN_WORKING_DIRECTORY}" \
            "${SCAN_DOCUMENT_ID}" \
            "${PAGE_NUMBER}" \
            "${ODD_SCAN_AREA_WIDTH}" \
            "${ODD_SCAN_AREA_HEIGHT}" \
            "${ODD_SCAN_AREA_TOP_LEFT_X}" \
            "${ODD_SCAN_AREA_TOP_LEFT_Y}"
        EXIT_STATUS=$?

        if [[ ${EXIT_STATUS} -gt 0 ]]; then
            show_message \
                "${BACKTITEL}" \
                "FEHLER" \
                "Während des Scannens trat ein Fehler auf!"
            exit 1
        fi


        # --------------------------
        # DIALOG wait between scans
        # --------------------------
        message=$(printf "%s%s%s" \
            "Wartezeit zwischen zwei Scans\n" \
            "Nächste Vorlage (gerade Seite) in Scanner auf dem Kopf stehend einlegen.\n\n" \
            "Für Scan-Abbruch ESC-Teste drücken.\n")
        show_message \
            "${BACKTITEL}" \
            "INFO" \
            "${message}" \
            ${WAITING_TIME_BETWEEN_SCANS}
        DIALOG_EXIT_STATUS=$?
        
        if [[ ${DIALOG_EXIT_STATUS} -gt 0 ]]; then
            let "UI_LOOP_BREAK=1"
        fi

    fi
done


# --------------------------------------------
# post-scan improvements
# --------------------------------------------
TITEL="Scan-Dateien aufbereiten"


# --------------------------------------------
# improve contrast on scans
# --------------------------------------------
# show_info \
# 	"${BACKTITEL}" \
# 	"${TITEL}\n\nKontrast aller gescannten Seiten verbessern ..."

# for tiff_file in ${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_???.tiff; do
# 	${MOGRIFY} -sigmoidal-contrast 3,0% "${tiff_file}"
# done


# --------------------------------------------
# delete blank pages
# http://philipp.knechtges.com/?p=190
# --------------------------------------------
show_info \
	"${BACKTITEL}" \
	"${TITEL}\n\nleere Seiten löschen ..."
for tiff_file in ${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_???.tiff; do
	histogram=$(${CONVERT} "${tiff_file}" -threshold 50% -format %c histogram:info:-)
	
	white=$(printf "%s\n" "${histogram}" | grep "#FFFFFF" | sed -n 's/^ *\(.*\):.*$/\1/p')
	if [[ -z "${white}" ]]; then white="0";fi
	
	black=$(printf "%s\n" "${histogram}" | grep "#000000" | sed -n 's/^ *\(.*\):.*$/\1/p')
	if [[ -z "${black}" ]]; then black="0";fi
	
	blank=$(printf "%s\n" "scale=4; ${black}/${white} < 0.005" | ${BC})

	if [[ ${blank} -eq 1 ]]; then
		rm --force "${tiff_file}"
	fi
done


# --------------------------------------------
# renumber files
# --------------------------------------------
show_info \
	"${BACKTITEL}" \
	"${TITEL}\n\nSeiten ggf. neu nummerieren ..."
MESSAGE="Seiten sortieren"
let "PAGE_NUMBER=1"
for tiff_file in ${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_???.tiff; do
	new_tiff_file=$(printf "${SCAN_WORKING_DIRECTORY}/${SCAN_DOCUMENT_ID}_%03d.tiff" ${PAGE_NUMBER})
	if [[ ! "${tiff_file}" = "${new_tiff_file}" ]]; then
		mv --force ${tiff_file} ${new_tiff_file}
	fi
	
	let "PAGE_NUMBER++"
done

exit 0
