({
    doInit : function(component, event, helper) {
    var numYear = [];
    
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    var currYear = $A.localizationService.formatDate(today, "yyyy");
    numYear.push(parseInt(currYear)-1);
    numYear.push(parseInt(currYear));
    numYear.push(parseInt(currYear)+1);
    numYear.push(parseInt(currYear)+2);
    component.set("v.exportYearList", numYear);
        
   },
    allowToShow : function(component,event,helper){
        var channelName= component.get("v.selectedCh");
         //console.log('==channelName--',channelName);
        if(channelName=='None')
        {
           component.set("v.ShowDataTOshow",true); 
        }
        else{
        component.set("v.ShowDataTOshow",false);
        }
    },
	 ExportBudget : function(component, event, helper){
      helper.ExportBudgetData(component, event, helper);
    },
      showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    } 
})