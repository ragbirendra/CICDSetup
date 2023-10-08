({
	 ExportBudgetData:function(component,event,helper){
     
        var selectedYrArr;
        var selectedChArr;
        selectedYrArr = component.get("v.selectedYr") ;
        
        selectedChArr = component.get("v.selectedCh") ;
        //console.log("selectedYrArr" + selectedYrArr);
         //console.log("selectedChArr " + selectedChArr);
        var action = component.get("c.FetchBackofficeBudgetRecords");
        
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
                   

                         keys1 =["DistrictCode","DistrictName","Year","BusinessLine","Region","TerritoryName","TerritoryCode","DiscretionaryBudget","Brand","TerritoryBrandBudget"];
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
                      hiddenElement.download = 'Backoffice Budget Export.csv';
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
                       component.set("v.msgToPass" ,errors[0].message );
            		   component.set("v.openModal",true);
                   }
               } 
           }    
        }); 
        $A.enqueueAction(action);      
    }
    
})