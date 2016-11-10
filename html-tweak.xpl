<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step  version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xsw="http://coko.foundation/xsweet"
  type="xsw:html-tweak" name="html-tweak">
  
  <!-- Run on a document.xml file (extracted from a .docx file)
       with its neighbor files in position. -->
  
  <p:input port="source"/>
  
  <p:input port="htmlTweakMap"/>
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:output port="_Z_FINAL">
    <p:pipe port="result" step="final"/>
  </p:output>
  
  <p:output port="_X_htmlTweakXSLT" primary="false">
    <p:pipe port="result" step="html-tweak-xsl"/>
  </p:output>
  
  <p:serialization port="_Z_FINAL"     indent="true" omit-xml-declaration="true"/>
  
  <p:serialization port="_X_htmlTweakXSLT" indent="true" />
  
  
  <!-- Next we step aside and generate a transformation from a spec... -->
  <p:xslt name="html-tweak-xsl">
    <p:input port="source">
      <p:pipe port="htmlTweakMap" step="html-tweak"></p:pipe>
    </p:input>

    <p:input port="stylesheet">
      <p:document href="make-html-tweak-xslt.xsl"/>
    </p:input>
    <!--<p:with-param name="show-css" select="'yes'"/>-->
  </p:xslt>
  
  <!-- Now going back to the verry beginning -->
  
  <p:xslt name="html-tweaked">
    <p:input port="source">
      <p:pipe port="source" step="html-tweak"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="result" step="html-tweak-xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>

</p:declare-step>