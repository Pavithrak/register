<%@ include file="/WEB-INF/template/include.jsp"%>
<openmrs:require privilege="View Registers" otherwise="/login.htm" redirect="/module/register/manageRegister.list" />

<spring:message var="pageTitle" code="register.manage.page.title" scope="page"/>

<%@ include file="/WEB-INF/template/header.jsp"%>

<div id="displayAddRegisterEntryPopup">
	<iframe id="displayAddRegisterEntryPopupIframe" width="100%" height="100%" marginWidth="0" marginHeight="0" frameBorder="0" scrolling="auto"></iframe>
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
				modal: true,
				open: function(a, b) {},
				close: function() { showRegisterContent(); }
		});
	});

	function loadUrlIntoAddRegisterEntryPopup(title, urlToLoad) {
		$j("#displayAddRegisterEntryPopupIframe").attr("src", urlToLoad);
		$j('#displayAddRegisterEntryPopup')
			.dialog('option', 'title', title)
			.dialog('option', 'height', '450')
			.dialog('open');
			
		}
</script>

<c:url var="viewRegisterEntryUrl"
	value="/module/register/registerHtmlForm.form">
	<c:param name="registerId" value="${commandMap.map['register'].id}" />
	<c:param name="mode" value="Enter" />
	<c:param name="inPopup" value="true" />
</c:url>


<p>
	<h2>
		${commandMap.map['register'].name}
	</h2>
</p>
<br/>
<c:if test="${not commandMap.map['register'].retired}">
	<openmrs:hasPrivilege privilege="Manage Register Patients">
		
		<openmrs:htmlInclude file="/scripts/dojoConfig.js"></openmrs:htmlInclude>
		<openmrs:htmlInclude file="/scripts/dojo/dojo.js"></openmrs:htmlInclude>
		
		<script type="text/javascript">
			dojo.require("dojo.widget.openmrs.PatientSearch");
			
			dojo.addOnLoad( function() {
				
				searchWidget = dojo.widget.manager.getWidgetById("pSearch");
				dojo.event.topic.subscribe("pSearch/select", 
					function(msg) {
						if (msg.objs[0].patientId){
							var newPatientURL = "${viewRegisterEntryUrl}" + "&patientId="+msg.objs[0].patientId;
							loadUrlIntoAddRegisterEntryPopup('<spring:message code="register.addPatientToRegister" />',newPatientURL);
						}
						else if (msg.objs[0].href)
							document.location = msg.objs[0].href;
					}
				);
				
				<c:if test="${empty hideAddNewPatient}">
					searchWidget.addPatientLink ='<a href="" onClick="loadUrlIntoAddRegisterEntryPopup(\'<spring:message code="register.addPatientToRegister" />\',\'${viewRegisterEntryUrl}\');return false;"><spring:message code="register.addPatientToRegister" /></a>';
				</c:if>
				searchWidget.inputNode.select();
				changeClassProperty("description", "display", "none");
				
			});
			
		</script>
		
		<div id="findPatient">
			<b class="boxHeader"><spring:message code="register.findPatient" />
			</b>
			<div class="box">
				<div dojoType="PatientSearch" widgetId="pSearch"
					showIncludeVoided="false"
					searchLabel="<spring:message code="Patient.searchBox" htmlEscape="true"/>"
					showVerboseListing="false"
					patientId='<request:parameter name="patientId"/>'
					searchPhrase='<request:parameter name="phrase"/>'
					showAddPatientLink='false'
				</div>
			</div>
		</div>
		<br />
		<a href="" onClick="loadUrlIntoAddRegisterEntryPopup('<spring:message code="register.addPatientToRegister" />','${viewRegisterEntryUrl}');return false;"><spring:message code="register.addPatientToRegister" /></a>
		<br />
		<br/>
	</openmrs:hasPrivilege>
</c:if>
<b class="boxHeader">
	<spring:message code="register.location.list.title"/>
