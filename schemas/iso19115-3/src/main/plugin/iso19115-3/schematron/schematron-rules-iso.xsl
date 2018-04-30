<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/1.0"
                xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
                xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/1.0"
                xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
                xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
                xmlns:gmw="http://standards.iso.org/iso/19115/-3/gmw/1.0"
                xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
                xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is
      the preferred method for meta-stylesheets to use where possible.
    -->
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
                 select="document(concat('../loc/', $lang, '/', $rule, '.xml'))"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators
    -->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators
    -->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
            <xsl:variable name="p_1"
                          select="1+       count(preceding-sibling::*[name()=name(current())])"/>
            <xsl:if test="$p_1&gt;1 or following-sibling::*[name()=name(current())]">[<xsl:value-of select="$p_1"/>]</xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>']</xsl:text>
            <xsl:variable name="p_2"
                          select="1+     count(preceding-sibling::*[local-name()=local-name(current())])"/>
            <xsl:if test="$p_2&gt;1 or following-sibling::*[local-name()=local-name(current())]">[<xsl:value-of select="$p_2"/>]</xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@
              <xsl:value-of select="name()"/>
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
         <xsl:text/>/@
        <xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans
      (Top-level element has index)
    -->
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
         <xsl:text/>/@
        <xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH-->
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

   <!--MODE: GENERATE-ID-2-->
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
                              title="Schematron&#xA;    validation for ISO 19115-1:2014 standard&#xA;  "
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
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/gmw/1.0" prefix="gmw"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mrc/1.0" prefix="mrc"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mrd/1.0" prefix="mrd"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mri/1.0" prefix="mri"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mrs/1.0" prefix="mrs"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/mcc/1.0" prefix="mcc"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/lan/1.0" prefix="lan"/>
         <svrl:ns-prefix-in-attribute-values uri="http://standards.iso.org/iso/19115/-3/gco/1.0" prefix="gco"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.fao.org/geonetwork" prefix="geonet"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema" prefix="xsi"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.cit.individualnameandposition</xsl:attribute>
            <xsl:attribute name="name_en">Individual MUST have a name or a position
    </xsl:attribute>
            <xsl:attribute name="name">Individual MUST have a name or a position
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.cit.organisationnameandlogo</xsl:attribute>
            <xsl:attribute name="name_en">Organisation MUST have a name or a logo</xsl:attribute>
            <xsl:attribute name="name">Organisation MUST have a name or a logo</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.gex.extenthasoneelement</xsl:attribute>
            <xsl:attribute name="name_en">Extent MUST have one description or one geographic,
      temporal or vertical element
    </xsl:attribute>
            <xsl:attribute name="name">Extent MUST have one description or one geographic,
      temporal or vertical element
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.gex.verticalhascrsorcrsid</xsl:attribute>
            <xsl:attribute name="name_en">Vertical element MUST contains a CRS or CRS
      identifier
    </xsl:attribute>
            <xsl:attribute name="name">Vertical element MUST contains a CRS or CRS
      identifier
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mco-releasability</xsl:attribute>
            <xsl:attribute name="name_en">Releasability MUST
      specified an addresse or a statement
    </xsl:attribute>
            <xsl:attribute name="name">Releasability MUST
      specified an addresse or a statement
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mco-legalconstraintdetails</xsl:attribute>
            <xsl:attribute name="name_en">Legal constraint MUST
      specified an access, use or other constraint or
      use limitation or releasability
    </xsl:attribute>
            <xsl:attribute name="name">Legal constraint MUST
      specified an access, use or other constraint or
      use limitation or releasability
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M31"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mco-legalconstraint-other</xsl:attribute>
            <xsl:attribute name="name_en">Legal constraint defining
      other restrictions for access or use constraint MUST
      specified other constraint.
    </xsl:attribute>
            <xsl:attribute name="name">Legal constraint defining
      other restrictions for access or use constraint MUST
      specified other constraint.
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M33"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mdb.root-element</xsl:attribute>
            <xsl:attribute name="name_en">Metadata document root element</xsl:attribute>
            <xsl:attribute name="name">Metadata document root element</xsl:attribute>
            <svrl:text>A metadata instance document conforming to
      this specification SHALL have a root MD_Metadata element
      defined in the http://standards.iso.org/iso/19115/-3/mdb/1.0 namespace.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M35"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mdb.defaultlocale</xsl:attribute>
            <xsl:attribute name="name_en">Default locale</xsl:attribute>
            <xsl:attribute name="name">Default locale</xsl:attribute>
            <svrl:text>The default locale MUST be documented if
      not defined by the encoding. The default value for the character
      encoding is "UTF-8".
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M37"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mdb.scope-name</xsl:attribute>
            <xsl:attribute name="name_en">Metadata scope Name</xsl:attribute>
            <xsl:attribute name="name">Metadata scope Name</xsl:attribute>
            <svrl:text>If a MD_MetadataScope element is present,
      the name property MUST have a value if resourceScope is not equal to
      "dataset"
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M39"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mdb.create-date</xsl:attribute>
            <xsl:attribute name="name_en">Metadata create date</xsl:attribute>
            <xsl:attribute name="name">Metadata create date</xsl:attribute>
            <svrl:text>A dateInfo property value with data type = "creation"
      MUST be present in every MD_Metadata instance.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M41"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mex.datatypedetails</xsl:attribute>
            <xsl:attribute name="name_en">Extended element information
      which are not codelist, enumeration or codelistElement
      MUST specified max occurence and domain value
    </xsl:attribute>
            <xsl:attribute name="name">Extended element information
      which are not codelist, enumeration or codelistElement
      MUST specified max occurence and domain value
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M43"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mex.conditional</xsl:attribute>
            <xsl:attribute name="name_en">Extended element information
      which are conditional MUST explained the condition
    </xsl:attribute>
            <xsl:attribute name="name">Extended element information
      which are conditional MUST explained the condition
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M45"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mex.mandatorycode</xsl:attribute>
            <xsl:attribute name="name_en">Extended element information
      which are codelist, enumeration or codelistElement
      MUST specified a code and a concept name
    </xsl:attribute>
            <xsl:attribute name="name">Extended element information
      which are codelist, enumeration or codelistElement
      MUST specified a code and a concept name
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M47"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mmi-updatefrequency</xsl:attribute>
            <xsl:attribute name="name_en">Maintenance information MUST
      specified an update frequency
    </xsl:attribute>
            <xsl:attribute name="name">Maintenance information MUST
      specified an update frequency
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M49"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mrc.sampledimension</xsl:attribute>
            <xsl:attribute name="name_en">Sample dimension MUST provide a max,
      a min or a mean value
    </xsl:attribute>
            <xsl:attribute name="name">Sample dimension MUST provide a max,
      a min or a mean value
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M51"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mrc.bandunit</xsl:attribute>
            <xsl:attribute name="name_en">Band MUST specified bounds units
      when a bound max or bound min is defined
    </xsl:attribute>
            <xsl:attribute name="name">Band MUST specified bounds units
      when a bound max or bound min is defined
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M53"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mrd.mediumunit</xsl:attribute>
            <xsl:attribute name="name_en">Medium having density MUST specified density
      units
    </xsl:attribute>
            <xsl:attribute name="name">Medium having density MUST specified density
      units
    </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M55"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mri.datasetextent</xsl:attribute>
            <xsl:attribute name="name_en">Dataset extent</xsl:attribute>
            <xsl:attribute name="name">Dataset extent</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M57"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mri.topicategoryfordsandseries</xsl:attribute>
            <xsl:attribute name="name_en">Topic category for dataset and series</xsl:attribute>
            <xsl:attribute name="name">Topic category for dataset and series</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M59"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mri.associatedresource</xsl:attribute>
            <xsl:attribute name="name_en">Associated resource name</xsl:attribute>
            <xsl:attribute name="name">Associated resource name</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M61"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.mri.defaultlocalewhenhastext</xsl:attribute>
            <xsl:attribute name="name_en">Resource language</xsl:attribute>
            <xsl:attribute name="name">Resource language</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M63"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">rule.srv.servicetaxonomy</xsl:attribute>
            <xsl:attribute name="name_en">Service taxonomy</xsl:attribute>
            <xsl:attribute name="name">Service taxonomy</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M65"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Schematron
    validation for ISO 19115-1:2014 standard
  </svrl:text>

   <!--PATTERN
        rule.cit.individualnameandpositionIndividual MUST have a name or a position
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Individual MUST have a name or a position
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//cit:CI_Individual" priority="1000" mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//cit:CI_Individual"/>
      <xsl:variable name="name" select="cit:name"/>
      <xsl:variable name="position" select="cit:positionName"/>
      <xsl:variable name="hasName" select="normalize-space($name) != ''"/>
      <xsl:variable name="hasPosition" select="normalize-space($position) != ''"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasName or $hasPosition"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasName or $hasPosition">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.cit.individualnameandposition-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The individual does not have a name or a
      position.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasName or $hasPosition">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasName or $hasPosition">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.cit.individualnameandposition-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Individual name is
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($name)"/>
               <xsl:text/>"
      and position
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($position)"/>
               <xsl:text/>"
      .
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>

   <!--PATTERN
        rule.cit.organisationnameandlogoOrganisation MUST have a name or a logo-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Organisation MUST have a name or a logo</svrl:text>

  <!--RULE
      -->
