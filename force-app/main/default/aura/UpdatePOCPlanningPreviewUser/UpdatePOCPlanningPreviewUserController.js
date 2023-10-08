({
    doInit : function(component, event, helper) {
        component.set("v.showLoading", true);
        // get already setup values
        var action = component.get("c.fetchSetupPreviewUsers");
        action.setCallback(this, function(response){
            var toastTitle = '';
            var toastMessage = 'An Error has occurred. Please contact Sys Admin.';
            var toastType = '';
            if(response.getState() === "ERROR"){  
                let errors = response.getError();
                toastTitle = 'Error';  
                toastType = 'error';      
                // Pass the error message if any
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    toastMessage = errors[0].message;
                } 
            }else if(response.getState() === "SUCCESS"){
                // success response
                component.set("v.listPreviewUsers", response.getReturnValue());
                toastTitle = 'Success';  
                toastType = 'success'; 
                toastMessage = 'Successfully loaded all data';
            }else{
                toastTitle = 'Unknown Sever Response';  
                toastType = 'error';
                toastMessage = 'We are not able to complete the action successfully. Please contact your Sys Admin';
            }
            component.set("v.showLoading", false);
            helper.generateToast(toastTitle, toastMessage, toastType);
        });
        $A.enqueueAction(action);
    },
    makeEditable: function(component, event, helper){
        component.set("v.showLoading", true);
        component.set("v.isDisabled", false);
        component.set("v.showLoading", false);
    },
    cancelOperation: function(component, event, helper){
        component.set("v.showLoading", true);
        component.set("v.isDisabled", true);
        component.set("v.showLoading", false);
    },
    saveOperation: function(component, event, helper){
        component.set("v.showLoading", true);
        var lstPrevUsers = component.get("v.listPreviewUsers");
        var action = component.get("c.savePreviewOpr");
        action.setParams({
            lstPrevValues : lstPrevUsers
        });
        action.setCallback(this, function(response){
            var toastTitle = '';
            var toastMessage = 'An Error has occurred. Please contact Sys Admin.';
            var toastType = '';
            if(response.getState() === "SUCCESS"){
                // success response
                component.set("v.listPreviewUsers", response.getReturnValue());
                component.set("v.isDisabled", true);
                toastTitle = 'Success';  
                toastType = 'success'; 
                toastMessage = 'Successfully updated the changes';
            }else if(response.getState() === "ERROR"){
                let errors = response.getError();
                toastTitle = 'Error';  
                toastType = 'error';      
                // Pass the error message if any
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    toastMessage = errors[0].message;
                } 
            }else{
                toastTitle = 'Unknown Sever Response';  
                toastType = 'error';
                toastMessage = 'We are not able to complete the actio nsuccessfully. Please contact your Sys Admin';
            }
            component.set("v.showLoading", false);
            helper.generateToast(toastTitle, toastMessage, toastType);
        });
        $A.enqueueAction(action);
    }
})