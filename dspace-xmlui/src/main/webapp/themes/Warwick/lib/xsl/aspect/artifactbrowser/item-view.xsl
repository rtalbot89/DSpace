<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

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
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights">

    <xsl:output indent="yes"/>

    <xsl:template name="itemSummaryView-DIM">
       
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemSummaryView-DIM"/>
                              <!-- START CG - 06/10/09 Check if URL_BUNDLE exists and display if so -->
        <xsl:call-template name="url_bundle"/>
		<!-- END CG - 06/10/09 -->
  <!-- rtalbot START 10/03/13 test for a manifest and call the cp-preview-link template if there is one-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='METADATA']/mets:file/mets:FLocat[@xlink:title='imsmanifest.xml']">
            <xsl:call-template name="cp-preview-link">
                <xsl:with-param name="man-url" select="./mets:fileSec/mets:fileGrp[@USE='METADATA']/mets:file/mets:FLocat[@xlink:title='imsmanifest.xml']/@xlink:href"/>
            </xsl:call-template>
        </xsl:if>
  <!-- rtalbot END 10/03/13 -->
        <xsl:copy-of select="$SFXLink" />
        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file">
                <!-- rtalbot 27/03/13 START testing for a CP and hiding the bitstream list if it is -->
                <xsl:choose>
                    <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='METADATA']/mets:file/mets:FLocat[@xlink:title='imsmanifest.xml']">
                       <!-- rtalbot 27/03/13 generate a link to toggle the bitstream view -->
                        <xsl:choose>
                            <xsl:when test="contains($queryString, 'assets=show')">
                                <p>
                                    <a href="{$base-url}/{$request-uri}">Hide assets</a>
                                </p>
                                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                                    <xsl:with-param name="context" select="."/>
                                    <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <p>
                                    <a href="?assets=show">Show assets</a>
                                </p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                            <xsl:with-param name="context" select="."/>
                            <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- rtalbot 27/03/13 END -->
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']"/>
            </xsl:when>
            
            <xsl:otherwise>
                <h2>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text>
                </h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text>
                        </th>
                        <th>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        </th>
                        <th>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        </th>
                        <th>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text>
                        </th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text>
                            </p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE']"/>

    </xsl:template>

