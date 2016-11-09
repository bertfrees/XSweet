<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsw="http://coko.foundation/xsweet"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">
  
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
  
<!-- Stylesheet to rewrite style and class on HTML
     via a template cascade - i.e., more than a single transformation
     can be performed over a single element.
    
    xsw:classes - xs:string* - tokenizes @class for handling
     xsw:hasClass - xs:boolean - true iff a value of @class matches

Possible mods wanted?

     demonstrations of
     add, remove, replace class
     
     add style property
     remove style property
     
     cast style or combination of style properties into class

Ultimately this could support a little language kinda like:

where { font-size: 18pt } .FreeForm
  remove { font-size } .FreeForm
  add    { color: red } .FreeFormNew

<where>
  <match>
    <style>font-size: 18pt</style>
    <class>FreeForm</class>
  </match>
  <remove>
    <style>font-size</style>
    <class>FreeForm</class>
  </remove>
  <add>
    <class>FreeFormNew</class>
    <style>color: red</style>
  </add>
</where>

providing mappings across @class (considered as NMTOKENS) and @style (considered as CSS property sets)

  -->



  <!-- Implementation of rule given above. -->
  
  <xsl:template match="key('elements-by-propertyValue','font-size: 18pt')[. intersect key('elements-by-class','Freeform')]" priority="12">
    <xsl:variable name="ran">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:for-each select="$ran/*">
      <xsl:copy>
        <xsl:copy-of select="@* except (@style | @class)"/>
        <xsl:call-template name="tweakStyle">
          <xsl:with-param name="removeProperties" select="'font-size'"/>
          <xsl:with-param name="addPropertyValues" select="'color: red'"></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="tweakClass">
          <xsl:with-param name="add">FreeFormNew</xsl:with-param>
          <xsl:with-param name="remove">FreeForm</xsl:with-param>
        </xsl:call-template>
        
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="key('elements-by-property','margin-bottom')" priority="11">
    <xsl:variable name="ran">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:for-each select="$ran/*">
      <xsl:copy>
        <xsl:copy-of select="@* except @style"/>
        <xsl:call-template name="tweakStyle">
          <xsl:with-param name="removeProperties" select="'margin-bottom'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="key('elements-by-propertyValue','font-family: Arial Unicode MS')" priority="10.5">
    <xsl:variable name="ran">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:for-each select="$ran/*">
      <xsl:copy>
        <xsl:copy-of select="@* except (@class | @style)"/>
        <xsl:call-template name="tweakStyle">
          <xsl:with-param name="removeProperties">font-family</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="tweakClass">
          <!--<xsl:with-param name="add">sans-serif</xsl:with-param>-->
        </xsl:call-template>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="key('elements-by-propertyValue','text-indent: 36pt')" priority="10">
    <xsl:variable name="ran">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:for-each select="$ran/*">
      <xsl:copy>
        <xsl:copy-of select="@* except (@class | @style)"/>
        <xsl:call-template name="tweakStyle">
          <xsl:with-param name="removeProperties" select="'text-indent'"/>
        </xsl:call-template>
        <xsl:call-template name="tweakClass">
          <xsl:with-param name="add" select="'indented'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>
  
<!-- Infrastructure should not require modification. -->
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="tweakClass">
    <xsl:param name="remove" select="()" as="xs:string*"/>
    <xsl:param name="add"    select="()" as="xs:string*"/>
    <xsl:if test="exists( ($add, xsw:classes(.)[not(.= $remove)] (: either $add or classes other than $remove :)))">
      <xsl:attribute name="class" select="xsw:classes(.)[not(.=$remove)], $add" separator="&#32;"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="tweakStyle">
    <!-- $removeProperties are expected as 'font-size', 'text-indent'  -->
    <!-- $addPropertyValues are expected as 'font-size: 12pt', 'text-indent: 36pt' -->
    <xsl:param name="removeProperties"     select="()" as="xs:string*"/>
    <xsl:param name="addPropertyValues"    select="()" as="xs:string*"/>
    <xsl:variable name="oldPropertyValues" select="xsw:style-propertyValues(.)"/>
    <xsl:variable name="newPropertyValues"
      select="$oldPropertyValues[not(replace(.,':.*$','') = $removeProperties)],
              $addPropertyValues"/>
    <xsl:if test="exists($newPropertyValues)">
      <xsl:attribute name="style">
        <xsl:for-each select="$newPropertyValues">
          <xsl:sort data-type="text"/>
          <xsl:if test="position() gt 1">; </xsl:if>
          <xsl:value-of select="."/>
        </xsl:for-each>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:function name="xsw:classes" as="xs:string*">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="tokenize($e/@class/normalize-space(.),'\s')"/>
  </xsl:function>
  
  <xsl:function name="xsw:style-properties" as="xs:string*">
    <!-- Returns 'font-family','font-size','color','text-indent' whatever
         properties are defined on @style -->
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="for $propVal in xsw:style-propertyValues($e)
      return substring-before($propVal,':')"/>
  </xsl:function>
  
  <xsl:function name="xsw:style-propertyValues" as="xs:string*">
    <!-- Returns 'font-family: Helvetica','font-size: 10pt' whatever
         properties are defined on @style -->
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="tokenize($e/@style/normalize-space(.),'\s*;\s*')"/>
  </xsl:function>
  
  <!--<xsl:function name="xsw:hasClass" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="c" as="xs:string"/>
    <xsl:sequence select="xsw:classes($e) = $c"/>
  </xsl:function>-->
  
  <xsl:key name="elements-by-class"         match="*[matches(@class,'\S')]" use="xsw:classes(.)"/>
  
  <xsl:key name="elements-by-property"      match="*[matches(@style,'\S')]" use="xsw:style-properties(.)"/>
  
  <xsl:key name="elements-by-propertyValue" match="*[matches(@style,'\S')]" use="xsw:style-propertyValues(.)"/>
  
</xsl:stylesheet>