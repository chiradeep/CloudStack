<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:if test="${!empty cookie.lang}">
	<fmt:setLocale value="${cookie.lang.value}" />
</c:if>
<fmt:setBundle basename="resources/messages"/>

<script language="javascript">
dictionary = { 	
	'label.action.edit.ISO' : '<fmt:message key="label.action.edit.ISO"/>',
	'label.action.delete.ISO' : '<fmt:message key="label.action.delete.ISO"/>',
	'label.action.delete.ISO.processing' : '<fmt:message key="label.action.delete.ISO.processing"/>',
	'message.action.delete.ISO' : '<fmt:message key="message.action.delete.ISO"/>',
	'message.action.delete.ISO.for.all.zones' : '<fmt:message key="message.action.delete.ISO.for.all.zones"/>',
	'label.action.copy.ISO' : '<fmt:message key="label.action.copy.ISO"/>',
	'label.action.copy.ISO.processing' : '<fmt:message key="label.action.copy.ISO.processing"/>',
	'label.action.create.vm' : '<fmt:message key="label.action.create.vm"/>',
	'label.action.create.vm.processing' : '<fmt:message key="label.action.create.vm.processing"/>',
	'label.action.download.ISO' : '<fmt:message key="label.action.download.ISO"/>',
	'message.download.ISO' : '<fmt:message key="message.download.ISO"/>'	
};	
</script>

<!-- ISO detail panel (begin) -->
<div class="main_title" id="right_panel_header">
    <div class="main_titleicon">
        <img src="images/title_isoicon.gif" /></div>
    <h1>
        <fmt:message key="label.iso"/>
    </h1>
</div>
<div class="contentbox" id="right_panel_content">
    <div class="info_detailbox errorbox" id="after_action_info_container_on_top" style="display: none">
        <p id="after_action_info">
        </p>
    </div>
    <div class="tabbox" style="margin-top: 15px;">
        <div class="content_tabs on">
            <fmt:message key="label.details"/></div>
    </div>
    <div id="tab_content_details">   	
 		<div id="tab_spinning_wheel" class="rightpanel_mainloader_panel" style="display: none;">
            <div class="rightpanel_mainloaderbox">
                <div class="rightpanel_mainloader_animatedicon">
                </div>
                <p>
                    <fmt:message key="label.loading"/> &hellip;</p>
            </div>
        </div>
        <div id="tab_container">
	        <div class="grid_container">
	        	<div class="grid_header">
	            	<div id="grid_header_title" class="grid_header_title">Title</div>
	                <div class="grid_actionbox" id="action_link"><p><fmt:message key="label.actions"/></p>
	                    <div class="grid_actionsdropdown_box" id="action_menu" style="display: none;">
	                        <ul class="actionsdropdown_boxlist" id="action_list">
	                            <li><fmt:message key="label.no.actions"/></li>
	                        </ul>
	                    </div>
	                </div>
	                <div class="gridheader_loaderbox" id="spinning_wheel" style="border: 1px solid #999;
	                display: none;">
	                    <div class="gridheader_loader" id="Div1">
	                    </div>
	                    <p id="description">
	                        <fmt:message key="label.detaching.disk"/> &hellip;</p>
	                </div>       
	            </div>
	            <div class="grid_rows odd">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.id"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="id">
	                    </div>
	                </div>
	            </div>
	            <div class="grid_rows even">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.zone"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="zonename">
	                    </div>
	                </div>
	            </div>
	            
	            <div class="grid_rows odd">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.zone"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="zoneid">
	                    </div>
	                </div>
	            </div>
	            
	            <div class="grid_rows even">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.name"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="name">
	                    </div>
	                    <input class="text" id="name_edit" style="width: 200px; display: none;" type="text" />
	                    <div id="name_edit_errormsg" style="display:none"></div>
	                </div>
	            </div>
	            <div class="grid_rows odd">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.display.text"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="displaytext">
	                    </div>
	                    <input class="text" id="displaytext_edit" style="width: 200px; display: none;" type="text" />
	                    <div id="displaytext_edit_errormsg" style="display:none"></div>
	                </div>
	            </div>
	                 
	            <div class="grid_rows even">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.size"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="size">
	                    </div>
	                </div>
	            </div>        
	            <div class="grid_rows odd">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.bootable"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="bootable">                      
	                    </div>
	                </div>
	            </div>	            	            
	            <div class="grid_rows even">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.public"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="ispublic">                       
	                    </div>	                
	                    <select class="select" id="ispublic_edit" style="width: 202px; display: none;">
	                        <option value="true"><fmt:message key="label.yes"/></option>
							<option value="false"><fmt:message key="label.no"/></option>
	                    </select>	                 
	                </div>
	            </div>	 
	            
	            <div class="grid_rows odd">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.featured"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="isfeatured">                        
	                    </div>
	                    <select class="select" id="isfeatured_edit" style="width: 202px; display: none;">
	                        <option value="true"><fmt:message key="label.yes"/></option>
							<option value="false"><fmt:message key="label.no"/></option>
	                    </select>
	                </div>
	            </div>
	            
	            <div class="grid_rows even">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.cross.zones"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="crossZones">
	                    </div>
	                </div>
	            </div>
				<div class="grid_rows odd">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.os.type"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="ostypename">
	                    </div>
	                    <select class="select" id="ostypename_edit" style="width: 202px; display: none;">                      
	                    </select>
	                </div>
	            </div>
	            <div class="grid_rows even">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.account"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="account">
	                    </div>
	                </div>
	            </div>
				<div class="grid_rows odd">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.domain"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="domain">
	                    </div>
	                </div>
	            </div>
	            <div class="grid_rows even">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.created"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="created">
	                    </div>
	                </div>
	            </div>          
	            <div class="grid_rows odd">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.status"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div class="row_celltitles" id="status">
	                    </div>
	                </div>
	            </div>	         
	            <div class="grid_rows even" id="progressbar_container">
	                <div class="grid_row_cell" style="width: 20%;">
	                    <div class="row_celltitles">
	                        <fmt:message key="label.download.progress"/>:</div>
	                </div>
	                <div class="grid_row_cell" style="width: 79%;">
	                    <div id="progressbar"></div>
	                </div>
	            </div>
	                        
	        </div>        
	        <div class="grid_botactionpanel">
	        	<div class="gridbot_buttons" id="save_button" style="display:none;"><fmt:message key="label.save"/></div>
	            <div class="gridbot_buttons" id="cancel_button" style="display:none;"><fmt:message key="label.cancel"/></div>
	        </div> 
	    </div>
    </div>
