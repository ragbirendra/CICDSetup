({
	 setNewWidth: function(component, event, helper) {
        var currentEle = component.get("v.currentEle");
        if( currentEle != null && currentEle.tagName ) {
            var parObj = currentEle;
            while(parObj.parentNode.tagName != 'TH') {
                if( parObj.className == 'slds-resizable__handle')
                    currentEle = parObj;    
                parObj = parObj.parentNode;
                count++;
            }
            var count = 1;
            var mouseStart = component.get("v.mouseStart");
            var oldWidth = parObj.offsetWidth;  // Get the width of DIV
            var newWidth = oldWidth + (event.clientX - parseFloat(mouseStart));
            component.set("v.newWidth", newWidth);
            currentEle.style.right = ( oldWidth - newWidth ) +'px';
            component.set("v.currentEle", currentEle);
        }
    },
	// We are setting the width which is just changed by the mouse move event     
    resetColumn: function(component, event, helper) {
        // Get the component which was used for the mouse move
        if( component.get("v.currentEle") !== null ) {
            var newWidth = component.get("v.newWidth"); 
            var currentEle = component.get("v.currentEle").parentNode.parentNode; // Get the DIV
            var parObj = currentEle.parentNode; // Get the TH Element
            parObj.style.width = newWidth+'px';
            currentEle.style.width = newWidth+'px';
            console.log(newWidth);
            component.get("v.currentEle").style.right = 0; // Reset the column devided 
            component.set("v.currentEle", null); // Reset null so mouse move doesn't react again
        }
	},
     calculateWidth: function(component, event, helper) {
        
        var childObj = event.target
        var mouseStart=event.clientX;
        component.set("v.currentEle", childObj);
        component.set("v.mouseStart",mouseStart);
        // Stop text selection event so mouse move event works perfectlly.
        if(event.stopPropagation) event.stopPropagation();
        if(event.preventDefault) event.preventDefault();
        event.cancelBubble=true;
        event.returnValue=false;  
    },
   removeRow: function(component, event, helper) {
        //Get the account list
       var data = component.get("v.data");
       
       //Get the target object
       var selectedItem = event.currentTarget;
       //Get the selected item index
       var index = selectedItem.dataset.record;
       var selectedRecordToDelete = data[index].recordId;
       console.log('selectedRecordToDelete',selectedRecordToDelete);
       var deleteRecord = component.get("c.deleteRecord");
       deleteRecord.setParams({
           "recordId" :selectedRecordToDelete
       });
       $A.enqueueAction(deleteRecord);
       
       console.log('index',index);
       data.splice(index, 1);
       console.log('deleted data',data)
        component.set("v.data", data); 
    },
})