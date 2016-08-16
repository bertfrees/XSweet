<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:coko="http://coko.foundation/xslt/wordml/util"
  exclude-result-prefixes="#all">
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="p[not(matches(.,'\S'))]"/>
  
  <xsl:template match="span[empty(@* except @style)]">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="@style"/>
  
  
</xsl:stylesheet>