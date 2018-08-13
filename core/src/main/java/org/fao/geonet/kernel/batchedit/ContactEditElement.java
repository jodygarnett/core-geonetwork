package org.fao.geonet.kernel.batchedit;

import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.Map.Entry;

import org.apache.commons.csv.CSVRecord;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.Metadata;
import org.fao.geonet.repository.MetadataRepository;
import org.fao.geonet.repository.specification.MetadataSpecs;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.filter.ElementFilter;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.domain.Specifications;

import jeeves.server.context.ServiceContext;

public class ContactEditElement implements EditElement {
	
	@Override
	public void removeAndAddElement(CSVBatchEdit batchEdit, ApplicationContext context, ServiceContext srvContext,
			Entry<String, Integer> header, CSVRecord csvr, XPath _xpath, List<BatchEditParameter> listOfUpdates)
			throws JDOMException, IOException {

		String headerVal = header.getKey();
		String[] contacts = csvr.get(headerVal).split(content_separator);

		ElementFilter filter = new ElementFilter("CI_RoleCode", Geonet.Namespaces.CIT);

		for (String con : contacts) {

			String[] contact = con.split(type_separator);

			if (contact.length > 0) {
				String value = contact[0];

				Element xmlEle = getContactElement(batchEdit, context, srvContext, value);

				String type = "";

				if (contact.length >= 2) {
					type = contact[1];
					Log.debug(Geonet.SEARCH_ENGINE, "KeywordEditElement --> keyword : " + value + ", keywordType: " + type);
				}

				Iterator elements = xmlEle.getDescendants(filter);

				while (elements.hasNext()) {
					Element e = (Element) elements.next();
					Log.debug(Geonet.SEARCH_ENGINE, "ContactEditElement --> codeListValue --> " + type);
					e.setAttribute("codeListValue", type);
				}

				Log.debug(Geonet.SEARCH_ENGINE, "ContactEditElement --> xmlEle : " + Xml.getString(xmlEle));

				String _val = "<gn_add>" + Xml.getString(xmlEle) + "</gn_add>";
				BatchEditParameter e = new BatchEditParameter(_xpath.getXPath(), _val);
				listOfUpdates.add(e);

			}
		}

	}

	public Element getContactElement(CSVBatchEdit batchEdit, ApplicationContext context, ServiceContext srvContext, String contact)
			throws IOException, JDOMException {

		Element request = Xml.loadString(
				"<request><isAdmin>true</isAdmin><_isTemplate>s</_isTemplate><_root>cit:CI_Responsibility</_root><any>*"
						+ contact + "*</any><fast>index</fast></request>",
				false);
		
		Metadata md = batchEdit.getMetadataByLuceneSearch(context, srvContext, request);
		
		return md.getXmlData(false);
	}

	public Element getContactElementfromDB(ApplicationContext context, ServiceContext srvContext, String contact)
			throws IOException, JDOMException {
		Specification<Metadata> title = MetadataSpecs.hasTitle(contact);
		MetadataRepository mdRepo = context.getBean(MetadataRepository.class);
		// Metadata md = mdRepo.findOneByTitle(contact);
		List<Metadata> mds = mdRepo.findAll(Specifications.where(title));

		if (mds != null && mds.size() > 0) {

			Metadata md = mds.get(0);

			// String contactData = md.getData();
			Element xmlEle = md.getXmlData(false);

			return xmlEle;
		}

		return null;
	}
}
