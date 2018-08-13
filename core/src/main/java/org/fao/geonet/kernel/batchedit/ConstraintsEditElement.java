package org.fao.geonet.kernel.batchedit;

import java.io.IOException;
import java.util.List;
import java.util.Map.Entry;

import org.apache.commons.csv.CSVRecord;
import org.jdom.JDOMException;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;

import jeeves.server.context.ServiceContext;

public class ConstraintsEditElement implements EditElement {

	@Override
	public void removeAndAddElement(CSVBatchEdit batchEdit, ApplicationContext context, ServiceContext serContext, Entry<String, Integer> header, CSVRecord csvr,
			XPath _xpath, List<BatchEditParameter> listOfUpdates) throws JDOMException, IOException {

		
		
	}

}
