<openmrs:htmlInclude file="/moduleResources/htmlformentry/jquery-ui-1.8.2.custom.css" />
<openmrs:htmlInclude file="/moduleResources/htmlformentry/jquery-1.4.2.min.js" />
<openmrs:htmlInclude file="/moduleResources/htmlformentry/jquery-ui-1.8.2.custom.min.js" />
<script type="text/javascript">
	$j = jQuery.noConflict();
</script>

<ul id="menu">
	<li class="first">
		<a href="${pageContext.request.contextPath}/admin"><spring:message
				code="admin.title.short" />
		</a>
	</li>
	<openmrs:hasPrivilege privilege="Manage Registers">
		<li
			<c:if test='<%= request.getRequestURI().contains("module/register/manageRegisterList") %>'>class="active"</c:if>>
			<a
				href="${pageContext.request.contextPath}/module/register/manageRegister.list">
				<spring:message code="register.manage.link" /> </a>
		</li>
	</openmrs:hasPrivilege>
</ul>