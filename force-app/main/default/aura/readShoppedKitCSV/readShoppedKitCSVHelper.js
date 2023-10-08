({
    parseCSVAndLoadRecords: function (component, event, helper, results ){
        
        var data = results.split('\n');
        var length = data.length;
        var finalData = [];
        var dataToInsert =[];
        var ItemName =[];
        var validData = [];
        var uniqueSet = new Set();
        var uniqueArray = [];
        component.set("v.excelHeader", data[0]);
        
        for(var i=1;i<length-1;i++){
                    data[i] = data[i].replace(/(\r\n|\n|\r|"")/gm,""); 
                    var str = data[i].split(','); 
                  	var item = { 
                            "ShoppedKitName": str[0] ,
                            "ProgramName": str[1],
                            "ShopkitStartDate": str[2],
                            "ShopkitEndDate": str[3],
                            
                            "ShopkitPrice": str[4],                   
                            "ShopkitSAPNumber": str[5],
                            "ShopkitTemporaryItemNumbers": str[6],
                            "ShopkitQty": str[7] ,
                            "Year": str[8] ,
                            "BusinessLine": str[9] 
                        };
                        uniqueSet.add(str[0]);
                        validData.push(item);        
           }
        uniqueArray = Array.from(uniqueSet);
        component.set("v.OptionsPC", uniqueArray); //'uniqueArray'
        component.set("v.listData",validData);
        component.set("v.listDataToDisplay",validData);
        component.set("v.isLoading", false );
 },
   
    saveBrand:function(component,event,helper){
        var resultToSave;
        var seletedItem= component.get("v.selectedPC");
        if(seletedItem=='All'){
            resultToSave= component.get("v.listData") ;
        }
        else
        {
            resultToSave=component.get("v.listDataToDisplay") ;
        }
        var action = component.get("c.createShopKitRecords");
        
        action.setParams({ 
            "shopkitsave" : JSON.stringify(resultToSave)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");            
            if (component.isValid() && state === "SUCCESS") {   
                
                var result = response.getReturnValue();  
                //alert('Records created successfully...!!!');
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_DataSaveSuccessfully") );
            	component.set("v.openModal",true);
                component.set("v.validationFlag",true);
            }
            else if (state === "INCOMPLETE") {
                component.set("v.isLoading",false);   
                component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ServerError") );
                component.set("v.openModal",true);
            }
            else if (state === "ERROR") {

                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                         component.set("v.msgToPass" ,errors[0].message);
                         component.set("v.openModal",true);
                   		 component.set("v.isLoading",false);
           
                    }
                } else {
                   console.log("Unknown error");
                    component.set("v.msgToPass" ,$A.get("$Label.c.ABI_OP_ApexSideError") );
                    component.set("v.openModal",true);
                    component.set("v.isLoading",false);
                }
            }
        }); 
        $A.enqueueAction(action);
    },
    
    filterRecords:function(component, event, helper)
    {
       var data = component.get("v.listData");
        
        var seletedItem= component.get("v.selectedPC");
       
        var length = data.length;
       
        var ItemName =[];
        var validData = [];
        var allData=[];
        if(data.length>0){
            if(seletedItem!='All'){
                for(var i=0;i<data.length;i++){
                    var splitData = data[i];
                  
                    if(seletedItem == data[i].ShoppedKitName){
                        
                        var item = { 
                            "ShoppedKitName": data[i].ShoppedKitName ,
                            "ProgramName": data[i].ProgramName,
                            "ShopkitStartDate": data[i].ShopkitStartDate,
                            "ShopkitEndDate": data[i].ShopkitEndDate,
                            
                            "ShopkitPrice": data[i].ShopkitPrice,                   
                            "ShopkitSAPNumber": data[i].ShopkitSAPNumber,
                            "ShopkitTemporaryItemNumbers": data[i].ShopkitTemporaryItemNumbers,
                            "ShopkitQty": data[i].ShopkitQty,
                            "Year": data[i].Year,
                            "BusinessLine": data[i].BusinessLine
                            
                        };
                        //ItemName.push(splitData[0]);
                        validData.push(item);
                    }
                }
                component.set("v.listDataToDisplay",validData);
            }
            else
            {
                for(var i=0;i<data.length;i++){
                    var item = { 
                        "ShoppedKitName": data[i].ShoppedKitName ,
                        "ProgramName": data[i].ProgramName,
                        "ShopkitStartDate": data[i].ShopkitStartDate,
                        "ShopkitEndDate": data[i].ShopkitEndDate,
                        
                        "ShopkitPrice": data[i].ShopkitPrice,                   
                        "ShopkitSAPNumber": data[i].ShopkitSAPNumber,
                        "ShopkitTemporaryItemNumbers": data[i].ShopkitTemporaryItemNumbers,
                        "ShopkitQty": data[i].ShopkitQty,
                        "Year": data[i].Year,
                        "BusinessLine": data[i].BusinessLine
                    };
                    allData.push(item);
                }
                component.set("v.listDataToDisplay",allData);
            }
         
            component.set("v.isLoading", false );
        }
    },
    convertArrayOfObjectsToCSV : function(component,event,helper){
        console.log("entered helper method");
        var csvStringResult, counter, keys, columnDivider, lineDivider, column2;
        columnDivider = ',';
        lineDivider =  '\n';
        keys =["Shopped Kit Name","Program Name","Shopkit Start Date","Shopkit End Date","Shopkit Price","Shopkit SAP Number","Shopkit Temporary Item Numbers","Shopkit Qty","Year","Business Line"];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 		column2=["Budweiser - Hockey - Petit","Budweiser - Hockey","9/15/2020","12/1/2020","36","7530620","","1","2020","Out of Home"];
        console.log("keys.length"+keys.length );
       /* for(var i=0; i < keys.length; i++){   
            counter = 0;
           		for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 				console.log("skey" + skey);
               	csvStringResult = skey;*/ 
               	csvStringResult = keys; 
                csvStringResult += lineDivider + column2;
                 console.log("csvStringResult inside for" +csvStringResult);
              // counter++;
 			//} 
             csvStringResult += lineDivider;
         // }
       console.log("csvStringResult" + csvStringResult);
        return csvStringResult;        
    }
})