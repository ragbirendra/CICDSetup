/* W-013969
   Updated updateDriverAndDiscretionarySpendFromShoppedKitItems method
   Updated By- Amol P 
*/
public class POCSpendCategories {

    public static List<POC_Spend_Category__c> createEachSpendCategoryRecordType(Map<Id, Annual_POC_Budget_Plan__c> newlyCreatedAnnualPOCBudgetPlans) {
        /*
        List<RecordType> BudgetRTList = [
            SELECT Id, DeveloperName From RecordType 
            WHERE (SObjectType = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory') 
            OR (SObjectType = 'Annual_Area_Budget__c' AND DeveloperName = 'IH_Territory') 
            OR (SObjectType =: 'Account' AND DeveloperName =: 'Outlet')
        ];
        

        RecordType OOHRT;
        RecordType IHRT;

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                OOHRT = rt;
            }
            else if(rt.DeveloperName == 'IH_Territory') {
                IHRT = rt;
            }
        }
        */
        ID OOHRTId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        ID IHRTId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('IH Territory').getRecordTypeId();
        ID NIHRTId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH Territory').getRecordTypeId();

        Boolean containsIHTerritory = false;
        Boolean containsNIHTerritory = false;
        Boolean containsOOHTerritory = false;

        for (Annual_POC_Budget_Plan__c annualPOCBudgetPlan : newlyCreatedAnnualPOCBudgetPlans.values()) {
            if (annualPOCBudgetPlan.Territory_Type__c == OOHRTId) {
                containsOOHTerritory = true;
            } else if (annualPOCBudgetPlan.Territory_Type__c == IHRTId) {
                containsIHTerritory = true;
            }else if (annualPOCBudgetPlan.Territory_Type__c == NIHRTId) {
                containsNIHTerritory = true;
            }
        }

        List<RecordType> recordTypeList = new List<RecordType>();
        if (containsOOHTerritory && containsIHTerritory && containsNIHTerritory) {
            recordTypeList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND IsActive = TRUE AND (DeveloperName LIKE '%In_Home' OR DeveloperName LIKE '%Out_of_Home')];
        } else if (containsIHTerritory ) {
            recordTypeList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND IsActive = TRUE AND DeveloperName LIKE '%In_Home'];
        } else if(containsOOHTerritory || containsNIHTerritory ){
            recordTypeList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND IsActive = TRUE AND DeveloperName LIKE '%Out_of_Home'];
        }
        system.debug(recordTypeList); 

        List<POC_Spend_Category__c> listOfPOCSpendCategories = new List<POC_Spend_Category__c>();
        for (Id annualPOCBudgetPlanID : newlyCreatedAnnualPOCBudgetPlans.keySet()) {
            for (RecordType recordType : recordTypeList) {
                if (containsOOHTerritory && containsIHTerritory) {
                    if (!recordType.DeveloperName.contains('In_Home') && newlyCreatedAnnualPOCBudgetPlans.get(annualPOCBudgetPlanID).Territory_Type__c == IHRTId) {
                        continue;
                    } else if (!recordType.DeveloperName.contains('Out_of_Home') && newlyCreatedAnnualPOCBudgetPlans.get(annualPOCBudgetPlanID).Territory_Type__c == OOHRTId) {
                        continue;
                    }else if (!recordType.DeveloperName.contains('Out_of_Home') && newlyCreatedAnnualPOCBudgetPlans.get(annualPOCBudgetPlanID).Territory_Type__c == NIHRTId) {
                        continue;
                    }
                }
                POC_Spend_Category__c newSpendCategory = new POC_Spend_Category__c();
                newSpendCategory.Annual_POC_Budget_Plan__c = annualPOCBudgetPlanID;
                newSpendCategory.Name = recordType.Name;
                newSpendCategory.Discretionary_Core_POCM_Spend__c = 0;
                newSpendCategory.Discretionary_CRM_Spend__c = 0;
                newSpendCategory.Discretionary_Marketing_Investment_Spend__c = 0;
                newSpendCategory.Pre_Planning_Spend__c = 0;
                newSpendCategory.Trade_Activation_Discretionary_Spend__c = 0;
                newSpendCategory.Trade_Activation_Driver_Spend__c = 0;
                newSpendCategory.Variable_Spend__c = 0;
                newSpendCategory.recordTypeId = recordType.Id;
                system.debug(newSpendCategory);
                listOfPOCSpendCategories.add(newSpendCategory);
            }
        }
        return listOfPOCSpendCategories;
    }

    public static List<POC_Spend_Category__c> updateDriverAndDiscretionarySpendFromShoppedKitItems(Map<Id, Marketing_Kit__c> oldMapOfShoppedKitItems, Map<Id, Marketing_Kit__c> newMapOfShoppedKitItems) {
        System.debug('===in update discretionary and driver---Old'+oldMapOfShoppedKitItems);
        System.debug('===in update discretionary and driver---new'+newMapOfShoppedKitItems);
        Map<Id, Decimal> newDriverRollupValues = new Map<Id, Decimal>(); 
        Map<Id, Decimal> newDiscretionaryRollupValues = new Map<Id, Decimal>();
        Map<Id, Decimal> newUserPaidRollupValues = new Map<Id, Decimal>();          //User Paid
        Map<Id, Decimal> newTotalRollupValues = new Map<Id, Decimal>();

        //List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND (DeveloperName = 'Trade_Activation_Out_of_Home' OR DeveloperName = 'Programming_In_Home')];

        ID TradeActivationRTId = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Trade Activation').getRecordTypeId();
        ID ProgrammingRTId = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Programming').getRecordTypeId();
        ID DiscretionaryId= Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Discretionary').getRecordTypeId();      //AP Changes W-01369   //AP CHanges


        for (Id marketingKitID : newMapOfshoppedKitItems.keySet()) {
            Marketing_Kit__c shoppedKitItem = newMapOfshoppedKitItems.get(marketingKitID);
            Decimal oldDriverSpend = 0.00;
            Decimal oldDiscretionarySpend = 0.00;
            Decimal oldUserPaidSpend = 0.00;                      //User Paid
            Decimal oldTotalSpend = 0.00;

            if (oldMapOfshoppedKitItems.containsKey(marketingKitID)) {
                if (oldMapOfshoppedKitItems.get(marketingKitID).Driver_Spend_Total__c != null) {
                    oldDriverSpend = oldMapOfshoppedKitItems.get(marketingKitID).Driver_Spend_Total__c;
                }
                if (oldMapOfshoppedKitItems.get(marketingKitID).Discretionary_Spend_Total__c != null) {
                    if(!oldMapOfshoppedKitItems.get(marketingKitID).User_Paid__c){
                    	oldDiscretionarySpend = oldMapOfshoppedKitItems.get(marketingKitID).Discretionary_Spend_Total__c;
                    }
                    else{
                        oldUserPaidSpend= oldMapOfshoppedKitItems.get(marketingKitID).Discretionary_Spend_Total__c; 
                    }
                }
                
                if (oldMapOfshoppedKitItems.get(marketingKitID).Total_Spend__c != null) {
                    oldTotalSpend = oldMapOfShoppedKitItems.get(marketingKitID).Total_Spend__c;
                }
            }
            System.debug('==oldDriverSpend '+oldDriverSpend +'====oldDiscretionarySpend @@'+oldDiscretionarySpend +'=oldTotalSpend ='+oldTotalSpend );
            System.debug('==shoppedKitItem.POC_Spend_Category__c@@'+shoppedKitItem.POC_Spend_Category__c+'====shoppedKitItem.Driver_Spend_Total__c @@'+shoppedKitItem.Driver_Spend_Total__c+'=shoppedKitItem.Discretionary_Spend_Total__c='+shoppedKitItem.Discretionary_Spend_Total__c+'==shoppedKitItem.Total_Spend__c=='+shoppedKitItem.Total_Spend__c); 
            if (shoppedKitItem.POC_Spend_Category__c != null && 
                (shoppedKitItem.Driver_Spend_Total__c != oldDriverSpend || shoppedKitItem.Discretionary_Spend_Total__c != oldDiscretionarySpend || shoppedKitItem.Discretionary_Spend_Total__c != oldUserPaidSpend || shoppedKitItem.Total_Spend__c != oldTotalSpend)
                ) {
                
                Decimal driverSpend = 0.00;
                Decimal discretionarySpend = 0.00;
                Decimal userSpend = 0.00;
                Decimal totalSpend = 0.00;

                if (shoppedKitItem.Total_Spend__c != null) {
                    totalSpend = shoppedKitItem.Total_Spend__c;
                }                
                if (shoppedKitItem.Driver_Spend_Total__c != null) {
                    driverSpend = shoppedKitItem.Driver_Spend_Total__c;
                }
                if (shoppedKitItem.Discretionary_Spend_Total__c != null) {
                    if(!shoppedKitItem.User_Paid__c){
                   	 discretionarySpend = shoppedKitItem.Discretionary_Spend_Total__c;
                    }
                    else
                    {
                     userSpend   = shoppedKitItem.Discretionary_Spend_Total__c;
                    }
                }
                


                if (!newDriverRollupValues.containsKey(shoppedKitItem.POC_Spend_Category__c)) {
                    newDriverRollupValues.put(shoppedKitItem.POC_Spend_Category__c, 0);
                }
                if (!newDiscretionaryRollupValues.containsKey(shoppedKitItem.POC_Spend_Category__c)) {
                    newDiscretionaryRollupValues.put(shoppedKitItem.POC_Spend_Category__c, 0);
                }
               if(!newUserPaidRollupValues.containsKey(shoppedKitItem.POC_Spend_Category__c)){
                    newUserPaidRollupValues.put(shoppedKitItem.POC_Spend_Category__c, 0);    
                }
                    
                if (!newTotalRollupValues.containsKey(shoppedKitItem.POC_Spend_Category__c)) {
                    newTotalRollupValues.put(shoppedKitItem.POC_Spend_Category__c, 0);
                }

                if ( (driverSpend - oldDriverSpend) != 0 || (discretionarySpend - oldDiscretionarySpend) != 0 || (userSpend - oldUserPaidSpend) != 0 ) {
                    newDriverRollupValues.put(shoppedKitItem.POC_Spend_Category__c,
                        newDriverRollupValues.get(shoppedKitItem.POC_Spend_Category__c) + 
                        (driverSpend - oldDriverSpend) 
                    );
                    newDiscretionaryRollupValues.put(shoppedKitItem.POC_Spend_Category__c,
                        newDiscretionaryRollupValues.get(shoppedKitItem.POC_Spend_Category__c) + 
                        (discretionarySpend - oldDiscretionarySpend)
                    );
                    newUserPaidRollupValues.put(shoppedKitItem.POC_Spend_Category__c,
                         newUserPaidRollupValues.get(shoppedKitItem.POC_Spend_Category__c) + 
                        (userSpend - oldUserPaidSpend)
                    );
                }

                if (totalSpend - oldTotalSpend != 0) {
                    newTotalRollupValues.put(shoppedKitItem.POC_Spend_Category__c,
                        newTotalRollupValues.get(shoppedKitItem.POC_Spend_Category__c) + 
                        (totalSpend - oldTotalSpend)
                    );
                }
            }
        }
        User oUser = [select id,isClubElite__c FROM User Where id =: userInfo.getUserId()];    //AP Changes -W013969 
        List<POC_Spend_Category__c> pocSpendCategoryList = new List<POC_Spend_Category__c>();
        System.debug('=====newDriverRollupValues@@@'+newDriverRollupValues);
        string territiryId ='';
        if (!newDriverRollupValues.keySet().isEmpty()) {
            boolean isBackOfficeUser=false;
           // if(!test.isRunningTest()){
           
               // territiryId = (string)Cache.Session.get('TerritoryBudgetId'); //added by Ragbirendra for DSM dashboard
                // system.debug('territiryId::::::'+territiryId);
               // isBackOfficeUser = POCPlanningApp.checkIfBackOfficeUser(territiryId);
          //  }
           //  if(!isBackOfficeUser){
            pocSpendCategoryList = [SELECT Id, Trade_Activation_Discretionary_Spend__c, Trade_Activation_Driver_Spend__c, Programming_Spend__c,Trade_Activation_User_Paid_Spend__c FROM POC_Spend_Category__c WHERE Id IN :newDriverRollupValues.keySet() AND (recordTypeId = :TradeActivationRTId OR recordTypeId = :ProgrammingRTId)];
           // }
            //else 
           // {
           //  if(oUser.isClubElite__c)
            // {
             //   pocSpendCategoryList = [SELECT Id, Trade_Activation_Discretionary_Spend__c, Trade_Activation_Driver_Spend__c, Programming_Spend__c FROM POC_Spend_Category__c WHERE Id IN :newDriverRollupValues.keySet() AND (recordTypeId = :TradeActivationRTId OR recordTypeId = :ProgrammingRTId)];

           //  }
           //  else
          //   {
          //    pocSpendCategoryList = [SELECT Id, Trade_Activation_Discretionary_Spend__c,Variable_Spend__c, Trade_Activation_Driver_Spend__c, Programming_Spend__c FROM POC_Spend_Category__c WHERE Id IN :newDriverRollupValues.keySet() AND (recordTypeId = :DiscretionaryId)];
          //   }
          //  }
            System.debug('=====pocSpendCategoryList @@@'+pocSpendCategoryList );
        }
        for (POC_Spend_Category__c pocSpendCategory : pocSpendCategoryList) {
       // System.debug('===in update discretionary and driver---'+pocSpendCategory.Variable_Spend__c);
            if (pocSpendCategory.Trade_Activation_Driver_Spend__c == null) {   pocSpendCategory.Trade_Activation_Driver_Spend__c = 0;
            }
            if (pocSpendCategory.Trade_Activation_Discretionary_Spend__c == null) {  pocSpendCategory.Trade_Activation_Discretionary_Spend__c = 0 ;
            }
            if(pocSpendCategory.Trade_Activation_User_Paid_Spend__c == null){
                pocSpendCategory.Trade_Activation_User_Paid_Spend__c = 0 ;
            }
            if (pocSpendCategory.Programming_Spend__c == null) { pocSpendCategory.Programming_Spend__c = 0;
            }
           //  if(!POCPlanningApp.checkIfBackOfficeUser(territiryId)){    //AP Changes   W-013969
            pocSpendCategory.Trade_Activation_Driver_Spend__c = pocSpendCategory.Trade_Activation_Driver_Spend__c + newDriverRollupValues.get(pocSpendCategory.Id);
            pocSpendCategory.Trade_Activation_Discretionary_Spend__c = pocSpendCategory.Trade_Activation_Discretionary_Spend__c + newDiscretionaryRollupValues.get(pocSpendCategory.Id);
            pocSpendCategory.Trade_Activation_User_Paid_Spend__c = pocSpendCategory.Trade_Activation_User_Paid_Spend__c + newUserPaidRollupValues.get(pocSpendCategory.Id);
            pocSpendCategory.Programming_Spend__c = pocSpendCategory.Programming_Spend__c + newTotalRollupValues.get(pocSpendCategory.Id);
           /* }
            else
            {
                if(oUser.isClubElite__c)
               {
                    pocSpendCategory.Trade_Activation_Driver_Spend__c = pocSpendCategory.Trade_Activation_Driver_Spend__c + newDriverRollupValues.get(pocSpendCategory.Id);
                    pocSpendCategory.Trade_Activation_Discretionary_Spend__c = pocSpendCategory.Trade_Activation_Discretionary_Spend__c + newDiscretionaryRollupValues.get(pocSpendCategory.Id);
                    pocSpendCategory.Programming_Spend__c = pocSpendCategory.Programming_Spend__c + newTotalRollupValues.get(pocSpendCategory.Id);
                }
                else
                {
                    
                  System.debug('===in update discretionary and driver---'+pocSpendCategory.Variable_Spend__c+'===='+newTotalRollupValues.get(pocSpendCategory.Id));
                  pocSpendCategory.Variable_Spend__c=pocSpendCategory.Variable_Spend__c+newTotalRollupValues.get(pocSpendCategory.Id);
                  System.debug('===in update discretionary and driver---'+pocSpendCategory.Variable_Spend__c);
                }
            }*/
        }

        return pocSpendCategoryList;
    }

}