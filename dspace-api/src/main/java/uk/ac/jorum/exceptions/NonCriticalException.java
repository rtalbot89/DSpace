/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package uk.ac.jorum.exceptions;

/**
 * An instance of this class denotes an exception which is not critical and can result in continuation of the thread on it's normal path. The 
 * Exception should probably be logged however.
 * @author gwaller
 *
 */
public class NonCriticalException extends Exception {

	public NonCriticalException(String message){
		super(message);
	}
	
	public NonCriticalException(String message, Throwable e){
		super(message, e);
	}
	
}
