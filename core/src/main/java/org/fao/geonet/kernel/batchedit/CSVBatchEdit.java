package org.fao.geonet.kernel.batchedit;

import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.io.StringReader;
import java.nio.charset.Charset;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.Metadata;
import org.fao.geonet.kernel.AddElemValue;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.EditLib;
import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.kernel.schema.MetadataSchema;
import org.fao.geonet.repository.MetadataRepository;
import org.fao.geonet.utils.Log;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.ApplicationEventPublisherAware;

import jeeves.server.context.ServiceContext;

public class CSVBatchEdit implements ApplicationEventPublisherAware {

	SAXBuilder sb = new SAXBuilder();

	private ApplicationEventPublisher applicationEventPublisher;
	Map<String, XPath> xpathExpr = new HashMap<>();

	@SuppressWarnings("unchecked")
	public void processCsv(File csvFile, ApplicationContext context, ServiceContext serviceContext) throws Exception {

		xpathExpr.put("title", getXPath("//mdb:identificationInfo/*/mri:citation/*/cit:title/gco:CharacterString"));
		xpathExpr.put("abstract", getXPath("//mdb:identificationInfo/*/mri:abstract/gco:CharacterString"));
		xpathExpr.put("geoBox", getXPath(
				"//mdb:identificationInfo/mri:MD_DataIdentification/mri:extent[*/gex:geographicElement/gex:EX_GeographicBoundingBox]"));

		xpathExpr.put("verticalExtent", getXPath(
				"//mdb:identificationInfo/mri:MD_DataIdentification/mri:extent[*/gex:verticalElement/gex:EX_VerticalExtent]"));
		
		xpathExpr.put("temporalExtent", getXPath(
				"//mdb:identificationInfo/mri:MD_DataIdentification/mri:extent[*/gex:temporalElement/gex:EX_TemporalExtent]"));
		
		xpathExpr.put("keyword",
				getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords[not(mri:MD_Keywords/mri:thesaurusName)]"));
		xpathExpr.put("keyword-thesaurus",
				getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords[mri:MD_Keywords/mri:thesaurusName]"));
		xpathExpr.put("contact", getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact"));
		xpathExpr.put("topicCategory", getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:topicCategory/mri:MD_TopicCategoryCode"));
		xpathExpr.put("metadataScope", getXPath("//mdb:metadataScope"));
		xpathExpr.put("responsibleParty", getXPath(
				"//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty"));
		xpathExpr.put("resourceLinkage", getXPath(
				"//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:onlineResource"));
		xpathExpr.put("associatedResource", getXPath(
				"//mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource/mri:MD_AssociatedResource/mri:metadataReference/cit:CI_Citation/cit:onlineResource"));
		xpathExpr.put("additionalInfo", getXPath(
				"//mdb:identificationInfo/mri:MD_DataIdentification/mri:additionalDocumentation/cit:CI_Citation/cit:onlineResource"));
		
		
		// xpathExpr.put("LegalConstraints", getXPath("//mdb:identificationInfo/*/*/mco:MD_LegalConstraints/*"));
		// xpathExpr.put("contact", getXPath("//mdb:identificationInfo/*/mri:pointOfContact/*/cit:party/*/cit:name/gco:CharacterString"));
		// xpathExpr.put("contact-custodian", getXPath("//mdb:identificationInfo/*/mri:pointOfContact/*/cit:party/*/cit:name/gco:CharacterString"));
		// xpathExpr.put("contact-owner", getXPath("//mdb:identificationInfo/*/mri:pointOfContact/*/cit:party/*/cit:name/gco:CharacterString"));

		final MetadataRepository metadataRepository = context.getBean(MetadataRepository.class);
		final SchemaManager schemaManager = context.getBean(SchemaManager.class);
		final DataManager dataMan = context.getBean(DataManager.class);
		EditLib editLib = new EditLib(schemaManager);
		Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> 33333333");
		// File templateFile = new File("batchedit_template.xml");

		CSVParser parser = null;
		try {
			parser = CSVParser.parse(csvFile, Charset.defaultCharset(), CSVFormat.EXCEL.withHeader());
		} catch (IOException e1) {
			Log.error(Geonet.SEARCH_ENGINE, e1.getMessage());
		}
		
		Path p = schemaManager.getSchemaDir("iso19115-3");
		File templateFile = p.resolve("batchedit_template.xml").toFile();

		Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> templateFile : " + templateFile.getPath());

		final Document tplDocument = sb.build(templateFile);

		for (CSVRecord csvr : parser) {

			Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> csvRecord.toString() : " + csvr.toString());

			Log.debug(Geonet.SEARCH_ENGINE,
					"CSVRecord, BatchEditsApi --> csvRecord.get(eCatId) : " + csvr.get("eCatId"));

			Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> csvRecord.get(uuid) : " + csvr.get("uuid"));

			try {
				
				Metadata record = metadataRepository.findOneByUuid(csvr.get("uuid"));
				MetadataSchema metadataSchema = schemaManager.getSchema(record.getDataInfo().getSchemaId());
				Element metadata = record.getXmlData(false);
				
				Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> record.getDataInfo().getRoot() : "
						+ record.getDataInfo().getRoot());

				// Element mdFile = record.getXmlData(false);
				Document document = sb.build(new StringReader(record.getData()));

				Iterator iter = parser.getHeaderMap().entrySet().iterator();
				List<BatchEditParameter> listOfUpdates = new ArrayList<>();

				while (iter.hasNext()) {
					Map.Entry<String, Integer> header = (Map.Entry<String, Integer>) iter.next();
					Log.debug(Geonet.SEARCH_ENGINE, header.getKey() + " - " + header.getValue());

					XPath _xpath = xpathExpr.get(header.getKey());

					if (_xpath != null) {
						removeOrAddElements(context, serviceContext, header, csvr, _xpath, document, listOfUpdates);
					}
				}

				boolean metadataChanged = false;
				
				Iterator<BatchEditParameter> listOfUpdatesIterator = listOfUpdates.iterator();
				Log.debug(Geonet.SEARCH_ENGINE, "CSVBatchEdit --> listOfUpdates : " + listOfUpdates.size());
				
//				Log.debug(Geonet.SEARCH_ENGINE, "\n\n ################################################document####################################### \n\n");
//              Log.debug(Geonet.SEARCH_ENGINE, Xml.getString(document));
//              Log.debug(Geonet.SEARCH_ENGINE, "\n\n ####################################################################################### \n\n");
                
                
				metadata = document.getRootElement();
				
                while (listOfUpdatesIterator.hasNext()) {
                    BatchEditParameter batchEditParameter =
                        listOfUpdatesIterator.next();

                    //Log.debug(Geonet.SEARCH_ENGINE, "CSVBatchEdit --> batchEditParameter : " + batchEditParameter.toString());
    				
                    AddElemValue propertyValue =
                        new AddElemValue(batchEditParameter.getValue());
                    
                    metadataChanged = editLib.addElementOrFragmentFromXpath(metadata, metadataSchema, batchEditParameter.getXpath(),
                        propertyValue, true);
                    
                    
                }
               
                if (metadataChanged) {
                	Log.debug(Geonet.SEARCH_ENGINE, "CSVBatchEdit --> updating Metadata.........");
                	dataMan.updateMetadata(serviceContext, record.getId() + "", metadata,
                    		false, false, true, "eng", null, false);
                	//report.addMetadataInfos(record.getId(), "Metadata updated.");
                }
                
            

			} catch (Exception e) {
				Log.error(Geonet.SEARCH_ENGINE, "Exception :" + e.getLocalizedMessage());

			}
		}

	}

	public void removeOrAddElements(ApplicationContext context, ServiceContext serviceContext, Map.Entry<String, Integer> header, CSVRecord csvr, 
			XPath _xpath, Document metadata, List<BatchEditParameter> listOfUpdates) throws IOException, JDOMException {

		String headerVal = header.getKey();
		EditElement editElement = EditElementFactory.getElementType(headerVal);
		
		if(StringUtils.isNotEmpty(csvr.get(headerVal).trim())){
			if(editElement != null){
				
				try {
					List<Element> elements = _xpath.selectNodes(metadata);
					Log.debug(Geonet.SEARCH_ENGINE, "elements.size() ---> "+elements.size());
					elements.iterator().forEachRemaining(e -> {
						e.removeContent();
						e.detach();
					});
				} catch (JDOMException e) {
					e.printStackTrace();
				}
	             
				editElement.removeAndAddElement(context, serviceContext, header, csvr, _xpath, listOfUpdates);
			}else {
				/*BatchEditParameter e = new BatchEditParameter(_xpath.getXPath(),
						"<gn_replace>" + csvr.get(headerVal) + "</gn_replace>");
				listOfUpdates.add(e);*/
				try {
					Log.debug(Geonet.SEARCH_ENGINE, "_xpath.getXPath() --> "+_xpath.getXPath());
					Element element = (Element) _xpath.selectSingleNode(metadata);
					element.setText(csvr.get(headerVal));
				} catch (Exception e) {
					e.printStackTrace();
				}	
			}
		}
		
	}

	public XPath getXPath(String xpath) throws JDOMException {
		XPath _xpath = XPath.newInstance(xpath);
		return _xpath;
	}

	@Override
	public void setApplicationEventPublisher(ApplicationEventPublisher applicationEventPublisher) {
		this.applicationEventPublisher = applicationEventPublisher;
	}

}

class BatchEditParameter implements Serializable {
    private String xpath;
    private String value;

    public BatchEditParameter() {
    }

    public BatchEditParameter(String xpath, String value) {
        if (StringUtils.isEmpty(xpath)) {
            throw new IllegalArgumentException(
                "Parameter xpath is not set. It should be not empty and define the XPath of the element to update.");
        }
        this.xpath = xpath;
        this.value = value;
    }

    public String getXpath() {
        return xpath;
    }

    public void setXpath(String xpath) {
        this.xpath = xpath;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
    
    public String toString() {
        StringBuffer sb = new StringBuffer("Editing xpath ");
        sb.append(this.xpath);
        if (StringUtils.isNotEmpty(this.value)) {
            sb.append(", searching for ");
            sb.append(this.value);
        }
        sb.append(".");
        return sb.toString();
    }
}
