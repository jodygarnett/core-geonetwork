//==============================================================================
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Joseph John,
//===	Canberra - Australia. email: joseph.john@ga.gov.au
//==============================================================================
package org.fao.geonet.kernel.batchedit;

import java.util.Arrays;
import java.util.List;
import java.util.Map.Entry;

import org.apache.commons.csv.CSVRecord;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.exceptions.BatchEditException;
import org.jdom.Element;
import org.jdom.output.XMLOutputter;
import org.jdom.xpath.XPath;
import org.springframework.context.ApplicationContext;

import jeeves.server.context.ServiceContext;

/**
 * This class creates extent - Geographical Element, Vertical extent, Vertical CRS and Temporal extent
 * 
 * @author Joseph John - U89263
 *
 */
public class ExtentEditElement implements EditElement {

	XMLOutputter out = new XMLOutputter();
	
	@Override
	public void removeAndAddElement(CSVBatchEdit batchEdit, ApplicationContext context, ServiceContext serContext, Entry<String, Integer> header, CSVRecord csvr, XPath _xpath, 
			List<BatchEditParam> listOfUpdates, BatchEditReport report) {


		String headerVal = header.getKey();
		
		String[] contents = csvr.get(headerVal).split(content_separator);
		
		for (String content : contents) {
			
			try{
				String[] values = content.split(type_separator);
	
				Element rootE = null;
				if(headerVal.equalsIgnoreCase(Geonet.EditType.GEOBOX))
					rootE = getGeographicBoundingBox(values);
				if(headerVal.equalsIgnoreCase(Geonet.EditType.VERTICAL))
					rootE = getVerticalExtent(batchEdit, values);
				if(headerVal.equalsIgnoreCase(Geonet.EditType.VERTICAL_CRS))
					rootE = getVerticalRefSystemElement(batchEdit, values);
				if(headerVal.equalsIgnoreCase(Geonet.EditType.TEMPORAL))
					rootE = getTemporalExtent(values);
				
				if(rootE != null){
					String strEle = out.outputString(rootE);
					String _val = "<gn_add>" + strEle + "</gn_add>";
		
					BatchEditParam e = new BatchEditParam(_xpath.getXPath(), _val);
					listOfUpdates.add(e);
				}
				
			}catch(BatchEditException e){
				report.getErrorInfo().add(e.getMessage());
			}
	
		}
				
	}
	
	/**
	 * Creates geographical bounding box
	 * 
	 * @param value
	 * @return
	 * @throws BatchEditException
	 */
	private Element getGeographicBoundingBox(String[] value) throws BatchEditException {
		try {
			//Element ex = new Element("extent", Geonet.Namespaces.MRI);
			Element exEx = new Element("EX_Extent", Geonet.Namespaces.GEX);
			Element geoE = new Element("geographicElement", Geonet.Namespaces.GEX);
			Element exGeoE = new Element("EX_GeographicBoundingBox", Geonet.Namespaces.GEX);

			Element westBL = new Element("westBoundLongitude", Geonet.Namespaces.GEX);
			Element eastBL = new Element("eastBoundLongitude", Geonet.Namespaces.GEX);
			Element southtBL = new Element("southBoundLatitude", Geonet.Namespaces.GEX);
			Element northBL = new Element("northBoundLatitude", Geonet.Namespaces.GEX);

			if (value.length > 0)
				westBL.addContent(new Element("Decimal", Geonet.Namespaces.GCO_3).setText(value[0]));

			if (value.length > 1)
				eastBL.addContent(new Element("Decimal", Geonet.Namespaces.GCO_3).setText(value[1]));

			if (value.length > 2)
				southtBL.addContent(new Element("Decimal", Geonet.Namespaces.GCO_3).setText(value[2]));

			if (value.length > 3)
				northBL.addContent(new Element("Decimal", Geonet.Namespaces.GCO_3).setText(value[3]));

			exGeoE.addContent(Arrays.asList(westBL, eastBL, southtBL, northBL));
			//ex.addContent(exEx.addContent(geoE.addContent(exGeoE)));
			exEx.addContent(geoE.addContent(exGeoE));
			return exEx;
		} catch (Exception e) {
			throw new BatchEditException("Unable to process GeographicBoundingBox having values: " + Arrays.asList(value));
		}
	}
	
	/**
	 * Creates vertical extent element
	 * @param batchEdit
	 * @param value
	 * @return
	 * @throws BatchEditException
	 */
	private Element getVerticalExtent(CSVBatchEdit batchEdit, String[] value) throws BatchEditException {
		try {
			//Element ex = new Element("extent", Geonet.Namespaces.MRI);
			Element exEx = new Element("EX_Extent", Geonet.Namespaces.GEX);
			Element vertE = new Element("verticalElement", Geonet.Namespaces.GEX);
			Element exVertE = verticalMinMaxElement(batchEdit, value);

			//ex.addContent(exEx.addContent(vertE.addContent(exVertE)));
			exEx.addContent(vertE.addContent(exVertE));
			return exEx;
			
		} catch (Exception e) {
			throw new BatchEditException("Unable to process vertical Extent having values: " + Arrays.asList(value));
		}
	}
	