<xsl:template match="//cit:CI_Organisation" priority="1000" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//cit:CI_Organisation"/>
      <xsl:variable name="name" select="cit:name"/>
      <xsl:variable name="logo" select="cit:logo/mcc:MD_BrowseGraphic/mcc:fileName"/>
      <xsl:variable name="hasName" select="normalize-space($name) != ''"/>
      <xsl:variable name="hasLogo" select="normalize-space($logo) != ''"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasName or $hasLogo"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasName or $hasLogo">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.cit.organisationnameandlogo-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The organisation does not have a name or a
      logo.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasName or $hasLogo">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasName or $hasLogo">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.cit.organisationnameandlogo-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Organisation name is
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($name)"/>
               <xsl:text/>"
      and logo filename is
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($logo)"/>
               <xsl:text/>"
      .
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

   <!--PATTERN
        rule.gex.extenthasoneelementExtent MUST have one description or one geographic,
      temporal or vertical element
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Extent MUST have one description or one geographic,
      temporal or vertical element
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gex:EX_Extent[/mdb:MD_Metadata/mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue=('dataset', '')]"
                 priority="1000"
                 mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gex:EX_Extent[/mdb:MD_Metadata/mdb:metadataScope/mdb:MD_MetadataScope/mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue=('dataset', '')]"/>
      <xsl:variable name="description" select="gex:description/*[normalize-space() != '']"/>
      <xsl:variable name="geographicId"
                    select="gex:geographicElement/gex:EX_GeographicDescription/                          gex:geographicIdentifier[normalize-space(*) != '']"/>
      <xsl:variable name="geographicBox"
                    select="gex:geographicElement/                          gex:EX_GeographicBoundingBox[                          normalize-space(gex:westBoundLongitude/gco:Decimal) != '' and                          normalize-space(gex:eastBoundLongitude/gco:Decimal) != '' and                          normalize-space(gex:southBoundLatitude/gco:Decimal) != '' and                          normalize-space(gex:northBoundLatitude/gco:Decimal) != ''                          ]"/>
      <xsl:variable name="geographicPoly"
                    select="gex:geographicElement/gex:EX_BoundingPolygon[                          normalize-space(gex:polygon) != '']"/>
      <xsl:variable name="temporal"
                    select="gex:temporalElement/gex:EX_TemporalExtent[                          normalize-space(gex:extent) != '']"/>
      <xsl:variable name="vertical"
                    select="gex:verticalElement/gex:EX_VerticalExtent[                          normalize-space(gex:minimumValue) != '' and                          normalize-space(gex:maximumValue) != '']"/>
      <xsl:variable name="hasAtLeastOneElement"
                    select="count($description) +         count($geographicId) +         count($geographicBox) +         count($geographicPoly) +         count($temporal) +         count($vertical) &gt; 0         "/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasAtLeastOneElement"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasAtLeastOneElement">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.gex.extenthasoneelement-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

      The extent does not contain a description or a geographicElement.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="count($description)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($description)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.gex.extenthasoneelement-desc-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The extent contains a description.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>

      <!--REPORT
      -->
