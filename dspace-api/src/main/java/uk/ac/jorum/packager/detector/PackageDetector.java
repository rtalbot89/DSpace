/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package uk.ac.jorum.packager.detector;

import org.dspace.content.Bitstream;
import org.dspace.content.packager.PackageIngester;

/**
 * @author gwaller
 *
 */
public interface PackageDetector {

	public boolean isValidPackage();
	
	public void setBitstream(Bitstream b);
	
	public Class<? extends PackageIngester> ingesterClass();
	
}
