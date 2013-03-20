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
public class WithdrawAllItems extends CommandLineDelete{

	public void usage(){
		System.out.println("Usage: " + WithdrawAllItems.class.getCanonicalName() + " <admin email>");
		System.exit(1);
	}
	
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		WithdrawAllItems instance = new WithdrawAllItems();
		
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
			System.out.println("* This utility will withdraw ALL items from DSpace");
			System.out.println("*");
			System.out.println("**************************************");
			System.out.println();
			System.out.println();
			
			instance.performDelete(true, true, args[0], null);
		} catch (Exception e){
			e.printStackTrace();
		}
		


	}

}
