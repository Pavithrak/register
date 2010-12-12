package org.openmrs.module.register.web.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.openmrs.Encounter;
import org.openmrs.Location;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.htmlformentry.FormEntrySession;
import org.openmrs.module.htmlformentry.HtmlForm;
import org.openmrs.module.htmlformentry.HtmlFormEntryConstants;
import org.openmrs.module.htmlformentry.HtmlFormEntryUtil;
import org.openmrs.module.htmlformentry.FormEntryContext.Mode;
import org.openmrs.module.htmlformentry.web.controller.HtmlFormEntryController;
import org.openmrs.module.register.RegisterService;
import org.openmrs.module.register.db.hibernate.Register;
import org.openmrs.web.WebConstants;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

public class RegisterHtmlFormController extends HtmlFormEntryController {

	private boolean isEncounterEnabled = false;
	private boolean isPatientCreated = false;

	/**
	 * Initially called after the formBackingObject method to get the landing
	 * form name
	 * 
	 * @return String form view name
	 */
	
	@Override
	protected Object formBackingObject(HttpServletRequest request) throws Exception {
		isPatientCreated = false;
		HtmlForm htmlForm = null;
		Patient patient = null;
		Register register=null;
		Encounter encounter = null;		
		CommandMap commandMap= new CommandMap();
		
		String patientIDParam = null;
		
		String locationIDParam = request.getParameter("locationId");
		Location location = null;
		if (StringUtils.hasText(locationIDParam)){
			location = Context.getLocationService().getLocation(new Integer(locationIDParam));
		}
		
		String encounterIDParam = request.getParameter("encounterId");
		if (StringUtils.hasText(encounterIDParam)) {
			try {
				encounter = Context.getEncounterService().getEncounter(new Integer(encounterIDParam));
				patient = encounter.getPatient();
			}
			catch (Exception e) {
			}
		}
		else {
			patientIDParam = request.getParameter("patientId");
			if (StringUtils.hasText(patientIDParam)) {
				try {
					patient = Context.getPatientService().getPatient(new Integer(patientIDParam));
				}
				catch (Exception e) {
				}
			}
		}

		Mode mode = Mode.VIEW;
		if ("Enter".equalsIgnoreCase(request.getParameter("mode"))) {
			mode = Mode.ENTER;
			if (patient == null) {
				patient = new Patient();
				isPatientCreated = true;
			}
		}
		else if ("Edit".equalsIgnoreCase(request.getParameter("mode"))) {
			mode = Mode.EDIT;
		}

		String registerIdParam = request.getParameter("registerId");
		
		if (StringUtils.hasText(registerIdParam)) {
			register = (Register)Context.getService(RegisterService.class).getRegister(Integer.valueOf(registerIdParam));
			htmlForm = HtmlFormEntryUtil.getService().getHtmlForm(register.getHtmlForm().getId());
		}

		if (!StringUtils.hasText(registerIdParam))
			throw new IllegalArgumentException("You must specify either an htmlFormId or a formId");

		if (htmlForm == null)
			throw new IllegalArgumentException("The given register ID '" + registerIdParam + "' does not have an HtmlForm associated with it");

		if (mode == Mode.VIEW || mode == Mode.EDIT) {
			if (encounter == null && patient == null) {
				if (StringUtils.hasText(encounterIDParam)){
					throw new IllegalArgumentException("No encounter with id " + encounterIDParam				
							+ "  or not able to reterive the given encounter details.");	
				}
				if (StringUtils.hasText(patientIDParam)){
					throw new IllegalArgumentException("No patient with id " + patientIDParam				
							+ "  or not able to reterive the given patient details.");
				}
				throw new IllegalArgumentException("encounterId/patientId param missing");
			}
		}

		FormEntrySession session;
		isEncounterEnabled = hasEncouterTag(htmlForm.getXmlData());
		if (isEncounterEnabled){
			session = new FormEntrySession(patient, encounter, mode, htmlForm, location);
		}
		else{
			session = new FormEntrySession(patient, htmlForm, mode, location);
		}

		// In case we're not using a sessionForm, we need to check for the case
		// where the underlying form was modified while a user was filling a
		// form out
		if (StringUtils.hasText(request.getParameter("formModifiedTimestamp"))) {
			long submittedTimestamp = Long.valueOf(request.getParameter("formModifiedTimestamp"));
			if (submittedTimestamp != session.getFormModifiedTimestamp()) {
				throw new RuntimeException(Context.getMessageSourceService().getMessage("htmlformentry.error.formModifiedBeforeSubmission"));
			}
		}

		Context.setVolatileUserData(HtmlFormEntryController.FORM_IN_PROGRESS_KEY, session);
		commandMap.addToMap("session", session);
		commandMap.addToMap("register", register);
		return commandMap;
	}

	@Override
	protected ModelAndView onSubmit(HttpServletRequest request, HttpServletResponse response, Object commandObject, BindException errors)
			throws Exception {
		
		CommandMap commandMap=(CommandMap)commandObject;
		FormEntrySession session = (FormEntrySession) commandMap.getMap().get("session");
		if (isEncounterEnabled) {
			session.prepareForSubmit();
		}
		else {
			session.preparePersonForSubmit();
		}

		if (session.getContext().getMode() == Mode.ENTER && isPatientCreated
				&& (session.getSubmissionActions().getPersonsToCreate() == null || session.getSubmissionActions().getPersonsToCreate().size() == 0))
			throw new IllegalArgumentException("This form is not going to create an Patient");

		ModelAndView resultView = handleSubmit(request, response, session, errors);
		
		if(!errors.hasErrors()){
			request.getSession().setAttribute(WebConstants.OPENMRS_MSG_ATTR, "register.record.saved");
		}

		return resultView;
	}

	private boolean hasEncouterTag(String xmlData) {
		for (String tag : HtmlFormEntryConstants.ENCOUNTER_TAGS) {
			tag = "<" + tag;
			if (xmlData.contains(tag)) {
				return true;
			}
		}
		return false;
	}
	
	@Override
	protected String getQueryPrameters(HttpServletRequest request,FormEntrySession formEntrySession) {
		return "?" + request.getQueryString();
	}
	
	 @Override
	    protected void onBindAndValidate(HttpServletRequest request,
	            Object commandObject, BindException errors) throws Exception {
		 super.onBindAndValidate(request, ((CommandMap)commandObject).getMap().get("session"), errors);
	 }
	
	private Register getRegisters(Integer registerId) {
		RegisterService registerService = (RegisterService) Context.getService(RegisterService.class);
		return registerService.getRegister(registerId);
	}
    
}