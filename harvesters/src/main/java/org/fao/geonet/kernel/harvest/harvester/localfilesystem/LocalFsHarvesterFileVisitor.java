package org.fao.geonet.kernel.harvest.harvester.localfilesystem;

import com.google.common.collect.Lists;
import jeeves.server.context.ServiceContext;
import org.fao.geonet.Logger;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.ISODate;
import org.fao.geonet.domain.Metadata;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.harvest.harvester.CategoryMapper;
import org.fao.geonet.kernel.harvest.harvester.GroupMapper;
import org.fao.geonet.kernel.harvest.harvester.HarvestResult;
import org.fao.geonet.repository.MetadataRepository;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;

import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Date;
import java.util.List;

/**
* @author Jesse on 11/6/2014.
*/
class LocalFsHarvesterFileVisitor extends SimpleFileVisitor<Path> {

    private final Logger log;
    private final LocalFilesystemParams params;
    private final DataManager dataMan;
    private final LocalFilesystemHarvester harvester;
    private final HarvestResult result = new HarvestResult();
    private final MetadataRepository repo;

    private boolean transformIt = false;
    private Path thisXslt;
    private final CategoryMapper localCateg;
    private final GroupMapper localGroups;
    private final List<String> idsForHarvestingResult = Lists.newArrayList();

    public LocalFsHarvesterFileVisitor(ServiceContext context, LocalFilesystemParams params, Logger log,
                                       LocalFilesystemHarvester harvester) throws Exception {
        this.thisXslt = context.getAppPath().resolve(Geonet.Path.IMPORT_STYLESHEETS);
        if (!params.importXslt.equals("none")) {
            thisXslt = thisXslt.resolve(params.importXslt);
            transformIt = true;
        }
        localCateg = new CategoryMapper(context);
        localGroups = new GroupMapper(context);
        this.log = log;
        this.params = params;
        this.dataMan = context.getBean(DataManager.class);
        this.harvester = harvester;
        this.repo = context.getBean(MetadataRepository.class);
    }

    @Override
    public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
        try {
            if (file.getFileName().toString().endsWith(".xml")) {
                result.totalMetadata++;
                Element xml;
                Path filePath = file.toAbsolutePath().normalize();

                try {
                    log.debug("reading file: " + filePath);
                    xml = Xml.loadFile(file);
                } catch (JDOMException e) { // JDOM problem
                    log.debug("Error loading XML from file " + filePath + ", ignoring");
                    e.printStackTrace();
                    result.badFormat++;
                    return FileVisitResult.CONTINUE; // skip this one
                } catch (Throwable e) { // some other error
                    log.debug("Error retrieving XML from file " + filePath + ", ignoring");
                    e.printStackTrace();
                    result.unretrievable++;
                    return FileVisitResult.CONTINUE; // skip this one
                }

                // validate it here if requested
                if (params.validate) {
                    try {
                        Xml.validate(xml);
                    } catch (Exception e) {
                        log.debug("Cannot validate XML from file " + filePath + ", ignoring. Error was: " + e.getMessage());
                        result.doesNotValidate++;
                        return FileVisitResult.CONTINUE; // skip this one
                    }
                }

                // transform using importxslt if not none
                if (transformIt) {
                    try {
                        xml = Xml.transform(xml, thisXslt);
                    } catch (Exception e) {
                        log.debug("Cannot transform XML from file " + filePath + ", ignoring. Error was: " + e.getMessage());
                        result.badFormat++;
                        return FileVisitResult.CONTINUE; // skip this one
                    }
                }

                String schema = dataMan.autodetectSchema(xml, null);
                if (schema == null) {
                    result.unknownSchema++;
                } else {
                    String uuid = dataMan.extractUUID(schema, xml);
                    if (uuid == null || uuid.equals("")) {
                        result.badFormat++;
                    } else {
                        String id = dataMan.getMetadataId(uuid);
                        if (id == null) {
                            // For new record change date will be the time of metadata xml date change or the date when
                            // the record was harvested (if can't be obtained the metadata xml date change)
                            String createDate = null;
                            // or the last modified date of the file
                            if (params.checkFileLastModifiedForUpdate) {
                                createDate = new ISODate(Files.getLastModifiedTime(file).toMillis(), false).getDateAndTime();
                            } else {
                                try {
                                    createDate = dataMan.extractDateModified(schema, xml);
                                } catch (Exception ex) {
                                    log.error("LocalFilesystemHarvester - addMetadata - can't get metadata modified date for metadata uuid= " +

                                              uuid + ", using current date for modified date");
                                    createDate = new ISODate().toString();
                                }
                            }

                            log.debug("adding new metadata");
                            id = harvester.addMetadata(xml, uuid, schema, localGroups, localCateg, createDate);
                            result.addedMetadata++;
                        } else {
                            // Check last modified date of the file with the record change date
                            // to check if an update is required
                            if (params.checkFileLastModifiedForUpdate) {
                                Date fileDate = new Date(Files.getLastModifiedTime(file).toMillis());

                                final Metadata metadata = repo.findOne(id);
                                final ISODate modified = metadata.getDataInfo().getChangeDate();
                                Date recordDate = modified.toDate();

                                String changeDate = new ISODate(fileDate.getTime(), false).getDateAndTime();

                                log.debug(" File date is: " + fileDate.toString() + " / record date is: " + modified);
                                if (recordDate.before(fileDate)) {
                                    log.debug("  Db record is older than file. Updating record with id: " + id);
                                    harvester.updateMetadata(xml, id, localGroups, localCateg, changeDate);
                                    result.updatedMetadata++;
                                } else {
                                    log.debug("  Db record is not older than last modified date of file. No need for update.");
                                    result.unchangedMetadata++;
                                }
                            } else {
                                log.debug("  updating existing metadata, id is: " + id);

                                String changeDate;

                                try {
                                    changeDate = dataMan.extractDateModified(schema, xml);
                                } catch (Exception ex) {
                                    log.error("LocalFilesystemHarvester - updateMetadata - can't get metadata modified date for " +
                                              "metadata id= " +
                                              id + ", using current date for modified date");
                                    changeDate = new ISODate().toString();
                                }

                                harvester.updateMetadata(xml, id, localGroups, localCateg, changeDate);
                                result.updatedMetadata++;
                            }
                        }
                        idsForHarvestingResult.add(id);
                    }
                }
            }
        } catch (Throwable e) {
            log.error("An error occurred while harvesting a local file:" + file);
        }
        return FileVisitResult.CONTINUE;
    }

    public HarvestResult getResult() {
        return result;
    }

    public List<String> getIdsForHarvestingResult() {
        return idsForHarvestingResult;
    }
}
