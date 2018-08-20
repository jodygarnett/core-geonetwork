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

import java.io.IOException;
import java.io.StringReader;
import java.util.Arrays;
import java.util.List;
import java.util.Map.Entry;

import org.apache.commons.csv.CSVRecord;
import org.apache.commons.lang.math.NumberUtils;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.Metadata;
import org.fao.geonet.exceptions.BatchEditException;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.output.XMLOutputter;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;

import jeeves.server.context.ServiceContext;

/**
 * 
 * @author Joseph John - U89263
 *
 */
public class MetadataEditElement implements EditElement {

	XMLOutputter out = new XMLOutputter();
	SAXBuilder sb = new SAXBuilder();
	
	@Override
	public void removeAndAddElement(CSVBatchEdit batchEdit, ApplicationContext context, ServiceContext serContext,
			Entry<String, Integer> header, CSVRecord csvr, XPath _xpath, List<BatchEditParam> listOfUpdates, BatchEditReport report) {

		String headerVal = header.getKey();

		String[] names = csvr.get(headerVal).split(content_separator);

		for (String name : names) {

			String[] values = name.split(type_separator);

			Element rootE = null;

			try {
				if(headerVal.equalsIgnoreCase(Geonet.EditType.MD_SCOPE))
					rootE = getMdScopeElement(values);
				if(headerVal.equalsIgnoreCase(Geonet.EditType.MD_PARENT))
					rootE = getMdparentElement(context, serContext, batchEdit, values);
			} catch (BatchEditException e) {
				report.getErrorInfo().add(e.getMessage());
			}

			if (rootE != null) {
				String strEle = out.outputString(rootE);

				String _val = "<gn_add>" + strEle + "</gn_add>";
				BatchEditParam e = new BatchEditParam(_xpath.getXPath(), _val);
				listOfUpdates.add(e);
			}

		}

	}

	private Element getMdScopeElement(String[] scopeCodes) throws BatchEditException {

		String value = "", codelist = "";
		if (scopeCodes.length > 0) {
			value = scopeCodes[0];
		}
		if (scopeCodes.length > 1) {
			codelist = scopeCodes[1];
		}
		
		try {
			
			Element mdScope = new Element("metadataScope", Geonet.Namespaces.MDB);
			Element _mdScope = new Element("MD_MetadataScope", Geonet.Namespaces.MDB);
			Element resScope = new Element("resourceScope", Geonet.Namespaces.MDB);

			Element cl = new Element("MD_ScopeCode", Geonet.Namespaces.MCC);
			cl.setAttribute("codeList", "codeListLocation#MD_ScopeCode");
			cl.setAttribute("codeListValue", codelist);

			Element name = new Element("name", Geonet.Namespaces.MDB);
			Element ch = new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(value);

			mdScope.addContent(_mdScope.addContent(Arrays.asList(resScope.addContent(cl), name.addContent(ch))));

			return mdScope;
		} catch (Exception e) {
			throw new BatchEditException("Unable to process Metadata Scope Element having value " + value);
		}

	}
	
	private Element getMdparentElement(ApplicationContext context, ServiceContext serContext, CSVBatchEdit batchEdit, String[] values) throws BatchEditException {

		String id = "";
		if (values.length <= 0) {
			throw new BatchEditException("Unable to process Parent Metadata Element, no valid eCatId/uuid provided.");
		}
		
		try {
			id = values[0];
			Element mdparent = new Element("parentMetadata", Geonet.Namespaces.MDB);
			Metadata md = null;
			Element request = null;
			String eCatId = "";
			if(NumberUtils.isDigits(id)){
				eCatId = id;
				request = Xml.loadString(
						"<request><isAdmin>true</isAdmin><_isTemplate>n</_isTemplate><eCatId>" + id + "</eCatId><fast>index</fast></request>",
						false);
			}else{
				request = Xml.loadString(
						"<request><isAdmin>true</isAdmin><_isTemplate>n</_isTemplate><uuid>" + id + "</uuid><fast>index</fast></request>",
						false);
			}
			
			md = batchEdit.getMetadataByLuceneSearch(context, serContext, request);	
			
			mdparent.addContent(getParentCitationElement(md, eCatId));
			
			return mdparent;
		} catch (Exception e) {
			throw new BatchEditException("Unable to process Parent Metadata Element for uuid/ecatId: " + id);
		}

	}
	
	private Element getParentCitationElement(Metadata md, String eCatId) throws BatchEditException {

		Element citation = new Element("CI_Citation", Geonet.Namespaces.CIT);
		String parent_title = "";
		try {
			Document document = sb.build(new StringReader(md.getData()));
			XPath _xpath = XPath.newInstance("//mdb:identificationInfo/*/mri:citation/*/cit:title/gco:CharacterString");
			Element element = (Element) _xpath.selectSingleNode(document);
			if(element != null){
				parent_title = element.getText();
			}
		} catch (Exception e) {
			Log.error(Geonet.SEARCH_ENGINE, "unable to build document for getting parent title");
		} 
		
		Element title = new Element("title", Geonet.Namespaces.CIT);
		Log.debug(Geonet.SEARCH_ENGINE, "ParentCitationElement --> title --> " + parent_title);
		title.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(parent_title));
		
		Element date = new Element("date", Geonet.Namespaces.CIT);
		Element ciDate = new Element("CI_Date", Geonet.Namespaces.CIT);
		Element date1 = new Element("date", Geonet.Namespaces.CIT);
		Element dateType = new Element("dateType", Geonet.Namespaces.CIT);

		try {
			
			date1.addContent(new Element("DateTime", Geonet.Namespaces.GCO_3).setText(md.getDataInfo().getCreateDate().getDateAndTime()));
			
			Element typeAttr = new Element("CI_DateTypeCode", Geonet.Namespaces.CIT);
			typeAttr.setAttribute("codeList", "codeListLocation#CI_DateTypeCode");
			typeAttr.setAttribute("codeListValue", "creation");
			dateType.addContent(typeAttr);
			
			date.addContent(ciDate.addContent(Arrays.asList(date1, dateType)));

			citation.addContent(Arrays.asList(title, date));
			
			citation.addContent(getMdIdentifierElement(md, md.getUuid(), "UUID"));
			citation.addContent(getMdIdentifierElement(md, eCatId, "eCatId"));
			
			return citation;
		} catch (Exception e) {
			throw new BatchEditException("Unable to process Citation Date Element");
		}
	}
	
	private Element getMdIdentifierElement(Metadata md, String id, String idType) throws BatchEditException {

		Element identifier = new Element("identifier", Geonet.Namespaces.CIT);
		Element mdId = new Element("MD_Identifier", Geonet.Namespaces.MCC);
		Element code = new Element("code", Geonet.Namespaces.MCC);
		Element desc = new Element("description", Geonet.Namespaces.MCC);
		Element fileName = new Element("FileName", Geonet.Namespaces.GCX);

		try {
			
			fileName.setAttribute("src", "").setText(id);
			code.addContent(fileName);
			desc.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(idType));
			identifier.addContent(mdId.addContent(Arrays.asList(code, desc)));

			return identifier;
		} catch (Exception e) {
			throw new BatchEditException("Unable to process Metadata Parent Identifier Element");
		}
	}
}
