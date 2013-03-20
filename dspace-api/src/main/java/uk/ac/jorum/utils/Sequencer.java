/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package uk.ac.jorum.utils;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author gwaller
 *
 */
public class Sequencer {

	private static Sequencer instance = new Sequencer();
	
	private AtomicInteger sequenceNumber = new AtomicInteger(0);
	
	private Sequencer(){
		
	}
	
	public static Sequencer getInstance(){
		return instance;
	}
	
	public int next() { 
		return sequenceNumber.getAndIncrement(); 
	}
	
	
}
