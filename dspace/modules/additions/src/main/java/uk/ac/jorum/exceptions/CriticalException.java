/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package uk.ac.jorum.exceptions;

/**
 * An instance of this class denotes an exception which is critical which demands action e.g. removing an installed item, DB rollback etc.
 * @author gwaller
 *
 */
public class CriticalException extends Exception {

	public CriticalException(String message){
		super(message);
	}
	
	public CriticalException(String message, Throwable e){
		super(message, e);
	}
	
}
