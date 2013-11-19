/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package uk.ac.jorum.packager.detector;

import org.dspace.content.Bitstream;
import org.dspace.content.packager.AbstractMETSIngester;
import org.dspace.content.packager.DSpaceMETSIngester;
import org.dspace.content.packager.PackageIngester;
import org.jdom.Document;


/**
 * @author gwaller
 *
 */
public class METSPackageDetector extends BasePackageDetector{

	public METSPackageDetector(Bitstream b){
		this.setBitstream(b);
	}
	
	public METSPackageDetector(){
		super();
	}
	
	/* (non-Javadoc)
	 * @see uk.ac.jorum.packager.detector.BasePackageDetector#isValidPackage()
	 */
	@Override
	public boolean isValidPackage() {
		
		Document manifest = this.containsManifest(AbstractMETSIngester.MANIFEST_FILE);
		
		/*
		 * NOTE:
		 * This isn't the most efficient way of using the manifest - it is parsed on the above step
		 * and then in the actual ingester it is parsed again. Need to refactor and pass in this already
		 * parsed instance.
		 */
		
		return (manifest != null);
	}

	/* (non-Javadoc)
	 * @see uk.ac.jorum.packager.detector.BasePackageDetector#ingesterClass()
	 */
	@Override
	public Class<? extends PackageIngester> ingesterClass() {
		return DSpaceMETSIngester.class;
	}

	
	
}
