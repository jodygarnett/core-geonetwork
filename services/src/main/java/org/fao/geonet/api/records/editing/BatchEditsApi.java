/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */
package org.fao.geonet.api.records.editing;

import java.io.BufferedWriter;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.io.Writer;
import java.lang.reflect.Type;
import java.nio.charset.Charset;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.apache.commons.io.FileUtils;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.Util;
import org.fao.geonet.api.API;
import org.fao.geonet.api.ApiParams;
import org.fao.geonet.api.ApiUtils;
import org.fao.geonet.api.processing.report.ErrorReport;
import org.fao.geonet.api.processing.report.IProcessingReport;
import org.fao.geonet.api.processing.report.InfoReport;
import org.fao.geonet.api.processing.report.SimpleMetadataProcessingReport;
import org.fao.geonet.api.records.model.BatchEditParameter;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.Metadata;
import org.fao.geonet.domain.Setting;
import org.fao.geonet.domain.SettingDataType;
import org.fao.geonet.exceptions.BatchEditException;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.AddElemValue;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.EditLib;
import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.kernel.SelectionManager;
import org.fao.geonet.kernel.batchedit.BatchEditParam;
import org.fao.geonet.kernel.batchedit.BatchEditReport;
import org.fao.geonet.kernel.batchedit.BatchEditXpath;
import org.fao.geonet.kernel.batchedit.CSVBatchEdit;
import org.fao.geonet.kernel.schema.MetadataSchema;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.repository.MetadataRepository;
import org.fao.geonet.repository.SettingRepository;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.xpath.XPath;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.multipart.MultipartFile;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.AmazonS3URI;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.google.common.collect.Sets;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;
import jeeves.server.context.ServiceContext;
import jeeves.services.ReadWriteController;

@RequestMapping(value = { "/api/records", "/api/" + API.VERSION_0_1 + "/records" })
@Api(value = "records", tags = "records", description = "Metadata record editing operations")
@Controller("records/edit")
@ReadWriteController
public class BatchEditsApi implements ApplicationContextAware {
	@Autowired
	SchemaManager _schemaManager;
	private ApplicationContext context;
	// List<BatchEditReport> reports;
	AmazonS3URI s3uri = new AmazonS3URI(Geonet.BATCHEDIT_BACKUP_BUCKET);
	Gson g = new Gson();
	Map<String, XPath> xpathExpr = new HashMap<>();

	public synchronized void setApplicationContext(ApplicationContext context) {
		this.context = context;
	}

