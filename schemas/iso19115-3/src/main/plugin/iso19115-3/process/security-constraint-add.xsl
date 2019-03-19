<?xml version="1.0" encoding="UTF-8"?>
<!--  
Stylesheet used to update metadata for a service and 
attached it to the metadata for data.
-->
<xsl:stylesheet version="2.0" xmlns:gmd="http://standards.iso.org/iso/19115/-3/gmd/1.0"
    xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
    xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
    xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
    xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
    xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gn="http://www.fao.org/geonetwork"
    xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:template match="/mdb:MD_Metadata | *[@gco:isoType = 'mdb:MD_Metadata']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>

            <xsl:apply-templates select="mdb:metadataIdentifier"/>
            <xsl:apply-templates select="mdb:defaultLocale"/>
            <xsl:apply-templates select="mdb:parentMetadata"/>
            <xsl:apply-templates select="mdb:metadataScope"/>
            <xsl:apply-templates select="mdb:contact"/>
            <xsl:apply-templates select="mdb:dateInfo"/>
            <xsl:apply-templates select="mdb:metadataStandard"/>
            <xsl:apply-templates select="mdb:metadataProfile"/>
            <xsl:apply-templates select="mdb:alternativeMetadataReference"/>
            <xsl:apply-templates select="mdb:otherLocale"/>
            <xsl:apply-templates select="mdb:metadataLinkage"/>
            <xsl:apply-templates select="mdb:spatialRepresentationInfo"/>
            <xsl:apply-templates select="mdb:referenceSystemInfo"/>
            <xsl:apply-templates select="mdb:metadataExtensionInfo"/>
            <xsl:apply-templates select="mdb:identificationInfo"/>
			<xsl:apply-templates select="mdb:contentInfo"/>
            <xsl:apply-templates select="mdb:distributionInfo"/>
            <xsl:apply-templates select="mdb:dataQualityInfo"/>
            <xsl:apply-templates select="mdb:resourceLineage"/>
            <xsl:apply-templates select="mdb:portrayalCatalogueInfo"/>

            <mdb:metadataConstraints>
                <mco:MD_SecurityConstraints>
                    <mco:reference>
                        <cit:CI_Citation>
                            <cit:title>
                                <gco:CharacterString>Australian Government Security ClassificationSystem </gco:CharacterString>
                            </cit:title>
                            <cit:editionDate>
                                <gco:Date>2018-11-01</gco:Date>
                            </cit:editionDate>
                            <cit:onlineResource>
                                <cit:CI_OnlineResource>
                                    <cit:linkage>
                                        <gco:CharacterString>https://www.protectivesecurity.gov.au/Pages/default.aspx</gco:CharacterString>
                                    </cit:linkage>
                                </cit:CI_OnlineResource>
                            </cit:onlineResource>
                        </cit:CI_Citation>
                    </mco:reference>
                    <mco:classification>
                        <mco:MD_ClassificationCode codeList="codeListLocation#MD_ClassificationCode" codeListValue="unclassified"/>
                    </mco:classification>
                </mco:MD_SecurityConstraints>
            </mdb:metadataConstraints>

            <xsl:apply-templates select="mdb:applicationSchemaInfo"/>
            <xsl:apply-templates select="mdb:metadataMaintenance"/>
            <xsl:apply-templates select="mdb:acquisitionInformation"/>
        </xsl:copy>

    </xsl:template>

    <!-- Remove geonet:* elements. -->
    <xsl:template match="gn:*" priority="2"/>

    <!-- Copy everything. -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
