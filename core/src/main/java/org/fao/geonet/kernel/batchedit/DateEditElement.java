package org.fao.geonet.kernel.batchedit;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map.Entry;

import org.apache.commons.csv.CSVRecord;
import org.fao.geonet.constants.Geonet;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.output.XMLOutputter;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;

import jeeves.server.context.ServiceContext;

public class DateEditElement implements EditElement{

	XMLOutputter out = new XMLOutputter();
	
	@Override
	public void removeAndAddElement(CSVBatchEdit batchEdit, ApplicationContext context, ServiceContext serContext,
			Entry<String, Integer> header, CSVRecord csvr, XPath _xpath, List<BatchEditParameter> listOfUpdates)
			throws JDOMException, IOException {
		
		String headerVal = header.getKey();
		
		String[] contents = csvr.get(headerVal).split(content_separator);
		
		for (String content : contents) {
			String[] values = content.split(type_separator);

			Element rootE = null;
			if(headerVal.equalsIgnoreCase(Geonet.EditType.CITATION_DATE))
				rootE = getCitationDateElement(batchEdit, values);
			
			String strEle = out.outputString(rootE);
			
			//Log.debug(Geonet.SEARCH_ENGINE, "GeoBoxEditElement --> strEle : " + strEle);
			
			String _val = "<gn_add>" + strEle + "</gn_add>";

			BatchEditParameter e = new BatchEditParameter(_xpath.getXPath(), _val);
			listOfUpdates.add(e);
	
		}
		
	}

	private Element getCitationDateElement(CSVBatchEdit batchEdit, String[] values) {
		
		Element date = new Element("date", Geonet.Namespaces.CIT);
		Element ciDate = new Element("CI_Date", Geonet.Namespaces.CIT);
		Element date1 = new Element("date", Geonet.Namespaces.CIT);
		Element dateType = new Element("dateType", Geonet.Namespaces.CIT);
		
		if (values.length > 0){
			String dateStr = "Date";
			String dateVal = values[0];
			if(dateVal.contains("T")){
				dateStr = "DateTime";
			}
			date1.addContent(new Element(dateStr, Geonet.Namespaces.GCO_3).setText(values[0]));
		}

		if (values.length > 1){
			String clval = values[1];
			Element typeAttr = new Element("CI_DateTypeCode", Geonet.Namespaces.CIT);
			typeAttr.setAttribute("codeList", "codeListLocation#CI_DateTypeCode");
			if(clval.contains(" ")){
				clval = batchEdit.toTitleCase(clval);
			}
			typeAttr.setAttribute("codeListValue", clval);
			dateType.addContent(typeAttr);
		}
		
		date.addContent(ciDate.addContent(Arrays.asList(date1, dateType)));
		
		return date;
	}

}
