<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsw="http://coko.foundation/xsweet"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">
  
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
  
<!-- XSweet: A demo of an "ad hoc" filter for a particular workflow or process. -->
<!-- Input: HTML Typescript -->
<!-- Output: A copy, with modifications. -->
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Deprecating these ... since @style info is factored out ...
    
    <xsl:template match="span[@style='font-family: Helvetica'][empty(@class)]">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="@style[.='font-family: Helvetica']"/> -->
  
  <xsl:template match="text()[matches(.,'^https?:')][string(.) castable as xs:anyURI][empty(ancestor::a)]">
    <a href="{encode-for-uri(.)}">
      <xsl:value-of select="."/>
    </a>
  </xsl:template>
    
</xsl:stylesheet>