//==============================================================================
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Joseph John,
//===	Canberra - Australia. email: joseph.john@ga.gov.au
//==============================================================================
package org.fao.geonet.kernel.batchedit;

import java.util.Arrays;
import java.util.List;
import java.util.Map.Entry;

import org.apache.commons.csv.CSVRecord;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.exceptions.BatchEditException;
import org.fao.geonet.utils.Log;
import org.jdom.Element;
import org.jdom.output.XMLOutputter;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;

import jeeves.server.context.ServiceContext;

/**
 * 
 * @author Joseph John - U89263
 *
 */
public class FormatEditElement implements EditElement {

	XMLOutputter out = new XMLOutputter();

	@Override
	public void removeAndAddElement(CSVBatchEdit batchEdit, ApplicationContext context, ServiceContext serContext,
			Entry<String, Integer> header, CSVRecord csvr, XPath _xpath, List<BatchEditParam> listOfUpdates, BatchEditReport report) {

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
			
			try{
				
				/*if (Geonet.EditType.DISTRIBUTION_FORMAT.equalsIgnoreCase(headerVal)) {
					rootE = getDistributionFormatElement(title, edition);
				} else if (Geonet.EditType.RESOURCE_FORMAT.equalsIgnoreCase(headerVal)) {
					rootE = getResourceFormatElement(title, edition);
				}*/
				
				rootE = formatElement(title, edition);
				
			}catch(BatchEditException e){
				report.getErrorInfo().add(e.getMessage());
			}
			
			if(rootE != null){
				String strEle = out.outputString(rootE);
	
				Log.debug(Geonet.SEARCH_ENGINE, "OnlineResource EditElement --> strEle : " + strEle);
	
				String _val = "<gn_add>" + strEle + "</gn_add>";
	
				BatchEditParam e = new BatchEditParam(_xpath.getXPath(), _val);
				listOfUpdates.add(e);
			}
		}
	}

	private Element getResourceFormatElement(String title, String edition) throws BatchEditException {
		Element resFormat = new Element("resourceFormat", Geonet.Namespaces.MRI);
		return resFormat.addContent(formatElement(title, edition));
	}

	private Element getDistributionFormatElement(String title, String edition) throws BatchEditException {
		Element disFormat = new Element("distributionFormat", Geonet.Namespaces.MRD);
		return disFormat.addContent(formatElement(title, edition));
	}

	private Element formatElement(String title, String edition) throws BatchEditException {
		try{
			//Element format = new Element("MD_Format", Geonet.Namespaces.MRD);
	
			//Element formatSpec = new Element("formatSpecificationCitation", Geonet.Namespaces.MRD);
			Element citation = new Element("CI_Citation", Geonet.Namespaces.CIT);
	
			Element _title = new Element("title", Geonet.Namespaces.CIT);
			_title.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(title));
	
			Element _edition = new Element("edition", Geonet.Namespaces.CIT);
			_edition.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(edition));
	
			//format.addContent(formatSpec.addContent(citation.addContent(Arrays.asList(_title, _edition))));
			//formatSpec.addContent(citation.addContent(Arrays.asList(_title, _edition)));
			citation.addContent(Arrays.asList(_title, _edition));
			
			return citation;
		} catch (Exception e) {
			throw new BatchEditException("Unable to process Format Element having title: " + title);
		}
	}

}
