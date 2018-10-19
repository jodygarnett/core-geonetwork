/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */
package org.fao.geonet.api.pages;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletResponse;

import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.api.API;
import org.fao.geonet.api.ApiParams;
import org.fao.geonet.domain.page.Page;
import org.fao.geonet.domain.page.PageIdentity;
import org.fao.geonet.repository.page.PageRepository;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;
import springfox.documentation.annotations.ApiIgnore;

@RequestMapping(value = { "/api", "/api/" + API.VERSION_0_1 })
@Api(value = "pages", tags = "pages",
description = "Static pages inside GeoNetwork")
@Controller("pages")
public class PagesAPI {

    // HTTP status messages not from ApiParams
    private static final String PAGE_NOT_FOUND="Page not found";
    private static final String PAGE_DUPLICATE="Page already in the system: use PUT";
    private static final String PAGE_SAVED="Page saved";
    private static final String PAGE_UPDATED="Page changes saved";
    private static final String PAGE_DELETED="Page removed";

    // WRITE, EDIT, DELETE, READ Page methods

    @ApiOperation(
            value = "Add a new Page object in DRAFT section in status HIDDEN",
            notes = "<a href='http://geonetwork-opensource.org/manuals/trunk/eng/users/user-guide/define-static-pages/define-pages.html'>More info</a>",
            nickname = "addPage")
    @RequestMapping(
            value = "/",
            method = RequestMethod.POST)
    @ResponseStatus(value = HttpStatus.OK)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = PAGE_SAVED),
            @ApiResponse(code = 404, message = PAGE_NOT_FOUND),
            @ApiResponse(code = 409, message = PAGE_DUPLICATE),
            @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT)
    })
    @ResponseBody
    public void addPage(
            @RequestParam(value = "language", required=true) final String language,
            @RequestParam(value = "pageId", required=true) final String pageId,
            @RequestParam(value = "data", required=false) final String data,
            @RequestParam(value = "format", required=true) final Page.PageFormat format,
            @ApiIgnore final HttpServletResponse response
            ) {

        final ApplicationContext appContext = ApplicationContextHolder.get();
        PageRepository pageRepository = appContext.getBean(PageRepository.class);

        if(pageRepository.findOne(new PageIdentity(language, pageId)) == null) {

            List<Page.PageSection> sections = new ArrayList<Page.PageSection>();
            sections.add(Page.PageSection.DRAFT);
            Page page = new Page(new PageIdentity(language, pageId), data, format, sections, Page.PageStatus.HIDDEN);

            pageRepository.save(page);
        } else {
            response.setStatus(HttpStatus.CONFLICT.value());
        }
    }

    @ApiOperation(
            value = "Edit a Page object",
            notes = "<a href='http://geonetwork-opensource.org/manuals/trunk/eng/users/user-guide/define-static-pages/define-pages.html'>More info</a>",
            nickname = "editPage")
    @RequestMapping(
            value = "/{language}/{pageId}",
            method = RequestMethod.PUT)
    @ResponseStatus(value = HttpStatus.OK)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = PAGE_UPDATED),
            @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT)
    })
    @ResponseBody
    public void editPage(
            @PathVariable(value = "language") final String language,
            @PathVariable(value = "pageId") final String pageId,
            @RequestParam(value = "data", required=false) final String data,
            @RequestParam(value = "format", required=true) final Page.PageFormat format,
            @ApiIgnore final HttpServletResponse response
            ) {
        final ApplicationContext appContext = ApplicationContextHolder.get();
        PageRepository pageRepository = appContext.getBean(PageRepository.class);

        Page page = pageRepository.findOne(new PageIdentity(language, pageId));

        if(page == null) {
            response.setStatus(HttpStatus.NOT_FOUND.value());
            return;
        }

        page.setData(data);
        page.setFormat(format);

        pageRepository.save(page);
    }

    @ApiOperation(
            value = "Delete a Page object",
            notes = "<a href='http://geonetwork-opensource.org/manuals/trunk/eng/users/user-guide/define-static-pages/define-pages.html'>More info</a>",
            nickname = "deletePage")
    @RequestMapping(
            value = "/{language}/{pageId}",
            method = RequestMethod.DELETE)
    @ResponseStatus(value = HttpStatus.OK)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = PAGE_DELETED),
            @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT)
    })
    @ResponseBody
    public void deletePage(
            @PathVariable(value = "language") final String language,
            @PathVariable(value = "pageId") final String pageId,
            @RequestParam(value = "data", required=false) final String data,
            @RequestParam(value = "format", required=true) final Page.PageFormat format,
            @ApiIgnore final HttpServletResponse response
            ) {
        final ApplicationContext appContext = ApplicationContextHolder.get();
        PageRepository pageRepository = appContext.getBean(PageRepository.class);

        Page page = pageRepository.findOne(new PageIdentity(language, pageId));

        if(page == null) {
            response.setStatus(HttpStatus.NOT_FOUND.value());
            return;
        }

        pageRepository.delete(new PageIdentity(language, pageId));        
    }

    @ApiOperation(
            value = "Return the page object",
            notes = "<a href='http://geonetwork-opensource.org/manuals/trunk/eng/users/user-guide/define-static-pages/define-pages.html'>More info</a>",
            nickname = "getPage")
    @RequestMapping(
            value = "/{language}/{pageId}",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseStatus(value = HttpStatus.OK)
    @ApiResponses(value = {
            @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW)
    })
    @ResponseBody
    public Page getPage(
            @PathVariable(value = "language") final String language,
            @PathVariable(value = "pageId") final String pageId,
            @ApiIgnore final HttpServletResponse response
            ) {
        final ApplicationContext appContext = ApplicationContextHolder.get();
        PageRepository pageRepository = appContext.getBean(PageRepository.class);

        Page page = pageRepository.findOne(new PageIdentity(language, pageId));

        if(page == null) {
            response.setStatus(HttpStatus.NOT_FOUND.value());
            return null;
        }

        return page;
    }

    @ApiOperation(
            value = "Return the static html content identified by pageId",
            notes = "<a href='http://geonetwork-opensource.org/manuals/trunk/eng/users/user-guide/define-static-pages/define-pages.html'>More info</a>",
            nickname = "getPage")
    @RequestMapping(
            value = "/{language}/{pageId}/data",
            method = RequestMethod.GET,
            produces = MediaType.TEXT_HTML_VALUE)
    @ResponseStatus(value = HttpStatus.OK)
    @ApiResponses(value = {
            @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW)
    })
    @ResponseBody
    public String getPageContent(
            @PathVariable(value = "language") final String language,
            @PathVariable(value = "pageId") final String pageId,
            @ApiIgnore final HttpServletResponse response
            ) {
        final ApplicationContext appContext = ApplicationContextHolder.get();
        PageRepository pageRepository = appContext.getBean(PageRepository.class);

        Page page = pageRepository.findOne(new PageIdentity(language, pageId));

        if(page == null) {
            response.setStatus(HttpStatus.NOT_FOUND.value());
            return null;
        }

        return page.getData();
    }


    // SECTION OPERATIONS methods

    @ApiOperation(
            value = "Adds the page to a section. This means that the link to the page will be shown in the list associated to that section.",
            notes = "<a href='http://geonetwork-opensource.org/manuals/trunk/eng/users/user-guide/define-static-pages/define-pages.html'>More info</a>",
            nickname = "addPageToSection")
    @RequestMapping(
            value = "/{language}/{pageId}/{section}",
            method = RequestMethod.POST)
    @ResponseStatus(value = HttpStatus.OK)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = PAGE_UPDATED),
            @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT)
    })
    @ResponseBody
    public void addPageToSection(
            @PathVariable(value = "language") final String language,
            @PathVariable(value = "pageId") final String pageId,
            @PathVariable(value = "section") final Page.PageSection section,
            @ApiIgnore final HttpServletResponse response
            ) {
        final ApplicationContext appContext = ApplicationContextHolder.get();
        PageRepository pageRepository = appContext.getBean(PageRepository.class);

        Page page = pageRepository.findOne(new PageIdentity(language, pageId));

        if(page == null) {
            response.setStatus(HttpStatus.NOT_FOUND.value());
            return;
        }

        Page.PageSection sectionToAdd = section;

        if(sectionToAdd.equals(Page.PageSection.ALL)) {
            page.setSections(new ArrayList<Page.PageSection>());
            page.getSections().add(sectionToAdd);
        } else if(!page.getSections().contains(sectionToAdd)) {
            page.getSections().add(sectionToAdd);
        }

        pageRepository.save(page);
    }

    @ApiOperation(
            value = "Removes the page from a section. This means that the link to the page will not be shown in the list associated to that section.",
            notes = "<a href='http://geonetwork-opensource.org/manuals/trunk/eng/users/user-guide/define-static-pages/define-pages.html'>More info</a>",
            nickname = "removePageFromSection")
    @RequestMapping(
            value = "/{language}/{pageId}/{section}",
            method = RequestMethod.DELETE)
    @ResponseStatus(value = HttpStatus.OK)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = PAGE_UPDATED),
            @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT)
    })
    @ResponseBody
    public void removePageFromSection(
            @PathVariable(value = "language") final String language,
            @PathVariable(value = "pageId") final String pageId,
            @PathVariable(value = "section") final Page.PageSection section,
            @ApiIgnore final HttpServletResponse response
            ) {
        final ApplicationContext appContext = ApplicationContextHolder.get();
        PageRepository pageRepository = appContext.getBean(PageRepository.class);

        Page page = pageRepository.findOne(new PageIdentity(language, pageId));

        if(page == null) {
            response.setStatus(HttpStatus.NOT_FOUND.value());
            return;
        }

        if(section.equals(Page.PageSection.ALL)) {
            page.setSections(new ArrayList<Page.PageSection>());
            page.getSections().add(Page.PageSection.DRAFT);
        } else if(section.equals(Page.PageSection.DRAFT)) {
            // Cannot remove a page from DRAFT section
        } else if(page.getSections().contains(section)) {
            page.getSections().remove(section);
        }

        pageRepository.save(page);
    }

    // STATUS OPERATION methods

    @ApiOperation(
            value = "Removes the page from a section. This means that the link to the page will not be shown in the list associated to that section.",
            notes = "<a href='http://geonetwork-opensource.org/manuals/trunk/eng/users/user-guide/define-static-pages/define-pages.html'>More info</a>",
            nickname = "removePageFromSection")
    @RequestMapping(
            value = "/{language}/{pageId}/{status}",
            method = RequestMethod.PUT)
    @ResponseStatus(value = HttpStatus.OK)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = PAGE_UPDATED),
            @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_EDIT)
    })
    @ResponseBody
    public void changePageStatus(
            @PathVariable(value = "language") final String language,
            @PathVariable(value = "pageId") final String pageId,
            @PathVariable(value = "status") final Page.PageStatus status,
            @ApiIgnore final HttpServletResponse response
            ) {

        final ApplicationContext appContext = ApplicationContextHolder.get();
        PageRepository pageRepository = appContext.getBean(PageRepository.class);

        Page page = pageRepository.findOne(new PageIdentity(language, pageId));

        if(page == null) {
            response.setStatus(HttpStatus.NOT_FOUND.value());
            return;
        }

        page.setStatus(status);

        pageRepository.save(page);
    }

    // LIST PAGES methods

    @ApiOperation(
            value = "List all pages according to the filters",
            notes = "<a href='http://geonetwork-opensource.org/manuals/trunk/eng/users/user-guide/define-static-pages/define-pages.html'>More info</a>",
            nickname = "listPages")
    @RequestMapping(
            value = "/list",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseStatus(value = HttpStatus.OK)
    @ApiResponses(value = {
            @ApiResponse(code = 403, message = ApiParams.API_RESPONSE_NOT_ALLOWED_CAN_VIEW)
    })
    @ResponseBody
    public List<Page> listPages(
            @RequestParam(value = "language", required = false) final String language,
            @RequestParam(value = "section", required = false) final Page.PageSection section,
            @RequestParam(value = "format", required = false) final Page.PageFormat format,
            @ApiIgnore final HttpServletResponse response
            ) {
        final ApplicationContext appContext = ApplicationContextHolder.get();
        PageRepository pageRepository = appContext.getBean(PageRepository.class);

        return pageRepository.findAll();

    }

}

