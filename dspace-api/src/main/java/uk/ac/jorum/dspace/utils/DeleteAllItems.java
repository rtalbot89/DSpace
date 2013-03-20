/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *
/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package uk.ac.jorum.dspace.utils;



/**
 * @author gwaller
 *
 */
public class DeleteAllItems extends CommandLineDelete{

	public void usage(){
		System.out.println("Usage: " + DeleteAllItems.class.getCanonicalName() + " <admin email>");
		System.exit(1);
	}
	
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		DeleteAllItems instance = new DeleteAllItems();
		
		if (args.length != 1){
			instance.usage();
		}
		
		try{
			
			System.out.println();
			System.out.println();
			System.out.println("**************************************");
			System.out.println("*");
			System.out.println("*  !!!!  WARNING  !!!!");
			System.out.println("*");
			System.out.println("* This utility will erase ALL items from DSpace");
			System.out.println("*");
			System.out.println("**************************************");
			System.out.println();
			System.out.println();
			
			instance.performDelete(true, false, args[0], null);
		} catch (Exception e){
			e.printStackTrace();
		}
		


	}

}
