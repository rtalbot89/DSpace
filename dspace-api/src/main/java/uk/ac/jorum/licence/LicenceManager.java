/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package uk.ac.jorum.licence;

/**
 * @author gwaller
 *
 */
public interface LicenceManager {
	
	public String getSectionName();
	
	public ItemLicence[] getInstalledLicences();
	
	public ItemLicence[] getInstalledLicencesInDisplayOrder();
		
}
