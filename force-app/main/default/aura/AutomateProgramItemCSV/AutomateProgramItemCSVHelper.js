({
    saveProgramItems:function(component,event,helper){
        var resultToSave = component.get("v.totalDataSet") ;
        console.log('resultToSave',resultToSave);
        var allListVals = [];
        /* change the date formate from mm/dd/yyyy to yyyy-mm-dd */
        
        for(var i=0;i<resultToSave.length;i++)
        { 
            var date = resultToSave[i].ProgramStartDate;
            var yourdate = date.split("/").reverse();
            var tmp = yourdate[2];
            yourdate[2] = yourdate[1];
            yourdate[1] = tmp;
            resultToSave[i].ProgramStartDate = yourdate.join("-");
            
            var date1 = resultToSave[i].ProgramEndDate;
            var yourdate = date1.split("/").reverse();
            var tmp = yourdate[2];
            yourdate[2] = yourdate[1];
            yourdate[1] = tmp;
            resultToSave[i].ProgramEndDate = yourdate.join("-");
            
            var date = resultToSave[i].PlanningStartDate;
            var yourdate = date.split("/").reverse();
            var tmp = yourdate[2];
            yourdate[2] = yourdate[1];
            yourdate[1] = tmp;
            resultToSave[i].PlanningStartDate = yourdate.join("-");
            
            var date = resultToSave[i].PlanningEndDate;
            var yourdate = date.split("/").reverse();
            var tmp = yourdate[2];
            yourdate[2] = yourdate[1];
            yourdate[1] = tmp;
            resultToSave[i].PlanningEndDate = yourdate.join("-");
            
            allListVals.push(resultToSave[i]);     
        }
        console.log('allListVals',allListVals);
        var action = component.get("c.createItemRecords");
        action.setParams({ 
            "brandToSave" : JSON.stringify(allListVals)
        });
        action.setCallback(this, function(response){
            console.log('response',response);
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {   
                var result = response.getReturnValue(); 
                console.log('result',result);
                component.set("v.isLoading",false);
               // component.set("v.msgToPass" ,'Data Saved Successfully' );
               component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_DataSavedLabel"));
               component.set("v.openModal",true);
               component.set("v.enableSave", true);
            }
            else if (state === "INCOMPLETE") {
                component.set("v.isLoading",false);   
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ServerError"));
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
                        component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApexSideError" ));
                        component.set("v.openModal",true);
                        component.set("v.isLoading",false);
                    }
                }
            
        }); 
        $A.enqueueAction(action);
    },
    convertArrayOfObjectsToCSV : function(component,event,helper){
        console.log("entered helper method");
        var column2;
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        columnDivider = ',';
        lineDivider =  '\n';
        keys= [$A.get("$Label.c.ABI_Program_Item_CSV_Headers").split(',')];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        column2=["Keith;Goose;ShockTop","AK Always On","Description","4/1/2020","11/23/2020","11/24/2020","11/25/2020","Out of Home","7522028","","AK Wood A Frame",
                 "No","1",
                 "eng","EA","CAD","1","256.69","325.9963","A Frame","Driver","YES","NO","NO","YES","Signs & Boards","Product Description EN","Product Description FR","ITEM1","ITEM1","YES","2020"];
        console.log("keys.length"+keys.length );
        for(var i=0; i < keys.length; i++){   
            counter = 0;
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
                console.log("skey" + skey);
                
                csvStringResult = skey; 
                csvStringResult += lineDivider+ column2; 
                console.log("csvStringResult inside else" +csvStringResult);
                counter++;
            } 
            csvStringResult += lineDivider;
        }
        console.log("csvStringResult" + csvStringResult);
        return csvStringResult;        
    },
})