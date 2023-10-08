({
    onYearChangehelper: function(component, selCalenderYr){
      //var selCalenderYr=component.find("selCalenderYr").get("v.value");
        console.log("selCalenderYr" + selCalenderYr);
        var budgetYr;
        var tryval=selCalenderYr +"-01-01";
        console.log("selCalenderYr" + tryval);
        var BudgetyearOptions = [];
        var action = component.get("c.changeStringToDate");
        action.setParams({
            "BudgetDate": tryval
        });
        action.setCallback(this, function(response){
            console.log("#### got response #### " + response.getReturnValue()); 
            budgetYr=response.getReturnValue();
            console.log('budgetYr' +budgetYr);
            BudgetyearOptions.push(budgetYr);
       		BudgetyearOptions.push(budgetYr+1);
            BudgetyearOptions.push(budgetYr+2);
        	console.log("BudgetyearOptions" + BudgetyearOptions);
        	component.set("v.BudgetyearOptions",BudgetyearOptions); 
        });
        $A.enqueueAction(action);
    },
    fetchAllWindows :function(component, recId){
        var thisUpdate = component.get("v.planningWindowObj");
        console.log("inside saction method");
    	var action = component.get("c.fetchAllPlanningWindows");
        action.setParams({
            recId : recId 
        });
        action.setCallback(this, function(response){
            console.log("#### got response #### " + response.getReturnValue());
            var checkExisting = response.getReturnValue();
            component.set("v.allPlanWindows",checkExisting);          
       		component.set("v.showLoading", false);
        });
        $A.enqueueAction(action);  
     
      
}
})