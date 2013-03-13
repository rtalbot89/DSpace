/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.artifactbrowser;

import org.apache.log4j.Logger;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.xml.sax.SAXException;

/**
 * Display a single item.
 *
 * @author Scott Phillips
 */
public class PreviewCP extends AbstractDSpaceTransformer
{
 
/**
 * Internationalization
 * 110523
 */
    public static final Message T_dspace_home =
        message("xmlui.general.dspace_home");
    public static final Message T_title =
        message("xmlui.ArtifactBrowser.AboutPage.title");
    public static final Message T_trail =
        message("xmlui.ArtifactBrowser.AboutPage.trail");
    public static final Message T_head =
        message("xmlui.ArtifactBrowser.AboutPage.head");
    public static final Message T_para =
        message("xmlui.ArtifactBrowser.AboutPage.para");
 
    private static Logger log = Logger.getLogger(PreviewCP.class);
 
        /**
        * Add a page title and trail links.
        */
        public void addPageMeta(PageMeta pageMeta) throws SAXException, WingException {
            // Set the page title
 
            // pageMeta.addMetadata("title").addContent("About Us");
            // 110523 modified page title with internationalization and added breadcrumbs
            pageMeta.addMetadata("title").addContent(T_title);
            // add trail
            pageMeta.addTrailLink(contextPath + "/",T_dspace_home);
            pageMeta.addTrail().addContent(T_trail);
        }
 
        /**
        * Add some basic contents
        */
        public void addBody(Body body) throws SAXException, WingException {
            //Division division = body.addDivision("about-page", "primary");
            //Division.setHead("About Us - Institutional Repository");
            //Division.addPara("We are an institutional repository that specializes in storing your digital artifacts.");
 
            //110523 modified with internationalization
            Division division = body.addDivision("about-page", "primary");
            division.setHead(T_head);
            division.addPara(T_para);
        }
}
