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
  
  
  <xsl:template match="/">
    <body>
      <div class="assimilated">
        <xsl:for-each-group select="$p-proxies-measured" group-by="string-join((@class,@style),' # ')">
          <!-- . is the first member of the group -->
            <xsl:copy>
              <xsl:copy-of select="@class, @style"/>
              <xsl:attribute name="data-average-run"    select="sum(current-group()/@data-run) div count(current-group())"/>
              <xsl:attribute name="data-always-caps"    select="not(current-group()/@data-allcaps='false')"/>
              <xsl:attribute name="data-never-fullstop" select="not(current-group()/@data-last-char = '.')"/>
            </xsl:copy>
        </xsl:for-each-group>
      </div>
    <div class="measured">
      <xsl:copy-of select="$p-proxies-measured"/>
    </div>
      <div class="digested">
        <xsl:copy-of select="$p-proxies"/>
      </div>
      
    </body>
  </xsl:template>
  
  <xsl:variable name="p-proxies" as="element(p)*">
    <xsl:apply-templates select="//div[@class='docx-body']/p" mode="digest"/>
  </xsl:variable>

  <xsl:variable name="p-proxies-measured" as="element()*">
    <xsl:for-each-group select="$p-proxies" group-adjacent="string-join((@class,@style),' # ')">
      <xsl:for-each select="current-group()">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="data-run" select="count(current-group())"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:for-each-group>
  </xsl:variable>
  

  <xsl:template match="p" mode="digest">
    <!-- lastchar shows the last (non-whitespace) character in the 'p'. -->
    <p data-lastchar="{replace(.,'^.*(\S)\s*$','$1')}" data-allcaps="{. = upper-case(.)}">
      <xsl:copy-of select="@class"/>
      <xsl:apply-templates select="@style" mode="refine"/>
    </p>
  </xsl:template>
  
  <!-- In the desired order. -->
  <xsl:variable name="keepers" select="'font-size','font-style','font-weight','color'"/>
  
  <xsl:template mode="refine" match="p/@style">
    <xsl:variable name="props" select="tokenize(.,'\s*;\s*')"/>
    
    <xsl:variable name="refined-style">
    <xsl:for-each select="$keepers[some $p in $props satisfies starts-with($p,.)]">
      <xsl:variable name="keeper" select="."/>
      <xsl:if test="position() gt 1">; </xsl:if>
      <xsl:value-of select="$props[starts-with(.,$keeper)]"/>
    </xsl:for-each>
    </xsl:variable>
    
    <xsl:if test="matches($refined-style,'\S')">
      <xsl:attribute name="style" select="$refined-style"/>
    </xsl:if>
    
  </xsl:template>

</xsl:stylesheet>