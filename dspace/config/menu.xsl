<?xml version="1.0" ?>
 <xsl:stylesheet version="1.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:lxslt="http://xml.apache.org/xslt"
 xmlns="http://www.imsproject.org/xsd/imscp_rootv1p1p2" 
    xmlns:imsmd="http://www.imsglobal.org/xsd/imsmd_rootv1p2p1" 
    xmlns:adlcp="http://www.adlnet.org/xsd/adlcp_rootv1p2" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:a="http://www.imsproject.org/xsd/imscp_rootv1p1p2"
>
<!--
<xsl:output method="xml" version="1.1" encoding="utf-16"/>
-->

<xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes"/>

<xsl:variable name ="title" select ="//*[local-name()='title']/*[local-name()='langstring']"/>

<xsl:template match="/">

<html>
    
<head>
<meta HTTP-EQUIV="content-type" CONTENT="text/html; charset=UTF-8"/>
<title><xsl:value-of select="//imsmd:title/imsmd:langstring"/></title>

</head>
<body>
<xsl:apply-templates select="/a:manifest/a:organizations"/>
</body>
</html>
</xsl:template>

<xsl:template match="a:organizations">
    <xsl:for-each select="a:organization">
        <h2><xsl:value-of select="a:title"/></h2>
        <ul>
        <xsl:for-each select="a:item">
            <xsl:variable name="x" select="@identifierref"/>
            <xsl:variable name="url" select="/a:manifest/a:resources/a:resource[@identifier=$x]/@href"/>
            <li>
                <a href='{$url}'>
                    <xsl:value-of select="a:title"/>
                </a>
            </li>
            </xsl:for-each>
        </ul>
    </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
