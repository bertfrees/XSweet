<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsw="http://coko.foundation/xsweet"
  xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">

  <!-- Indent should really be no, but for testing. -->
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

  <!-- 
  Heuristic analysis is implemented as a series of filters.
  Each filter is implemented as an internal (XSLT) pipeline consuming
  the (temporary) result tree emitted by the previous filter.
  
  Filters process as follows:
  $p-proxies - Rewrites every 'p' element in the main document content.
  These proxies capture certain style or formatting info
  but also detect conditions such as end stops (periods) at the ends of lines,
  line length, or whether content is all caps.
  
  $p-proxies-measured - Consumes $p-proxies. Since one of the properties
  on paragraphs we are interested in is their 'stickiness' which can be
  indicated by the length of runs of paragraphs of that type. We can
  add that info to each p by passing them through a filter.
  
  $p-proxies-assimilated - Collapses 'p' elements in $p-proxies-measured into
  sets for further analysis (since ultimately elements will be mapped to headers in sets).
  
  $p-proxies-filtered - Removes 'p' elements from $p-proxies-assimilated that are
  judged *not* to be headers. Only headers are left.
  
  This is the critical phase since it determines how the mapping happens. It is
  controlled via mode  'keep-headers', which provides a template cascade that permits
  only p elements through if they are judged to be candidate headers.
  
  $p-proxies-grouped - Groups the proxies together by (header) level
  
  -->

  <xsl:param name="form" as="xs:string">xslt</xsl:param>


  <xsl:template match="/*">
    <body>
      <div class="grouped">
        <xsl:copy-of select="$p-proxies-grouped"/>
      </div>
      <div class="filtered">
        <xsl:copy-of select="$p-proxies-filtered"/>
      </div>
      <div class="assimilated">
        <xsl:copy-of select="$p-proxies-assimilated"/>
      </div>
      <div class="measured">
        <xsl:copy-of select="$p-proxies-measured"/>
      </div>
      <div class="digested">
        <xsl:copy-of select="$p-proxies"/>
      </div>

    </body>
  </xsl:template>


  <xsl:variable name="p-proxies">
    <xsl:apply-templates select="//div[@class = 'docx-body']/p" mode="digest"/>
  </xsl:variable>

  <xsl:variable name="p-proxies-measured">
    <xsl:for-each-group select="$p-proxies/*"
      group-adjacent="string-join((@class, @style, @data-all-caps), ' # ')">
      <xsl:for-each select="current-group()">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="data-run" select="count(current-group())"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:for-each-group>
  </xsl:variable>


  <xsl:variable name="p-proxies-assimilated">
    <!-- Consolidates info about individual p elements into sets -->
    <xsl:for-each-group select="$p-proxies-measured/*"
      group-by="string-join((@class, @style), ' # ')">
      <!-- Note: not sorting yet these are in arbitrary order. -->
      <!-- But we will still treat all-caps groups separate from others with the same properties. -->
      <xsl:for-each-group select="current-group()" group-by="@data-allcaps">
        <xsl:copy>
          <xsl:copy-of select="@class, @style"/>
          <xsl:attribute name="data-nominal-fontsize" select="xsw:nominal-size(.)"/>
          <xsl:attribute name="data-count"            select="count(current-group())"/>
          <xsl:attribute name="data-average-length"   select="format-number(sum(current-group()/@data-length) div count(current-group()), '0.##')"/>
          <xsl:attribute name="data-average-run"      select="sum(current-group()/@data-run) div count(current-group())"/>
          <xsl:attribute name="data-always-caps"      select="not(current-group()/@data-allcaps = 'false')"/>
          <xsl:attribute name="data-never-fullstop"   select="not(current-group()/@data-lastchar = '.')"/>
        </xsl:copy>
      </xsl:for-each-group>
    </xsl:for-each-group>
  </xsl:variable>

  <xsl:param as="xs:string" name="headerRegex">^h(ead|eader|eading)?\d\d?</xsl:param>

  <xsl:variable name="p-proxies-filtered">
    <xsl:variable name="named-headers" select="$p-proxies-assimilated/*[matches(@class, $headerRegex, 'i')]"/>

    <!-- If we have explicitly named headers, we'll keep em. -->
    <xsl:sequence select="$named-headers"/>

    <xsl:if test="empty($named-headers)">
      <xsl:apply-templates select="$p-proxies-assimilated/*" mode="keep-headers"/>
    </xsl:if>

  </xsl:variable>

  <!-- Never keep a p unless instructed otherwise -->
  <xsl:template mode="keep-headers" match="*"/>

  <!-- Always keep lines that never show full stops (hey what can go wrong) -->
  <xsl:template mode="keep-headers" priority="100" match="p[@data-never-fullstop = 'true']">
    <xsl:sequence select="."/>
  </xsl:template>

  <!-- Never a header if the commonest type of 'p' -->
  <xsl:template mode="keep-headers" priority="99"  match="p[not(../@data-count &gt; @data-count)]"/>

  <!-- Assuming it passes that test, keep it if it doesn't appear in large runs, is
       less than 120 chars long on average, and is bigger than *someone* -->
  <xsl:template mode="keep-headers" priority="98"  match="p[@data-average-run &lt; 4]
      [@data-nominal-font-size &gt; ../@data-nominal-font-size]
      [@data-average-length &lt;= 120]">
    <!-- Casual polling suggests char length for headers in English
         should be 25-40 on ave, compared to li (150-175ish) or p (over 1000) -->
    <xsl:sequence select="."/>
  </xsl:template>


  <xsl:variable name="p-proxies-grouped">
    <!-- Yes we know the XML syntax is harsh don't worry it's compiled away, this is very fast! -->
    <xsl:choose>
      <xsl:when test="$p-proxies-filtered/*[matches(@class, $headerRegex,'i')]">
        <xsl:call-template name="group-proxies-by-header-level"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="group-proxies-by-font"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="group-proxies-by-header-level">
    <xsl:for-each-group select="$p-proxies-filtered/*" group-by="replace(@class, '\D', '')">
      <xsl:sort select="current-grouping-key()" data-type="number" order="descending"/>

      <!-- If the data assigns header levels hell we'll take em. -->
      <!-- Notice the header level they come out isn't necessarily the stated header level (i.e. h2 might be level 3 if there is no level 2) -->
      <div class="hX">
        <xsl:sequence select="current-group()"/>
      </div>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template name="group-proxies-by-font">
    <!-- Alternatively we can sort and group by font properties including primarily size. -->
    <xsl:for-each-group select="$p-proxies-filtered/*" group-by="@data-nominal-fontsize">
      <xsl:sort select="current-grouping-key()" data-type="number"/>
      
      <xsl:for-each-group select="current-group()"
        group-by="tokenize(@style, '\s*;\s*') = 'font-style: italic'">
        <xsl:sort select="string(current-grouping-key())"/><!-- 'false' or 'true' -->

        <xsl:for-each-group select="current-group()"
          group-by="tokenize(@style, '\s*;\s*') = 'font-weight: bold'">

          <xsl:for-each-group select="current-group()" group-by="@data-always-caps">
            <xsl:sort select="string(current-grouping-key())"/><!-- likewise -->

            <!-- Now we've split and ordered them, they can be grouped. -->
            <div class="hX">
              <xsl:sequence select="current-group()"/>
            </div>
          </xsl:for-each-group>
        </xsl:for-each-group>
      </xsl:for-each-group>
    </xsl:for-each-group>
  </xsl:template>