<xsl:if test="count($geographicId)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($geographicId)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.gex.extenthasoneelement-id-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The extent contains a geographic identifier.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>

      <!--REPORT
      -->
<xsl:if test="count($geographicBox)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($geographicBox)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.gex.extenthasoneelement-box-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The extent contains a bounding box element.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>

      <!--REPORT
      -->
<xsl:if test="count($geographicPoly)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($geographicPoly)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.gex.extenthasoneelement-poly-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The extent contains a bounding polygon.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>

      <!--REPORT
      -->
<xsl:if test="count($temporal)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($temporal)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.gex.extenthasoneelement-temporal-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The extent contains a temporal element.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>

      <!--REPORT
      -->
<xsl:if test="count($vertical)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($vertical)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.gex.extenthasoneelement-vertical-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The extent contains a vertical element.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>

   <!--PATTERN
        rule.gex.verticalhascrsorcrsidVertical element MUST contains a CRS or CRS
      identifier
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Vertical element MUST contains a CRS or CRS
      identifier
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gex:EX_VerticalExtent" priority="1000" mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gex:EX_VerticalExtent"/>
      <xsl:variable name="crs" select="gex:verticalCRS"/>
      <xsl:variable name="crsId" select="gex:verticalCRSId"/>
      <xsl:variable name="hasCrsOrCrsId" select="count($crs) + count($crsId) &gt; 0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasCrsOrCrsId"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasCrsOrCrsId">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.gex.verticalhascrsorcrsid-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The vertical extent does not contains CRS or
      CRS identifier.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasCrsOrCrsId">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasCrsOrCrsId">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.gex.verticalhascrsorcrsid-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The vertical extent contains CRS information.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>

   <!--PATTERN
        rule.mco-releasabilityReleasability MUST
      specified an addresse or a statement
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Releasability MUST
      specified an addresse or a statement
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//mco:MD_Releasability" priority="1000" mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//mco:MD_Releasability"/>
      <xsl:variable name="addressee" select="mco:addressee[normalize-space(.) != '']"/>
      <xsl:variable name="statement" select="mco:statement/*[normalize-space(.) != '']"/>
      <xsl:variable name="hasAddresseeOrStatement"
                    select="count($addressee) +                 count($statement) &gt; 0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasAddresseeOrStatement"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasAddresseeOrStatement">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mco-releasability-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

      The releasabilty does not define addresse or statement.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="count($addressee)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($addressee)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mco-releasability-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The releasability addressee is defined:
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($addressee)"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>

      <!--REPORT
      -->
<xsl:if test="count($statement)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($statement)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mco-releasability-statement-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The releasability statement is
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($statement)"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>

   <!--PATTERN
        rule.mco-legalconstraintdetailsLegal constraint MUST
      specified an access, use or other constraint or
      use limitation or releasability
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Legal constraint MUST
      specified an access, use or other constraint or
      use limitation or releasability
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//mco:MD_LegalConstraints" priority="1000" mode="M31">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//mco:MD_LegalConstraints"/>
      <xsl:variable name="accessConstraints"
                    select="mco:accessConstraints[                 normalize-space(.) != '' or                 count(.//@codeListValue[. != '']) &gt; 0]"/>
      <xsl:variable name="useConstraints"
                    select="mco:useConstraints/*[                  normalize-space(.) != '' or                  count(.//@codeListValue[. != '']) &gt; 0]"/>
      <xsl:variable name="otherConstraints"
                    select="mco:otherConstraints/*[                  normalize-space(.) != '']"/>
      <xsl:variable name="useLimitation"
                    select="mco:useLimitation/*[                  normalize-space(.) != '' or                  count(.//@codeListValue[. != '']) &gt; 0]"/>
      <xsl:variable name="releasability"
                    select="mco:releasability/*[                  normalize-space(.) != '' or                  count(.//@codeListValue[. != '']) &gt; 0]"/>
      <xsl:variable name="hasDetails"
                    select="count($accessConstraints) +                        count($useConstraints) +                        count($otherConstraints) +                        count($useLimitation) +                        count($releasability)                       &gt; 0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasDetails"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasDetails">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.mco-legalconstraintdetails-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

      The legal constraint is incomplete.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasDetails">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasDetails">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mco-legalconstraintdetails-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The legal constraint is complete.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="@*|node()" priority="-2" mode="M31">
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>

   <!--PATTERN
        rule.mco-legalconstraint-otherLegal constraint defining
      other restrictions for access or use constraint MUST
      specified other constraint.
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Legal constraint defining
      other restrictions for access or use constraint MUST
      specified other constraint.
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//mco:MD_LegalConstraints[       mco:accessConstraints/mco:MD_RestrictionCode/@codeListValue = 'otherRestrictions' or       mco:useConstraints/mco:MD_RestrictionCode/@codeListValue = 'otherRestrictions'       ]"
                 priority="1000"
                 mode="M33">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mco:MD_LegalConstraints[       mco:accessConstraints/mco:MD_RestrictionCode/@codeListValue = 'otherRestrictions' or       mco:useConstraints/mco:MD_RestrictionCode/@codeListValue = 'otherRestrictions'       ]"/>
      <xsl:variable name="otherConstraints"
                    select="mco:otherConstraints/*[normalize-space(.) != '']"/>
      <xsl:variable name="hasOtherConstraints" select="count($otherConstraints) &gt; 0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasOtherConstraints"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasOtherConstraints">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.mco-legalconstraint-other-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

      The legal constraint does not specified other constraints
      while access and use constraint is set to other restriction.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasOtherConstraints">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasOtherConstraints">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mco-legalconstraint-other-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The legal constraint other constraints is
      "<xsl:text/>
               <xsl:copy-of select="$otherConstraints"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M33"/>
   <xsl:template match="@*|node()" priority="-2" mode="M33">
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>

   <!--PATTERN
        rule.mdb.root-elementMetadata document root element-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Metadata document root element</svrl:text>

  <!--RULE
      -->
