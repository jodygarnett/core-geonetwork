<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
                xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
                xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
                xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
                xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
                xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
                xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/1.0"
                xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>
   <xsl:include xmlns:svrl="http://purl.oclc.org/dsdl/svrl" href="../../../xsl/utils-fn.xsl"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="lang"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="thesaurusDir"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="rule"/>
   <xsl:variable xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="loc"
                 select="document(concat('../loc/', $lang, '/', substring-before($rule, '.xsl'), '.xml'))"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
            <xsl:variable name="p_1" select="1+    count(preceding-sibling::*[name()=name(current())])"/>
            <xsl:if test="$p_1&gt;1 or following-sibling::*[name()=name(current())]">[<xsl:value-of select="$p_1"/>]</xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>']</xsl:text>
            <xsl:variable name="p_2"
                          select="1+   count(preceding-sibling::*[local-name()=local-name(current())])"/>
            <xsl:if test="$p_2&gt;1 or following-sibling::*[local-name()=local-name(current())]">[<xsl:value-of select="$p_2"/>]</xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="Schematron validation for Version 2.0 of Geoscience Australia profile of ISO 19115-1:2014 standard"
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml/3.2" prefix="gml"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/srv/2.0" prefix="srv"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/cit/1.0" prefix="cit"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/gex/1.0" prefix="gex"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mco/1.0" prefix="mco"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mdb/1.0" prefix="mdb"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mex/1.0" prefix="mex"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mmi/1.0" prefix="mmi"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mrc/1.0" prefix="mrc"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mrd/1.0" prefix="mrd"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mri/1.0" prefix="mri"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mrl/1.0" prefix="mrl"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mrs/1.0" prefix="mrs"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mcc/1.0" prefix="mcc"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/lan/1.0" prefix="lan"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/gco/1.0" prefix="gco"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19157/-2/mdq/1.0" prefix="mdq"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.fao.org/geonetwork" prefix="geonet"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema" prefix="xsi"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.ga.mdb.metadataidentifierpresent</xsl:attribute>
            <xsl:attribute name="name">Metadata identifier must be present.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.ga.mdb.metadataparentidentifierpresent</xsl:attribute>
            <xsl:attribute name="name">Metadata parent identifier must be present if metadataScope is one of ('feature','featureType','attribute','attributeType').</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.ga.mdb.dataseturipresent</xsl:attribute>
            <xsl:attribute name="name">Dataset URI must be present if metadataScope is one of ('dataset','').</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.ga.mdb.metadataprofilepresent</xsl:attribute>
            <xsl:attribute name="name">Metadata profile information must be present and correctly filled out.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.ga.mrl.resourcelineagepresent</xsl:attribute>
            <xsl:attribute name="name">Resource Lineage must be present and correctly filled out.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M30"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.ga.mco.securityconstraints</xsl:attribute>
            <xsl:attribute name="name">Constraint Information must be present and correctly filled out.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M32"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.ga.mri.identificationinformation</xsl:attribute>
            <xsl:attribute name="name">Identification Information must be present and correctly filled out.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M34"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.ga.gex.identificationinformation</xsl:attribute>
            <xsl:attribute name="name">Identification Information must have an extent if metadataScope is dataset.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M36"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Legal Constraints has required/mandatory descendent elements.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M38"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Security Constraints has required/mandatory descendent elements.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M40"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Resource Format has required/mandatory descendent elements.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M42"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Maintenance Information has required/mandatory descendent elements.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M44"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Distribution Information has required/mandatory descendent elements.</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M46"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Schematron validation for Version 2.0 of Geoscience Australia profile of ISO 19115-1:2014 standard</svrl:text>

   <!--PATTERN rule.ga.mdb.metadataidentifierpresentMetadata identifier must be present.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Metadata identifier must be present.</svrl:text>

	  <!--RULE -->
