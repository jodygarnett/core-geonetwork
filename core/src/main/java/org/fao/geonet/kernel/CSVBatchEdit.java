package org.fao.geonet.kernel;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.charset.Charset;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.Metadata;
import org.fao.geonet.kernel.schema.MetadataSchema;
import org.fao.geonet.repository.MetadataRepository;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.jdom.input.SAXBuilder;
import org.jdom.output.XMLOutputter;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.ApplicationEventPublisherAware;

import jeeves.server.context.ServiceContext;

public class CSVBatchEdit implements ApplicationEventPublisherAware{

	private int count = 0;
	private static final String delimiter = "###";
	
	XMLOutputter out = new XMLOutputter();
	SAXBuilder sb = new SAXBuilder();

	private ApplicationEventPublisher applicationEventPublisher;
	Map<String, XPath> xpathExpr = new HashMap<>();
	
	@SuppressWarnings("unchecked")
	public void processCsv(File csvFile, ApplicationContext context, ServiceContext serviceContext) throws Exception {
		
		xpathExpr.put("title", getXPath("//mdb:identificationInfo/*/mri:citation/*/cit:title/gco:CharacterString"));
		xpathExpr.put("abstract", getXPath("//mdb:identificationInfo/*/mri:abstract"));
		xpathExpr.put("geoBox", getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:extent[gex:EX_Extent/gex:geographicElement/gex:EX_GeographicBoundingBox]"));
		xpathExpr.put("keyword", getXPath("//mdb:identificationInfo/mri:MD_DataIdentification/mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword"));
		
//		xpathExpr.put("LegalConstraints", getXPath("//mdb:identificationInfo/*/*/mco:MD_LegalConstraints/*"));
//		xpathExpr.put("contact", getXPath("//mdb:identificationInfo/*/mri:pointOfContact/*/cit:party/*/cit:name/gco:CharacterString"));
//		xpathExpr.put("contact-custodian", getXPath("//mdb:identificationInfo/*/mri:pointOfContact/*/cit:party/*/cit:name/gco:CharacterString"));
//		xpathExpr.put("contact-owner", getXPath("//mdb:identificationInfo/*/mri:pointOfContact/*/cit:party/*/cit:name/gco:CharacterString"));
		
		
		final MetadataRepository metadataRepository = context.getBean(MetadataRepository.class);
		final TransformManager transformManager = context.getBean(TransformManager.class);
		final SchemaManager schemaManager = context.getBean(SchemaManager.class);
		final DataManager dataMan = context.getBean(DataManager.class);
		EditLib editLib = new EditLib(schemaManager);
		Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> 33333333");
		//File templateFile = new File("batchedit_template.xml");
 		
		CSVParser parser = null;
		try {
			parser = CSVParser.parse(csvFile, Charset.defaultCharset(), CSVFormat.EXCEL.withHeader());
		} catch (IOException e1) {
			Log.error(Geonet.SEARCH_ENGINE, e1.getMessage());
		}

		//String schema = parser.getRecords().get(0).get("schema");
		//Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> schema: " + schema);
		Path p = schemaManager.getSchemaDir("iso19115-3");
		File templateFile = p.resolve("batchedit_template.xml").toFile();
		
		Log.debug(Geonet.SEARCH_ENGINE,
				"CSVRecord, BatchEditsApi --> templateFile : " + templateFile.getPath());

		
		final Document tplDocument = sb.build(templateFile);
		
		
		for (CSVRecord csvr : parser) {
			
			boolean metadataChanged;
			
			Log.debug(Geonet.SEARCH_ENGINE,
					"CSVRecord, BatchEditsApi --> csvRecord.toString() : " + csvr.toString());

			Log.debug(Geonet.SEARCH_ENGINE,
					"CSVRecord, BatchEditsApi --> csvRecord.get(eCatId) : " + csvr.get("eCatId"));
			
			Log.debug(Geonet.SEARCH_ENGINE,
					"CSVRecord, BatchEditsApi --> csvRecord.get(uuid) : " + csvr.get("uuid"));
			
			try {
				Metadata record = metadataRepository.findOneByUuid(csvr.get("uuid"));
				
				Log.debug(Geonet.SEARCH_ENGINE,
						"CSVRecord, BatchEditsApi --> record.getDataInfo().getRoot() : " + record.getDataInfo().getRoot());
				
				//Element mdFile =  record.getXmlData(false);
				final Document document = sb.build(new StringReader(record.getData()));
				
				
				parser.getHeaderMap().entrySet().iterator().forEachRemaining(h -> {
					String header = h.getKey();
					Integer index = h.getValue();
					
					XPath _xpath = xpathExpr.get(header);
					
					if(_xpath != null){
						
						Log.debug(Geonet.SEARCH_ENGINE, "---------- "+ header + " ------------");
						Log.debug(Geonet.SEARCH_ENGINE, "---------------> _xpath, " + _xpath.getXPath());
						
						
						if(header.equalsIgnoreCase("keyword")){
							AddElemValue propertyValue;
							try {
								propertyValue = new AddElemValue(csvr.get(header));

								MetadataSchema metadataSchema = schemaManager
										.getSchema(record.getDataInfo().getSchemaId());
								editLib.addElementOrFragmentFromXpath(document.detachRootElement(),
										metadataSchema, xpathExpr.get(header).getXPath(), propertyValue, true);
							} catch (JDOMException | IOException e) {
								e.printStackTrace();
							}
							
						}
						
						
						List<Element> elements = null;
						try {
							elements = _xpath.selectNodes(document);
						} catch (JDOMException e) {
							Log.error(Geonet.SEARCH_ENGINE, "JDOMException while selecting nodes, CSV BatchEdit operation " + e.getLocalizedMessage());
						}
						
						Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> 11111111");
						
						if(elements != null && elements.size() <= 0){
							
						}
						
						if(elements != null){
							Log.debug(Geonet.SEARCH_ENGINE, "elements.size() --> "+elements.size());
							
							elements.forEach(el -> {
								
								Element _el = (Element)el;
								
								Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> _el: " + _el.getName());
								
								try{
									
									boolean _metadataChanged = false;
									boolean addElement = false;
									if(StringUtils.isNotEmpty(_el.getValue().trim())){
										String value = csvr.get(header);
										if(isReadOnly(header)){
											Element l = getLastChild(_el);
											Log.debug(Geonet.SEARCH_ENGINE, "Setting value for " + l.getName()+ ": " + value);
											l.setText(value);
											
										}else if(value.contains("||")){
											String[] replaceVal = value.split("||");
											Element l = getLastChild(_el);
											Log.debug(Geonet.SEARCH_ENGINE, "Setting value for " + l.getName()+ ": " + replaceVal[0]);
											l.setText(replaceVal[1]);
											//value = replaceVal[1];
										}else if(!isReadOnly(header) && !value.contains("###")) {
											Element l = getLastChild(_el);
											l.setText(value);
											//mdFile.addContent(_el);
										}else if(value.contains("###") && value.contains("||")){
											
										}else if(value.contains("###")){
											String[] replaceVals = value.split("###");
											for (String rv : replaceVals) {
												Element l = getLastChild(_el);
												l.setText(value);
												//mdFile.addContent(_el);
											}
										}else{
											
										}

										/*AddElemValue propertyValue = new AddElemValue(value);
										MetadataSchema metadataSchema = schemaManager
												.getSchema(record.getDataInfo().getSchemaId());
										_metadataChanged = editLib.addElementOrFragmentFromXpath(mdFile,
												metadataSchema, xpathExpr.get(header).getXPath(), propertyValue, true);*/
										
									}
									
									Log.debug(Geonet.SEARCH_ENGINE, "mdFile --> " + Xml.getString(document));
				                        
								}catch(Exception e){
									Log.error(Geonet.SEARCH_ENGINE, "Exception while last child, CSV BatchEdit operation: " + e.getLocalizedMessage());
								}
							});
							
							if(elements.size() <= 0){
								String value = csvr.get(header);
								Log.debug(Geonet.SEARCH_ENGINE, "xpathExpr.get(header).getExpression() --> " + xpathExpr.get(header).getXPath());
							
								XPath expr = null;
								Element els = null;
								try{
									expr = XPath.newInstance(xpathExpr.get(header).getXPath());
									els = (Element) expr.selectSingleNode(tplDocument);
								}catch (JDOMException e) {
									Log.error(Geonet.SEARCH_ENGINE, "JDOMException while creating xpath / selecting single node, CSV BatchEdit operation " + e.getLocalizedMessage());
								}
								
								Log.debug(Geonet.SEARCH_ENGINE, "els.getChildren().size() --> "+els.getChildren().size());
								
								try {
									StringWriter writer = new StringWriter();
									out.output(els, writer);
									els.getParentElement().addContent(writer.toString());
									Element bbele = setValues(els, value);
									count = 0;
									Log.debug(Geonet.SEARCH_ENGINE, "ECAT ###### Xml.getString(bbele) --> " + Xml.getString(bbele));
								} catch (Exception e1) {
									Log.error(Geonet.SEARCH_ENGINE, "Exception while setting values, CSV BatchEdit operation: " + e1.getLocalizedMessage());
								} 
								
							}
						}else{
							Log.debug(Geonet.SEARCH_ENGINE, "$$$$$$$$ ECAT ######, Element is null..");
						}
						
					}
					
				});
				
	            dataMan.updateMetadata(serviceContext, record.getId() + "", document.detachRootElement(), false, false, true,"eng", null, false);
	            
			} catch (Exception e) {
				Log.error(Geonet.SEARCH_ENGINE, "Exception :" + e.getLocalizedMessage());
				
			}
		}
		
	}

	public boolean isReadOnly(String column) {
	
		switch (column) {
		case "title":
			return true;
		case "abstract":
			return true;
		case "geoBox":
			return true;
		default:
			return false;
		}
	}
	
	public XPath getXPath(String xpath) throws JDOMException{
		XPath _xpath = XPath.newInstance(xpath);
		return _xpath;
	}
	
	public Element getLastChild(Element e) throws Exception{

		if (e != null) {
			Log.debug(Geonet.SEARCH_ENGINE, "ECAT ###### e.getChildren().size() ---> " + e.getChildren().size());
			
			if(e.getChildren().size() <= 0){
				Log.debug(Geonet.SEARCH_ENGINE, "ECAT ###### The last child is " + e.getName());
				return e;
			}
			Log.debug(Geonet.SEARCH_ENGINE, "ECAT ###### Trying to get child of " + e.getName());

			if (e.getChildren().size() >= 1) {
				String child = ((Element)e.getChildren().get(0)).getName();

				Namespace childns = ((Element) e.getChildren().get(0)).getNamespace();
				Log.debug(Geonet.SEARCH_ENGINE, child + ":" + childns.getPrefix());
				getLastChild(e.getChild(child, childns));
			}
			
		}
		Log.debug(Geonet.SEARCH_ENGINE, "---------#########------------");
		return e;
	}
	
	public Element setValues(Element e, String value) throws Exception{

		String[] values = value.split("###");
		
		Log.debug(Geonet.SEARCH_ENGINE, "count = " + count);
		if (e != null) {
			if(e.getChildren().size() > 0){
				for (Object o : e.getChildren()) {
					Element c = (Element) o;
					Log.debug(Geonet.SEARCH_ENGINE, "ECAT ###### Type is element: " + c.getName());
					setValues(e.getChild(c.getName(), c.getNamespace()), value);
				}	
			}else{
				Log.debug(Geonet.SEARCH_ENGINE, "ECAT ###### Type is Text: assigning " + e.getName() + "with " + values[count]);
				e.setText(values[count]);
				count++;
			}
			
		}
		
		return e;
		
	}
	
	
	@Override
	public void setApplicationEventPublisher(ApplicationEventPublisher applicationEventPublisher) {
		this.applicationEventPublisher = applicationEventPublisher;		
	}

}
