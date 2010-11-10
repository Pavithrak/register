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
package org.openmrs.module.register.db.hibernate;

import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.SessionFactory;
import org.hibernate.classic.Session;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;
import org.openmrs.Encounter;
import org.openmrs.Form;
import org.openmrs.Location;
import org.openmrs.module.htmlformentry.HtmlForm;
import org.openmrs.module.register.db.RegisterDAO;

public class HibernateRegisterDAO implements RegisterDAO {
	private SessionFactory sessionFactory;

	public void setSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}

	private Session getCurrentSession() {
		return sessionFactory.getCurrentSession();
	}

	@SuppressWarnings("unchecked")
	public List<Register> getRegisters(boolean includeRetired) {
		Criteria criteria = sessionFactory.getCurrentSession().createCriteria(Register.class);
		if(!includeRetired){
			criteria.add(Restrictions.eq("retired", false));
		}
		return criteria.list();
	}

	public Register getRegister(Integer registerId) {
		return (Register) sessionFactory.getCurrentSession().load(Register.class, registerId);
	}

	public Register saveRegister(Register register) {
		HtmlForm htmlForm = register.getHtmlForm();
		if(htmlForm.getId() == null) {
			Form form = htmlForm.getForm();
			if(form.getId() == null) {
				getCurrentSession().save(form);
			}
			getCurrentSession().save(htmlForm);
		}
		
		RegisterType registerType = register.getRegisterType();
		if(registerType.getId() == null) {
			getCurrentSession().save(registerType);
		}
		
		getCurrentSession().saveOrUpdate(register);
		return register;
	}
	
	public void deleteRegister(Register register) {
		getCurrentSession().delete(register);
	}

	@SuppressWarnings("unchecked")
	public List<RegisterType> getRegisterTypes() {
		Criteria criteria = sessionFactory.getCurrentSession().createCriteria(RegisterType.class);
		return criteria.list();
	}

	public RegisterType getRegisterType(Integer id) {
		return (RegisterType) sessionFactory.getCurrentSession().load(RegisterType.class, id);
	}

	/**
	 * @see org.openmrs.module.register.db.RegisterDAO#getEncounters(org.openmrs.Form, org.openmrs.Location, java.lang.Integer, java.lang.Integer)
	 */
	@SuppressWarnings("unchecked")
	@Override
	public List<Encounter> getEncounters(Form form,	Location location, Integer pageSize, Integer page) {
		Criteria criteria = baseEncounterCriteria(form, location);
		criteria.addOrder(Order.asc("encounterDatetime"));
		criteria.addOrder(Order.asc("dateCreated"));
		criteria.setFirstResult((page - 1) * pageSize);
		criteria.setMaxResults(pageSize);
		return criteria.list();
	}

	/**
	 * @see org.openmrs.module.register.db.RegisterDAO#getEncounterCount(org.openmrs.Form, org.openmrs.Location)
	 */
	@Override
	public Integer getEncounterCount(Form form, Location location) {
		Criteria criteria = baseEncounterCriteria(form, location);
		criteria.setProjection(Projections.rowCount());
		return (Integer)criteria.list().get(0);
	}

	@Override
	public void deleteEncounter(Integer encounterId) {
		Session session = sessionFactory.getCurrentSession();
		Encounter encounter = (Encounter) session.load(Encounter.class, encounterId);
		encounter.setVoided(true);
		session.update(encounter);
	}

	private Criteria baseEncounterCriteria(Form form, Location location) {
		Criteria criteria = sessionFactory.getCurrentSession().createCriteria(
				Encounter.class);
		criteria.add(Restrictions.eq("form", form));
		criteria.add(Restrictions.eq("location", location));
		criteria.add(Restrictions.not(Restrictions.eq("voided", true)));
		return criteria;
	}

}