</div>
<!-- ISO detail panel (end) -->

<!--  top buttons (begin) -->
<div id="top_buttons">
    <div class="actionpanel_button_wrapper" id="add_iso_button">
        <div class="actionpanel_button">
            <div class="actionpanel_button_icons">
                <img src="images/addvm_actionicon.png" alt="Add ISO" /></div>
            <div class="actionpanel_button_links">
				<fmt:message key="label.add.iso"/>
            </div>
        </div>
    </div>
</div>
<!--  top buttons (end) -->

<!-- Add ISO Dialog (begin) -->
<div id="dialog_add_iso" title='<fmt:message key="label.add.iso"/>' style="display:none">		
	<div class="dialog_formcontent">
		<form action="#" method="post" id="form2">
			<ol>
				<li>
					<label><fmt:message key="label.name"/>:</label>
					<input class="text" type="text" name="add_iso_name" id="add_iso_name" style="width:250px"/>
					<div id="add_iso_name_errormsg" class="dialog_formcontent_errormsg" style="display:none;"></div>
				</li>
				<li>
					<label><fmt:message key="label.display.text"/>:</label>
					<input class="text" type="text" name="add_iso_display_text" id="add_iso_display_text" style="width:250px"/>
					<div id="add_iso_display_text_errormsg" class="dialog_formcontent_errormsg" style="display:none;"></div>
				</li>
				<li>
					<label><fmt:message key="label.url"/>:</label>
					<input class="text" type="text" name="add_iso_url" id="add_iso_url" style="width:250px"/>
					<div id="add_iso_url_errormsg" class="dialog_formcontent_errormsg" style="display:none;"></div>
				</li>				
				<li>
                    <label><fmt:message key="label.zone"/>:</label>
                    <select class="select" id="add_iso_zone">
                    </select>
                </li>	
				<li>
					<label for="add_iso_public"><fmt:message key="label.bootable"/>:</label>
					<select class="select" name="add_iso_bootable" id="add_iso_bootable">
						<option value="true"><fmt:message key="label.yes"/></option>
						<option value="false"><fmt:message key="label.no"/></option>
					</select>
				</li>		
				<li id="add_iso_os_type_container">
					<label for="add_iso_os_type"><fmt:message key="label.os.type"/>:</label>
					<select class="select" name="add_iso_os_type" id="add_iso_os_type">
					</select>
					<div id="add_iso_os_type_errormsg" class="dialog_formcontent_errormsg" style="display: none;"></div>
				</li>						
				<li id="add_iso_public_container" style="display:none">
					<label><fmt:message key="label.public"/>?:</label>
					<select class="select" id="add_iso_public">
						<option value="false"><fmt:message key="label.no"/></option>
						<option value="true"><fmt:message key="label.yes"/></option>						
					</select>
				</li>	
				
				<li id="isfeatured_container" style="display:none">
					<label><fmt:message key="label.featured"/>?:</label>
					<select class="select" id="isfeatured">
					    <option value="false"><fmt:message key="label.no"/></option>
						<option value="true"><fmt:message key="label.yes"/></option>						
					</select>
				</li>
				
			</ol>
		</form>
	</div>
