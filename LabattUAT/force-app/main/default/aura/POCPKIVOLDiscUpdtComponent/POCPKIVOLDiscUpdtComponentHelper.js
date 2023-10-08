({
	showMessage : function(paramMode, paramTitle, paramMessage, paramError) {
        // Configure error toast
        let toastParams = {
            "mode": paramMode,
            "title": paramTitle,
            "message": paramMessage,
            "type": paramError
        };
        // Fire error toast
        console.log("#### check 17 #### " + paramMessage);
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
	}
})