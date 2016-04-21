<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
This is an XSL stylesheet which converts Launc Pad info.xml files into HTML.
Use the XSLT command to perform the conversion.
xslt info.xml info.xsl -web

Copyright 2001-2001 The MathWorks, Inc. 
$Revision: 1.2 $  $Date: 2001/08/18 20:07:24 $
-->


<xsl:template match="*|/"><xsl:apply-templates/></xsl:template>

<xsl:template match="text()|@*"><xsl:value-of select="."/></xsl:template>

<!-- This is the root element of an info.xml file -->
<xsl:template match="productinfo">
<html>
   <head><title><xsl:value-of select="child::name"/> Info</title></head>
   <body>
   <h2>
      <xsl:value-of select="child::name"/> (R<xsl:value-of select="child::matlabrelease"/>)
   </h2>
   <i>Area: <xsl:value-of select="child::area"/></i>
   <xsl:apply-templates select="list"/>
   </body>
</html>
</xsl:template>

<!-- A list can currently contain only listitems. -->
<xsl:template match="list">
   <ul><xsl:apply-templates/></ul>
</xsl:template>

<!-- Each listitem is one node in the HTML list -->
<xsl:template match="listitem">
   <li><a href="matlab:{child::callback}"><xsl:value-of select="label"/></a></li>
</xsl:template>

<!-- null operators -->
<xsl:template match="productinfo/name"/>
<xsl:template match="productinfo/matlabrelease"/>
<xsl:template match="productinfo/area"/>
<xsl:template match="productinfo/icon"/>

</xsl:stylesheet>
