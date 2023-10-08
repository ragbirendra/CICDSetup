({
    doInit: function (component, event, helper){
        debugger;
        console.log("inside handleClick");
        var url;
        var action = component.get("c.fetchURL");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "ERROR") {
                console.log("inside if error");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                        component.set("v.msgToPass" ,'An Error occurred ');
                        component.set("v.openModal",true);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            if (state === "SUCCESS") {
                var itemId = response.getReturnValue();
                console.log("itemId" +itemId);
                if(itemId == ''){
                    component.set("v.msgToPass" ,'Please enter the value');
                    component.set("v.openModal",true); 
                }
                else{
                    url=$A.get("$Label.c.ABI_OP_URL") + '/lightning/r/Folder/' + itemId +'/view?queryScope=userFolders';
                    component.set("v.link", url);
                }
            }
        });
        $A.enqueueAction(action);       
        
    },
    
    loadItemRecord : function(component, event, helper) {
        var skuNum = component.get("v.enteredSku");
        var action = component.get("c.fetchItem");
        action.setParams({
            skuNumber : skuNum
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
                var itemId = response.getReturnValue();
                component.set("v.recordId",itemId);
                console.log("itemId" +itemId);
                if(itemId == ''){
                    component.set("v.msgToPass" ,'Please enter the value');
                    component.set("v.openModal",true); 
                }
                else{
                    component.set("v.showDataSection", true);
                    component.set("v.selectedItemId", itemId);
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleClick : function (component, event, helper){
        var link = component.get("v.link");
        console.log("link in handleClick" + link);
        window.open(link);
        // $A.get("e.force:navigateToURL").setParams({ 
        //	"url": (link) 
        // }).fire();
        
    },
    handleUploadFinished : function (component, event, helper) {        
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        //alert("Files uploaded : " + uploadedFiles.length);
        component.set("v.msgToPass" ,"Files uploaded : " + uploadedFiles.length );
        component.set("v.openModal",true);
    },
    handleSave: function(component, event, helper) {
        var fuploader = component.find("fuploader").get("v.files");
        console.log("Inside fuploader" + fuploader );
        if(fuploader != null){
            if (component.find("fuploader").get("v.files").length > 0) {
                console.log("#### controller 1 ####");
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
    handleCancel: function(component, event, helper){
        component.set("v.showImageSection",false);
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
})