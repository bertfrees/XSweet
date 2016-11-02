<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:xsw="http://coko.foundation/xsweet"
  type="xsw:docx-extract-and-refine" name="docx-extract-and-refine">
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:option name="docx-file-uri" required="true"/>
  
  <p:output port="_Z_FINAL">
    <p:pipe port="_Z_FINAL" step="document-production"/>
  </p:output>
  
  <p:output port="_A_extracted" primary="false">
    <p:pipe port="_A_extracted" step="document-production"/>
  </p:output>
  <p:output port="_B_arranged" primary="false">
    <p:pipe port="_B_arranged" step="document-production"/>
  </p:output>
  <p:output port="_C1_scrubbed" primary="false">
    <p:pipe port="_C1_scrubbed" step="document-production"/>
  </p:output>
  <p:output port="_C2_trimmed"  primary="false">
    <p:pipe port="_C2_trimmed"  step="document-production"/>
  </p:output>
  <p:output port="_C3_folded"  primary="false">
    <p:pipe port="_C3_folded"  step="document-production"/>
  </p:output>
  <p:output port="_E_mapped" primary="false">
    <p:pipe port="_E_mapped" step="document-production"/>
  </p:output>
  <p:output port="_F_rinsed" primary="false">
    <p:pipe port="_F_rinsed" step="document-production"/>
  </p:output>
  <p:output port="_G_rewired" primary="false">
    <p:pipe port="_G_rewired" step="document-production"/>
  </p:output>
  
  <p:output port="_O_plaintext" primary="false">
    <p:pipe port="result" step="plaintext"/>
  </p:output>
  <p:output port="_O_analysis" primary="false">
    <p:pipe port="result" step="analysis"/>
  </p:output>
  
  <p:serialization port="_Z_FINAL"     indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_A_extracted" indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_B_arranged"  indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_C1_scrubbed" indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_C2_trimmed"  indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_C3_folded"   indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_E_mapped"    indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_F_rinsed"    indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_G_rewired"   indent="true" omit-xml-declaration="true"/>
  
  <p:serialization port="_O_plaintext" method="text" />
  <p:serialization port="_O_analysis"  indent="true" omit-xml-declaration="true"/>
  
  <p:import href="docx-document-production.xpl"/>
  
  <p:variable name="document-path" select="concat('jar:',$docx-file-uri,'!/word/document.xml')"/>
  <!--<p:variable name="document-xml"  select="doc($document-path)"/>-->
  <!-- Validate HTML5 results here:  http://validator.w3.org/nu/ -->

  <p:load>
    <p:with-option name="href" select="$document-path"/>
  </p:load>
  
  <xsw:docx-document-production name="document-production"/>
  
  <p:xslt name="analysis">
    <p:input port="source">
      <p:pipe port="_C3_folded" step="document-production"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="html-analysis.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="plaintext">
    <p:input port="source">
      <p:pipe port="_E_mapped" step="document-production"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="plaintext.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:xslt name="slops-extracted">
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