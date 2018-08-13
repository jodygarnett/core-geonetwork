package org.fao.geonet.kernel.batchedit;

import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.io.StringReader;
import java.nio.charset.Charset;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.WordUtils;
import org.apache.lucene.document.DocumentStoredFieldVisitor;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.TopDocs;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.Metadata;
import org.fao.geonet.kernel.AddElemValue;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.EditLib;
import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.kernel.schema.MetadataSchema;
import org.fao.geonet.kernel.search.IndexAndTaxonomy;
import org.fao.geonet.kernel.search.LuceneConfig;
import org.fao.geonet.kernel.search.LuceneQueryBuilder;
import org.fao.geonet.kernel.search.LuceneQueryInput;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.kernel.search.index.LuceneIndexLanguageTracker;
import org.fao.geonet.repository.MetadataRepository;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.geotools.referencing.ReferencingFactoryFinder;
import org.jdom.Attribute;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.xpath.XPath;
import org.opengis.metadata.Identifier;
import org.opengis.referencing.FactoryException;
import org.opengis.referencing.crs.CRSAuthorityFactory;
import org.opengis.referencing.crs.CoordinateReferenceSystem;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.ApplicationEventPublisherAware;

import jeeves.server.context.ServiceContext;

public class CSVBatchEdit implements ApplicationEventPublisherAware {

	SAXBuilder sb = new SAXBuilder();

	LuceneIndexLanguageTracker tracker;
	IndexAndTaxonomy indexAndTaxonomy;
	IndexSearcher searcher;
	LuceneConfig luceneConfig;
	
	private ApplicationEventPublisher applicationEventPublisher;
	Map<String, XPath> xpathExpr = new HashMap<>();

