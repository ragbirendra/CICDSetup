({
    generateToast : function(titleVal, messageVal, typeVal) {
        let toastParams = {
            title: titleVal,
            message: messageVal, 
            type: typeVal
        };                
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
})