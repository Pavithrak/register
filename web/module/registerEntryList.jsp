<%@ include file="/WEB-INF/template/include.jsp"%>
<openmrs:require privilege="View Register Entries" otherwise="/login.htm" redirect="/module/register/manageRegister.list" />

<openmrs:htmlInclude file="/moduleResources/htmlformentry/jquery-ui-1.8.2.custom.css" />
<openmrs:htmlInclude file="/moduleResources/htmlformentry/jquery-1.4.2.min.js" />
<openmrs:htmlInclude file="/moduleResources/htmlformentry/jquery-ui-1.8.2.custom.min.js" />
<script type="text/javascript">
	$j = jQuery.noConflict();
</script>
<openmrs:htmlInclude file="/scripts/dojoConfig.js"></openmrs:htmlInclude>
<openmrs:htmlInclude file="/scripts/dojo/dojo.js"></openmrs:htmlInclude>


<spring:message var="pageTitle" code="register.manage.page.title" scope="page" />

<%@ include file="/WEB-INF/template/header.jsp"%>

<div id="displayAddRegisterEntryPopup">
	<iframe id="displayAddRegisterEntryPopupIframe" width="100%" height="100%" marginWidth="0" marginHeight="0" frameBorder="0"	scrolling="auto"></iframe>
</div>

<link href="/openmrs/scripts/jquery/dataTables/css/dataTables.css?v=1.8.0.0" type="text/css" rel="stylesheet" />

<script type="text/javascript">
	$j(document).ready(function() {
		$j('#displayAddRegisterEntryPopup').dialog({
				title: 'dynamic',
				autoOpen: false,
				draggable: true,
				resizable: true,
				closeOnEscape: true,
				width: '95%',
				overlay: { backgroundColor: "#000000", opacity: 0.5 },
				modal: true,
				open: function(a, b) {},
				close: function() { showRegisterContent(); refreshFindPatientDojoWidget();}
		});
	});

	function loadUrlIntoAddRegisterEntryPopup(title, param) {
		var urlToLoad = "/openmrs/module/register/registerHtmlForm.form?closeAfterSubmission=close&inPopup=true&registerId=";

		urlToLoad += $j('#registerId').val();
		if(param){
			urlToLoad = urlToLoad + '&' + param;
		}
		$j("#displayAddRegisterEntryPopupIframe").attr("src", urlToLoad);
		$j('#displayAddRegisterEntryPopup')
			.dialog('option', 'title', title)
			.dialog('option', 'height', '450')
			.dialog('open');
	}
</script>

<br />
<input type="hidden" id="registerCount" value='1' />
<input type="hidden" id="currentPage" value='1' />
<input type="hidden" id="total_pages" value='1' />

<div id="registerLocationPanel">
	<b class="boxHeader"><spring:message code="register.title" /> </b>
	<div class="box">
		<table cellspacing="0" cellpadding="3">
			<tr>
				<th>
					<spring:message code="register.title" />
				</th>
				<td>
					<div id="registerPanel"></div>
				</td>
			</tr>
			<tr>
				<th>
					<spring:message code="register.location.list.title" />
				</th>
				<td>
					<select name="locationId" id="locationId">
						<option value="-1">
							<spring:message code="register.location.select" />
						</option>
						<c:forEach var="location" items="${commandMap.map['locations'] }">
						<option value="${ location.locationId }">${ location.name }</option>
						</c:forEach>
					</select>
				</td>
			</tr>
		</table>
	</div>
</div>
<br />

<div id="resultPanel"  style="display:none">
	<b class="boxHeader"><div id="locationName"></div></b>
	<div id="registerData" class="box">
		<table width="100%">
			<tbody>
				<tr>
					<td align="left">
						Show
						<select id="noOfItems" onChange="pageSizeChange();">
							<option value="2">2</option>
							<option value="5">5</option>
							<option value="10">10</option>
						</select>
						entries
					</td>
				</tr>
			</tbody>
		</table>

        	<table cellspacing="0" cellpadding="2" style="width: 100%;" class="openmrsSearchTable">
			<thead id="searchresultheaders">
			</thead>
			<tbody id="Searchresult">
			</tbody>
		</table>

		<div id="locationBoxNav" class="dataTables_info"></div>
		<div id="searchNav" align="center" style="padding: 15px;">
			<div id='previous' align="center" class="paginate_enabled_previous"	onClick="previousPage();"></div>
			<div id='next' align="center" class="paginate_disabled_next" onClick="nextPage();"></div>
		</div>
	</div>
