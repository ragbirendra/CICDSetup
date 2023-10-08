({
    parseCSVAndLoadRecords: function (component, event, helper, results ){
        var data = results.split('\n');
        var length = data.length;
        var finalData = [];
        var dataToInsert =[];
        var ItemName =[];
        var validData = [];
        var uniqueSet = new Set();
        var uniqueArray=[];
        
        component.set("v.headerVal", data[0]);   
        console.log("data before" + data);
        for(var i=1;i<length-1;i++){
            
            data[i] = data[i].replace(/(\r\n|\n|\r|"")/gm,"");
            
            console.log("data[i] inside loop" + data[i]);
           	//if(data[i].includes('"'));
           
            var str = data[i].split(',');           
                       var item = { 
                       "DistrictCode" :str[0],
                       "DistrictName":str[1],
                       "Year":str[2],
                       "BusinessLine":str[3],
                       "Region" :str[4],
                       "TerritoryName": str[5] ,
                       "TerritoryCode": str[6], 
                       "DiscretionaryBudget": str[7],
                       "Brand": str[8],
                       "TerritoryBrandBudget": str[9]
                           };
                        validData.push(item);
                        uniqueSet.add(str[5]);
            console.log("data[i] after split" ,+data[i]);
                } 
         
        //end of for loop
        uniqueArray = Array.from(uniqueSet);
        console.log("uniqueArray" ,+uniqueArray);
        component.set("v.OptionsPC", uniqueArray); //'uniqueArray'
        component.set("v.listData",validData);
        component.set("v.listDataToDisplay",validData);
        component.set("v.isLoading", false );
    },
   saveBudget:function(component,event,helper){
     
        var resultToSave;
        var headerCheck;
        resultToSave=component.get("v.listDataToDisplay") ;
        var action = component.get("c.createBudgetPR");
        
        action.setParams({ 
            "recordsToSave" : JSON.stringify(resultToSave)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
           if (state === "SUCCESS") {  
               component.set("v.pushtoOnplanFlag",false);
               var result = response.getReturnValue();  
               //alert('Records created successfully...!!!');
               component.set("v.msgToPass" ,'Data Saved Successfully' );
            	component.set("v.openModal",true);
               component.set("v.isLoading",false);
               component.set("v.pushtoOnplanFlag", false);
           }
            else if (state === "INCOMPLETE") {
                component.set("v.isLoading",false);   
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApexSideError"));
                component.set("v.openModal",true);
            }
            else if (state === "ERROR"){
                
                var errors = response.getError();
                if (errors) {
                   if (errors[0] && errors[0].message) {
                      // alert(''+errors[0].message);
                       component.set("v.msgToPass" ,errors[0].message);
                       component.set("v.openModal",true);
                       component.set("v.isLoading",false);
                   }
               } else {
                        console.log("Unknown error");
                        component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApexSideError" ));
                        component.set("v.openModal",true);
                        component.set("v.isLoading",false);
                    }
           }
              
        }); 
       
        $A.enqueueAction(action);
    },
    ExportBudgetData:function(component,event,helper){
     
        var selectedYrArr;
        var selectedChArr;
        selectedYrArr = component.get("v.selectedYr") ;
        
        selectedChArr = component.get("v.selectedCh") ;
        console.log("selectedYrArr" + selectedYrArr);
         console.log("selectedChArr " + selectedChArr);
        var action = component.get("c.FetchBudgetRecords");
        
        action.setParams({ 
            "selectedYrArr" : selectedYrArr,
            "selectedChArr" : selectedChArr
        });
        action.setCallback(this, function(response){
            var state = response.getState();
           if (state === "SUCCESS") {   
               var result = response.getReturnValue();  
               console.log("result" + result);
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
                        component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_NoRecordFound") );
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
    },
    fetchDistAndTerritoryRecord :function(component,event,helper){
        
        var action = component.get("c.fetchDistAndTerrRecord");
        
        action.setCallback(this, function(response){
           var state = response.getState();
           var returnValue =  response.getReturnValue();
            
            var indexToSplit = returnValue.indexOf('territoryCodeStarted');
            var first = returnValue.slice(0, indexToSplit);
            var second = returnValue.slice(indexToSplit + 1);
            console.log('first:::'+first);
            console.log('second:::'+second);
            if (state === "SUCCESS") {   
                
              // alert('Record Push to onplan has been initiated it may take 8 hrs for completion');
               component.set("v.OnpointDisCodeArr" ,first );
                component.set("v.SalesTerrCodeArr",second);
            }else{
                var errors = response.getError();
                if (errors) {
                   if (errors[0] && errors[0].message) {
                       //alert('Error while push to onplan . Error: '+errors[0].message);
                        component.set("v.msgToPass" ,'Sales & Territory details not Found'+errors[0].message );
            			component.set("v.openModal",true);
                   }
               } 
           }
              
        }); 
        $A.enqueueAction(action);
    },
    pushOnplanBatchRun:function(component,event,helper){
  

        var action = component.get("c.pushOnplanBatchExe");
        
        action.setCallback(this, function(response){
            var state = response.getState();
           if (state === "SUCCESS") {    
              // alert('Record Push to onplan has been initiated it may take 8 hrs for completion');
               component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_BudgetLoadMessage") );
            	component.set("v.openModal",true);
           }else{
                var errors = response.getError();
                if (errors) {
                   if (errors[0] && errors[0].message) {
                       //alert('Error while push to onplan . Error: '+errors[0].message);
                        component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_FailedToPush")+errors[0].message );
            			component.set("v.openModal",true);
                   }
               } 
           }
              
        }); 
        $A.enqueueAction(action);
    },
   filterRecords:function(component, event, helper)
    {
        var data = component.get("v.listData");
        var seletedItem= component.get("v.selectedPC");
        var length = data.length;
        var ItemName =[];
        var validData = [];
        var allData=[];
        if(data.length>0){
           if(seletedItem!='All'){
                for(var i=0;i<data.length;i++){
                    var splitData = data[i];
                    if(seletedItem == data[i].TerritoryName){
       
                        var item = { 
                            "DistrictCode": data[i].DistrictCode,
                            "DistrictName": data[i].DistrictName,
                            "Year": data[i].Year,
                            "BusinessLine": data[i].BusinessLine,
                            "Region": data[i].Region,
                            "TerritoryName": data[i].TerritoryName,                   
                            "TerritoryCode": data[i].TerritoryCode,
                            "DiscretionaryBudget":data[i].DiscretionaryBudget,
                            "Brand": data[i].Brand,
                            "TerritoryBrandBudget": data[i].TerritoryBrandBudget
                        };
                        //ItemName.push(splitData[0]);
                        validData.push(item);
                    }
                }
                component.set("v.listDataToDisplay",validData);
            }
            else
            {
                for(var i=0;i<data.length;i++){
                    var item = { 
                            "DistrictCode": data[i].DistrictCode,
                            "DistrictName": data[i].DistrictName,
                            "Year": data[i].Year,
                            "BusinessLine": data[i].BusinessLine,
                            "Region": data[i].Region,
                            "TerritoryName": data[i].TerritoryName,                   
                            "TerritoryCode": data[i].TerritoryCode,
                            "DiscretionaryBudget":data[i].DiscretionaryBudget,
                            "Brand": data[i].Brand,
                            "TerritoryBrandBudget": data[i].TerritoryBrandBudget
                    };
                    allData.push(item);
                }
                component.set("v.listDataToDisplay",allData);
            }

            component.set("v.isLoading", false );
        }
    },
    convertArrayOfObjectsToCSV : function(component,event,helper){
        console.log("entered helper method");
        var csvStringResult, counter, keys, columnDivider, lineDivider,column2;
        columnDivider = ',';
        lineDivider =  '\n';
        keys =["District Code","District Name","Year","Business Line","Region","Territory Name","Territory Code","Discretionary Budget","Brand","Territory Brand Budget"];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 		column2=["10102","10102 - NEW BRUNSWICK (District)","2020","Out of Home","ATLANTIC REGION","10119 - NB SAINT JOHN/ST STEPHEN","10119","1","Bud Light Flavours and Radler","0"];
        /*for(var i=0; i < keys.length; i++){   
            counter = 0;
           		for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 				console.log("skey" + skey);
               
               //csvStringResult += skey; 
                 console.log("csvStringResult inside else" +csvStringResult);
               counter++;
 			} */
        csvStringResult = keys; 
        csvStringResult += lineDivider + column2;     
        csvStringResult += lineDivider;
          //}
       console.log("csvStringResult" + csvStringResult);
        return csvStringResult;        
    }
})