<xsl:template match="//mdb:metadataIdentifier[1]/mcc:MD_Identifier" priority="1000"
                 mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mdb:metadataIdentifier[1]/mcc:MD_Identifier"/>
      <xsl:variable name="mdid" select="mcc:code/gco:CharacterString"/>
      <xsl:variable name="hasMdid" select="normalize-space($mdid) != ''"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$hasMdid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasMdid">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mdb.metadataidentifierpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The metadata identifier is not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$hasMdid">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasMdid">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mdb.metadataidentifierpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The metadata identifier is present
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($mdid)"/>
               <xsl:text/>"
      .</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

   <!--PATTERN rule.ga.mdb.metadataparentidentifierpresentMetadata parent identifier must be present if metadataScope is one of ('feature','featureType','attribute','attributeType').-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Metadata parent identifier must be present if metadataScope is one of ('feature','featureType','attribute','attributeType').</svrl:text>

	  <!--RULE -->
<xsl:template match="/mdb:MD_Metadata" priority="1000" mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/mdb:MD_Metadata"/>
      <xsl:variable name="scopeCode"
                    select="mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue"/>
      <xsl:variable name="parentId"
                    select="mdb:parentMetadata/cit:CI_Citation/cit:identifier/mcc:MD_Identifier/mcc:code/gco:CharacterString"/>
      <xsl:variable name="hasParent"
                    select="normalize-space($parentId) and $scopeCode = ('feature','featureType','attribute','attributeType')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hasParent)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="not($hasParent)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mdb.metadataparentidentifierpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The metadata parent identifier must be present if metadataScope is one of ('feature','featureType','attribute','attributeType').</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="not($hasParent)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="not($hasParent)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mdb.metadataparentidentifierpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The metadata parent identifier is present "<xsl:text/>
               <xsl:copy-of select="normalize-space($parentId)"/>
               <xsl:text/>" and metadataScope "<xsl:text/>
               <xsl:copy-of select="normalize-space($scopeCode)"/>
               <xsl:text/>" is one of ('feature','featureType','attribute','attributeType').</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>

   <!--PATTERN rule.ga.mdb.dataseturipresentDataset URI must be present if metadataScope is one of ('dataset','').-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Dataset URI must be present if metadataScope is one of ('dataset','').</svrl:text>

	  <!--RULE -->
<xsl:template match="/mdb:MD_Metadata[mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue=('dataset', '')]"
                 priority="1000"
                 mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/mdb:MD_Metadata[mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue=('dataset', '')]"/>
      <xsl:variable name="scopeCode"
                    select="mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue"/>
      <xsl:variable name="dataseturi"
                    select="mdb:identificationInfo/*/mri:citation/*/cit:identifier/mcc:MD_Identifier[mcc:codeSpace/gco:CharacterString='ga-dataSetURI']/mcc:code/gco:CharacterString"/>
      <xsl:variable name="hasDataseturi"
                    select="normalize-space($dataseturi) and $scopeCode = ('dataset', '')"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$hasDataseturi"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasDataseturi">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mdb.dataseturipresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The dataSetURI identifier must be present if metadataScope is one of ('dataset','').</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$hasDataseturi">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasDataseturi">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mdb.dataseturipresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The dataSetURI identifier is present "<xsl:text/>
               <xsl:copy-of select="normalize-space($dataseturi)"/>
               <xsl:text/>" and metadataScope is "<xsl:text/>
               <xsl:copy-of select="normalize-space($scopeCode)"/>
               <xsl:text/>".</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>

   <!--PATTERN rule.ga.mdb.metadataprofilepresentMetadata profile information must be present and correctly filled out.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Metadata profile information must be present and correctly filled out.</svrl:text>

	  <!--RULE -->
<xsl:template match="//mdb:metadataProfile/cit:CI_Citation" priority="1000" mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mdb:metadataProfile/cit:CI_Citation"/>
      <xsl:variable name="title" select="cit:title/gco:CharacterString"/>
      <xsl:variable name="hasTitle"
                    select="normalize-space($title) = 'Geoscience Australia Community Metadata Profile of ISO 19115-1:2014'"/>
      <xsl:variable name="edition" select="cit:edition/gco:CharacterString"/>
      <xsl:variable name="hasEdition"
                    select="normalize-space($edition) = 'Version 2.0, April 2015'"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$hasTitle and $hasEdition"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasTitle and $hasEdition">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mdb.metadataprofilepresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The metadata profile information (mdb:metadataProfile) is not present or may be incorrect - looking for title: 'Geoscience Australia Community Metadata Profile of ISO 19115-1:2014' and edition/version: 'Version 2.0, April 2015'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$hasTitle and $hasEdition">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasTitle and $hasEdition">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mdb.metadataprofilepresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The metadata profile information is present: "<xsl:text/>
               <xsl:copy-of select="normalize-space($title)"/>
               <xsl:text/>" with "<xsl:text/>
               <xsl:copy-of select="normalize-space($edition)"/>
               <xsl:text/>".</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>

   <!--PATTERN rule.ga.mrl.resourcelineagepresentResource Lineage must be present and correctly filled out.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Resource Lineage must be present and correctly filled out.</svrl:text>

	  <!--RULE -->
