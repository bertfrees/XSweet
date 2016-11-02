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
  
  <!-- Remove any 'p' element that is truly empty - nothing but whitespace, no elements.
       (Empty inline elements were stripped by generic logic: see scrub.xsl.) -->
  <!--<xsl:template match="p[not(matches(.,'\S'))][empty(*)]"/>-->
  
  <!-- Rewrite @style to remove properties duplicative of inherited properties -->
  
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
    
    <!-- Only if we have an item in sequence $significant (a sequence of strings) do we produce a new @style. --> 
    <xsl:if test="exists($significant)">
      <xsl:attribute name="style">
        <xsl:value-of select="$significant" separator="; "/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="span[empty(@style|@class)]">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="span">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="@style"/>
      <xsl:apply-templates/>
    </xsl:copy>
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
  
  <xsl:template match="b/b | i/i | u/u" priority="5">
    <xsl:apply-templates/>
  </xsl:template>
</xsl:stylesheet>