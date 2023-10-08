({
    onFileUpload: function (component, event, helper) {
        component.set("v.showTable", true);
        component.set("v.showButtons", true);
        component.set("v.isLoading", true );
        var fileAttachedName = event.getSource().get("v.files")[0]["name"];
        component.set("v.fileName", fileAttachedName);
        var file = event.getSource().get('v.files')[0];
        if(file.name.endsWith(".csv")){
            var reader = new FileReader();
            reader.readAsText(event.getSource().get('v.files')[0], 'ISO-8859-1');
            reader.onload = function() {
                helper.parseCSVAndLoadRecords(component, event, helper, reader.result);
                
            }
            return false; 
        }else{
            
            component.set("v.isLoading",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Failure Message',
                message: 'Please Upload CSV File!',
                duration:' 5000',
                key: 'info_alt',
                type: 'success',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        component.set("v.isLoading",false);
    },
    doInit : function(component, event, helper) {
        var numYear = [];
        var numYerBO= [];
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var currYear = $A.localizationService.formatDate(today, "yyyy");
        numYear.push(parseInt(currYear)-1);
        numYear.push(parseInt(currYear));
        numYear.push(parseInt(currYear)+1);
        numYear.push(parseInt(currYear)+2);
        numYerBO.push(parseInt(currYear));
        numYerBO.push(parseInt(currYear)+1);
        numYerBO.push(parseInt(currYear)+2);    
        component.set("v.exportYearList", numYear);
        component.set("v.exportYearListForBO", numYerBO);
        
        var uploadTypeVal='Budget';
        var action = component.get("c.excelheaderValidation");
        action.setParams({ 
            "uploadType" : uploadTypeVal
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {    
                var headerResult = response.getReturnValue();
                component.set("v.fileHeader", headerResult);
                
                
            }else{
                //alert('Excel Header validation Failed');
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApexSideError") );
                component.set("v.openModal",true);
            }
            
        }); 
        $A.enqueueAction(action);
        helper.fetchDistAndTerritoryRecord(component,event,helper);
    },
    onSave: function (component, event, helper) {
        var resultToSave;
        var allVlaueRecords=[];
        resultToSave= component.get("v.listDataToDisplay") ;
        //component.set("v.isLoading", true );
        for(var i=0;i<resultToSave.length;i++) {
            allVlaueRecords.push(resultToSave[i]);
        }
        helper.saveBudget(component,event,helper);
        component.set("v.listInfo",allVlaueRecords); 
        component.set("v.isLoading", false);
        
    },
    
    ValidateRec: function (component, event, helper) {
        
        component.set("v.isLoading", true);
        var resultToSave; 
        var YearList = component.get("v.exportYearList")
        var busLineSet = new Set();
        resultToSave= component.get("v.listDataToDisplay") ;
        var errorMsg = [];
        var OnpointDisCodeArr = component.get("v.OnpointDisCodeArr");
        var SalesTerrCodeArr = component.get("v.SalesTerrCodeArr");
        OnpointDisCodeArr.push("National");
        var str = component.get("v.headerVal");
        str = str.split(',');
        var headerStr = component.get("v.fileHeader");
        headerStr = headerStr.split(',');
        if((str[0] != headerStr[0]) ||(str[1] != headerStr[1]) ||(str[2] != headerStr[2] )||(str[3] != headerStr[3]) ||(str[4] != headerStr[4]) ||(str[5] != headerStr[5]) ||(str[6] != headerStr[6]) ||(str[7] != headerStr[7]) ||(str[8] != headerStr[8]) ||(!str[9].includes(headerStr[9])))
        {
            //alert('Please upload Correct Header Excel !!!');
            component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_POCP_ExcelFormatError") );
            component.set("v.openModal",true);
            component.set("v.isLoading", false);
            return;
        }
        for(var i=0;i<resultToSave.length;i++)
        {     
            
            if(resultToSave[i].DistrictName =='' || resultToSave[i].DistrictCode =='' || resultToSave[i].Year =='' || resultToSave[i].BusinessLine =='' || resultToSave[i].Region =='' || resultToSave[i].TerritoryName =='' || resultToSave[i].TerritoryCode ==''  || resultToSave[i].DiscretionaryBudget =='' || resultToSave[i].Brand =='' || resultToSave[i].TerritoryBrandBudget =='' ){  
                errorMsg.push($A.get("$Label.c.ABI_OP_FillAllValue")+' Check Row No:'+(i+1));  
            }
            if(!OnpointDisCodeArr.includes(resultToSave[i].DistrictCode)){
                errorMsg.push('District Code is not valid, Please' +'Check Row No::'+(i+1));
            }
            if(!SalesTerrCodeArr.includes(resultToSave[i].TerritoryCode)){
                errorMsg.push('Territory Code is not valid, Please '+'Check Row No::'+(i+1));
            }
            if(resultToSave[i].BusinessLine !='Out of Home' && resultToSave[i].BusinessLine  !='In Home'){
                errorMsg.push($A.get("$Label.c.ABI_OP_BusinessLineSelection")+'Check Row No::'+(i+1));  
            }
            busLineSet.add(resultToSave[i].BusinessLine);        
            if(YearList.indexOf(parseInt(resultToSave[i].Year))==-1){
                errorMsg.push($A.get("$Label.c.ABI_OP_YearSelection")+' Please Check Row No::'+(i+1));   
            } 
            if(isNaN(resultToSave[i].TerritoryBrandBudget)||isNaN(resultToSave[i].DiscretionaryBudget)){
                errorMsg.push($A.get("$Label.c.ABI_OP_TerrBudgetCharacter")+' Please Check Row No::'+(i+1));
            }
        }
        if(busLineSet.size>1){
            errorMsg.push($A.get("$Label.c.ABI_OP_BusinessLineUniform"));   
        }
        
        if(typeof errorMsg != "undefined" && errorMsg != null && errorMsg.length != null && errorMsg.length > 0)
        {
            var allmsg=[];
            allmsg = errorMsg.join("\n");
            component.set("v.isLoading", false);
            component.set("v.msgToPass" ,errorMsg );
            component.set("v.openModal",true);
            return; 
        }
        component.set("v.isLoading", false);
        component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ValidationSuccess") );
        component.set("v.openModal",true);
        component.set("v.saveFlag",false);
        component.set("v.rowDisableFlag",false);
        //alert('Validated Successfully !!!! Now You are able to Save Records In Stagging Area......');
        
    },
    fetchParticularItem:function(component , event , helper){
        var selectedItem = component.get("v.selectedPC");   
        helper.filterRecords(component, event, helper);    
    },
    clear:function(component , event , helper){
        component.set("v.showTable",false);
        // resetting a few more variables
        component.set("v.fileName", 'No file selected'); 
        var emptyArr = [];
        component.set("v.OptionsPC", emptyArr); //'uniqueArray'
        component.set("v.listData",emptyArr);
        component.set("v.listDataToDisplay",emptyArr);
        component.set("v.saveFlag",true);
        component.set("v.pushtoOnplanFlag", true);
    },
    
    ExportBudget : function(component, event, helper){
        helper.ExportBudgetData(component, event, helper);
    },
    pushOnplan : function(component, event, helper){
        helper.pushOnplanBatchRun(component, event, helper);
    },
    downloadCsv : function(component,event,helper){
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component, event, helper);   
        if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'Budget Upload Template'+'.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    },
    onBudgetBactchCall: function(component,event,helper){
        var year = component.get("v.selectedYrForBO");
        var bl= component.get("v.selectedBL");
        //console.log('@@@@ year',year);
        //console.log('@@@@ bl',bl);
        if(year!= '-----' && bl != '-----')
        {
            var action = component.get("c.createBudgetBOC");			
            action.setParams({ 
                "year": year,
                "bussinessLine":bl
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                var returnValue =  response.getReturnValue();
                if (returnValue.isSuccess) {   
                    //alert('Back budget load process is initiated, once it complete will send mail to Myriam Wilhelmy'); 
                    component.set("v.msgToPass" ,returnValue.successMsg);
                    component.set("v.openModal",true);
                }
                else {
                    component.set("v.msgToPass" ,returnValue.errorMsg);
                    component.set("v.openModal",true);
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            //alert(' Please select year and Bussiness line');
            component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_BusAndYear"));
            component.set("v.openModal",true);
        }
    },
    allowToShow : function(component,event,helper){
        var selYear= component.get("v.selectedYrForBO");
        //console.log('==channelName--',channelName);
        if(selYear=='selectyear')
        {
            component.set("v.ShowDataTOshow",true); 
        }
        else{
            component.set("v.ShowDataTOshow",false);
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