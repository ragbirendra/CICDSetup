({
    doInit: function (component,event,helper) {
        
        //helper.getProgramData(component);
        //helper.getStatusData(component);
        helper.getBusinessLineData(component);
        helper.getYear(component);
    },
    
    yearchanged:function (component,event,helper) {
        var yearVal = component.get("v.selectedYr");
        console.log('--'+yearVal);   
        helper.getProgramData(component,yearVal);
        
    },
    programChanged:function (component,event,helper) {
        var yearVal = component.get("v.selectedYr");
        var selectedProgram = component.get("v.selectedProgram");
        console.log('--'+yearVal);   
        helper.getStatusData(component,yearVal,selectedProgram);
        
    },
    
    downloadCsv : function(component,event,helper){
        
        // get the staging records 
        var stockData = component.get("v.allData");
        console.log('----stock data---', stockData);        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
        if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = stockData[0].ProgramName+'.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    },
    ExportItem : function(component, event, helper){
        helper.ExportItemData(component, event, helper);
    },
    
    allowToShow:function(component,event,helper)
    {
        var status= component.get("v.selectedStatus");
        
        if(status=='None')
        {
            component.set("v.ShowDataTOshow",true); 
        }
        else{
            component.set("v.ShowDataTOshow",false);
        }
    },
 /*   fetchData : function(component,event,helper){
        var programName=component.get("v.selectedProgram"); 
        var statusName=component.get("v.selectedStatus");
        var businessName=component.get("v.selectedBusinessLine");        
        helper.fetchAllData(component,programName,statusName,businessName);
        
    },
    */
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    }
    
})