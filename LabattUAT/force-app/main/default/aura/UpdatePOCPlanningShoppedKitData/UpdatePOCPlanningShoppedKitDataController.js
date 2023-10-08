({
    doInit : function(component, event, helper) {
    var numYear = [];
    
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    var currYear = $A.localizationService.formatDate(today, "yyyy");
    numYear.push(parseInt(currYear)-1);
    numYear.push(parseInt(currYear));
    numYear.push(parseInt(currYear)+1);
    numYear.push(parseInt(currYear)+2);
    
     component.set("v.YearList", numYear);
        
   },
    onYearChange:function (component, event, helper) {
        component.set("v.selectedProg","Select a Program");
        component.set("v.onchangehide",false);
        var selectedChannelName = component.find("busSel").get("v.value");
        var selectedYearValue = component.find("yrSel").get("v.value");
        
        if(selectedChannelName =='Select a Business Line'|| selectedYearValue =='selectyear'){
           
            component.set("v.msgToPass" ,"Please Select Business Line and Year Both !!!");
            component.set("v.openModal",true);
        }else{
            var showDataAction = component.get("c.getPickListVals");
            
            showDataAction.setParams({
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
                    console.log("filteredData::: " +filteredData);
                    component.set("v.ProgramLst", filteredData);
                    
                } else {
                    console.log('error');
                }
                
            });
            $A.enqueueAction(showDataAction);
        }
    },
     onProgramChange : function(component, event, helper) {
          
          component.set("v.onchangehide",false);
     },
    onChannelChange : function(component, event, helper) {
          component.set("v.selectedYr","selectyear");
          component.set("v.selectedProg","Select a Program");
          component.set("v.onchangehide",false);
     },
    
    loadItemRecord : function(component, event, helper) {
        // his method calls the server to get the program associations for
        // the item sku number entered by the user
        
        var selectedProgramName = component.find("proSel").get("v.value");
        var selectedYear = component.find("yrSel").get("v.value");
        var selectedBusinessLine = component.find("busSel").get("v.value");

        if((selectedProgramName==undefined || selectedYear=='selectyear') || selectedBusinessLine=='channel')
        {
         component.set("v.msgToPass" ,'Please Enter All Value');
         component.set("v.openModal",true); 
         return;
        }
       
        component.set("v.showLoading", true);
        var action = component.get("c.fetchToolkitItemMapping");
        action.setParams({
            "selectedProgramName" : selectedProgramName,
            "selectedYear" : selectedYear,
            "selectedBusinessLine" : selectedBusinessLine
            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        component.set("v.msgToPass" ,'An Error occurred : please check the value');
        					component.set("v.openModal",true);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            if (state === "SUCCESS") {
            var associationRecs = response.getReturnValue();
            if(associationRecs != null && associationRecs.length > 0){
                component.set("v.mktItemAssData", associationRecs);
                 component.set("v.onchangehide",true);
            }
                else{
                    component.set("v.msgToPass" ,'No Record Found / No Shopped Kit Item associated');
        			component.set("v.openModal",true); 
                }
               
            }
            component.set("v.showLoading", false);
           
                
        });
        $A.enqueueAction(action);
    },
    processDeletion : function(component, event, helper){
        // this method is called every time the user selects
        // or deselects a row on the table that is displayed and either adds to or removes
        // from the list of association ids that we maintain - which we eventually delete
        component.set("v.showLoading", true);
        var selectedRecId = event.getSource().get("v.value");
        var selectedStatus = event.getSource().get("v.checked");
        console.log("#### selected record #### " + selectedRecId + " #### " + selectedStatus);
        var allSelectedRecords = [];
        allSelectedRecords = component.get("v.delListOfAss");
        if(selectedStatus == true){
            // add to the list
            allSelectedRecords.push(selectedRecId);
        }else if(selectedStatus == false){
            // delete from the list
            for(var i = 0; i<allSelectedRecords.length; i++){
                if(allSelectedRecords[i] == selectedRecId){
                    allSelectedRecords.splice(i,1);
                    break;
                }
            }
        } 
        component.set("v.delListOfAss", allSelectedRecords);
        console.log("#### final state of ids #### " + component.get("v.delListOfAss"));  
        component.set("v.showLoading", false);            
    },
    
    deleteAssociations: function(component, event, helper){
        // server side action is called to actually delete the association records
        component.set("v.showLoading", true);
        var toBeDeletedAss = component.get("v.delListOfAss");
        console.log("toBeDeletedAss" +toBeDeletedAss);
        
        if(toBeDeletedAss != null && toBeDeletedAss != "undefined" && toBeDeletedAss.length > 0){
            var action = component.get("c.deleteItemToolkitMapping");
            action.setParams({
                associationIds : toBeDeletedAss
            });
            action.setCallback(this, function(response){
                console.log("#### successfully deleted #### " + response.getReturnValue());
                // after coming back from server if deletion is successful then we iterate over the 
                // result and the existing displayed set of data and remove the ones from the 
                // list - those which were already deleted - then the UI no longer continues to
                // show those records
                var weGotBack = response.getReturnValue();
                if(weGotBack != null && weGotBack != undefined && weGotBack != 'failure'){
                    var deletedRecIds = [];
                    var indicesToDelete = [];
                    if(weGotBack.indexOf(";;") != -1){
                        deletedRecIds = weGotBack.split(";;");
                    }else{
                        deletedRecIds.push(weGotBack);
                    }
                    var existingData = component.get("v.mktItemAssData");
                    for(var i=0; i<existingData.length; i++){
                        for(var j = 0; j<deletedRecIds.length; j++){
                            if(existingData[i].Id == deletedRecIds[j]){
                                indicesToDelete.push(i);
                            }
                        }
                    }
                    if(indicesToDelete.length > 0){
                        for(var i=0; i<indicesToDelete.length; i++){
                            existingData.splice(indicesToDelete[i],1);
                        }
                    }
                    component.set("v.mktItemAssData", null);
                }else {
                    // some problem happened
                    // add error handling - toast message
                    component.set("v.msgToPass" ,'Some error occured');
        			component.set("v.openModal",true); 
                }
                // add success toast
                component.set("v.msgToPass" ,'Successfully Deleted Association');
        		component.set("v.openModal",true);
                component.set("v.showLoading", false);
            });
            $A.enqueueAction(action);
           
            
        }
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        
        component.set("v.isLoading", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner
          
        component.set("v.isLoading", false);
    }
})