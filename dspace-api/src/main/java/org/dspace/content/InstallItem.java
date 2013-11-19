/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content;

import java.io.IOException;
import java.sql.SQLException;
import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.embargo.EmbargoManager;
import org.dspace.event.Event;
import org.dspace.identifier.IdentifierException;
import org.dspace.identifier.IdentifierService;
import org.dspace.utils.DSpace;
import uk.ac.jorum.exceptions.CriticalException;
import uk.ac.jorum.exceptions.NonCriticalException;
import uk.ac.jorum.utils.ExceptionLogger;


/**
 * Support to install an Item in the archive.
 * 
 * @author dstuve
 * @version $Revision$
 */
public class InstallItem
{
	/** log4j category */
	private static Logger log = Logger.getLogger(InstallItem.class);
	
    /**
     * Take an InProgressSubmission and turn it into a fully-archived Item,
     * creating a new Handle.
     * 
     * @param c
     *            DSpace Context
     * @param is
     *            submission to install
     * 
     * @return the fully archived Item
     */
    public static Item installItem(Context c, InProgressSubmission is)
            throws SQLException, IOException, AuthorizeException
    {
        return installItem(c, is, null);
    }

    /**
     * Take an InProgressSubmission and turn it into a fully-archived Item.
     * 
     * @param c  current context
     * @param is
     *            submission to install
     * @param suppliedHandle
     *            the existing Handle to give to the installed item
     * 
     * @return the fully archived Item
     */
    public static Item installItem(Context c, InProgressSubmission is,
            String suppliedHandle) throws SQLException,
            IOException, AuthorizeException
    {
        Item item = is.getItem();
        IdentifierService identifierService = new DSpace().getSingletonService(IdentifierService.class);
        try {
            if(suppliedHandle == null)
            {
                identifierService.register(c, item);
            }else{
                identifierService.register(c, item, suppliedHandle);
            }
        } catch (IdentifierException e) {
            throw new RuntimeException("Can't create an Identifier!");
        }


        populateMetadata(c, item);

        return finishItem(c, item, is);

    }

    /**
     * Turn an InProgressSubmission into a fully-archived Item, for
     * a "restore" operation such as ingestion of an AIP to recreate an
     * archive.  This does NOT add any descriptive metadata (e.g. for
     * provenance) to preserve the transparency of the ingest.  The
     * ingest mechanism is assumed to have set all relevant technical
     * and administrative metadata fields.
     *
     * @param c  current context
     * @param is
     *            submission to install
     * @param suppliedHandle
     *            the existing Handle to give the installed item, or null
     *            to create a new one.
     *
     * @return the fully archived Item
     */
    public static Item restoreItem(Context c, InProgressSubmission is,
            String suppliedHandle)
        throws SQLException, IOException, AuthorizeException
    {
        Item item = is.getItem();

        IdentifierService identifierService = new DSpace().getSingletonService(IdentifierService.class);
        try {
            if(suppliedHandle == null)
            {
                identifierService.register(c, item);
            }else{
                identifierService.register(c, item, suppliedHandle);
            }
        } catch (IdentifierException e) {
            throw new RuntimeException("Can't create an Identifier!");
        }

        // Even though we are restoring an item it may not have the proper dates. So let's
        // double check that it has a date accessioned and date issued, and if either of those dates
        // are not set then set them to today.
        DCDate now = DCDate.getCurrent();
        
        // If the item doesn't have a date.accessioned, create one.
        DCValue[] dateAccessioned = item.getDC("date", "accessioned", Item.ANY);
        if (dateAccessioned.length == 0)
        {
	        item.addDC("date", "accessioned", null, now.toString());
        }
        
        // create issue date if not present
        DCValue[] currentDateIssued = item.getDC("date", "issued", Item.ANY);
        if (currentDateIssued.length == 0)
        {
            DCDate issued = new DCDate(now.getYear(),now.getMonth(),now.getDay(),-1,-1,-1);
            item.addDC("date", "issued", null, issued.toString());
        }
        
        // Record that the item was restored
		String provDescription = "Restored into DSpace on "+ now + " (GMT).";
		item.addDC("description", "provenance", "en", provDescription);

        return finishItem(c, item, is);
    }


