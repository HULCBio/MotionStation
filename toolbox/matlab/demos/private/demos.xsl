<?xml version="1.0" encoding="utf-8"?>

<!--
This is an XSL stylesheet which converts DEMOS.XML files into HTML.

Copyright 1984-2003 The MathWorks, Inc. 
$Revision: 1.1.6.9 $  $Date: 2004/04/15 00:00:33 $
-->

<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#160;"> ]>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:file="java.io.File">
  <xsl:output method="html" indent="yes"/>

<!-- Pull a couple of variables from MATLAB to help resolve paths. -->
<xsl:variable name="matlabroot">
  <xsl:value-of select="matlab:matlabRoot()" xmlns:matlab="java:com.mathworks.jmi.Matlab"/>
</xsl:variable>
<xsl:variable name="docroot">
  <xsl:value-of select="helpPrefs:getDocRoot()" xmlns:helpPrefs="java:com.mathworks.mlwidgets.help.HelpPrefs"/>
</xsl:variable>

<!-- Windows requires three slashes and Unix doesn't mind them. -->
<xsl:variable name="urlbase">file:///</xsl:variable>

<xsl:template match="demos">

<html>
  <head>
    <title><xsl:value-of select="name"/> Demos</title>
    <base href="{$urlbase}{$demosroot}/"/>
    <style>
h1 {
  color: #990000; 
  font-size: xx-large;
}
h2 {
  color: #990000;
  font-size: x-large;
  margin-bottom: 5px;
}

xA {
  text-decoration: none;
}
.small {
  font-size: small ;
}
.Xdemo {
  background-color: #EFEFEF;
}
.demo {
  border: black 1 solid;
}
    </style>

  </head>
  <body>
    


<!-- BODY BEGIN -->    

<xsl:choose>
  <xsl:when test="not($section)">
    <!-- Show all sections (if any). -->

    <!-- Header and intro text -->
    <h1><xsl:value-of select="name"/> Demos</h1>
    <xsl:choose>
      <xsl:when test="description[@isCdata='no']">
        <xsl:copy-of select="description/*"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="description" disable-output-escaping="yes"/>
      </xsl:otherwise>
    </xsl:choose>

    <!-- Demo listing -->
    <xsl:choose>
      <xsl:when test="demosection">
        <!-- Subsections -->
        <xsl:for-each select="demosection">
          <h2><xsl:value-of select="label"/></h2>
          <xsl:choose>
            <xsl:when test="description[@isCdata='no']">
              <xsl:copy-of select="description/*"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="description" disable-output-escaping="yes"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:call-template name="demotable">
            <xsl:with-param name="demoitemlist" select="demoitem"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <!-- No subsections -->
        <xsl:call-template name="demotable">
          <xsl:with-param name="demoitemlist" select="demoitem"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:when>

  <xsl:otherwise>
    <!-- Show only one <demosection -->
    <xsl:for-each select="demosection[label=$section]">
      <h2><xsl:value-of select="label"/></h2>
      <xsl:choose>
        <xsl:when test="description[@isCdata='no']">
          <xsl:copy-of select="description/*"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="description" disable-output-escaping="yes"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="demotable">
        <xsl:with-param name="demoitemlist" select="demoitem"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:otherwise>
</xsl:choose>


<!-- BODY END -->

  </body>
</html>

</xsl:template>


<!-- Build a table that lists all of the demos. -->
<xsl:template name="demotable">
  <xsl:variable name="demoitemlist"/>
  <!-- Section title -->
  <table cellpadding="2" cellspacing="0" width="100%">
    <!-- Section listing -->
    <xsl:for-each select="demoitem">
      <xsl:if test="(position() mod 2) = 1">
        <tr valign="top">
          <td width="50%">
            <xsl:apply-templates select="."/>
          </td>
          <td width="50%">
            <xsl:apply-templates select="following-sibling::demoitem[position()=1]"/>
          </td>
        </tr>
      </xsl:if>
    </xsl:for-each>
  </table>
</xsl:template>


