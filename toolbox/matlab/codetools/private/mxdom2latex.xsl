<?xml version="1.0" encoding="utf-8"?>

<!--
This is an XSL stylesheet which converts mscript XML files into XSLT.
Use the XSLT command to perform the conversion.

Ned Gulley and Matthew Simoneau, September 2003
Copyright 1984-2003 The MathWorks, Inc. 
$Revision: 1.1.6.2 $  $Date: 2003/12/24 19:11:56 $
-->

<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#160;"> ]>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:escape="http://www.mathworks.com/namespace/latex/escape"
  xmlns:mwsh="http://www.mathworks.com/namespace/mcode/v1/syntaxhighlight.dtd">
  <xsl:output method="text" indent="no"/>
  <xsl:strip-space elements="*"/>

<xsl:template match="mscript">
% This LaTeX was auto-generated from an M-file by MATLAB.
% To make changes, update the M-file and republish this document.

\documentclass{article}
\usepackage{graphicx}
\usepackage{color}

\sloppy
\definecolor{lightgray}{gray}{0.5}
\setlength{\parindent}{0pt}

\begin{document}

    <!-- Determine if the there should be an introduction section. -->
    <xsl:variable name="hasIntro" select="count(cell[@style = 'overview'])"/>
    <xsl:if test = "$hasIntro">
\section*{<xsl:value-of select="cell[1]/steptitle"/>}

<xsl:apply-templates select="cell[1]/text"/>
</xsl:if>
    
    <xsl:variable name="body-cells" select="cell[not(@style = 'overview')]"/>

    <!-- Include contents if there are titles for any subsections. -->
    <xsl:if test="count(cell/steptitle[not(@style = 'document')])">
      <xsl:call-template name="contents">
        <xsl:with-param name="body-cells" select="$body-cells"/>
      </xsl:call-template>
    </xsl:if>
    
    <!-- Loop over each cell -->
    <xsl:for-each select="$body-cells">
        <!-- Title of cell -->
        <xsl:if test="steptitle">
          <xsl:variable name="headinglevel">
            <xsl:choose>
              <xsl:when test="steptitle[@style = 'document']">section</xsl:when>
              <xsl:otherwise>subsection</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

\<xsl:value-of select="$headinglevel"/>*{<xsl:value-of select="steptitle"/>}

</xsl:if>

        <!-- Contents of each cell -->
        <xsl:apply-templates select="text"/>
        <xsl:apply-templates select="mcode"/>
        <xsl:apply-templates select="mcodeoutput"/>
        <xsl:apply-templates select="img"/>

    </xsl:for-each>


<xsl:if test="copyright">
\begin{par} \footnotesize \color{lightgray} \emph{
   <xsl:value-of select="copyright"/>
} \color{black} \normalsize \end{par}
</xsl:if>


\end{document}
    
</xsl:template>



<xsl:template name="contents">
  <xsl:param name="body-cells"/>
\subsection*{Contents}

\begin{itemize}
\setlength{\itemsep}{-1ex}<xsl:for-each select="$body-cells">
      <xsl:if test="./steptitle">
   \item <xsl:value-of select="steptitle"/>
      </xsl:if>
    </xsl:for-each>
\end{itemize}
</xsl:template>




<!-- HTML Tags in text sections -->
<xsl:template match="p">\begin{par}
<xsl:apply-templates/><xsl:text>
\end{par} \vspace{1em}
</xsl:text>
</xsl:template>

<xsl:template match="ul">\begin{itemize}
\setlength{\itemsep}{-1ex}
<xsl:apply-templates/>\end{itemize}
</xsl:template>
<xsl:template match="li">   \item <xsl:apply-templates/><xsl:text>
</xsl:text></xsl:template>
<xsl:template match="pre">
  <xsl:choose>
    <xsl:when test="@class='error'">
\begin{verbatim}<xsl:value-of select="."/>\end{verbatim}
    </xsl:when>
    <xsl:otherwise>
