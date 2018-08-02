package org.fao.geonet.kernel.batchedit;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map.Entry;

import org.apache.commons.csv.CSVRecord;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.Thesaurus;
import org.fao.geonet.kernel.ThesaurusManager;
import org.fao.geonet.utils.Log;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.jdom.output.XMLOutputter;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;

import jeeves.server.context.ServiceContext;

public class KeywordEditElement implements EditElement {

	XMLOutputter out = new XMLOutputter();

	@Override
	public void removeAndAddElement(ApplicationContext context, ServiceContext serContext,
			Entry<String, Integer> header, CSVRecord csvr, XPath _xpath, List<BatchEditParameter> listOfUpdates)
			throws IOException, JDOMException {

		String headerVal = header.getKey();

		String[] keywords = csvr.get(headerVal).split(content_separator);

		for (String keyword : keywords) {

			Element rootE = null;

			if (headerVal.equalsIgnoreCase(Geonet.EditType.KEYWORD))
				rootE = getKeywordElement(keyword);
			if (headerVal.equalsIgnoreCase(Geonet.EditType.KEYWORD_THESAURUS))
				rootE = getKeywordElementWithThesaurus(keyword, context, serContext);

			String strEle = out.outputString(rootE);

			// Log.debug(Geonet.SEARCH_ENGINE, "KeywordEditElement -->
			// strEle : " + strEle);

			String _val = "<gn_add>" + strEle + "</gn_add>";
			BatchEditParameter e = new BatchEditParameter(_xpath.getXPath(), _val);
			listOfUpdates.add(e);

		}

	}

	private Element getKeywordElement(String keyword) throws IOException {

		String[] values = keyword.split(type_separator);

		Element descK = new Element("descriptiveKeywords", Geonet.Namespaces.MRI);
		Element mdK = new Element("MD_Keywords", Geonet.Namespaces.MRI);

		Element k = new Element("keyword", Geonet.Namespaces.MRI);
		String value = "", codelist = "";

		if (values.length > 0)
			value = values[0];
		Element ch = new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(value);

		Element type = new Element("type", Geonet.Namespaces.MRI);
		Element cl = new Element("MD_KeywordTypeCode", Geonet.Namespaces.MRI);
		cl.setAttribute("codeList", "codeListLocation#MD_KeywordTypeCode");

		if (values.length > 1)
			codelist = values[1];
		cl.setAttribute("codeListValue", codelist);

		descK.addContent(mdK.addContent(Arrays.asList(k.addContent(ch), type.addContent(cl))));

		// out.output(descK, System.out);
		return descK;

	}

	private Element getKeywordElementWithThesaurus(String title_keyword, ApplicationContext context,
			ServiceContext serContext) throws IOException, JDOMException {

		String[] values = title_keyword.split(type_separator);
		ThesaurusManager thesaurusMan = context.getBean(ThesaurusManager.class);
		Thesaurus thes = null;

		if (values.length > 0) {

			Log.debug(Geonet.SEARCH_ENGINE, "CSVBatchEdit, KeywordEditElement --> title: " + values[0]);
			// thes = thesaurusMan.getThesaurusByName(values[0]);
			Collection<Thesaurus> thesColl = thesaurusMan.getThesauriMap().values();

			thes = thesColl.stream().filter(t -> t.getTitle().equalsIgnoreCase(values[0].trim())).findFirst().get();

			if (thes != null && values.length > 1) {

				Element descK = new Element("descriptiveKeywords", Geonet.Namespaces.MRI);
				Element mdK = new Element("MD_Keywords", Geonet.Namespaces.MRI);

				String[] keywords = values[1].split(",");

				for (String keyword : keywords) {
					Log.debug(Geonet.SEARCH_ENGINE, "CSVBatchEdit, KeywordEditElement --> keyword -> " + keyword);
					Element k = new Element("keyword", Geonet.Namespaces.MRI);
					Element ch = new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(keyword);
					k.addContent(ch);
					mdK.addContent(k);
				}

				Element type = new Element("type", Geonet.Namespaces.MRI);
				Element cl = new Element("MD_KeywordTypeCode", Geonet.Namespaces.MRI);
				cl.setAttribute("codeList", "codeListLocation#MD_KeywordTypeCode");
				cl.setAttribute("codeListValue", thes.getDname());

				descK.addContent(mdK.addContent(Arrays.asList(type, getThesaurus(thes))));

				return descK;
			} else {
				Log.debug(Geonet.SEARCH_ENGINE, "CSVBatchEdit, KeywordEditElement --> ThesaurusByName is null");
			}

		}

		return null;

	}

	private Element getThesaurus(Thesaurus the) throws IOException, JDOMException {

		
		Element theName = new Element("thesaurusName", Geonet.Namespaces.MRI);
		Element citation = new Element("CI_Citation", Geonet.Namespaces.CIT);
		Element title = new Element("title", Geonet.Namespaces.CIT);
		Element date = new Element("date", Geonet.Namespaces.CIT);
		Element ciDate = new Element("CI_Date", Geonet.Namespaces.CIT);
		Element date1 = new Element("date", Geonet.Namespaces.CIT);
		Element dateType = new Element("dateType", Geonet.Namespaces.CIT);
		Element identifier = new Element("identifier", Geonet.Namespaces.CIT);
		Element mdIdentifier = new Element("MD_Identifier", Geonet.Namespaces.MCC);
		Element code = new Element("code", Geonet.Namespaces.MCC);
		Element anchor = new Element("Anchor", Geonet.Namespaces.GCX);
		
		title.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(the.getTitle()));
		
		if(the.getDate().contains("T")){
			date1.addContent(new Element("DateTime", Geonet.Namespaces.GCO_3).setText(the.getDate()));
		}else{
			date1.addContent(new Element("Date", Geonet.Namespaces.GCO_3).setText(the.getDate()));
		}
		
		
		dateType.addContent(new Element("CI_DateTypeCode", Geonet.Namespaces.CIT)
				.setAttribute("codeList", "codeListLocation#CI_DateTypeCode")
				.setAttribute("codeListValue", "publication"));
		date.addContent(ciDate.addContent(Arrays.asList(date1, dateType)));
		
		Namespace xlink = Namespace.getNamespace("xlink", "http://www.w3.org/1999/xlink");
		anchor.addNamespaceDeclaration(xlink);
		anchor.setAttribute("href",the.getDownloadUrl(), xlink)
				.setText("geonetwork.thesaurus." + the.getKey());
		
		identifier.addContent(mdIdentifier.addContent(code.addContent(anchor)));
		
		theName.addContent(citation.addContent(Arrays.asList(title, date, identifier)));
		
		return theName;
	}

}
