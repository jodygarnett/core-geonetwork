package org.fao.geonet.kernel.batchedit;

import java.util.HashMap;
import java.util.Map;

import org.fao.geonet.constants.Geonet;
import org.jdom.JDOMException;
import org.jdom.xpath.XPath;

public class BatchEditXpath {

	Map<String, XPath> xpathExpr = new HashMap<>();
	
	public Map<String, XPath> loadXpath() throws JDOMException {
		
		xpathExpr.put(Geonet.EditType.TITLE, getXPath("//mdb:identificationInfo/*/mri:citation/*/cit:title/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.ABSTRACT, getXPath("//mdb:identificationInfo/*/mri:abstract/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.PURPOSE, getXPath("//mdb:identificationInfo/*/mri:purpose/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.USE_LIMITATION, getXPath("//mdb:identificationInfo/*/mri:resourceConstraints/mco:MD_LegalConstraints/mco:useLimitation/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.LINEAGE, getXPath("//mdb:resourceLineage/mrl:LI_Lineage/mrl:statement/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.SOURCE_DESC, getXPath("//mdb:resourceLineage/mrl:LI_Lineage/mrl:source/mrl:LI_Source/mrl:description/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.SPACIAL_REF_SYSYTEM, getXPath("//mdb:identificationInfo/*/gex:EX_Extent/gex:verticalElement/*/gex:verticalCRSId/mrs:MD_ReferenceSystem/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.SPACIAL_EXTENT_DESC, getXPath("//mdb:identificationInfo/*/mri:extent/*/gex:description/gco:CharacterString"));
		xpathExpr.put(Geonet.EditType.HORIZONTAL_SPACIAL_REFSYSTEM, getXPath("//mdb:referenceSystemInfo/*/mrs:referenceSystemIdentifier/mcc:MD_Identifier/mcc:code/gco:CharacterString"));
		
		xpathExpr.put(Geonet.EditType.MAINTENANCE_FREQ, getXPath("//mdb:identificationInfo/*/mri:resourceMaintenance/mmi:MD_MaintenanceInformation/mmi:maintenanceAndUpdateFrequency/mmi:MD_MaintenanceFrequencyCode/@codeListValue"));
		xpathExpr.put(Geonet.EditType.STATUS, getXPath("//mdb:identificationInfo/*/mri:status/mcc:MD_ProgressCode/@codeListValue"));
		xpathExpr.put(Geonet.EditType.MD_SECURITY_CONSTRAINT, getXPath("//mdb:metadataConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode/@codeListValue"));
		xpathExpr.put(Geonet.EditType.RES_SECURITY_CONSTRAINT, getXPath("//mdb:identificationInfo/*/mri:resourceConstraints/mco:MD_SecurityConstraints/mco:classification/mco:MD_ClassificationCode/@codeListValue"));
		
		xpathExpr.put(Geonet.EditType.GEOBOX, getXPath("//mdb:identificationInfo/*/mri:extent[*/gex:geographicElement/gex:EX_GeographicBoundingBox]"));
		xpathExpr.put(Geonet.EditType.VERTICAL, getXPath("//mdb:identificationInfo/*/mri:extent[*/gex:verticalElement/gex:EX_VerticalExtent]"));
		xpathExpr.put(Geonet.EditType.VERTICAL_CRS, getXPath("//mdb:identificationInfo/*/mri:extent/*/gex:verticalElement/gex:EX_VerticalExtent/gex:verticalCRSId"));
		xpathExpr.put(Geonet.EditType.TEMPORAL, getXPath("//mdb:identificationInfo/*/mri:extent[*/gex:temporalElement/gex:EX_TemporalExtent]"));
		
		xpathExpr.put(Geonet.EditType.KEYWORD, getXPath("//mdb:identificationInfo/*/mri:descriptiveKeywords[not(mri:MD_Keywords/mri:thesaurusName)]"));
		xpathExpr.put(Geonet.EditType.KEYWORD_THESAURUS, getXPath("//mdb:identificationInfo/*/mri:descriptiveKeywords[mri:MD_Keywords/mri:thesaurusName]"));
		
		xpathExpr.put(Geonet.EditType.MD_CONTACT, getXPath("//mdb:contact"));
		xpathExpr.put(Geonet.EditType.RES_CONTACT, getXPath("//mdb:identificationInfo/*/mri:pointOfContact"));
		xpathExpr.put(Geonet.EditType.RESPONSIBLE_PARTY, getXPath("//mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:citedResponsibleParty"));
		
		xpathExpr.put(Geonet.EditType.CITATION_DATE, getXPath("//mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:date"));
		
		xpathExpr.put(Geonet.EditType.TOPIC_CAT, getXPath("//mdb:identificationInfo/*/mri:topicCategory/mri:MD_TopicCategoryCode"));
		xpathExpr.put(Geonet.EditType.MD_SCOPE, getXPath("//mdb:metadataScope"));
		xpathExpr.put(Geonet.EditType.MD_PARENT, getXPath("//mdb:parentMetadata"));

		xpathExpr.put(Geonet.EditType.DATA_STORAGE_LINK, getXPath("//mdb:identificationInfo/*/mri:citation/cit:CI_Citation/cit:onlineResource"));
		xpathExpr.put(Geonet.EditType.ASSOCIATED_RES, getXPath("//mdb:identificationInfo/*/mri:associatedResource/mri:MD_AssociatedResource/mri:metadataReference/cit:CI_Citation/cit:onlineResource"));
		xpathExpr.put(Geonet.EditType.ADDITIONAL_INFO, getXPath("//mdb:identificationInfo/*/mri:additionalDocumentation"));
		xpathExpr.put(Geonet.EditType.DISTRIBUTION_LINK, getXPath("//mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine"));
		
		xpathExpr.put(Geonet.EditType.RESOURCE_FORMAT, getXPath("//mdb:identificationInfo/*/mri:resourceFormat"));
		xpathExpr.put(Geonet.EditType.DISTRIBUTION_FORMAT, getXPath("//mdb:distributionInfo/*/mrd:distributionFormat"));
		
		return xpathExpr;
	}
	
	public XPath getXPath(String xpath) throws JDOMException {
		XPath _xpath = XPath.newInstance(xpath);
		return _xpath;
	}
}
