DOCX-xslt - XSLT for extraction of document contents from MS Office Open XML

Wendell Piez for Coko Foundation
From July 2016

[file] docx-extract.xpl - XProc pipeline specification for three-step pipeline

[file] docx-html-extract.xsl - A stylesheet wrapper providing "inspection" of the .docx (file),
  calls quickndirty2.xsl for the actual extraction.
  Interface: initial template should be 'extract';
    parameter $docx-file-path must be passed in (a URI)

[file] quickndirty.xsl - first attempt at extraction of data from docx
[file] quickndirty2.xsl - better attempt (so this one is called)
  *Both these stylesheets assume a document.xml file (not a containing .docx package file)
    as primary input (i.e. they don't read into the zip but assume the environment has done that.)

[file] scrub.xsl - post-process to be run on results of quickndirty process
  removes superfluous markup
    (currently: @style attributes over HTML; empty paragraphs)

[file] join-elements.xsl - post-process to merge contiguous runs of markup
  into single spans
    so <u>Moby </u><u>Dick</u> becomes <u>Moby Dick</u>

So a pipeline might run

set saxonHE="java -jar C:\Bin\Saxon\saxon9he.jar"

set FILEURI=$1

saxonHE -xsl:docx-html-extract.xsl -it:extract           -o:$FILE-extracted.xml docx-file-path:%FILEURI%
saxonHE -xsl:scrub.xsl             -s:FILE-extracted.xml -o:$FILE-scrubbed.xml
saxonHE -xsl:join-elements.xsl     -s:FILE-scrubbed.xml  -o:$FILE-finished.xml

With all three files (final and temporary results) left as artifacts in the system.