	/**
	 * The service edits to the current selection or a set of uuids.
	 */
	@ApiOperation(value = "Edit a set of records by XPath expressions", nickname = "batchEdit")
	@RequestMapping(value = "/batchediting", method = RequestMethod.PUT, produces = {
			MediaType.APPLICATION_JSON_VALUE })
	@ApiResponses(value = { @ApiResponse(code = 201, message = "Return a report of what has been done."),
			@ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT) })
	@PreAuthorize("hasRole('Editor')")
	@ResponseStatus(HttpStatus.CREATED)
	@ResponseBody
	public IProcessingReport batchEdit(
			@ApiParam(value = ApiParams.API_PARAM_RECORD_UUIDS_OR_SELECTION, required = false, example = "iso19139") @RequestParam(required = false) String[] uuids,
			@ApiParam(value = ApiParams.API_PARAM_BUCKET_NAME, required = false) @RequestParam(required = false) String bucket,
			@RequestBody BatchEditParameter[] edits, HttpServletRequest request) throws Exception {

		List<BatchEditParameter> listOfUpdates = Arrays.asList(edits);
		if (listOfUpdates.size() == 0) {
			throw new IllegalArgumentException("At least one edit must be defined.");
		}

		ServiceContext serviceContext = ApiUtils.createServiceContext(request);
		final Set<String> setOfUuidsToEdit;
		if (uuids == null) {
			SelectionManager selectionManager = SelectionManager.getManager(serviceContext.getUserSession());

			synchronized (selectionManager.getSelection(bucket)) {
				final Set<String> selection = selectionManager.getSelection(bucket);
				setOfUuidsToEdit = Sets.newHashSet(selection);
			}
		} else {
			setOfUuidsToEdit = Sets.newHashSet(Arrays.asList(uuids));
		}

		if (setOfUuidsToEdit.size() == 0) {
			throw new IllegalArgumentException("At least one record should be defined or selected for updates.");
		}

		ConfigurableApplicationContext appContext = ApplicationContextHolder.get();
		DataManager dataMan = appContext.getBean(DataManager.class);
		SchemaManager _schemaManager = context.getBean(SchemaManager.class);
		AccessManager accessMan = context.getBean(AccessManager.class);
		final String settingId = Settings.SYSTEM_CSW_TRANSACTION_XPATH_UPDATE_CREATE_NEW_ELEMENTS;
		boolean createXpathNodeIfNotExists = context.getBean(SettingManager.class).getValueAsBool(settingId);

		SimpleMetadataProcessingReport report = new SimpleMetadataProcessingReport();
		report.setTotalRecords(setOfUuidsToEdit.size());

		String changeDate = null;
		final MetadataRepository metadataRepository = context.getBean(MetadataRepository.class);
		for (String recordUuid : setOfUuidsToEdit) {
			Metadata record = metadataRepository.findOneByUuid(recordUuid);
			if (record == null) {
				report.incrementNullRecords();
			} else if (!accessMan.isOwner(serviceContext, String.valueOf(record.getId()))) {
				report.addNotEditableMetadataId(record.getId());
			} else {
				// Processing
				try {
					EditLib editLib = new EditLib(_schemaManager);
					MetadataSchema metadataSchema = _schemaManager.getSchema(record.getDataInfo().getSchemaId());
					Element metadata = record.getXmlData(false);
					boolean metadataChanged = false;

					Iterator<BatchEditParameter> listOfUpdatesIterator = listOfUpdates.iterator();
					while (listOfUpdatesIterator.hasNext()) {
						BatchEditParameter batchEditParameter = listOfUpdatesIterator.next();

						AddElemValue propertyValue = new AddElemValue(batchEditParameter.getValue());

						metadataChanged = editLib.addElementOrFragmentFromXpath(metadata, metadataSchema,
								batchEditParameter.getXpath(), propertyValue, createXpathNodeIfNotExists);
					}
					if (metadataChanged) {
						boolean validate = false;
						boolean ufo = false;
						boolean index = true;
						dataMan.updateMetadata(serviceContext, record.getId() + "", metadata, validate, ufo, index,
								"eng", // Not used when validate is false
								changeDate, false);
						report.addMetadataInfos(record.getId(), "Metadata updated.");
					}
				} catch (Exception e) {
					report.addMetadataError(record.getId(), e);
				}
				report.incrementProcessedRecords();
			}
		}
		report.close();
		return report;
	}

	/**
	 * The service updates records by uploading the csv file
	 */
	@ApiOperation(value = "Updates records by uploading the csv file")
	@RequestMapping(value = "/batchediting/csv", method = RequestMethod.POST, produces = {
			MediaType.APPLICATION_JSON_VALUE })
	@ApiResponses(value = { @ApiResponse(code = 201, message = "Return a report of what has been done."),
			@ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT) })
	@PreAuthorize("hasRole('Administrator')")
	@ResponseStatus(HttpStatus.CREATED)
	@ResponseBody
	public SimpleMetadataProcessingReport batchUpdateUsingCSV(@RequestParam(value = "file") MultipartFile file,
			@RequestParam(value = "mode") String mode, HttpServletRequest request) {

		SimpleMetadataProcessingReport report = new SimpleMetadataProcessingReport();

		ServiceContext serviceContext = ApiUtils.createServiceContext(request);

		Log.debug(Geonet.SEARCH_ENGINE, "ECAT, BatchEditsApi mode: " + mode);

		// File csvFile = new File(file.getOriginalFilename());
		try {
			// csvFile.createNewFile();
			File csvFile = File.createTempFile(file.getOriginalFilename(), "csv");
			FileUtils.copyInputStreamToFile(file.getInputStream(), csvFile);
			processCsv(csvFile, context, serviceContext, mode, report);

		} catch (Exception e) {
			Log.error(Geonet.SEARCH_ENGINE, "ECAT, BatchEditsApi (C) Stacktrace is\n" + Util.getStackTrace(e));
			report.addError(e);
		}

		return report;

	}
	
	/**
	 * The service updates records by uploading the csv file
	 */
	@ApiOperation(value = "Get batch edit report history.")
	@RequestMapping(value = "/batchediting/history", method = RequestMethod.GET, produces = {
			MediaType.APPLICATION_JSON_VALUE })
	@ApiResponses(value = { @ApiResponse(code = 201, message = "Return a report of what has been done."),
			@ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT) })
	@PreAuthorize("hasRole('Administrator')")
	@ResponseStatus(HttpStatus.CREATED)
	@ResponseBody
	public List<CustomReport> batchUpdateHistory(HttpServletRequest request) {
		
		try{
			Type listType = new TypeToken<List<CustomReport>>() {}.getType();
	
			SettingRepository settingRepo = context.getBean(SettingRepository.class);
			Setting sett = settingRepo.findOne(Settings.METADATA_BATCHEDIT_HISTORY);
	
			if(sett != null){
				List<CustomReport> report = g.fromJson(sett.getValue(), listType);
				return report;
			}
		}catch(Exception e){}
		
		return null;

	}

	/**
	 * 
	 * @param csvFile
	 * @param context
	 * @param serviceContext
	 * @param mode
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public SimpleMetadataProcessingReport processCsv(File csvFile, ApplicationContext context,
			ServiceContext serviceContext, String mode, SimpleMetadataProcessingReport report) {

		// Create folder in s3 bucket with current date
		Date datetime = new Date(System.currentTimeMillis());
		String dateTimeStr = Geonet.DATE_FORMAT.format(datetime);

		AmazonS3 s3client = getS3Client();

		try {
			xpathExpr = new BatchEditXpath().loadXpath();
		} catch (JDOMException e) {
			Log.error(Geonet.SEARCH_ENGINE, "Unable to loadXpath, " + e.getMessage());
		}
		SAXBuilder sb = new SAXBuilder();
		// final CSVBatchEdit cbe = context.getBean(CSVBatchEdit.class);
		CSVBatchEdit cbe = new CSVBatchEdit(context);
		final MetadataRepository metadataRepository = context.getBean(MetadataRepository.class);
		final SchemaManager schemaManager = context.getBean(SchemaManager.class);
		final DataManager dataMan = context.getBean(DataManager.class);
		EditLib editLib = new EditLib(schemaManager);

		CSVParser parser = null;
		try {
			// Parse the csv file
			parser = CSVParser.parse(csvFile, Charset.defaultCharset(), CSVFormat.EXCEL.withHeader());
			// report.setTotalRecords(parser.getRecords().size());
		} catch (IOException e1) {
			Log.error(Geonet.SEARCH_ENGINE, e1.getMessage());
		}
		// Currently only supports iso19115-3 standard
		Path p = schemaManager.getSchemaDir("iso19115-3");
		for (CSVRecord csvr : parser) {

			final int id;

			Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> csvRecord.toString() : " + csvr.toString());
			try {
				Metadata record = null;
				if (!csvr.isMapped("uuid")) {
					if (csvr.isMapped("eCatId")) {
						id = Integer.parseInt(csvr.get("eCatId"));

						Log.debug(Geonet.SEARCH_ENGINE,
								"CSVRecord, BatchEditsApi --> csvRecord.get(eCatId) : " + csvr.get("eCatId"));

						// Search record based on eCatId from lucene index
						Element request = Xml
								.loadString("<request><isAdmin>true</isAdmin><_isTemplate>n</_isTemplate><eCatId>"
										+ csvr.get("eCatId") + "</eCatId><fast>index</fast></request>", false);
						try {
							record = cbe.getMetadataByLuceneSearch(context, serviceContext, request);
						} catch (BatchEditException e) {
							report.addMetadataError(id, new Exception(e.getMessage()));
							// report.incrementNullRecords();
							continue;
						}
					} else {// If there is no valid uuid and ecatId, doesn't
							// process this record and continue to execute next
							// record
						report.addError(new Exception("Unable to process record number " + csvr.getRecordNumber()));
						// report.incrementNullRecords();
						continue;
					}

				} else {// find record by uuid, if its defined in csv file
					record = metadataRepository.findOneByUuid(csvr.get("uuid"));
					if (csvr.isMapped("eCatId")) {
						id = Integer.parseInt(csvr.get("eCatId"));
					} else {
						id = record.getId();
					}

				}

				if (record == null) {
					report.addError(new Exception(
							"No metadata found, Unable to process record number " + csvr.getRecordNumber()));
					// report.incrementNullRecords();
					continue;
				}

				if (!saveToS3Bucket(s3client, dateTimeStr, record)) {
					report.addError(new Exception("Unable to backup record uuid/ecat: " + id));
					continue;
				}

				MetadataSchema metadataSchema = schemaManager.getSchema(record.getDataInfo().getSchemaId());
				Element metadata = record.getXmlData(false);

				Log.debug(Geonet.SEARCH_ENGINE, "CSVRecord, BatchEditsApi --> record.getDataInfo().getRoot() : "
						+ record.getDataInfo().getRoot());

				Document document = sb.build(new StringReader(record.getData()));

				Iterator iter = parser.getHeaderMap().entrySet().iterator();
				List<BatchEditParam> listOfUpdates = new ArrayList<>();

				// Iterate through all csv records, and create list of batchedit
				// parameter with xpath and values
				while (iter.hasNext()) {
					Map.Entry<String, Integer> header = (Map.Entry<String, Integer>) iter.next();
					Log.debug(Geonet.SEARCH_ENGINE, header.getKey() + " - " + header.getValue());

					XPath _xpath = xpathExpr.get(header.getKey());

					if (_xpath != null) {
						BatchEditReport batchreport = cbe.removeOrAddElements(context, serviceContext, header, csvr,
								_xpath, document, listOfUpdates, mode);
						batchreport.getErrorInfo().stream().forEach(err -> {
							report.addMetadataError(id, new Exception(err));
						});
						batchreport.getProcessInfo().stream().forEach(info -> {
							report.addMetadataInfos(id, info);
						});
					}
				}

				boolean metadataChanged = false;

				Iterator<BatchEditParam> listOfUpdatesIterator = listOfUpdates.iterator();
				Log.debug(Geonet.SEARCH_ENGINE, "BatchEditsApi --> listOfUpdates : " + listOfUpdates.size());

				metadata = document.getRootElement();

				// Iterate through batchedit parameter list and add elements
				while (listOfUpdatesIterator.hasNext()) {
					BatchEditParam batchEditParam = listOfUpdatesIterator.next();

					Log.debug(Geonet.SEARCH_ENGINE,
							"CSVBatchEdit --> batchEditParameter : " + batchEditParam.toString());

					AddElemValue propertyValue = new AddElemValue(batchEditParam.getValue());

					metadataChanged = editLib.addElementOrFragmentFromXpath(metadata, metadataSchema,
							batchEditParam.getXpath(), propertyValue, true);
				}

				if (metadataChanged) {
					Log.debug(Geonet.SEARCH_ENGINE, "BatchEditsApi --> updating Metadata.........");
					dataMan.updateMetadata(serviceContext, record.getId() + "", metadata, false, false, true, "eng",
							null, false);
					report.addMetadataInfos(id, "Metadata updated, uuid: " + record.getUuid());
					report.incrementProcessedRecords();
				}

			} catch (Exception e) {
				Log.error(Geonet.SEARCH_ENGINE, "Exception :" + e.getMessage());
			}

		}

		// create entry for this batch edit in s3 bucket
		SettingRepository settingRepo = context.getBean(SettingRepository.class);
		addEntry(report, dateTimeStr, settingRepo);
				
		return report;
	}

	private AmazonS3 getS3Client() {

		AmazonS3 s3client = AmazonS3ClientBuilder.standard().withRegion(s3uri.getRegion()).build();

		return s3client;
	}

	private boolean saveToS3Bucket(AmazonS3 s3client, String dateTimeStr, Metadata md) {
		try {
			byte[] bytes = md.getData().getBytes();
			ObjectMetadata metadata = new ObjectMetadata();
			metadata.setContentLength(bytes.length);
			InputStream targetStream = new ByteArrayInputStream(bytes);

			PutObjectRequest putObj = new PutObjectRequest(s3uri.getBucket(), dateTimeStr + "/" + md.getUuid() + ".xml",
					targetStream, metadata).withCannedAcl(CannedAccessControlList.PublicRead);

			s3client.putObject(putObj);
		} catch (Exception e) {
			return false;
		}

		return true;
	}

	private boolean addEntry(SimpleMetadataProcessingReport report, String dateTime, SettingRepository settingRepo){
		
		try{
			Type listType = new TypeToken<List<CustomReport>>() {}.getType();
			
			List<CustomReport> target = new LinkedList<CustomReport>();
			CustomReport customReport = new CustomReport();
			customReport.setErrorReport(report.getMetadataErrors());
			customReport.setInfoReport(report.getMetadataInfos());
			customReport.setProcessedRecords(report.getNumberOfRecordsProcessed());
			customReport.setDateTime(dateTime);
			
			target.add(customReport);
			Setting sett = settingRepo.findOne(Settings.METADATA_BATCHEDIT_HISTORY);
			
			if(sett == null){
				sett = new Setting();
				sett.setName(Settings.METADATA_BATCHEDIT_HISTORY);
				sett.setDataType(SettingDataType.JSON);
				sett.setPosition(200199);
				String _rep = g.toJson(target, listType);
				Log.debug(Geonet.SEARCH_ENGINE, "BatchEditsApi --> _rep :" + _rep);
				sett.setValue(_rep);
			}else{
				List<CustomReport> target2 = g.fromJson(sett.getValue(), listType);
				target2.add(customReport);
				String _rep = g.toJson(target2, listType);
				sett.setValue(_rep);
			}
		
			settingRepo.save(sett);
		}catch (Exception e) {
			return false;
		}
		
		return true;
	}

}

class CustomReport {
	protected int processedRecords = 0;
	protected String dateTime;
	protected List<EditErrorReport> errorReport;
	protected List<EditInfoReport> infoReport;
	
//	protected Map<Integer, List<String>> metadataErrors = new HashMap<Integer, List<String>>();
//    protected Map<Integer, List<String>> metadataInfos = new HashMap<Integer, List<String>>();
	public int getProcessedRecords() {
		return processedRecords;
	}
	public void setProcessedRecords(int processedRecords) {
		this.processedRecords = processedRecords;
	}
	public String getDateTime() {
		return dateTime;
	}
	public void setDateTime(String dateTime) {
		this.dateTime = dateTime;
	}
	
	public List<EditErrorReport> getErrorReport() {
		return errorReport;
	}
	public void setErrorReport(Map<Integer, ArrayList<ErrorReport>> metadataErrors) {
		this.errorReport = new ArrayList<>();
		metadataErrors.entrySet().stream().forEach(e -> {
			EditErrorReport eer = new EditErrorReport();
			eer.setId(e.getKey());
			eer.setMetadataErrors(e.getValue().stream().map(ErrorReport::getMessage).collect(Collectors.toList()));
			this.errorReport.add(eer);
		});
	}
	
	public List<EditInfoReport> getInfoReport() {
		return infoReport;
	}
	public void setInfoReport(Map<Integer, ArrayList<InfoReport>> metadataInfos) {
		this.infoReport = new ArrayList<>();
		metadataInfos.entrySet().stream().forEach(e -> {
			EditInfoReport eir = new EditInfoReport();
			eir.setId(e.getKey());
			eir.setMetadataInfos(e.getValue().stream().map(InfoReport::getMessage).collect(Collectors.toList()));
			this.infoReport.add(eir);
		});
	}
	
	/*public Map<Integer, List<String>> getMetadataErrors() {
		return metadataErrors;
	}
	public void setMetadataErrors(Map<Integer, ArrayList<ErrorReport>> metadataErrors) {
		this.metadataErrors = new HashMap<>();
		metadataErrors.entrySet().stream().forEach(e -> {
			this.metadataErrors.put(e.getKey(), e.getValue().stream().map(ErrorReport::getMessage).collect(Collectors.toList()));
		});
		//this.metadataErrors = metadataErrors;
	}
	public Map<Integer, List<String>> getMetadataInfos() {
		return metadataInfos;
	}
	public void setMetadataInfos(Map<Integer, ArrayList<InfoReport>> metadataInfos) {
		this.metadataInfos = new HashMap<>();
		metadataInfos.entrySet().stream().forEach(e -> {
			this.metadataInfos.put(e.getKey(), e.getValue().stream().map(InfoReport::getMessage).collect(Collectors.toList()));
		});
		//this.metadataInfos = metadataInfos;
	}*/
    
	


	class EditErrorReport {
		private int id;
		private List<String> metadataErrors;

		public int getId() {
			return id;
		}

		public void setId(int id) {
			this.id = id;
		}

		public List<String> getMetadataErrors() {
			return metadataErrors;
		}

		public void setMetadataErrors(List<String> metadataErrors) {
			this.metadataErrors = metadataErrors;
		}

	}
	
	class EditInfoReport {
		private int id;
		private List<String> metadataInfos;

		public int getId() {
			return id;
		}

		public void setId(int id) {
			this.id = id;
		}

		public List<String> getMetadataInfos() {
			return metadataInfos;
		}

		public void setMetadataInfos(List<String> metadataInfos) {
			this.metadataInfos = metadataInfos;
		}

	}
    
}