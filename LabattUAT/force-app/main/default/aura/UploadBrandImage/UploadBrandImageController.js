({
    doInit: function (component,event,helper) {
      //var brdName = component.get("v.enteredSku");
        var action = component.get("c.fetchBrandDetail");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        component.set("v.msgToPass" ,'An Error occurred : please check the value');
        					component.set("v.openModal",true);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            if (state === "SUCCESS") {
            var brandList = response.getReturnValue();
               console.log("BrandList" +brandList.Id);
                component.set("v.BrandList", brandList);
                if(brandList == ''){
                    component.set("v.msgToPass" ,'Please enter the value');
        			component.set("v.openModal",true); 
                }
                else{
            component.set("v.showDataSection", true);
            //component.set("v.selectedItemId", brandId);
           // component.set("v.showImageSection",true);    
                }
            }
        });
        $A.enqueueAction(action);   
        
    },
    
    ShowImageSave : function (component, event, helper){
        var brdName = component.get("v.selectedBrand");
        var action = component.get("c.fetchBrandId");
        action.setParams({
            brandName : brdName
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        component.set("v.msgToPass" ,'An Error occurred : please check the value');
        					component.set("v.openModal",true);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            if (state === "SUCCESS") {
            var brandId = response.getReturnValue();
               console.log("brandId" +brandId);
                if(brandId == ''){
                    component.set("v.msgToPass" ,'Please enter the value');
        			component.set("v.openModal",true); 
                }
                else{
            component.set("v.showDataSection", true);
            component.set("v.selectedItemId", brandId);
            component.set("v.showImageSection",true);    
                }
            }
        });
        $A.enqueueAction(action);
         
    },
    handleCancel: function(component, event, helper){
        component.set("v.showImageSection",false);
    },
    handleUploadFinished : function (component, event, helper) {        
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        var fileName = uploadedFiles[0].name;
        //alert("Files uploaded : " + uploadedFiles.length);
        component.set("v.msgToPass" ,uploadedFiles.length  + "Files uploaded : " + fileName );
        component.set("v.openModal",true);
    },
    handleSave: function(component, event, helper) {
      var fuploader = component.find("fuploader").get("v.files");
        console.log("Inside fuploader" + fuploader );
        if(fuploader != null){
        if (component.find("fuploader").get("v.files").length > 0) {
            console.log("#### controller 1 ####");
            //helper.delHelper(component, event, helper);
            helper.uploadHelper(component, event);
        } else {
            //alert('Please Select a Valid File');
            component.set("v.msgToPass" ,'Please Select a Valid File');
        	component.set("v.openModal",true);
        }}
        else{
           component.set("v.msgToPass" ,'Please Select a Valid File');
        	component.set("v.openModal",true); 
        }
    },
    
    handleFilesChange: function(component, event, helper) {
       var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    }
})