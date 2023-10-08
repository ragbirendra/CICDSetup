({
    initializeDataTable: function (component,helper) {
        var action1 = component.get("c.getPickListVals");
        action1.setStorable();
        action1.setCallback(this, function (response) {
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
                component.set("v.allData", records);				
               
            } else {
                console.log('error');
            }
        });
        var requestInitiatedTime = new Date().getTime();
        $A.enqueueAction(action1);
        
        
    },
    updateComment: function (component,comment){
        //  var comment=component.get("v.reasonForRejection");
        // alert("Comment to save" , + comment);
        action=component.get("c.updateComment");
        action.setParams({ 
            "Comment" :comment
        });
        action.setCallback(this, function(response){
            //console.log('response',response);
            var state = response.getState();
            console.log('state',state);
            
            if (state === "SUCCESS") {   
                var result = response.getReturnValue(); 
                component.set("v.isLoading",false);
                alert('CHANGES UPDATED SUCCESSFULLY!');
                component.set("v.msgToPass" ,'CHANGES UPDATED SUCCESSFULLY!' );
                component.set("v.openModal",true);
            }else if(state === "ERROR"){
                component.set("v.isLoading",false);
                //alert('Error Occured: Please Check the Data Enteries and try again');
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApexSideError"));
                component.set("v.openModal",true);                
            }else{
                console.log('Other Exception Occured');
            }
        }); 
        $A.enqueueAction(action);   
    },
    saveTAUserChanges: function (component, helper) {
        var dataToSave = component.get("v.data");
        var comment=component.get("v.reasonForRejection");
        //console.log("Save changes method" + comment);
        console.log('dataToSave',dataToSave);
        var saveChangesAction = component.get("c.saveUpdateditemRecords");
        saveChangesAction.setParams({ 
            "brandToSave" : JSON.stringify(dataToSave),
            "comment" : comment
        });
        
        saveChangesAction.setCallback(this, function(response){
            //console.log('response',response);
            var state = response.getState();
            console.log('state',state);
            
            if (state === "SUCCESS") {   
                var result = response.getReturnValue(); 
                component.set("v.isLoading",false);
                component.set("v.msgToPass" ,'Changes Updated Successfully!' );
                component.set("v.openModal",true);
            }else if(state === "ERROR"){
                component.set("v.isLoading",false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                //alert('Error. Please try again or contact your admin!');
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApexSideError"));
                component.set("v.openModal",true);                
            }else{
                console.log('Other Exception Occured');
            }
        }); 
        
        $A.enqueueAction(saveChangesAction);
        
        
    },
    
    buildData: function (component, helper) {
        var selectedStatusName = component.find("statusNameid").get("v.value");
        var selectedProgramName = component.find("programNameid").get("v.value");
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        if(selectedProgramName == 'All'){
            if(allData.length<= 20){
                component.set("v.totalPages",1);
            }else{
                component.set("v.totalPages", Math.ceil(allData.length / component.get("v.pageSize")));
                // console.log('v.totalPages',component.get("v.totalPages"));
            }
            
            // console.log('allData',allData);
            var x = (pageNumber - 1) * pageSize;
            
            //creating data-table data
            for (; x <  (pageNumber) * pageSize; x++) {
                if (allData[x]) {
                    data.push(allData[x]);
                }
            }
            component.set("v.data", data);
            helper.generatePageList(component, pageNumber);
        }else{
            var allData = component.get("v.data");
            if(allData.length <= 20){
                component.set("v.totalPages",1);
            }else{
                component.set("v.totalPages", Math.ceil(allData.length / component.get("v.pageSize")));
            }
            // console.log('allData',allData);
            var x = (pageNumber - 1) * pageSize;
            
            //creating data-table data
            for (; x <  (pageNumber) * pageSize; x++) {
                if (allData[x]) {
                    data.push(allData[x]);
                }
            }
            component.set("v.data", data);
            //helper.generatePageList(component, pageNumber);
        }
        
    },
    
    /*
	 * this function generate page list
	 * */
    generatePageList: function (component, pageNumber) {
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if (totalPages > 1) {
            if (totalPages <= 10) {
                var counter = 2;
                for (; counter < (totalPages); counter++) {
                    pageList.push(counter);
                }
            } else {
                if (pageNumber < 5) {
                    pageList.push(2, 3, 4, 5, 6);
                } else {
                    if (pageNumber > (totalPages - 5)) {
                        pageList.push(totalPages - 5, totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1);
                    } else {
                        pageList.push(pageNumber - 2, pageNumber - 1, pageNumber, pageNumber + 1, pageNumber + 2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
    },
    
   filterProgramResult: function (component, event, helper, selectedProgramName) {
        var allRecords = component.get("v.allData");
        var filteredProgramLst = [];
        var sortedStatusLst = [];
        var selectedProgramName = component.find("programNameid").get("v.value");
        var selectedStatusName = component.find("statusNameid").get("v.value");
        var selectedBusinessLine = component.find("businessLineId").get("v.value");
        var selectedBudgetYear = component.find("budgetYearid").get("v.value");
        var uniqueStatusLst = [];
        var uniqueYearLst = [];
        var lookup = {};
        for(var i=0;i<allRecords.length;i++){
            if(allRecords[i].programName ==selectedProgramName && allRecords[i].BusinessLine ==selectedBusinessLine  
               && allRecords[i].Year ==selectedBudgetYear  ){
                var statusNameUnique = allRecords[i].Status;
                console.log('statusNameUnique',statusNameUnique);
                if (!(statusNameUnique in lookup)) {
                    lookup[statusNameUnique] = 1;
                    uniqueStatusLst.push(statusNameUnique);
                }
               
            }
        }
        component.set("v.StatusLst", uniqueStatusLst); 
    },
    filterStatusResult: function (component, event, helper, selectedStatusName, selectedProgramName) {
       // component.set("v.YearLst",'Select Budget Year');
      /*  var allRecords = component.get("v.allData");
        var filteredProgramLst = [];
        var sortedStatusLst = [];
        var selectedProgramName = component.find("programNameid").get("v.value");
        var selectedStatusName = component.find("statusNameid").get("v.value");
        var selectedBusinessLine = component.find("businessLineId").get("v.value");
        var selectedBudgetYear = component.find("budgetYearid").get("v.value");
        var uniqueYearLst = [];
        var lookup = {}; */
       /* for(var i=0;i<allRecords.length;i++){
            if(allRecords[i].programName ==selectedProgramName && allRecords[i].BusinessLine ==selectedBusinessLine 
               && allRecords[i].Status == selectedStatusName  ){
                console.log('allRecords++',allRecords);
                var yearUnique = allRecords[i].Year;
                //statusNameUnique.add(allRecords[i].Status);
                console.log('yearUnique',yearUnique);
                if (!(yearUnique in lookup)) {
                    lookup[yearUnique] = 1;
                    uniqueYearLst.push(yearUnique);
                }
            }
        }
        component.set("v.YearLst", uniqueYearLst); */
    },
    //Pagination
    updateDataTable: function (component, pageNumber, pageRecordsDisplayed, records) {
        component.set("v.isLoading", true);
        component.set("v.data", pageRecords);
        this.hideSpinner(component);
        
    },
})