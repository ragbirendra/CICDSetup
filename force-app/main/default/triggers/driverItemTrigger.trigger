//W-013969 Trigger is to update driver spend in to POC spend category variable spend

trigger driverItemTrigger on Driver_Item__c (after update, after insert) {
    if(trigger.isUpdate){
    List<POC_Spend_Category__c> pocToUpdate=new List<POC_Spend_Category__c>();
    SET<id> pocSpendCategoryID=new SET<Id>();
    for(Driver_Item__c objDrvrItem:Trigger.new)
    {
        Driver_Item__c  oldPoc = Trigger.oldMap.get(objDrvrItem.id);
 		System.debug('========oldPoc'+oldPoc);
        Decimal oldItemSPend=oldPoc.Item_Spend__c;
        Decimal newSpendValue=objDrvrItem.Item_Spend__c;
        System.debug('========oldItemSPend'+oldItemSPend +'==newSpendValue='+newSpendValue);
        if(oldItemSPend != newSpendValue)
        {
            pocSpendCategoryID.add(objDrvrItem.POC_Spend_Category__c);
        }    
    }
        for(POC_Spend_Category__c objPOC:[SELECT id, Variable_Spend__c FROM POC_Spend_Category__c WHERE ID IN:pocSpendCategoryID])
    	{
       for(Driver_Item__c objDriverItem:Trigger.new){
           if(objDriverItem.POC_Spend_Category__c==objPOC.id)
            {
                Driver_Item__c  oldPoc=Trigger.oldMap.get(objDriverItem.id);
                Decimal oldItemSPend=oldPoc.Item_Spend__c;
       			 Decimal newSpendValue=objDriverItem.Item_Spend__c;
                if(oldItemSPend == null && newSpendValue != null)
                {
                   objPOC.Variable_Spend__c= objPOC.Variable_Spend__c+ newSpendValue;
                }
                else if(oldItemSPend < newSpendValue){
                objPOC.Variable_Spend__c =objPOC.Variable_Spend__c - oldItemSPend + newSpendValue;
                }
                else if(oldItemSPend > newSpendValue){
                 objPOC.Variable_Spend__c =objPOC.Variable_Spend__c- oldItemSPend + newSpendValue;   
                }
                pocToUpdate.add(objPOC);
            }
           }  
    	}
   // update pocToUpdate;
    }
}