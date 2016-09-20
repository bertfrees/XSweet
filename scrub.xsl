<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:coko="http://coko.foundation/xslt/wordml/util"
  exclude-result-prefixes="#all">
  
  <!-- Indent should really be no, but for testing. -->
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
  
  <!-- Copy everything by default. -->
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Strip these, retaining their contents. -->
  <xsl:template match="position | iCs | lang | vertAlign | noProof">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Remove any 'p' element that has nothing but whitespace. -->
  <xsl:template match="p[not(matches(.,'\S'))]"/>

  <!-- And likewise drop any descendant of p that must have content to
       be meaningful. -->
  <xsl:template match="p//*[not(matches(.,'\S'))]">
    <xsl:if test="exists(descendant-or-self::img | descendant-or-self::br | descendant-or-self::hr)">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  <!-- Remove any 'span' element that has nothing but @style
       (but retain its contents). -->
  <!--<xsl:template match="span[empty(@* except @style)]">
    <xsl:apply-templates/>
  </xsl:template>-->
  
  <!-- @style is rewritten to normalize its CSS. -->
  <xsl:template match="@style">
    <xsl:variable name="properties" select="tokenize(.,';\s*')"/>
    <!-- Doesn't handle just any CSS; assumes single space after ':' is normal. -->
    <!-- Grouping by value serves to remove duplicates. -->
    <xsl:attribute name="style">
      <xsl:for-each-group select="$properties" group-by=".">
        <!-- And also permits us to sort them. -->
        <xsl:sort select="."/>
        <xsl:if test="not(position() eq 1)">; </xsl:if>
        <xsl:value-of select="."/>
      </xsl:for-each-group>
    </xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>