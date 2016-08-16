<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:option name="docx-file-uri" required="true"/>
  
  <p:output port="result">
    <p:pipe port="result" step="final"/>
  </p:output>
  
  <p:output port="interimA" primary="false">
    <p:pipe port="result" step="slops-extracted"/>
  </p:output>
  <p:output port="interimB" primary="false">
    <p:pipe port="result" step="scrubbed"/>
  </p:output>
  <p:output port="interimC" primary="false">
    <p:pipe port="result" step="collapsed"/>
  </p:output>
  
  <p:serialization port="result" indent="true" omit-xml-declaration="true"/>
  <p:serialization port="interimA" indent="true" omit-xml-declaration="true"/>
  <p:serialization port="interimB" indent="true" omit-xml-declaration="true"/>
  <p:serialization port="interimC" indent="true" omit-xml-declaration="true"/>
  
  <p:variable name="document-path" select="concat('jar:',$docx-file-uri,'!/word/document.xml')"/>
  <!--<p:variable name="document-xml"  select="doc($document-path)"/>-->
  <!-- Validate HTML5 results here:  http://validator.w3.org/nu/ -->

  <p:load>
    <p:with-option name="href" select="$document-path"/>
  </p:load>
  
  <p:xslt name="slops-extracted">
    <p:input port="stylesheet">
      <p:document href="quickndirty2.xsl"/>
    </p:input>
    <p:with-param name="show-css" select="'yes'"/>
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
  
  <p:identity name="final"/>

</p:declare-step>