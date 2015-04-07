<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:gco="http://standards.iso.org/19139/gco/1.0/2014-12-25"
  xmlns:cit="http://standards.iso.org/19115/-3/cit/1.0/2014-12-25">

	<xsl:output method="text"/>
	<xsl:output method="xml" indent="yes" name="xml"/>

	<xsl:template match="/">

		<xsl:for-each select="//ROW">
			<xsl:variable name="name" select="COLUMN[@NAME='PUBLISHER']" />
			<xsl:variable name="filename" select="concat('publishers/',position(),'.xml')" />
			<xsl:message>Creating <xsl:value-of select="$filename"/></xsl:message>
			<xsl:result-document href="{$filename}" format="xml">

	<cit:CI_Responsibility
		uuid="urn:ga-publishers:{$name}"
		title="ResourcePublishher: {$name}">
		<cit:role>
			<cit:CI_RoleCode codeList="codeListLocation#CI_RoleCode" codeListValue="publisher">publisher</cit:CI_RoleCode>
		</cit:role>

		<cit:party>
			<cit:CI_Organisation>
      	<cit:name>
        	<gco:CharacterString><xsl:value-of select="$name"/></gco:CharacterString>
      	</cit:name>
				<!-- TODO: contact information for publisher? -->
			</cit:CI_Organisation>
		</cit:party>

	</cit:CI_Responsibility>


			</xsl:result-document>
		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>
  
