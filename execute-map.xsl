<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  
  <xsl:variable name="mapping-specs">
    <!-- You can leave off any of @element, @class or @style.
      @class will be decomposed (tokenized) and compared by class assignment.
      (All given classes must be matched for a match, so class="mixlix bronco" is equivalent to CSS .mixlix.bronco )
      On @style, CSS will be decomposed and matched by property-value pairs.
      Only elements matching all given criteria (including all CSS properties, compared as literals) -->
    <match element="p" class="mixlix" style="font-style: 10px; font-family: Palatino">
      <h1/>
    </match>
  </xsl:variable>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Assemble eligible nodes by intersecting massive key retrievals across $map-specs
    from element types. ! :-) -->
  
  
</xsl:stylesheet>