<xsl:template match="//mdb:MD_Metadata" priority="1001" mode="M30">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//mdb:MD_Metadata"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mdb:resourceLineage/mrl:LI_Lineage"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mdb:resourceLineage/mrl:LI_Lineage">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mrl.resourcelineagepresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
Resource Lineage elements not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mdb:resourceLineage/mrl:LI_Lineage">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mdb:resourceLineage/mrl:LI_Lineage">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mrl.resourcelineagepresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Resource Lineage elements are present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//mdb:resourceLineage/mrl:LI_Lineage" priority="1000" mode="M30">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mdb:resourceLineage/mrl:LI_Lineage"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(mrl:statement)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="normalize-space(mrl:statement)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mrl.resourcelineagestatementpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
Resource Lineage statement not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(mrl:statement)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="normalize-space(mrl:statement)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mrl.resourcelineagestatementpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Resource Lineage statement is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="@*|node()" priority="-2" mode="M30">
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>

   <!--PATTERN rule.ga.mco.securityconstraintsConstraint Information must be present and correctly filled out.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Constraint Information must be present and correctly filled out.</svrl:text>

	  <!--RULE -->
<xsl:template match="//mdb:MD_Metadata" priority="1001" mode="M32">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//mdb:MD_Metadata"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mdb:metadataConstraints/*"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mdb:metadataConstraints/*">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mco.metadataconstraintspresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
Metadata Constraint elements not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mdb:metadataConstraints/*">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mdb:metadataConstraints/*">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mco.metadataconstraintspresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Metadata Constraint elements are present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mdb:metadataConstraints/mco:MD_SecurityConstraints"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mdb:metadataConstraints/mco:MD_SecurityConstraints">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mco.metadatasecurityconstraintspresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
Metadata Security Constraint elements not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mdb:metadataConstraints/mco:MD_SecurityConstraints">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mdb:metadataConstraints/mco:MD_SecurityConstraints">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mco.metadatasecurityconstraintspresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Metadata Security Constraint elements are present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//mco:MD_SecurityConstraints/mco:classification" priority="1000"
                 mode="M32">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mco:MD_SecurityConstraints/mco:classification"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(mco:MD_ClassificationCode/@codeList) and normalize-space(mco:MD_ClassificationCode/@codeListValue)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="normalize-space(mco:MD_ClassificationCode/@codeList) and normalize-space(mco:MD_ClassificationCode/@codeListValue)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mco.securityconstraintsclassificationpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
Classification code not present in Security Constraints.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(mco:MD_ClassificationCode/@codeList) and normalize-space(mco:MD_ClassificationCode/@codeListValue)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="normalize-space(mco:MD_ClassificationCode/@codeList) and normalize-space(mco:MD_ClassificationCode/@codeListValue)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mco.securityconstraintsclassificationpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Classification code is present in Security Constraints.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="@*|node()" priority="-2" mode="M32">
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>

   <!--PATTERN rule.ga.mri.identificationinformationIdentification Information must be present and correctly filled out.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Identification Information must be present and correctly filled out.</svrl:text>

	  <!--RULE -->
<xsl:template match="//mdb:MD_Metadata[descendant::mri:MD_DataIdentification]"
                 priority="1001"
                 mode="M34">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mdb:MD_Metadata[descendant::mri:MD_DataIdentification]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mdb:identificationInfo/mri:MD_DataIdentification"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mdb:identificationInfo/mri:MD_DataIdentification">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mri.identificationinformationpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
Data Identification Information element not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mdb:identificationInfo/mri:MD_DataIdentification">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mdb:identificationInfo/mri:MD_DataIdentification">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mri.identificationinformationpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Data Identification Information element is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//mri:MD_DataIdentification[parent::mdb:identificationInfo[parent::mdb:MD_Metadata]]"
                 priority="1000"
                 mode="M34">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mri:MD_DataIdentification[parent::mdb:identificationInfo[parent::mdb:MD_Metadata]]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(mri:pointOfContact[descendant::text()])&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count(mri:pointOfContact[descendant::text()])&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mri.pointofcontactpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/pointOfContact information not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="count(mri:pointOfContact[descendant::text()])&gt;0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count(mri:pointOfContact[descendant::text()])&gt;0">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mri.pointofcontactpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/pointOfContact information is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mri:resourceMaintenance/mmi:MD_MaintenanceInformation"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mri:resourceMaintenance/mmi:MD_MaintenanceInformation">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mri.maintenanceinformationpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceMaintenance/ MD_MaintenanceInformation not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mri:resourceMaintenance/mmi:MD_MaintenanceInformation">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mri:resourceMaintenance/mmi:MD_MaintenanceInformation">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mri.maintenanceinformationpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceMaintenance/ MD_MaintenanceInformation is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mri:resourceFormat/mrd:MD_Format"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mri:resourceFormat/mrd:MD_Format">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mri.resourceformatpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceFormat/ MD_Format not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mri:resourceFormat/mrd:MD_Format">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mri:resourceFormat/mrd:MD_Format">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mri.resourceformatpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceFormat/ MD_Format is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mri:resourceConstraints/*"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mri:resourceConstraints/*">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mri.resourceconstraintspresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceConstraints information not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mri:resourceConstraints/*">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mri:resourceConstraints/*">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mri.resourceconstraintspresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceConstraints information is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(mri:topicCategory)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="normalize-space(mri:topicCategory)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mri.topiccategorypresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ topicCategory not present or empty.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(mri:topicCategory)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="normalize-space(mri:topicCategory)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mri.topiccategorypresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ topicCategory is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mri:resourceConstraints/mco:MD_SecurityConstraints"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mri:resourceConstraints/mco:MD_SecurityConstraints">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mri.securityconstraintspresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceConstraints/ MD_SecurityConstraints not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mri:resourceConstraints/mco:MD_SecurityConstraints">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mri:resourceConstraints/mco:MD_SecurityConstraints">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mri.securityconstraintspresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceConstraints/ MD_SecurityConstraints is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mri:resourceConstraints/mco:MD_LegalConstraints"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mri:resourceConstraints/mco:MD_LegalConstraints">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mri.legalconstraintspresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceConstraints/ MD_LegalConstraints not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mri:resourceConstraints/mco:MD_LegalConstraints">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mri:resourceConstraints/mco:MD_LegalConstraints">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mri.legalconstraintspresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceConstraints/ MD_LegalConstraints is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M34"/>
   <xsl:template match="@*|node()" priority="-2" mode="M34">
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>

   <!--PATTERN rule.ga.gex.identificationinformationIdentification Information must have an extent if metadataScope is dataset.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Identification Information must have an extent if metadataScope is dataset.</svrl:text>

	  <!--RULE -->
<xsl:template match="//mdb:MD_Metadata[mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue=('dataset','')]"
                 priority="1000"
                 mode="M36">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mdb:MD_Metadata[mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue=('dataset','')]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(mdb:identificationInfo/*/mri:extent/gex:EX_Extent/*)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count(mdb:identificationInfo/*/mri:extent/gex:EX_Extent/*)&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.gex.extentinformationpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ extent information not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="count(mdb:identificationInfo/*/mri:extent/gex:EX_Extent/*)&gt;0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count(mdb:identificationInfo/*/mri:extent/gex:EX_Extent/*)&gt;0">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.gex.extentinformationpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ extent information is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M36"/>
   <xsl:template match="@*|node()" priority="-2" mode="M36">
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>

   <!--PATTERN Legal Constraints has required/mandatory descendent elements.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Legal Constraints has required/mandatory descendent elements.</svrl:text>

	  <!--RULE -->
<xsl:template match="//mri:MD_DataIdentification" priority="1002" mode="M38">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//mri:MD_DataIdentification"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mri:resourceConstraints/mco:MD_LegalConstraints/mco:accessConstraints"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mri:resourceConstraints/mco:MD_LegalConstraints/mco:accessConstraints">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mco.accessconstraintspresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceConstraints/ MD_LegalConstraints/ accessConstraints not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mri:resourceConstraints/mco:MD_LegalConstraints/mco:accessConstraints">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mri:resourceConstraints/mco:MD_LegalConstraints/mco:accessConstraints">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mco.accessconstraintspresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceConstraints/ MD_LegalConstraints/ accessConstraints is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mri:resourceConstraints/mco:MD_LegalConstraints/mco:useConstraints"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mri:resourceConstraints/mco:MD_LegalConstraints/mco:useConstraints">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mco.useconstraintspresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceConstraints/MD_LegalConstraints/useConstraints not present.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mri:resourceConstraints/mco:MD_LegalConstraints/mco:useConstraints">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mri:resourceConstraints/mco:MD_LegalConstraints/mco:useConstraints">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mco.useconstraintspresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_DataIdentification/ resourceConstraints/MD_LegalConstraints/useConstraints is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//mco:MD_LegalConstraints/mco:accessConstraints" priority="1001"
                 mode="M38">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mco:MD_LegalConstraints/mco:accessConstraints"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(mco:MD_RestrictionCode/@codeList) and normalize-space(mco:MD_RestrictionCode/@codeListValue)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="normalize-space(mco:MD_RestrictionCode/@codeList) and normalize-space(mco:MD_RestrictionCode/@codeListValue)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mco.accessconstraintscodepresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_LegalConstraints/ accessConstraints/ MD_RestrictionCode not present or missing code list values.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(mco:MD_RestrictionCode/@codeList) and normalize-space(mco:MD_RestrictionCode/@codeListValue)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="normalize-space(mco:MD_RestrictionCode/@codeList) and normalize-space(mco:MD_RestrictionCode/@codeListValue)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mco.accessconstraintscodepresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_LegalConstraints/ accessConstraints/ MD_RestrictionCode is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//mco:MD_LegalConstraints/mco:useConstraints" priority="1000" mode="M38">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mco:MD_LegalConstraints/mco:useConstraints"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(mco:MD_RestrictionCode/@codeList) and normalize-space(mco:MD_RestrictionCode/@codeListValue)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="normalize-space(mco:MD_RestrictionCode/@codeList) and normalize-space(mco:MD_RestrictionCode/@codeListValue)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mco.useconstraintscodepresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_LegalConstraints/ useConstraints/ MD_RestrictionCode not present or missing code list values.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(mco:MD_RestrictionCode/@codeList) and normalize-space(mco:MD_RestrictionCode/@codeListValue)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="normalize-space(mco:MD_RestrictionCode/@codeList) and normalize-space(mco:MD_RestrictionCode/@codeListValue)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mco.useconstraintscodepresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_LegalConstraints/ useConstraints/ MD_RestrictionCode is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M38"/>
   <xsl:template match="@*|node()" priority="-2" mode="M38">
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>

   <!--PATTERN Security Constraints has required/mandatory descendent elements.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Security Constraints has required/mandatory descendent elements.</svrl:text>

	  <!--RULE -->
<xsl:template match="//mco:MD_SecurityConstraints/mco:classification" priority="1000"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mco:MD_SecurityConstraints/mco:classification"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(mco:MD_ClassificationCode/@codeList) and normalize-space(mco:MD_ClassificationCode/@codeListValue)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="normalize-space(mco:MD_ClassificationCode/@codeList) and normalize-space(mco:MD_ClassificationCode/@codeListValue)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mco.securityconstraintspresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_ClassificationCode not present or missing code list values.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(mco:MD_ClassificationCode/@codeList) and normalize-space(mco:MD_ClassificationCode/@codeListValue)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="normalize-space(mco:MD_ClassificationCode/@codeList) and normalize-space(mco:MD_ClassificationCode/@codeListValue)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mco.securityconstraintspresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
MD_ClassificationCode is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M40"/>
   <xsl:template match="@*|node()" priority="-2" mode="M40">
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>

   <!--PATTERN Resource Format has required/mandatory descendent elements.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Resource Format has required/mandatory descendent elements.</svrl:text>

	  <!--RULE -->
<xsl:template match="//mrd:MD_Format[parent::mri:resourceFormat]" priority="1000" mode="M42">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mrd:MD_Format[parent::mri:resourceFormat]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mrd.resourceformatnamepresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
resourceFormat/ MD_Format/ formatSpecificationCitation/ */ title (format name) not present or empty.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mrd.resourceformatnamepresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
resourceFormat/ MD_Format/ formatSpecificationCitation/ */ title (format name) is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:edition/gco:CharacterString)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:edition/gco:CharacterString)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mrd.resourceformatversionpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
resourceFormat/ MD_Format/ formatSpecificationCitation/ */ edition (format version) not present or empty.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:edition/gco:CharacterString)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:edition/gco:CharacterString)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mrd.resourceformatversionpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
resourceFormat/ MD_Format/ formatSpecificationCitation/ */ edition (format version) is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M42"/>
   <xsl:template match="@*|node()" priority="-2" mode="M42">
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>

   <!--PATTERN Maintenance Information has required/mandatory descendent elements.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Maintenance Information has required/mandatory descendent elements.</svrl:text>

	  <!--RULE -->
