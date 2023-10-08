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
        var typeArr = []; // please take this from field describe result
        //typeArr.push('Trade Activation');
        typeArr.push('KI Volume and Discretionary');
        typeArr.push('Driver POCM Forecast');
        typeArr.push('Trade Activation');
        component.set("v.typeOptions" , typeArr);
        var bussLineArr =[];
        bussLineArr.push('Out of Home (OOH)');
        bussLineArr.push('In Home (IH)');
        component.set("v.businessLineOptions" , bussLineArr);
        component.set("v.showLoading", false);
        
        
    },
    onYearSelection : function(component, event, helper){
        component.set("v.showLoading", true);
        component.set("v.showDefinWindowCmp", true);
        // get the already defined year
        var action = component.get("c.fetchPlanningWindows");
        console.log("#### year value #### " + component.get("v.selectedYear"));
        action.setParams({
            selYear: component.get("v.selectedYear")
        });
        action.setCallback(this, function(response){
            
            var result = response.getReturnValue();
            component.set("v.planningrecords", result);
            var budRec = component.get("v.planningrecords");
            component.set("v.defPlanWindows", response.getReturnValue());
            component.set("v.showLoading", false);
            component.set("v.showDefinedWindow", true);
        });
        $A.enqueueAction(action);
    },
    defineNewWindow: function(component, event, helper){
        component.set("v.showCreatePanel", true);
        var selCalYr=component.get("v.selectedYear");
        component.set("v.isEditYr", false);
        component.set("v.showDefinedWindow", false);
        component.set("v.isNewYr", true);
        component.set("v.planningWindowObj", { 'sobjectType': 'POC_Planning_Setup_Admin__c' , 'Planning_Year__c' : selCalYr });
        component.set("v.isEditOp", false);
        component.set("v.showZone", false);
        var scrollOptions = {
            left: 100,
            top: 500,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
       // window.scrollTo(1000, 5000);
    },
    
    onYearChange: function(component, event, helper){
        component.set("v.showCreatePanel", false);
        component.set("v.showDefinWindowCmp", false);
        component.set("v.defPlanWindows", '');
        
        var selCalenderYr=component.find("selCalenderYr").get("v.value");
        var Newflag=component.get("v.isNewYr");
        var Editflag=component.get("v.showDefinedWindow");
        if(Newflag){
            component.set("v.planningWindowObj", { 'sobjectType': 'POC_Planning_Setup_Admin__c' , 'Planning_Year__c' : selCalenderYr });
        }
        if(Editflag){
            var action = component.get("c.fetchPlanningWindows");
            console.log("#### year value #### " + component.get("v.selectedYear"));
            action.setParams({
                selYear: component.get("v.selectedYear")
            });
            action.setCallback(this, function(response){
                console.log("#### got response #### " + response.getReturnValue());
                component.set("v.defPlanWindows", response.getReturnValue());
                component.set("v.showLoading", false);
            });
            $A.enqueueAction(action);
            
        }
        helper.onYearChangehelper(component,selCalenderYr);
        
    },
    onStartDateChange: function(component, event, helper){
        var startDiff;
        var strtTimeZone=component.find("strtTimeZone").get("v.value");
        //var cmTarget = component.find('changeIt');
        var sdate=new Date(strtTimeZone);
        startDiff=sdate.getTimezoneOffset()/60;
        component.set("v.timezoneGMT",startDiff);
        component.set("v.showZone", true);
        //$A.util.removeClass(cmTarget, 'xyz');
    },
    removeNewWindow: function(component, event, helper){
        component.set("v.showCreatePanel", false);
        component.set("v.planningWindowObj", { 'sobjectType': 'POC_Planning_Setup_Admin__c' });
        component.set("v.showLoading", false);
        component.set("v.isNewYr", true);
        component.set("v.isEditYr", false);
        var old=component.get("v.oldData");
        component.set("v.planningWindowObj", old);
        console.log('old' + old);
        //var editClk=component.find('editClick').get("v.value");
        //cnsole.log("editClk" + editClk);
         var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
    createData: function(component, event, helper){
        // debugger;
        component.set("v.showLoading", true);
        var checkExisting = component.get("v.defPlanWindows");
        var thisInstance = component.get("v.planningWindowObj");
        var startDiff;
        var endDiff;
        console.log("thisInstance.Calender year " + thisInstance.Planning_Year__c);
        console.log("thisInstance.Business_Line__c " + thisInstance.Business_Line__c);
        console.log("thisInstance.Budget_Year__c " + thisInstance.Budget_Year__c);
        console.log("thisInstance.Plan_Start_Date__c" +thisInstance.Plan_Start_Date__c);
        console.log("thisInstance.Type__c " + thisInstance.Type__c);
        console.log("thisInstance.Plan_End_Date__c" +thisInstance.Plan_End_Date__c);
        // console.log("checkExisting[i].End_Date__c" +checkExisting[i].End_Date__c);
        // check whether the planng start date and end date fall within the same year
        // as that of the selected calendar year
        console.log("#### check plan start date year ### " + new Date(thisInstance.Plan_Start_Date__c).getFullYear());
        console.log("#### check plan end date year ### " + new Date(thisInstance.Plan_End_Date__c).getFullYear());
        console.log("#### check calendar year parseint ### " + parseInt(thisInstance.Planning_Year__c));
        console.log((parseInt(new Date(thisInstance.Plan_Start_Date__c).getFullYear()) == parseInt(new Date(thisInstance.Plan_End_Date__c).getFullYear()) == parseInt(thisInstance.Planning_Year__c)));
        if(!(parseInt(new Date(thisInstance.Plan_Start_Date__c).getFullYear()) == parseInt(new Date(thisInstance.Plan_End_Date__c).getFullYear()) &&
             parseInt(new Date(thisInstance.Plan_End_Date__c).getFullYear()) == parseInt(thisInstance.Planning_Year__c))){
            console.log("#### year vals does not match #### ");
            component.set("v.showLoading", false);
            // give some validation message - toast
            component.set("v.msgToPass" ,'Start Date and End Date should fall within the same year and must be equal to Calendar Year' );
            component.set("v.openModal",true);
            return;
        }
        for(var i=0; i<checkExisting.length; i++){            
            
            if(thisInstance.Type__c == checkExisting[i].Type__c && thisInstance.Business_Line__c == checkExisting[i].Business_Line__c 
               && thisInstance.Plan_Start_Date__c <= checkExisting[i].Plan_End_Date__c &&
               thisInstance.Budget_Year__c == checkExisting[i].Budget_Year__c && 
               
               checkExisting[i].Plan_Start_Date__c <= thisInstance.Plan_End_Date__c){ // main validation - test test test
                console.log("#### overlap found in planning windows #### ");
                component.set("v.showLoading", false);
                // give some validation message - toast
                component.set("v.msgToPass" ,'Overlap found in planning windows' );
                component.set("v.openModal",true);
                return;
            }
            
        }
        var sdate=new Date(thisInstance.Plan_Start_Date__c);
        console.log("sdate" + sdate);
        console.log("sdate year " +sdate.getYear() );
        startDiff=sdate.getTimezoneOffset()/60;
        component.set("v.msgToPass" ,'Please note all the date and time are in GMT. Startdate and Enddate in GMT  are   ' + startDiff + '  hrs of your local time ');
        component.set("v.openModal",true);
        if(thisInstance.Plan_Start_Date__c > thisInstance.Plan_End_Date__c ){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Planning End Date cannot be before Planning Start Date' );
            component.set("v.openModal",true);
            return;
        }
        if(thisInstance.Plan_Start_Date__c == undefined){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,' Planning Start Date is mandatory' );
            component.set("v.openModal",true);
            return;
        }
        if(thisInstance.Plan_End_Date__c == undefined){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Planning End Date is mandatory' );
            component.set("v.openModal",true);
            return;
        }
        if(thisInstance.Budget_Year__c == ''){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Budget year is required' );
            component.set("v.openModal",true);
            return;
        }
        if(thisInstance.Type__c == ''){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Type is required' );
            component.set("v.openModal",true);
            return;
        }
        if(thisInstance.Planning_Year__c == ''){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Planning year is required' );
            component.set("v.openModal",true);
            return;
        }
        if(thisInstance.Business_Line__c == undefined ||thisInstance.Business_Line__c =='' ){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Business line is required' );
            component.set("v.openModal",true);
            return;
        }
        /*if(thisInstance.Business_Line__c != undefined){
            if(!thisInstance.Business_Line__c == "OOH" || !thisInstance.Business_Line__c == "IH" ){
           	component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Business line should have correct value' );
            component.set("v.openModal",true);
            return;
            }
        } */    
        
        else{
            if(thisInstance.Business_Line__c == "Out of Home (OOH)" || thisInstance.Business_Line__c == "In Home (IH)"){
                var action = component.get("c.definePlanningWindow");
                action.setParams({
                    planWindowData: component.get("v.planningWindowObj")
                });
                action.setCallback(this, function(result){  
                    var state = result.getState();
                    console.log('state',state);
                    if (state === "SUCCESS") {   
                        component.set("v.defPlanWindows", result.getReturnValue());
                        component.set("v.showCreatePanel", false);
                        component.set("v.showLoading", false);
                    }
                    else if (state === "INCOMPLETE") {
                        component.set("v.isLoading",false);   
                        component.set("v.msgToPass" ,'Server Error Occured: Kindly refresh and try again' );
                        component.set("v.openModal",true);
                    }
                        else if (state === "ERROR") { 
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message: " +errors[0].message);
                                    component.set("v.msgToPass" ,errors[0].message);
                                    component.set("v.openModal",true);
                                    component.set("v.isLoading",false);
                                }
                            } else {
                                console.log("Unknown error");
                                component.set("v.msgToPass" ,'Error Occured: Please contact your admin or try again' );
                                component.set("v.openModal",true);
                                component.set("v.isLoading",false);
                            }
                        }
                });
                $A.enqueueAction(action);
                component.set("v.planningWindowObj", { 'sobjectType': 'POC_Planning_Setup_Admin__c' });
            }
            else{
                component.set("v.showLoading", false);
                component.set("v.msgToPass" ,'Business line should  have values : IH or OOH' );
                component.set("v.openModal",true);
                return;  
            }
        }
    },
    delPlanWindowData: function(component, event, helper){
        console.log("#### get the record id #### " + event.currentTarget.getAttribute("data-recId"));
        var confirmResult = confirm("Are you sure you want to delete the selected record?");
        if(confirmResult){
            component.set("v.showLoading", true);
            component.set("v.showCreatePanel", false);
            
            var action = component.get("c.deletePlanWindows");
            action.setParams({
                recId: event.currentTarget.getAttribute("data-recId"),
                selYear: component.get("v.selectedYear")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") { 
                    component.set("v.defPlanWindows", response.getReturnValue());
                    component.set("v.showCreatePanel", false);
                    component.set("v.showLoading", false);
                }
                else if (state === "INCOMPLETE") {
                    component.set("v.isLoading",false);   
                    component.set("v.msgToPass" ,'Server Error Occured: Kindly refresh and try again' );
                    component.set("v.openModal",true);
                }
                    else if (state === "ERROR") { 
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " +errors[0].message);
                                component.set("v.msgToPass" ,errors[0].message);
                                component.set("v.openModal",true);
                                component.set("v.isLoading",false);
                            }
                        } else {
                            console.log("Unknown error");
                            component.set("v.msgToPass" ,'Error Occured: Please contact your admin or try again' );
                            component.set("v.openModal",true);
                            component.set("v.isLoading",false);
                        }
                    }
            });
            $A.enqueueAction(action);
        }
    },
    updtPlanningWindowRec: function(component, event, helper){
        component.set("v.showLoading", true);
        component.set("v.isEditYr", true); 
        component.set("v.isNewYr", false);
        component.set("v.isEditOp", true); 
        component.set("v.showDefinedWindow", false); 
        var oldValue=[];
        // component.set("v.planningWindowObj", oldValue);
        var tryedit;
        // var BudgetyearOptions = [];
        var existingRecords = component.get("v.defPlanWindows");
        //console.log("existingRecords Planning_Year__c" +thisUpdate.Planning_Year__c);
        var selRecToUpdt = event.currentTarget.getAttribute("data-recId");
        console.log("selRecToUpdt" +selRecToUpdt);
        for(var i=0; i<existingRecords.length; i++){
            if(existingRecords[i].Id === selRecToUpdt){
                console.log("existingRecords" + existingRecords[i].Budget_Year__c);
                tryedit=existingRecords[i].Planning_Year__c;
                console.log("tryedit" + tryedit);
                oldValue=existingRecords[i];
                
                helper.onYearChangehelper(component,tryedit);
                component.set("v.oldData",existingRecords[i] ); 	
                component.set("v.planningWindowObj",existingRecords[i] ); 	
                break;
            }
        }
        component.set("v.showLoading", false);
        component.set("v.showCreatePanel", true);
        window.scrollTo(0,560);
        helper.fetchAllWindows(component, selRecToUpdt);
    },
    executeUpdateOperation: function(component, event, helper){
        //debugger;
        // call update method
        var thisUpdate = component.get("v.planningWindowObj");
        console.log("thisUpdate.Calender year " + thisUpdate.Planning_Year__c);
        console.log("thisUpdate.Business_Line__c " + thisUpdate.Business_Line__c);
        console.log("thisUpdate.Budget_Year__c " + thisUpdate.Budget_Year__c);
        console.log("thisUpdate.Plan_Start_Date__c" +thisUpdate.Plan_Start_Date__c);
        console.log("thisUpdate.Type__c " + thisUpdate.Type__c);
        console.log("thisUpdate.Plan_End_Date__c" +thisUpdate.Plan_End_Date__c);
        var abc=component.get("v.allPlanWindows");
        
        for(var i=0; i<abc.length; i++){
            console.log("abc.Calender year " + abc[i].Planning_Year__c);
            console.log("abc.Business_Line__c " + abc[i].Business_Line__c);
            console.log("abc.Budget_Year__c " + abc[i].Budget_Year__c);
            console.log("abc.Plan_Start_Date__c" +abc[i].Plan_Start_Date__c);
            console.log("abc.Type__c " + abc[i].Type__c);
            console.log("abc.Plan_End_Date__c" +abc[i].Plan_End_Date__c);
            
            if( abc[i].Type__c==thisUpdate.Type__c  &&  abc[i].Business_Line__c == thisUpdate.Business_Line__c  && 
               
               thisUpdate.Plan_Start_Date__c <= abc[i].Plan_End_Date__c &&  abc[i].Budget_Year__c==thisUpdate.Budget_Year__c  &&
               abc[i].Plan_Start_Date__c <= thisUpdate.Plan_End_Date__c){ // main validation - test test test
                console.log("#### overlap found in planning windows #### ");
                component.set("v.showLoading", false);
                // give some validation message - toast
                component.set("v.msgToPass" ,'Overlap found in planning windows' );
                component.set("v.openModal",true);
                return;
            }
            
        }
        if(!(parseInt(new Date(thisUpdate.Plan_Start_Date__c).getFullYear()) == parseInt(new Date(thisUpdate.Plan_End_Date__c).getFullYear()) &&
             parseInt(new Date(thisUpdate.Plan_End_Date__c).getFullYear()) == parseInt(thisUpdate.Planning_Year__c))){
            console.log("#### year vals does not match #### ");
            component.set("v.showLoading", false);
            // give some validation message - toast
            component.set("v.msgToPass" ,'Start Date and End Date should fall within the same year and must be equal to Calendar Year' );
            component.set("v.openModal",true);
            return;
        }
        if(thisUpdate.Plan_Start_Date__c > thisUpdate.Plan_End_Date__c ){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Planning End Date cannot be before Planning Start Date' );
            component.set("v.openModal",true);
            return;
        }
        if(thisUpdate.Plan_Start_Date__c == undefined){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,' Planning Start Date is mandatory' );
            component.set("v.openModal",true);
            return;
        }
        if(thisUpdate.Plan_End_Date__c == undefined){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Planning End Date is mandatory' );
            component.set("v.openModal",true);
            return;
        }
        if(thisUpdate.Budget_Year__c == ''){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Budget year is required' );
            component.set("v.openModal",true);
            return;
        }
        if(thisUpdate.Type__c == ''){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Type is required' );
            component.set("v.openModal",true);
            return;
        }
        /*if(thisUpdate.Business_Line__c != 'IH' ||thisUpdate.Business_Line__c != 'OOH'){
           	component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Please enter business line : either IH or OOH ' );
            component.set("v.openModal",true);
            return; 
        }*/
        
        if(thisUpdate.Planning_Year__c == ''){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Planning year is required' );
            component.set("v.openModal",true);
            return;
        }
        if(thisUpdate.Business_Line__c == undefined || thisUpdate.Business_Line__c ==''){
            component.set("v.showLoading", false);
            component.set("v.msgToPass" ,'Business line is required' );
            component.set("v.openModal",true);
            return;
        }
        else{
            if(thisUpdate.Business_Line__c == "Out of Home (OOH)" || thisUpdate.Business_Line__c == "In Home (IH)"){
                var confirmResult = confirm("Are you sure you want to update the record?");
                if(confirmResult){
                    component.set("v.showLoading", true);
                    var action = component.get("c.updatePlanWindows");
                    action.setParams({
                        planWindowData: component.get("v.planningWindowObj"),
                        selYear: component.get("v.selectedYear")
                    });
                    action.setCallback(this, function(response){ // show toast in case of error - ankita's code
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set("v.defPlanWindows", response.getReturnValue());
                            component.set("v.showCreatePanel", false);
                            component.set("v.isEditOp", false);   
                            component.set("v.showLoading", false);  
                        }
                        else if (state === "INCOMPLETE") {
                            component.set("v.isLoading",false);   
                            component.set("v.msgToPass" ,'Server Error Occured: Kindly refresh and try again' );
                            component.set("v.openModal",true);
                        }
                            else if (state === "ERROR") { 
                                var errors = response.getError();
                                if (errors) {
                                    if (errors[0] && errors[0].message) {
                                        console.log("Error message: " +errors[0].message);
                                        component.set("v.msgToPass" ,errors[0].message);
                                        component.set("v.openModal",true);
                                        component.set("v.isLoading",false);
                                    }
                                } else {
                                    console.log("Unknown error");
                                    component.set("v.msgToPass" ,'Error Occured: Please contact your admin or try again' );
                                    component.set("v.openModal",true);
                                    component.set("v.isLoading",false);
                                }
                            }
                    });
                    $A.enqueueAction(action);
                    component.set("v.isNewYr", true);
                    component.set("v.isEditYr", false);
                    component.set("v.planningWindowObj", { 'sobjectType': 'POC_Planning_Setup_Admin__c' });
                }   
            }else{
                component.set("v.showLoading", false);
                component.set("v.msgToPass" ,'Business line value should be : IH or OOH' );
                component.set("v.openModal",true);
                return;
            }
        }
    }
})