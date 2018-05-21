package org.fao.geonet.api.records;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

import org.fao.geonet.domain.MetadataType;
import org.fao.geonet.kernel.mef.MEFLib;
import org.fao.geonet.services.AbstractServiceIntegrationTest;
import org.junit.Before;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import jeeves.server.context.ServiceContext;
import junit.framework.Assert;

/**
 * Tests for class {@link MetadataInsertDeleteApi}.
 *
 * @author joseph john
 **/
public class MetadataInsertDeleteApiTest extends AbstractServiceIntegrationTest {

	private ServiceContext context;
	
	@Autowired
	private WebApplicationContext wac;

	@Before
	public void setUp() throws Exception {
		this.context = createServiceContext();
	}
	
	@Test
	public void testInsertFromAWSS3Bucket() throws Exception{
		
		MockMvc mockMvc = MockMvcBuilders.webAppContextSetup(this.wac).build();
		MockHttpSession mockHttpSession = loginAsAnonymous();
		String query = "serverFolder=https://s3-ap-southeast-2.amazonaws.com/ga-ecat-import&metadataType=METADATA&uuidProcessing=NOTHING&transformWith=_none_&assignToCatalog=on&group=&category=";
		mockMvc.perform(get("/api/records/" + query).session(mockHttpSession).accept(MediaType.APPLICATION_JSON));
	            
		MetadataInsertDeleteApi api = new MetadataInsertDeleteApi();
		api.insert(MetadataType.METADATA, null, null, null, "https://s3-ap-southeast-2.amazonaws.com/ga-ecat-import",null, false, false, MEFLib.UuidAction.NOTHING, 
					"", null, false, "_none_", null, null, null);
		//api.insert(metadataType, xml, url, serverFolder, recursiveSearch, assignToCatalog, uuidProcessing, 
					//group, category, rejectIfInvalid, transformWith, schema, extra, request)
		Assert.assertTrue(true);
	}
}
