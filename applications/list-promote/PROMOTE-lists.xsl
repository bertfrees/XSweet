<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsw="http://coko.foundation/xsweet"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">

  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
  
  <!-- In lieu of suppressXsltNamespaceCheck:on, matching the non-existent HTML 'x'
       element suppresses a runtime warning. -->
  <xsl:template match="/x"/>
  
  <xsl:variable name="transformation-sequence">
    <xsw:transform version="2.0">mark-lists.xsl</xsw:transform>
    <xsw:transform version="2.0">itemize-lists.xsl</xsw:transform>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:variable name="source" select="."/>
    <xsl:iterate select="$transformation-sequence/*">
      <xsl:param name="sourcedoc" select="$source" as="document-node()"/>
      <xsl:on-completion select="$sourcedoc"/>
      <xsl:next-iteration>
        <xsl:with-param name="sourcedoc">
          <xsl:apply-templates select=".">
            <xsl:with-param name="sourcedoc" select="$sourcedoc"/>
          </xsl:apply-templates>
        </xsl:with-param>
      </xsl:next-iteration>
    </xsl:iterate>
  </xsl:template>
  
  <xsl:template match="xsw:transform">
    <xsl:param    name="sourcedoc" as="document-node()"/>
    <xsl:variable name="xslt"      select="."/>
    <xsl:variable name="runtime"   select="map {
      'xslt-version'        : xs:decimal($xslt/@version),
      'stylesheet-location' : string($xslt),
      'source-node'         : $sourcedoc }" />
    <!-- The function returns a map; primary results are under 'output'
         unless a base output URI is given
         https://www.w3.org/TR/xpath-functions-31/#func-transform -->
    <xsl:sequence select="transform($runtime)?output"/>
  </xsl:template>
  
</xsl:stylesheet>