\begin{verbatim}<xsl:value-of select="."/>\end{verbatim}
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
<xsl:template match="b">\textbf{<xsl:apply-templates/>}</xsl:template>
<xsl:template match="tt">\texttt{<xsl:apply-templates/>}</xsl:template>
<xsl:template match="a">\begin{verbatim}<xsl:value-of select="."/>\end{verbatim}</xsl:template>

<xsl:template match="text()">
  <!-- Escape special characters in text -->
  <xsl:call-template name="replace">
    <xsl:with-param name="string" select="."/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="equation">
<xsl:value-of select="."/>
</xsl:template>


<!-- Code input and output -->

<xsl:template match="mcode">\begin{verbatim}
<xsl:value-of select="."/>
\end{verbatim}
</xsl:template>

<xsl:template match="mcodeoutput">
\color{lightgray} \begin{verbatim}<xsl:value-of select="."/>\end{verbatim} \color{black}
</xsl:template>


<!-- Figure and model snapshots -->

<xsl:template match="img">
\includegraphics [width=4in]{<xsl:value-of select="@src"/>}
</xsl:template>

<!-- Colors for syntax-highlighted input code -->

<xsl:template match="mwsh:code">\begin{verbatim}<xsl:apply-templates/>\end{verbatim}
</xsl:template>
<xsl:template match="mwsh:keywords">
  <span class="keyword"><xsl:value-of select="."/></span>
</xsl:template>
<xsl:template match="mwsh:strings">
  <span class="string"><xsl:value-of select="."/></span>
</xsl:template>
<xsl:template match="mwsh:comments">
  <span class="comment"><xsl:value-of select="."/></span>
</xsl:template>
<xsl:template match="mwsh:unterminated_strings">
  <span class="untermstring"><xsl:value-of select="."/></span>
</xsl:template>
<xsl:template match="mwsh:system_commands">
  <span class="syscmd"><xsl:value-of select="."/></span>
</xsl:template>


<!-- Footer information -->

<xsl:template match="copyright">
  <xsl:value-of select="."/>
</xsl:template>
<xsl:template match="revision">
  <xsl:value-of select="."/>
</xsl:template>


<!-- Used to escape special characters in the LaTeX output. -->

<escape:replacements>
  <!-- special TeX characters -->
  <replace><from>$</from><to>\$</to></replace>
  <replace><from>&amp;</from><to>\&amp;</to></replace>
  <replace><from>%</from><to>\%</to></replace>
  <replace><from>#</from><to>\#</to></replace>
  <replace><from>_</from><to>\_</to></replace>
  <replace><from>{</from><to>\{</to></replace>
  <replace><from>}</from><to>\}</to></replace>
  <!-- mainly in code -->
  <replace><from>~</from><to>\ensuremath{\tilde{\;}}</to></replace>
  <replace><from>^</from><to>\verb=^=</to></replace>
  <replace><from>\</from><to>\ensuremath{\backslash}</to></replace>
  <!-- mainly in math -->
  <replace><from>|</from><to>\ensuremath{|}</to></replace>
  <replace><from>&lt;</from><to>\ensuremath{&lt;}</to></replace>
  <replace><from>&gt;</from><to>\ensuremath{&gt;}</to></replace>
</escape:replacements>

<xsl:variable name="replacements" select="document('')/xsl:stylesheet/escape:replacements/replace"/>

<xsl:template name="replace">
  <xsl:param name="string"/>
  <xsl:param name="next" select="1"/>

  <xsl:variable name="count" select="count($replacements)"/>
  <xsl:variable name="first" select="$replacements[$next]"/>
  <xsl:choose>
    <xsl:when test="$next > $count">
      <xsl:value-of select="$string"/>
    </xsl:when>
    <xsl:when test="contains($string, $first/from)">      
      <xsl:call-template name="replace">
        <xsl:with-param name="string"
                        select="substring-before($string, $first/from)"/>
        <xsl:with-param name="next" select="$next+1" />
      </xsl:call-template>
      <xsl:copy-of select="$first/to" />
      <xsl:call-template name="replace">
        <xsl:with-param name="string"
                        select="substring-after($string, $first/from)"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="replace">
        <xsl:with-param name="string" select="$string"/>
        <xsl:with-param name="next" select="$next+1"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
