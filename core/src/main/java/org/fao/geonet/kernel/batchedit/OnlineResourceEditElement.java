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
public class OnlineResourceEditElement implements EditElement {

	XMLOutputter out = new XMLOutputter();

	@Override
	public void removeAndAddElement(CSVBatchEdit batchEdit, ApplicationContext context, ServiceContext serContext,
			Entry<String, Integer> header, CSVRecord csvr, XPath _xpath, List<BatchEditParam> listOfUpdates, BatchEditReport report) {

		String headerVal = header.getKey();

		String[] contents = csvr.get(headerVal).split(content_separator);
		Log.debug(Geonet.SEARCH_ENGINE, "online resource contents length: " + contents.length);
		for (String content : contents) {
			String[] values = content.split(type_separator);
			Log.debug(Geonet.SEARCH_ENGINE, "extents values length: " + values.length);

			String name = "", desc = "", linkage = "";

			if (values.length > 0)
				name = values[0];
			if (values.length > 1)
				desc = values[1];
			if (values.length > 2)
				linkage = values[2];

			Element rootE = null;

			try {
				if (Arrays.asList(Geonet.EditType.DATA_STORAGE_LINK, Geonet.EditType.ASSOCIATED_RES).contains(headerVal)) {
					rootE = getOnlineResourceElement(name, desc, linkage);
				} else if (Geonet.EditType.ADDITIONAL_INFO.equalsIgnoreCase(headerVal)) {
					rootE = additionalInformation(name, desc, linkage);
				} else if (Geonet.EditType.DISTRIBUTION_LINK.equalsIgnoreCase(headerVal)){
					rootE = getOnlineElement(name, desc, linkage);
				}
			} catch (BatchEditException e) {
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

	private Element getOnlineResourceElement(String _name, String description, String link) throws BatchEditException {
		try{
			Element onlineResource = new Element("onlineResource", Geonet.Namespaces.CIT);
	
			onlineResource.addContent(onlineResElement(_name, description, link));
			return onlineResource;
			
		}catch(BatchEditException e){
			throw new BatchEditException("Unable to process Online Resource Element having name " + _name + " and link " + link);
		}
	}

	private Element getOnlineElement(String _name, String description, String link) throws BatchEditException {
		try{
			Element online = new Element("onLine", Geonet.Namespaces.MRD);
	
			online.addContent(onlineResElement(_name, description, link));
	
			return online;
		}catch(BatchEditException e){
			throw new BatchEditException("Unable to process Online Element..", e);
		}
	}

	private Element additionalInformation(String _name, String description, String link) throws BatchEditException {
		try{
			Element addInfo = new Element("additionalDocumentation", Geonet.Namespaces.MRI);
			Element citation = new Element("CI_Citation", Geonet.Namespaces.CIT);
			Element onlineres = new Element("onlineResource", Geonet.Namespaces.CIT);
			Element title = new Element("title", Geonet.Namespaces.CIT);
	
			citation.addContent(title.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(_name)));
			citation.addContent(onlineres.addContent(onlineResElement(_name, description, link)));
			addInfo.addContent(citation);
		
			return addInfo;
			
		}catch(BatchEditException e){
			throw new BatchEditException("Unable to process additional Information having name " + _name + " and link " + link);
		}
	}

	private Element onlineResElement(String _name, String description, String link) throws BatchEditException {

		try {
			Element onlineRes = new Element("CI_OnlineResource", Geonet.Namespaces.CIT);

			Element linkage = new Element("linkage", Geonet.Namespaces.CIT);
			linkage.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(link));

			Element protocol = new Element("protocol", Geonet.Namespaces.CIT);
			protocol.addContent(
					new Element("CharacterString", Geonet.Namespaces.GCO_3).setText("WWW:LINK-1.0-http--link"));

			Element name = new Element("name", Geonet.Namespaces.CIT);
			name.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(_name));

			Element desc = new Element("description", Geonet.Namespaces.CIT);
			desc.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(description));

			Element function = new Element("function", Geonet.Namespaces.CIT);
			Element cl = new Element("CI_OnLineFunctionCode", Geonet.Namespaces.CIT);
			cl.setAttribute("codeList", "codeListLocation#CI_OnLineFunctionCode");
			cl.setAttribute("codeListValue", "information");
			function.addContent(cl);

			onlineRes.addContent(Arrays.asList(linkage, protocol, name, desc, function));

			return onlineRes;
		} catch (Exception e) {
			throw new BatchEditException("Unable to process onlineRes Element having name " + _name + " and link " + link);
		}
	}
}