<xsl:template match="//mmi:maintenanceAndUpdateFrequency[ancestor::mri:resourceMaintenance]"
                 priority="1000"
                 mode="M44">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mmi:maintenanceAndUpdateFrequency[ancestor::mri:resourceMaintenance]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(mmi:MD_MaintenanceFrequencyCode/@codeList) and normalize-space(mmi:MD_MaintenanceFrequencyCode/@codeListValue)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="normalize-space(mmi:MD_MaintenanceFrequencyCode/@codeList) and normalize-space(mmi:MD_MaintenanceFrequencyCode/@codeListValue)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mmi.resourcemaintenancecodelistpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
resourceMaintenance/ maintenanceAndUpdateFrequency/ MD_MaintenanceFrequencyCode not present or missing code list values.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(mmi:MD_MaintenanceFrequencyCode/@codeList) and normalize-space(mmi:MD_MaintenanceFrequencyCode/@codeListValue)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="normalize-space(mmi:MD_MaintenanceFrequencyCode/@codeList) and normalize-space(mmi:MD_MaintenanceFrequencyCode/@codeListValue)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mmi.resourcemaintenancecodelistpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
resourceMaintenance/ maintenanceAndUpdateFrequency/ MD_MaintenanceFrequencyCode is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M44"/>
   <xsl:template match="@*|node()" priority="-2" mode="M44">
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>

   <!--PATTERN Distribution Information has required/mandatory descendent elements.-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Distribution Information has required/mandatory descendent elements.</svrl:text>

	  <!--RULE -->
