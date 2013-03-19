<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--<?xml version="1.0" encoding="UTF-8"?>-->

<!--
    Document   : item-preview.xsl
    Created on : March 6, 2013, 3:51 PM
    Author     : robtalbot89
    Description:
    This is extra to the DSpace base to generate the
    CP preview page. Might be better called cp-preview.xsl
-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                                                     xmlns:atom="http://www.w3.org/2005/Atom"
                                                     xmlns:ore="http://www.openarchives.org/ore/terms/"
                                                     xmlns:oreatom="http://www.openarchives.org/ore/atom/"
                                                     xmlns="http://www.w3.org/1999/xhtml"
                                                     xmlns:xalan="http://xml.apache.org/xalan"
                                                     xmlns:encoder="xalan://java.net.URLEncoder"
                                                     xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
                                                     xmlns:jstring="java.lang.String"
                                                     xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
                                                     xmlns:xi="http://www.w3.org/2001/XInclude"
                                                     xmlns:imsmd="http://www.imsglobal.org/xsd/imsmd_rootv1p2p1"
                                                     xmlns:a="http://www.imsproject.org/xsd/imscp_rootv1p1p2"
                                                     xmlns:http="http://xml.apache.org/cocoon/requestgenerator/2.0" 
                                                     exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights"
>
    
    <xsl:param name="item-id" select="substring-before($request-uri,'previewcp')"/>
    
    <xsl:template name="cp-preview">
       <!-- rtalbot 13/03/13 these styles may be better in the top level
       stylesheet. They are used to hide page elements not needed in the preview -->
        <style>
            #ds-options-wrapper {
            display:none;
            }
        </style>
        <!-- rtalbot 13/03/13 include and process the manifest 
        using the @USE=METADATA attribute to detect that there is a manifest. 
        There may be better alternatives
        -->
        <xsl:variable name="manifest-url" select="./mets:fileSec/mets:fileGrp[@USE='METADATA']/mets:file/mets:FLocat[@xlink:title='imsmanifest.xml']/@xlink:href"/>
        <xsl:variable name="man-path" select="concat($base-url,'/bitstream/',$item-id,'imsmanifest.xml')"/>
        <xsl:apply-templates select="document($man-path)/a:manifest/a:organizations"/>
    </xsl:template>
    
    <xsl:template match="a:organizations">
        <!-- rtalbot 13/03/13 This is the key template that actually generates the menu 
        jQuery progressive enhancement is used to attach a handler to each menu link that switches
        the iFrame content-->
        
        <!-- rtalbot 13/03/13 find the URL of the first item in the menu to pre-populate
        the viewer iframe -->
        <xsl:param name="first-link" select="a:organization[1]/a:item[1]/@identifierref"/>
        <xsl:param name="first-page" select="/a:manifest/a:resources/a:resource[@identifier=$first-link]/@href"/>
        
        <xsl:for-each select="a:organization">
            <h1>
                <xsl:value-of select="a:title"/>
            </h1>
            <ul id="cp-menu">
                <xsl:for-each select="a:item">
                    <xsl:variable name="x" select="@identifierref"/>
                    <xsl:variable name="url" select="/a:manifest/a:resources/a:resource[@identifier=$x]/@href"/>
                    <li>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat($base-url,'/bitstream/handle',$item-id,$url)"/>
                            </xsl:attribute>
                            <xsl:value-of select="a:title"/>
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:for-each>
        <!--rtalbot 13/03/13 The iFrame that displays the current content.
        Putting CSS inline is not great and should probably be moved.
        -->
        <iframe id="viewHolder" style="position:absolute;left:250px;top:40px;width:800px;height:650px">
            <xsl:attribute name="src">
                <xsl:value-of select="concat($base-url,'/bitstream/',$item-id,'/', $first-page)"/>
            </xsl:attribute>
        </iframe>
    </xsl:template>
</xsl:stylesheet>
