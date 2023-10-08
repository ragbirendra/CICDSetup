({
	  doInit: function (component, event, helper) {
        var UsrinfoAction = component.get("c.FetchUserInfo");
        UsrinfoAction.setCallback(this, function (response) {
        var state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            if (state === "SUCCESS") {
                var usrRecords = response.getReturnValue();  
                 console.log('FetchUserInfo',usrRecords);
               if(usrRecords.Is_TAU_Admin__c == true && usrRecords.is_TAU_User__c == false){
                    component.set("v.isTAAdmin", true);
                    component.set("v.isTAUser", false);
                    console.log('FetchUserInfo1',usrRecords);
                }else  if(usrRecords.is_TAU_User__c == true && usrRecords.Is_TAU_Admin__c == false ){
                    component.set("v.isTAAdmin", false);
                    component.set("v.isTAUser", true);
                    console.log('FetchUserInfo2',usrRecords);
                }else{
                    component.set("v.isTAAdmin", false);
                    component.set("v.isTAUser", false);
                    console.log('FetchUserInfo3',usrRecords);
                    alert('User should be TAU Admin or TAU user to have complete access to this page');
                }
                console.log('success');
            } else {
                console.log('error');
            }
            
        });
        $A.enqueueAction(UsrinfoAction);
      },
    
 /*    handleComponentEvent : function(cmp, event) {
        var selectedTabId = event.getParam("tabssetValue");

        // set the handler attributes based on event data
        cmp.set("v.selectedTabIdVal", selectedTabId);
       // var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
       // cmp.set("v.numEvents", numEventsHandled);
    } */
})