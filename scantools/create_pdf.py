#!/usr/bin/env python3
# -*- coding: utf-8 -*-
 
# -----------------------------------------------------------------------------
# Update meta data of existing PDF document from JSON file, therfore in the
# background do ...
# ... check if PDF file exists and delete it
# ... add all PNG files as single pages to the PDF file
# ... set meta data of PDF file with content from JSON file
# -----------------------------------------------------------------------------
# AUTHOR ........ Marcus Trommen (mailto:marcus.trommen@gmx.net)
# LAST CHANGE ... 2021-12-31
# -----------------------------------------------------------------------------

import os
import fpdf
import json
from PIL import Image


# -----------------------------------------------------------------------------
# file extensions

PNG_EXTENSION = ".png"
PDF_EXTENSION = ".pdf"
JSON_EXTENSION = ".json"

# -----------------------------------------------------------------------------
def get_environment():

	args={}
	args["SCAN_WORKING_DIRECTORY"] = os.environ["SCAN_WORKING_DIRECTORY"]
	args["SCAN_DOCUMENT_ID"] = os.environ["SCAN_DOCUMENT_ID"]
	
	return args


# -----------------------------------------------------------------------------
def get_files_from_directory(path_to_files, filter_file_extension):

	filenames = []

	for filename in os.listdir(path_to_files):
		if filename.endswith(filter_file_extension):
			filename=os.path.join(path_to_files, filename)
			filenames.append(filename)

	filenames.sort()
	return filenames


# -----------------------------------------------------------------------------
def add_metadata_to_pdf(pdf_document, json_document):

	# load document metadata from JSON file
	metadata = {}
	with open(json_document, "r") as fileObject:
		metadata = json.load(fileObject)
		if not metadata:
			raise RuntimeError("JSON file should not be empty!")

	
	# metadata
	pdf_document.set_author("Marcus Trommen")
	pdf_document.set_creator("Scan Workflow with PyFPDF library")
	pdf_document.set_keywords(" ".join(metadata["keywords"]))
	pdf_document.set_subject(metadata["title"])
	pdf_document.set_title(metadata["id"])
	pdf_document.set_display_mode("fullpage", "continuous")
	
	return


# -----------------------------------------------------------------------------
def add_scans_to_pdf(pdf_document, args):
	filename_list = get_files_from_directory(args["SCAN_WORKING_DIRECTORY"], PNG_EXTENSION)

	pdf_document.set_margins(left=0.0, top=0.0, right=0.0)
	
	for filename in filename_list:
		image = Image.open(filename)
		width, height = image.size
		
		if (width < height):
			# format = portrait / hochkant
			pdf_document.add_page(orientation = 'P')
			pdf_document.image(filename, x = 0, y = 0, w = 210, h = 296, type = 'png')
		else:
			# format = landscap / quer
			pdf_document.add_page(orientation = 'L')
			pdf_document.image(filename, x = 0, y = 0, w = 296, type = 'png')

	return



# -----------------------------------------------------------------------------
# main program
# -----------------------------------------------------------------------------
if __name__ == '__main__':
	args = get_environment()
	
	origin_path = args["SCAN_WORKING_DIRECTORY"]
		
	pdf_path = os.path.join(
		origin_path, args["SCAN_DOCUMENT_ID"] + PDF_EXTENSION)
	
	json_path = os.path.join(
		origin_path, args["SCAN_DOCUMENT_ID"] + JSON_EXTENSION)

	pdf_document = fpdf.FPDF(orientation="P", unit="mm", format="A4")

	add_metadata_to_pdf(pdf_document, json_path)
	
	add_scans_to_pdf(pdf_document, args)

	# close document
	pdf_document.close()
	pdf_document.output(pdf_path, 'F')
