<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsw="http://coko.foundation/xsweet"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">
  
  <!-- Indent should really be no, but for testing. -->
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
  
  <!-- Copy everything by default. -->
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
<!-- Rewrites CSS where p has all its contents in a single branch; display semantics
     of that branch are expressed in CSS and overwrite the p element's given @style.
     [examples]
  
  <p style="color: #000020; font-size: 13.5pt; margin-left: 72pt">
    <span style="color: #000020; font-size: 13.5pt">
      <i>All wholesome food is caught without a net or a trap.</i>
    </span>
  </p>
  
  should be rewritten
  
  <p style="color: #000020; font-size: 13.5pt; font-style: italic; margin-left: 72pt">All wholesome food is caught without a net or a trap.</p>

Note the properties overwritten on descendants are removed, and the 'i' element is rewritten as
font-style='italic'.

Note the following mappings:
  i - font-style='italic'.
  b - font-weight='bold'.
  u - text-decoration='underline'.

  -->
  
  
</xsl:stylesheet>