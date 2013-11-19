<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : testims.xsl
    Created on : February 22, 2013, 1:17 PM
    Author     : rob
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"

xmlns:imsmd="http://www.imsglobal.org/xsd/imsmd_rootv1p2p1"
xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
exclude-result-prefixes="imsmd"
>
    <xsl:output method="xml"/>
    
    <xsl:output indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>
	<xsl:variable name="newline">
		<xsl:text/>
	</xsl:variable>

    <!-- TODO customize transformation rules 
         syntax recommendation http://www.w3.org/TR/xslt 
    -->
    <xsl:template match="text()"></xsl:template>
    
    <xsl:template match="imsmd:lom">
		<xsl:element name="dim:dim">
			<xsl:value-of select="$newline"/>
			<xsl:comment>IMPORTANT NOTE:
				***************************************************************************************
				THIS "Dspace Intermediate Metadata" ('DIM') IS **NOT** TO BE USED FOR
				INTERCHANGE WITH OTHER SYSTEMS.
				***************************************************************************************
				It does NOT pretend to be a standard, interoperable representation of Dublin
				Core. It is EXPRESSLY used for transformation to and from source metadata XML
				vocabularies into and out of the DSpace object model. See
				http://wiki.dspace.org/DspaceIntermediateMetadata For more on Dublin Core
				standard schemata, see:
				http://dublincore.org/schemas/xmls/qdc/2003/04/02/qualifieddc.xsd
				http://dublincore.org/schemas/xmls/qdc/2003/04/02/dcterms.xsd Dublin Core
				usage guide: http://dublincore.org/documents/usageguide/ Also:
				http://dublincore.org/documents/dc-rdf/</xsl:comment>
			<xsl:value-of select="$newline"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
    
 
    <!-- Match the title imsmd=>general=>title=>langstring -->
	<xsl:template match="imsmd:title/imsmd:langstring">
	  <xsl:if test="normalize-space(.)">
		<xsl:element name="dim:field">
			<xsl:attribute name="mdschema">dc</xsl:attribute>
			<xsl:attribute name="element">title</xsl:attribute>
      		<xsl:attribute name="lang">
				<xsl:value-of select="@xml:lang"/>
			</xsl:attribute>
		<xsl:value-of select="normalize-space(.)"/>
		</xsl:element>	
	  </xsl:if>
	</xsl:template>
   <!--  <xsl:template match="text()"></xsl:template>
    <xsl:template match="/">
        <xsl:apply-templates/>
       
    </xsl:template>-->
    
 

</xsl:stylesheet>
