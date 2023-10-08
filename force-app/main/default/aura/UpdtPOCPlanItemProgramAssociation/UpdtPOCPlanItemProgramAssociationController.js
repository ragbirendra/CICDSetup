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
    loadItemRecord : function(component, event, helper) {
        // his method calls the server to get the program associations for
        // the item sku number entered by the user
        var selectedSKU = component.get("v.enteredSku");
        var selectedYear = component.find("yrSel").get("v.value");
        //alert(''+selectedSKU+''+selectedYear)
        if(selectedSKU == undefined || selectedYear=='selectyear'||selectedSKU==''||selectedYear=='None')
        {
             //alert('test'+selectedSKU+''+selectedYear)
         component.set("v.msgToPass" ,'Please Enter All Value');
         component.set("v.openModal",true);
         return;
        }
        component.set("v.showLoading", true);
        var action = component.get("c.fetchToolkitItemMapping");
        action.setParams({
            "skuNumber" : selectedSKU,
            "selectedYear" : selectedYear
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
            }
                else{
                    component.set("v.msgToPass" ,'No Record Found');
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
                    component.set("v.mktItemAssData", existingData);
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
    }
})