<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsw="http://coko.foundation/xsweet"
  exclude-result-prefixes="#all">
  
  <!-- Indent should really be no, but for testing. -->
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
  
  <xsl:param as="xs:string" name="show-css">yes</xsl:param>

  <xsl:variable name="endnotes-file" select="resolve-uri('endnotes.xml',document-uri(/))"/>
  
  <xsl:variable name="endnotes-doc"
    select="if (doc-available($endnotes-file)) then doc($endnotes-file) else ()"/>

  <!-- Reinstate footnotes handling when we have some. -->
  <!-- <xsl:variable name="footnotes-doc" select="document('footnotes.xml',/)"/>
       <xsl:key name="footnotes-by-id" match="w:footnote" use="@w:id"/> -->


  <!-- Turn $show-css to 'yes' to switch on $css-reflect. -->
  <!-- $show-css supplements the traversal with @style markers wherever certain
       kinds of formatting (e.g. font shift indicators including the spurious font shifts
       left in by word processors) are indicated in the text; it can be very noisy. -->
  <xsl:variable as="xs:boolean" name="css-reflect" select="$show-css='yes'"/>
  
  <!-- Run on 'document.xml' inside a .docx -->
  
  <!-- Note that unprefixed elements are in namespace http://www.w3.org/1999/xhtml --> 
  <xsl:template match="/w:document">
    <html>
      <head>
        <meta charset="UTF-8"/> 
      </head>
      <xsl:apply-templates select="w:body"/>
    </html>
  </xsl:template>
  
  <xsl:template match="w:body">
    <body>
      <div class="docx-body">
        <xsl:apply-templates select="w:p"/>
      </div>
      <div class="docx-endnotes">
        <xsl:apply-templates select="$endnotes-doc/*/w:endnote"/>
      </div>
      <!--<div class="docx-footnotes">
        <xsl:apply-templates select="$footnotes-doc/*/w:footnote"/>
      </div>-->
    </body>
  </xsl:template>

  <xsl:template match="w:endnote">
    <div class="docx-endnote" id="en{@w:id}">
      <xsl:apply-templates select="w:p"/>
    </div>
  </xsl:template>
  
  <xsl:template match="w:endnoteRef">
    <span class="endnoteRef"><xsl:comment> value to be generated </xsl:comment></span>
  </xsl:template>
  
  <!-- //w:p/w:pPr/w:pStyle -->
  <xsl:template match="w:p">
    <p>
      <!-- Copying any style declaration -->
      <xsl:for-each select="w:pPr/w:pStyle">
        <!-- strip periods, colons and non-XML name chars (this includes spaces) -->
        <xsl:variable name="safer" select="replace(@w:val,'[\.:\C]','')"/>
        <xsl:attribute name="class">
          <!-- Drop in a _ if the first character is not an initial name char in XML (or HTML NMTOKEN) -->
          <xsl:if test="matches($safer,'^\I')">_</xsl:if>
          <xsl:value-of select="$safer"/>
        </xsl:attribute>
      </xsl:for-each>
      
      <!-- Also promoting (some) properties to CSS @style -->
      <xsl:variable name="style">
        <xsl:apply-templates mode="render-css" select="w:pPr"/>
      </xsl:variable>
      <!-- Adding the attribute only when there is a value. -->
      <xsl:if test="matches($style,'\S')">
        <xsl:attribute name="style" select="$style"/>
      </xsl:if>
      <xsl:apply-templates select="*"/>
    </p>
  </xsl:template>
  
  <!-- Drop in default traversal -->
  <xsl:template match="w:pPr"/>
  
  <!-- Nothing to see here :-( keep going. -->
  <xsl:template match="w:hyperlink">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:function name="xsw:css-literal" as="xs:string?">
    <xsl:param name="run" as="element(w:r)"/>
    <xsl:if test="$css-reflect">
      <xsl:apply-templates select="$run/w:rPr" mode="render-css"/>
    </xsl:if>
  </xsl:function>
  
  <xsl:template match="w:r[matches(xsw:css-literal(.), '\S')]">
    <span style="{normalize-space(xsw:css-literal(.))}">
      <xsl:call-template name="format-components"/>
    </span>
  </xsl:template>
  
  <xsl:template match="w:r">
    <xsl:call-template name="format-components"/>
  </xsl:template>
  
  <xsl:template name="format-components">
    <xsl:for-each-group select="* except w:rPr" group-adjacent="xsw:has-format(.)">
      <!--  current-grouping-key() is always true for some elements, and true for all when
              there is no w:rPr. The effect of the group-adjacent is to "bundle" elements
              to be wrapped in formatting, or not, depending on the element type. For example,
              footnote callouts that are expanded to footnotes are not wrapped, lest formatting
              for the callout be wrapped around the footnote in the result. -->
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <!-- when the stuff is to be formatted, traverse to w:rPr carrying the group through. -->
          <xsl:apply-templates select="../w:rPr">
            <xsl:with-param name="contents" tunnel="yes">
              <xsl:apply-templates select="current-group()"/>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="current-group()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="w:endnoteReference" priority="3">
    <!-- All we have to go on is the @w:id ... so we take it -->
    <a class="endnoteReference" href="#en{@w:id}">
      <xsl:apply-templates/>
      <xsl:if test="empty(node())">
        <xsl:comment> (generated) </xsl:comment>
      </xsl:if>
    </a>
  </xsl:template>

  <!-- Again overriding the default behavior for w:r/*, to the same effect.
       Check and switch on when we do footnotes. 
       See line 50 or so (template @match='w:body') -->
  <!--<xsl:template match="w:footnoteReference" priority="3">
    <div class="footnote_fetched">
      <xsl:apply-templates select="key('footnotes-by-id',@w:id,$footnotes-doc)"/>
    </div>
  </xsl:template>-->
  
  <!-- w:rPr works by pushing its contents through its children one at a time
       in sibling succession, given them each an opportunity to wrap the results. -->
  <!-- Individual templates matching w:rPr/* provide for the particular mappings into HTML. -->
  <xsl:template match="w:rPr">
    <xsl:param name="contents" select="()" tunnel="yes"/>
    <xsl:apply-templates select="*[1]">
      <!-- Tunneling <xsl:with-param name="contents" select="$contents"/>-->
    </xsl:apply-templates>
    <xsl:if test="empty(*)">
      <xsl:sequence select="$contents"/>
    </xsl:if>
  </xsl:template>

  
  <!-- Look ma! no modes! children of w:rPr perform a *sibling traversal*
       in order to wrap themselves sequentially in HTML (inline) wrappers. -->
  <!-- xsl:template/@priority must be used to assure a better match than the default. -->
  
  <!-- By default we name an element after its tag in Word ML (w: namespace). -->
  <xsl:template match="w:rPr/*">
    <xsl:element name="{local-name()}">
      <xsl:call-template name="tuck-next"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template priority="4" match="w:rPr/w:bCs">
    <!-- https://msdn.microsoft.com/en-us/library/documentformat.openxml.wordprocessing.boldcomplexscript(v=office.14).aspx -->
    <!-- But note this template is overridden below for most w:bCs as we consider it redundant when already bold. -->
    <b class="bCs">
      <xsl:call-template name="tuck-next"/>
    </b>
  </xsl:template>

  <xsl:template priority="5" match="w:u[not(matches(@w:val,'\S'))]">
    <xsl:call-template name="tuck-next"/>
  </xsl:template>
    
  <!-- When there's an inline style, announce it. -->
  <xsl:template priority="5" match="w:rPr/w:rStyle">
    <span class="{@w:val}">
      <xsl:call-template name="tuck-next"/>
    </span>
  </xsl:template>
  
  <!-- This should match any formatting we don't wish to see among wrapped inline elements;
       note that the same formatting properties may be detected in/by CSS reflection instead. -->
  <xsl:template priority="5"
    match="w:rPr/w:sz | w:rPr/w:szCs | w:rPr/w:rFonts | w:rPr/w:color | w:rPr/w:shd | w:rPr/w:smallCaps |
    w:bCs[exists(../w:b)] ">
    <!-- Just do the next one. -->
    <xsl:call-template name="tuck-next"/>
  </xsl:template>

  <!-- Called to effect the sibling traversal among w:rPrr/* elements. -->
  <xsl:template name="tuck-next">
    <xsl:param name="contents" select="()" tunnel="yes"/>
    <!-- If there's more format, keep going. -->
    <xsl:apply-templates select="following-sibling::*[1]"/>
    <!-- If not go back to get the text. -->
    <xsl:if test="empty(following-sibling::*)">
      <xsl:sequence select="$contents"/>
    </xsl:if>
  </xsl:template>

  <xsl:function name="xsw:has-format" as="xs:boolean">
    <xsl:param name="n" as="node()"/>
    <xsl:variable name="n-is-callout" as="xs:boolean">
      <xsl:apply-templates select="$n" mode="is-callout"/>
    </xsl:variable>
    <xsl:sequence select="exists($n/../w:rPr) and not($n-is-callout)"/>
  </xsl:function>
  
  <!-- Since we don't want to see these wrapped in formatting ...  -->
  <xsl:template match="w:footnoteReference | w:endnoteReference" mode="is-callout" as="xs:boolean">
    <xsl:sequence select="true()"/>
  </xsl:template>
  
  <xsl:template match="*" mode="is-callout" as="xs:boolean">
    <xsl:sequence select="false()"/>
  </xsl:template>
  

  <xsl:template match="*" mode="render-css"/>
  
  <xsl:template mode="render-css" match="w:pPr | w:rPr">
    <xsl:value-of separator="; ">
      <xsl:apply-templates mode="#current"/>
    </xsl:value-of><!---->
  </xsl:template>
  
  <!-- Inside w:pPr -->
  <xsl:template mode="render-css" match="w:ind" as="xs:string*">
    <xsl:apply-templates mode="#current" select="@w:left | @w:right | @w:firstLine | @w:hanging"/>
  </xsl:template>

  <xsl:template mode="render-css" match="w:spacing" as="xs:string*">
    <xsl:apply-templates mode="#current" select="@w:before | @w:after"/>
  </xsl:template>
  
  <xsl:template mode="render-css" match="w:ind/@* | w:spacing/@*">
    <xsl:value-of>
      <xsl:apply-templates mode="css-property" select="."/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select=". div 20"/>
      <xsl:text>pt</xsl:text>
    </xsl:value-of>
  </xsl:template>
  
  <xsl:template priority="2" mode="render-css" match="w:ind/@w:hanging">
    <xsl:value-of>
      <xsl:text>text-indent: -</xsl:text>
      <xsl:value-of select=". div 20"/>
      <xsl:text>pt</xsl:text>
    </xsl:value-of>
    <xsl:value-of>
      <xsl:text>padding-left: </xsl:text>
      <xsl:value-of select=". div 20"/>
      <xsl:text>pt</xsl:text>
    </xsl:value-of>
  </xsl:template>


  <xsl:template mode="css-property" match="w:spacing/@w:before">margin-top</xsl:template>
  <xsl:template mode="css-property" match="w:spacing/@w:after" >margin-bottom</xsl:template>
  <xsl:template mode="css-property" match="w:ind/@w:left"      >margin-left</xsl:template>
  <xsl:template mode="css-property" match="w:ind/@w:right"     >margin-right</xsl:template>
  <xsl:template mode="css-property" match="w:ind/@w:firstLine" >text-indent</xsl:template>
  
  <xsl:template mode="render-css" as="xs:string" match="w:rFonts[exists(@w:ascii|@w:cs|@w:hAnsi|@w:eastAsia)]">
    <xsl:value-of>
      <xsl:text>font-family: </xsl:text>
      <xsl:value-of select="(@w:ascii,@w:cs, @w:hAnsi, @w:eastAsia)[1]"/>
    </xsl:value-of>
  </xsl:template>
  
  <xsl:template mode="render-css" as="xs:string?" match="w:szCs[.=(../w:sz)]"/>
  
  <!-- Font size for complex scripts (szCs) is just noise. -->
  <xsl:template mode="render-css" as="xs:string?" match="w:szCs"/>
  
  <xsl:template mode="render-css" as="xs:string" match="w:sz">
    <xsl:value-of>
      <xsl:text>font-size: </xsl:text>
      <xsl:value-of select="@w:val div 2"/>
      <xsl:text>pt</xsl:text>
    </xsl:value-of>
  </xsl:template>
  
  <xsl:template mode="render-css" as="xs:string" match="w:smallCaps">
    <xsl:text>font-variant: small-caps</xsl:text>
  </xsl:template>
  
  <xsl:template mode="render-css" as="xs:string" match="w:color">
    <xsl:value-of>
      <xsl:text>color: </xsl:text>
      <xsl:value-of select="@w:val/replace(.,'^\d','#$0')"/>
    </xsl:value-of>
  </xsl:template>
  
</xsl:stylesheet>