<xsl:template match="/" priority="1000" mode="M35">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/"/>
      <xsl:variable name="hasOneMD_MetadataElement" select="count(/mdb:MD_Metadata) = 1"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasOneMD_MetadataElement"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasOneMD_MetadataElement">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mdb.root-element-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The root
      element must be MD_Metadata.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasOneMD_MetadataElement">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasOneMD_MetadataElement">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mdb.root-element-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Root
      element MD_Metadata found.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M35"/>
   <xsl:template match="@*|node()" priority="-2" mode="M35">
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>

   <!--PATTERN
        rule.mdb.defaultlocaleDefault locale-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Default locale</svrl:text>

  <!--RULE
      -->
<xsl:template match="/mdb:MD_Metadata/mdb:defaultLocale|                        /mdb:MD_Metadata/mdb:identificationInfo/*/mri:defaultLocale"
                 priority="1000"
                 mode="M37">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/mdb:MD_Metadata/mdb:defaultLocale|                        /mdb:MD_Metadata/mdb:identificationInfo/*/mri:defaultLocale"/>
      <xsl:variable name="encoding"
                    select="string(lan:PT_Locale/lan:characterEncoding/                   lan:MD_CharacterSetCode/@codeListValue)"/>
      <xsl:variable name="hasEncoding" select="normalize-space($encoding) != ''"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasEncoding"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasEncoding">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mdb.defaultlocale-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The
      default locale character encoding is "UTF-8". Current value is
      "<xsl:text/>
                  <xsl:copy-of select="$encoding"/>
                  <xsl:text/>".
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasEncoding">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasEncoding">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mdb.defaultlocale-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The
      characeter encoding is "<xsl:text/>
               <xsl:copy-of select="$encoding"/>
               <xsl:text/>.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M37"/>
   <xsl:template match="@*|node()" priority="-2" mode="M37">
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>

   <!--PATTERN
        rule.mdb.scope-nameMetadata scope Name-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Metadata scope Name</svrl:text>

  <!--RULE
      -->
<xsl:template match="/mdb:MD_Metadata/mdb:metadataScope/                           mdb:MD_MetadataScope[not(mdb:resourceScope/                             mcc:MD_ScopeCode/@codeListValue = 'dataset')]"
                 priority="1000"
                 mode="M39">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/mdb:MD_Metadata/mdb:metadataScope/                           mdb:MD_MetadataScope[not(mdb:resourceScope/                             mcc:MD_ScopeCode/@codeListValue = 'dataset')]"/>
      <xsl:variable name="scopeCode"
                    select="string(mdb:resourceScope/mcc:MD_ScopeCode/@codeListValue)"/>
      <xsl:variable name="scopeCodeName" select="normalize-space(mdb:name)"/>
      <xsl:variable name="hasScopeCodeName" select="normalize-space($scopeCodeName) != ''"/>
      <xsl:variable name="nilReason" select="string(mdb:name/@gco:nilReason)"/>
      <xsl:variable name="hasNilReason" select="$nilReason != ''"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasScopeCodeName or $hasNilReason"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasScopeCodeName or $hasNilReason">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mdb.scope-name-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
Specify a
      name for the metadata scope
      (required if the scope code is not "dataset", in that case
      "<xsl:text/>
                  <xsl:copy-of select="$scopeCode"/>
                  <xsl:text/>").
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasScopeCodeName or $hasNilReason">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasScopeCodeName or $hasNilReason">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mdb.scope-name-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Scope name
      "
      <xsl:text/>
               <xsl:copy-of select="$scopeCodeName"/>
               <xsl:text/>
               <xsl:text/>
               <xsl:copy-of select="$nilReason"/>
               <xsl:text/>"
      is defined for resource with type "<xsl:text/>
               <xsl:copy-of select="$scopeCode"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M39"/>
   <xsl:template match="@*|node()" priority="-2" mode="M39">
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>

   <!--PATTERN
        rule.mdb.create-dateMetadata create date-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Metadata create date</svrl:text>

  <!--RULE
      -->
<xsl:template match="mdb:MD_Metadata" priority="1000" mode="M41">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="mdb:MD_Metadata"/>
      <xsl:variable name="creationDates"
                    select="./mdb:dateInfo/cit:CI_Date[                     normalize-space(cit:date/gco:DateTime) != '' and                      cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']/                   cit:date/gco:DateTime"/>
      <xsl:variable name="hasAtLeastOneCreationDate"
                    select="count(./mdb:dateInfo/cit:CI_Date[                     normalize-space(cit:date/gco:DateTime) != '' and                      cit:dateType/cit:CI_DateTypeCode/@codeListValue = 'creation']                     ) &gt; 0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasAtLeastOneCreationDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasAtLeastOneCreationDate">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mdb.create-date-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
Specify a
      creation date for the metadata record
      in the metadata section.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasAtLeastOneCreationDate">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasAtLeastOneCreationDate">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mdb.create-date-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      Metadata creation date:<xsl:text/>
               <xsl:copy-of select="$creationDates"/>
               <xsl:text/>.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M41"/>
   <xsl:template match="@*|node()" priority="-2" mode="M41">
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>

   <!--PATTERN
        rule.mex.datatypedetailsExtended element information
      which are not codelist, enumeration or codelistElement
      MUST specified max occurence and domain value
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Extended element information
      which are not codelist, enumeration or codelistElement
      MUST specified max occurence and domain value
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//mex:MD_ExtendedElementInformation[       mex:dataType/mex:MD_DatatypeCode/@codeListValue != 'codelist' and       mex:dataType/mex:MD_DatatypeCode/@codeListValue != 'enumeration' and       mex:dataType/mex:MD_DatatypeCode/@codeListValue != 'codelistElement'       ]"
                 priority="1000"
                 mode="M43">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mex:MD_ExtendedElementInformation[       mex:dataType/mex:MD_DatatypeCode/@codeListValue != 'codelist' and       mex:dataType/mex:MD_DatatypeCode/@codeListValue != 'enumeration' and       mex:dataType/mex:MD_DatatypeCode/@codeListValue != 'codelistElement'       ]"/>
      <xsl:variable name="name" select="normalize-space(mex:name/*)"/>
      <xsl:variable name="dataType"
                    select="normalize-space(mex:dataType/mex:MD_DatatypeCode/@codeListValue)"/>
      <xsl:variable name="maximumOccurrence" select="normalize-space(mex:maximumOccurrence/*)"/>
      <xsl:variable name="hasMaximumOccurrence" select="$maximumOccurrence != ''"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasMaximumOccurrence"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasMaximumOccurrence">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.mex.datatypedetails-maxocc-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

      Extended element information "<xsl:text/>
                  <xsl:copy-of select="$name"/>
                  <xsl:text/>"
      of type "<xsl:text/>
                  <xsl:copy-of select="$dataType"/>
                  <xsl:text/>"
      does not specified max occurence.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasMaximumOccurrence">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasMaximumOccurrence">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mex.datatypedetails-maxocc-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      Extended element information "<xsl:text/>
               <xsl:copy-of select="$name"/>
               <xsl:text/>"
      of type "<xsl:text/>
               <xsl:copy-of select="$dataType"/>
               <xsl:text/>"
      has max occurence: "<xsl:text/>
               <xsl:copy-of select="$maximumOccurrence"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:variable name="domainValue" select="normalize-space(mex:domainValue/*)"/>
      <xsl:variable name="hasDomainValue" select="$domainValue != ''"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasDomainValue"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasDomainValue">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.mex.datatypedetails-domain-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

      Extended element information "<xsl:text/>
                  <xsl:copy-of select="$name"/>
                  <xsl:text/>"
      of type "<xsl:text/>
                  <xsl:copy-of select="$dataType"/>
                  <xsl:text/>"
      does not specified domain value.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasDomainValue">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasDomainValue">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mex.datatypedetails-domain-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      Extended element information "<xsl:text/>
               <xsl:copy-of select="$name"/>
               <xsl:text/>"
      of type "<xsl:text/>
               <xsl:copy-of select="$dataType"/>
               <xsl:text/>"
      has domain value: "<xsl:text/>
               <xsl:copy-of select="$domainValue"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M43"/>
   <xsl:template match="@*|node()" priority="-2" mode="M43">
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>

   <!--PATTERN
        rule.mex.conditionalExtended element information
      which are conditional MUST explained the condition
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Extended element information
      which are conditional MUST explained the condition
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//mex:MD_ExtendedElementInformation[       mex:obligation/mex:MD_ObligationCode = 'conditional'       ]"
                 priority="1000"
                 mode="M45">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mex:MD_ExtendedElementInformation[       mex:obligation/mex:MD_ObligationCode = 'conditional'       ]"/>
      <xsl:variable name="name" select="normalize-space(mex:name/*)"/>
      <xsl:variable name="condition" select="normalize-space(mex:condition/*)"/>
      <xsl:variable name="hasCondition" select="$condition != ''"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasCondition"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasCondition">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mex.conditional-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

      The conditional extended element "<xsl:text/>
                  <xsl:copy-of select="$name"/>
                  <xsl:text/>"
      does not specified the condition.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasCondition">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasCondition">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mex.conditional-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The conditional extended element "<xsl:text/>
               <xsl:copy-of select="$name"/>
               <xsl:text/>"
      has for condition: "<xsl:text/>
               <xsl:copy-of select="$condition"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M45"/>
   <xsl:template match="@*|node()" priority="-2" mode="M45">
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>

   <!--PATTERN
        rule.mex.mandatorycodeExtended element information
      which are codelist, enumeration or codelistElement
      MUST specified a code and a concept name
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Extended element information
      which are codelist, enumeration or codelistElement
      MUST specified a code and a concept name
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//mex:MD_ExtendedElementInformation[       mex:dataType/mex:MD_DatatypeCode/@codeListValue = 'codelist' or       mex:dataType/mex:MD_DatatypeCode/@codeListValue = 'enumeration' or       mex:dataType/mex:MD_DatatypeCode/@codeListValue = 'codelistElement'       ]"
                 priority="1000"
                 mode="M47">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mex:MD_ExtendedElementInformation[       mex:dataType/mex:MD_DatatypeCode/@codeListValue = 'codelist' or       mex:dataType/mex:MD_DatatypeCode/@codeListValue = 'enumeration' or       mex:dataType/mex:MD_DatatypeCode/@codeListValue = 'codelistElement'       ]"/>
      <xsl:variable name="name" select="normalize-space(mex:name/*)"/>
      <xsl:variable name="dataType"
                    select="normalize-space(mex:dataType/mex:MD_DatatypeCode/@codeListValue)"/>
      <xsl:variable name="code" select="normalize-space(mex:code/*)"/>
      <xsl:variable name="hasCode" select="$code != ''"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasCode"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasCode">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mex.mandatorycode-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

      The extended element "<xsl:text/>
                  <xsl:copy-of select="$name"/>
                  <xsl:text/>"
      of type "<xsl:text/>
                  <xsl:copy-of select="$dataType"/>
                  <xsl:text/>"
      does not specified a code.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasCode">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasCode">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mex.mandatorycode-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The extended element "<xsl:text/>
               <xsl:copy-of select="$name"/>
               <xsl:text/>"
      of type "<xsl:text/>
               <xsl:copy-of select="$dataType"/>
               <xsl:text/>"
      has for code: "<xsl:text/>
               <xsl:copy-of select="$code"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:variable name="conceptName" select="normalize-space(mex:conceptName/*)"/>
      <xsl:variable name="hasConceptName" select="$conceptName != ''"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasConceptName"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasConceptName">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.mex.mex.mandatoryconceptname-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

      The extended element "<xsl:text/>
                  <xsl:copy-of select="$name"/>
                  <xsl:text/>"
      of type "<xsl:text/>
                  <xsl:copy-of select="$dataType"/>
                  <xsl:text/>"
      does not specified a concept name.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasConceptName">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasConceptName">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mex.mex.mandatoryconceptname-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The extended element "<xsl:text/>
               <xsl:copy-of select="$name"/>
               <xsl:text/>"
      of type "<xsl:text/>
               <xsl:copy-of select="$dataType"/>
               <xsl:text/>"
      has for concept name: "<xsl:text/>
               <xsl:copy-of select="$conceptName"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M47"/>
   <xsl:template match="@*|node()" priority="-2" mode="M47">
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>

   <!--PATTERN
        rule.mmi-updatefrequencyMaintenance information MUST
      specified an update frequency
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Maintenance information MUST
      specified an update frequency
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//mmi:MD_MaintenanceInformation" priority="1000" mode="M49">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mmi:MD_MaintenanceInformation"/>
      <xsl:variable name="userDefinedMaintenanceFrequency"
                    select="mmi:userDefinedMaintenanceFrequency/                 gco:TM_PeriodDuration[normalize-space(.) != '']"/>
      <xsl:variable name="maintenanceAndUpdateFrequency"
                    select="mmi:maintenanceAndUpdateFrequency/                 mmi:MD_MaintenanceFrequencyCode/@codeListValue[normalize-space(.) != '']"/>
      <xsl:variable name="maintenanceAndUpdateFrequencyStr"
                    select="string($maintenanceAndUpdateFrequency)"/>
      <xsl:variable name="hasCodeOrUserFreq"
                    select="count($maintenanceAndUpdateFrequency) +                 count($userDefinedMaintenanceFrequency) &gt; 0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasCodeOrUserFreq"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasCodeOrUserFreq">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mmi-updatefrequency-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

      The maintenance information does not define update frequency.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="count($userDefinedMaintenanceFrequency)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($userDefinedMaintenanceFrequency)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mmi-updatefrequency-user-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The user defined update frequency is
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($userDefinedMaintenanceFrequency)"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>

      <!--REPORT
      -->
<xsl:if test="count($maintenanceAndUpdateFrequency)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($maintenanceAndUpdateFrequency)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mmi-updatefrequency-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The update frequency is "<xsl:text/>
               <xsl:copy-of select="$maintenanceAndUpdateFrequencyStr"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M49"/>
   <xsl:template match="@*|node()" priority="-2" mode="M49">
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>

   <!--PATTERN
        rule.mrc.sampledimensionSample dimension MUST provide a max,
      a min or a mean value
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Sample dimension MUST provide a max,
      a min or a mean value
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//mrc:MD_SampleDimension" priority="1000" mode="M51">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//mrc:MD_SampleDimension"/>
      <xsl:variable name="max" select="mrc:maxValue[normalize-space(*) != '']"/>
      <xsl:variable name="min" select="mrc:minValue[normalize-space(*) != '']"/>
      <xsl:variable name="mean" select="mrc:meanValue[normalize-space(*) != '']"/>
      <xsl:variable name="hasMaxOrMinOrMean" select="count($max) + count($min) + count($mean) &gt; 0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasMaxOrMinOrMean"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasMaxOrMinOrMean">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mrc.sampledimension-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The
      sample dimension does not provide max, min or mean value.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="count($max)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($max)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mrc.sampledimension-max-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The sample dimension max value is
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($max)"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>

      <!--REPORT
      -->
<xsl:if test="count($min)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($min)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mrc.sampledimension-min-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The sample dimension min value is
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($min)"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>

      <!--REPORT
      -->
<xsl:if test="count($mean)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($mean)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mrc.sampledimension-mean-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The sample dimension mean value is
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($mean)"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M51"/>
   <xsl:template match="@*|node()" priority="-2" mode="M51">
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>

   <!--PATTERN
        rule.mrc.bandunitBand MUST specified bounds units
      when a bound max or bound min is defined
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Band MUST specified bounds units
      when a bound max or bound min is defined
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//mrc:MD_Band[       normalize-space(mrc:boundMax/*) != '' or        normalize-space(mrc:boundMin/*) != ''       ]"
                 priority="1000"
                 mode="M53">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mrc:MD_Band[       normalize-space(mrc:boundMax/*) != '' or        normalize-space(mrc:boundMin/*) != ''       ]"/>
      <xsl:variable name="max" select="normalize-space(mrc:boundMax/*)"/>
      <xsl:variable name="min" select="normalize-space(mrc:boundMin/*)"/>
      <xsl:variable name="units" select="normalize-space(mrc:boundUnits[normalize-space(*) != ''])"/>
      <xsl:variable name="hasUnits" select="$units != ''"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasUnits"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasUnits">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mrc.bandunit-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The band
      defined a bound without unit.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasUnits">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasUnits">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mrc.bandunit-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The band bound [<xsl:text/>
               <xsl:copy-of select="$min"/>
               <xsl:text/>-<xsl:text/>
               <xsl:copy-of select="$max"/>
               <xsl:text/>] unit is
      "<xsl:text/>
               <xsl:copy-of select="$units"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M53"/>
   <xsl:template match="@*|node()" priority="-2" mode="M53">
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>

   <!--PATTERN
        rule.mrd.mediumunitMedium having density MUST specified density
      units
    -->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Medium having density MUST specified density
      units
    </svrl:text>

  <!--RULE
      -->
<xsl:template match="//mrd:MD_Medium[mrd:density]" priority="1000" mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mrd:MD_Medium[mrd:density]"/>
      <xsl:variable name="density" select="normalize-space(mrd:density/*)"/>
      <xsl:variable name="units"
                    select="normalize-space(mrd:densityUnits[normalize-space(*) != ''])"/>
      <xsl:variable name="hasUnits" select="$units != ''"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasUnits"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasUnits">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mrd.mediumunit-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The medium
      define a density without unit.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasUnits">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasUnits">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mrd.mediumunit-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      Medium density is "<xsl:text/>
               <xsl:copy-of select="$density"/>
               <xsl:text/>" (unit:
      "<xsl:text/>
               <xsl:copy-of select="$units"/>
               <xsl:text/>").
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M55"/>
   <xsl:template match="@*|node()" priority="-2" mode="M55">
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>

   <!--PATTERN
        rule.mri.datasetextentDataset extent-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Dataset extent</svrl:text>

  <!--RULE
      -->
<xsl:template match="/mdb:MD_Metadata[mdb:metadataScope/                           mdb:MD_MetadataScope/mdb:resourceScope/                           mcc:MD_ScopeCode/@codeListValue = 'dataset']/                           mdb:identificationInfo/mri:MD_DataIdentification"
                 priority="1000"
                 mode="M57">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/mdb:MD_Metadata[mdb:metadataScope/                           mdb:MD_MetadataScope/mdb:resourceScope/                           mcc:MD_ScopeCode/@codeListValue = 'dataset']/                           mdb:identificationInfo/mri:MD_DataIdentification"/>
      <xsl:variable name="geodescription"
                    select="mri:extent/gex:EX_Extent/gex:geographicElement/                   gex:EX_GeographicDescription/gex:geographicIdentifier[                   normalize-space(mcc:MD_Identifier/mcc:code/*/text()) != ''                   ]"/>
      <xsl:variable name="geobox"
                    select="mri:extent/gex:EX_Extent/gex:geographicElement/                   gex:EX_GeographicBoundingBox[                   normalize-space(gex:westBoundLongitude/gco:Decimal) != '' and                   normalize-space(gex:eastBoundLongitude/gco:Decimal) != '' and                   normalize-space(gex:southBoundLatitude/gco:Decimal) != '' and                   normalize-space(gex:northBoundLatitude/gco:Decimal) != ''                   ]"/>
      <xsl:variable name="hasGeoextent" select="count($geodescription) + count($geobox) &gt; 0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasGeoextent"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasGeoextent">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mri.datasetextent-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
