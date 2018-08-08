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

public class OnlineResourceEditElement implements EditElement{

	XMLOutputter out = new XMLOutputter();
	
	@Override
	public void removeAndAddElement(ApplicationContext context, ServiceContext serContext, Entry<String, Integer> header, CSVRecord csvr, 
			XPath _xpath, List<BatchEditParameter> listOfUpdates)
			throws JDOMException, IOException {
		
		String headerVal = header.getKey();
		
		String[] contents = csvr.get(headerVal).split(content_separator);
		Log.debug(Geonet.SEARCH_ENGINE, "online resource contents length: " + contents.length);
		for (String content : contents) {
			String[] values = content.split(type_separator);
			Log.debug(Geonet.SEARCH_ENGINE, "extents values length: " + values.length);
			
			String name = "", desc = "", linkage = "";
			
			if(values.length > 0)
				name = values[0];
			if(values.length > 1)
				desc = values[1];
			if(values.length > 2)
				linkage = values[2];
			
			Element rootE;
			if(Arrays.asList(Geonet.EditType.ONLINE_RES, Geonet.EditType.ASSOCIATED_RES).contains(headerVal.toLowerCase())){
				rootE = getOnlineResourceElement(name, desc, linkage);
			}else if(Geonet.EditType.ASSOCIATED_RES.equalsIgnoreCase(headerVal)){
				rootE = additionalInformation(name, desc, linkage);
			}else{
				rootE = getOnlineElement(name, desc, linkage);
			}
			
			String strEle = out.outputString(rootE);
			
			Log.debug(Geonet.SEARCH_ENGINE, "OnlineResource EditElement --> strEle : " + strEle);
			
			String _val = "<gn_add>" + strEle + "</gn_add>";
			
			BatchEditParameter e = new BatchEditParameter(_xpath.getXPath(), _val);
			listOfUpdates.add(e);
		}
		
	}

	private Element getOnlineResourceElement(String _name, String description, String link) throws IOException {
		
		Element onlineResource = new Element("onlineResource", Geonet.Namespaces.CIT);
		
		onlineResource.addContent(onlineResElement(_name, description, link));

		// out.output(descK, System.out);
		return onlineResource;

	}
	
	private Element getOnlineElement(String _name, String description, String link) throws IOException {
		
		
		Element online = new Element("onLine", Geonet.Namespaces.MRD);
		
		online.addContent(onlineResElement(_name, description, link));
		
		// out.output(descK, System.out);
		return online;

	}

	private Element additionalInformation(String _name, String description, String link){
		Element addInfo = new Element("additionalDocumentation", Geonet.Namespaces.MRI);
		Element citation = new Element("CI_Citation", Geonet.Namespaces.CIT);
		Element title = new Element("title", Geonet.Namespaces.CIT);
		
		citation.addContent(title.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(_name)));
		citation.addContent(onlineResElement(_name, description, link));
		addInfo.addContent(citation);
		
		return addInfo;
	}
	private Element onlineResElement(String _name, String description, String link){
		Element onlineRes = new Element("CI_OnlineResource", Geonet.Namespaces.CIT);

		Element linkage = new Element("linkage", Geonet.Namespaces.CIT);
		linkage.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(link));
		
		Element protocol = new Element("protocol", Geonet.Namespaces.CIT);
		protocol.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText("WWW:LINK-1.0-http--link"));
		
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
	}
}