</div>
<!-- Add ISO Dialog (end) -->

<!-- Copy ISO Dialog (begin) -->
<div id="dialog_copy_iso" title='<fmt:message key="label.action.copy.ISO"/>' style="display:none">	
    <p>
	    <fmt:message key="message.copy.iso.confirm"/>:	    
	</p>
	<div class="dialog_formcontent">
		<form action="#" method="post" id="form4">
			<ol>				
				<li>
                    <label><fmt:message key="label.zone"/>:</label>
                    <select class="select" id="copy_iso_zone">  
                        <option value=""></option>                        
                    </select>
                </li>		
				<div id="copy_iso_zone_errormsg" class="dialog_formcontent_errormsg" style="display:none;"></div> 
			</ol>
		</form>
	</div>
</div>
<!--  Copy ISO Dialog (end) -->

<!-- Create VM from ISO (begin) -->
<div id="dialog_create_vm_from_iso" title='<fmt:message key="label.action.create.vm"/>' style="display:none">	
	<div class="dialog_formcontent">
		<form action="#" method="post" id="form5">
			<ol>			   
				<li>
					<label><fmt:message key="label.name"/>:</label>
					<input class="text" type="text" id="name"/>
					<div id="name_errormsg" class="dialog_formcontent_errormsg" style="display:none;"></div>
				</li>
				<li>
					<label><fmt:message key="label.group"/>:</label>
					<input class="text" type="text" id="group"/>
					<div id="group_errormsg" class="dialog_formcontent_errormsg" style="display:none;"></div>
				</li>				
				<li>
                    <label><fmt:message key="label.service.offering"/>:</label>
                    <select class="select" id="service_offering">
                    </select>
                </li>					
				<li>
                    <label><fmt:message key="label.disk.offering"/>:</label>
                    <select class="select" id="disk_offering">
                    </select>
                </li>
                <li id="size_container">
                    <label>
                        <fmt:message key="label.size"/>:</label>
                    <input class="text" type="text" id="size" />
                    <div id="size_errormsg" class="dialog_formcontent_errormsg" style="display: none;">
                    </div>
                </li>    		
                <li>
                    <label><fmt:message key="label.hypervisor"/>:</label>
                    <select class="select" id="hypervisor">
                        <option value='XenServer'>Citrix XenServer</option>
                        <option value='VmWare'>VMware ESX</option>                            
                        <option value='KVM'>KVM</option>
                    </select>     
                </li>						
			</ol>
		</form>
	</div>
</div>

<!-- Download ISO Dialog (begin) -->
<div id="dialog_download_ISO" title='<fmt:message key="label.action.download.ISO"/>' style="display: none">    
   <!--Loading box-->
   <div id="spinning_wheel" class="ui_dialog_loaderbox">
       <div class="ui_dialog_loader">
       </div>
       <p>
           <fmt:message key="label.generating.url"/>....</p>
   </div>
   <!--Confirmation msg box-->
   <!--Note: for error msg, just have to add error besides everything for eg. add error(class) next to ui_dialog_messagebox error, ui_dialog_msgicon error, ui_dialog_messagebox_text error.  -->
   <div id="info_container" class="ui_dialog_messagebox error" style="display: none;">
       <div id="icon" class="ui_dialog_msgicon error">
       </div>
       <div id="info" class="ui_dialog_messagebox_text error">
           (info)</div>
   </div>
</div>
<!-- Download ISO Dialog (end) -->
<!-- Create VM from template/ISO (end) -->

<div id="hidden_container">
    <!-- advanced search popup (begin) -->
    <div class="adv_searchpopup_bg" id="advanced_search_popup" style="display: none;">
        <div class="adv_searchformbox">
            <form action="#" method="post">
            <ol>                
                <li>
                    <select class="select" id="adv_search_zone">
                    </select>
                </li>
                <li id="adv_search_domain_li" style="display: none;">
                    <input class="text textwatermark" type="text" id="domain" value='<fmt:message key="label.by.domain" />' />
                    <div id="domain_errormsg" class="dialog_formcontent_errormsg" style="display: none;">
                    <!--
                    <select class="select" id="adv_search_domain">
                    </select>
                    -->
                </li>
                <li id="adv_search_account_li" style="display: none;">
                    <input class="text textwatermark" type="text" id="adv_search_account" value='<fmt:message key="label.by.account" />' />
                </li>
            </ol>
            </form>
        </div>
    </div>
    <!-- advanced search popup (end) -->
</div>
