({
	convertArrayOfObjectsToCSV : function(component,objectRecords){
       
        var csvStringResult, counter, keys, columnDivider, lineDivider, keysHeader;
       
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
       
        columnDivider = ',';
        lineDivider =  '\n';
 
        
          keysHeader = ['POC Id','AccountName','BrandName','ProgramName','itemName','skuNumber','Quantity','Is Complete'];
          keys= ['pocId','accountName','BrandName','ProgramName','itemName','skuNumber','qty','status' ];
        
        csvStringResult = '';
        csvStringResult += keysHeader.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   } 
               console.log('objectRecords[i]:::',objectRecords[i]);
               
               console.log('--in a records ---',objectRecords[i][skey]);
                 if(objectRecords[i][skey] ==undefined){
                     objectRecords[i][skey]='';
                 }
                 var stringChar= objectRecords[i][skey].toString();
                 console.log('---stringChar @@@@',stringChar);
                 //if(stringChar.includes('#')){
                    // var n = objectRecords[i][skey].indexOf('#');
                     stringChar = stringChar.replace('#','');
                // }
                 
                 
               csvStringResult += '"'+ stringChar+'"'; 
               
               counter++;
 
            } 
             csvStringResult += lineDivider;
          }
       
       
        return csvStringResult;        
    },
    getProgramData: function(component,brandName){
        var action = component.get("c.getProgramData");
        action.setParams({
             "brandName" : brandName,
             "yearVal": component.get("v.selectedBudgetYear"),
             "busienssLineVal": component.get("v.selectedBusinessLine")
         });
		//action.setStorable();
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
             	
             	/*var lookup = {};
                var uniqueDataToReview = [];
                for (var i = 0; i < records.length; i++) {
                    //console.log('-----records[i]...key---',dummyArr[i]);
                    var uniqueValue = records[i].Program_Name__c;
                    if (!(uniqueValue in lookup)) {	
                        lookup[uniqueValue] = 1;
                        uniqueDataToReview.push(uniqueValue[i]);
                    }
                }*/
             	
             	//console.log('=====Result log oof program---',uniqueDataToReview);
				component.set("v.ProgramList", records.listOfProgram);
             component.set("v.selectedOnPointBrand", records.onPointBrandName);
               component.set("v.ProgramListTOshow",false);
    			
				//component.set("v.data", records);
                
				
			} else {
				console.log('error');
			}
		});
        
		$A.enqueueAction(action);  
    },
    
    fetchDataToReview: function(component,brandName,programName){
        component.set("v.loadSpinner", true);
    	var action = component.get("c.getDataToReview");
        action.setParams({
            "brandName" : brandName ,
            "ProgramName" : programName,
            "yearVal" : component.get("v.selectedBudgetYear"),
            "businessLineVal" : component.get("v.selectedBusinessLine")
        });
       // action.setParams({"ProgramName" : programName });
       // action.setStorable();
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
                component.set("v.loadSpinner", false);
			}
			if (state === "SUCCESS") {
				let records = response.getReturnValue();
                var cloned_array = [].concat(records);
                console.log('records',response.getReturnValue());
				//component.set("v.allData", cloned_array);
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
                var uniqueDataToReview = [];
                for (var i = 0; i < dummyArr.length; i++) {
                    //console.log('-----records[i]...key---',dummyArr[i]);
                    var uniqueValue = dummyArr[i].compositeKey;
                    if (!(uniqueValue in lookup)) {	
                        lookup[uniqueValue] = 1;
                        uniqueDataToReview.push(dummyArr[i]);
                    }
                }
               // console.log('@@@@@uniqueDataToReview@@@@@',uniqueDataToReview);
                component.set("v.DataToReview", uniqueDataToReview); 
                
                var stockData = component.get("v.DataToReview");
               // console.log('---stockData---',stockData);
                //console.log()
                // call the helper function which "return" the CSV data as a String   
                var csv = this.convertArrayOfObjectsToCSV(component,stockData);  
                            
                if (csv == null){return;} 
                
                // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
                var hiddenElement = document.createElement('a');
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
                hiddenElement.target = '_self'; // 
                hiddenElement.download = stockData[0].ProgramName+'.csv';  // CSV file Name* you can change it.[only name not .csv] 
                // document.body.appendChild(hiddenElement); // Required for FireFox browser
               // console.log('before hidden element +++++');
                hiddenElement.click(); // using click() js function to download csv file
               // var elem= hiddenElement.parentNode.removeChild(hiddenElement);
                component.set("v.showReviewButton",false);
               /* var stateComplete= component.get("v.isStateComplete");
                console.log(' ******stateComplete ****',stateComplete);
                if(stateComplete){
                    component.set("v.ShowReopenProgram", false);
                     component.set("v.ShowMarkAsComplete", true);
                }
                else{
                    component.set("v.ShowMarkAsComplete", false);
                    component.set("v.ShowReopenProgram", true);
                }*/
                component.set("v.loadSpinner", false);
                
            } else {
				console.log('error');
			}
		});
		$A.enqueueAction(action);
	},
    fetchAllData: function(component,brandName,programName, skuNumber){
        component.set("v.loadSpinner", true);
        var action = component.get("c.getData");
        console.log(' >>>>>')
        action.setParams({"brandName" : brandName ,"ProgramName" : programName, "skuNumber": skuNumber});
       // action.setParams({"ProgramName" : programName });
        //action.setStorable();
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
                component.set("v.loadSpinner", false);
			}
			if (state === "SUCCESS") {
				let records = response.getReturnValue();
                console.log(' @@@@ records @@@',records);
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
                console.log('----uniqueData @@@@',uniqueData);
                component.set("v.originalDataSet", uniqueData); // kaustav - end
                console.log('allData',component.get("v.allData"));
                console.log('originalDataSet',component.get("v.originalDataSet"));
    			component.set("v.ShowDownload",false);
				component.set("v.data", records);
                component.set("v.loadSpinner", false);
				
			} else {
				console.log('error');
			}
		});
		$A.enqueueAction(action);
        
    },
    
    updateQuantity: function(component, id, qty)
    {
        if(qty !=''){
        var action = component.get("c.updateyQuantity");
        action.setParams({"qty" : qty ,"recordId" : id });
       
		action.setCallback(this, function (response) {
			var state = response.getState();
            if(state === "SUCCESS"){
                var brandName=component.get("v.selectedBrand"); 
                var programName= component.get("v.selectedProgram");
                //this.fetchDataToReview(component,brandName,programName);
                //alert('Quantity is update Successfully');
                
            } else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
		});
		$A.enqueueAction(action);
    	}
    },
    
    mergeItem: function(component, event, currentChangeData, originaldata)
    {
        component.set("v.loadSpinner", true);
        var brandName=component.get("v.selectedBrand");
        var programName= component.get("v.selectedProgram");
    	var action2 = component.get("c.updateSKUNumber");
        var currentRowString= JSON.stringify(currentChangeData);
        console.log('------originalRow @@@',currentRowString);
        console.log('------currentRowString @@@',currentRowString);
        var originalRowString= JSON.stringify(originaldata);
        action2.setParams({"currentRow" : currentRowString ,"originalRow" : originalRowString, "brandName" : brandName, "programName" : programName });
		action2.setCallback(this, function (response) {
			var state = response.getState();
            var result = response.getReturnValue();
            console.log('-----mergeITem Result--->',result);
            if(result.isSuccess ){
                
                 var fetchFromController=result.dataTOPass;
        		 //component.set("v.allData",fetchFromController);
                
               // component.set("v.originalDataSet",fetchFromController);               // AP CHange Today
               // component.set("v.loadSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                console.log('---toastEvent--',toastEvent);
                toastEvent.setParams({
                    title : 'Success Message',
                    message: result.successMsg,
                    duration:'5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                var brandName=component.get("v.selectedBrand"); 
                component.set("v.isProgramCompletionToShow", true);
                console.log('==brandName--',brandName);
                var programName= component.get("v.selectedProgram");
                var skuNumber = component.get("v.selectedLookUpRecordSKU").Item_Number__c;
                console.log('----skuNumber---',skuNumber);
                console.log('==programName--',programName);
                  this.fetchAllData(component,brandName,programName,skuNumber);   
                component.set("v.SaveSKUChange", true);
                component.set("v.loadSpinner", false);
            } else{ 
                //alert(result.errorMsg);
                 component.set("v.loadSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: result.errorMsg,
                    duration:'5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
		});
			$A.enqueueAction(action2);
        
    	},
    createAllocation: function(component, account,program,brand,item,qty){
        var accountToPass= JSON.stringify(account);        
        var itemToPass= JSON.stringify(item);
        var action3 = component.get("c.allocationCreation");        
        action3.setParams({"Account" : accountToPass ,"Program" : program ,"Item" : itemToPass ,"Brand" :brand, "Qtity":qty, });
        action3.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(result.isSuccess){
               var item =component.get("v.selectedLookUpRecordSKUAllocation");
                console.log('===ite-----',item);
               component.set("v.selectedLookUpRecordSKU",item);
              // alert('Allocation Created Successfully');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success Message',
                    message: 'Allocation Created Successfully',
                    duration:'5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                 component.set("v.isOpen", false);
                var blankArray=[];
                component.set("v.selectedLookUpRecordSKUAllocation",blankArray);
                component.set("v.SelectedAccountRecords",blankArray);
                component.set("v.qty",0);
                var brandName=component.get("v.selectedBrand"); 
        		var programName= component.get("v.selectedProgram");
        		var skuNumber = component.get("v.selectedLookUpRecordSKU").SKU_Number__c;
        		this.fetchAllData(component,brandName,programName,skuNumber);
                
            } else if(state === "ERROR"){
                var errors = action3.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
		});
		$A.enqueueAction(action3);
    },
    
    reviewData: function(component, event, helper) {
        
        var dataToReview= JSON.stringify(component.get("v.DataToReview"));
        var action3 = component.get("c.reviewStaging");
         action3.setParams({"dataToReview" : dataToReview  });
        action3.setCallback(this, function (response) {
			var state = response.getState();
            var result = response.getReturnValue();
            if(result.isSuccess){
                // var toastEvent = $A.get("e.force:showToast");
               // console.log('---toastEvent--',toastEvent);
                /*toastEvent.setParams({
                    title : 'Success Message',
                    message: result.successMsg,
                    duration:'5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();*/
                component.set("v.msgToPass" ,result.successMsg);
        	   component.set("v.openModal",true);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: result.errorMsg,
                    duration:'5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
		});
		$A.enqueueAction(action3);
    },
    reopenStaging: function(component, event, helper) {
        
        var dataToReview= JSON.stringify(component.get("v.DataToReview"));
        var action2 = component.get("c.reopenStagingData");
         action2.setParams({"dataToReview" : dataToReview  });
        action2.setCallback(this, function (response) {
			var state = response.getState();
            var result = response.getReturnValue();
            console.log('--->>>>---',result);
            if(result.isSuccess){
                 var toastEvent = $A.get("e.force:showToast");
                console.log('---toastEvent--',toastEvent);
                toastEvent.setParams({
                    title : 'Success Message',
                    message: result.successMsg,
                    duration:'5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: result.errorMsg,
                    duration:'5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
		});
		$A.enqueueAction(action2);
    },
    onCheck: function(component, event, helper){
        var currentChangeData= component.get("v.allData");
        var originaldata= component.get("v.originalDataSet");
        console.log(' ******originaldata***',originaldata);
        console.log(' ******currentChangeData***',currentChangeData);
        var checkCmp = component.find("checkbox");
        var checked = checkCmp.get("v.value");
        console.log(' *******',checked);
        var skuToApplyAll=currentChangeData[0].skuNumber;
         var OriginalSKu=originaldata[0].skuNumber;
        console.log('@@@@@@ SKu to apply @@@',skuToApplyAll);
        if(checked == true){
            for(var i in currentChangeData){
                currentChangeData[i].skuNumber = skuToApplyAll;
            }
            component.set("v.allData",currentChangeData);
        }
        else if(checked == false){
            for(var i in currentChangeData){
                currentChangeData[i].skuNumber = OriginalSKu;
            }
            component.set("v.allData",currentChangeData);
        }
        
    },
    enableSKUButton:function(component, event, helper){
        component.set("v.SaveSKUChange", false);
    },
    
    findStateOfAllocation:function(component, programName){
        var action4 = component.get("c.getStateOfProgram");
        action4.setParams({"programName" : programName  });
        action4.setCallback(this, function (response) {
            var result = response.getReturnValue();
            console.log('---result @@@@', result);
            component.set("v.selectedProgramStartDate",result.Program_Start_Date__c);
            component.set("v.selectedProgramEndDate",result.Program_End_Date__c);
            if(result.Data_Reviewed__c ){
                if ( result.OnPoint_Program_Id__c == null || result.OnPoint_Program_Id__c == ''){
                    component.set('v.isStateComplete',true);
                    component.set('v.movedToOnPoint',false);
                    component.set("v.ShowReopenProgram", false);
                    component.set("v.ShowMarkAsComplete", true);
                    component.set('v.ShowDataTOshow',true);
                    component.set('v.SaveSKUChange',true);
                }
                else if(result.OnPoint_Program_Id__c != null || result.OnPoint_Program_Id__c != ''){
                    component.set("v.movedToOnPoint", true);
					component.set('v.isStateComplete',true);
                    //component.set('v.ShowDataTOshow',true);
                   component.set('v.SaveSKUChange',true);
                        component.set("v.ShowReopenProgram", true);
                        component.set("v.ShowMarkAsComplete", true); 
                }
                 
            }
           
            else{
                component.set('v.isStateComplete',false);
                component.set("v.ShowMarkAsComplete", false);
                    //component.set('v.ShowDataTOshow',true);
                component.set("v.ShowReopenProgram", true);
            }
            
        });
        $A.enqueueAction(action4);
    },
    fetchDataToReviewToReOpenfunction:function(component,brandName,programName){
        component.set("v.loadSpinner", true);
    	var action = component.get("c.getDataToReview");
        action.setParams({
            "brandName" : brandName ,
            "ProgramName" : programName,
            "yearVal" : component.get("v.selectedBudgetYear"),
            "businessLineVal" : component.get("v.selectedBusinessLine")
        });
       // action.setParams({"ProgramName" : programName });
       // action.setStorable();
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
                component.set("v.loadSpinner", false);
			}
			if (state === "SUCCESS") {
				let records = response.getReturnValue();
                var cloned_array = [].concat(records);
                console.log('records',response.getReturnValue());
				//component.set("v.allData", cloned_array);
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
                var uniqueDataToReview = [];
                for (var i = 0; i < dummyArr.length; i++) {
                    console.log('-----records[i]...key---',dummyArr[i]);
                    var uniqueValue = dummyArr[i].compositeKey;
                    if (!(uniqueValue in lookup)) {	
                        lookup[uniqueValue] = 1;
                        uniqueDataToReview.push(dummyArr[i]);
                    }
                }
               // console.log('@@@@@uniqueDataToReview@@@@@',uniqueDataToReview);
                component.set("v.DataToReview", uniqueDataToReview);
                console.log('=== dataToReview fetchDataToReviewToReOpenfunction -->',uniqueDataToReview);
                var dataToReview= JSON.stringify(component.get("v.DataToReview"));
                console.log('=== dataToReview -->',dataToReview);
                var action3 = component.get("c.reviewStaging");
                action3.setParams({"dataToReview" : dataToReview  });
                action3.setCallback(this, function (response) {
                    // window.setTimeout($A.getCallback(function(){
                    var state = response.getState();
                    var result = response.getReturnValue();
                    if(result.isSuccess){
                        // var toastEvent = $A.get("e.force:showToast");
                        // console.log('---toastEvent--',toastEvent);
                        /*toastEvent.setParams({
                                title : 'Success Message',
                                message: result.successMsg,
                                duration:'5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'pester'
                            });
                            toastEvent.fire();*/
                                component.set("v.msgToPass" ,result.successMsg);
                                component.set("v.openModal",true);
                                component.set("v.loadSpinner", false);
                                component.set("v.ShowMarkAsComplete", true);
                                component.set("v.ShowReopenProgram", false);
                                component.set("v.isStateComplete", true);
                        		component.set("v.movedToOnPoint", false);
                                // var a = component.get('c.downloadCsv');
                                // $A.enqueueAction(a);
                            } else {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Error Message',
                                    message: result.errorMsg,
                                    duration:'5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'pester'
                                });
                                toastEvent.fire();
                                component.set("v.loadSpinner", false);
                            }
                            // }),10000);
                            
                        });
                $A.enqueueAction(action3);
            }
            else {
				console.log('error');
			}
		});
		$A.enqueueAction(action);
        
	},
    fetchDataToReviewToReOpenAllocation:function(component,brandName,programName){
        component.set("v.loadSpinner", true);
    	var action = component.get("c.getDataToReview");
        action.setParams({
            "brandName" : brandName ,
            "ProgramName" : programName,
            "yearVal" : component.get("v.selectedBudgetYear"),
            "businessLineVal" : component.get("v.selectedBusinessLine")
        });
       // action.setParams({"ProgramName" : programName });
       // action.setStorable();
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
                component.set("v.loadSpinner", false);
			}
			if (state === "SUCCESS") {
				let records = response.getReturnValue();
                var cloned_array = [].concat(records);
                console.log('records',response.getReturnValue());
				//component.set("v.allData", cloned_array);
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
                var uniqueDataToReview = [];
                for (var i = 0; i < dummyArr.length; i++) {
                    console.log('-----records[i]...key---',dummyArr[i]);
                    var uniqueValue = dummyArr[i].compositeKey;
                    if (!(uniqueValue in lookup)) {	
                        lookup[uniqueValue] = 1;
                        uniqueDataToReview.push(dummyArr[i]);
                    }
                }
                console.log('@@@@@uniqueDataToReview@@@@@',uniqueDataToReview);
                component.set("v.DataToReview", uniqueDataToReview);
                //console.log('=== dataToReview fetchDataToReviewToReOpenfunction -->',uniqueDataToReview);
                var dataToReview= JSON.stringify(component.get("v.DataToReview"));
                var action2 = component.get("c.reopenStagingData");
                action2.setParams({"dataToReview" : dataToReview  });
                action2.setCallback(this, function (response) {
                    var state = response.getState();
                    var result = response.getReturnValue();
                    console.log('--->>>>---',result);
                    if(result.isSuccess){
                        var toastEvent = $A.get("e.force:showToast");
                        console.log('---toastEvent--',toastEvent);
                        toastEvent.setParams({
                            title : 'Success Message',
                            message: result.successMsg,
                            duration:'5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        component.set("v.loadSpinner", false);
                        component.set("v.ShowMarkAsComplete", false);
                        component.set("v.ShowReopenProgram", true);
                        component.set("v.isStateComplete", false);
                        // var a = component.get('c.downloadCsv');
                        //	 $A.enqueueAction(a);
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error Message',
                            message: result.errorMsg,
                            duration:'5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        component.set("v.loadSpinner", false);
                    }
                });
                $A.enqueueAction(action2);
                
            }
            else {
                     console.log('error');       
                            }
        });
        $A.enqueueAction(action);
    }
        
})