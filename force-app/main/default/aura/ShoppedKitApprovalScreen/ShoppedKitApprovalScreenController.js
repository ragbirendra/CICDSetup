({
    /*
	 * This finction defined column header
	 * and calls getAccounts helper method for column data
	 * editable:'true' will make the column editable
	 * */
    doInit: function (component, event, helper) {
        var numYear = [];
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var currYear = $A.localizationService.formatDate(today, "yyyy");
        numYear.push(parseInt(currYear));
        numYear.push(parseInt(currYear)+1);
        numYear.push(parseInt(currYear)+2);
        console.log("numYear:::"+numYear);
        component.set("v.exportYearList", numYear);
        
        var UsrinfoAction = component.get("c.FetchUserInfo");
        UsrinfoAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            if (state === "SUCCESS") {
                
                var usrRecords = response.getReturnValue();  
                
                if(usrRecords.Is_TAU_Admin__c == true && usrRecords.is_TAU_User__c == false){
                    component.set("v.isTAAdmin", true);
                    component.set("v.isTAUser", false);
                }else  if(usrRecords.is_TAU_User__c == true && usrRecords.Is_TAU_Admin__c == false ){
                    component.set("v.isTAAdmin", false);
                    component.set("v.isTAUser", true);
                }else{
                    // alert('Logged In user should be TAAdmin or TAUser to access this Page');
                    component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_TAUserOrTAAdmin"));
                    component.set("v.openModal",true);
                    component.set("v.isTAAdmin", false);
                    component.set("v.isTAUser", false);
                }
                console.log('success');
            } else {
                console.log('error');
            }
            
        });
        $A.enqueueAction(UsrinfoAction);
        //Call a helper function to initialize the table
        helper.initializeDataTable(component,helper);
        
        //helper.getpickval(component, helper);
    },
    showData:function (component, event, helper) {
        component.set("v.isLoading", true);
        component.set("v.showDataTable",true);
        var selectedProgramName = component.find("programNameid").get("v.value");
        var selectedStatusName = component.find("statusNameid").get("v.value");
        var selectedChannelName = component.find("channelNameid").get("v.value");
        var selectedYearValue = component.find("yrSel").get("v.value");
        
        if(selectedProgramName == 'Select a Program' || selectedStatusName=='Select a Status'|| selectedChannelName =='Select a Business Line'|| selectedYearValue =='selectyear'){
            component.set("v.data", null);
            component.set("v.showDataTable", false);
            component.set("v.isLoading", false);
            //alert('Please Select both Program Name and Status');
            component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ProgramNameStatus"));
            component.set("v.openModal",true);
        }else{
            
            var showDataAction = component.get("c.getFilteredvals");
            
            showDataAction.setParams({
                "selectedProgramName":selectedProgramName,
                "selectedStatusName" :selectedStatusName,
                "selectedChannelName" :selectedChannelName,
                "selectedYearValue" :selectedYearValue
            });
            showDataAction.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                if (state === "SUCCESS") {
                    var filteredData = response.getReturnValue();
                    console.log('getFilteredvals response inside Controller', filteredData);
                    console.log('selectedProgramName inside Controller', selectedProgramName);
                    console.log('selectedStatusName inside Controller', selectedStatusName);
                    if(selectedStatusName=='Rejected'){
                        component.set("v.rejectFlag", true);   
                    }
                    component.set("v.data", filteredData);
                    component.set('v.isAdmComment',true);
                    component.set("v.isLoading", false);
                } else {
                    console.log('error');
                }
                
            });
            $A.enqueueAction(showDataAction);
        }
        var selectedStatusName = component.find("statusNameid").get("v.value");
        var Tauser = component.get("v.isTAUser");
        console.log('selectedStatusName1111',selectedStatusName);
        if(((selectedStatusName == 'Rejected') || (selectedStatusName == 'Loaded') || (selectedStatusName == 'Failed'))){
            component.set('v.tableColumns', [
                {label: 'Program Name', fieldName: 'programName', type: 'text', editable: false, initialWidth: 200},
                {label: 'Status of Approval', fieldName: 'approvalStatus', type: 'picklist',editable: false, initialWidth: 200},
                {label: 'Shoppedkit Name', fieldName: 'shopedkitName', type: 'text',editable: false, initialWidth: 200},
                {label: 'Start Date', fieldName: 'shopkitStartDate', type: 'text',editable: true, initialWidth: 150},
                {label: 'End Date', fieldName: 'shopkitEndDate', type: 'text',editable: true, initialWidth: 150},
                {label: 'SAP Number', fieldName: 'shopkitSAPNumber', type: 'text',editable: false, initialWidth: 100},
                {label: 'Temporary Item Numbers', fieldName: 'shopkitTemporaryItemNumbers',editable: false, type: 'text', initialWidth: 100},
                {label: 'Price', fieldName: 'shopkitPrice', type: 'number',editable: true, initialWidth: 100},
                {label: 'ShoppedkitQty', fieldName: 'shopkitQty', type: 'number',editable: true, initialWidth: 100},
                {label: 'BusinessLine', fieldName: 'businessLine', type: 'text',editable: false, initialWidth: 200}
                //{label: 'comment', fieldName: 'comment', type: 'text',editable: false, initialWidth: 200}
            ]); 
        }else if(((selectedStatusName == 'Approved') || (selectedStatusName == 'Completed') || (selectedStatusName == 'Submitted for Approval'))&& Tauser){
            component.set('v.tableColumns', [
                {label: 'Program Name', fieldName: 'programName', type: 'text', editable: false, initialWidth: 200},
                {label: 'Status of Approval', fieldName: 'approvalStatus', type: 'picklist',editable: false, initialWidth: 200},
                {label: 'Shopedkit Name', fieldName: 'shopedkitName', type: 'text',editable: false, initialWidth: 200},
                {label: 'Start Date', fieldName: 'shopkitStartDate', type: 'text',editable: false, initialWidth: 150},
                {label: 'End Date', fieldName: 'shopkitEndDate', type: 'text',editable: false, initialWidth: 150},
                {label: 'SAP Number', fieldName: 'shopkitSAPNumber', type: 'text',editable: false, initialWidth: 100},
                {label: 'Temporary Item Numbers', fieldName: 'shopkitTemporaryItemNumbers',editable: false, type: 'text', initialWidth: 100},
                {label: 'Price', fieldName: 'shopkitPrice', type: 'number',editable: false,initialWidth: 100},
                {label: 'ShoppedkitQty', fieldName: 'shopkitQty', type: 'number',editable: false, initialWidth: 100},
                {label: 'BusinessLine', fieldName: 'businessLine', type: 'text',editable: false, initialWidth: 200}
                //{label: 'comment', fieldName: 'comment', type: 'text',editable: false, initialWidth: 200}
            ]); 
        }
            else if((selectedStatusName == 'Approved') || (selectedStatusName == 'Completed') || (selectedStatusName == 'Loaded')){
                component.set('v.tableColumns', [
                    {label: 'Program Name', fieldName: 'programName', type: 'text', editable: false, initialWidth: 200},
                    {label: 'Status of Approval', fieldName: 'approvalStatus', type: 'picklist',editable: false, initialWidth: 200},
                    {label: 'Shopedkit Name', fieldName: 'shopedkitName', type: 'text',editable: false, initialWidth: 200},
                    {label: 'Start Date', fieldName: 'shopkitStartDate', type: 'text',editable: false, initialWidth: 150},
                    {label: 'End Date', fieldName: 'shopkitEndDate', type: 'text',editable: false, initialWidth: 150},
                    {label: 'SAP Number', fieldName: 'shopkitSAPNumber', type: 'text',editable: false, initialWidth: 100},
                    {label: 'Temporary Item Numbers', fieldName: 'shopkitTemporaryItemNumbers',editable: false, type: 'text', initialWidth: 100},
                    {label: 'Price', fieldName: 'shopkitPrice', type: 'number',editable: false,initialWidth: 100},
                    {label: 'ShoppedkitQty', fieldName: 'shopkitQty', type: 'number',editable: false, initialWidth: 100},
                    {label: 'BusinessLine', fieldName: 'businessLine', type: 'text',editable: false, initialWidth: 200}
                    // {label: 'comment', fieldName: 'comment', type: 'text',editable: false, initialWidth: 200}
                ]); 
            } 
                else if((selectedStatusName == 'Submitted for Approval')){
                    component.set('v.tableColumns', [
                        {label: 'Program Name', fieldName: 'programName', type: 'text',editable: false, initialWidth: 200},
                        {label: 'Status of Approval', fieldName: 'approvalStatus', type: 'picklist',editable: false, initialWidth: 200},
                        {label: 'Shopedkit Name', fieldName: 'shopedkitName', type: 'text',editable: false, initialWidth: 200},
                        {label: 'Start Date', fieldName: 'shopkitStartDate', type: 'text',editable: false, initialWidth: 150},
                        {label: 'End Date', fieldName: 'shopkitEndDate', type: 'text',editable: false, initialWidth: 150},
                        {label: 'SAP Number', fieldName: 'shopkitSAPNumber', type: 'text',editable: false, initialWidth: 100},
                        {label: 'Temporary Item Numbers', fieldName: 'shopkitTemporaryItemNumbers',editable: false, type: 'text', initialWidth: 100},
                        {label: 'Price', fieldName: 'shopkitPrice', type: 'number',editable: false,initialWidth: 100},
                        {label: 'ShoppedkitQty', fieldName: 'shopkitQty', type: 'number',editable: false, initialWidth: 100},
                        {label: 'BusinessLine', fieldName: 'businessLine', type: 'text',editable: false, initialWidth: 200}
                        // {label: 'comment', fieldName: 'comment', type: 'text',editable: true, initialWidth: 200}
                    ]); 
                } 
        
        component.set("v.approveFlag",false); 
        component.set("v.rejectFlag",false);
    },
    
    hideSpinner: function (cmp) {
        
        cmp.set("v.isLoading", false);
        
    },
    onChannelChange: function (component, event, helper) {
        var allData = component.get("v.allData");	
        var channel = component.get("v.businessLine");
        var channelSelectedList = [];
        console.log('channel',channel);
        console.log('allData--',allData);
        if( channel != 'Select a Business Line'){
            for (var i = 0; i < allData.length; i++) {
                if(channel == allData[i].businessLine )
                    channelSelectedList.push(allData[i]);
            }
        }
        var lookup = {};
        var uniqueProgramName = [];
        var uniqueStatusLst = [];
        console.log('channelSelectedList',channelSelectedList);
        if( channel != 'Select a Business Line'){
            for (var i = 0; i < channelSelectedList.length; i++) {
                var programNameUnique = channelSelectedList[i].programName;
                var statusNameUnique = channelSelectedList[i].approvalStatus;
                if (!(programNameUnique in lookup)) {
                    lookup[programNameUnique] = 1;
                    uniqueProgramName.push(programNameUnique);
                    
                }
                if (!(statusNameUnique in lookup)) {
                    lookup[statusNameUnique] = 1;
                    uniqueStatusLst.push(statusNameUnique);
                }
            }
            component.set("v.ProgramLst", uniqueProgramName);
            component.set("v.StatusLst", uniqueStatusLst); 
            
        }else{
            alert('Please Select Valid Business Line');
        }
        
    },
    onProgramChange: function (component, event, helper) {
        var channel = component.get("v.businessLine");
        if(channel == 'Select a Business Line'){
            component.set("v.msgToPass" ,'Please select a value for Business Line!' );
            component.set("v.openModal",true);          
            return;
        }
        component.set("v.totalPages", 1);
        var selectedProgramName = component.find("programNameid").get("v.value");
        console.log('selectedProgramName', selectedProgramName);
       // helper.filterProgramResult(component, event, helper, selectedProgramName);
        var allRecords = component.get("v.allData");
        var filteredProgramLst = [];
        var sortedStatusLst = [];
        var selectedProgramName = component.find("programNameid").get("v.value");
        var selectedStatusName = component.find("statusNameid").get("v.value");
        var selectedBusinessLine = component.find("channelNameid").get("v.value");
        var selectedBudgetYear = component.find("yrSel").get("v.value");
        var uniqueStatusLst = [];
        var uniqueYearLst = [];
        var lookup = {};
        for(var i=0;i<allRecords.length;i++){
            if(allRecords[i].programName ==selectedProgramName && allRecords[i].businessLine ==selectedBusinessLine  
               && allRecords[i].Year ==selectedBudgetYear  ){
                var statusNameUnique = allRecords[i].approvalStatus;
                console.log('statusNameUnique',statusNameUnique);
                if (!(statusNameUnique in lookup)) {
                    lookup[statusNameUnique] = 1;
                    uniqueStatusLst.push(statusNameUnique);
                }
               
            }
        }
        component.set("v.StatusLst", uniqueStatusLst); 
    },
    
    
    onYearChange: function (component, event, helper) {
        component.set('v.data',[]);
        component.set("v.businessLine",'Select a Business Line');
        var allData = component.get("v.allData");	
        var SelYear = component.get("v.selectedYr");
        var yearSelectedList = [];
        
        if( SelYear != 'selectyear'){
            for (var i = 0; i < allData.length; i++) {
                if(SelYear == allData[i].Year )
                    yearSelectedList.push(allData[i]);
            }
        }
        var lookup = {};
        var uniqueProgramName = [];
        var uniqueStatusLst = [];
        
        if( SelYear != 'selectyear'){
            for (var i = 0; i < yearSelectedList.length; i++) {
                var programNameUnique = yearSelectedList[i].programName;
                var statusNameUnique = yearSelectedList[i].approvalStatus;
                if (!(programNameUnique in lookup)) {
                    lookup[programNameUnique] = 1;
                    uniqueProgramName.push(programNameUnique);
                    
                }
                if (!(statusNameUnique in lookup)) {
                    lookup[statusNameUnique] = 1;
                    uniqueStatusLst.push(statusNameUnique);
                }
            }
            component.set("v.ProgramLst", uniqueProgramName);
            component.set("v.StatusLst", uniqueStatusLst); 
            
        }else{
            alert('Please Select Valid Business Line');
        }
        
    },
    SubmitForApproval: function (component, event, helper) {
        var selectedProgram = component.find("programNameid").get("v.value");
        var selectedStatus = component.find("statusNameid").get("v.value");
        var selectedChannelName = component.find("channelNameid").get("v.value");
        var selectedYearValue = component.find("yrSel").get("v.value");
        
        var action = component.get("c.ApproveRecords");
        action.setParams({
            "selectedProgramName": selectedProgram,
            "selectedStatusName": selectedStatus,
            "selectedChannelName":selectedChannelName,
            "selectedYearValue":selectedYearValue
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // alert('Mail sent successfully for Approval');
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApprovalLabel"));
                component.set("v.openModal",true);
                console.log('success');
                
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //alert(''+errors[0].message);
                        component.set("v.msgToPass" ,''+errors[0].message );
                        component.set("v.openModal",true);
                    }
                } 
            }
            
        });
        $A.enqueueAction(action);
        
    },
    Approve: function (component, event, helper) {
        var selectedStatus = component.find("statusNameid").get("v.value");
        var selectedProgram = component.find("programNameid").get("v.value");
        var selectedChannelName = component.find("channelNameid").get("v.value");
        var selectedYearName = component.find("yrSel").get("v.value");
        var approveAction = component.get("c.recordsApproval");
        
        approveAction.setParams({
            "selectedProgramName": selectedProgram,
            "selectedStatusName": selectedStatus,
            "selectedChannelName":selectedChannelName,
            "selectedYearName":selectedYearName,
        });
        approveAction.setCallback(this, function (response) {
            var state = response.getState();
            
            // console.log('****State***'+state);
            if (state === "SUCCESS") {
                
                // alert('Record Approved');
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_PushToPOCPOnApproval"));
                component.set("v.openModal",true);
                
            } else {
                // alert('Unable to Approve');
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApexSideError"));
                component.set("v.openModal",true);
            }
        });
        $A.enqueueAction(approveAction);
        component.set("v.approveFlag",true); 
        component.set("v.rejectFlag",true);
        
    },
    Reject: function (component, event, helper) {
        var selectedStatus = component.find("statusNameid").get("v.value");
        var selectedProgram = component.find("programNameid").get("v.value");
        var commentArea =component.find("adminComment").get("v.value");
        var selectedChannelName = component.find("channelNameid").get("v.value");
        var selectedYearValue = component.find("yrSel").get("v.value");
        
        if(commentArea == undefined || commentArea==null){   
            //alert("please enter rejection comments in comment section");
            component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_RejectionComment"));
            component.set("v.openModal",true);
            return;
        }
        else{
            component.set("v.reasonForRejection" , commentArea);
            var rejectAction = component.get("c.recordsRejection");
            
            rejectAction.setParams({
                "selectedProgramName": selectedProgram,
                "selectedStatusName": selectedStatus,
                "selectedChannelName":selectedChannelName,
                "selectedYearValue":selectedYearValue,
                "comments" :commentArea ,
                "ids":null
            });
            
            rejectAction.setCallback(this, function (response) {
                var state = response.getState();
                
                // console.log('****State***'+state);
                if (state === "SUCCESS") {
                    //alert('Selected Shopped Kit Program gets Rejected');
                    component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ShopkitRejected"));
                    component.set("v.openModal",true);
                    console.log('success');
                    
                } else {
                    //alert('Unable to Reject the record');
                    component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ServerError"));
                    component.set("v.openModal",true);
                }
            });
            $A.enqueueAction(rejectAction);
            component.set("v.approveFlag",true); 
            component.set("v.rejectFlag",true);
        } 
    },
    
    SubmitToOnplan: function (component, event, helper) {
        console.log('****Inside SubmitToOnplan***');
        var currentList = component.get('v.data');
        
        console.log('****currentList*****', currentList);
        var recordIds = [];
        for (var i = 0; i < currentList.length; i++) {
            recordIds.push(currentList[i].recordId);
        }
        
        var serverAction = component.get("c.PushToOnPlan");
        serverAction.setParams({
            "IdList": recordIds
        });
        
        serverAction.setCallback(this, function (response) {
            var state = response.getState();
            console.log('****State***' + state);
            if (state === "SUCCESS") {
                //alert('Shopped Kit Item Successfully pushed to POC Planning');
                component.set("v.msgToPass" ,$A.get("$Label.c.Items_Successfully_pushed_to_POCP"));
                component.set("v.openModal",true);
                console.log('success');
                
            } else {
                //alert('Error. Please try again or contact your admin!');
                //component.set("v.msgToPass" ,'Error. Please try again or contact your admin!' );
                //component.set("v.openModal",true);
                //console.log('**error**');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //alert(''+errors[0].message);
                        component.set("v.msgToPass" ,''+$A.get("$Label.c.ABI_OP_FailedToPush")+errors[0].message );
                        component.set("v.openModal",true);
                    }
                } 
            }
        });
        $A.enqueueAction(serverAction);
        
    },
    clear:function(component , event , helper){
        location.reload();
    },
    onSave: function (component, event, helper) {
        helper.onSaveRejectLoadedFailedRecord(component,event, helper);
    },
    ExportShoppedKit:function(component , event , helper){
        helper.exportShoppedKitData(component, event, helper);
        
    }
    
    
})