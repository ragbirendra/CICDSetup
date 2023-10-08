({
    doInit:function (component, event, helper){
    var numYear = [];
    
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    var currYear = $A.localizationService.formatDate(today, "yyyy");
    numYear.push(parseInt(currYear)-1);
    numYear.push(parseInt(currYear));
    numYear.push(parseInt(currYear)+1);
    numYear.push(parseInt(currYear)+2);
    
    component.set("v.exportYearList", numYear);
      var uploadTypeVal='shoppedKit';
      var action = component.get("c.excelheaderValidation");
        action.setParams({ 
            "uploadType" : uploadTypeVal
        });
       action.setCallback(this, function(response){
            var state = response.getState();
           if (state === "SUCCESS") {    
              var headerResult = response.getReturnValue();
              component.set("v.fileHeader", headerResult);
              console.log(headerResult);
               
           }else if (state === "INCOMPLETE") {
                   
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ServerError") );
                component.set("v.openModal",true);
            }
           else if(state === "ERROR"){
                var errors = response.getError();
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApexSideError"));
            	component.set("v.openModal",true);
           }
              
        }); 
        $A.enqueueAction(action); 
        
    },
    
    
    onFileUpload: function (component, event, helper) {
        component.set("v.showTable", true);
        component.set("v.showButtons", true);
        component.set("v.isLoading", true );
        var fileAttachedName = event.getSource().get("v.files")[0]["name"];
        component.set("v.fileName", fileAttachedName);
        var file = event.getSource().get('v.files')[0];
        console.log('File Name-->',file);
        console.log('file length',file.length);
        if(file.name.endsWith(".csv")){
            var reader = new FileReader();
            reader.readAsText(file, 'ISO-8859-1');
            reader.onload = function() {
                helper.parseCSVAndLoadRecords(component, event, helper, reader.result);  
            }
            return false; 
         }else{
            
            console.log('file is invalid-->>');
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
    },
    validate: function (component, event, helper) {
        var resultToSave;
        var YearList = component.get("v.exportYearList")
        var businessLineSet = new Set();
        var header = component.get("v.fileHeader");
        var str1 = component.get("v.excelHeader")
        var str = str1.split(',');
        var headerStr = header.split(',');
        var dateExp = /^\d{1,2}\/\d{1,2}\/\d{4}$/ ;
        if((str[0] != headerStr[0]) ||(str[1] != headerStr[1]) ||(str[2] != headerStr[2] )||(str[3] != headerStr[3]) ||(str[4] != headerStr[4]) ||(str[5] != headerStr[5]) ||(str[6] != headerStr[6])||(str[7] != headerStr[7]) ||(str[8] != headerStr[8])||(!str[9].includes(headerStr[9])))
        {
            component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_POCP_ExcelFormatError") );
            component.set("v.openModal",true);
            return;
        }
            resultToSave= component.get("v.listDataToDisplay") ;
       
        var blankValueRecords =[];
        var nonBlankVlaueRecords=[];
        var allVlaueRecords=[];
        for(var i=0;i<resultToSave.length;i++)
        {
            businessLineSet.add(resultToSave[i].BusinessLine);
            if(resultToSave[i].ShopkitSAPNumber !='' && resultToSave[i].ShopkitTemporaryItemNumbers !='' ){
                //alert('Please insert Either SAP item number or Temp Item Number...');
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_SAPorTEMPValidation")+' Please check Row number:'+(i+1));
            	component.set("v.openModal",true);
                return;
            }
            
            if((resultToSave[i].ShopkitSAPNumber.length >7) || ((resultToSave[i].ShopkitSAPNumber.length<7)&&(resultToSave[i].ShopkitSAPNumber.length!=0))){
                //alert('Invalid SAP item number...');
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_SAPNumberIncorrectValidation")+' Please check Row number:'+(i+1) );
            	component.set("v.openModal",true);
                return;
            }
            var shopkitStartDate = new Date(resultToSave[i].ShopkitStartDate);
            var shopkitStartDateMatch = resultToSave[i].ShopkitStartDate;
            var formattedshopkitStartDate = shopkitStartDate.getMonth()+1+ '/' + shopkitStartDate.getDate() + '/' +  shopkitStartDate.getFullYear();
                console.log('formattedshopkitStartDate',formattedshopkitStartDate);
                if(formattedshopkitStartDate == 'NaN/NaN/NaN' ||formattedshopkitStartDate == undefined ){
                    component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_StartDateValidation")+' Please check Row number:'+(i+1) );
                component.set("v.openModal",true);
                return;
                 }
            var shopkitEndDate = new Date(resultToSave[i].ShopkitEndDate);
            var shopkitEndDateMatch = resultToSave[i].ShopkitEndDate;
            var formattedshopkitEndDate = shopkitEndDate.getMonth()+1+ '/' + shopkitEndDate.getDate() + '/' +  shopkitEndDate.getFullYear();
                console.log('formattedshopkitEndDate',formattedshopkitEndDate);
                if(formattedshopkitEndDate == 'NaN/NaN/NaN' ||formattedshopkitEndDate == undefined ){
                    component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_EndDateValidation")+' Please check Row number:'+(i+1) );
                component.set("v.openModal",true);
                return;
                 }
            if(!shopkitStartDateMatch.match(dateExp) || shopkitStartDateMatch==null || shopkitStartDateMatch== ''){
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_StartDateValidation")+' Please check Row number:'+(i+1) );
                component.set("v.openModal",true);
                return;
                    }
            if(!shopkitEndDateMatch.match(dateExp) ||  shopkitEndDateMatch==null || shopkitEndDateMatch== ''){
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_EndDateValidation")+' Please check Row number:'+(i+1) );
                component.set("v.openModal",true);
                return;
                    }
            var d1 = Date.parse(resultToSave[i].ShopkitStartDate);
            var d2 = Date.parse(resultToSave[i].ShopkitEndDate);
              if (d1 > d2) {
                //alert ("Start Date Should not be Greater than End Date !!!");
                    component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_StartDateGreater")+' Please check Row number:'+(i+1));
            	component.set("v.openModal",true);
                  return;
              }
            
            if(isNaN(resultToSave[i].ShopkitSAPNumber) ||isNaN(resultToSave[i].ShopkitPrice) || isNaN(resultToSave[i].ShopkitQty)|| isNaN(resultToSave[i].Year)){
               //alert ("Item SAP Number ,Price and quantity should not contain any Character  !!!");
               component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_NAN_SAPPriceYearQuantity")+' Please check Row number:'+(i+1) );
               component.set("v.openModal",true); 
                  return; 
            }
            if(YearList.indexOf(parseInt(resultToSave[i].Year))==-1)
            {
                //alert('Year only should be Previous year, current Year or Next Year (YYYY) !!!!');
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_YearSelection")+' Please check Row number:'+(i+1) );
            	component.set("v.openModal",true);
                return;
            }
            if(resultToSave[i].BusinessLine !='Out of Home' && resultToSave[i].BusinessLine !='In Home'){
              component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_BusinessLineSelection")+' Please check Row number:'+(i+1) );
              component.set("v.openModal",true);
                 return;
            }
            console.log('in for loop'+resultToSave[0].BrandName);
            if(resultToSave[i].ShoppedKitName =='' || resultToSave[i].ProgramName =='' || resultToSave[i].ShopkitStartDate =='' || resultToSave[i].ShopkitEndDate =='' || resultToSave[i].ShopkitPrice =='' || (resultToSave[i].ShopkitSAPNumber =='' && resultToSave[i].ShopkitTemporaryItemNumbers =='' ) || (resultToSave[i].ShopkitSAPNumber !='' && resultToSave[i].ShopkitTemporaryItemNumbers !='' ) || resultToSave[i].ShopkitQty ==''|| resultToSave[i].Year ==''|| resultToSave[i].BusinessLine =='')
            {
                blankValueRecords.push(resultToSave[i]);
                allVlaueRecords.push(resultToSave[i]);
                console.log('in in condition check');
            }
            else
            {
                nonBlankVlaueRecords.push(resultToSave[i]);
                allVlaueRecords.push(resultToSave[i]);
            }
            
        }
        if(businessLineSet.size>1)
        {
         component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_BusinessLineUniform") );
         component.set("v.openModal",true);
         return;   
        }
        if(blankValueRecords.length > 0){
            //alert('Please fill all the values');
            component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_FillAllValue") );
            component.set("v.openModal",true);
            return;
        }
        else{
            //alert('all values are in correct format Please save to further Process');
            component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ValidationSuccess") );
            component.set("v.openModal",true);
            component.set("v.validationflagDis",true);
        }
        component.set("v.listInfo",allVlaueRecords);
        component.set("v.validationFlag",false);
    },
    onSave: function (component, event, helper) {
        var resultToSave;
        var seletedItem= component.get("v.selectedPC");
        if(seletedItem=='All'){
            resultToSave= component.get("v.listDataToDisplay") ;
        }
        else
        {
            resultToSave=component.get("v.listDataToDisplay") ;
        }
        var blankValueRecords =[];
        var nonBlankVlaueRecords=[];
        var allVlaueRecords=[];
        
        for(var i=0;i<resultToSave.length;i++)
        { 
            var dat = resultToSave[i].ShopkitStartDate;
            var yourdate = dat.split("/").reverse();
            var tmp = yourdate[2];
            yourdate[2] = yourdate[1];
            yourdate[1] = tmp;
            resultToSave[i].ShopkitStartDate = yourdate.join("-");
            
            var dat = resultToSave[i].ShopkitEndDate;
            var yourdate = dat.split("/").reverse();
            var tmp = yourdate[2];
            yourdate[2] = yourdate[1];
            yourdate[1] = tmp;
            resultToSave[i].ShopkitEndDate = yourdate.join("-");
            nonBlankVlaueRecords.push(resultToSave[i]);
            allVlaueRecords.push(resultToSave[i]);     
        }

       helper.saveBrand(component,event,helper);
       component.set("v.listInfo",allVlaueRecords);
      
    },
    fetchParticularItem:function(component , event , helper){
        var selectedItem=component.get("v.selectedPC");
        helper.filterRecords(component, event, helper);
        
    },
    clear:function(component , event , helper){
               //location.reload(); // commenting out to stop from refreshing
		// resetting the variables on clear button
		component.set("v.showTable",false);
        component.set("v.fileName", 'No file selected'); 
        var emptyArr = [];
        component.set("v.OptionsPC", emptyArr); //'uniqueArray'
        component.set("v.listData",emptyArr);
        component.set("v.listDataToDisplay",emptyArr);
        component.set("v.validationflagDis",false);
    },
    previewRecords : function(component, event, helper){
      var newEvent = $A.get("e.force:navigateToComponent");
      var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ShoppedKitApprovalScreen',
                pageName: 'ShoppedKitApproval'
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
            downloadCsv : function(component,event,helper){
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component, event, helper);   
        if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'Shopped Kit Upload Template'+'.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }
    
})