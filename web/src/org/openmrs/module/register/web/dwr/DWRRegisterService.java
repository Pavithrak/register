package org.openmrs.module.register.web.dwr;

import java.util.List;
import java.util.Vector;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.api.context.Context;
import org.openmrs.module.register.RegisterService;
import org.openmrs.web.dwr.EncounterListItem;

public class DWRRegisterService {
	protected final Log log = LogFactory.getLog(getClass());
	
	public RegisterViewResult getRegisterEntriesByLocation(int registerId, int locationId){
		RegisterService registerService = Context.getService(RegisterService.class);
		List<Encounter> encounters = registerService.getEncountersForRegisterByLocation(registerId, locationId);
		List<EncounterListItem> encounterListItems = new Vector<EncounterListItem>();
		for (Encounter encounter : encounters) {
			encounterListItems.add(new EncounterListItem(encounter));
		}
		
		RegisterViewResult registerViewResult = new RegisterViewResult();
		
		registerViewResult.addHeader("personName", "Person Name");
		registerViewResult.addHeader("gender", "Gender");
		registerViewResult.addHeader("dateOfBirth", "Birth Date");
		registerViewResult.addHeader("encounterId", "Encounter Id");
		registerViewResult.addHeader("encounterDate", "Encounter Date");
		registerViewResult.addHeader("encounterLocation", "Encounter Location");
		
		for (Encounter encounter : encounters) {
			registerViewResult.addRegisterViewResult(new RegisterEntry(encounter));
			
			for (Obs obs : encounter.getAllObs()) {
				String displayString = obs.getConcept().getDisplayString(); 
				registerViewResult.addObsHeader(displayString, displayString);
			}
		}
		return registerViewResult;		
	}
}
