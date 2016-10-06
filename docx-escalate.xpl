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
  
  <p:output port="_D_in" primary="false">
    <p:pipe port="_D_tightened" step="document-production"/>
  </p:output>
  <p:output port="_E_digested" primary="false">
    <p:pipe port="result" step="digest-paragraphs"/>
  </p:output>
  <!--
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
  <p:serialization port="_Z_FINAL"     indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_E_digested"     indent="true" omit-xml-declaration="true"/>
  <p:serialization port="_D_in" indent="true" omit-xml-declaration="true"/>
  
  <p:import href="docx-document-production.xpl"/>
  
  <p:variable name="document-path" select="concat('jar:',$docx-file-uri,'!/word/document.xml')"/>
  <!--<p:variable name="document-xml"  select="doc($document-path)"/>-->
  <!-- Validate HTML5 results here:  http://validator.w3.org/nu/ -->

  <p:load>
    <p:with-option name="href" select="$document-path"/>
  </p:load>
  
  <xsw:docx-document-production name="document-production"/>
  
  <!-- Promotes detectable paragraph-wide styles into CSS on @style -->
  <p:xslt name="normalize-paragraphs">
    <p:input port="source">
      <p:pipe port="_D_tightened" step="document-production"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="collapse-paragraphs.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>
  
  <p:xslt name="digest-paragraphs">
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0"
          xmlns="http://www.w3.org/1999/xhtml"
          xpath-default-namespace="http://www.w3.org/1999/xhtml"
          exclude-result-prefixes="#all">
          
          <xsl:template match="/">
            <ul>
              <xsl:apply-templates select="//div[@class='docx-body']/p" mode="digest"/>
            </ul>
          </xsl:template>
          
          <xsl:template match="p" mode="digest">
            <li>
              <xsl:text>p</xsl:text>
              <xsl:value-of select="@class/concat('.',.)"/>
              <xsl:value-of select="@style/concat(' { ',., ' }')"/>
            </li>
          </xsl:template>
        </xsl:stylesheet>
        
      </p:inline>
    </p:input>
  </p:xslt>
  
</p:declare-step>