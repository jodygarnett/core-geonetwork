<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
	xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
  xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0">

	<xsl:output method="text"/>
	<xsl:output method="xml" indent="yes" name="xml"/>

	<xsl:template match="/">

		<xsl:for-each select="//ROW">
			<xsl:variable name="licenceno" select="COLUMN[@NAME='LICENCENO']" />
			<xsl:variable name="licence" select="COLUMN[@NAME='LICENCE_NAME']" />
			<xsl:variable name="licencetype" select="COLUMN[@NAME='LICENCE_TYPE']" />
			<xsl:variable name="filename" select="concat('licences/',$licenceno,'.xml')" />
			<xsl:message>Creating <xsl:value-of select="$filename"/></xsl:message>
			<xsl:result-document href="{$filename}" format="xml">

	<mco:MD_LegalConstraints
		uuid="urn:ga-licences:{$licenceno}"
		title="Licence: {$licence} {$licencetype}">
		<!-- TODO: add link to CC browse graphic? via mco:graphic element -->
		<mco:reference>
			<cit:CI_Citation>
				<cit:title>
					<gco:CharacterString><xsl:value-of select="$licence"/></gco:CharacterString>
				</cit:title>
				<xsl:if test="normalize-space($licencetype)">
					<cit:alternateTitle>
						<gco:CharacterString><xsl:value-of select="$licencetype"/></gco:CharacterString>
					</cit:alternateTitle>
				</xsl:if>
				<xsl:if test="normalize-space(COLUMN[@NAME='VERSION'])">
					<cit:edition>
						<gco:CharacterString><xsl:value-of select="COLUMN[@NAME='VERSION']"/></gco:CharacterString>
					</cit:edition>
				</xsl:if>
				<xsl:apply-templates mode="online" select="COLUMN[@NAME='LICENCE']"/>
			</cit:CI_Citation>
		</mco:reference>
		<!-- TODO: maybe include persons from ga licence table responsible for entering/modifying licence via mco:responsibility element -->
		<mco:accessConstraints>
			<mco:MD_RestrictionCode codeList="codeListLocation#MD_RestrictionCode" codeListValue="license">license</mco:MD_RestrictionCode>
		</mco:accessConstraints>
		<mco:useConstraints>
			<mco:MD_RestrictionCode codeList="codeListLocation#MD_RestrictionCode" codeListValue="license">license</mco:MD_RestrictionCode>
		</mco:useConstraints>
	</mco:MD_LegalConstraints>
		
			</xsl:result-document>
		</xsl:for-each>

	</xsl:template>
			

	<xsl:template mode="online" match="COLUMN[@NAME='LICENCE' and normalize-space()!='' and starts-with(text(),'http:')]">
      <cit:onlineResource>
        <cit:CI_OnlineResource>
          <cit:linkage>
						<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
          </cit:linkage>
        </cit:CI_OnlineResource>
      </cit:onlineResource>
	</xsl:template>
</xsl:stylesheet>
  
