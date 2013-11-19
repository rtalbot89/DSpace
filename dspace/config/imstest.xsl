<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : imstest.xsl
    Created on : March 1, 2013, 2:27 PM
    Author     : robtalbot89
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
     xmlns="http://www.imsproject.org/xsd/imscp_rootv1p1p2" 
    xmlns:imsmd="http://www.imsglobal.org/xsd/imsmd_rootv1p2p1" 
    xmlns:adlcp="http://www.adlnet.org/xsd/adlcp_rootv1p2" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xsi:schemaLocation="http://www.imsproject.org/xsd/imscp_rootv1p1p2
http://www.imsglobal.org/xsd/imscp_rootv1p1p2.xsd
http://www.w3.org/XML/1998/namespace
http://www.imsglobal.org/xsd/ims_xml.xsd
http://www.imsglobal.org/xsd/imsmd_rootv1p2p1
http://www.imsglobal.org/xsd/imsmd_rootv1p2p1.xsd
http://www.w3.org/XML/1998/namespace
http://www.imsglobal.org/xsd/http://www.imsglobal.org/xsd/ims_xml.xsd
http://www.adlnet.org/xsd/adlcp_rootv1p2
http://www.adlnet.org/xsd/adlcp_rootv1p2.xsd" 


>
    <xsl:output method="html"/>

    <!-- TODO customize transformation rules 
         syntax recommendation http://www.w3.org/TR/xslt 
    -->
    <xsl:template match="/">
        <html>
            <head>
                <title>imstest.xsl</title>
            </head>
            <body>
                <xsl:value-of select="//imsmd:title/imsmd:langstring"/>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
