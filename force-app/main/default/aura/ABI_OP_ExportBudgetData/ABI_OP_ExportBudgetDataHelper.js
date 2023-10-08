({
	 fetchAllData: function(component,year,channel){
       
        var action = component.get("c.FetchBudgetRecords");
        action.setParams({"selectedChArr" : channel ,"selectedYrArr" : year });
       
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
				let records = response.getReturnValue();
                var cloned_array = [].concat(records);
                console.log('records',response.getReturnValue());
				component.set("v.allData", cloned_array);
                var dummyArr = []; // kaustav - start
                for(var i = 0; i<records.length; i++){
                    var dummyObj = {};
                    //console.log('---records[i]---',records[i]);
                    for(var thisAttr in records[i]){
                        if(records[i].hasOwnProperty(thisAttr)){
                            dummyObj[thisAttr] = records[i][thisAttr];
                            dummyArr.push(dummyObj);
                        }
                    }
                }
                
                //Added by AMOL, for unique in original Data set
                var lookup = {};
                var uniqueData = [];
                for (var i = 0; i < dummyArr.length; i++) {
                    console.log('-----records[i]...key---',dummyArr[i]);
                    var uniqueValue = dummyArr[i].compositeKey;
                    if (!(uniqueValue in lookup)) {	
                        lookup[uniqueValue] = 1;
                        uniqueData.push(dummyArr[i]);
                    }
                }
                
                component.set("v.originalDataSet", uniqueData); // kaustav - end
                //console.log('allData',component.get("v.allData"));
                //console.log('originalDataSet',component.get("v.originalDataSet"));
    			component.set("v.ShowDownload",false);
				component.set("v.data", records);
                
				
			} else {
				console.log('error');
			}
		});
		$A.enqueueAction(action);
        
    },
    ExportBudgetData:function(component,event,helper){
     
        var selectedYrArr;
        var selectedChArr;
        selectedYrArr = component.get("v.selectedYr") ;
        
        selectedChArr = component.get("v.selectedCh") ;
        //console.log("selectedYrArr" + selectedYrArr);
        // console.log("selectedChArr " + selectedChArr);
        var action = component.get("c.FetchBudgetRecords");
        
        action.setParams({ 
            "selectedYrArr" : selectedYrArr,
            "selectedChArr" : selectedChArr
        });
        action.setCallback(this, function(response){
            var state = response.getState();
           if (state === "SUCCESS") {   
               var result = response.getReturnValue();  
               //console.log("result" + result);
               if(result.length > 0){
                        component.set("v.budgetrecords", result);
                        component.set("v.isLoading", false);
                        var csvStringResult, counter, keys, columnDivider, lineDivider,keys1;
                        var budRec = component.get("v.budgetrecords");
                        // check if "budRec" parameter is null, then return from function
                        if (budRec == null || !budRec.length) {
                        return null;
                        }
                         columnDivider = ',';
                         lineDivider =  '\n';
                         keys1 =["District_Code__c","District_Name__c","Year__c","Business_Line__c","Region__c","Territory_Name__c","Territory_Code__c","Discretionary_Budget__c","Brand__c","Territory_Brand_Budget__c"];
                         keys =["District Code","District Name","Year","Business Line","Region","Territory Name","Territory Code","Discretionary Budget","Brand","Territory Brand Budget"];
                         
                         csvStringResult = '';
                         csvStringResult += keys.join(columnDivider);
                         csvStringResult += lineDivider;

                        for(var i=0; i < budRec.length; i++){
                           counter = 0;

                            for(var sTempkey in keys1) {
                             var skey = keys1[sTempkey] ;
                           if(counter > 0){
                            csvStringResult += columnDivider;
                             }
                              if(budRec[i][skey]==undefined){
                               csvStringResult += '""';   
                              }
                             else{
                                csvStringResult += '"'+ budRec[i][skey]+'"';    
                              }
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
                      hiddenElement.download = 'Budget Export.csv';
                      document.body.appendChild(hiddenElement); 
                      hiddenElement.click(); 
                    }else{
                        //alert('No Data Found');
                        component.set("v.msgToPass" ,'No Data Found' );
            			component.set("v.openModal",true);
                        component.set("v.isLoading", false);
                    }
           }else{
                
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
    }
    
})