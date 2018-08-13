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

public class MdScopeEditElement implements EditElement {

	XMLOutputter out = new XMLOutputter();

	@Override
	public void removeAndAddElement(CSVBatchEdit batchEdit, ApplicationContext context, ServiceContext serContext, Entry<String, Integer> header, CSVRecord csvr,
			XPath _xpath, List<BatchEditParameter> listOfUpdates) throws JDOMException, IOException {

		String headerVal = header.getKey();

		String[] names = csvr.get(headerVal).split(content_separator);

		for (String name : names) {

			String[] scopeCodes = name.split(type_separator);

			if (scopeCodes.length > 0) {
				String value = scopeCodes[0];
				String type = "";

				if (scopeCodes.length >= 2) {
					type = scopeCodes[1];
					Log.debug(Geonet.SEARCH_ENGINE,
							"KeywordEditElement --> keyword : " + value + ", keywordType: " + type);
				}
				Element rootE = getMdScopeElement(value, type);
				String strEle = out.outputString(rootE);

				// Log.debug(Geonet.SEARCH_ENGINE, "KeywordEditElement -->
				// strEle : " + strEle);

				String _val = "<gn_add>" + strEle + "</gn_add>";
				BatchEditParameter e = new BatchEditParameter(_xpath.getXPath(), _val);
				listOfUpdates.add(e);
			}

		}

	}

	private Element getMdScopeElement(String value, String codelist) throws IOException {

		Element mdScope = new Element("metadataScope", Geonet.Namespaces.MDB);
		Element _mdScope = new Element("MD_MetadataScope", Geonet.Namespaces.MDB);
		Element resScope = new Element("resourceScope", Geonet.Namespaces.MDB);

		Element cl = new Element("MD_ScopeCode", Geonet.Namespaces.MCC);
		cl.setAttribute("codeList", "codeListLocation#MD_ScopeCode");
		cl.setAttribute("codeListValue", codelist);

		Element name = new Element("name", Geonet.Namespaces.MDB);
		Element ch = new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(value);

		mdScope.addContent(_mdScope.addContent(Arrays.asList(resScope.addContent(cl), name.addContent(ch))));

		// out.output(descK, System.out);
		return mdScope;

	}
}
