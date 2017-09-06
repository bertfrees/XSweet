<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- Requests a tool use HTML5 serialization rules. -->
  <xsl:output method="html" html-version="5" indent="no"/>
  
  <!-- Otherwise, just copies. -->
  <xsl:mode on-no-match="deep-copy"/>
  
</xsl:stylesheet>