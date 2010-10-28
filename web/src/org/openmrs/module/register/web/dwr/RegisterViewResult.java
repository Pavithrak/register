package org.openmrs.module.register.web.dwr;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;

public class RegisterViewResult {
	
	private Map<String, String> headers;
	private Map<String, String> obsHeaders;
	private List<RegisterEntry> registerViewResults;
	
	public RegisterViewResult(){
		headers = new LinkedHashMap<String, String>();
		obsHeaders = new LinkedHashMap<String, String>();
		registerViewResults = new Vector<RegisterEntry>();
	}
	
	public void addRegisterViewResult(RegisterEntry registerViewResult){
		registerViewResults.add(registerViewResult);
	}
	
	public Map<String, String> getHeaders() {		
		return headers;
	}
	
	public void addHeader(String key, String Value) {
		headers.put(key, Value);
	}

	public List<RegisterEntry> getRegisterViewResults() {
		return registerViewResults;
	}

	public void setRegisterViewResults(List<RegisterEntry> registerViewResults) {
		this.registerViewResults = registerViewResults;
	}

	public void addObsHeader(String key, String Value) {
		obsHeaders.put(key, Value);
	}

	public Map<String, String> getObsHeaders() {
		return obsHeaders;
	}
}
