trigger AnnualAreaBudgetTrigger on Annual_Area_Budget__c (after insert, after update, after delete, before insert, before update) {

    Map<Id, Annual_Area_Budget__c> mapOfOldAnnualAreaBudgets;
    if (trigger.isUpdate || trigger.isDelete) {
        mapOfOldAnnualAreaBudgets = Trigger.oldMap;
    }
    Map<Id, Annual_Area_Budget__c> mapOfNewAnnualAreaBudgets;
    if ((trigger.isInsert && trigger.isAfter) || trigger.isUpdate) {
        mapOfNewAnnualAreaBudgets = Trigger.newMap;
    }

    List<Annual_Area_Budget__c> listOfNewAnnualAreaBudgets;
    if (!trigger.isDelete) {
       listOfNewAnnualAreaBudgets = Trigger.new;
    }

    if (trigger.isAfter) {

        if (trigger.isInsert || trigger.isUpdate) {
            List<Annual_Brand_Area_Budget_Plan__c> listOfAnnualBrandAreaBudgetPlans = AnnualBrandAreaBudgetPlans.generateRecordForEachBrand(mapOfNewAnnualAreaBudgets);
            if (!listOfAnnualBrandAreaBudgetPlans.isEmpty()) {
                system.debug('listOfAnnualBrandAreaBudgetPlans:::'+listOfAnnualBrandAreaBudgetPlans);
                //insert listOfAnnualBrandAreaBudgetPlans;
               Database.UpsertResult[] resultUp=  Database.upsert(listOfAnnualBrandAreaBudgetPlans, Annual_Brand_Area_Budget_Plan__c.External_Id__c,false);
               system.debug('resultUp:::'+resultUp); 
            }
        }

        //Create POC Budget for each POC in Territory
        if (trigger.isInsert) {
            List<Annual_POC_Budget_Plan__c> AnnualPOCBudgetList = AnnualPOCBudgetPlan.generateRecordForEachPOCInArea(mapOfNewAnnualAreaBudgets);
            system.debug('AnnualPOCBudgetList:::'+AnnualPOCBudgetList);
            if (!AnnualPOCBudgetList.isEmpty()) {
                insert AnnualPOCBudgetList;
            }

        }
        
        Annual_Area_Budget__c[] parentAnnualBudgets = AnnualAreaBudgets.rollupBudgetValuestoAllocated(mapOfOldAnnualAreaBudgets, mapOfNewAnnualAreaBudgets);
        if (!parentAnnualBudgets.isEmpty()) {
            update parentAnnualBudgets;
        }

        if (trigger.isUpdate) {
            Annual_POC_Budget_Plan__c[] listOfAnnualPOCBudgetPlans = AnnualAreaBudgets.uncheckIsUpdate(mapOfOldAnnualAreaBudgets, mapOfNewAnnualAreaBudgets);
            if  (!listOfAnnualPOCBudgetPlans.isEmpty()) {
                update listOfAnnualPOCBudgetPlans;
            }

            Annual_Area_Budget__c[] childAnnualAreaBudgets = AnnualAreaBudgets.updateApproverOnChild(mapOfOldAnnualAreaBudgets, mapOfNewAnnualAreaBudgets);
            if (!childAnnualAreaBudgets.isEmpty()) {
                update childAnnualAreaBudgets;
            }
            //Update Shopkit when approval status changed from submitted for Approval to Approved
            List<Marketing_Kit__c> shoppedKitList = AnnualAreaBudgets.updateApprovalStatusOnShopkit(mapOfOldAnnualAreaBudgets, mapOfNewAnnualAreaBudgets);
            if(!shoppedKitList.isEmpty()){
                update shoppedKitList;   
            }
            
        }
    }
    if (trigger.isBefore) {
        if (trigger.isInsert || trigger.isUpdate) {
            Boolean isUpdate = false;
            if (trigger.isUpdate) {
                isUpdate = true;
            }
            listOfNewAnnualAreaBudgets = AnnualAreaBudgets.setApproverBeforeInsert(listOfNewAnnualAreaBudgets, isUpdate);
            AnnualAreaBudgets.beforeInsertOrUpdate(Trigger.new);
        }
    }

}