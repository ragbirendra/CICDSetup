({
    getProgramData: function(component){
        var action = component.get("c.getProgramData");
		action.setStorable();
        action.setCallback(this, function (response) {
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
				var records = response.getReturnValue();
                console.log('records',response.getReturnValue());
				component.set("v.ProgramList", records);
    			
				//component.set("v.data", records);
                
				
			} else {
				console.log('error');
			}
		});
        
		$A.enqueueAction(action);   
    },
    
    getStatusData :function(component){
      var statusAction=component.get("c.getStatusData");
       statusAction.setStorable();
        statusAction.setCallback(this, function (response) {
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
				var records = response.getReturnValue();
                console.log('records',response.getReturnValue());
				component.set("v.statusList", records);	
                //component.set("v.ShowDataTOshow",false);
			} else {
				console.log('error');
			}
		});
        
		$A.enqueueAction(statusAction);           
    },
    exportShoppedKitData:function(component,event,helper){
     
        var selectedYrArr,selectedChannel,selectedStatus,selectedProgram;
        selectedYrArr = component.get("v.selectedYr") ;
        selectedChannel = component.get("v.selectedCh") ;
         selectedStatus = component.get("v.selectedStatus") ;
         selectedProgram = component.get("v.selectedProgram") ;
        var action = component.get("c.ExportShoppedKitRecord");
        
        action.setParams({ 
            "selectedYrArr" : selectedYrArr,
            "selectedChannel" : selectedChannel,
            "selectedStatus" : selectedStatus,
            "selectedProgram" : selectedProgram
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
                   //console.log(" budRec data " + budRec);
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
                         //console.log("budRec.length:::"+budRec.length)
                         
                        for(var i=0; i < budRec.length; i++){
                           counter = 0;

                            for(var sTempkey in keys1) {
                             var skey = keys1[sTempkey] ;
                           if(counter > 0){
                            csvStringResult += columnDivider;
                             }  
                                if(budRec[i][skey]==undefined){
                                    csvStringResult += '""';}
                                else{
                                    csvStringResult += '"'+ budRec[i][skey]+'"'; }  
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
                       // alert('No Data Found');
                       	component.set("v.msgToPass" ,'No Data Found' );
            			component.set("v.openModal",true);
                        component.set("v.isLoading", false);
                    }
           }else{
                
                var errors = response.getError();
                if (errors) {
                   if (errors[0] && errors[0].message) {
                      // alert(''+errors[0].message);
                      component.set("v.msgToPass" ,''+errors[0].message );
            		  component.set("v.openModal",true);
                   }
               } 
           }    
        }); 
        $A.enqueueAction(action);      
    }
})