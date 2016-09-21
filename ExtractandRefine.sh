#!/bin/bash
# For producing HTML5 outputs via XSweet XSLT from sources extracted from .docx (Office Open XML)

# $DOCXdocumentXML is the 'word/document.xml' file extracted (unzipped) from a .docx file
# (Also, its neighbor files from the .docx package should be available.)
DOCXdocumentXML="Demo_text_docx/word/document.xml"

# $FILE is a short identifier
FILE="DEMOTEXT"                                          

saxonHE="java -jar lib/SaxonHE9-7-0-8J/saxon9he.jar"  # SaxonHE (XSLT 2.0 processor)
EXTRACT="docx-html-extract.xsl"        # "Extraction" stylesheet
REFINE1="handle-notes.xsl"             # "Refinement" stylesheets
REFINE2="scrub.xsl"
REFINE3="join-elements.xsl"

# Intermediate and final outputs (serializations) are all left on the file system
$saxonHE -xsl:$EXTRACT -s:$DOCXdocumentXML     -o:$FILE-EXTRACTED.html
echo Made $FILE-EXTRACTED.html
$saxonHE -xsl:$REFINE1 -s:$FILE-EXTRACTED.html -o:$FILE-REFINED_1.html
echo Made $FILE-REFINED_1.html
$saxonHE -xsl:$REFINE2 -s:$FILE-REFINED_1.html -o:$FILE-REFINED_2.html
echo Made $FILE-REFINED_2.html
$saxonHE -xsl:$REFINE3 -s:$FILE-REFINED_2.html -o:$FILE-REFINED_3.html
echo Made $FILE-REFINED_3.html

