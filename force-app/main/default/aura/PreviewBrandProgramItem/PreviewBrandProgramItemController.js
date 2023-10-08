({
    /*
	 * This finction defined column header
	 * and calls getAccounts helper method for column data
	 * editable:'true' will make the column editable
	 * */
    doInit: function (component, event, helper) {
       var UsrinfoAction = component.get("c.FetchUserInfo");
        UsrinfoAction.setCallback(this, function (response) {
            
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        component.set("v.msgToPass" ,errors[0].message);
                        component.set("v.openModal",true);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            if (state === "SUCCESS") {
                var usrRecords = response.getReturnValue();  
                var numYear = [];
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                var currYear = $A.localizationService.formatDate(today, "yyyy");
                numYear.push(parseInt(currYear));
                numYear.push(parseInt(currYear)+1);
                numYear.push(parseInt(currYear)+2);
                console.log("numYear:::"+numYear);
                
                component.set("v.YearLst", numYear);
                console.log('FetchUserInfo',usrRecords);
                if(usrRecords.Is_TAU_Admin__c == true && usrRecords.is_TAU_User__c == false){
                    component.set("v.isTAAdmin", true);
                    component.set("v.isTAUser", false);
                    console.log('FetchUserInfo1',usrRecords);
                }else  if(usrRecords.is_TAU_User__c == true && usrRecords.Is_TAU_Admin__c == false ){
                    component.set("v.isTAAdmin", false);
                    component.set("v.isTAUser", true);
                    console.log('FetchUserInfo2',usrRecords);
                }else{
                    component.set("v.isTAAdmin", false);
                    component.set("v.isTAUser", false);
                    console.log('FetchUserInfo3',usrRecords);
                    //alert('User should be TAU Admin or TAU user to have complete access to this page');
                    component.set("v.msgToPass" ,'User should be TAU Admin or TAU user to have complete access to this page');
                    component.set("v.openModal",true);
                }
                console.log('success');
            } else {
                console.log('error');
            }
            
        });
        $A.enqueueAction(UsrinfoAction);
        //Call a helper function to initialize the table
        helper.initializeDataTable(component,helper);// pageNumber, pageRecordsDisplayed);
       
    },
    
    showData:function (component, event, helper) {
        component.set('v.disableReject',false);
        component.set("v.disableApprove",false); 
        var selectedProgramName = component.find("programNameid").get("v.value");
        var selectedStatusName = component.find("statusNameid").get("v.value");
        console.log('selectedStatusName11'+selectedStatusName);
        var selectedBusinessLine = component.find("businessLineId").get("v.value");
        var selectedBudgetYear = component.find("budgetYearid").get("v.value");
        component.set("v.selectedStatus",selectedStatusName);
        if(selectedStatusName === 'Approved'){
           component.set("v.disableReject",true);
        
        }
        component.set("v.isLoading", true);
        component.set("v.showDataTable",true);
        if(selectedProgramName == 'Select a Program' || selectedStatusName=='Select a Status' ||
           selectedBusinessLine =='Select a Business Line' || selectedBudgetYear == 'Select Budget Year'){
            component.set("v.data", null);
            component.set("v.showDataTable", false);
            component.set("v.isLoading", false);
            component.set("v.msgToPass" ,'Please Select all the values. Program Name, Status,Year and Business Line.' );
            component.set("v.openModal",true);
        }else if(!(selectedProgramName == 'Select a Program' ||selectedStatusName =='Select a Status' ||
                   selectedBusinessLine=='Select a Business Line' ||selectedBudgetYear == 'Select Budget Year' )){
            var showDataAction = component.get("c.getFilteredvals");
            showDataAction.setParams({
                "selectedProgramName":selectedProgramName,
                "selectedStatusName" :selectedStatusName,
                "selectedBusinessLine" :selectedBusinessLine,
                "selectedBudgetYear" :selectedBudgetYear
            });
            showDataAction.setCallback(this, function (response) {
                var state = response.getState();
                var res = response.getReturnValue();
                console.log('res11',res);
                if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                            component.set("v.msgToPass" ,errors[0].message);
                            component.set("v.openModal",true);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                if (state === "SUCCESS") {
                    var filteredData = response.getReturnValue();
                    console.log('filteredData',filteredData);
                    if(filteredData.length > 0){
                        component.set("v.isLoading", false);
                        var errorIndex = [];
                        var errorIndexNullImg = [];
                        var allListVals = [];
                        for(var i=0;i< filteredData.length;i++){
                            if(filteredData[i].ImageLink != null ){
                                if(filteredData[i].ImageLink.includes(null) ){
                                    errorIndex.push(i+1);
                                }
                            }else{
                                errorIndexNullImg.push(i+1)
                                console.log('no image link found');
                            }
                            
                            var date = filteredData[i].ProgramStartDate;
                            var yourdate = date.split("-").reverse();
                            var tmp = yourdate[0];
                            yourdate[0] = yourdate[1];
                            yourdate[1] = tmp;
                            filteredData[i].ProgramStartDate = yourdate.join("/");
                            
                            var date1 = filteredData[i].ProgramEndDate;
                            var yourdate = date1.split("-").reverse();
                            var tmp = yourdate[0];
                            yourdate[0] = yourdate[1];
                            yourdate[1] = tmp;
                            filteredData[i].ProgramEndDate = yourdate.join("/");
                            
                            var date = filteredData[i].PlanningStartDate;
                            var yourdate = date.split("-").reverse();
                            var tmp = yourdate[0];
                            yourdate[0] = yourdate[1];
                            yourdate[1] = tmp;
                            filteredData[i].PlanningStartDate = yourdate.join("/");
                            
                            var date = filteredData[i].PlanningEndDate;
                            var yourdate = date.split("-").reverse();
                            var tmp = yourdate[0];
                            yourdate[0] = yourdate[1];
                            yourdate[1] = tmp;
                            filteredData[i].PlanningEndDate = yourdate.join("/");
                            
                            allListVals.push(filteredData[i]); 
                        }
                        component.set("v.data", allListVals);
                        component.set("v.incorrectImageLink",errorIndex);
                        component.set('v.noImageLink',errorIndexNullImg);
                        //component.set('v.disableReject',false);
                        
                        component.set('v.isAdmComment',true);
                        console.log('errorIndex',errorIndex);
                        console.log('errorIndexNullImg',errorIndexNullImg)
                    }else{
                        //alert('No Data Found');
                        component.set("v.msgToPass" ,'No Data Found' );
                        component.set("v.openModal",true);
                        component.set("v.isLoading", false);
                        component.set("v.showDataTable", false);
                        
                    }
                } else {
                    console.log('error');
                }
                
            });
            $A.enqueueAction(showDataAction);
        }
        
        
    },
    saveChanges:  function (component, event, helper) {
        component.set("v.isLoading",true);
        
        helper.saveTAUserChanges(component,event,helper);   
        // component.set("v.isLoading",false);
    },
    
    onNext: function (component, event, helper) {
        // debugger;
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber + 1);
        helper.buildData(component, helper);
    },
    
    
    onPrev: function (component, event, helper) {
        // debugger;
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber - 1);
        helper.buildData(component, helper);
    },
    
    
    processMe: function (component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper);
    },
    
    
    onFirst: function (component, event, helper) {
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
    },
    
    
    onLast: function (component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
    },
    onChannelChange: function (component, event, helper) {
        component.set("v.ProgramLst",'Select a Program');
        component.set("v.programNamePL",'Select a Program');
        component.set("v.StatusLst",'Select a Status');
        component.set("v.statusOptionValue",'Select a Status');
        
        var channelSelectedList = component.get("v.allData");	
        var channel = component.get("v.businessLine");
        var selectedBudgetYear = component.find("budgetYearid").get("v.value");
       
        var lookup = {};
        var uniqueProgramName = [];
        var uniqueStatusLst = [];
        var uniqueYearLst = [];
        // console.log('channelSelectedList',channelSelectedList);
        if(channelSelectedList.length > 0){
            for (var i = 0; i < channelSelectedList.length; i++) {
                if(selectedBudgetYear == channelSelectedList[i].Year 
                   && channel == channelSelectedList[i].BusinessLine){
                    var programNameUnique = channelSelectedList[i].programName;
                    var statusNameUnique = channelSelectedList[i].Status;
                    if (!(programNameUnique in lookup)) {
                        lookup[programNameUnique] = 1;
                        uniqueProgramName.push(programNameUnique);
                    }
                    if (!(statusNameUnique in lookup)) {
                        lookup[statusNameUnique] = 1;
                        uniqueStatusLst.push(statusNameUnique);
                    }
                }
                                
             }
            component.set("v.ProgramLst", uniqueProgramName);
            component.set("v.StatusLst", uniqueStatusLst); 
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
        helper.filterProgramResult(component, event, helper, selectedProgramName);
        // helper.buildData(component, helper);
    },
    onStatusChange: function (component, event, helper) {
        var selectedStatusName = component.find("statusNameid").get("v.value");
        var selectedProgramName = component.find("programNameid").get("v.value");
        console.log('selectedStatusName'+selectedStatusName +'----selectedProgramName----'+selectedProgramName);
        //console.log('selectedStatusName', selectedStatusName);
        if(selectedStatusName =='Approved'){
            component.set('v.disableReject',true);
        }
        if(selectedStatusName =='Rejected'){
           
            component.set('v.disableReject',true);
            component.set('v.enablePOC',true);
        }
        
        if(selectedStatusName =='Loaded'){
            component.set('v.disableReject',false);
            component.set('v.enablePOC',true);
            component.set('v.isAdmComment',false);
        }
        
        if(component.get("v.statusOptionValue") =='Loaded'){
            component.set('v.isAdmComment',false);
        }
        //helper.filterStatusResult(component, event, helper, selectedStatusName, selectedProgramName);
        //helper.buildData(component, helper);
    }, 
    onYearChange: function(component, event, helper) {
       // component.set("v.StatusLst",'Select a Status' ); 
        component.set("v.ProgramLst",'Select a Program');
        component.set("v.programNamePL",'Select a Program');
        component.set("v.data",[]);
        component.set("v.channelLst",'Select a Business Line' );
        component.set("v.businessLine",'Select a Business Line');
        var allData = component.get("v.allData");
        var selectedYear = component.get("v.yearOptionValue");
        var yearSelectedList = component.get("v.YearLst");
        console.log('selectedYear',selectedYear);
        console.log('allData--',allData);
     /*   if( selectedYear != 'Select Budget Year'){
            for (var i = 0; i < allData.length; i++) {
                if(selectedYear == allData[i].Year )
                    yearSelectedList.push(allData[i]);
            }
        } */
        var lookup = {};
        var uniqueChannel = [];
        if(allData.length > 0){
            for (var i = 0; i < allData.length; i++) {
                if( selectedYear != 'Select Budget Year' && selectedYear == allData[i].Year){
                    var blUnique = allData[i].BusinessLine;
                    if (!(blUnique in lookup)) {
                        lookup[blUnique] = 1;
                        uniqueChannel.push(blUnique);
                    }
                }
            }
            component.set("v.channelLst", uniqueChannel);
        }
     },
    
    hideSpinner: function (cmp) {
        
        cmp.set("v.isLoading", false);
        
    },
    SubmitForApproval: function (component, event, helper) {
        var selectedProgram = component.find("programNameid").get("v.value");
        var selectedStatus = component.find("statusNameid").get("v.value");
        var selectedBusinessLine = component.find("businessLineId").get("v.value");
         var selectedYear = component.get("v.yearOptionValue");
        if(selectedStatus == 'Approved'){
            component.set("v.msgToPass" ,'Records are already Approved!' );
            component.set("v.openModal",true);
        }else{
            var action = component.get("c.submitRecordsForApproval");
            action.setParams({
                "selectedProgramName": selectedProgram,
                "selectedStatus":selectedStatus,
                "selectedBusinessLine": selectedBusinessLine,
                "selectedYear":selectedYear
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApprovalLabel"));
                    component.set("v.openModal",true);
                    console.log('success');
                    
                } else {
                    console.log('error');
                }
                
            });
            $A.enqueueAction(action);
        }
        
    },
    Approve: function (component, event, helper) {
        debugger;
        var selectedStatus = component.find("statusNameid").get("v.value");
        var selectedBusinessLine = component.find("businessLineId").get("v.value");
        if(selectedStatus == 'Approved'){
            component.set("v.msgToPass" ,'Records are already Approved');
            component.set("v.openModal",true);
            return;
        }
        if(selectedStatus == 'Completed'){
            component.set("v.msgToPass" ,'Completed Records cannot be Approved');
            component.set("v.openModal",true);
            return;
        }
        component.set('v.disableReject',true);
        component.set("v.disableApprove",true); 
        component.set("v.isLoading", true);
        var selectedStatus = component.find("statusNameid").get("v.value");
        var selectedProgram = component.find("programNameid").get("v.value");
        var selectedBusinessLine = component.find("businessLineId").get("v.value");
        var selectedYear = component.get("v.yearOptionValue");
        var approveAction = component.get("c.recordsApproval");
        approveAction.setParams({
            "selectedProgramName": selectedProgram,
            "selectedStatusName": selectedStatus,
            "selectedBusinessLine": selectedBusinessLine,
             "selectedYear": selectedYear
        });
        $A.enqueueAction(approveAction);
        approveAction.setCallback(this, function (response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.msgToPass",$A.get("$Label.c.ABI_OP_PushToPOCPOnApproval"));
                component.set("v.openModal",true);
                console.log('success');
                component.set("v.isLoading", false);
                
            }else if(state === "ERROR") {
                component.set("v.msgToPass" ,'Error in Approving Records' );
                component.set("v.openModal",true);
                component.set("v.isLoading", false);
                
            }
        });
         
          
    },
    
    clear:function(component , event , helper){
        location.reload();
        
    },
    Reject: function (component, event, helper) {
        debugger;
        var selectedStatus = component.find("statusNameid").get("v.value");
        var selectedBusinessLine = component.find("businessLineId").get("v.value");
          var selectedYear = component.get("v.yearOptionValue");
        if(selectedStatus == 'Approved'){
            component.set("v.msgToPass" ,'Approved Records cannot be rejected');
            component.set("v.openModal",true);
            return;
        }
        if(selectedStatus == 'Rejected'){
            component.set("v.msgToPass" ,'Records are already rejected');
            component.set("v.openModal",true);
            return;
        }
        component.set("v.isLoading", true);
        var selectedProgram = component.find("programNameid").get("v.value");
        if(selectedStatus == 'Submitted for Approval'){
            var commentArea=component.find("adminComment1").get("v.value");
        }else if(selectedStatus == 'Loaded'){
           var commentArea=component.find("adminComment").get("v.value");
        }
        console.log('commentArea',commentArea);
        if(commentArea == undefined || commentArea==null){   
            component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_RejectionComment"));
            component.set("v.openModal",true);
             component.set("v.isLoading", false);
            return;
        }
        else{
            component.set("v.reasonForRejection" , commentArea);
            var rejectAction = component.get("c.recordsRejection");
            //console.log("comments are till reject function"+commentArea);
            rejectAction.setParams({ 
                "selectedProgramName": selectedProgram,
                "comments" :commentArea,    
                "selectedStatusName": selectedStatus,
                "selectedBusinessLine": selectedBusinessLine,
                "selectedYear" :selectedYear
            });
            
            rejectAction.setCallback(this, function (response) {
                var state = response.getState();
                
                console.log('****State***'+state);
                if (state === "SUCCESS") {
                    //alert('Records Rejected!');
                    component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_RecordsRejected"));
                    component.set("v.openModal",true);
                    console.log('success');
                    component.set("v.isLoading", false);
                    
                } else {
                    component.set("v.msgToPass" ,'Error occured while Rejecting Records. Please try again');
                    component.set("v.openModal",true);
                    component.set("v.isLoading", false);
                }
            });
            $A.enqueueAction(rejectAction);
            
        }
          component.set("v.disableApprove",true); 
            component.set("v.disableReject",true);
        
    },
    
    SubmitToOnplan: function (component, event, helper) {
        //logic for image check here
        component.set("v.isLoading", true);
        var incorrectImageLink = component.get("v.incorrectImageLink");
        var noLink = component.get("v.noImageLink");
        if(incorrectImageLink.length > 0 ){
            //alert('You have not uploaded images for Programs at row'+' '+incorrectImageLink);
            //component.set("v.msgToPass" ,'You have not uploaded images for Programs at row'+' '+incorrectImageLink);
            //	component.set("v.openModal",true);
        }
        var selectedStatusName = component.find("statusNameid").get("v.value");
        var selectedProgramName = component.find("programNameid").get("v.value");
        console.log('****Inside SubmitToOnplan***');
        var currentList = component.get('v.data');
        
        console.log('****currentList*****', currentList);
        var recordIds = [];
        //console.log('$$$$recordsids$$$$',recordIds);
        for (var i = 0; i < currentList.length; i++) {
            recordIds.push(currentList[i].recordId);
        }
        if(selectedStatusName != $A.get("$Label.c.ABI_OP_AppravalStatusApproved")){
            //alert('Status should be approved to Push to onplan!')
            component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApprovedStatusforPOCP"));
            component.set("v.openModal",true);
            component.set("v.isLoading", false);
        }else{
            
            var serverAction = component.get("c.PushToOnPlan1");
            serverAction.setParams({
                "IdList": recordIds
            });
            
            serverAction.setCallback(this, function (response) {
                var state = response.getState();
                var POCPResponse = response.getReturnValue();  
                console.log('****State***' + state);
                console.log('POCPResponse',POCPResponse);
                var isStatusCompleted = true;
                
                if(POCPResponse !== null && POCPResponse.length > 0 ){
                    for(var i = 0; i< POCPResponse.length; i++){
                        if(POCPResponse[i].Status_of_Approval__c == $A.get("$Label.c.ABI_OP_ApprovalStatusFailed")){
                            isStatusCompleted == false;
                            break;
                        }
                    }
                }
                if (state === "SUCCESS" && isStatusCompleted == true) {
                    debugger;
                    component.set("v.isLoading", false);
                    component.set("v.msgToPass" ,$A.get("$Label.c.Items_Successfully_pushed_to_POCP"));
                    component.set("v.openModal",true);
                    console.log('success');
                } else if(state === "ERROR"){
                    debugger;
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                            component.set("v.msgToPass" ,errors[0].message);
                            component.set("v.openModal",true);
                            component.set("v.isLoading", false);
                        }
                    } else {
                        console.log("Unknown error");
                        component.set("v.isLoading", false);
                    }
                }else if(state === "SUCCESS" && isStatusCompleted == false){
                    component.set("v.isLoading", false);
                    component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_FailedToPush"));
                    component.set("v.openModal",true);
                }else if (state === "INCOMPLETE") {
                    component.set("v.isLoading",false);   
                    component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ServerError"));
                    component.set("v.openModal",true);
                }
            });
            $A.enqueueAction(serverAction);
        } 
        
    },
    //used for column width
    calculateWidth: function(component, event, helper) {
        var childObj = event.target
        var mouseStart=event.clientX;
        component.set("v.currentEle", childObj);
        component.set("v.mouseStart",mouseStart);
        // Stop text selection event so mouse move event works perfectlly.
        if(event.stopPropagation) event.stopPropagation();
        if(event.preventDefault) event.preventDefault();
        event.cancelBubble=true;
        event.returnValue=false;  
    },
    
    setNewWidth: function(component, event, helper) {
        var currentEle = component.get("v.currentEle");
        if( currentEle != null && currentEle.tagName ) {
            var parObj = currentEle;
            while(parObj.parentNode.tagName != 'TH') {
                if( parObj.className == 'slds-resizable__handle')
                    currentEle = parObj;    
                parObj = parObj.parentNode;
                count++;
            }
            var count = 1;
            var mouseStart = component.get("v.mouseStart");
            var oldWidth = parObj.offsetWidth;  // Get the width of DIV
            var newWidth = oldWidth + (event.clientX - parseFloat(mouseStart));
            component.set("v.newWidth", newWidth);
            currentEle.style.right = ( oldWidth - newWidth ) +'px';
            component.set("v.currentEle", currentEle);
        }
    },
    // We are setting the width which is just changed by the mouse move event     
    resetColumn: function(component, event, helper) {
        // Get the component which was used for the mouse move
        if( component.get("v.currentEle") !== null ) {
            var newWidth = component.get("v.newWidth"); 
            var currentEle = component.get("v.currentEle").parentNode.parentNode; // Get the DIV
            var parObj = currentEle.parentNode; // Get the TH Element
            parObj.style.width = newWidth+'px';
            currentEle.style.width = newWidth+'px';
            //console.log(newWidth);
            component.get("v.currentEle").style.right = 0; // Reset the column devided 
            component.set("v.currentEle", null); // Reset null so mouse move doesn't react again
        }
    }
    
})