<!--this is the key summary template -->
    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata">           
            <xsl:call-template name="itemSummaryView-DIM-fields"/>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-fields">
        <xsl:param name="clause" select="'1'"/>
        <xsl:param name="phase" select="'even'"/>
        <xsl:variable name="otherPhase">
            <xsl:choose>
                <xsl:when test="$phase = 'even'">
                    <xsl:text>odd</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>even</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <!-- Title row -->
            <xsl:when test="$clause = 1">

                <xsl:choose>
                    <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                      <!-- display first title as h1 -->
                        <h1>
                            <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                        </h1>
                        <div class="simple-item-view-other">
                            <span class="bold">
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-title</i18n:text>:
                            </span>
                            <span>
                                <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                                    <xsl:value-of select="./node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                        <xsl:text>; </xsl:text>
                                        <br/>
                                    </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:when>
                    <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                        <h1>
                            <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                        </h1>
                    </xsl:when>
                    <xsl:otherwise>
                        <h1>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </h1>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>

          <!-- Author(s) row -->
            <xsl:when test="$clause = 2 and (dim:field[@element='contributor'][@qualifier='author'] or dim:field[@element='creator'] or dim:field[@element='contributor'])">
                <div class="simple-item-view-authors">
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <span>
                                    <xsl:if test="@authority">
                                        <xsl:attribute name="class">
                                            <xsl:text>ds-dc_contributor_author-authority</xsl:text>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <xsl:copy-of select="node()"/>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@element='creator']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor']">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>

          <!-- identifier.uri row -->
            <xsl:when test="$clause = 3 and (dim:field[@element='identifier' and @qualifier='uri'])">
                <div class="simple-item-view-other">
                    <span class="bold">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text>:
                    </span>
                    <span>
                        <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:copy-of select="./node()"/>
                                </xsl:attribute>
                                <xsl:copy-of select="./node()"/>
                            </a>
                            <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                                <br/>
                            </xsl:if>
                        </xsl:for-each>
                    </span>
                </div>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>

          <!-- date.issued row -->
            <xsl:when test="$clause = 4 and (dim:field[@element='date' and @qualifier='issued'])">
                <div class="simple-item-view-other">
                    <span class="bold">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>:
                    </span>
                    <span>
                        <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                            <xsl:copy-of select="substring(./node(),1,10)"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                                <br/>
                            </xsl:if>
                        </xsl:for-each>
                    </span>
                </div>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>

          <!-- Abstract row -->
            <xsl:when test="$clause = 5 and (dim:field[@element='description' and @qualifier='abstract' and descendant::text()])">
                <div class="simple-item-view-description">
                    <h3>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text>:
                    </h3>
                    <div>
                        <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                        <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                            <xsl:choose>
                                <xsl:when test="node()">
                                    <xsl:copy-of select="node()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                                <div class="spacer">&#160;</div>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </div>
                </div>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>

          <!-- Description row -->
            <xsl:when test="$clause = 6 and (dim:field[@element='description' and not(@qualifier)])">
                <div class="simple-item-view-description">
                    <h3 class="bold">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-description</i18n:text>:
                    </h3>
                    <div>
                        <xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1 and not(count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1)">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                        <xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
                            <xsl:copy-of select="./node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
                                <div class="spacer">&#160;</div>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </div>
                </div>
                <xsl:call-template name="itemSummaryView-DIM-fields">
                    <xsl:with-param name="clause" select="($clause + 1)"/>
                    <xsl:with-param name="phase" select="$otherPhase"/>
                </xsl:call-template>
            </xsl:when>
          
          
            <xsl:when test="$clause = 7 and $ds_item_view_toggle_url != ''">
                <p class="ds-paragraph item-view-toggle item-view-toggle-bottom">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$ds_item_view_toggle_url"/>
                        </xsl:attribute>
                        <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
                    </a>
                </p>
            </xsl:when>

          <!-- recurse without changing phase if we didn't output anything -->
            <xsl:otherwise>
            <!-- IMPORTANT: This test should be updated if clauses are added! -->
                <xsl:if test="$clause &lt; 8">
                    <xsl:call-template name="itemSummaryView-DIM-fields">
                        <xsl:with-param name="clause" select="($clause + 1)"/>
                        <xsl:with-param name="phase" select="$phase"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>

         <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default) -->
        <xsl:apply-templates select="mets:fileSec/mets:fileGrp[@USE='CC-LICENSE']"/>
        
    </xsl:template>


    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <table class="ds-includeSet-table detailtable">
            <xsl:apply-templates mode="itemDetailView-DIM"/>
        </table>
        <span class="Z3988">
            <xsl:attribute name="title">
                <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
        <tr>
            <xsl:attribute name="class">
                <xsl:text>ds-table-row </xsl:text>
                <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
            </xsl:attribute>
            <td class="label-cell">
                <xsl:value-of select="./@mdschema"/>
                <xsl:text>.</xsl:text>
                <xsl:value-of select="./@element"/>
                <xsl:if test="./@qualifier">
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@qualifier"/>
                </xsl:if>
            </td>
            <td>
                <xsl:copy-of select="./node()"/>
                <xsl:if test="./@authority and ./@confidence">
                    <xsl:call-template name="authorityConfidenceIcon">
                        <xsl:with-param name="confidence" select="./@confidence"/>
                    </xsl:call-template>
                </xsl:if>
            </td>
            <td>
                <xsl:value-of select="./@language"/>
            </td>
        </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

    <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>

        <h2>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text>
        </h2>
        <div class="file-list">
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                     	<!--Do not sort any more bitstream order can be changed-->
                        <!--<xsl:sort data-type="number" select="boolean(./@ID=$primaryBitstream)" order="descending" />-->
                        <!--<xsl:sort select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>-->
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper clearfix">
            <div class="thumbnail-wrapper">
                <a class="image-link">
                    <xsl:attribute name="href">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                            </img>
                        </xsl:when>
                        <xsl:otherwise>
                            <img alt="Icon" src="{concat($theme-path, '/images/mime.png')}" style="height: {$thumbnail.maxheight}px;"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </div>
            <div class="file-metadata" style="height: {$thumbnail.maxheight}px;">
                <div>
                    <span class="bold">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </span>
                    <span>
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 17, 5)"/>
                    </span>
                </div>
                <!-- File size always comes in bytes and thus needs conversion -->
                <div>
                    <span class="bold">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </span>
                    <span>
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                </div>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
         In the original DSpace, this would get resolved to an application via
         the Bitstream Registry, but we are constrained by the capabilities of METS
         and can't really pass that info through. -->
                <div>
                    <span class="bold">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </span>
                    <span>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </span>
                </div>
                <!---->
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                    <div>
                        <span class="bold">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </span>
                        <span>
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <!--<xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>-->
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 17, 5)"/>
                        </span>
                    </div>
                </xsl:if>
            </div>
            <div class="file-link" style="height: {$thumbnail.maxheight}px;">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                        <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                        <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 <!--rtalbot 11/03/13 
   Named template to generate link to preview page
   if this is an IMS CP
    -->
    <xsl:template name = "cp-preview-link">
        <xsl:param name="man-url"/>
        <xsl:variable name="webappcontext" select="substring-before($man-url, '/bitstream/')"/>
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="$man-url"/>
            </xsl:attribute>
            <xsl:attribute name="target">_blank</xsl:attribute>
            <xsl:attribute name="id">
                <xsl:text>cp-preview</xsl:text>
            </xsl:attribute>
            <!-- rtalbot 13/03/13 dodgy use of link to graphic below
            probably use something other that Jorum's anyway -->
            <img src="{$webappcontext}/themes/Warwick/images/preview-content-package.png" />
        </a>
        <xsl:element name="div">
            <xsl:attribute name="id">dialog-modal</xsl:attribute>
            <xsl:attribute name="title">Learning Object Preview</xsl:attribute>
            <xsl:attribute name="style">display:none</xsl:attribute>
            <xsl:element name="div">
                <xsl:attribute name="class">cp-menu</xsl:attribute>
                 <xsl:comment/>
            </xsl:element>
            <xsl:element name="iframe">
                <xsl:attribute name="id">viewHolder</xsl:attribute>
                 <xsl:comment/>
            </xsl:element>
        </xsl:element>
        <!--
        <div id="dialog-modal" title="Learning Object Preview" style="display:none;">
            <iframe src="http://www.w3schools.com" id="viewHolder">
                <text></text>
            </iframe>
        </div>-->
    </xsl:template>
    
    <!-- START CG - 06/10/09 Check if URL_BUNDLE exists and display if so -->
    <xsl:template name="url_bundle">
	<xsl:if test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='URL_BUNDLE']/mets:file/mets:FLocat/@xlink:title">
        	<h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-web-resource-title</i18n:text></h2>
        	
        	<xsl:for-each select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='URL_BUNDLE']/mets:file/mets:FLocat">
        		<p>
        		<xsl:call-template name="url">
        			<xsl:with-param name="urlValue" select="@xlink:title"/>
        			<xsl:with-param name="urlName" select="@xlink:title"/>
        		</xsl:call-template>
        		<br/>
        		</p>
        	</xsl:for-each>
        </xsl:if>
    </xsl:template>  
    <!-- END CG - 06/10/09 -->
    
    <!-- START CG - 06/10/09 If file in bitsteam, display details -->
    <xsl:template name="bitstream_display">
	<xsl:if test="(./mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID])">

		        <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT']">
		            <xsl:with-param name="context" select="."/>
		            <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
		        </xsl:apply-templates>   
        
        </xsl:if>  
    </xsl:template>  
    <!-- END CG - 06/10/09 -->
    
    
    
    <!-- Added by CG - handy snippet to create an html anchor for a url in a URL_BUNDLE-->
	<xsl:template name="url">
	<xsl:param name="urlValue"/>
	<xsl:param name="urlName"/>
	 		<a 
	 			href="{$urlValue}" 
	 			title="{$urlValue}">
     	    	<xsl:value-of select="$urlName" />          
     	    </a>
    </xsl:template>    
</xsl:stylesheet>
