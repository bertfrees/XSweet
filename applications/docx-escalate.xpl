<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:xsw="http://coko.foundation/xsweet"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  type="xsw:docx-escalate" name="docx-escalate">
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:option name="docx-file-uri" required="true"/>
  
  <p:output port="_Z_FINAL">
    <p:pipe port="result" step="final"/>
  </p:output>
  
  <p:output port="_A_in" primary="false">
    <p:pipe port="_Z_FINAL" step="document-production"/>
  </p:output>
  <p:output port="_M_ready" primary="false">
    <p:pipe port="result" step="ready"/>
  </p:output>
  <p:output port="_N_digested" primary="false">
    <p:pipe port="result" step="digest-paragraphs"/>
  </p:output>
  <p:output port="_O_with_headers" primary="false">
    <p:pipe port="result" step="omg-apply-the-header-mapping-xslt"/>
  </p:output>
  <p:output port="_P1_lists" primary="false">
    <p:pipe port="result" step="promote-lists"/>
  </p:output>
  <p:output port="_P2_lists" primary="false">
    <p:pipe port="result" step="promote-lists"/>
  </p:output>
  <p:output port="_P3_lists" primary="false">
    <p:pipe port="result" step="refine-lists"/>
  </p:output>
  
  <p:output port="_O_escalator-xslt" primary="false">
    <p:pipe port="result" step="escalator-xslt"/>
  </p:output>

  <p:serialization port="_A_in"                indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_M_ready"          indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_N_digested"       indent="true"/>
  <p:serialization port="_O_with_headers"   indent="true"/>
  <p:serialization port="_P1_lists"         indent="true"/>
  <p:serialization port="_P2_lists"         indent="true"/>
  <p:serialization port="_P3_lists"         indent="true"/>
  <p:serialization port="_O_escalator-xslt" indent="true"/>
  <p:serialization port="_Z_FINAL"          indent="true" omit-xml-declaration="true"/>
  
  <p:import href="docx-extract/docx-document-production.xpl"/>
  
  <p:variable name="document-path" select="concat('jar:',$docx-file-uri,'!/word/document.xml')"/>
  <!--<p:variable name="document-xml"  select="doc($document-path)"/>-->
  <!-- Validate HTML5 results here:  http://validator.w3.org/nu/ -->

  <p:load>
    <p:with-option name="href" select="$document-path"/>
  </p:load>
  
  <xsw:docx-document-production name="document-production"/>
  
  <!-- Promotes detectable paragraph-wide styles into CSS on @style -->
  
  <p:identity name="ready">
    <p:input port="source">
      <p:pipe port="_E_folded" step="document-production"/>
    </p:input>
  </p:identity>
  
  <!-- To produce the header mapping xslt we go back to the normalized source:
       first we build an analysis table -->
  <p:xslt name="digest-paragraphs">
    <p:input port="stylesheet">
      <p:document href="header-promote/digest-paragraphs.xsl"/>
    </p:input>
  </p:xslt>
  
  <!-- Then we generate an XSLT stylesheet from it -->
  <p:xslt name="escalator-xslt">
    <p:input port="stylesheet">
      <p:document href="header-promote/make-header-escalator-xslt.xsl"/>
    </p:input>
  </p:xslt>

  <!-- Now we go back to 'ready' -->
  <p:identity>
    <p:input port="source">
      <p:pipe port="result" step="ready"/>
    </p:input>
  </p:identity>
  
  <!-- This is the loop! where we apply the stylesheet we have generated -->
  <p:xslt name="omg-apply-the-header-mapping-xslt">
    <p:input port="stylesheet">
      <p:pipe port="result" step="escalator-xslt"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="infer-lists"/>-->
  <p:xslt name="infer-lists">
    <p:input port="stylesheet">
      <p:document href="list-promote/mark-lists.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="promote-lists">
    <p:input port="stylesheet">
      <p:document href="list-promote/nest-lists.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="refine-lists">
    <p:input port="stylesheet">
      <p:document href="list-promote/refine-lists.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="cleanup">
    <p:input port="stylesheet">
      <p:document href="html-polish/final-rinse.xsl"/>
    </p:input>
  </p:xslt>
  
  
  
  <p:xslt name="rewired">
    <p:input port="stylesheet">
      <p:document href="css-abstract/css-abstract.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>
  
  <!--<p:xslt name="">
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0"
          xmlns="http://www.w3.org/1999/xhtml"
          xpath-default-namespace="http://www.w3.org/1999/xhtml"
          exclude-result-prefixes="#all"/>
      </p:inline>
    </p:input>
  </p:xslt>-->
  
  
  
</p:declare-step>