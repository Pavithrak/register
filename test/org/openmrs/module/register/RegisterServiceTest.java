/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.register;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.util.List;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.openmrs.Encounter;
import org.openmrs.api.EncounterService;
import org.openmrs.api.FormService;
import org.openmrs.api.LocationService;
import org.openmrs.api.context.Context;
import org.openmrs.module.htmlformentry.HtmlForm;
import org.openmrs.module.register.db.hibernate.Register;
import org.openmrs.module.register.db.hibernate.RegisterType;
import org.openmrs.test.BaseContextSensitiveTest;
import org.openmrs.test.BaseModuleContextSensitiveTest;
import org.openmrs.test.Verifies;

public class RegisterServiceTest extends BaseModuleContextSensitiveTest {

    protected static final String INITIAL_DATA_XML = "resources/org/openmrs/module/register/RegisterServiceTest-initialData.xml";
    private RegisterService service;

    /**
     * Run this before each unit test in this class. This adds a bit more data to the base data that
     * is done in the "@Before" method in {@link BaseContextSensitiveTest} (which is run right
     * before this method).
     *
     * @throws Exception
     */
    @Before
    public void runBeforeEachTest() throws Exception {
        executeDataSet(INITIAL_DATA_XML);
        service = Context.getService(RegisterService.class);
    }

    @Test
    public void shouldReturnAllRegisters() {
        List<Register> registers = service.getRegisters(true);
        assertEquals(2, registers.size());
    }

    @Test
    public void shouldCreateARegister() throws Exception {
        HtmlForm htmlForm = new HtmlForm();
        RegisterType registerType = new RegisterType();
        Register register = new Register();

        register.setName("register");
        register.setHtmlForm(htmlForm);
        register.setRegisterType(registerType);

        service.saveRegister(register);
        Assert.assertNotNull(register.getId());
    }

    @Test
    public void shouldNotReturnRetiredRegisters() {
        List<Register> registers = service.getRegisters(false);
        assertEquals(1, registers.size());
        for (Register register : registers) {
            assertFalse(register.getRetired());
        }
    }

    @Test
    public void shouldReturnRegistersGivenARegisterId() {
        Register register = service.getRegister(112);
        assertEquals("Sample Visit register2", register.getName());
    }

    @Test
    public void shouldDeleteAGivenRegisterId() {
        service.deleteRegister(111);
        List<Register> registerList = service.getRegisters(true);
        for (Register register : registerList) {
            if (111 == register.getId()) {
                fail();
            }
        }
    }

    @Test
    public void shouldReturnRegisterTypes() {
        List<RegisterType> registerTypes = service.getRegisterTypes();
        assertEquals(2,registerTypes.size());
    }

    @Test
    public void shouldReturnRegisterTypeGivenItsId() {
        RegisterType registerType = service.getRegisterType(101);
        assertEquals(101,registerType.getId().intValue());
    }

    @Test
    public void shouldReturnTheCorrespondingEncounters() {
        List<Encounter> encounters = service.getEncountersForRegisterByLocation(111, 1,2,1);
        assertEquals(2,encounters.size());
    }

	@Test
	@Verifies(value = "should get all the encounter with the given form and location id for the given page and pagesize", method = "getEncounters(Form, Location)")
	public void getEncounters_shouldGetAllTheEncountersWithTheGivenFormAndLocationId()
			throws Exception {
		
		FormService formService = Context.getFormService();
		LocationService locService = Context.getLocationService();
		
		List<Encounter> encountersPage1 = service.getEncounters(formService.getForm(1), locService.getLocation(1), 2, 1);
		assertEquals(2, encountersPage1.size());
		
		List<Encounter> encountersPage2 = service.getEncounters(formService.getForm(1), locService.getLocation(1), 2, 2);
		assertEquals(2, encountersPage2.size());

		List<Encounter> encountersPage3 = service.getEncounters(formService.getForm(1), locService.getLocation(1), 2, 3);
		assertEquals(1, encountersPage3.size());

	}
	
	@Test
	@Verifies(value = "should get all the encounter with the given form and location id for the given page and pagesize with encounterDatetime & date created in Ascending order", method = "getEncounters(Form, Location)")
	public void getEncounters_shouldGetAllTheEncountersWithTheGivenFormAndLocationIdForGivenPageAndPageSizeWithEncounterDateAndDateCreatedInAscOrder()
			throws Exception {		
		FormService formService = Context.getFormService();
		LocationService locService = Context.getLocationService();
		
		List<Encounter> encountersPage1 = service.getEncounters(formService.getForm(1), locService.getLocation(1), 5, 1);
		assertEquals(5, encountersPage1.size());
			
		for(int i=0;i<encountersPage1.size()-1;i++){
			assertTrue(encountersPage1.get(i).getEncounterDatetime().before(encountersPage1.get(i+1).getEncounterDatetime()));
		}

	}
	
	@Test
	@Verifies(value = "should get the total  encounter count with the given form and location id ", method = "getEncounterCount(Form, Location)")
	public void getEncounterCount_shouldGetTotalEncounterCountWithTheGivenFormAndLocationId()
			throws Exception {
		FormService formService = Context.getFormService();
		LocationService locService = Context.getLocationService();
		Integer encounterCount = service.getEncounterCount(formService.getForm(1), locService.getLocation(1));
		assertEquals(5, encounterCount.intValue());
	}
}
