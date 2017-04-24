<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
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
  
  <!-- Strip these, retaining their contents. -->
  <xsl:template match="position | iCs | lang | vertAlign | noProof">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Matching b, i and u if they have only whitespace text content
       this includes <b> </b> and <b><tab/></b> -->
       
  
  <xsl:template match="caps | strike">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="caps//text()">
    <xsl:value-of select="upper-case(.)"/>
  </xsl:template>
  
  <!-- Remove any 'p' element that has nothing but whitespace. -->
  <!--<xsl:template match="p[not(matches(.,'\S'))]"/>-->
  
  <!-- We're going to keep 'tab' although invalid in the target - since it is too early to expand (presumably to tab/ws) -->
  <xsl:template match="tab" priority="99">
    <tab/>
  </xsl:template>
  
  <!-- Inline elements that are truly empty can be stripped. -->
  <xsl:template match="p//*[empty(.//* except (.//tab|.//span|.//b|.//i|.//u)) and not(string(.))]">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Matching b, i and u if they have only whitespace text content w/ other formatting properties
       this includes <b> </b> and <b><tab/></b> -->
  
  
  <xsl:template priority="5" match="img | br | hr">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Otherwise @style is rewritten to normalize its CSS.
       Note we can get 'naked' spans (without @class or @style) which may require later cleanup. -->
  
  <xsl:template match="@style">
    <!-- Acquire properties by breaking at ';\s*' (semi-colon) and keeping only those that match
         a regex (requiring a colon followed by non-ws). -->
    <xsl:variable name="properties" select="tokenize(.,';\s*')[matches(.,':\s*\S')]"/>
    
    <xsl:variable name="inherited-font-family" select="../ancestor::*/tokenize(@style,'\s*;\s*') (: a CSS property on an ancestor :)
      (: declaring font-family :) [matches(.,'^font-family:')]
      (: first one available happens to be the closest :) [1]"/>
    
    <xsl:variable name="included-properties" select="$properties[not(.=$inherited-font-family)]"/>
    <!-- Doesn't handle just any CSS; assumes single space after ':' is normal. -->
    <!-- Grouping by value serves to remove duplicates. -->
    <xsl:if test="exists($included-properties)">
      <xsl:attribute name="style">
        <xsl:for-each-group select="$included-properties" group-by=".">
          <!-- And also permits us to sort them. -->
          <xsl:sort select="."/>
          <xsl:if test="not(position() eq 1)">; </xsl:if>
          <xsl:value-of select="."/>
        </xsl:for-each-group>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>