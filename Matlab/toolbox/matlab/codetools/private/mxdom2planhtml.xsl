<?xml version="1.0" encoding="utf-8"?>

<!--
This is an XSL stylesheet which converts mscript XML files into HTML.
Use the XSLT command to perform the conversion.

Copyright 1984-2003 The MathWorks, Inc. 
$Revision: 1.1.6.1 $  $Date: 2003/02/25 07:52:43 $
-->

<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#160;"> ]>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" indent="yes"/>

<xsl:template match="mscript">
  
  <!-- Loop over each cell -->
  <xsl:for-each select="cell">
      <!-- Title of cell -->
      <strong><xsl:value-of select="steptitle"/></strong><br/>
    
      <!-- Contents of each cell -->
      <xsl:apply-templates select="text"/>
      
  </xsl:for-each>
  
</xsl:template>


<!-- HTML Tags in text sections -->

<xsl:template match="p">
  <p><xsl:apply-templates/></p>
</xsl:template>
<xsl:template match="ul">
  <ul><xsl:apply-templates/></ul>
</xsl:template>
<xsl:template match="li">
  <li><xsl:apply-templates/></li>
</xsl:template>
<xsl:template match="pre">
  <pre><xsl:apply-templates/></pre>
</xsl:template>
<xsl:template match="b">
  <b><xsl:apply-templates/></b>
</xsl:template>
<xsl:template match="tt">
  <tt><xsl:apply-templates/></tt>
</xsl:template>
<xsl:template match="a">
  <a>
    <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
    <xsl:apply-templates/>
  </a>
</xsl:template>

</xsl:stylesheet>

