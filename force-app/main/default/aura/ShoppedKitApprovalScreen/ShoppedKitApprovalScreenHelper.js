({
    initializeDataTable: function (component,helper) {
        
        component.set('v.tableColumns', [
            {label: 'record Id', fieldName: 'recordId', type: 'text', editable: false, initialWidth: 0},
            {label: 'Program Name', fieldName: 'programName', type: 'text', editable: false, initialWidth: 200},
            {label: 'Status of Approval', fieldName: 'approvalStatus', type: 'picklist',editable: false, initialWidth: 200},
            {label: 'Shoppedkit Name', fieldName: 'shopedkitName', type: 'text',editable: false, initialWidth: 200},
            {label: 'Start Date', fieldName: 'shopkitStartDate', type: 'text',editable: false, initialWidth: 150},
            {label: 'End Date', fieldName: 'shopkitEndDate', type: 'text',editable: false, initialWidth: 150},
            {label: 'SAP Number', fieldName: 'shopkitSAPNumber', type: 'text', initialWidth: 100},
            {label: 'Temporary Item Numbers', fieldName: 'shopkitTemporaryItemNumbers', type: 'text', initialWidth: 100},
            {label: 'Price', fieldName: 'shopkitPrice', type: 'number',editable: false, initialWidth: 100},
            {label: 'ShoppedkitQty', fieldName: 'shopkitQty', type: 'number',editable: false, initialWidth: 100},
            {label: 'Comment', fieldName: 'comment', type: 'text',editable: false, initialWidth: 200},
            {label: 'BusinessLine', fieldName: 'businessLine', type: 'text',editable: false, initialWidth: 200}
        ]); 
        
        var action1 = component.get("c.getPickListVals");
        action1.setStorable();
        action1.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        component.set("v.msgToPass" ,errors[0].message);
                        component.set("v.openModal",true);
                        component.set("v.isLoading",false);
                    }
                } else {
                    console.log("Unknown error");
                    component.set("v.msgToPass" ,'Error Occured: Please contact your admin or try again');
                    component.set("v.openModal",true);
                    component.set("v.isLoading",false);
                }
            }
            else if (state === "SUCCESS") {
                var records = response.getReturnValue();
                console.log('Helper doInit response',records);
                component.set("v.allData", records);				
            } else {
                console.log('error');
            }
        });
        var requestInitiatedTime = new Date().getTime();
        $A.enqueueAction(action1);
        
        
    },
   
    onSaveRejectLoadedFailedRecord: function (component ,event, helper) {
        var updateStatusDta = component.find("ApprovalDataTable").get("v.draftValues");
        var selectedStatus = component.find("statusNameid").get("v.value");
        var updateAction = component.get("c.SaveRejectLoadedFailedRecord");
        
        updateAction.setParams({
            "saveupdateddata": updateStatusDta,
            "selectedSta" : selectedStatus
        });
        updateAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('Records Saved Successfully ,Please refresh to See Your Changes!!!');
 				component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_RecordSavedRefresh"));
                component.set("v.openModal",true);
            } 
            else if (state === "INCOMPLETE") {
                component.set("v.isLoading",false);   
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApexSideError") );
                component.set("v.openModal",true);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +errors[0].message);
                            component.set("v.msgToPass" ,errors[0].message);
                            component.set("v.openModal",true);
                            component.set("v.isLoading",false);
                        }
                    }else {
                        console.log("Unknown error");
                        component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApexSideError") );
                        component.set("v.openModal",true);
                        component.set("v.isLoading",false);
                    }
            }
        });
        $A.enqueueAction(updateAction);
        
    },exportShoppedKitData:function(component,event,helper){
     
        var selectedYrArr;
        selectedYrArr = component.get("v.selectedYr") ;
        var action = component.get("c.ExportShoppedKitRecord");
        
        action.setParams({ 
            "selectedYrArr" : selectedYrArr
        });
        action.setCallback(this, function(response){
            var state = response.getState();
           if (state === "SUCCESS") {   
               var result = response.getReturnValue();  
               
               if(result.length > 0){
                        component.set("v.shopkitRecords", result);
                        component.set("v.isLoading", false);
                        var csvStringResult, counter, keys, columnDivider, lineDivider,keys1;
                        var budRec = component.get("v.shopkitRecords");
                        if (budRec == null || !budRec.length) {
                        return null;
                        }
                         columnDivider = ',';
                         lineDivider =  '\n';
                         keys1 = ["Shopped_Kit_Name__c","Program_Name__c","Shopkit_Start_Date__c","Shopkit_End_Date__c","Shopkit_Price__c","Shopkit_SAP_Number__c","Shopkit_Temporary_Item_Numbers__c","Shopkit_Qty__c","Year__c","Business_Line__c"];
                         keys =["Shopped Kit Name","Program Name","Shopkit Start Date","Shopkit End Date","Shopkit Price","Shopkit SAP Number","Shopkit Temporary Item Numbers","Shopkit Qty","Year","Business Line"];
     
                         csvStringResult = '';
                         csvStringResult += keys.join(columnDivider);
                         csvStringResult += lineDivider;
                         console.log("budRec.length:::"+budRec.length)
                         
                        for(var i=0; i < budRec.length; i++){
                           counter = 0;

                            for(var sTempkey in keys1) {
                             var skey = keys1[sTempkey] ;
                           if(counter > 0){
                            csvStringResult += columnDivider;
                             }  
                           if(budRec[i][skey]==undefined)
                           csvStringResult += '""';
                           else
                           csvStringResult += '"'+ budRec[i][skey]+'"';   
                           counter++;
                           }
                           csvStringResult += lineDivider;
                           }
                       
                          if (csvStringResult == null){
                           return;
                           }
         
        
                      var hiddenElement = document.createElement('a');
                      hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvStringResult);
                   
                      hiddenElement.target = '_self';
                      hiddenElement.download = 'Shopped Kit Export.csv';
                      document.body.appendChild(hiddenElement); 
                      hiddenElement.click(); 
                    }else{
                        //alert('No Data Found');
                        component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_NoRecordFound"));
                    	component.set("v.openModal",true);
                        component.set("v.isLoading", false);
                    }
           }else{
                
                var errors = response.getError();
                if (errors) {
                   if (errors[0] && errors[0].message) {
                       //alert(''+errors[0].message);
                       component.set("v.msgToPass" ,''+errors[0].message);
                    	component.set("v.openModal",true);
                   }
               } 
           }    
        }); 
        $A.enqueueAction(action);      
    }
})