    private static void populateMetadata(Context c, Item item)
        throws SQLException, IOException, AuthorizeException
    {
        // create accession date
        DCDate now = DCDate.getCurrent();
        item.addDC("date", "accessioned", null, now.toString());

        // add date available if not under embargo, otherwise it will
        // be set when the embargo is lifted.
        // this will flush out fatal embargo metadata
        // problems before we set inArchive.
        if (EmbargoManager.getEmbargoTermsAsDate(c, item) == null)
        {
             item.addDC("date", "available", null, now.toString());
        }

        // create issue date if not present
        DCValue[] currentDateIssued = item.getDC("date", "issued", Item.ANY);

        if (currentDateIssued.length == 0)
        {
            DCDate issued = new DCDate(now.getYear(),now.getMonth(),now.getDay(),-1,-1,-1);
            item.addDC("date", "issued", null, issued.toString());
        }

         String provDescription = "Made available in DSpace on " + now
                + " (GMT). " + getBitstreamProvenanceMessage(item);

        if (currentDateIssued.length != 0)
        {
            DCDate d = new DCDate(currentDateIssued[0].value);
            provDescription = provDescription + "  Previous issue date: "
                    + d.toString();
        }

        // Add provenance description
        item.addDC("description", "provenance", "en", provDescription);
    }

    // final housekeeping when adding new Item to archive
    // common between installing and "restoring" items.
    private static Item finishItem(Context c, Item item, InProgressSubmission is)
        throws SQLException, IOException, AuthorizeException
    {
        log.debug("robmessage in finish item");
        // create collection2item mapping
        is.getCollection().addItem(item);

        // set owning collection
        item.setOwningCollection(is.getCollection());

        // set in_archive=true only if the user didn't specify that it is a private item
        if(item.isDiscoverable()){
            item.setArchived(true);
        }
        else{ // private item is withdrawn as well
            item.withdraw();
        }

        // save changes ;-)
        item.update();

        // Notify interested parties of newly archived Item
        c.addEvent(new Event(Event.INSTALL, Constants.ITEM, item.getID(),
                item.getHandle()));

        // remove in-progress submission
        is.deleteWrapper();

        
        // GWaller 9/11/09 IssueID #73 Call post install hook which will generate preview page for content packages
        // NOTE: this must be called before 'inheritCollectionDefaultPolicies' so that the user still has privs to create the preview bundle!
        try{
        	item.postInstallHook(c);
        } catch (NonCriticalException e){
        	ExceptionLogger.logException(log, e);
        } catch (CriticalException e){
        	ExceptionLogger.logException(log, e);
        	
        	// Action must be taken - we received a critical error.
        	// As the item is already installed at this point, it should be withdrawn so a user cannot see it.
        	// This must be taken as the item coudl be in an invalid state and should be corrected before making it live again.
        	item.withdraw();
        }
        
        // remove the item's policies and replace them with
        // the defaults from the collection
        item.inheritCollectionDefaultPolicies(is.getCollection());

        // set embargo lift date and take away read access if indicated.
        EmbargoManager.setEmbargo(c, item);

        return item;
    }

    /**
     * Generate provenance-worthy description of the bitstreams contained in an
     * item.
     * 
     * @param myitem  the item to generate description for
     * 
     * @return provenance description
     */
    public static String getBitstreamProvenanceMessage(Item myitem)
    						throws SQLException
    {
        // Get non-internal format bitstreams
        Bitstream[] bitstreams = myitem.getNonInternalBitstreams();

        // Create provenance description
        StringBuilder myMessage = new StringBuilder();
        myMessage.append("No. of bitstreams: ").append(bitstreams.length).append("\n");

        // Add sizes and checksums of bitstreams
        for (int j = 0; j < bitstreams.length; j++)
        {
            myMessage.append(bitstreams[j].getName()).append(": ")
                    .append(bitstreams[j].getSize()).append(" bytes, checksum: ")
                    .append(bitstreams[j].getChecksum()).append(" (")
                    .append(bitstreams[j].getChecksumAlgorithm()).append(")\n");
        }

        return myMessage.toString();
    }
}
