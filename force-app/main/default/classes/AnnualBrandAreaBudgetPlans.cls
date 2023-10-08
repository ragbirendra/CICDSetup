public class AnnualBrandAreaBudgetPlans {

    public static List<Annual_Brand_Area_Budget_Plan__c> generateRecordForEachBrand(Map<Id, Annual_Area_Budget__c> mapOfAnnualAreaBudgets) {
        //List<RecordType> recordTypeList = [SELECT Id, DeveloperName FROM RecordType WHERE (sobjecttype = 'Brand__c' AND DeveloperName = 'Trade_Activation') OR (sobjecttype = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory')];


        ID brandrecordTypeID = Schema.SObjectType.Brand__c.getRecordTypeInfosByName().get('Trade Activation').getRecordTypeId();
        ID OOHTerritoryRecTypeID = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        ID NIHTerritoryRecTypeID = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH Territory').getRecordTypeId();
            //added by Rag: IN Home
/*
        RecordType brandrecordType = new RecordType();
        RecordType recordType = new RecordType();
        
        for(RecordType rt: recordTypeList){
            if(rt.DeveloperName == 'Trade_Activation'){
                brandrecordType = rt;
            } 
            else if(rt.DeveloperName == 'Territory'){
              recordType = rt;    
            }
        }
*/
        List<Brand__c> listOfBrands = [SELECT Id, Name,User_Paid__c FROM Brand__c Where RecordTypeId = :brandrecordTypeID AND Is_IH_Only__c != true];       //Added by AP User Paid
        List<Annual_Brand_Area_Budget_Plan__c> listOfPreExistingAnnualBrandAreaBudgetPlans = [
       SELECT Id, Annual_Area_Budget__c, Brand__c, Brand__r.Name 
            FROM Annual_Brand_Area_Budget_Plan__c 
       WHERE Annual_Area_Budget__c IN :mapOfAnnualAreaBudgets.keySet() AND Brand__r.Is_IH_Only__c != true
        ];
        

        Map<String, Annual_Brand_Area_Budget_Plan__c> mapOfAnnualAreaBudgetAndBrand = new Map<String, Annual_Brand_Area_Budget_Plan__c>();
        //Map<String ,Annual_Brand_Area_Budget_Plan__c> mapofPreExistingExternalId = new Map<String ,Annual_Brand_Area_Budget_Plan__c>();
        for (Annual_Brand_Area_Budget_Plan__c preExistingAnnualbrandAreaBudgetPlan : listOfPreExistingAnnualBrandAreaBudgetPlans) {
            mapOfAnnualAreaBudgetAndBrand.put(
                preExistingAnnualbrandAreaBudgetPlan.Annual_Area_Budget__c + '' + preExistingAnnualbrandAreaBudgetPlan.Brand__c, 
                preExistingAnnualbrandAreaBudgetPlan
            );
              
        }
		System.debug(' @@@ mapOfAnnualAreaBudgetAndBrand @@@'+mapOfAnnualAreaBudgetAndBrand);
        List<Annual_Brand_Area_Budget_Plan__c> listOfAnnualBrandAreaBudgetPlans = new List<Annual_Brand_Area_Budget_Plan__c>();
        List<String> duplicateExternalId = new List<String>();
        for (Id aabID : mapOfAnnualAreaBudgets.keySet()) {
            for (Brand__c brand : listOfBrands) {
                System.debug(' @@@ Brand__c @@@'+brand);
                if (!mapOfAnnualAreaBudgetAndBrand.containsKey(aabID + '' + brand.Id) && (mapOfAnnualAreaBudgets.get(aabID).recordTypeId == OOHTerritoryRecTypeID || mapOfAnnualAreaBudgets.get(aabID).recordTypeId == NIHTerritoryRecTypeID )) {//added by rag:Inhome
                    System.debug(' @@@ mapOfAnnualAreaBudgetAndBrand @@@'+mapOfAnnualAreaBudgetAndBrand);
                    string recordtypename = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosById().get(mapOfAnnualAreaBudgets.get(aabID).recordTypeId).getname(); 
                    System.debug('---- in a AABId---'+aabID );
                    Annual_Brand_Area_Budget_Plan__c annualBrandAreaBudgetPlan = new Annual_Brand_Area_Budget_Plan__c();
                    annualBrandAreaBudgetPlan.Annual_Area_Budget__c = aabID;
                    annualBrandAreaBudgetPlan.Brand__c = brand.Id;
                    annualBrandAreaBudgetPlan.Brand_Budget__c = 0;                
                    annualBrandAreaBudgetPlan.User_Paid__c = brand.User_Paid__c;     // Added by Amol User Paid  W-014033
                                      
                    //added by Ragbirendra
                    system.debug('External Key:::'+mapOfAnnualAreaBudgets.get(aabID).Territory_Code__c+'_'+mapOfAnnualAreaBudgets.get(aabID).Budget_Year__c+'_'+brand.Name+'_'+recordtypename);
                    if(!duplicateExternalId.contains(mapOfAnnualAreaBudgets.get(aabID).Territory_Code__c+'_'+mapOfAnnualAreaBudgets.get(aabID).Budget_Year__c+'_'+brand.Name+'_'+recordtypename)){
                        duplicateExternalId.add(mapOfAnnualAreaBudgets.get(aabID).Territory_Code__c+'_'+mapOfAnnualAreaBudgets.get(aabID).Budget_Year__c+'_'+brand.Name+'_'+recordtypename);
                        annualBrandAreaBudgetPlan.External_Id__c = mapOfAnnualAreaBudgets.get(aabID).Territory_Code__c+'_'+mapOfAnnualAreaBudgets.get(aabID).Budget_Year__c+'_'+brand.Name+'_'+recordtypename;//added to populate external id field in annual brand budget
                        listOfAnnualBrandAreaBudgetPlans.add(annualBrandAreaBudgetPlan);
                       }
                    }
                }
                
            }
         system.debug('listOfAnnualBrandAreaBudgetPlans::::'+listOfAnnualBrandAreaBudgetPlans);
        for(Annual_Brand_Area_Budget_Plan__c aa:listOfAnnualBrandAreaBudgetPlans){
          system.debug('final external Key::::'+aa.External_Id__c);  
        }

        return listOfAnnualBrandAreaBudgetPlans;
    }

    public static List<Annual_Brand_Area_Budget_Plan__c> updateDriverAndDiscretionarySpendFromShoppedKitItems(Map<Id, Marketing_Kit__c> oldMapOfShoppedKitItems, Map<Id, Marketing_Kit__c> newMapOfShoppedKitItems) {
        Map<Id, Decimal> newDriverRollupValues = new Map<Id, Decimal>(); 
        Map<Id, Decimal> newDiscretionaryRollupValues = new Map<Id, Decimal>();
        Set<String> brandNameSet = new Set<String>();

        for (Id marketingKitID : newMapOfshoppedKitItems.keySet()) {
            Marketing_Kit__c shoppedKitItem = newMapOfshoppedKitItems.get(marketingKitID);
            Decimal oldDriverSpend = 0.00;
            Decimal oldDiscretionarySpend = 0.00;

            if (oldMapOfshoppedKitItems.containsKey(marketingKitID)) {
                if (oldMapOfshoppedKitItems.get(marketingKitID).Driver_Spend_Total__c != null) {
                    oldDriverSpend = oldMapOfshoppedKitItems.get(marketingKitID).Driver_Spend_Total__c;
                }
                if (oldMapOfshoppedKitItems.get(marketingKitID).Discretionary_Spend_Total__c != null) {
                    oldDiscretionarySpend = oldMapOfshoppedKitItems.get(marketingKitID).Discretionary_Spend_Total__c;
                }
            }

            if (shoppedKitItem.Annual_Brand_Area_Budget_Plan__c != null && (shoppedKitItem.Driver_Spend_Total__c != oldDriverSpend || 
                 shoppedKitItem.Discretionary_Spend_Total__c != oldDiscretionarySpend)) {
                
                Decimal driverSpend = 0.00;
                Decimal discretionarySpend = 0.00;

                if (shoppedKitItem.Driver_Spend_Total__c != null) {
                    driverSpend = shoppedKitItem.Driver_Spend_Total__c;
                }

                if (shoppedKitItem.Discretionary_Spend_Total__c != null) {
                    discretionarySpend = shoppedKitItem.Discretionary_Spend_Total__c;
                }

                if (!newDriverRollupValues.containsKey(shoppedKitItem.Annual_Brand_Area_Budget_Plan__c)) {
                    newDriverRollupValues.put(shoppedKitItem.Annual_Brand_Area_Budget_Plan__c, 0.00);
                }
                if (!newDiscretionaryRollupValues.containsKey(shoppedKitItem.Annual_Brand_Area_Budget_Plan__c)) {
                    newDiscretionaryRollupValues.put(shoppedKitItem.Annual_Brand_Area_Budget_Plan__c, 0.00);
                }
                brandNameSet.add(shoppedKitItem.Brand__c);
                
                newDriverRollupValues.put(shoppedKitItem.Annual_Brand_Area_Budget_Plan__c,
                    newDriverRollupValues.get(shoppedKitItem.Annual_Brand_Area_Budget_Plan__c) + 
                    (driverSpend - oldDriverSpend) 
                );
                newDiscretionaryRollupValues.put(shoppedKitItem.Annual_Brand_Area_Budget_Plan__c,
                    newDiscretionaryRollupValues.get(shoppedKitItem.Annual_Brand_Area_Budget_Plan__c) + 
                    (discretionarySpend - oldDiscretionarySpend)
                );
            }
        }

        List<Annual_Brand_Area_Budget_Plan__c> listOfAnnualBrandAreaBudgetPlans = new List<Annual_Brand_Area_Budget_Plan__c>();
        if (!newDriverRollupValues.keySet().isEmpty()) {
            User oUser = [select id,isClubElite__c FROM User Where id =: userInfo.getUserId()]; 
            //if(!oUser.isClubElite__c){
            listOfAnnualBrandAreaBudgetPlans = [SELECT Id, Discretionary_Spend__c, Driver_Spend__c FROM Annual_Brand_Area_Budget_Plan__c WHERE Id IN :newDriverRollupValues.keySet() AND Brand__r.Name IN :brandNameSet];
            //}
            //else{
             //listOfAnnualBrandAreaBudgetPlans = [SELECT Id, Discretionary_Spend__c, Driver_Spend__c FROM Annual_Brand_Area_Budget_Plan__c WHERE Id IN :newDriverRollupValues.keySet() AND Brand__r.Name IN :brandNameSet AND Brand__r.Name = 'Club Elite'];   
            //}
        }
        system.debug('===newDriverRollupValues==='+newDriverRollupValues);
        system.debug('===newDiscretionaryRollupValues==='+newDiscretionaryRollupValues);
        for (Annual_Brand_Area_Budget_Plan__c annualBrandAreaBudgetPlan : listOfAnnualBrandAreaBudgetPlans) {
            if (annualBrandAreaBudgetPlan.Driver_Spend__c == null) { 
                annualBrandAreaBudgetPlan.Driver_Spend__c = 0;
            }
            if (annualBrandAreaBudgetPlan.Discretionary_Spend__c == null) { 
                annualBrandAreaBudgetPlan.Discretionary_Spend__c = 0 ;
            }
           // annualBrandAreaBudgetPlan.Driver_Spend__c = annualBrandAreaBudgetPlan.Driver_Spend__c + newDriverRollupValues.get(annualBrandAreaBudgetPlan.Id);
          //  annualBrandAreaBudgetPlan.Driver_Spend__c = annualBrandAreaBudgetPlan.Driver_Spend__c + newDriverRollupValues.get(annualBrandAreaBudgetPlan.Id);
            annualBrandAreaBudgetPlan.Discretionary_Spend__c = annualBrandAreaBudgetPlan.Discretionary_Spend__c + newDriverRollupValues.get(annualBrandAreaBudgetPlan.Id) +newDiscretionaryRollupValues.get(annualBrandAreaBudgetPlan.Id);
        }

        return listOfAnnualBrandAreaBudgetPlans;
    }

}