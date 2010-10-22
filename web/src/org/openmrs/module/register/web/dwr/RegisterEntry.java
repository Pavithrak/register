package org.openmrs.module.register.web.dwr;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.util.Format;

public class RegisterEntry {
	
	private String personName;
	private String gender;
	private String dateOfBirth;
	private String encounterId;
	private String encounterDate;
	private String encounterLocation;	
	private Map<String, String> observations;
	
	public RegisterEntry(Encounter encounter){
		Patient patient = encounter.getPatient();
		
		personName = patient.getGivenName();
		gender = patient.getGender();
		dateOfBirth = Format.format(patient.getBirthdate());
		encounterId = encounter.getId() + "";
		encounterDate = Format.format(encounter.getEncounterDatetime());
		encounterLocation = encounter.getLocation().getName();
		observations = new LinkedHashMap<String, String>();
		
		Set<Obs> allObs = encounter.getAllObs();
		for (Obs obs : allObs) {			
			observations.put(obs.getConcept().getName().getName(), obs.getValueAsString(Context.getLocale()));
		}
	}
	
	public String getPersonName() {
		return personName;
	}
	
	public void setPersonName(String personName) {
		this.personName = personName;
	}
	
	public String getEncounterDate() {
		return encounterDate;
	}
	
	public void setEncounterDate(String encounterDate) {
		this.encounterDate = encounterDate;
	}

	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	public String getDateOfBirth() {
		return dateOfBirth;
	}

	public void setDateOfBirth(String dateOfBirth) {
		this.dateOfBirth = dateOfBirth;
	}

	public String getEncounterId() {
		return encounterId;
	}

	public void setEncounterId(String encounterId) {
		this.encounterId = encounterId;
	}

	public String getEncounterLocation() {
		return encounterLocation;
	}

	public void setEncounterLocation(String encounterLocation) {
		this.encounterLocation = encounterLocation;
	}

	public Map<String, String> getObservations() {
		return observations;
	}

	public void setObservations(Map<String, String> observations) {
		this.observations = observations;
	}
}