The
      dataset MUST provide a
      geographic description or a bounding box.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="count($geodescription) &gt; 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($geodescription) &gt; 0">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mri.datasetextentdesc-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The
      dataset geographic description is:
      "<xsl:text/>
               <xsl:copy-of select="normalize-space($geodescription)"/>
               <xsl:text/>".
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>

      <!--REPORT
      -->
<xsl:if test="count($geobox) &gt; 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="count($geobox) &gt; 0">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mri.datasetextentbox-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
The
      dataset geographic bounding box is:
      [W:<xsl:text/>
               <xsl:copy-of select="$geobox/gex:westBoundLongitude/*/text()"/>
               <xsl:text/>,
      S:<xsl:text/>
               <xsl:copy-of select="$geobox/gex:southBoundLatitude/*/text()"/>
               <xsl:text/>],
      [E:<xsl:text/>
               <xsl:copy-of select="$geobox/gex:eastBoundLongitude/*/text()"/>
               <xsl:text/>,
      N:<xsl:text/>
               <xsl:copy-of select="$geobox/gex:northBoundLatitude/*/text()"/>
               <xsl:text/>],
      .
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M57"/>
   <xsl:template match="@*|node()" priority="-2" mode="M57">
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>

   <!--PATTERN
        rule.mri.topicategoryfordsandseriesTopic category for dataset and series-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Topic category for dataset and series</svrl:text>

  <!--RULE
      -->