</b>
<form method="get" class="box">

	<div id="locationList">
		<table>
			<tr>
				<td>
					<spring:message code="register.location.list.title" />
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
	
	<input type="hidden" id="registerId" value='<c:out value="${param.registerId}"/>'/>
	<input type="hidden" id="htmlFormId" value='<c:out value="${commandMap.map['htmlFormId']}"/>'/>	
	
	<input type="hidden" id="registerCount" value='1'/>	
	<input type="hidden" id="currentPage" value='1'/>	
	<input type="hidden" id="total_pages" value='1'/>	
	
	<br style="clear:both;" />
	<div id="registerContents">
		<table width="100%">
			<tbody id="searchInfoBar" >			
			<tr>
				<td align="left">
			        	Show <select id="noOfItems"   onChange="pageSizeChange();"><option value="2">2</option><option value="5">5</option><option value="10">10</option></select> entries
			        </td>
			        <td align="right">	        	
			        </td>
		        </tr>
	        	</tbody>
       		</table>	
       
        	<h3></h3>
        	
        	<table cellspacing="0" cellpadding="2" style="width: 100%;" class="openmrsSearchTable">
        		<thead id="searchresultheaders">
			</thead>
        		<tbody id="Searchresult">
        		</tbody>
        	</table>
        	
        	<div id="locationBoxNav" class="dataTables_info"></div>
		<div id="searchNav" align="center" style="padding: 15px;">
			<div id='previous'  align="center" class="paginate_enabled_previous" onClick="previousPage();"></div>
			<div id='next'  align="center" class="paginate_disabled_next"  onClick="nextPage();"></div>
		</div>
	</div>
	
</form>

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
	showRegisterContent();	
});


function pageSizeChange(){
	reloadView();
	
}


function togglePaginationButtons(){
	$j('#next').attr("class","paginate_disabled_next");
	if(Number($j('#registerCount').val())<Number($j('#noOfItems').val())){
		$j('#previous').attr("class","paginate_disabled_previous");
	}else{
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

	DWRRegisterService.getRegisterEntriesByLocation($j('#registerId').val(),$j('#locationId').val(),$j('#htmlFormId').val(),$j('#noOfItems').val(),$j('#currentPage').val(),fillDataInTable);
}


function showRegisterContent(){
	if($j('#locationId').val()!=-1){
	$j('#registerContents').show();
	reloadView();
	}else{
		$j('#registerContents').hide();
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
		var value = typeof(registryRowData[key]) == 'undefined' ? "" : registryRowData[key];
	    html += '<td>' + value + '</td>';						    
	}) 	
	return html;
}

function constructRegisterTable(){
	
			var page_index = $j('#currentPage').val();
			var items_per_page = $j('#noOfItems').val();
		       // Get number of elements per pagionation page from form
		       var headerKeys = [];
		       var tableHeaderHtml = "<tr>";
		       headerData = addHeaders(registerEntries['headers']);
		       tableHeaderHtml += headerData['headerHtml'];
		       headerKeys = headerData['headerKeys'];
		       headerData = addHeaders(registerEntries['obsHeaders']);
		       tableHeaderHtml += headerData['headerHtml'];
		       var obsHeaderKeys = headerData['headerKeys'];
		       
		       tableHeaderHtml += '</tr>';
                var newcontent = '';
                
                // Iterate through a selection of the content and build an HTML string
                var rowStyle = "oddRow" ;
                if(items_per_page > 0){
	                for(var i = 0; i < registerEntries['registerViewResults'].length; i++)
	                {
	                	newcontent += '<tr class="'+rowStyle+'">' ;
	                	newcontent += addRegistryRows(headerKeys, registerEntries['registerViewResults'][i]);
	                	newcontent += addRegistryRows(obsHeaderKeys, registerEntries['registerViewResults'][i]['observations']);
	                	newcontent += '</tr>' ;
	                	if(rowStyle == 'oddRow'){
	                    	rowStyle = 'evenRow';
	                	}else{
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
    
           $j(document).ready(showRegisterContent);       

            

</script>
