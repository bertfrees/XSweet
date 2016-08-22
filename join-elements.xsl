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
  
  <xsl:template match="p">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="collapse-ilk"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="collapse-ilk">
    <xsl:param name="among" select="node()"/>
    <xsl:for-each-group select="$among" group-adjacent="coko:node-hash(.)">
      <xsl:for-each select="current-group()[1]/self::*">
        <!-- In the element case, splice in an element. -->
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:call-template name="collapse-ilk">
            <xsl:with-param name="among" select="current-group()/node()"/>
          </xsl:call-template> 
        </xsl:copy>
      </xsl:for-each>
      <!-- Splice in anything not an element. -->
      <xsl:copy-of select="current-group()[empty(self::*)]"/>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:function name="coko:node-hash" as="xs:string">
    <xsl:param name="n" as="node()"/>
    <xsl:value-of separator="|">
      <xsl:apply-templates select="$n" mode="hash"/>
    </xsl:value-of>
  </xsl:function>
  
  <!-- Note we're going to collapse things with the same (local) name
       though in different namespaces - this ain't lookin to be namespace safe -->
  <xsl:template match="*" mode="hash">
    <xsl:value-of select="local-name()"/>
    <xsl:for-each select="@*">
      <xsl:sort select="local-name()"/>
      <xsl:if test="position() ne 1"> ::: </xsl:if>
      <xsl:apply-templates mode="#current" select="."/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="@*" mode="hash">
    <xsl:value-of select="local-name(),." separator="="/>
  </xsl:template>
 
  <!-- These guys should never collapse so their hash is always unique -->
  <xsl:template match="div | p" mode="hash">
    <xsl:value-of select="local-name(.)"/>
    <xsl:value-of select="generate-id(.)"/>
  </xsl:template>
  
  <xsl:template match="text() | comment() | processing-instruction()" mode="hash"/>

  
</xsl:stylesheet>