<xsl:template match="/mdb:MD_Metadata[mdb:metadataScope/                          mdb:MD_MetadataScope/mdb:resourceScope/                          mcc:MD_ScopeCode/@codeListValue = 'dataset' or                           mdb:metadataScope/                          mdb:MD_MetadataScope/mdb:resourceScope/                          mcc:MD_ScopeCode/@codeListValue = 'series']/                          mdb:identificationInfo/mri:MD_DataIdentification"
                 priority="1000"
                 mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/mdb:MD_Metadata[mdb:metadataScope/                          mdb:MD_MetadataScope/mdb:resourceScope/                          mcc:MD_ScopeCode/@codeListValue = 'dataset' or                           mdb:metadataScope/                          mdb:MD_MetadataScope/mdb:resourceScope/                          mcc:MD_ScopeCode/@codeListValue = 'series']/                          mdb:identificationInfo/mri:MD_DataIdentification"/>
      <xsl:variable name="topics" select="mri:topicCategory/mri:MD_TopicCategoryCode"/>
      <xsl:variable name="hasTopics" select="count($topics) &gt; 0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasTopics"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasTopics">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.mri.topicategoryfordsandseries-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
A topic category MUST be specified for
      dataset or series.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasTopics">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasTopics">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mri.topicategoryfordsandseries-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Number of topic category identified:
      <xsl:text/>
               <xsl:copy-of select="count($topics)"/>
               <xsl:text/>.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M59"/>
   <xsl:template match="@*|node()" priority="-2" mode="M59">
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>

   <!--PATTERN
        rule.mri.associatedresourceAssociated resource name-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Associated resource name</svrl:text>

  <!--RULE
      -->