</div>
<br />

<openmrs:hasPrivilege privilege="Manage Register Entries">

	<script type="text/javascript">
			dojo.require("dojo.widget.openmrs.PatientSearch");
			
			dojo.addOnLoad(refreshFindPatientDojoWidget());
			
			function refreshFindPatientDojoWidget(){			
				searchWidget = dojo.widget.manager.getWidgetById("pSearch");
				clearSearch(searchWidget);
				dojo.event.topic.subscribe("pSearch/select", 
					function(msg) {
						if (msg.objs[0].patientId){
							var param = "mode=Enter&patientId="+msg.objs[0].patientId;
							loadUrlIntoAddRegisterEntryPopup('<spring:message code="register.addPatientToRegister" />',param);
						}
						else if (msg.objs[0].href)
							document.location = msg.objs[0].href;
					}
				);
				
				if(searchWidget){
					<c:if test="${empty hideAddNewPatient}">
						searchWidget.addPatientLink ='<a href="" onClick="loadUrlIntoAddRegisterEntryPopup(\'<spring:message code="register.addPatientToRegister" />\',\'mode=Enter\');return false;"><spring:message code="register.addPatientToRegister" /></a>';
					</c:if>				
					searchWidget.inputNode.select();
				}
				changeClassProperty("description", "display", "none");
			}
			
			function clearSearch(searchWidget){
				if(searchWidget){				
					searchWidget.clearSearch();
				}
				$j('#searchInfoBar').html("");
				$j('#searchPagingBar').html("");
			}
	</script>

	<div id="findPatientPanel"  style="display:none">
		<b class="boxHeader"><spring:message code="register.findPatient" /></b>
		<div class="box">
			<div dojoType="PatientSearch" widgetId="pSearch"
				showIncludeVoided="false"
				searchLabel="<spring:message code="Patient.searchBox" htmlEscape="true"/>"
				showVerboseListing="false"
				patientId='<request:parameter name="patientId"/>'
				searchPhrase='<request:parameter name="phrase"/>'
				showAddPatientLink='false'>
			</div>
	
			<div id="addPatientPanel">
				<table>
					<tr>
						<td>
							or
							<a href=""
								onClick="loadUrlIntoAddRegisterEntryPopup('<spring:message code="register.addPatientToRegister" />','mode=Enter');return false;"><spring:message
									code="register.addPatientToRegister" />
							</a>
						</td>
					</tr>
				</table>
			</div>
		</div>
	</div>
</openmrs:hasPrivilege>

<%@ include file="/WEB-INF/template/footer.jsp"%>
<openmrs:htmlInclude file="/dwr/engine.js" />
<openmrs:htmlInclude file="/dwr/util.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRRegisterService.js" />

