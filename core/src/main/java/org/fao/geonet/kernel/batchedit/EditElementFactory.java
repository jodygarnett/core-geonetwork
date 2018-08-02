package org.fao.geonet.kernel.batchedit;

import org.fao.geonet.constants.Geonet;

public class EditElementFactory {

	public static EditElement getElementType(String type) {
		
		switch (type.toLowerCase()) {
		case Geonet.EditType.KEYWORD:
		case Geonet.EditType.KEYWORD_THESAURUS:
			return new KeywordEditElement();
		case Geonet.EditType.GEOBOX:
		case Geonet.EditType.VERTICAL:
		case Geonet.EditType.TEMPORAL:
			return new ExtentEditElement();
		case Geonet.EditType.CONTACT:
		case Geonet.EditType.RESPONSIBLE_PARTY:
			return new ContactEditElement();
		case Geonet.EditType.ONLINE_RES:
		case Geonet.EditType.ASSOCIATED_RES:
		case Geonet.EditType.ADDITIONAL_INFO:
			return new OnlineResourceEditElement();
		default:
			return null;
		}
		
		
		/*if (type.equalsIgnoreCase(Geonet.EditType.KEYWORD))
			return new KeywordEditElement();
		else if (type.equalsIgnoreCase(Geonet.EditType.GEOBOX))
			return new ExtentEditElement();
		else if (type.equalsIgnoreCase(Geonet.EditType.GEOBOX))
			return new ExtentEditElement();
		else if (type.equalsIgnoreCase(Geonet.EditType.CONTACT))
			return new ContactEditElement();*/

		//return null;
	}

}