<xsl:template match="//mri:MD_DataIdentification/mri:associatedResource/*|                        //srv:SV_ServiceIdentification/mri:associatedResource/*"
                 priority="1000"
                 mode="M61">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mri:MD_DataIdentification/mri:associatedResource/*|                        //srv:SV_ServiceIdentification/mri:associatedResource/*"/>
      <xsl:variable name="nameTitle" select="normalize-space(mri:name/*/cit:title)"/>
      <xsl:variable name="nameRef" select="mri:name/@uuidref"/>
      <xsl:variable name="mdRefTitle" select="normalize-space(mri:metadataReference/*/cit:title)"/>
      <xsl:variable name="mdRefRef" select="mri:metadataReference/@uuidref"/>
      <xsl:variable name="hasName" select="$nameTitle != '' or $nameRef != ''"/>
      <xsl:variable name="hasMdRef" select="$mdRefTitle != '' or $mdRefRef != ''"/>
      <xsl:variable name="resourceRef"
                    select="concat($nameTitle, $nameRef,                               $mdRefRef, $mdRefTitle)"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasName or $hasMdRef"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasName or $hasMdRef">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.mri.associatedresource-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

      When a resource is associated, a name or a metadata
      reference MUST be specified.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasName or $hasMdRef">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasName or $hasMdRef">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mri.associatedresource-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      The resource "<xsl:text/>
               <xsl:copy-of select="$resourceRef"/>
               <xsl:text/>"
      is associated.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M61"/>
   <xsl:template match="@*|node()" priority="-2" mode="M61">
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>

   <!--PATTERN
        rule.mri.defaultlocalewhenhastextResource language-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Resource language</svrl:text>

  <!--RULE
      -->
