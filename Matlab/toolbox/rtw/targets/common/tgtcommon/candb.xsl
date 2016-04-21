<?xml version="1.0" ?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- XSL Stylesheet for generating a web page view of the CANdb data file.

	See readcandbdbc.m

	Copyright 2003-2004 The MathWorks, Inc.
	$Revision: 1.1.6.2 $
	$Date: 2004/04/19 01:21:42 $
	-->
    <xsl:template match="/">
        <HTML>
            <BODY>
                <table border="0" cellpadding="5">

                    <!--Process each message-->
                    <xsl:for-each select="candb/message">
                        <tr><td colspan="12" bgcolor="green"><hr></hr></td></tr>
                        <tr>
                            <TR>
                                <TD><b>Name</b></TD> 
                                <TD><b>ID</b></TD> 
                                <TD><b>ID Type</b></TD> 
                                <TD><b>Length</b></TD> 
                                <TD><b>Transmitter</b></TD> 
                            </TR>
                            <TR>
                                <TD>
                                    <xsl:value-of select="name" /> 
                                </TD>
                                <TD>
                                    <xsl:value-of select="id" /> 
                                </TD>
                                <TD>
                                    <xsl:value-of select="idtype" /> 
                                </TD>
                                <TD>
                                    <xsl:value-of select="dlc" /> 
                                </TD>
                                <TD>
                                    <xsl:value-of select="transmitter" /> 
                                </TD>
                            </TR>
                        </tr>
                        <tr>
                            <tr>
                                <td><b>Name</b></td>
                                <td><b>Start Bit</b></td>
                                <td><b>Bit Length</b></td>
                                <td><b>Byte Layout</b></td>
                                <td><b>Sign</b></td>
                                <td><b>Data Type</b></td>
                                <td><b>Multiplex Type</b></td>
                                <td><b>Multiplex Value</b></td>
                                <td><b>Offset</b></td>
                                <td><b>Factor</b></td>
                                <td><b>Min</b></td>
                                <td><b>Max</b></td>
                                <td><b>Units</b></td>
                                <td><b>Receivers</b></td>
                            </tr>
                            <xsl:for-each select="signals/signal">
                                <tr>
                                    <td><xsl:value-of select="name"/></td> 
                                    <td><xsl:value-of select="start_bit"/></td> 
                                    <td><xsl:value-of select="bit_length"/></td> 
                                    <td><xsl:value-of select="byte_layout"/></td> 
                                    <td><xsl:value-of select="sign"/></td> 
                                    <td><xsl:value-of select="data_type"/></td> 
                                    <td><xsl:value-of select="multiplex_type"/></td> 
                                    <td><xsl:value-of select="multiplex_value"/></td> 
                                    <td><xsl:value-of select="offset"/></td> 
                                    <td><xsl:value-of select="factor"/></td> 
                                    <td><xsl:value-of select="min"/></td> 
                                    <td><xsl:value-of select="max"/></td> 
                                    <td><xsl:value-of select="units"/></td> 
                                    <td>
                                        <xsl:for-each select="receivers/receiver">
                                            <xsl:if test="not(position() = 1)">,&#160;&#160;</xsl:if>
                                            <xsl:value-of select="text()"/> 
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </table>
            </BODY>
        </HTML>
    </xsl:template>
</xsl:stylesheet>

