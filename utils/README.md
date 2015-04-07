Utilities for loading GA fragments

* gaAuthorstoCI_Organisation.xsl - converts database dump of authors table to CI_Organisation fragments in a directory called authors
* gaContactstoCI_Organisation.xsl - converts database dump of contacts table to CI_Organisation fragments in a directory called contacts
* gaPublisherstoCI_Organisation.xsl - converts database dump of publishers table to CI_Organisation fragments in a directory called publishers

* gaLicensestoMD_LegalConstraints.xsl - converts database dump of licenses table to MD_LegalConstraints fragments ina  directory called licenses

* gaProtocolstoGNStrings.xsl - converts database dump of protocols table to XML that can be added to the iso19115-3/loc/eng/labels.xml as helpers for the cit:protocol element in the GN editor
* gaSeriesTitlestoGNStrings.xsl - converts database dump of series title table to XML that can be added to the iso19115-3/loc/eng/labels.xml as helpers for the cit:series/cit:CI_Series/cit:name element in the GN editor

To execute these XSLTs you need the XML database dump of the relevant table and access to the saxon jar file. Here is an
example:

% java -jar /usr/local/jakarta/geonetwork-anzmest-ga-2.10.5/web/geonetwork/WEB-INF/lib/saxon-9.1.0.8b-patch.jar -s ~simon/Documents/gawork/lookups/Protocols_table.xml -o protocols.xml gaProtocolstoGNStrings.xsl

Some XSLTs produce fragments. The fragments will be created and stored in a subdirectory of the directory in which you run the XSLT. For example, gaAuthorstoCI_Organisation.xsl creates a directory authors and stores the authors fragments in it. For these XSLTs, the output argument (-o) can be left out. For example:

% java -jar /usr/local/jakarta/geonetwork-anzmest-ga-2.10.5/web/geonetwork/WEB-INF/lib/saxon-9.1.0.8b-patch.jar -s ~simon/Documents/gawork/lookups/Publisher_table.xml gaPublisherstoCI_Responsibility.xsl

Fragments are loaded into GeoNetwork using the batch import function in the Administration menu. Ensure that you select 'subtemplates' as the type of metadata before executing the import.
