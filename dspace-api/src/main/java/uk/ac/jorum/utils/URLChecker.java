/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package uk.ac.jorum.utils;

/**
 * @author gwaller
 *
 */
public class URLChecker {

	// GWaller 17/11/09 Added support for feed urls
	public static final String[] URL_SCHEMES = {"http://", "https://", "ftp://", "feed://"}; 
	
	
	/**
	 * Checkes the supplied String and 
	 * @param url
	 * @return
	 */
	public static int isURL(String url){
		int result = 0;
		
		for (String scheme : URL_SCHEMES){
			if (url.regionMatches(true, 0, scheme, 0, scheme.length())){
				result = scheme.length();
			}
		}
		
		return result;
	}
	
}
