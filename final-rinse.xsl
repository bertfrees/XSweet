<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsw="http://coko.foundation/xsweet"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml">

  <!-- Removes redundant tagging from HTML based on @style analysis, element type e.g. redundant b, i, u etc. -->
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@style">
    <xsl:variable name="here" select=".."/>
    <!-- Any CSS properties not declared on an ancestor are significant. -->
    <xsl:variable name="significant" as="xs:string*">
      <xsl:for-each select="tokenize(.,'\s*;\s*')">
        <xsl:variable name="prop" select="."/>
        <xsl:variable name="propName" select="replace($prop,':.*$','')"/>
        <!-- the property is redundant if the same as the same property on the closest element with the property -->
        <xsl:variable name="redundant" select="$here/ancestor::*[contains(@style,$propName)][1]/tokenize(@style,'\s*;\s*') = $prop"/>
        <xsl:if test="not($redundant)">
          <xsl:sequence select="$prop"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:if test="exists($significant)">
      <xsl:attribute name="style">
        <xsl:value-of select="$significant" separator="; "/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="span">
    <xsl:variable name="newStyle">
      <span>
        <xsl:apply-templates select="@style"/>
      </span>
    </xsl:variable>
    <xsl:choose><!-- We only copy the span if it has a class -->
      <xsl:when test="matches(@class,'\S')">
        <xsl:next-match/>
      </xsl:when>
      <xsl:when test="exists($newStyle/span/@style)"><!-- or if it has a style after reduction -->
        <xsl:next-match/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="b[ancestor::*[contains(@style,'font-weight')][1]/tokenize(@style,'\s*;\s*') = 'font-weight: bold']">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="i[ancestor::*[contains(@style,'font-style')][1]/tokenize(@style,'\s*;\s*') = 'font-style: italic']">
    <xsl:apply-templates/>  
  </xsl:template>
  
  <xsl:template match="u[ancestor::*[contains(@style,'text-decoration')][1]/tokenize(@style,'\s*;\s*') = 'text-decoration: underline']">
    <xsl:apply-templates/>  
  </xsl:template>
  
  <xsl:template match="b/b | i/i | u/u | b[not(matches(.,'\S'))] | i[not(matches(.,'\S'))] | u[not(matches(.,'\S'))]" priority="5">
    <xsl:apply-templates/>
  </xsl:template>
</xsl:stylesheet>