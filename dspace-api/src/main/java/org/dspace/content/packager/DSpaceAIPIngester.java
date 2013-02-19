/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.packager;

import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;

import org.jdom.Element;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.content.Collection;
import org.dspace.content.DCValue;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.MetadataField;
import org.dspace.content.MetadataSchema;
import org.dspace.content.NonUniqueMetadataException;
import org.dspace.content.WorkspaceItem;
import org.dspace.content.crosswalk.CrosswalkException;
import org.dspace.content.crosswalk.MetadataValidationException;
import org.dspace.core.Context;
import org.dspace.core.Constants;
import uk.ac.jorum.exceptions.CriticalException;
import uk.ac.jorum.exceptions.NonCriticalException;

/**
 * Subclass of the METS packager framework to ingest a DSpace
 * Archival Information Package (AIP).  The AIP is intended to be, foremost,
 * a _complete_ and _accurate_ representation of one object in the DSpace
 * object model.  An AIP contains all of the information needed to restore
 * the object precisely in another DSpace archive instance.
 * <p>
 * This ingester recognizes two distinct types of AIPs: "Manifest-Only" and "External".
 * The Manifest-Only AIP, which is selected by specifying a PackageParameters
 * key "manifestOnly" with the value "true", refers to all its contents by 
 * reference only. For Community or Collection AIPs this means all references to their
 * child objects are just via Handles. For Item AIPs all Bitreams are just
 * referenced by their asset store location instead of finding them in the "package".
 * The Manifest-Only AIP package format is simply a METS XML document serialized into a file.
 * <p>
 * An "external" AIP (the default), is a conventional Zip-file based package
 * that includes copies of all bitstreams referenced by the object as well
 * as a serialized METS XML document in the path "mets.xml".
 *
 * Configuration keys:
 *
 *  # instructs which xwalk plugin to use for a given type of metadata
 *  mets.dspaceAIP.ingest.crosswalk.{mdSecName} = {pluginName}
 *  mets.dspaceAIP.ingest.crosswalk.DC = QDC
 *  mets.dspaceAIP.ingest.crosswalk.DSpaceDepositLicense = NULLSTREAM
 *
 *  # Option to save METS manifest in the item: (default is false)
 *  mets.default.ingest.preserveManifest = false
 *
 * @author Larry Stone
 * @author Tim Donohue
 * @version $Revision: 1.1 $
 *
 * @see AbstractMETSIngester
 * @see AbstractPackageIngester
 * @see PackageIngester
 * @see org.dspace.content.packager.METSManifest
 */
