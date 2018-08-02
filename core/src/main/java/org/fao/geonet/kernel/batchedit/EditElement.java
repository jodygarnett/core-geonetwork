package org.fao.geonet.kernel.batchedit;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.apache.commons.csv.CSVRecord;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;

import jeeves.server.context.ServiceContext;

public interface EditElement {

	public static final String content_separator = "###";
	public static final String type_separator = "~";
	
	public void removeAndAddElement(ApplicationContext context, ServiceContext serContext, Map.Entry<String, Integer> header, CSVRecord csvr, XPath _xpath,
			List<BatchEditParameter> listOfUpdates) throws JDOMException, IOException;
}
