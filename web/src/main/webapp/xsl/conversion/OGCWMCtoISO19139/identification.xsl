<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:wmc="http://www.opengis.net/context"
                xmlns:wmc11="http://www.opengeospatial.net/context"
                xmlns:ows-context="http://www.opengis.net/ows-context"
                xmlns:ows="http://www.opengis.net/ows"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:math="http://exslt.org/math"
                exclude-result-prefixes="#all">
  
  <xsl:variable name="df">[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]</xsl:variable>

  <xsl:template match="*" mode="DataIdentification">
    <xsl:param name="topic"/>
    <xsl:param name="lang"/>

    <gmd:citation>
      <gmd:CI_Citation>
        <gmd:title>
          <gco:CharacterString><xsl:value-of select="wmc:General/wmc:Title|
                                                     wmc11:General/wmc11:Title|
                                                     ows-context:General/ows:Title"/></gco:CharacterString>
        </gmd:title>
        <!-- date is mandatory -->
        <gmd:date>
          <gmd:CI_Date>
            <gmd:date>
              <gco:DateTime><xsl:value-of select="format-dateTime(current-dateTime(),$df)"/></gco:DateTime>
            </gmd:date>
            <gmd:dateType>
              <gmd:CI_DateTypeCode codeListValue="publication"
                                   codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" />
            </gmd:dateType>
          </gmd:CI_Date>
        </gmd:date>
        
        <gmd:presentationForm>
          <gmd:CI_PresentationFormCode codeListValue="mapDigital"
            codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_PresentationFormCode"
          />
        </gmd:presentationForm>
      </gmd:CI_Citation>
    </gmd:citation>

    <gmd:abstract>
      <gco:CharacterString><xsl:value-of select="wmc:General/wmc:Abstract|
                                                 wmc11:General/wmc11:Abstract|
                                                 ows-context:General/ows:Abstract"/></gco:CharacterString>
    </gmd:abstract>

    <gmd:status>
      <gmd:MD_ProgressCode codeList="./resources/codeList.xml#MD_ProgressCode" codeListValue="completed" />
    </gmd:status>

    <xsl:for-each select="wmc:General/wmc:ContactInformation|
                          wmc11:General/wmc11:ContactInformation|
                          ows-context:General/ows:ServiceProvider">
      <gmd:pointOfContact>
        <gmd:CI_ResponsibleParty>
          <xsl:apply-templates select="." mode="RespParty"/>
        </gmd:CI_ResponsibleParty>
      </gmd:pointOfContact>
    </xsl:for-each>

    <!-- TODO: add graphic overview -->
    
    <xsl:for-each select="wmc:General/wmc:KeywordList|
                          wmc11:General/wmc11:KeywordList|
                          ows-context:General/ows:Keywords">
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords>
          <xsl:apply-templates select="." mode="Keywords"/>
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>
    </xsl:for-each>
    
    <gmd:language>
      <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/" codeListValue="$lang"/>
    </gmd:language>


    <gmd:topicCategory>
      <gmd:MD_TopicCategoryCode><xsl:value-of select="$topic"/></gmd:MD_TopicCategoryCode>
    </gmd:topicCategory>

  </xsl:template>



  <xsl:template match="*" mode="Keywords">
    <xsl:for-each select=".//*:Keyword">
      <gmd:keyword>
        <gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
      </gmd:keyword>
    </xsl:for-each>

    <gmd:type>
      <gmd:MD_KeywordTypeCode codeList="./resources/codeList.xml#MD_KeywordTypeCode" codeListValue="theme" />
    </gmd:type>

  </xsl:template>

</xsl:stylesheet>