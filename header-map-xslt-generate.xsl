<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsw="http://coko.foundation/xsweet"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml">
  
  <xsl:output indent="yes"/>
  
<!-- Example input - all these have been identified as headers -
    <div class="grouped">
      <div class="level-group">
        <p style="font-size: 10pt; font-weight: bold"
          data-nominal-fontsize="10"
          data-count="1"
          data-average-length="18"
          data-average-run="1"
          data-always-caps="true"
          data-never-fullstop="true"/>
      </div>
      <div class="level-group">
        <p style="font-size: 10pt; font-style: italic; font-weight: bold"
          data-nominal-fontsize="10"
          data-count="10"
          data-average-length="67.2"
          data-average-run="1"
          data-always-caps="false"
          data-never-fullstop="true"/>
      </div>
      <div class="level-group">
        <p style="font-weight: bold"
          data-nominal-fontsize="12"
          data-count="3"
          data-average-length="27.67"
          data-average-run="3"
          data-always-caps="false"
          data-never-fullstop="true"/>
      </div>
    </div>
-->  
  
  <xsl:namespace-alias stylesheet-prefix="xsw" result-prefix="xsl"/>
  
  <xsl:template match="body">
    
    <!--       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:xsw="http://coko.foundation/xsweet"
      xmlns="http://www.w3.org/1999/xhtml"
      
    -->
    <xsw:stylesheet version="2.0"
      xpath-default-namespace="http://www.w3.org/1999/xhtml"
      exclude-result-prefixes="#all">
      
      <xsw:variable name="in">
        <xsl:copy-of select="div[@class='grouped']"/>
      </xsw:variable>


      <xsl:apply-templates select="div[@class='grouped']/div[@class='level-group']/*" mode="xslt-produce"/>

      <xsw:template match="node() | @*">
        <xsw:copy>
          <xsw:apply-templates select="node() | @*"/>
        </xsw:copy>
      </xsw:template>

    </xsw:stylesheet>
  </xsl:template>
  
  
  <!-- Template writes XSLT templates  -->
  
  <xsl:template match="div[@class='level-group']/*" mode="xslt-produce">
    <xsl:variable name="match">
      <xsl:value-of select="local-name()"/>
      <xsl:for-each select="@class">
        <xsl:text>[@class/tokenize(.,'\s*') = '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>']</xsl:text>
      </xsl:for-each>
      <xsl:for-each select="@style/tokenize(.,'\s*;\s*')">
        <xsl:text>[@style/tokenize(.,'\s*;\s*') = '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>']</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsw:template match="{$match}">
      <xsl:variable name="h-level" select="count(..|../following-sibling::div)"/>
      <xsl:attribute name="priority" select="101 - $h-level"/>
      <xsw:element name="h{$h-level}">
        <xsw:copy-of select="@*"/>
        <xsw:comment> was <xsw:value-of select="local-name()"/> </xsw:comment>
        <xsw:apply-templates/>
      </xsw:element>
    </xsw:template>
  </xsl:template>
  
</xsl:stylesheet>