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
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink 
                                                     xsl util jstring rights xi a http imsmd oreatom ore atom
                                                     "
>
    
    <!--<xsl:param name="item-id" select="substring-before($request-uri,'previewcp')"/>-->
    
    <xsl:template name="cp-preview">
        <xsl:param name="tp"/>
       <!-- rtalbot 03/04/13 these styles are local overrides 
       to hide page elements not needed in the preview, as well as to define the presentation -->
        <style>
            #ds-options-wrapper, #ds-trail, #ds-user-box {
            display:none;
            }
            #ds-body {
            width:1000px;
         
            }
            #ds-content{
            margin-left:auto;
            margin-right:auto;
       
            }
            
            #cp-menu {
            /*width:250px;*/
            width:15%;
            margin-right:10px;
            float:left;      
            }
            
            /* make sure menu links wrap */
            #cp-menu a {
            white-space: pre;           /* CSS 2.0 */
            white-space: pre-wrap;      /* CSS 2.1 */
            white-space: pre-line;      /* CSS 3.0 */
            white-space: -pre-wrap;     /* Opera 4-6 */
            white-space: -o-pre-wrap;   /* Opera 7 */
            white-space: -moz-pre-wrap; /* Mozilla */
            white-space: -hp-pre-wrap;  /* HP Printers */
            word-wrap: break-word;      /* IE 5+ */
	
            }
            
            #viewHolder {
            width:80%;
            height:700px; 
            vertical-align:top;
            }
        </style>
        <script type="text/javascript">
            //unobtrusive jQuery ehancement to add function to links in menu
            $(document).ready(function(){
            $("#cp-menu li").bind("click", function(event){
            event.preventDefault();
            var newUrl = $(this).find("a").attr("href");
            $("#viewHolder").attr("src",newUrl);
  
            });
            });
             
        </script>
        <!-- rtalbot 13/03/13 include and process the manifest 
        using the @USE=METADATA attribute to detect that there is a manifest. 
        There may be better alternatives
        -->
        <xsl:variable name="manifest-url" select="./mets:fileSec/mets:fileGrp[@USE='METADATA']/mets:file/mets:FLocat[@xlink:title='imsmanifest.xml']/@xlink:href"/>
        <!--<xsl:variable name="man-path" select="concat($base-url,'/bitstream/',$item-id,'imsmanifest.xml')"/>-->
        <xsl:element name="p">
            foo
            <xsl:value-of select="$manifest-url"/>
        </xsl:element>
        <!--<xsl:apply-templates select="document($manifest-url)/a:manifest/a:organizations"/>-->
        
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
             <!--rtalbot 28/03/13 test if there is more than one item.
             If there is just one we don't need a menu. may be exceptions but easy enough to change-->
            <xsl:if test="count(a:item) &gt; 1">
                <ul id="cp-menu">
                    <xsl:for-each select="a:item">
                        <xsl:variable name="x" select="@identifierref"/>
                        <xsl:variable name="url" select="/a:manifest/a:resources/a:resource[@identifier=$x]/@href"/>
                        <li>
                            <a>
                                <xsl:attribute name="href">
                                    <!--<xsl:value-of select="concat($base-url,'/bitstream/handle',$item-id,$url)"/>-->
                                </xsl:attribute>
                                <xsl:value-of select="a:title"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:if>
        </xsl:for-each>
        <!--rtalbot 03/04/13 The iFrame that displays the current content.-->
        <iframe id="viewHolder">
            <xsl:attribute name="src">
               <!-- <xsl:value-of select="concat($base-url,'/bitstream/',$item-id,'/', $first-page)"/>-->
            </xsl:attribute>
        </iframe>
    </xsl:template>
</xsl:stylesheet>