	@SuppressWarnings("unchecked")
	public void processCsv(File csvFile, ApplicationContext context, ServiceContext serviceContext, String mode) throws Exception {

		//SimpleMetadataProcessingReport report = new SimpleMetadataProcessingReport();
		
		xpathExpr.put(Geonet.EditType.TITLE, getXPath("//mdb:identificationInfo/*/mri:citation/*/cit:title/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.ABSTRACT, getXPath("//mdb:identificationInfo/*/mri:abstract/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.PURPOSE, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:purpose/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.USE_LIMITATION, getXPath("//mdb:identificationInfo/*/mri:resourceConstraints/mco:MD_LegalConstraints/mco:useLimitation/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.SPACIAL_REF_SYSYTEM, getXPath("//mdb:identificationInfo/*/gex:EX_Extent/gex:verticalElement/*/gex:verticalCRSId/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString"));
		
		xpathExpr.put(Geonet.EditType.MAINTENANCE_FREQ, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceMaintenance/mmi:MD_MaintenanceInformation/mmi:maintenanceAndUpdateFrequency/mmi:MD_MaintenanceFrequencyCode/@codeListValue"));
		xpathExpr.put(Geonet.EditType.STATUS, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:status/mcc:MD_ProgressCode/@codeListValue"));
		xpathExpr.put(Geonet.EditType.MD_SECURITY_CONSTRAINT, getXPath("//mdb:metadataConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode/@codeListValue"));
		xpathExpr.put(Geonet.EditType.RES_SECURITY_CONSTRAINT, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode/@codeListValue"));
		
		
		xpathExpr.put(Geonet.EditType.GEOBOX, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:extent[*/gex:geographicElement/gex:EX_GeographicBoundingBox]"));
		xpathExpr.put(Geonet.EditType.VERTICAL, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:extent[*/gex:verticalElement/gex:EX_VerticalExtent]"));
		xpathExpr.put(Geonet.EditType.VERTICAL_CRS, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:extent/*/gex:verticalElement/gex:EX_VerticalExtent/gex:verticalCRSId"));
		xpathExpr.put(Geonet.EditType.TEMPORAL, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:extent[*/gex:temporalElement/gex:EX_TemporalExtent]"));
		
		
		xpathExpr.put(Geonet.EditType.KEYWORD, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords[not(mri:MD_Keywords/mri:thesaurusName)]"));
		xpathExpr.put(Geonet.EditType.KEYWORD_THESAURUS, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords[mri:MD_Keywords/mri:thesaurusName]"));
		
		
		xpathExpr.put(Geonet.EditType.POINT_OF_CONTACT, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact"));
		xpathExpr.put(Geonet.EditType.RESPONSIBLE_PARTY, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:citedResponsibleParty"));
		
		xpathExpr.put(Geonet.EditType.CITATION_DATE, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:date"));
		
		xpathExpr.put(Geonet.EditType.TOPIC_CAT, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:topicCategory/mri:MD_TopicCategoryCode"));
		xpathExpr.put(Geonet.EditType.MD_SCOPE, getXPath("//mdb:metadataScope"));
		

		xpathExpr.put(Geonet.EditType.RES_LINKAGE, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:citation/cit:CI_Citation/cit:onlineResource"));
		xpathExpr.put(Geonet.EditType.ASSOCIATED_RES, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:associatedResource/mri:MD_AssociatedResource/mri:metadataReference/cit:CI_Citation/cit:onlineResource"));
		xpathExpr.put(Geonet.EditType.ADDITIONAL_INFO, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:additionalDocumentation"));
		xpathExpr.put(Geonet.EditType.TRANSFER_OPTION, getXPath("//mdb:distributionInfo/mrd:MD_Distribution/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine"));
		
		
		xpathExpr.put(Geonet.EditType.RESOURCE_FORMAT, getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:resourceFormat"));
		xpathExpr.put(Geonet.EditType.DISTRIBUTION_FORMAT, getXPath("//mdb:distributionInfo/mrd:MD_Distribution/mrd:distributionFormat"));
		
		
		final MetadataRepository metadataRepository = context.getBean(MetadataRepository.class);
		final SchemaManager schemaManager = context.getBean(SchemaManager.class);
		final DataManager dataMan = context.getBean(DataManager.class);
		EditLib editLib = new EditLib(schemaManager);
		Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> 33333333");
		// File templateFile = new File("batchedit_template.xml");
		
		
		tracker = context.getBean(LuceneIndexLanguageTracker.class);
		indexAndTaxonomy = tracker.acquire("eng", -1);
		searcher = new IndexSearcher(indexAndTaxonomy.indexReader);
		luceneConfig = context.getBean(LuceneConfig.class);
		
		
		CSVParser parser = null;
		try {
			//Parse the csv file
			parser = CSVParser.parse(csvFile, Charset.defaultCharset(), CSVFormat.EXCEL.withHeader());
		} catch (IOException e1) {
			Log.error(Geonet.SEARCH_ENGINE, e1.getMessage());
		}
		
		//Currently only supports iso19115-3 standard
		Path p = schemaManager.getSchemaDir("iso19115-3");
		
		/*
		File templateFile = p.resolve("batchedit_template.xml").toFile();
		Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> templateFile : " + templateFile.getPath());
		final Document tplDocument = sb.build(templateFile); 
		*/

		for (CSVRecord csvr : parser) {

			Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> csvRecord.toString() : " + csvr.toString());
			Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> csvRecord.get(eCatId) : " + csvr.get("eCatId"));

			//Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> csvRecord.get(uuid) : " + csvr.get("uuid"));

			try {
				Metadata record = null;
				if(!csvr.isMapped("uuid")){
					if(csvr.isMapped("eCatId")){
						
						//Search record based on eCatId from lucene index 
						Element request = Xml.loadString(
								"<request><isAdmin>true</isAdmin><_isTemplate>n</_isTemplate><eCatId>" + csvr.get("eCatId") + "</eCatId><fast>index</fast></request>",
								false);
						record = getMetadataByLuceneSearch(context, serviceContext, request);	
					}else{//If there is no valid uuid and ecatId, doesn't process this record and continue to execute next record
						
						//report.addMetadataError(-1, new Exception("Unable to process record number " + csvr.getRecordNumber()));
						continue;
					}
					 
				}else{//find record by uuid, if its defined in csv file
					record = metadataRepository.findOneByUuid(csvr.get("uuid"));
				}
				
				if(record == null){
					//report.addMetadataError(-1, new Exception("No metadata found, Unable to process record number " + csvr.getRecordNumber()));
					continue;
				}
				
				MetadataSchema metadataSchema = schemaManager.getSchema(record.getDataInfo().getSchemaId());
				Element metadata = record.getXmlData(false);
				
				Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> record.getDataInfo().getRoot() : "
						+ record.getDataInfo().getRoot());
				
				Document document = sb.build(new StringReader(record.getData()));

				Iterator iter = parser.getHeaderMap().entrySet().iterator();
				List<BatchEditParameter> listOfUpdates = new ArrayList<>();

				//Iterate through all csv records, and create list of batchedit parameter with xpath and values 
				while (iter.hasNext()) {
					Map.Entry<String, Integer> header = (Map.Entry<String, Integer>) iter.next();
					Log.debug(Geonet.SEARCH_ENGINE, header.getKey() + " - " + header.getValue());

					XPath _xpath = xpathExpr.get(header.getKey());

					if (_xpath != null) {
						removeOrAddElements(context, serviceContext, header, csvr, _xpath, document, listOfUpdates, mode);
					}
				}

				boolean metadataChanged = false;
				
				Iterator<BatchEditParameter> listOfUpdatesIterator = listOfUpdates.iterator();
				Log.debug(Geonet.SEARCH_ENGINE, "CSVBatchEdit --> listOfUpdates : " + listOfUpdates.size());
                
				metadata = document.getRootElement();
				
				//Iterate through batchedit parameter list and add elements
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
			XPath _xpath, Document metadata, List<BatchEditParameter> listOfUpdates, String mode) throws IOException, JDOMException {

		String headerVal = header.getKey();
		EditElement editElement = EditElementFactory.getElementType(headerVal);
		
		if(StringUtils.isNotEmpty(csvr.get(headerVal).trim())){
			if(editElement != null){
				
				if(mode.equals("remove")){
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
				}
				
				editElement.removeAndAddElement(this, context, serviceContext, header, csvr, _xpath, listOfUpdates);
				
			}else if(_xpath.getXPath().contains("/@")){
				try {
					Attribute attr = (Attribute) _xpath.selectSingleNode(metadata);
					attr.setValue(csvr.get(headerVal));
				} catch (Exception e) {
					e.printStackTrace();
				}
			} else {
				try {
					Log.debug(Geonet.SEARCH_ENGINE, "_xpath.getXPath() --> "+_xpath.getXPath());
					Element element = (Element) _xpath.selectSingleNode(metadata);
					if(element != null){
						Log.debug(Geonet.SEARCH_ENGINE, "element for xpath " + _xpath.getXPath() + " is not null");
						element.setText(csvr.get(headerVal));
					}
					else{
						Log.debug(Geonet.SEARCH_ENGINE, "element for xpath " + _xpath.getXPath() + " is null");
						BatchEditParameter e = new BatchEditParameter(_xpath.getXPath(),
								"<gn_add>" + csvr.get(headerVal) + "</gn_add>");
						listOfUpdates.add(e);
					}
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
	
	
	public Metadata getMetadataByLuceneSearch(ApplicationContext context, ServiceContext srvContext, Element request)
			throws IOException, JDOMException {

		LuceneQueryInput luceneQueryInput = new LuceneQueryInput(request);
		
		Query _query = new LuceneQueryBuilder(luceneConfig, luceneConfig.getTokenizedField(),
				SearchManager.getAnalyzer(Geonet.DEFAULT_LANGUAGE, true), Geonet.DEFAULT_LANGUAGE)
						.build(luceneQueryInput);

		MetadataRepository mdRepo = context.getBean(MetadataRepository.class);

		Log.debug(Geonet.SEARCH_ENGINE, "getMetadataByLuceneSearch --> Lucene query: " + _query);

		try {
			

			TopDocs tdocs = searcher.search(_query, 1);
			DocumentStoredFieldVisitor docVisitor = new DocumentStoredFieldVisitor("_uuid");

			Log.debug(Geonet.SEARCH_ENGINE, "getMetadataByLuceneSearch --> tdocs.scoreDocs length: " + tdocs.scoreDocs.length);

			indexAndTaxonomy.indexReader.document(tdocs.scoreDocs[0].doc, docVisitor);
			org.apache.lucene.document.Document doc = docVisitor.getDocument();

			String uuid = doc.get("_uuid");
			Log.debug(Geonet.SEARCH_ENGINE, "getMetadataByLuceneSearch --> uuid: " + uuid);

			if (uuid != null) {
				Metadata md = mdRepo.findOneByUuid(uuid);
				return md;
			}

		} catch (IOException e) {
			e.printStackTrace();
		}

		return null;
	}
	
	public Crs getById(String crsId) {
        for (Object object : ReferencingFactoryFinder
            .getCRSAuthorityFactories(null)) {
            CRSAuthorityFactory factory = (CRSAuthorityFactory) object;

            try {
                Set<String> codes = factory
                    .getAuthorityCodes(CoordinateReferenceSystem.class);
                for (Object codeObj : codes) {
                    String code = (String) codeObj;
                    if (code.equals(crsId)) {
                        String authorityTitle = (factory.getAuthority()
                            .getTitle() == null ? "" : factory
                            .getAuthority().getTitle().toString());
                        String authorityEdition = (factory.getAuthority()
                            .getEdition() == null ? "" : factory
                            .getAuthority().getEdition().toString());

                        String authorityCodeSpace = "";
                        Collection<? extends Identifier> ids = factory
                            .getAuthority().getIdentifiers();
                        for (Identifier id : ids) {
                            authorityCodeSpace = id.getCode();
                        }

                        String description;
                        try {
                            description = factory.getDescriptionText(code)
                                .toString();
                        } catch (Exception e1) {
                            description = "-";
                        }
                        description += " (" + authorityCodeSpace + ":" + code
                            + ")";

                        return new Crs(code, authorityTitle,
                            authorityEdition, authorityCodeSpace,
                            description);
                    }
                }
            } catch (FactoryException e) {
            }
        }
        return null;
    }
	
	public String toTitleCase(String clval){
		String[] vals = clval.split(" ");
		StringBuilder titleCase = new StringBuilder();
		if(vals.length > 1){
			titleCase.append(vals[0].toLowerCase());
			for(int i = 1; i < vals.length; i++){
				titleCase.append(WordUtils.capitalize(vals[i]));
			}
		}
		return titleCase.toString();
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

class Crs {
    private String code;

    ;
    private String authority;
    private String version;
    private String codeSpace;
    private String description;
    public Crs() {
    }

    public Crs(String code, String authority,
               String version, String codeSpace,
               String description) {
        this.code = code;
        this.authority = authority;
        this.version = version;
        this.codeSpace = codeSpace;
        this.description = description;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getAuthority() {
        return authority;
    }

    public void setAuthority(String authority) {
        this.authority = authority;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getCodeSpace() {
        return codeSpace;
    }

    public void setCodeSpace(String codeSpace) {
        this.codeSpace = codeSpace;
    }

}