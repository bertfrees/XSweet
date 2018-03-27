<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsw="http://coko.foundation/xsweet"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">
  
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
  
  <!-- XSweet: picks up URI substrings and renders them as (HTML) anchors with (purported or matched) links -->
<!-- Input: HTML Typescript or relatively clean HTML or XML. -->
<!-- Output: A copy, except that URIs now appear as live links (`a` elements). -->
  
  <xsl:template match="* | @* | processing-instruction() | comment()">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
 
<!-- tlds includes three-letter domain names but also anything that indicates
     an URL when followed by . (dot) e.g. .mil or .us ...  -->
  <xsl:variable name="tlds"         as="xs:string" expand-text="true">(com|org|net|gov|mil|edu|io|foundation|mx|us)</xsl:variable>
 
  <xsl:template match="text()">
    <!-- tokenize by splitting around spaces, plus leading punctuation characters  -->
    <xsl:analyze-string select="." regex="\p{{P}}$|\p{{P}}?\s+">
      <xsl:matching-substring>
        <xsl:value-of select="."/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
          <xsl:choose>
            <!-- skip file URIs -->
            <xsl:when test="matches(.,'file:/')">
              <xsl:value-of select="."/>
            </xsl:when>
            <xsl:when test="matches(.,('\.' || $tlds )) and (. castable as xs:anyURI)">
              <xsl:variable name="has-protocol" select="matches(.,'^(https?|ftp)://')"/>
              <a href="{'http://'[not($has-protocol)]}{.}">
                <xsl:value-of select="."/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
 
 
<!-- Old code wasn't working with a shorter TLD list but it could be okay now ... -->
  <xsl:variable name="urlchar"      as="xs:string" expand-text="true">[\w\-_]</xsl:variable>
  <xsl:variable name="extraURLchar" as="xs:string">[\w\-\$:;/:@&amp;=+,_]</xsl:variable>
  
  <xsl:variable name="domain"    as="xs:string" expand-text="true">({$urlchar}+\.)</xsl:variable>
  
  <xsl:variable name="tail"      as="xs:string" expand-text="true">(/|(\.(xml|html|htm|gif|jpg|jpeg|pdf|png|svg)))?</xsl:variable>
  <xsl:variable name="pathstep"  as="xs:string" expand-text="true">(/{$urlchar}+)</xsl:variable>
  
  <xsl:variable name="url-match" as="xs:string" expand-text="true">((http|ftp|https):/?/?)?{$domain}+{$tlds}{$pathstep}*{$tail}(\?{$extraURLchar}+)?</xsl:variable>
  
      <xsl:template match="text()" mode="regexing">
        
        <xsl:analyze-string select="." regex="{$url-match}">
          <!--(https?:)?(\w+\.)?(\w+)\.(\w\w\w)-->
      <xsl:matching-substring>
        <xsl:variable name="has-protocol" select="matches(.,'^https?://')"/>
        <a href="{'http://'[not($has-protocol)]}{regex-group(0)}">
          <xsl:value-of select="."/>
        </a>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <!--<xsl:template match="text()[matches(.,'^https?:')][string(.) castable as xs:anyURI][empty(ancestor::a)]">
    <a href="{encode-for-uri(.)}">
      <xsl:value-of select="."/>
    </a>
  </xsl:template>-->
    
</xsl:stylesheet>