public class DSpaceAIPIngester
       extends AbstractMETSIngester
{
    /** log4j category */
    private static Logger log = Logger.getLogger(DSpaceAIPIngester.class);

    /**
     * Ensure it's an AIP generated by the complementary AIP disseminator.
     */
    @Override
    void checkManifest(METSManifest manifest)
        throws MetadataValidationException
    {
        String profile = manifest.getProfile();
        if (profile == null)
        {
            throw new MetadataValidationException("Cannot accept METS with no PROFILE attribute!");
        }
        else if (!profile.equals(DSpaceAIPDisseminator.PROFILE_1_0))
        {
            throw new MetadataValidationException("METS has unacceptable PROFILE attribute, profile=" + profile);
        }
    }


    /**
     * Choose DMD section(s) to crosswalk.
     * <p>
     * The algorithm is:<br>
     * 1. Use whatever the <code>dmd</code> parameter specifies as the primary DMD.<br>
     * 2. If (1) is unspecified, find DIM (preferably) or MODS as primary DMD.<br>
     * 3. If (1) or (2) succeeds, crosswalk it and ignore all other DMDs with
     *    same GROUPID<br>
     * 4. Crosswalk remaining DMDs not eliminated already.
     */
    @Override
    public void crosswalkObjectDmd(Context context, DSpaceObject dso,
                              METSManifest manifest,
                              MdrefManager callback,
                              Element dmds[], PackageParameters params)
        throws CrosswalkException, PackageValidationException,
               AuthorizeException, SQLException, IOException
    {
        int found = -1;

        // Check to see what dmdSec the user specified in the 'dmd' parameter
        String userDmd = null;
        if (params != null)
        {
            userDmd = params.getProperty("dmd");
        }
        if (userDmd != null && userDmd.length() > 0)
        {
            for (int i = 0; i < dmds.length; ++i)
            {
                if (userDmd.equalsIgnoreCase(manifest.getMdType(dmds[i])))
                {
                    found = i;
                }
            }
        }

        // DIM is preferred, if nothing specified by user
        if (found == -1)
        {
            // DIM is preferred for AIP
            for (int i = 0; i < dmds.length; ++i)
            {
                //NOTE: METS standard actually says this should be DIM (all uppercase). But,
                // just in case, we're going to be a bit more forgiving.
                if ("DIM".equalsIgnoreCase(manifest.getMdType(dmds[i])))
                {
                    found = i;
                }
            }
        }

        // MODS is acceptable otehrwise..
        if (found == -1)
        {
            for (int i = 0; i < dmds.length; ++i)
            {
                //NOTE: METS standard actually says this should be MODS (all uppercase). But,
                // just in case, we're going to be a bit more forgiving.
                if ("MODS".equalsIgnoreCase(manifest.getMdType(dmds[i])))
                {
                    found = i;
                }
            }
        }

        String groupID = null;
        if (found >= 0)
        {
            manifest.crosswalkItemDmd(context, params, dso, dmds[found], callback);
            groupID = dmds[found].getAttributeValue("GROUPID");

            if (groupID != null)
            {
                for (int i = 0; i < dmds.length; ++i)
                {
                    String g = dmds[i].getAttributeValue("GROUPID");
                    if (g != null && !g.equals(groupID))
                    {
                        manifest.crosswalkItemDmd(context, params, dso, dmds[i], callback);
                    }
                }
            }
        }

        // otherwise take the first.  Don't xwalk more than one because
        // each xwalk _adds_ metadata, and could add duplicate fields.
        else if (dmds.length > 0)
        {
            manifest.crosswalkItemDmd(context, params, dso, dmds[0], callback);
        }

        // it's an error if there is nothing to crosswalk:
        else
        {
            throw new MetadataValidationException("DSpaceAIPIngester: Could not find an acceptable object-wide DMD section in manifest.");
        }
    }


    /**
     * Ignore license when restoring an manifest-only AIP, since it should
     * be a bitstream in the AIP already.
     * Otherwise:  Check item for license first; then, take deposit
     * license supplied by explicit argument next, else use collection's
     * default deposit license.
     * Normally the rightsMD crosswalks should provide a license.
     */
    @Override
    public void addLicense(Context context, Item item, String license,
                                    Collection collection, PackageParameters params)
        throws PackageValidationException,
               AuthorizeException, SQLException, IOException
    {
        boolean newLicense = false;

        if(!params.restoreModeEnabled())
        {
            //AIP is not being restored/replaced, so treat it like a SIP -- every new SIP needs a new license
            newLicense = true;
        }

        // Add deposit license if there isn't one in the object,
        // and it's not a restoration of an "manifestOnly" AIP:
        if (!params.getBooleanProperty("manifestOnly", false) &&
            PackageUtils.findDepositLicense(context, item) == null)
        {
            newLicense = true;
        }

        if(newLicense)
        {
            PackageUtils.addDepositLicense(context, license, item, collection);
        }
    }

    /**
     * Last change to fix up a DSpace Object.
     * <P>
     * For AIPs, if the object is an Item, we may want to make sure all of its
     * metadata fields already exist in the database (otherwise, the database
     * will throw errors when we attempt to save/update the Item)
     *
     * @param context DSpace Context
     * @param dso DSpace object
     * @param params Packager Parameters
     */
    @Override
    public void finishObject(Context context, DSpaceObject dso, PackageParameters params)
        throws PackageValidationException, CrosswalkException,
         AuthorizeException, SQLException, IOException
    {
        if(dso.getType()==Constants.ITEM)
        {
            // Check if 'createMetadataFields' option is enabled (default=true)
            // This defaults to true as by default we should attempt to restore as much metadata as we can.
            // When 'createMetadataFields' is set to false, an ingest will fail if it attempts to ingest content to a missing metadata field.
            if (params.getBooleanProperty("createMetadataFields", true))
            {
                // We want to verify that all the Metadata Fields we've crosswalked
                // actually *exist* in the DB.  If not, we'll try to create them
                createMissingMetadataFields(context, (Item) dso);
            }
        }
    }

    /**
     * Nothing extra to do to bitstream after ingestion.
     */
    @Override
    public void finishBitstream(Context context,
                                                Bitstream bs,
                                                Element mfile,
                                                METSManifest manifest,
                                                PackageParameters params)
        throws MetadataValidationException, SQLException, AuthorizeException, IOException
    {
        // nothing to do.
    }

    /**
     * Return the type of DSpaceObject in this package; it is
     * in the TYPE attribute of the mets:mets element.
     */
    @Override
    public int getObjectType(METSManifest manifest)
        throws PackageValidationException
    {
        Element mets = manifest.getMets();
        String typeStr = mets.getAttributeValue("TYPE");
        if (typeStr == null || typeStr.length() == 0)
        {
            throw new PackageValidationException("Manifest is missing the required mets@TYPE attribute.");
        }
        if (typeStr.startsWith("DSpace "))
        {
            typeStr = typeStr.substring(7);
        }
        int type = Constants.getTypeID(typeStr);
        if (type < 0)
        {
            throw new PackageValidationException("Manifest has unrecognized value in mets@TYPE attribute: " + typeStr);
        }
        return type;
    }

    /**
     * Name used to distinguish DSpace Configuration entries for this subclass.
     */
    @Override
    public String getConfigurationName()
    {
        return "dspaceAIP";
    }

    /**
     * Verifies that all the unsaved, crosswalked metadata fields that have
     * been added to an Item actually exist in our Database.  If they don't
     * exist, they are created within the proper database tables.
     * <P>
     * This method must be called *before* item.update(), as the call to update()
     * will throw a SQLException when attempting to save any fields which
     * don't already exist in the database.
     * <P>
     * NOTE: This will NOT create a missing Metadata Schema (e.g. "dc" schema),
     * as we do not have enough info to create schemas on the fly.
     *
     * @param context - DSpace Context
     * @param item - Item whose unsaved metadata fields we are testing
     * @throws AuthorizeException if a metadata field doesn't exist and current user is not authorized to create it (i.e. not an Admin)
     * @throws PackageValidationException if a metadata schema doesn't exist, as we cannot autocreate a schema
     */
    protected static void createMissingMetadataFields(Context context, Item item)
        throws PackageValidationException, AuthorizeException, IOException, SQLException
    {
        // Get all metadata fields/values currently added to this Item
        DCValue allMD[] = item.getMetadata(Item.ANY, Item.ANY, Item.ANY, Item.ANY);

        // For each field, we'll check if it exists. If not, we'll create it.
        for(DCValue md : allMD)
        {
            MetadataSchema mdSchema = null;
            MetadataField mdField = null;
            try
            {
                //Try to access this Schema
                mdSchema = MetadataSchema.find(context, md.schema);
                //If Schema found, try to locate field from database
                if(mdSchema!=null)
                {
                    mdField = MetadataField.findByElement(context, mdSchema.getSchemaID(), md.element, md.qualifier);
                }
            }
            catch(SQLException se)
            {
                //If a SQLException error is thrown, then this field does NOT exist in DB
                //Set field to null, so we know we need to create it
                mdField = null;
            }

            // If our Schema was not found, we have a problem
            // We cannot easily create a Schema automatically -- as we don't know its Namespace
            if(mdSchema==null)
            {
                throw new PackageValidationException("Unknown Metadata Schema encountered (" + md.schema + ") when attempting to ingest an Item.  You will need to create this Metadata Schema in DSpace Schema Registry before the Item can be ingested.");
            }

            // If our Metadata Field is null, we will attempt to create it in the proper Schema
            if(mdField==null)
            {
                try
                {
                    //initialize field (but don't set a scope note) & create it
                    mdField = new MetadataField(mdSchema, md.element, md.qualifier, null);
                    // NOTE: Only Adminstrators can create Metadata Fields -- create() will throw an AuthorizationException for non-Admins
                    mdField.create(context);
                    //log that field was created
                    log.info("Located a missing metadata field (schema:'" + mdSchema.getName() +"', element:'"+ md.element +"', qualifier:'"+ md.qualifier +"') while ingesting Item.  This missing field has been created in the DSpace Metadata Field Registry.");
                }
                catch(NonUniqueMetadataException ne)
                {   // This exception should never happen, as we already checked to make sure the field doesn't exist.
                    // But, we'll catch it anyways so that the Java compiler doesn't get upset
                    throw new SQLException("Unable to create Metadata Field (element='" + md.element + "', qualifier='" + md.qualifier + "') in Schema "+ mdSchema.getName() +".", ne);
                }
            }
        }
    }

    /**
     * Returns a user help string which should describe the
     * additional valid command-line options that this packager
     * implementation will accept when using the <code>-o</code> or
     * <code>--option</code> flags with the Packager script.
     *
     * @return a string describing additional command-line options available
     * with this packager
     */
    @Override
    public String getParameterHelp()
    {
        String parentHelp = super.getParameterHelp();

        //Return superclass help info, plus the extra parameters/options that this class supports
        return parentHelp +
                "\n\n" +
                "* createMetadataFields=[boolean]      " +
                   "If true, ingest attempts to create any missing metadata fields." +
                   "If false, ingest will fail if a metadata field is encountered which doesn't already exist. (default = true)" +
                "\n\n" +
                "* dmd=[dmdSecType]      " +
                   "Type of the METS <dmdSec> which should be used to restore item metadata (defaults to DIM, then MODS)";
    }

    @Override
    public void postInstallHook(Context context, Item item) throws NonCriticalException, CriticalException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public boolean updateLicenceInfoInManifest(Context context, Item item, Bitstream bitstreamContainingManifest, InputStream manifestStream, boolean backupBitstream, String licenceUrl, String licenceName) throws SQLException, IOException, AuthorizeException, MetadataValidationException, CriticalException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public void updateEmbeddedLicence(Context context, Item item) throws NonCriticalException, CriticalException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

   

    @Override
    public WorkspaceItem ingest(Context context, Collection[] collections, InputStream in, PackageParameters params, String license) throws PackageException, CrosswalkException, AuthorizeException, SQLException, IOException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

}
