/**
 * The contents of this file are subject to the license and copyright detailed
 * in the LICENSE and NOTICE files at the root of the source tree and available
 * online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.artifactbrowser;

import java.sql.SQLException;
import org.apache.log4j.Logger;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.HandleUtil;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.content.DCValue;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.xml.sax.SAXException;

/**
 * Display a single item.
 *
 * @author Scott Phillips
 */
public class PreviewCP extends AbstractDSpaceTransformer {

    /**
     * Internationalization 110523
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
    public void addPageMeta(PageMeta pageMeta) throws SAXException, WingException, SQLException {
        // Set the page title
        DSpaceObject dso = HandleUtil.obtainHandle(objectModel);
        if (!(dso instanceof Item)) {
            return;
        }

        Item item = (Item) dso;

        // Set the page title
        String title = getItemTitle(item);

        if (title != null) {
            pageMeta.addMetadata("title").addContent(title);
        } else {
            pageMeta.addMetadata("title").addContent(item.getHandle());
        }

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

    /**
     * Obtain the item's title.
     */
    public static String getItemTitle(Item item) {
        DCValue[] titles = item.getDC("title", Item.ANY, Item.ANY);

        String title;
        if (titles != null && titles.length > 0) {
            title = titles[0].value;
        } else {
            title = null;
        }
        return title;
    }
}