<script type="text/javascript">
	var registerEntries = {};
	var local_currentPage = 1;
	var items_per_page = $j('#noOfItems').val();
	var local_total_pages =1;
	
	$j('#locationId').change(function() {
		items_per_page = $j('#noOfItems').val();
		$j('#locationName').html($j('#registerId option:selected').text()+" - "+$j('#locationId option:selected').text());
		showRegisterContent();	
	});
	
	function pageSizeChange(){
		reloadView();
	}
	
	function togglePaginationButtons(){
		$j('#next').attr("class","paginate_disabled_next");
		if(Number($j('#registerCount').val())<Number($j('#noOfItems').val())){
			$j('#previous').attr("class","paginate_disabled_previous");
		}
		else{
			$j('#previous').attr("class","paginate_enabled_previous");
		}
	}
	
	function nextPage() {
		local_currentPage=Number($j('#currentPage').val());
		local_total_pages=Number($j('#total_pages').val());
		if(local_currentPage < local_total_pages){
			$j('#previous').attr("class","paginate_enabled_previous");
			local_currentPage = Number(local_currentPage) + 1;
			$j('#currentPage').val(local_currentPage);		
			reloadViewData();
		}
		if(local_currentPage==local_total_pages){
			$j('#next').attr("class","paginate_disabled_next");
		}
	}
	
	function previousPage() {
		local_currentPage=Number($j('#currentPage').val());
		if(local_currentPage > 1){
			local_currentPage = local_currentPage - 1;
			$j('#currentPage').val(local_currentPage);
			reloadViewData();
			$j('#next').attr("class","paginate_enabled_next");
		}if(local_currentPage==1){
			$j('#previous').attr("class","paginate_disabled_previous");
		}
	}
	
	function reloadEntries(data){
		$j('#registerCount').val(data);
		local_total_pages = Math.ceil( $j('#registerCount').val()/ $j('#noOfItems').val());
		$j('#total_pages').val(local_total_pages);
		$j('#currentPage').val(local_total_pages);
		reloadViewData();
		togglePaginationButtons();
	}
	
	fillDataInTable = function(data){
		registerEntries = data;
		constructRegisterTable();
	}
	
	function reloadView(){
		DWRRegisterService.getRegisterEntryCount($j('#registerId').val(),$j('#locationId').val(),reloadEntries);
	}
	
	function reloadViewData(){
		DWRRegisterService.getRegisterEntriesByLocation($j('#registerId').val(),$j('#locationId').val(),$j('#noOfItems').val(),$j('#currentPage').val(),fillDataInTable);
	}
	
	function deleteEncounter(encounterID) {
		if(confirm('You are about to remove an encounter from this register. Are you sure?')) {
			DWRRegisterService.deleteEncounter(encounterID);
			reloadView();
		}
	}
	
	function showRegisterContent(){
		if($j('#locationId').val()!=-1 && $j('#registerId').val()!=-1){
			showResultPanel();
			showFindPatientPanel();
			reloadView();
		}
		else{
			hideResultPanel();
			hideFindPatientPanel();
		}
	}
	
	function addHeaders(headerRawData){
		headerData = {'headerHtml' : "", 'headerKeys' : []};
	    $j.each(headerRawData, function(key, value){
		   		headerData['headerKeys'][headerData['headerKeys'].length] = key;
		   		headerData['headerHtml'] += '<th>' + value + '</th>';
		    });
		return headerData;
	}
	
	function addRegistryRows(keys, registryRowData){
		var html = "";
		$j.each(keys, function(index, key){
			var value = "";
			if(key == 'edit'){
				var encounterID = registryRowData['encounterId'];
			
				value = '<a href="" onClick="loadUrlIntoAddRegisterEntryPopup(\'<spring:message code="register.edit" />\',\'mode=Edit&encounterId=' + encounterID + '\');return false;">' +  
								'<img src="${pageContext.request.contextPath}/images/edit.gif" title="<spring:message code="general.edit"/>" border="0" align="top" />' +
							'</a>'
			} else if(key == 'delete') {
				var encounterID = registryRowData['encounterId'];
				value = '<input type="image" alt="Delete" title="Delete Encounter From Register" ' + 
					'onclick="deleteEncounter(' + encounterID + ');" ' + 
					'name="delete" ' + 
					'src="${pageContext.request.contextPath}/images/trash.gif">'
			}
			else {
				value = typeof(registryRowData[key]) == 'undefined' ? "" : registryRowData[key];	    	
		    	}						    
			    html += '<td>' + value + '</td>';						    
		}) 	
		return html;
	}
	
	function constructRegisterTable(){
		var page_index = $j('#currentPage').val();
		var items_per_page = $j('#noOfItems').val();
		// Get number of elements per pagionation page from form
     
		var tableHeaderHtml = "<tr> ";
		var headerKeys = [];
		<openmrs:hasPrivilege privilege="Manage Register Entries">
			tableHeaderHtml += "<th> Edit </th> ";     	
			tableHeaderHtml += "<th> Delete </th> ";     	
			headerKeys = headerKeys.concat(["edit", "delete"]);
		</openmrs:hasPrivilege>
		
		headerData = addHeaders(registerEntries['headers']);
		tableHeaderHtml += headerData['headerHtml'];
     		headerKeys = headerKeys.concat(headerData['headerKeys']);
		headerData = addHeaders(registerEntries['obsHeaders']);
		tableHeaderHtml += headerData['headerHtml'];
		var obsHeaderKeys = headerData['headerKeys'];
		
		tableHeaderHtml += '</tr>';
		var newcontent = '';
		
		// Iterate through a selection of the content and build an HTML string
		var rowStyle = "oddRow" ;
		if($j('#registerCount').val() > 0){
			for(var i = 0; i < registerEntries['registerViewResults'].length; i++)
			{
				newcontent += '<tr class="'+rowStyle+'">' ;
				newcontent += addRegistryRows(headerKeys, registerEntries['registerViewResults'][i]);
				newcontent += addRegistryRows(obsHeaderKeys, registerEntries['registerViewResults'][i]['observations']);
				newcontent += '</tr>' ;
				if(rowStyle == 'oddRow'){
			    	rowStyle = 'evenRow';
				}
				else{
					rowStyle = 'oddRow';
				}
			}
		}
		else{
			newcontent += '<tr class="'+rowStyle+'">' + '<td> No records found. </td> </tr>';;
		}
		
		// Replace old content with new content
		$j('#searchresultheaders').html(tableHeaderHtml);
		$j('#Searchresult').html(newcontent);
		if(registerEntries['registerViewResults'] && registerEntries['registerViewResults'].length >0){
			var start_index = ((page_index - 1) * items_per_page) + 1;
			var end_index = ((page_index - 1) * items_per_page)+ registerEntries['registerViewResults'].length;
			$j('#locationBoxNav').html("Viewing <b>" + start_index+ "-" + end_index+ "</b> of <b>" + $j('#registerCount').val() + "</b>");
		}else{
			$j('#locationBoxNav').html("");
		}
		// Prevent click event propagation
		return false;
	}
	    
	function loadRegisterDropdow(){
		var registerCoactiveGroupmboHtml='<select name="registerId" id="registerId" onchange="registerChangeEvent()"><option value="-1"><spring:message code="register.selectRegister" /></option>'
		var activeGroup='';
		var retiredGroup='';
		
		<c:forEach var="register" items="${commandMap.map['registers']}">
			 <c:choose>
			  		<c:when test="${!register.value.retired}">
			  			activeGroup +='<option value="${ register.key }">${ register.value.name }</option>';
			  		</c:when>	
			  		<c:otherwise>
			  			retiredGroup += '<option value="${ register.key }">${ register.value.name }</option>';
			  		</c:otherwise>
			</c:choose>
		</c:forEach>

		if(activeGroup.length>0){
			 registerCoactiveGroupmboHtml =registerCoactiveGroupmboHtml + '<optgroup label="active">'+ activeGroup + '</optgroup>'
		}

		if(retiredGroup.length>0){
			registerCoactiveGroupmboHtml=registerCoactiveGroupmboHtml+ '<optgroup label="retired">' + retiredGroup +'</optgroup>'
		}

		registerCoactiveGroupmboHtml +='</select>';						
		$j('#registerPanel').html(registerCoactiveGroupmboHtml);
	}
	
	function registerChangeEvent(){
		$j('#locationName').html($j('#registerId option:selected').text()+" - "+$j('#locationId option:selected').text());
	    showRegisterContent();
	}	         
	        
	function isActiveRegister(){
     	var label=$j("#registerId option:selected").parents("optgroup").attr("label"); 
		if(label=='active'){
			return true;
		}
		else{
		    return false;
		}
	}
	        
	function  showFindPatientPanel(){
		if($j('#findPatientPanel')){
			if(isActiveRegister()){
				$j('#findPatientPanel').show();
	     		}
			else{
				hideFindPatientPanel();
			}
		}
	}
	
	function  showResultPanel(){
		$j('#resultPanel').show();
	}
	
	function  hideFindPatientPanel(){
		if($j('#findPatientPanel')){
		 	$j('#findPatientPanel').hide();
		}
	}
	
	function  hideResultPanel(){
		$j('#resultPanel').hide();
	}
	        
	$j(document).ready(showRegisterContent);
	loadRegisterDropdow();
</script>