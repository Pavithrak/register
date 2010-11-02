package org.openmrs.module.register.web.dwr;

import java.util.List;
import java.util.Vector;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Encounter;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.htmlformentry.FormEntrySession;
import org.openmrs.module.htmlformentry.HtmlForm;
import org.openmrs.module.htmlformentry.HtmlFormEntryService;
import org.openmrs.module.htmlformentry.FormEntryContext.Mode;
import org.openmrs.module.htmlformentry.schema.HtmlFormField;
import org.openmrs.module.htmlformentry.schema.HtmlFormSchema;
import org.openmrs.module.htmlformentry.schema.HtmlFormSection;
import org.openmrs.module.htmlformentry.schema.ObsField;
import org.openmrs.module.htmlformentry.schema.ObsGroup;
import org.openmrs.module.register.RegisterService;
import org.openmrs.web.dwr.EncounterListItem;

public class DWRRegisterService {
	protected final Log log = LogFactory.getLog(getClass());

	public RegisterViewResult getRegisterEntriesByLocation(int registerId, int locationId, int htmlFormId, int pageSize, int page) {

		RegisterService registerService = Context.getService(RegisterService.class);
		HtmlFormEntryService htmlFormEntryService = Context.getService(HtmlFormEntryService.class);
		HtmlForm htmlForm = htmlFormEntryService.getHtmlForm(htmlFormId);
		List<Encounter> encounters = registerService.getEncountersForRegisterByLocation(registerId, locationId, pageSize, page);
		List<EncounterListItem> encounterListItems = new Vector<EncounterListItem>();
		for (Encounter encounter : encounters) {
			encounterListItems.add(new EncounterListItem(encounter));
		}
		RegisterViewResult registerViewResult = new RegisterViewResult();
		registerViewResult.addHeader("encounterDate", "Encounter Date");
		registerViewResult.addHeader("personName", "Person Name");
		registerViewResult.addHeader("gender", "Gender");
		registerViewResult.addHeader("dateOfBirth", "Birth Date");

		for (Encounter encounter : encounters) {
			registerViewResult.addRegisterViewResult(new RegisterEntry(encounter));
		}

		FormEntrySession fes;
		try {
			fes = new FormEntrySession(new Patient(), null, Mode.ENTER, htmlForm);
			HtmlFormSchema schema = fes.getContext().getSchema();
			for (HtmlFormSection section : schema.getSections()) {
				for (HtmlFormField field : section.getFields()) {
					fieldHelper(field, registerViewResult);
				}
			}
		}
		catch (Exception e) {
			log.error(e);
		}
		return registerViewResult;
	}

	private void fieldHelper(HtmlFormField field, RegisterViewResult registerViewResult) {

		if (field instanceof ObsField) {
			// single column for this concept
			ObsField obsField = (ObsField) field;
			registerViewResult.addObsHeader(obsField.getQuestion().getDisplayString(), obsField.getName());
		}
		else if (field instanceof ObsGroup) {
			// combine all the concepts into one column
			ObsGroup og = (ObsGroup) field;
			for (ObsField obsField : og.getChildren()) {
				fieldHelper(obsField, registerViewResult);
			}
		}
		else {
			log.debug(field.getClass() + " not yet implemented");
		}

	}

	public int getRegisterEntryCount(int registerId, int locationId) {

		RegisterService registerService = Context.getService(RegisterService.class);
		return registerService.getEncounterCountForRegisterByLocation(registerId, locationId).intValue();
	}

}
