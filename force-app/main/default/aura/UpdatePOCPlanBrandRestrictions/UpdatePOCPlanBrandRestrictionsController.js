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
        component.set("v.showLoading", false);
    },
    renderDualList: function(component, event, helper){
        component.set("v.showLoading", true);
        if(component.get("v.selectedYear") == ''){
            var allBrandArrEmpty = [];
            var selBrandArrEmpty = [];
            component.set("v.optionsAvailable", allBrandArrEmpty);
            component.set("v.valuesSelected", selBrandArrEmpty);
            component.set("v.showLoading", false);
            return;
        }
        var action = component.get("c.fetchAllBrandRecords");
        action.setParams({
            selYear : component.get("v.selectedYear")
        });
        action.setCallback(this, function(response){ 
            // please take this callback to helper as it is called from 2 sperate methods
            var brandStr = response.getReturnValue();
            console.log("#### brand in js #### " + brandStr);
            var splitResponse = brandStr.split("_-_");
            var allBrandArr = [];
            var selBrandArr = [];
            var splitAllBrand = splitResponse[0].split(";");
            var splitSelBrands = [];
            if(splitResponse[1]){
                splitSelBrands = splitResponse[1].split("$");
            }
            for(var i=0; i<splitAllBrand.length; i++){
                var thisObj = {};
                thisObj.label = splitAllBrand[i];
                thisObj.value = splitAllBrand[i];
                allBrandArr.push(thisObj);
                if(splitResponse[1]){
                    for(var j=0; j<splitSelBrands.length; j++){
                        if(splitAllBrand[i] == splitSelBrands[j] ){
                            selBrandArr.push(splitSelBrands[j]);
                        }
                    }                    
                }
            }            
            component.set("v.optionsAvailable", allBrandArr);
            component.set("v.valuesSelected", selBrandArr);
            component.set("v.showLoading", false);
        });
        $A.enqueueAction(action);
    },
    modifyBrandRes: function(component, event, helper){
        component.set("v.isReadOnly", false);
    },
    cancelOpr: function(component, event, helper){
        component.set("v.showLoading", true);
        var action = component.get("c.fetchAllBrandRecords");
        action.setParams({
            selYear : component.get("v.selectedYear")
        });
        action.setCallback(this, function(response){
            var brandStr = response.getReturnValue();
            var splitResponse = brandStr.split("_-_");
            var allBrandArr = [];
            var selBrandArr = [];
            var splitAllBrand = splitResponse[0].split(";");
            for(var i=0; i<splitAllBrand.length; i++){
                var thisObj = {};
                thisObj.label = splitAllBrand[i];
                thisObj.value = splitAllBrand[i];
                allBrandArr.push(thisObj);
                if(splitResponse[1].indexOf(splitAllBrand[i]) != -1){
                    selBrandArr.push(splitAllBrand[i]);
                }
            }
            component.set("v.optionsAvailable", allBrandArr);
            component.set("v.valuesSelected", selBrandArr);
            component.set("v.isReadOnly", true);
            component.set("v.showLoading", false);
        });
        $A.enqueueAction(action);
    },
    saveBrandRes : function(component, event, helper){
        component.set("v.showLoading", true);
        console.log("#### the selected brand values #### " + component.get("v.valuesSelected"));
        var action = component.get("c.saveBrandRestrictions");
        action.setParams({
            newBrandVals : component.get("v.valuesSelected"),
            selYear : component.get("v.selectedYear")
        });
        action.setCallback(this, function(response){
            console.log("#### came back after saving ####");
            component.set("v.isReadOnly", true);
            component.set("v.showLoading", false);
        });
        $A.enqueueAction(action);
    },
    clearRestrication:  function(component, event, helper){
        var allBrandArr=[];
         component.set("v.optionsAvailable", allBrandArr);
            component.set("v.valuesSelected", allBrandArr);
    }
    
})