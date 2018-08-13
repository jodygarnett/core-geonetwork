package org.fao.geonet.kernel.batchedit;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map.Entry;

import org.apache.commons.csv.CSVRecord;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.utils.Log;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.output.XMLOutputter;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;

import jeeves.server.context.ServiceContext;

public class FormatEditElement implements EditElement {

	XMLOutputter out = new XMLOutputter();

	@Override
	public void removeAndAddElement(CSVBatchEdit batchEdit, ApplicationContext context, ServiceContext serContext,
			Entry<String, Integer> header, CSVRecord csvr, XPath _xpath, List<BatchEditParameter> listOfUpdates)
			throws JDOMException, IOException {

		String headerVal = header.getKey();

		String[] contents = csvr.get(headerVal).split(content_separator);

		Log.debug(Geonet.SEARCH_ENGINE, "format contents length: " + contents.length);
		for (String content : contents) {
			String[] values = content.split(type_separator);
			Log.debug(Geonet.SEARCH_ENGINE, "format values length: " + values.length);

			String title = "", edition = "";

			if (values.length > 0)
				title = values[0];
			if (values.length > 1)
				edition = values[1];

			Element rootE = null;
			if (Geonet.EditType.DISTRIBUTION_FORMAT.equalsIgnoreCase(headerVal)) {
				rootE = getDistributionFormatElement(title, edition);
			} else if (Geonet.EditType.RESOURCE_FORMAT.equalsIgnoreCase(headerVal)) {
				rootE = getResourceFormatElement(title, edition);
			}

			if(rootE != null){
				String strEle = out.outputString(rootE);
	
				Log.debug(Geonet.SEARCH_ENGINE, "OnlineResource EditElement --> strEle : " + strEle);
	
				String _val = "<gn_add>" + strEle + "</gn_add>";
	
				BatchEditParameter e = new BatchEditParameter(_xpath.getXPath(), _val);
				listOfUpdates.add(e);
			}
		}
	}

	private Element getResourceFormatElement(String title, String edition) {
		Element resFormat = new Element("resourceFormat", Geonet.Namespaces.MRI);
		return resFormat.addContent(formatElement(title, edition));
	}

	private Element getDistributionFormatElement(String title, String edition) {
		Element disFormat = new Element("distributionFormat", Geonet.Namespaces.MRD);
		return disFormat.addContent(formatElement(title, edition));
	}

	private Element formatElement(String title, String edition) {
		Element format = new Element("MD_Format", Geonet.Namespaces.MRD);

		Element formatSpec = new Element("formatSpecificationCitation", Geonet.Namespaces.MRD);
		Element citation = new Element("CI_Citation", Geonet.Namespaces.CIT);

		Element _title = new Element("title", Geonet.Namespaces.CIT);
		_title.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(title));

		Element _edition = new Element("edition", Geonet.Namespaces.CIT);
		_edition.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(edition));

		format.addContent(formatSpec.addContent(citation.addContent(Arrays.asList(_title, _edition))));

		return format;
	}

}
