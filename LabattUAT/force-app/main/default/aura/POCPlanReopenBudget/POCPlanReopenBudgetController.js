({
    doInit : function(component, event, helper) {
        // default="[{'sObjectType':'Annual_Area_Budget__c'}]"
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
    queryBudgetData: function(component, event, helper){
        component.set("v.showLoading", true);
        var fName = component.get("v.ownFirstName");
        var lName = component.get("v.ownLastName");
        console.log("#### first name #### " + fName);
        console.log("#### last name #### " + lName);
        //var terrCodeVal = component.get("v.srchTerrCode");
        var budYearSelected = component.get("v.selectedYear");
        if(fName != null && lName != null && budYearSelected != null){
            var action = component.get("c.fetchAnnAreaBudgetRec");
            action.setParams({
                budYear : budYearSelected,
                ownerFirstName : fName,
                ownerLastName : lName
            });
            action.setCallback(this, function(response){
                console.log("#### response #### " + JSON.stringify(response.getReturnValue()));
                component.set("v.allTerrBudgets", response.getReturnValue());
                component.set("v.showLoading", false);
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.showLoading", false);
            alert("Please provide all values");            
        }
    },
    reopenBudget : function(component, event, helper){        
        var userConf = confirm("You are about to Reopen the Budget for the user. Please Confirm.");
        if(userConf != true){
            return;
        }
        component.set("v.showLoading", true);
        var clickedRow = event.currentTarget.getAttribute("data-recId");
        console.log("#### got id #### " + clickedRow);
        var getAllBudgetRecs = component.get("v.allTerrBudgets");
        var chosenRecord = {};
        for(var i=0; i<getAllBudgetRecs.length; i++){
            if(getAllBudgetRecs[i].Id == clickedRow){
                chosenRecord = getAllBudgetRecs[i];
                chosenRecord.Approval_Status__c = 'Required';
            }
        }
        var action = component.get("c.updateAnnAreaBudget");
        action.setParams({
            budgetRecordToUpdate : chosenRecord
        });
        action.setCallback(this, function(response){
            var updatedRecord = response.getReturnValue();
            var allRecords = component.get("v.allTerrBudgets");
            var indexToNote = 0;
            for(var i=0; i<allRecords.length; i++){
                if(allRecords[i].Id == updatedRecord.Id){
                    indexToNote = i;
                }
            }
            allRecords[indexToNote] = updatedRecord;
            component.set("v.allTerrBudgets",allRecords);
            component.set("v.showLoading", false);
        });
        $A.enqueueAction(action);
    },
    approveBudget : function(component, event, helper){
        var userConf = confirm("You are about to Approve the Budget for the user by passing the actual approval process. Please Confirm.");
        if(userConf != true){
            return;
        }
        component.set("v.showLoading", true);
        var clickedRow = event.currentTarget.getAttribute("data-recId");
        console.log("#### got id #### " + clickedRow);
        var getAllBudgetRecs = component.get("v.allTerrBudgets");
        var chosenRecord = {};
        for(var i=0; i<getAllBudgetRecs.length; i++){
            if(getAllBudgetRecs[i].Id == clickedRow){
                chosenRecord = getAllBudgetRecs[i];
                chosenRecord.Approval_Status__c = 'Approved';
            }
        }
        var action = component.get("c.updateAnnAreaBudget");
        action.setParams({
            budgetRecordToUpdate : chosenRecord
        });
        action.setCallback(this, function(response){
            var updatedRecord = response.getReturnValue();
            var allRecords = component.get("v.allTerrBudgets");
            var indexToNote = 0;
            for(var i=0; i<allRecords.length; i++){
                if(allRecords[i].Id == updatedRecord.Id){
                    indexToNote = i;
                }
            }
            allRecords[indexToNote] = updatedRecord;
            component.set("v.allTerrBudgets",allRecords);
            component.set("v.showLoading", false);
        });
        $A.enqueueAction(action);
    }
})