<!-- Mode 'digest' is the initial (first) pass over the document, which boils down all paragraph-level 
  objects (they will be 'p' in the input) into informative little proxies of themselves.
  
  So for example
  <p style="font-size: 14pt">CHAPTER 1</p>
  
  becomes
  <p data-lastchar="1" data-allcaps="true" data-length="9" style="font-size: 14pt"/>

  Note that @style may be rewritten (only properties in which we will later be interested, are kept).
  
  Analysis proceeds from there in subsequent passes.

  -->

  <xsl:template match="p" mode="digest">
    <!-- lastchar shows the last (non-whitespace) character in the 'p'. -->
    <p data-lastchar="{replace(.,'^.*(\S)\s*$','$1')}" data-allcaps="{. = upper-case(.)}"
      data-length="{string-length(.)}">
      <xsl:copy-of select="@class"/>
      <xsl:apply-templates select="@style" mode="digest"/>
    </p>
  </xsl:template>

  <!-- In the desired order. -->
  <xsl:variable name="keepers" select="'font-size', 'font-style', 'font-weight', 'color'"/>

  <xsl:template mode="digest" match="p/@style">
    <xsl:variable name="props" select="tokenize(., '\s*;\s*')"/>

    <xsl:variable name="refined-style">
      <xsl:for-each select="$keepers[some $p in $props satisfies starts-with($p, .)]">
        <xsl:variable name="keeper" select="."/>
        <xsl:if test="position() gt 1">; </xsl:if>
        <xsl:value-of select="$props[starts-with(., $keeper)]"/>
      </xsl:for-each>
    </xsl:variable>

    <!-- Add an attribute iff there is a 'refined' value. -->
    <xsl:if test="matches($refined-style, '\S')">
      <xsl:attribute name="style" select="$refined-style"/>
    </xsl:if>

  </xsl:template>

  <xsl:function name="xsw:nominal-size" as="xs:decimal">
    <xsl:param name="p" as="element(p)"/>
    <!-- returns the numeric value if assigned, or 12 if not. -->
    <xsl:sequence
      select="(replace(tokenize($p/@style, '\s*;\s*')[starts-with(., 'font-size:')], '[^\.\d]', '')[. castable as xs:decimal], 12)[1] cast as xs:decimal"
    />
  </xsl:function>


</xsl:stylesheet>