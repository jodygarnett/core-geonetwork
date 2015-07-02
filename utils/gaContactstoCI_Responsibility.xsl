<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0">

	<xsl:output method="text"/>
	<xsl:output method="xml" indent="yes" name="xml"/>

	<xsl:template match="/">

		<xsl:for-each select="//ROW">
			<xsl:variable name="contactno" select="COLUMN[@NAME='CONTACT_NO']" />
			<xsl:variable name="filename" select="concat('contacts/',$contactno,'.xml')" />
			<xsl:variable name="organisation" select="COLUMN[@NAME='ORGANISATION']" />
			<xsl:message>Creating <xsl:value-of select="$filename"/></xsl:message>
			<xsl:result-document href="{$filename}" format="xml">

	<cit:CI_Responsibility
		uuid="urn:ga-contacts:{$contactno}"
		title="Contact: {$organisation}">
		<cit:role>
			<cit:CI_RoleCode codeList="codeListLocation#CI_RoleCode" codeListValue="pointOfContact">pointOfContact</cit:CI_RoleCode>
		</cit:role>
		<cit:party>
			<cit:CI_Organisation>
      	<cit:name>
        	<gco:CharacterString><xsl:value-of select="$organisation"/></gco:CharacterString>
      	</cit:name>
				<xsl:if test="normalize-space(COLUMN[@NAME='PHONE']) or
									  	normalize-space(COLUMN[@NAME='ADDRESS1']) or 
									  	normalize-space(COLUMN[@NAME='ADDRESS2']) or 
											normalize-space(COLUMN[@NAME='SUBURB']) or 
											normalize-space(COLUMN[@NAME='STATE']) or 
											normalize-space(COLUMN[@NAME='POSTCODE']) or 
											normalize-space(COLUMN[@NAME='COUNTRY']) or 
											normalize-space(COLUMN[@NAME='EMAIL'])">
      		<cit:contactInfo>
        		<cit:CI_Contact>
							<xsl:apply-templates mode="phone" select="COLUMN[@NAME='PHONE']" /> 
							<xsl:apply-templates mode="phone" select="COLUMN[@NAME='FAX']" /> 
							<xsl:if test="normalize-space(COLUMN[@NAME='ADDRESS1']) or 
									        	normalize-space(COLUMN[@NAME='ADDRESS2']) or
														normalize-space(COLUMN[@NAME='SUBURB']) or 
														normalize-space(COLUMN[@NAME='STATE']) or 
														normalize-space(COLUMN[@NAME='POSTCODE']) or 
														normalize-space(COLUMN[@NAME='COUNTRY']) or 
														normalize-space(COLUMN[@NAME='EMAIL'])">
          			<cit:address>
            			<cit:CI_Address>
										<xsl:if test="normalize-space(COLUMN[@NAME='ADDRESS1'])">
											<cit:deliveryPoint>
												<gco:CharacterString><xsl:value-of select="COLUMN[@NAME='ADDRESS1']"/></gco:CharacterString>
											</cit:deliveryPoint>
										</xsl:if>
										<xsl:if test="normalize-space(COLUMN[@NAME='ADDRESS2'])">
											<cit:deliveryPoint>
												<gco:CharacterString><xsl:value-of select="COLUMN[@NAME='ADDRESS2']"/></gco:CharacterString>
											</cit:deliveryPoint>
										</xsl:if>
										<xsl:if test="normalize-space(COLUMN[@NAME='SUBURB'])">
              				<cit:city>
												<gco:CharacterString><xsl:value-of select="COLUMN[@NAME='SUBURB']"/></gco:CharacterString>
              				</cit:city>
										</xsl:if>
										<xsl:if test="normalize-space(COLUMN[@NAME='STATE'])">
              				<cit:administrativeArea>
												<gco:CharacterString><xsl:value-of select="COLUMN[@NAME='STATE']"/></gco:CharacterString>
              				</cit:administrativeArea>
										</xsl:if>
										<xsl:if test="normalize-space(COLUMN[@NAME='POSTCODE'])">
              				<cit:postalCode>
												<gco:CharacterString><xsl:value-of select="COLUMN[@NAME='POSTCODE']"/></gco:CharacterString>
              				</cit:postalCode>
										</xsl:if>
										<xsl:if test="normalize-space(COLUMN[@NAME='COUNTRY'])">
              				<cit:country>
												<gco:CharacterString><xsl:value-of select="COLUMN[@NAME='COUNTRY']"/></gco:CharacterString>
              				</cit:country>
										</xsl:if>
										<xsl:if test="normalize-space(COLUMN[@NAME='EMAIL'])">
          						<cit:electronicMailAddress>
												<gco:CharacterString><xsl:value-of select="COLUMN[@NAME='EMAIL']"/></gco:CharacterString>
          						</cit:electronicMailAddress>
										</xsl:if>
            			</cit:CI_Address>
          			</cit:address>
							</xsl:if>
							<xsl:apply-templates mode="online" select="COLUMN[@NAME='FTP']"/>
        		</cit:CI_Contact>
      		</cit:contactInfo>
				</xsl:if>
				<xsl:apply-templates mode="position" select="COLUMN[@NAME='POSITION']"/>
			</cit:CI_Organisation>
		</cit:party>
	</cit:CI_Responsibility>
	
			</xsl:result-document>
		</xsl:for-each>

	</xsl:template>

	<xsl:template mode="phone" match="COLUMN[(@NAME='PHONE' or @NAME='FAX') and normalize-space()!='']">
					<cit:phone>
						<cit:CI_Telephone>
							<cit:number>
								<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
							</cit:number>
							<cit:numberType>
								<xsl:choose>
									<xsl:when test="@NAME='PHONE'">
										<cit:CI_TelephoneTypeCode codeList="codeListLocation#CI_TelephoneTypeCode" codeListValue="voice">voice</cit:CI_TelephoneTypeCode>
									</xsl:when>
									<xsl:when test="@NAME='FAX'">
										<cit:CI_TelephoneTypeCode codeList="codeListLocation#CI_TelephoneTypeCode" codeListValue="facsimile">facsimile</cit:CI_TelephoneTypeCode>
									</xsl:when>
								</xsl:choose>
							</cit:numberType>
						</cit:CI_Telephone>
					</cit:phone>
	</xsl:template>

	<xsl:template mode="position" match="COLUMN[@NAME='POSITION' and normalize-space()!='']">
      <cit:individual>
        <cit:CI_Individual>
          <cit:positionName>
						<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
          </cit:positionName>
        </cit:CI_Individual>
      </cit:individual>
	</xsl:template>

	<xsl:template mode="online" match="COLUMN[@NAME='FTP' and normalize-space()!='']">
      <cit:onlineResource>
        <cit:CI_OnlineResource>
          <cit:linkage>
						<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
          </cit:linkage>
        </cit:CI_OnlineResource>
      </cit:onlineResource>
	</xsl:template>
</xsl:stylesheet>
  
