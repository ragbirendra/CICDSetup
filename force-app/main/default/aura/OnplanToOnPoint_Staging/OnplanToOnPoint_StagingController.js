({
    doInit: function (component,helper) {
        component.set("v.loadSpinner", true);
        // get the current date
        var d = new Date();
        var n = d.getFullYear();
        var yearOptions = [];
        yearOptions.push(n);
        yearOptions.push(n+1);
        yearOptions.push(n+2);
        component.set("v.yearOptions",yearOptions);
        var actionNew = component.get("c.getUserInformation");
        actionNew.setCallback(this, function (response) {
            var state= response.getState();
            var userAdmin=  response.getReturnValue();
            console.log('---userAdmin====',userAdmin);
            console.log('---state====',state);
            if(userAdmin.isSuccess){
                component.set("v.loadSpinner", false);
            }
            else
            {
                component.set("v.loadSpinner", false);
                component.set("v.msgToPass" ,'Only Trade Activation Admin can create/modify allocation');
                component.set("v.openModal",true); 
            }
        });
        $A.enqueueAction(actionNew); 
        
    },
    buildBrandList: function(component, event, helper){
        component.set("v.loadSpinner", true);
        var programListEmpty=[];
        component.set("v.ProgramList",programListEmpty);
        component.set("v.allData",programListEmpty);
        component.set("v.allocationTOshow",true);
        component.set("v.ShowMarkAsComplete",true);
        component.set("v.ShowReopenProgram",true);
        component.set("v.ShowDataTOshow",true);
        component.set("v.isProgramCompletionToShow", false);
        
        
        //component.set("v.selectedLookUpRecordSKU",'');
        var selectedYear = "";
        var selBusLine = "";
        selectedYear = component.get("v.selectedBudgetYear");
        selBusLine = component.get("v.selectedBusinessLine");
        if(selectedYear != "" && selBusLine != ""){
            var action = component.get("c.getBrandData");
            action.setParams({
                "yearVal": selectedYear,
                "businessLineVal" : selBusLine
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
                    var records = response.getReturnValue();
                    console.log('records',response.getReturnValue());
                    component.set("v.brandList", records);                        
                    //component.set("v.data", records); 
                    component.set("v.showBrandList", false); 
                    component.set("v.loadSpinner", false); 
                } else {
                    console.log('error');
                    component.set("v.loadSpinner", false);
                    component.set("v.msgToPass" ,'Error while fetching brand list');
                    component.set("v.openModal",true);                     
                }
            });                
            $A.enqueueAction(action);
        }else{
            component.set("v.loadSpinner", false);
            component.set("v.showBrandList", true); 
            component.set("v.msgToPass" ,'Please select year and business line to proceed');
            component.set("v.openModal",true); 
        }        
    },
    calculateCostAndPrice : function(component, event, helper) {
        //var target = event.target;
        var rowIndex = event.getSource().get("v.tabindex");
        var data= component.get("v.originalDataSet");
        console.log('data-- ',data);
        var originaldata= component.get("v.originalDataSet");
        console.log('--originaldata---',originaldata);
        var originaldata3= component.get("v.data");
        console.log('--Data 3---',originaldata3);
        console.log("Row No : " + rowIndex);
        console.log("Row No  Data: " + data[rowIndex].qty);
        data[rowIndex].totalSpend=data[rowIndex].qty* data[rowIndex].itemPrice;
        console.log('data Total Spend ---'+data[rowIndex].totalSpend); 
        component.set("v.allData",originaldata);
        var id=data[rowIndex].Id;
        var qty= data[rowIndex].qty;
        helper.updateQuantity(component,id,qty);         
        
    },
    replaceItem: function(component, event, helper){
        var currentChangeData= component.get("v.allData");
        console.log('--currentChangeData---',currentChangeData); // kaustav - just added the [0].skuNumber part
        var originaldata= component.get("v.originalDataSet");
        console.log('--originaldata---',originaldata);
        console.log('--originaldata---',originaldata); // kaustav - - just added the [0].skuNumber part
        var data= component.get("v.data");
        console.log('--data---',data);
        // var oldRow=originaldata[rowIndex];
        //console.log('--oldRow---',oldRow);
        //  var newRow = currentChangeData[rowIndex];
        // console.log('--newRow---',newRow);
        helper.mergeItem(component, event, currentChangeData, originaldata);
        var checkCmp = component.find("checkbox");
        checkCmp.set("v.value", false);
        
        
    },
    downloadCsv : function(component,event,helper){
        var brandName=component.get("v.selectedBrand"); 
        var programName= component.get("v.selectedProgram");
        helper.fetchDataToReview(component,brandName,programName);
    },
    
    fetchProgramList : function(component,event,helper){
        var programListEmpty=[];
        component.set("v.ProgramList",programListEmpty);
        component.set("v.allData",programListEmpty);
        var brandName = component.get("v.selectedBrand"); 
        component.set("v.selectedProgram",'None');
        component.set("v.ShowMarkAsComplete",true); 
        component.set("v.ShowReopenProgram",true); 
        component.set("v.isProgramCompletionToShow", false);
        component.set("v.allocationTOshow",true); 
        console.log('---component.get("v.selectedProgram");---',component.get("v.selectedProgram"));
        if(brandName == 'None'){
            component.set("v.ShowDataTOshow",true);  
            //component.set("v.isProgramCompletionToShow", false);
        }
        else{
            helper.getProgramData(component, brandName);
            
        }	
        
    },
    fetchData : function(component,event,helper){
        var brandName=component.get("v.selectedBrand"); 
        //component.set("v.isProgramCompletionToShow", false);
        console.log('==brandName--',brandName);
        var programName= component.get("v.selectedProgram");
        var skuNumber = component.get("v.selectedLookUpRecordSKU").Item_Number__c;
        console.log('----skuNumber---',skuNumber);
        console.log('==programName--',programName);
        helper.fetchAllData(component,brandName,programName,skuNumber);
        
        
    },
    allowToShow : function(component,event,helper){
        var programName= component.get("v.selectedProgram");
        
        console.log('==programName--',programName);
        
        if(programName=='None')
        {
            component.set("v.allocationTOshow",true); 
            component.set("v.ShowMarkAsComplete",true); 
            component.set("v.ShowReopenProgram",true); 
            component.set("v.isProgramCompletionToShow", false);
        }
        else{
            component.set("v.allocationTOshow",false);
            
            helper.findStateOfAllocation(component, programName);
            component.set("v.isProgramCompletionToShow", true);
        }     
    },
    handleSelectRecord:function(component,event,helper){
        if(component.get("v.selectedLookUpRecordSKU").Id == undefined){
            component.set("v.ShowDataTOshow",true);
        }
        else
        {
            component.set("v.ShowDataTOshow",false);
        }
    },
    
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    openmodal:function(component,event,helper) {
        component.set("v.isOpen", true);
        
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        var dmmyArr = [];
        component.set("v.addedAllocations",[]);
        component.set("v.qty",0);  
        component.set("v.isOpen", false);
    },
    addAllocationsNew : function(component, event, helper){
        var account = component.get("v.SelectedAccountRecords");
        console.log('-----account---',account.Id);
        var item =component.get("v.selectedLookUpRecordSKUAllocation");
        var qty=component.get("v.qty");
        console.log('-----qty---',qty);
        if(account.Id ==undefined || account.Id == null ){
            //alert('Please select Account');
            component.set("v.msgToPass" ,'Please select Account');
            component.set("v.openModal",true);      
            return;
        }else if(item.Id ==undefined || item.Id == null){
            component.set("v.msgToPass" ,'Please select Item ');
            component.set("v.openModal",true);      
            return;
        }else if(qty == undefined || qty == 0 || qty == null){
            component.set("v.msgToPass" ,'Please select Quantity');
            component.set("v.openModal",true);      
            return;
        }
        var varAddedAll = component.get("v.addedAllocations");
        var thisAllocation = {};
        thisAllocation.Account = component.get("v.SelectedAccountRecords");
        thisAllocation.Program = component.get("v.selectedProgram");
        thisAllocation.Item=component.get("v.selectedLookUpRecordSKUAllocation");
        console.log('--thisAllocation.ItemSelected--',thisAllocation.Item);
        console.log('--ItemSelected--',thisAllocation.Item.Name);
        console.log('--Account --',thisAllocation.Account.Name);
        thisAllocation.Brand = component.get("v.selectedBrand");	
        thisAllocation.Qtity = component.get("v.qty");
        thisAllocation.yearVal = component.get("v.selectedBudgetYear");
        thisAllocation.busienssLineVal = component.get("v.selectedBusinessLine");
        console.log(' ### this aloction###',thisAllocation);
        console.log(' ### this varAddedAll###',varAddedAll);
        varAddedAll.push(thisAllocation);
        component.set("v.addedAllocations",varAddedAll);
        console.log("#### added allocations #### " , varAddedAll);
        /* var ItemSelected = component.get("v.selectedLookUpRecordSKUAllocation");
        component.set("v.SelectedAccountRecords",null);
        component.set("v.selectedLookUpRecordSKUAllocation",null);
        component.set("v.qty",0);
        thisAllocation.ItemId= thisAllocation.Item.Id;
        thisAllocation.ItemName= thisAllocation.Item.Name;
        thisAllocation.SKUNumber= thisAllocation.Item.SKU_Number__c;
        thisAllocation.BrandName= thisAllocation.Item.Brand_Name__c;
        thisAllocation.ItemPrice= thisAllocation.Item.Item_Price__c;
        thisAllocation.ProgramStartDate= thisAllocation.Item.Program_Start_Date__c;
        thisAllocation.ProgramEndDate= thisAllocation.Item.Program_End_Date__c;
        thisAllocation.ProgramName= thisAllocation.Item.Program_Name__c;*/
        
    },
    saveAllocation: function(component, event, helper) {
        
        component.set("v.loadSpinner", true);
        var bulkAllocation= JSON.stringify(component.get("v.addedAllocations"));
        console.log("#### added allocations #### " , bulkAllocation);
        var action2 = component.get("c.bulkAllocationCreation");
        action2.setParams({"bulkAllocation" : bulkAllocation,"programStartDate":component.get("v.selectedProgramStartDate"),"programEndDate":component.get("v.selectedProgramEndDate") });
        action2.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(result.isSuccess ){
                
                var fetchFromController=result.dataTOPass;
                component.set("v.allData",fetchFromController);
                component.set("v.loadSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                console.log('---toastEvent--',toastEvent);
                component.set("v.isOpen", false);
                toastEvent.setParams({
                    title : 'Success Message',
                    message: result.successMsg,
                    duration:'5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                
                toastEvent.fire();
                var dmmyArr = [];
                component.set("v.addedAllocations",[]);
                component.set("v.qty",0);
            } else {
                //alert(result.errorMsg);
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
    reviewData: function(component, event, helper) {
        component.set("v.loadSpinner", true);
        var brandName=component.get("v.selectedBrand"); 
        var programName= component.get("v.selectedProgram");
        helper.fetchDataToReviewToReOpenfunction(component,brandName,programName);
        var dataToReview= JSON.stringify(component.get("v.DataToReview"));
        console.log('=== dataToReview -->',dataToReview);
        /* var action3 = component.get("c.reviewStaging");
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
                    toastEvent.fire();--
                    component.set("v.msgToPass" ,result.successMsg);
                   component.set("v.openModal",true);
                    component.set("v.loadSpinner", false);
                    
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
		$A.enqueueAction(action3);*/
    },
    reopenStaging: function(component, event, helper) {
        component.set("v.loadSpinner", true);
        var brandName=component.get("v.selectedBrand"); 
        var programName= component.get("v.selectedProgram");
        helper.fetchDataToReviewToReOpenAllocation(component,brandName,programName);
        var dataToReview= JSON.stringify(component.get("v.DataToReview"));
        console.log('===dataToReview on reopen',dataToReview);
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
        //$A.enqueueAction(action2);
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
    onQtyCheck: function(component, event, helper){
        var currentChangeData= component.get("v.allData");
        var originaldata= component.get("v.originalDataSet");
        console.log(' ******originaldata***',originaldata);
        console.log(' ******currentChangeData***',currentChangeData);
        var checkCmp = component.find("checkboxQty");
        var checked = checkCmp.get("v.value");
        console.log(' *******',checked);
        var qtyToApplyAll=currentChangeData[0].qty;
        var OriginalQty=originaldata[0].qty;
        console.log('@@@@@@ SKu to apply @@@',qtyToApplyAll);
        if(checked == true){
            for(var i in currentChangeData){
                currentChangeData[i].qty = qtyToApplyAll;
            }
            component.set("v.allData",currentChangeData);
        }
        else if(checked == false){
            for(var i in currentChangeData){
                currentChangeData[i].qty = OriginalQty;
            }
            component.set("v.allData",currentChangeData);
        }
        
    },
    enableSKUButton:function(component, event, helper){
        //component.set('v.isStateComplete',true);
        if(!component.get('v.isStateComplete')){
            component.set("v.SaveSKUChange", false);
        }
    },
    goToBackOffice : function(component, event, helper) {
        component.set("v.loadSpinner", true);
        var evt = $A.get("e.force:navigateToComponent");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__backOfficeReportComponent',
                pageName: 'BackOfficePoc'
            }
        };
        
        component.set("v.pageReference", pageReference);
        const navService = component.find('navService');
        //navService.navigate(pageReference);
        const handleUrl = (url) => {
            window.open(url);
        };
            const handleError = (error) => {
            console.log(error);
        };
            navService.generateUrl(pageReference).then(handleUrl, handleError);
            component.set("v.loadSpinner", false);
        },
    removeRow: function(component, event, helper) {
                //Get the account list
                var allocationList = component.get("v.addedAllocations");
                //Get the target object
                var selectedItem = event.currentTarget;
                //Get the selected item index
                var index = selectedItem.dataset.record;
                console.log('--- ina a index----',index);        
                allocationList.splice(index, 1);
                component.set("v.addedAllocations", allocationList);
            },   
          })