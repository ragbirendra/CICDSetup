({
	doInit : function(component, event, helper) {
		component.set("v.showLoading", true);
        // get the current date
        var d = new Date();
        var n = d.getFullYear();
        var yearOptions = [];
        yearOptions.push(n);
        yearOptions.push(n+1);
        yearOptions.push(n+2);
        component.set("v.yearOptions",yearOptions); 
        component.set("v.showLoading", false);
	},
    handleFilesChange : function(component, event, helper){
        component.set("v.isLoading", true);
        var numCols = component.get("v.numberColumns");
        var files = event.getSource().get("v.files");
        var fileReaderObj = new FileReader();
        fileReaderObj.readAsText(files[0]);
        fileReaderObj.onload = function(){
            let fileContent = fileReaderObj.result;
            // in excel if user deletes rows the last row might still have \n\r or \r
            // so removing those before splitting
            if(fileContent.endsWith("\r\n")){
                fileContent = fileContent.substring(0,fileContent.lastIndexOf("\r\n"));
            }
            if(fileContent.endsWith("\n")){
                fileContent = fileContent.substring(0,fileContent.lastIndexOf("\n"));
            }
            if(fileContent.endsWith("\r")){
                fileContent = fileContent.substring(0,fileContent.lastIndexOf("\r"));
            }
            let dataRows = fileContent.split('\n');
            console.log("dataRows" + dataRows[0]);
            for(var i=0 ;i< dataRows.length ; ++i){
                console.log("entered if of dataRows.includes"+[i] +dataRows[i].includes("\""));
                
                if(dataRows[i].includes("\"")){
                
                    component.set("v.msgToPass" ,'Error occured while parsing the file. Make sure there are no Double Quotes or Commas in file.' +'\n'+
                                  'Please Check row :' +(i));
                    component.set("v.openModal",true);
                    component.set("v.isLoading", false);
                    return;
                    
                }
            }
            let headerRow = dataRows[0].replace(/[\n\r]/g, '');
            headerRow = headerRow.split(',');
            console.log('headerRow',headerRow.toString());
            let headerJSON = [];
			let previewData = [];       
            for(var i=0; i<headerRow.length; i++){
                var headObj = {};
                headObj.label = headerRow[i];
                headObj.fieldName = headerRow[i];
                headObj.type = "text";
                headerJSON.push(headObj);
            } 
            for (var i=1; i<dataRows.length ; i++){
                let thisObj = {};
                let thisRow = dataRows[i].replace(/[\n\r]/g, '');
                thisRow = thisRow.split(',');     
                console.log('thisRow[i] after split'+thisRow);
                for(var j=0; j<thisRow.length; j++){
                    thisObj[headerRow[j]] = thisRow[j]; //dynamically add attributes to the json
                }
                previewData.push(thisObj);
            }
            component.set("v.previewData",previewData);
            component.set("v.headerData", headerJSON);
            component.set("v.isLoading", false);
        };
    },
    validateData: function(component, event, helper){
        component.set("v.isLoading", true);
        let checkRows = true;
        component.set("v.isValidationPassed", false);
        var errorsFound = [];
        var numCols = component.get("v.numberColumns");
        var yearColumn = component.get("v.checkYearColumn");
        var busLineCol = component.get("v.checkBusLineColumn");
        var onlyNumberExp = /^[0-9.]+$/;
        // check header
        var expectedHeader = component.get("v.sampleHeader");
        var headerData = component.get("v.headerData");
        var duplicateRowChk = new Set();
        var uniqueKey ='';
        
        expectedHeader = expectedHeader.split(",");
        if(expectedHeader.length != headerData.length){ // check the number of columns in the file
            // header not matching
            checkRows = false;
            component.set("v.msgToPass" ,'The file header did not match');
            component.set("v.openModal",true);
            //helper.showMessage('dismissible','Error', 'The file header did not match', 'error');
			//return;            
        }
        for(var i=0; i<expectedHeader.length; i++){ // check exact sequence of headers
            if(expectedHeader[i] != headerData[i].label){
                console.log(" expected header ## " + expectedHeader[i] + " actual header ## " + JSON.stringify(headerData[i]) );
                // header not matching
                checkRows = false;            	
                break;                
            }
        }
        if(checkRows == false){
            component.set("v.msgToPass" ,'The file header did not match');
            component.set("v.openModal",true);
            //helper.showMessage('dismissible','Error', 'The file header did not match', 'error');
            component.set("v.isLoading", false);
        }
        if(checkRows){ // start checking the rows of data as header has passed all validations
            var dataRows = component.get("v.previewData");
            for(var i=0; i<dataRows.length; i++){
                uniqueKey='';
                var keyArr = Object.keys(dataRows[i]);
                console.log("keyArr before for loop " + keyArr);
                for(var j=0; j<keyArr.length; j++){
                    console.log("keyArr after  for loop " + keyArr[j]);
                    if(dataRows[i][keyArr[j]]  == '' || dataRows[i][keyArr[j]] == null){// empty cell check
                        var rowNum = i+1;
                        var msg = 'Found empty cell ' + keyArr[j] + ' at row ' + rowNum;
                        errorsFound.push(msg);
                    }
                    
                    
                    if(yearColumn == keyArr[j]){ // all year vlaues should match selected budget year
                        var selYear = component.get("v.selectedBudgetYear");
                        if(dataRows[i][keyArr[j]] != selYear){
                            var rowNum = i+1;
                            var msg = 'Budget Year does not match selected year ' + ' at row ' + rowNum ;
                            errorsFound.push(msg);
                        }  
                    }
                    if(busLineCol == keyArr[j]){// all business line values should match selected business line
                        var selLine = component.get("v.selectedBusLine");
                        if(dataRows[i][keyArr[j]] != selLine){
                            var rowNum = i+1;
                            var msg = 'Business Line does not match selected business line ' + ' at row ' + rowNum ;
                            errorsFound.push(msg);
                        }
                    }
                    uniqueKey+= dataRows[i][keyArr[j]];
                }//closing J
                if(!duplicateRowChk.has(uniqueKey))
                {
                 duplicateRowChk.add(uniqueKey);   
                }
                else
                {
                    var msg = 'duplicate Found at Row No: '+ (i+1);
                errorsFound.push(msg);    
                }
            }//closing I
            if(errorsFound.length > 0){// if errors were discovered show message
                var strMsg = [];
                strMsg = errorsFound.join("\n");
                component.set("v.msgToPass" ,errorsFound);
            	component.set("v.openModal",true);
                //helper.showMessage('sticky', 'Error', strMsg , 'error'); 
                component.set("v.isLoading", false);
            }else{
                // get the annual area budget records from server
                // and check if the territories whcich the user has mentioned in the file 
                // has any budget data already created for the selected year and business line
                var action = component.get("c.fetchAllAABRecords");
                action.setParams({
                    selYear : component.get("v.selectedBudgetYear"),
                    businessLine : component.get("v.selectedBusLine")
                });
                action.setCallback(this, function(response){
                    if(response.getState() == "SUCCESS"){
                        component.set("v.budgetDataList", response.getReturnValue());
                        var aabDataFromDB = response.getReturnValue();
                        var commonData = [];
                        var noMatchFoundData = [];
                        var uploadedDataSet = component.get("v.previewData");
                        for(var i=0; i<uploadedDataSet.length; i++){
                            var isMatchFound = false;
                            for(var j=0; j<aabDataFromDB.length; j++){
                                if(uploadedDataSet[i]["Territory Code"] === aabDataFromDB[j].Territory_Code__c){
                                    aabDataFromDB[j].Assigned_KI_Volume__c = uploadedDataSet[i]["Assigned KI Volume"];
                                    aabDataFromDB[j].Discretionary_Budget__c = uploadedDataSet[i]["Discretionary Budget"];
                                    commonData.push(aabDataFromDB[j]);
                                    isMatchFound = true;
                                }
                            }
                            if(!isMatchFound){// no matching budget data was found for this territory
                                var rowNum = i+1;
                                noMatchFoundData.push("Budget Data Does not exist for Territory Code " + uploadedDataSet[i]["Territory Code"] + " at row number " + rowNum + '\n');
                            }
                        }
                        component.set("v.matchingDataSet", commonData);
                        if(noMatchFoundData != null && noMatchFoundData.length > 0){// there were some territories for which annual area budget has not yet been loaded
                            var strMsg = [];
                            strMsg = noMatchFoundData.join("\n");
                           	component.set("v.msgToPass" ,noMatchFoundData);
            				component.set("v.openModal",true);
                            //helper.showMessage('sticky', 'Error', strMsg, 'error');
                            component.set("v.isValidationPassed", false);
                            component.set("v.isLoading", false);
                        }else{// all validations passed
                             component.set("v.msgToPass" ,'Validations Passed Successfully');
            				component.set("v.openModal",true);
                           // helper.showMessage('dismissible', 'Success', 'Validations Passed Successfully', 'success');
                            component.set("v.isValidationPassed", true);
                            component.set("v.isLoading", false);
                        }
                    }else{
                        component.set("v.msgToPass" ,'Error while validating data from server. Please contact System Admin.');
            			component.set("v.openModal",true);
                       // helper.showMessage('dismissible', 'Error', 'Error while validating data from server. Please contact System Admin.', 'error');
                        component.set("v.isLoading", false);
                    }
                    
                });
                $A.enqueueAction(action);
            }
        } 
    },
    saveFunction: function(component, event, helper){// simple save functionality
        component.set("v.isLoading", true);
		var action = component.get("c.updateTerrKIAndDisc");
        var dataToSend = component.get("v.matchingDataSet");
        action.setParams({
            lstToUpdate : dataToSend
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_BudgetLoadMessage") );
            	component.set("v.openModal",true);
               // helper.showMessage('dismissible', 'Success', 'Data Updated Successfully', 'success');
            }else{
                var toastMessage = 'Unknown Error. Please contact your System Administrator.'
                let errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    toastMessage = errors[0].message;
                }
                component.set("v.msgToPass" ,toastMessage);
            	component.set("v.openModal",true);
                //helper.showMessage('dismissible', 'Error', toastMessage, 'error');
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    clearAllData: function(component, evet, helper){// reset all the vlaues
        component.set("v.isLoading", true);
        var emptyArr = [];
        component.set("v.previewData", emptyArr);
        component.set("v.headerData", emptyArr);
        component.set("v.isValidationPassed", false);
        component.set("v.budgetDataList", emptyArr);
        component.set("v.matchingDataSet", emptyArr);
        component.set("v.isLoading", false);
    },
    downloadCsv: function(component, event, helper){// download sample csv file as per extected file template
        var csv=component.get("v.sampleHeader") + '\n' + component.get("v.sampleRow");
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'KIVolAndDiscBudgetTemplate'+'.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }
})