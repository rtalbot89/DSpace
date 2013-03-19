/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package uk.ac.jorum.packager;

import java.io.IOException;
import java.io.InputStream;

import org.dspace.content.crosswalk.MetadataValidationException;

/**
 * @author gwaller
 *
 */
public class SCORMIngester extends IMSIngester {

	/* (non-Javadoc)
	 * @see uk.ac.jorum.packager.IMSIngester#createManifest(java.io.InputStream, boolean)
	 */
	@Override
	protected XMLManifest createManifest(InputStream is, boolean validate) throws IOException,
			MetadataValidationException {
		return SCORMManifest.create(is, validate);
	}

	
	
}
