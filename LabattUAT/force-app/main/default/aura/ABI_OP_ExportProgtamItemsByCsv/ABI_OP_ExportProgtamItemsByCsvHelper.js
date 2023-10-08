({
	convertArrayOfObjectsToCSV : function(component,objectRecords){
       
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
       
        columnDivider = ',';
        lineDivider =  '\n';
 
       /* keys= ['BrandName','ProgramName','itemName','SAPitemNumber','TEMPitemNumber',
                 'programDescription','language','itemDescriptionEN','itemDescriptionFR','itemPrice',
                 'standardPrice','fullPriceToRep','programStartDate','programEndDate','planningStartDate',
                 'planningEndtDate','ItemClassification','menuCategory']; */
        keys= [$A.get("$Label.c.ABI_Program_Item_CSV_Headers").split(',')];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               console.log('--in a records ---',objectRecords[i][skey]);
                 if(objectRecords[i][skey] ==undefined){
                     objectRecords[i][skey]='';
                 }
               csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
               counter++;
 			} 
             csvStringResult += lineDivider;
          }
       
       
        return csvStringResult;        
    },
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
    getBusinessLineData :function(component){
      var action=component.get("c.getBusinessLineData");
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
				component.set("v.businessLineLst", records);	
			} else {
				console.log('error');
			}
		});
        
		$A.enqueueAction(action);           
    },
    
    getYear :function(component){
        var numYear = [];
    	var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    	var currYear = $A.localizationService.formatDate(today, "yyyy");
    	numYear.push(parseInt(currYear)-2);
    	numYear.push(parseInt(currYear)-1);
   		numYear.push(parseInt(currYear));
        numYear.push(parseInt(currYear)+1);
        numYear.push(parseInt(currYear)+2);
    	console.log("numYear:::"+numYear);
        
    	component.set("v.exportYearList", numYear);
        
    },
    
    fetchAllData: function(component,programName,statusName,businessName){
        var selectedYr;
        selectedYr=component.get("v.selectedYr");
        var yearToCompare;
        if(selectedYr == 2021){
            yearToCompare='1/1/2019';
             //alert(yearToCompare);
        }
        if(selectedYr == 2018){
            yearToCompare='1/1/2018';
        }
        if(selectedYr == 2017){
            yearToCompare='1/1/2017';
        }
       
        var yearToCompare=component.get("v.yearToCompare");
        var action = component.get("c.getData");
        action.setParams({
            "ProgramName"   :programName ,
            "yearToCompare" :yearToCompare,
            "status" :statusName,
            "selectedBusinessLine":businessName
        });
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
                console.log('records in fetch all data ',response.getReturnValue());
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
                console.log('allData',component.get("v.allData"));
                console.log('originalDataSet',component.get("v.originalDataSet"));
    			component.set("v.ShowDownload",false);
				component.set("v.data", records);
                
				
			} else {
				console.log('error');
			}
		});
		$A.enqueueAction(action);
        
    },
    ExportItemData:function(component,event,helper){
     
        var selectedYrArr;
        var selectedChArr;
        var selectProgram;
        var selectStatus;
        selectedYrArr = component.get("v.selectedYr") ;
        
        selectedChArr = component.get("v.selectedBusinessLine") ;
        selectProgram = component.get("v.selectedProgram") ;
        selectStatus = component.get("v.selectedStatus") ;
        console.log("selectedYrArr in helper" + selectedYrArr);
       	console.log("selectedChArr " + selectedChArr);
        console.log("selectProgram " + selectProgram);
        console.log("selectStatus " + selectStatus);
        var action = component.get("c.getData");
        
        action.setParams({ 
            "ProgramName" : selectProgram,
            "yearToCompare" : selectedYrArr,
            "status":selectStatus,
            "selectedBusinessLine" : selectedChArr
        });
        action.setCallback(this, function(response){
            var state = response.getState();
           if (state === "SUCCESS") {   
               var result = response.getReturnValue();  
               console.log("result" + result);
          		console.log("result length" + result.length);
               if(result.length > 0){
                        component.set("v.itemrecords", result);
                        component.set("v.isLoading", false);
                        var csvStringResult, counter, keys, columnDivider, lineDivider,keys1;
                        var budRec = component.get("v.itemrecords");
                   		console.log("budRec data" +budRec);
                        // check if "budRec" parameter is null, then return from function
                        if (budRec == null || !budRec.length) {
                        return null;
                        }
                         columnDivider = ',';
                         lineDivider =  '\n';
                   
                     keys1 =['BrandName','ProgramName','ProgramDescription',
                           'ProgramStartDate','ProgramEndDate','PlanningStartDate','PlanningEndDate','BusinessLine',
                           'SAPItemNumber','TempItemNumber','ProductName','isUserPaid','Size','Language','UnitOfMeasure',
                           'Currency2','QuantityPerUOM','StandardPrice','FullPriceToRep','ItemType','ItemClassification',
                           'Atlantic','Quebec','Ontario','West','MenuCategory','ItemDescriptionEN','ItemDescriptionFR',
                           'ParentProductType','ProductType','IsAllocationOnly','Year'];
                   
                   
                   keys =['BrandName','ProgramName','ProgramDescription',
                          'ProgramStartDate','ProgramEndDate','PlanningStartDate','PlanningEndDate','BusinessLine',
                          'SAPItemNumber','TempItemNumber','ProductName','isUserPaid','Size','Language','UnitOfMeasure',
                          'Currency2','QuantityPerUOM','StandardPrice','FullPriceToRep','ItemType','ItemClassification',
                          'Atlantic','Quebec','Ontario','West','MenuCategory','ItemDescriptionEN','ItemDescriptionFR',
                          'ParentProductType','ProductType','IsAllocationOnly','Year'];
                   
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
                               console.log(budRec[i][skey]+ 'budRec[i][skey]');
                           }
                           counter++;
                       }
                       csvStringResult += lineDivider;
                   }
                     
                      if (csvStringResult == null){
                           return;
                          console.log('csvStringResult' + csvStringResult);
                        }
                      var hiddenElement = document.createElement('a');
                      hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvStringResult);
                   
                      hiddenElement.target = '_self';
                      hiddenElement.download = 'PBI_Export.csv';
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