<xsl:template match="//mri:MD_DataIdentification[       ../../mdb:contentInfo/mrc:MD_FeatureCatalogue or       ../../mdb:contentInfo/mrc:MD_FeatureCatalogueDescription]"
                 priority="1000"
                 mode="M63">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//mri:MD_DataIdentification[       ../../mdb:contentInfo/mrc:MD_FeatureCatalogue or       ../../mdb:contentInfo/mrc:MD_FeatureCatalogueDescription]"/>
      <xsl:variable name="resourceLanguages"
                    select="mri:defaultLocale/lan:PT_Locale/                 lan:language/lan:LanguageCode/@codeListValue[. != '']"/>
      <xsl:variable name="hasAtLeastOneLanguage" select="count($resourceLanguages) &gt; 0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$hasAtLeastOneLanguage"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$hasAtLeastOneLanguage">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                          diagnostic="rule.mri.defaultlocalewhenhastext-failure-en">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>
Resource language MUST be defined when the
      resource
      includes textual information.
    </svrl:diagnostic-reference> 
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--REPORT
      -->
<xsl:if test="$hasAtLeastOneLanguage">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasAtLeastOneLanguage">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}"
                                       diagnostic="rule.mri.defaultlocalewhenhastext-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>
Number of resource language:
      <xsl:text/>
               <xsl:copy-of select="count($resourceLanguages)"/>
               <xsl:text/>.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M63"/>
   <xsl:template match="@*|node()" priority="-2" mode="M63">
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>

   <!--PATTERN
        rule.srv.servicetaxonomyService taxonomy-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Service taxonomy</svrl:text>

  <!--RULE
      -->
<xsl:template match="//srv:SV_ServiceIdentification" priority="1000" mode="M65">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//srv:SV_ServiceIdentification"/>
      <xsl:variable name="listOfTaxonomy"
                    select="'Geographic human interaction services,                         Geographic model/information management services,                         Geographic workflow/task management services,                         Geographic processing services,                         Geographic processing services — spatial,                        Geographic processing services — thematic,                        Geographic processing services — temporal,                         Geographic processing services — metadata,                         Geographic communication services'"/>
      <xsl:variable name="serviceTaxonomies"
                    select="mri:descriptiveKeywords/mri:MD_Keywords/mri:keyword[         contains($listOfTaxonomy, */text())]"/>
      <xsl:variable name="hasAtLeastOneTaxonomy" select="count($serviceTaxonomies) &gt; 0"/>

      <!--REPORT
      -->
<xsl:if test="$hasAtLeastOneTaxonomy">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                 test="$hasAtLeastOneTaxonomy">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text/> 
            <svrl:diagnostic-reference ref="#_{geonet:element/@ref}" diagnostic="rule.mri.servicetaxonomy-success-en">
               <xsl:attribute name="xml:lang">en</xsl:attribute>

      Number of service taxonomy specified:
      <xsl:text/>
               <xsl:copy-of select="count($serviceTaxonomies)"/>
               <xsl:text/>.
    </svrl:diagnostic-reference> 
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M65"/>
   <xsl:template match="@*|node()" priority="-2" mode="M65">
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
</xsl:stylesheet>