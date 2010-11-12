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

import org.springframework.transaction.annotation.Transactional;
import org.openmrs.Encounter;
import org.openmrs.Form;
import org.openmrs.Location;
import org.openmrs.annotation.Authorized;

import org.openmrs.module.register.db.hibernate.Register;
import org.openmrs.module.register.db.hibernate.RegisterType;

import java.util.List;

public interface RegisterService {

	@Transactional(readOnly = true)
	@Authorized( { RegisterConstant.MANAGE_REGISTERS })
	public List<Register> getRegisters();

	@Transactional(readOnly = true)
	@Authorized( { RegisterConstant.MANAGE_REGISTERS })
	public List<Register> getRegisters(boolean includeRetired);

	@Transactional(readOnly = true)
	@Authorized( { RegisterConstant.MANAGE_REGISTERS })
	public Register getRegister(Integer registerId);

	@Transactional
	@Authorized( { RegisterConstant.MANAGE_REGISTERS })
	public Register saveRegister(Register register);

	@Transactional
	@Authorized( { RegisterConstant.MANAGE_REGISTERS })
	public void deleteRegister(Integer registerId);

	@Transactional
	@Authorized( { RegisterConstant.MANAGE_REGISTERS })
	public void deleteRegister(Register register);

	@Transactional(readOnly = true)
	@Authorized( { RegisterConstant.MANAGE_REGISTERS })
	public List<RegisterType> getRegisterTypes();

	@Transactional(readOnly = true)
	@Authorized( { RegisterConstant.MANAGE_REGISTERS })
	public RegisterType getRegisterType(Integer registerTypeId);

	@Transactional(readOnly = true)
	@Authorized( { RegisterConstant.VIEW_REGISTER_ENTRIES })
	public List<Encounter> getEncountersForRegisterByLocation(Integer registerId, Integer locationId, Integer pageSize, Integer page);

	@Transactional(readOnly = true)
	@Authorized( { RegisterConstant.VIEW_REGISTER_ENTRIES })
	public Integer getEncounterCountForRegisterByLocation(Integer registerId, Integer locationId);

	/**
	 * Get all encounters for a given form and location
	 * 
	 * @param form
	 * @param location
	 * @param pageSize
	 * @param page
	 * @return
	 * 
	 * @should get all the encounter with the given form and location id based
	 *         on the pagesize and page
	 * @should get all the encounter with the given form and location id for the
	 *         given page and pagesize with encounterDatetime & date created in
	 *         Ascending order
	 */
	@Transactional(readOnly = true)
	@Authorized( { RegisterConstant.VIEW_REGISTER_ENTRIES })
	public List<Encounter> getEncounters(Form form, Location location, Integer pageSize, Integer page);

	/**
	 * Get the total encounter count for a given form and location
	 * 
	 * @param form
	 * @param location
	 * @return
	 * @should get the total encounter count with the given form and location id
	 */
	@Transactional(readOnly = true)
	@Authorized( { RegisterConstant.VIEW_REGISTER_ENTRIES })
	public Integer getEncounterCount(Form form, Location location);

	@Transactional
	@Authorized( { RegisterConstant.MANAGE_REGISTER_ENTRIES })
	public void deleteEncounter(Integer encounterId);

}
