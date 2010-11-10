<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="View Registers" otherwise="/login.htm" redirect="/module/register/manageRegister.list"/>

<spring:message var="pageTitle" code="register.manage.page.title" scope="page"/>

<%@ include file="/WEB-INF/template/header.jsp" %>
<%@ include file="localHeader.jsp" %>


<p>

<h2>
    <spring:message code="register.management"/>
</h2>
</p>

<openmrs:hasPrivilege privilege="Manage Registers">
    <a href="register.form"><spring:message code="register.create.link"/></a>
</openmrs:hasPrivilege>

<br/>
<br/>

<b class="boxHeader">
    <a style="display: block; float: right"
       href="#"
       onClick="return toggleRowVisibilityForClass('registerTable', 'retired', false);">
        <spring:message code="register.toggle.retired"/>
    </a>
    <spring:message code="register.list.title"/>
</b>

<form method="post" class="box" id="target">
    <table id="registerTable" cellspacing="5">
        <tr>
            <th><spring:message code="general.name"/></th>
            <th><spring:message code="general.description"/></th>
            <th><spring:message code="register.type"/></th>
            <th><spring:message code="register.htmlform"/></th>
        </tr>
        <c:forEach var="register" items="${registers}">
            <tr
            <c:if test="${register.retired}">class="retired"</c:if>>
            <td valign="top">
                <openmrs:hasPrivilege privilege="Manage Registers">
                    <a href="register.form?registerId=${register.registerId}">${register.name}</a>
                </openmrs:hasPrivilege>
                <openmrs:hasPrivilege privilege="Manage Registers" inverse="true">
                    ${register.name}
                </openmrs:hasPrivilege>
                (${register.registerId})
            </td>
            <td valign="top">${register.description}</td>
            <td valign="top">${register.registerType.name}</td>
            <td valign="top">${register.htmlForm.name}</td>
            </tr>
        </c:forEach>
    </table>
</form>

<script type="text/javascript">
    toggleRowVisibilityForClass("registerTable", "retired", false);
</script>

<%@ include file="/WEB-INF/template/footer.jsp" %>