<!-- Display a demo. -->
<xsl:template match="demoitem">
  <table width="100%" height="100%" class="demo">
    <tr valign="middle">

      <!-- Thumbnail -->
      <td width="85" height="64" align="center" valign="middle">
        <img width="85" height="0"/><br clear="all"/>
        <img>
          <xsl:attribute name="src">
            <xsl:call-template name="chooseThumbnail"/>
          </xsl:attribute>
        </img>
      </td>

      <!-- Text -->
      <td>

        <!-- Replace $docroot if it's in the file's path. -->
        <xsl:variable name="filename">
          <xsl:choose>
            <xsl:when test="starts-with(file,'$docroot')"><xsl:value-of select="$urlbase"/><xsl:value-of select="concat($docroot,substring-after(file,'$docroot'))"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="file"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <!-- Show demo label (title). -->
        <xsl:variable name="quotedDemosroot">
          <xsl:call-template name="quotify">
            <xsl:with-param name="string" select="$demosroot"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="quotedCallback">
          <xsl:call-template name="quotify">
            <xsl:with-param name="string" select="callback"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="quotedProduct">
          <xsl:call-template name="quotify">
            <xsl:with-param name="string" select="/demos/name"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="quotedLabel">
          <xsl:call-template name="quotify">
            <xsl:with-param name="string" select="label"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="quotedFile">
          <xsl:call-template name="quotify">
            <xsl:with-param name="string" select="file"/>
          </xsl:call-template>
        </xsl:variable>

        <a href="matlab:indexhelper('{$quotedDemosroot}','{$quotedCallback}','{$quotedProduct}','{$quotedLabel}','{$quotedFile}')"><xsl:value-of select="label"/></a>
        
      </td>

    </tr>
  </table>
</xsl:template>


<!-- Figure out which thumbnail to use for this demo. -->
<xsl:template name="chooseThumbnail">
  <xsl:variable name="thumbnail" select="concat($demosroot,'/',substring-before(file,'.html'),'_img_thumbnail.png')"/>
  <xsl:variable name="thumbnail2" select="concat($demosroot,'/html/',callback,'.png')"/>
  <xsl:variable name="thumbnail3" select="concat($demosroot,'/html/',m-file,'.png')"/>
  <xsl:variable name="thumbnail4" select="concat($demosroot,'/',substring-before(file,'.html'),'.png')"/>
  <xsl:value-of select="$urlbase"/>
  <xsl:choose>
    <xsl:when test="starts-with(callback,'playback')"><xsl:value-of select="$matlabroot"/>/toolbox/matlab/icons/greenarrowicon.gif</xsl:when>
    <xsl:when test="file:exists(file:new($thumbnail))"><xsl:value-of select="$thumbnail"/></xsl:when>
    <xsl:when test="file:exists(file:new($thumbnail2))"><xsl:value-of select="$thumbnail2"/></xsl:when>
    <xsl:when test="file:exists(file:new($thumbnail3))"><xsl:value-of select="$thumbnail3"/></xsl:when>
    <xsl:when test="file:exists(file:new($thumbnail4))"><xsl:value-of select="$thumbnail4"/></xsl:when>
    <xsl:when test="/demos/icon">
      <xsl:choose>
        <xsl:when test="starts-with(/demos/icon,'$matlabroot')"><xsl:value-of select="concat($matlabroot,substring-after(/demos/icon,'$matlabroot'))"/></xsl:when>
        <xsl:when test="starts-with(/demos/icon,'$toolbox')"><xsl:value-of select="concat($matlabroot,'/toolbox',substring-after(/demos/icon,'$toolbox'))"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="/demos/icon"/></xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'{$matlabroot}/toolbox/matlab/icons/matlabicon.gif'"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="quotify">
  <xsl:param name="string"/>
    <xsl:call-template name="globalReplace">
      <xsl:with-param name="outputString" select="$string"/>
      <xsl:with-param name="target" select='"&apos;"'/>
      <xsl:with-param name="replacement" select='"&apos;&apos;"'/>
    </xsl:call-template>
</xsl:template>

<!-- Search and replace  -->
<!-- From http://www.xml.com/lpt/a/2002/06/05/transforming.html -->
<xsl:template name="globalReplace">
  <xsl:param name="outputString"/>
  <xsl:param name="target"/>
  <xsl:param name="replacement"/>
  <xsl:choose>
    <xsl:when test="contains($outputString,$target)">
      <xsl:value-of select=
        "concat(substring-before($outputString,$target),$replacement)"/>
      <xsl:call-template name="globalReplace">
        <xsl:with-param name="outputString" 
          select="substring-after($outputString,$target)"/>
        <xsl:with-param name="target" select="$target"/>
        <xsl:with-param name="replacement" 
          select="$replacement"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$outputString"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
