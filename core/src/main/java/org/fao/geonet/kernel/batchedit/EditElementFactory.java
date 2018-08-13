package org.fao.geonet.kernel.batchedit;

import org.fao.geonet.constants.Geonet;
import org.fao.geonet.utils.Log;

public class EditElementFactory {

	public static EditElement getElementType(String type) {
		
		Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> type.toLowerCase(): " + type.toLowerCase());
		
		switch (type) {
		case Geonet.EditType.KEYWORD:
		case Geonet.EditType.KEYWORD_THESAURUS:
			return new KeywordEditElement();
		case Geonet.EditType.GEOBOX:
		case Geonet.EditType.VERTICAL:
		case Geonet.EditType.VERTICAL_CRS:
		case Geonet.EditType.TEMPORAL:
			return new ExtentEditElement();
		case Geonet.EditType.POINT_OF_CONTACT:
		case Geonet.EditType.RESPONSIBLE_PARTY:
			return new ContactEditElement();
		case Geonet.EditType.RES_LINKAGE:
		case Geonet.EditType.ASSOCIATED_RES:
		case Geonet.EditType.ADDITIONAL_INFO:
		case Geonet.EditType.TRANSFER_OPTION:
			return new OnlineResourceEditElement();
		case Geonet.EditType.DISTRIBUTION_FORMAT:
		case Geonet.EditType.RESOURCE_FORMAT:
			return new FormatEditElement();
		case Geonet.EditType.CITATION_DATE:
			return new DateEditElement();
		default:
			return null;
		}
	
	}

}
