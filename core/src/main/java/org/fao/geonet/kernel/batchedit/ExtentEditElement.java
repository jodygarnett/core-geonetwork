package org.fao.geonet.kernel.batchedit;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map.Entry;

import org.apache.commons.csv.CSVRecord;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.utils.Log;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.output.XMLOutputter;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;

import jeeves.server.context.ServiceContext;

public class ExtentEditElement implements EditElement {

	XMLOutputter out = new XMLOutputter();
	
	@Override
	public void removeAndAddElement(ApplicationContext context, ServiceContext serContext, Entry<String, Integer> header, CSVRecord csvr, XPath _xpath, 
			List<BatchEditParameter> listOfUpdates) throws IOException {


		String headerVal = header.getKey();
		
		String[] contents = csvr.get(headerVal).split(content_separator);
		
		for (String content : contents) {
			String[] values = content.split(type_separator);

			Element rootE = null;
			if(headerVal.equalsIgnoreCase(Geonet.EditType.GEOBOX))
				rootE = getGeographicBoundingBox(values);
			if(headerVal.equalsIgnoreCase(Geonet.EditType.VERTICAL))
				rootE = getVerticalExtent(values);
			if(headerVal.equalsIgnoreCase(Geonet.EditType.TEMPORAL))
				rootE = getTemporalExtent(values);
			
			String strEle = out.outputString(rootE);
			
			//Log.debug(Geonet.SEARCH_ENGINE, "GeoBoxEditElement --> strEle : " + strEle);
			
			String _val = "<gn_add>" + strEle + "</gn_add>";

			BatchEditParameter e = new BatchEditParameter(_xpath.getXPath(), _val);
			listOfUpdates.add(e);
	
		}
				
	}
	
	private Element getGeographicBoundingBox(String[] value) throws IOException {

		Element ex = new Element("extent", Geonet.Namespaces.MRI);
		Element exEx = new Element("Ex_Extent", Geonet.Namespaces.GEX);
		Element geoE = new Element("geographicElement", Geonet.Namespaces.GEX);
		Element exGeoE = new Element("EX_GeographicBoundingBox", Geonet.Namespaces.GEX);

		Element westBL = new Element("westBoundLongitude", Geonet.Namespaces.GEX);
		Element eastBL = new Element("eastBoundLongitude", Geonet.Namespaces.GEX);
		Element southtBL = new Element("southBoundLatitude", Geonet.Namespaces.GEX);
		Element northBL = new Element("northBoundLatitude", Geonet.Namespaces.GEX);

		if (value.length > 0)
			westBL.addContent(new Element("Decimal", Geonet.Namespaces.GCO_3).setText(value[0]));

		if (value.length > 1)
			eastBL.addContent(new Element("Decimal", Geonet.Namespaces.GCO_3).setText(value[1]));

		if (value.length > 2)
			southtBL.addContent(new Element("Decimal", Geonet.Namespaces.GCO_3).setText(value[2]));

		if (value.length > 3)
			northBL.addContent(new Element("Decimal", Geonet.Namespaces.GCO_3).setText(value[3]));

		exGeoE.addContent(Arrays.asList(westBL, eastBL, southtBL, northBL));
		ex.addContent(exEx.addContent(geoE.addContent(exGeoE)));

		// out.output(ex, System.out);
		return ex;

	}
	
	private Element getVerticalExtent(String[] value) throws IOException {

		Element ex = new Element("extent", Geonet.Namespaces.MRI);
		Element exEx = new Element("Ex_Extent", Geonet.Namespaces.GEX);
		Element vertE = new Element("verticalElement", Geonet.Namespaces.GEX);
		Element exVertE = new Element("EX_VerticalExtent", Geonet.Namespaces.GEX);

		Element min = new Element("minimumValue", Geonet.Namespaces.GEX);
		Element max = new Element("maximumValue", Geonet.Namespaces.GEX);

		if (value.length > 0)
			min.addContent(new Element("Real", Geonet.Namespaces.GCO_3).setText(value[0]));

		if (value.length > 1)
			max.addContent(new Element("Real", Geonet.Namespaces.GCO_3).setText(value[1]));

		exVertE.addContent(Arrays.asList(min, max));
		ex.addContent(exEx.addContent(vertE.addContent(exVertE)));

		// out.output(ex, System.out);
		return ex;

	}
	
	private Element getTemporalExtent(String[] value) throws IOException {

		Element ex = new Element("extent", Geonet.Namespaces.MRI);
		Element exEx = new Element("Ex_Extent", Geonet.Namespaces.GEX);
		Element tempE = new Element("temporalElement", Geonet.Namespaces.GEX);
		Element exTempE = new Element("EX_TemporalExtent", Geonet.Namespaces.GEX);
		Element tempExtent = new Element("extent", Geonet.Namespaces.GEX);
		
		Element period = new Element("TimePeriod", Geonet.Namespaces.GML);

		if (value.length > 0)
			period.addContent(new Element("beginPosition", Geonet.Namespaces.GML).setText(value[0]));

		if (value.length > 1)
			period.addContent(new Element("endPosition", Geonet.Namespaces.GML).setText(value[1]));

		tempExtent.addContent(Arrays.asList(period));
		ex.addContent(exEx.addContent(tempE.addContent(exTempE.addContent(tempExtent))));

		// out.output(ex, System.out);
		return ex;

	}

}
