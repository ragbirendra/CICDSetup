({
    handleFilesChange : function(component, event, helper) {// read file and load initial records        
        debugger;
         var show = component.find("dataTablediv");
        $A.util.removeClass(show,"slds-hide");
        component.set("v.isLoading", true);
        component.set("v.showButton", true);
        component.set("v.enableSave", true);
        component.set("v.showTable",true);
       // component.set("v.noLoad",true);
        var fileAttachedName = event.getSource().get("v.files")[0]["name"];
        component.set("v.fileName", fileAttachedName);
        var files = event.getSource().get("v.files");
        var fileReaderObj = new FileReader();
        fileReaderObj.readAsText(files[0]);
        fileReaderObj.onload = function(){            
            let fileContent = fileReaderObj.result;
            // in excel if user deletes rows the last row might still have \n\r or \r
            // so removing those before splitting
            if(fileContent.endsWith("\r\n")){ // kaustav - changed from \n\r to \r\n
                fileContent = fileContent.substring(0,fileContent.lastIndexOf("\r\n"));
            }
            if(fileContent.endsWith("\n")){ // kaustav - changed from else if to if
                fileContent = fileContent.substring(0,fileContent.lastIndexOf("\n"));
            }
            if(fileContent.endsWith("\r")){ // kaustav - added this if
                fileContent = fileContent.substring(0,fileContent.lastIndexOf("\r"));
            }
            console.log("fileContent" + fileContent);
            let dataRows = fileContent.split('\n');
            console.log("dataRows" + dataRows[0]);
            for(var i=0 ;i< dataRows.length ; ++i){
                if(dataRows[i].includes("\"")){
                    component.set("v.msgToPass" ,'Error occured while parsing the file. Make sure there are no Double Quotes or Commas in file.' +'\n'+
                                  'Please Check row :' +(i+1));
                    component.set("v.openModal",true);
                    component.set("v.isLoading", false);
                    return;
                    
                }
            }
            let headerRow = dataRows[0].replace(/[\n\r]/g, ''); // kaustav
            //headerRow = headerRow.substring(0, headerRow.length - 1);
            headerRow = headerRow.split(','); // kaustav
            console.log('headerRow',headerRow);
            console.log('headerRow'+headerRow);
            var customHeader = $A.get("$Label.c.ABI_Program_Item_CSV_Headers").split(',');
            console.log('customHeaderlist',customHeader);
            console.log('customHeaderlist'+customHeader);
            //console.log('data[0].splitlist',data[0].split(','));
            let matched = false;
            if(headerRow.length == customHeader.length ){
                for(var i=0; i< customHeader.length ; ++i ){
                    if(customHeader[i] == headerRow[i].split(',')){
                        console.log('customHeader',customHeader[i]);
                        console.log('data[0].split'+headerRow[i].split(','));
                        matched = true;
                        console.log('matchedtrue',matched);
                    }else{
                        console.log('customHeader',customHeader[i]);
                        console.log('data[0].split'+headerRow[i].split(','));
                        matched = false;
                        console.log('matchedtrue',matched);
                        break;
                    }
                }
            }else{
                component.set("v.msgToPass" ,'Please use a valid template.' );
                component.set("v.openModal",true);
            }
            let headerJSON = [];
            let initialDataLoadVolume = 0;
            // initial load will be either 200 or total data length whichever is lesser
            initialDataLoadVolume = (dataRows.length - 1) > 200 ? 200: (dataRows.length - 1) ;
            let allDataRows = [];
            let previewData = [];
            if( matched === true && headerRow.length == customHeader.length){
                for(var i=0; i<headerRow.length; i++){
                    var headObj = {};
                    headObj.label = headerRow[i].replace('"','');
                    headObj.fieldName = headerRow[i].replace('"','');
                    headObj.text = "text";
                    headerJSON.push(headObj);
                } 
                
                for (var i=1; i<dataRows.length ; i++){
                    let thisObj = {};
                    let thisRow = dataRows[i].replace(/[\n\r]/g, ''); // kaustav
                    thisRow = thisRow.split(','); // kaustav
                    
                    for(var j=0; j<thisRow.length; j++){
                        thisObj[headerRow[j]] = thisRow[j]; //dynamically add attributes to the json
                        thisObj.keyAttr = i; // mandatory - key attribute
                        
                    } 
                    
                    if(previewData.length <= initialDataLoadVolume){
                        // previewData.replace(/"/g,' ');
                        previewData.push(thisObj); // first set of data only on load
                    }                
                    allDataRows.push(thisObj);  // store all data rows from file but do not load             
                    
                }
                console.log('previewData',previewData);
                console.log('length',allDataRows.length);
                console.log("v.totalDataSet",allDataRows);
                component.set("v.previewData",previewData);
                component.set("v.headerData", headerJSON);
                component.set("v.isLoading", false);
                component.set("v.totalDataSet",allDataRows);
                component.set("v.totalRowsToLoad",allDataRows.length);
                component.set("v.totalRowsLoaded",previewData.length);
            }else{
                //alert('File format is incorrect. Please use the correct the file templete and upload again!');
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_IncorrectFileFormate"));
                component.set("v.openModal",true);
                component.set("v.isLoading", false);
            }
        };
    },
    downloadCsv : function(component,event,helper){
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component, event, helper);   
        if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'Program Item Upload Template'+'.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    },
    downloadCsvforProduct : function(component,event,helper){
        var csv = helper.convertArrayOfObjectsToCSV(component, event, helper);   
        if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'Program Type'+'.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    },
    clear: function (component, event, helper) {
      
        var hide = component.find("dataTablediv");
        $A.util.addClass(hide,"slds-hide");
        component.set("v.fileName", 'No File Selected');
        component.set("v.totalRowsLoaded",0);
        component.set("v.totalRowsToLoad",0);
        
    },
    continueToLoad: function(component, event, helper){ // function for infinite loading
         component.set("v.isLoading", true);               
            component.set("v.loadMoreStatus", "Loading more data...");
            setTimeout($A.getCallback(function(){
                console.log('preview data',component.get("v.previewData"));
                console.log('total data',component.get("v.totalDataSet"));
                let currentPreviewDataList = component.get("v.previewData");
                let totalDataSet = component.get("v.totalDataSet");
                // condition for checking if all data rows are already loaded
                if(currentPreviewDataList.length == totalDataSet.length){ 
                    component.set("v.enableInfiniteLoading",false);
                    component.set("v.loadMoreStatus", "No more data to load");
                    component.set("v.isLoading", false); 
                    return false;
                }
                // all data rows were not loaded so proceed with further data load
                let initialDataLoadVolume = 0;        
                let currentLastIndex = currentPreviewDataList.length;
                let dataToAdd = [];
                initialDataLoadVolume = totalDataSet.length - currentLastIndex >  200 ? 200 : totalDataSet.length - currentLastIndex ;
                for(var i=currentLastIndex; i<currentLastIndex+initialDataLoadVolume; i++){
                    dataToAdd.push(totalDataSet[i]);
                }
                let newDataSet = currentPreviewDataList.concat(dataToAdd);
                component.set("v.previewData",newDataSet);
                component.set("v.totalRowsLoaded",newDataSet.length);
                component.set("v.loadMoreStatus", "");
                component.set("v.isLoading", false); 
            }), 100);
      
        
    },
    onSave: function (component, event, helper) {
        component.set("v.isLoading",true);
        helper.saveProgramItems(component,event,helper);   
        
    },
    viewImageDetails : function(component, event, helper){ // row level action handler
        // in actual code the image needs to be fetched and set to attributes in this method
        // the next 2 lines show how to access row properties for the clicked row
        // in actual implementation we have to get the id and fetch the attachment url if not
        // already present with us and then set them as attributes and open the modal window
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log("#### able to access row properties #### " + row.keyAttr);
        component.set("v.doShowModal", true);
    },
    closeModal: function(component, event, helper){
        component.set("v.doShowModal", false);
    },
    previewRecords : function(component, event, helper){
        var newEvent = $A.get("e.force:navigateToComponent");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__PreviewBrandProgramItem',
                pageName: 'PreviewProgramItems'
            }
        };
        component.set("v.pageReference", pageReference);
        const navService = component.find('navService');
        const handleUrl = (url) => {
            window.open(url);
        };
            const handleError = (error) => {
            console.log(error);
        };
            navService.generateUrl(pageReference).then(handleUrl, handleError);
            
        },
            
            ValidateRecords:function(component, event, helper){ 
                var listToValidate= component.get("v.totalDataSet");
                console.log('listOfData===>',listToValidate);
                var alphaExp = /^[a-zA-Z0-9 ;-]+$/;
                var alphaExpProductName = /^[a-zA-Z0-9 $()\/''-.]+$/;
                var descripValidtn = /^[^,]+$;/;
                var duplicateChk= new Set();
                var onlyNumberExp = /^[0-9.]+$/;
                var dateExp = /^\d{1,2}\/\d{1,2}\/\d{4}$/ ;// mm/dd/yyyy \d{4}-\d{2}-\d{2}  /^\d{2}\/\d{2}\/\d{4}$/
                var errorArr=[];
                var flag = true;
                for(var i=0; i<listToValidate.length;i++){
                    var ProgramStartDate = listToValidate[i].ProgramStartDate;
                    var ProgramEndDate = listToValidate[i].ProgramEndDate;
                    var PlanningStartDate = listToValidate[i].PlanningStartDate;
                    var PlanningEndDate = listToValidate[i].PlanningEndDate;
                    var ProgramStartDateCompare = new Date(listToValidate[i].ProgramStartDate); 
                    var ProgramEndDateCompare = new Date(listToValidate[i].ProgramEndDate); 
                    var PlanningStartDateCompare = new Date(listToValidate[i].PlanningStartDate); 
                    var PlanningEndDateCompare = new Date(listToValidate[i].PlanningEndDate); 
                    var ProgramName=  listToValidate[i].ProgramName;
                    var BrandName=  listToValidate[i].BrandName;
                    var SAPItemNumber= listToValidate[i].SAPItemNumber;
                    var TempItemNumber=listToValidate[i].TempItemNumber;
                    var MenuCategory = listToValidate[i].MenuCategory;
                    var ItemType = listToValidate[i].ItemType;
                    var Quantity = listToValidate[i].QuantityPerUOM;
                    var StandardPrice =  listToValidate[i].StandardPrice;
                    var FullPriceToRep =  listToValidate[i].FullPriceToRep;
                    var BusinessLine =  listToValidate[i].BusinessLine;
                    var year =  listToValidate[i].Year;
                    var ProductName =  listToValidate[i].ProductName;
                    var isUserPaid =  listToValidate[i].isUserPaid;
                    var ItemClassification =  listToValidate[i].ItemClassification;
                    //var IHItemClassification =  listToValidate[i].IHItemClassification;
                    
                    if(!duplicateChk.has(ProgramName + ProductName + BrandName +SAPItemNumber +TempItemNumber + isUserPaid + year + BusinessLine)){
                        duplicateChk.add(ProgramName + ProductName + BrandName +SAPItemNumber +TempItemNumber + isUserPaid + year + BusinessLine);
                        console.log('duplicateChk' + duplicateChk);
                    }
                    else{
                        errorArr.push("Duplicate row found. Please check Row:"+(i+1));
                    }
                    
                    var a = i+1;
                    
                    var formattedProgramstartDate = ProgramStartDateCompare.getMonth()+1+ '/' + ProgramStartDateCompare.getDate() + '/' +  ProgramStartDateCompare.getFullYear();
                    console.log('formattedProgramstartDate',formattedProgramstartDate);
                    if(formattedProgramstartDate == 'NaN/NaN/NaN' ||formattedProgramstartDate == undefined ){
                        errorArr.push("Incorrect Date: Use MM/DD/YYYY formate at row" +a);
                    }
                    
                    var formattedProgramEndDate = ProgramEndDateCompare.getMonth()+1+ '/' + ProgramEndDateCompare.getDate() + '/' +  ProgramEndDateCompare.getFullYear();
                    console.log('formattedProgramstartDate',formattedProgramstartDate);
                    if(formattedProgramEndDate == 'NaN/NaN/NaN' ||formattedProgramEndDate == undefined){
                        errorArr.push("Incorrect Date: Use MM/DD/YYYY formate at row" +a);
                    }
                    var formattedPlanningStartDate = PlanningStartDateCompare.getMonth()+1+ '/' + PlanningStartDateCompare.getDate() + '/' +  PlanningStartDateCompare.getFullYear();
                    console.log('formattedPlanningStartDate',formattedPlanningStartDate);
                    if(formattedPlanningStartDate == 'NaN/NaN/NaN' ||formattedPlanningStartDate == undefined){
                        errorArr.push("Incorrect Date: Use MM/DD/YYYY formate at row" +a);
                    }
                    var formattedPlanningEndDate = PlanningEndDateCompare.getMonth()+1+ '/' + PlanningEndDateCompare.getDate() + '/' +  PlanningEndDateCompare.getFullYear();
                    console.log('PlanningEndDateCompare',formattedProgramstartDate);
                    if(formattedPlanningEndDate == 'NaN/NaN/NaN' ||formattedPlanningEndDate == undefined){
                        errorArr.push("Incorrect Date: Use MM/DD/YYYY formate at row"+a);
                    }
                    
                    if(ItemType == '' || ItemType==null){
                        errorArr.push($A.get("$Label.c.ABI_OP_ItemType") +a);
                    }
                    if(isUserPaid == '' || isUserPaid==null){
                        errorArr.push($A.get("$Label.c.ABI_OP_UserPaid") +a);
                    }
                    if(BusinessLine == '' || BusinessLine==null){
                        errorArr.push($A.get("$Label.c.ABI_OP_BusinessLine") +a);
                    }
                    if(ProductName == '' || ProductName==null){
                        errorArr.push($A.get("$Label.c.ABI_OP_ProductName") +a);
                    }
                    if(!ProductName.match(alphaExpProductName)){
                        errorArr.push($A.get("$Label.c.ABI_OP_UnderscoreinProductName") +a);
                        //($A.get("$Label.c.ABI_OP_UnderscoreinProductName") +a);
                    }
                    if(year == '' || year==null){
                        errorArr.push($A.get("$Label.c.ABI_OP_Year") +a);
                    }
                    if(ItemClassification == '' || ItemClassification==null){
                        errorArr.push($A.get("$Label.c.ABI_OP_ItemClassification") +a);
                    }
                    if(ItemClassification !== ''){
                        if(!(ItemClassification =='Driver' || ItemClassification =='Visibility'|| ItemClassification =='Promotional')){
                            errorArr.push($A.get("$Label.c.ABI_OP_ItemClassificationVals") +a);
                        }
                    }
                    /*   if(IHItemClassification !== ''){
                        if(!(IHItemClassification =='Driver' || IHItemClassification =='Visibility'|| IHItemClassification =='Promotional')){
                            errorArr.push("Please put correct value for IH Item Classification. Values can be Driver,Visibility or Promotional. Please check Row:" +a);
                        }
                    }
                    */
                    if(!(BusinessLine =='Out of Home' || BusinessLine =='In Home')){
                        errorArr.push($A.get("$Label.c.ABI_OP_BusinessLineVals") +a);
                    }
                    if(listToValidate[0].BusinessLine !== listToValidate[i].BusinessLine){
                        if(flag ==  true){
                            errorArr.push("Business line should be same for all Programs uploaded. Either Out of Home or In Home");
                            flag = false;
                        }
                        
                    } 
                    if(!Quantity.match(onlyNumberExp)){
                        errorArr.push($A.get("$Label.c.ABI_OP_Quantity") +a);
                    }
                    if(!StandardPrice.match(onlyNumberExp)){
                        errorArr.push($A.get("$Label.c.ABI_OP_StandardPrice") +a);
                    }
                    if(!FullPriceToRep.match(onlyNumberExp)){
                        errorArr.push($A.get("$Label.c.ABI_OP_FullPrice") +a);
                    }
                    
                    if(MenuCategory == '' || MenuCategory==null){
                        errorArr.push($A.get("$Label.c.ABI_OP_MenuCategory") +a);
                    }
                    if(!SAPItemNumber && !TempItemNumber){
                        //alert("Either SAPItemNumber or TempItemNumber should have value,both cannot be blank");
                        errorArr.push("Either enter SAP or Temp Item Number. Please check Row:" +a);
                    }
                    if(TempItemNumber !== ''){
                        if(!TempItemNumber.match(alphaExp)){
                            errorArr.push("Tempoprary number cannot not have special Characters. Please check Row:" +a);
                        }
                    }
                    
                    if(SAPItemNumber !="" && SAPItemNumber.length != '7'){
                        errorArr.push($A.get("$Label.c.ABI_OP_IncorrectSAPID") +a);
                    }
                    
                    if(SAPItemNumber !=""  && TempItemNumber !=""){
                        errorArr.push($A.get("$Label.c.ABI_OP_SAPID") +a);
                    }
                    if(ProgramStartDateCompare>ProgramEndDateCompare){
                        errorArr.push($A.get("$Label.c.ABI_OP_PrgStartDateEndDate") +a);
                    }
                    if(PlanningStartDateCompare>PlanningEndDateCompare)
                    {
                        errorArr.push($A.get("$Label.c.ABI_OP_PlanningEndDateandStartDate") +a); 
                    } 
                    if(!PlanningStartDate.match(dateExp) || PlanningStartDate==null || PlanningStartDate== ''){
                        errorArr.push($A.get("$Label.c.ABI_OP_NotNullPlanningSD") +a);
                    }
                    if(!PlanningEndDate.match(dateExp) || PlanningEndDate==null || PlanningEndDate== ''){
                        errorArr.push($A.get("$Label.c.ABI_OP_NotNullPlanningED") +a);
                    }
                    if(!ProgramStartDate.match(dateExp) || ProgramStartDate==null || ProgramStartDate== ''){
                        errorArr.push($A.get("$Label.c.ABI_OP_NotNullPrgstartDate") +a);
                    }
                    if(!ProgramEndDate.match(dateExp) ||  ProgramEndDate==null || ProgramEndDate== ''){
                        errorArr.push($A.get("$Label.c.ABI_OP_NotNullPrgEndDate") +a);
                    }
                    
                    if(!BrandName.match(alphaExp) || BrandName==null || BrandName== ''){
                        errorArr.push($A.get("$Label.c.ABI_OP_BrandNameNotNull") +a);
                    }
                    if( ProgramName==null || ProgramName== ''){
                        
                        errorArr.push($A.get("$Label.c.ABI_OP_ProgramNameCannotBeNull") +a);
                        
                    }
                }
                if(errorArr.length > 0){
                    var arr=[];
                    // alert(errorArr.join("\n"));
                    arr=errorArr.join("\n");
                    component.set("v.msgToPass",errorArr);
                    component.set("v.openModal",true);
                }
                if(errorArr.length ==0){
                    component.set("v.msgToPass",$A.get("$Label.c.ABI_OP_FileValidated"));
                    component.set("v.openModal",true);
                    component.set("v.enableSave", false);
                    component.set("v.flag",false);
                } 
            },
        })