<xsl:template match="//mrd:MD_Distribution[parent::mdb:distributionInfo]" priority="1001"
                 mode="M46">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mrd:MD_Distribution[parent::mdb:distributionInfo]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="mrd:distributionFormat/mrd:MD_Format"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="mrd:distributionFormat/mrd:MD_Format">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="mrd:distributionFormat/mrd:MD_Format">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="mrd:distributionFormat/mrd:MD_Format">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//mrd:MD_Format[parent::mrd:distributionFormat]" priority="1000"
                 mode="M46">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mrd:MD_Format[parent::mrd:distributionFormat]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mrd.distributionformatnamepresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
distributionFormat/ MD_Format/ formatSpecificationCitation/ */ title (format name) not present or empty.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:title/gco:CharacterString)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mrd.distributionformatnamepresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
distributionFormat/ MD_Format/ formatSpecificationCitation/ */ title (format name) is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:edition/gco:CharacterString)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:edition/gco:CharacterString)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.ga.mrd.distributionformatversionpresent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
distributionFormat/ MD_Format/ formatSpecificationCitation/ */ edition (format version) not present or empty.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:edition/gco:CharacterString)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="normalize-space(mrd:formatSpecificationCitation/cit:CI_Citation/cit:edition/gco:CharacterString)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.ga.mrd.distributionformatversionpresent-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
distributionFormat/ MD_Format/ formatSpecificationCitation/ */ edition (format version) is present.</svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M46"/>
   <xsl:template match="@*|node()" priority="-2" mode="M46">
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
</xsl:stylesheet>