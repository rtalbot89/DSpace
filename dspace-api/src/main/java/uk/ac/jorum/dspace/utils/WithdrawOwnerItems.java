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
public class WithdrawOwnerItems extends CommandLineDelete{

	public void usage(){
		System.out.println("Usage: " + WithdrawOwnerItems.class.getCanonicalName() + " <admin email> <depositor email>");
		System.exit(1);
	}
	
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		WithdrawOwnerItems instance = new WithdrawOwnerItems();
		
		if (args.length != 2){
			instance.usage();
		}
		
		try{
			instance.performDelete(false, true, args[0], args[1]);
		} catch (Exception e){
			e.printStackTrace();
		}
		


	}

}
