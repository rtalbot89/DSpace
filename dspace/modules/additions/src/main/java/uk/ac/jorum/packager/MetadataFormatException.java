/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package uk.ac.jorum.packager;

import org.dspace.content.crosswalk.MetadataValidationException;
import org.jdom.Element;

/**
 * @author gwaller
 *
 */
public class MetadataFormatException extends MetadataValidationException {

	public MetadataFormatException(Element elem){
		super("Unsupported metadata format found - cannot find match for namespace " + elem.getNamespace().toString());
	}
	
	public MetadataFormatException(){
		super("Unable to determine metadata format. Perhaps metadata elements cannot be found.");
	}
	
}