	/**
	 * 
	 * @param batchEdit
	 * @param value
	 * @return
	 * @throws BatchEditException
	 */
	private Element verticalMinMaxElement(CSVBatchEdit batchEdit, String[] value) throws BatchEditException{
		
		try{
			Element exVertE = new Element("EX_VerticalExtent", Geonet.Namespaces.GEX);
	
			Element min = new Element("minimumValue", Geonet.Namespaces.GEX);
			Element max = new Element("maximumValue", Geonet.Namespaces.GEX);
	
			if (value.length > 0)
				min.addContent(new Element("Real", Geonet.Namespaces.GCO_3).setText(value[0]));
	
			if (value.length > 1)
				max.addContent(new Element("Real", Geonet.Namespaces.GCO_3).setText(value[1]));
			
			exVertE.addContent(Arrays.asList(min, max));
	
			return exVertE;
		}catch(Exception e){
			throw new BatchEditException("Unable to process vertical Min/Max Element having values: " + Arrays.asList(value));
		}
	}
	
	/**
	 * creates vertical crs element
	 * @param batchEdit
	 * @param value
	 * @return
	 * @throws BatchEditException
	 */
	private Element getVerticalRefSystemElement(CSVBatchEdit batchEdit, String[] value) throws BatchEditException{
		
		try{
			//Element exVertCrs = new Element("verticalCRSId", Geonet.Namespaces.GEX);
			Element refSys = new Element("MD_ReferenceSystem", Geonet.Namespaces.MRS);
			Element refSysId = new Element("referenceSystemIdentifier", Geonet.Namespaces.MRS);
			Element mdId = new Element("MD_Identifier", Geonet.Namespaces.MCC);
	
			String codeText = "", codeSpaceText = "", versionText ="";
			/*if(!NumberUtils.isDigits(value[0])){
				String desc = value[0];
				int _1 = desc.indexOf(":") + 1;
				int _2 = desc.lastIndexOf(")");
				ref_code =  desc.substring(_1, _2);
			}*/
			
			//Crs crs = batchEdit.getById(ref_code);
			//if(crs !=null){
			
			if(value.length > 0)
				codeText = value[0];

			if(value.length > 1)
				codeSpaceText = value[1];

			if(value.length > 2)
				versionText = value[2];
			
			Element code = new Element("code", Geonet.Namespaces.MCC);
			//code.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(crs.getDescription()));
			code.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(codeText));
			
			Element codeSpace = new Element("codeSpace", Geonet.Namespaces.MCC);
			codeSpace.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText("EPSG"));
			
			Element version = new Element("version", Geonet.Namespaces.MCC);
			version.addContent(new Element("CharacterString", Geonet.Namespaces.GCO_3).setText(versionText));

			mdId.addContent(Arrays.asList(code, codeSpace, version));
			
			//exVertCrs.addContent(refSys.addContent(refSysId.addContent(mdId)));
			refSys.addContent(refSysId.addContent(mdId));
			return refSys;
			//}
		
			
			
		}catch(Exception e){
			throw new BatchEditException("Unable to process Vertical reference system having values: " + Arrays.asList(value));
		}
		
		
	}
	
	/**
	 * Create temporal extent element
	 * 
	 * @param value
	 * @return
	 * @throws BatchEditException
	 */
	private Element getTemporalExtent(String[] value) throws BatchEditException {

		try{
			Element ex = new Element("extent", Geonet.Namespaces.MRI);
			Element exEx = new Element("EX_Extent", Geonet.Namespaces.GEX);
			Element tempE = new Element("temporalElement", Geonet.Namespaces.GEX);
			Element exTempE = new Element("EX_TemporalExtent", Geonet.Namespaces.GEX);
			Element tempExtent = new Element("extent", Geonet.Namespaces.GEX);

			Element period = new Element("TimePeriod", Geonet.Namespaces.GML);
			period.setAttribute("id", "A1234", Geonet.Namespaces.GML);

			if (value.length > 0)
				period.addContent(new Element("beginPosition", Geonet.Namespaces.GML).setText(value[0]));

			if (value.length > 1)
				period.addContent(new Element("endPosition", Geonet.Namespaces.GML).setText(value[1]));

			tempExtent.addContent(Arrays.asList(period));
			ex.addContent(exEx.addContent(tempE.addContent(exTempE.addContent(tempExtent))));
	
			// out.output(ex, System.out);
			return ex;
		}catch(Exception e){
			throw new BatchEditException("Unable to process TemporalExtent having values: " + Arrays.asList(value));
		}
		
	}

}
