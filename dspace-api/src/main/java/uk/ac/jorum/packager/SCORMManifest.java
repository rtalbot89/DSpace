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
import java.util.Iterator;
import java.util.List;

import org.dspace.content.crosswalk.MetadataValidationException;
import org.jdom.Attribute;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;

import uk.ac.jorum.packager.detector.SCORMPackageDetector;

/**
 * @author gwaller
 *
 */
public class SCORMManifest extends IMSManifest {

	public SCORMManifest(Document manifestDoc) {
		super(manifestDoc);
	}

	/**
	 * Create a new manifest object from a serialized IMS manifest XML document.
	 * Parse document read from the input stream, optionally validating.
	 * @param is input stream containing serialized XML
	 * @param validate if true, enable XML validation using schemas
	 *   in document.  Also validates any sub-documents.
	 * @throws MetadataValidationException if there is any error parsing
	 *          or validating the METS.
	 * @return new XMLManifest object.
	 */
	public static XMLManifest create(InputStream is, boolean validate) throws IOException, MetadataValidationException {
		return new SCORMManifest(parseManifest(is, validate));
	}

}
