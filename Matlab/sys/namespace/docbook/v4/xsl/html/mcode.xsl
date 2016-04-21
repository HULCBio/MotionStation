<?xml version="1.0" encoding="utf-8"?>

<!--
This is an XSL stylesheet which converts mscript XML files into HTML.
Use the XSLT command to perform the conversion.

This is intended to be included inside another XSL file, not used standalone.

When EntityResolvers work properly, this should be moved to its own directory.

Copyright 1984-2002 The MathWorks, Inc.
$Revision: 1.1 $  $Date: 2002/04/08 18:21:24 $
-->

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mwsh="http://www.mathworks.com/namespace/mcode/v1/syntaxhighlight.dtd">
  <xsl:param name="code.keyword">blue</xsl:param>
  <xsl:param name="code.comment">green</xsl:param>
  <xsl:param name="code.string">#B20000</xsl:param>
  <xsl:param name="code.untermstring">purple</xsl:param>
  <xsl:param name="code.syscmd">orange</xsl:param>
  <xsl:strip-space elements="mwsh:code"/>

<xsl:template match="mwsh:code"><pre><xsl:apply-templates/></pre></xsl:template>

<xsl:template match="mwsh:keywords">
  <span style="color:{$code.keyword}"><xsl:value-of select="."/></span>
</xsl:template>

<xsl:template match="mwsh:strings">
  <span style="color:{$code.string}"><xsl:value-of select="."/></span>
</xsl:template>

<xsl:template match="mwsh:comments">
  <span style="color:{$code.comment}"><xsl:value-of select="."/></span>
</xsl:template>

<xsl:template match="mwsh:unterminated_strings">
  <span style="color:{$code.untermstring}"><xsl:value-of select="."/></span>
</xsl:template>

<xsl:template match="mwsh:system_commands">
  <span style="color:{$code.syscmd}"><xsl:value-of select="."/></span>
</xsl:template>

</xsl:stylesheet>

