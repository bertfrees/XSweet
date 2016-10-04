<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:option name="docx-file-uri" required="true"/>
  
  <!--<p:output port="_Z_FINAL">
    <p:pipe port="result" step="final"/>
  </p:output>
  
  <p:output port="_A_extracted" primary="false">
    <p:pipe port="result" step="slops-extracted"/>
  </p:output>
  <p:output port="_B_arranged" primary="false">
    <p:pipe port="result" step="notes-arranged"/>
  </p:output>
  <p:output port="_C_scrubbed" primary="false">
    <p:pipe port="result" step="scrubbed"/>
  </p:output>
  <p:output port="_D_tightened" primary="false">
    <p:pipe port="result" step="collapsed"/>
  </p:output>
  <p:output port="_E_mapped" primary="false">
    <p:pipe port="result" step="mapped"/>
  </p:output>
  <p:output port="_F_plaintext" primary="false">
    <p:pipe port="result" step="plaintext"/>
  </p:output>
  <p:output port="_G_analysis" primary="false">
    <p:pipe port="result" step="analysis"/>
  </p:output>
  
  <p:serialization port="_Z_FINAL"     indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_A_extracted" indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_B_arranged"  indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_C_scrubbed"  indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_D_tightened" indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_E_mapped"    indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_F_plaintext" method="text" />
  <p:serialization port="_G_analysis"  indent="true" omit-xml-declaration="true"/>
  -->
  <p:variable name="document-path" select="concat('jar:',$docx-file-uri,'!/word/document.xml')"/>
  <!--<p:variable name="document-xml"  select="doc($document-path)"/>-->
  <!-- Validate HTML5 results here:  http://validator.w3.org/nu/ -->

  <!--<p:load>
    <p:with-option name="href" select="$document-path"/>
  </p:load>
  
  <p:xslt name="slops-extracted">
    <p:input port="stylesheet">
      <p:document href="docx-html-extract.xsl"/>
    </p:input>
    <p:with-param name="show-css" select="'yes'"/>
  </p:xslt>
  
  <p:xslt name="notes-arranged">
    <p:input port="stylesheet">
      <p:document href="handle-notes.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="scrubbed">
    <p:input port="stylesheet">
      <p:document href="scrub.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="collapsed">
    <p:input port="stylesheet">
      <p:document href="join-elements.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="mapped">
    <p:input port="stylesheet">
      <p:document href="zorba-map.xsl"/>
    </p:input>
  </p:xslt>

  <p:identity name="final"/>

  <p:xslt name="analysis">
    <p:input port="source">
      <p:pipe port="result" step="collapsed"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="html-analysis.xsl"/>
    </p:input>
  </p:xslt>
  
  
  <p:xslt name="plaintext">
    <p:input port="source">
      <p:pipe port="result" step="mapped"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="plaintext.xsl"/>
    </p:input>
  </p:xslt>-->

</p:declare-step>