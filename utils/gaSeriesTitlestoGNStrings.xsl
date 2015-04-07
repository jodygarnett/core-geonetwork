<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">

		<xsl:for-each select="//ROW">
			<xsl:variable name="code" select="COLUMN[@NAME='TITLE']" />

			<option value="{$code}"><xsl:value-of select="$code"/></option>
		</xsl:for-each>

		<!-- The options output from this XSLT must be placed in schemaPlugins/iso19115-3/loc/eng/labels.xml as helpers for the 
		     cit:series/cit:CI_Series/cit:name label -->

	</xsl:template>

</xsl:stylesheet>
  
