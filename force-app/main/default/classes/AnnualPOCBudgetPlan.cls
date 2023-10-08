public with sharing class AnnualPOCBudgetPlan {
    
    public static final String COOLER = 'Cooler';
    public static final String NON_BUD = 'Tier Non-Bud';
    public static final String IH_TERRITORY = 'IH Territory';

    public static Boolean triggerBypass = false;

    //Create POC Budget for each POC in Territory
    public static List<Annual_POC_Budget_Plan__c> generateRecordForEachPOCInArea(Map<Id, Annual_Area_Budget__c> mapOfNewAnnualAreaBudgets) {
        
        /*
        List<RecordType> BudgetRTList = [
            SELECT Id, DeveloperName From RecordType 
            WHERE (SObjectType = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory') 
                OR (SObjectType = 'Annual_Area_Budget__c' AND DeveloperName = 'IH_Territory') 
                OR (SObjectType =: 'Account' AND DeveloperName = 'Outlet')
                OR (SObjectType =: 'Annual_POC_Budget_Plan__c')
            ]; 

        RecordType OOHRT;
        RecordType IHRT;
        RecordType OutletRT;
        RecordType pocIH;
        RecordType pocOOH;
        */

        ID OOHRTid = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        ID IHRTid  = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('IH Territory').getRecordTypeId();
        ID NIHRTid = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH Territory').getRecordTypeId();
        ID OutletRTid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
        ID pocIHRTid  = Schema.SObjectType.Annual_POC_Budget_Plan__c.getRecordTypeInfosByName().get('IH POC Budget Plan').getRecordTypeId();
        ID pocOOHRTid = Schema.SObjectType.Annual_POC_Budget_Plan__c.getRecordTypeInfosByName().get('OOH POC Budget Plan').getRecordTypeId();
        ID pocNIHRTid = Schema.SObjectType.Annual_POC_Budget_Plan__c.getRecordTypeInfosByName().get('New IH POC Budget Plan').getRecordTypeId();
        //added by Rag : IN home
        /*
        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                OOHRT = rt;
            }
            else if(rt.DeveloperName == 'IH_Territory') {
                IHRT = rt;
            }
            else if(rt.DeveloperName == 'Outlet'){
                OutletRT = rt;
            } else if (rt.DeveloperName == 'IH_POC_Budget_Plan') {
                pocIH = rt;
            } else if (rt.DeveloperName == 'OOH_POC_Budget_Plan') {
                pocOOH = rt;
            }
        }
        */
        List<Annual_POC_Budget_Plan__c> AnnualPOCBudgetList = new List<Annual_POC_Budget_Plan__c>();
        Set<String> TerritorySet = new Set<String>();
        Integer NumOfTerritories2Set = 5;
        Map<Integer, Set<String>> mapOfTerritorySetsByGroupNum = new Map<Integer, Set<String>>();
        Map<String, Annual_Area_Budget__c> mapOfNewAnnualAreaBudgetsByTerrId = new Map<String, Annual_Area_Budget__c>();
        Map<Id, Id> mapOfBudgetsAndThePOCRTForThem = new Map<Id, Id>();
        Map<Id, String> regionIDByAAB = new Map<Id, String>();
        Map<Id, String> yearByAAB = new Map<Id, String>();
        Set<Id> TerritoryIdSet = new Set<Id>();
        Set<String> yearsInUse = new Set<String>();
        Set<String> regionIDs = new Set<String>();

        //Get the Ids for all the all the new territory budgets
        for(Annual_Area_Budget__c aab: mapOfNewAnnualAreaBudgets.values()){
            if((aab.RecordTypeId == OOHRTid || aab.RecordTypeId == IHRTid || aab.RecordTypeId == NIHRTid) && aab.Sales_Territory__c != null){
                TerritoryIdSet.add(aab.Id);
                yearsInUse.add(aab.Budget_Year__c);
                yearByAAB.put(aab.Id, aab.Budget_Year__c);
            }
        }
         System.debug('@@@@TerritoryIdSet---'+TerritoryIdSet+'--yearsInUse---'+yearsInUse+'#####'+yearByAAB);
        //Look to see if any new budgets are a territory
        if(!TerritoryIdSet.isEmpty()) {        
            Map<ID, Annual_Area_Budget__c> aabMap2 = new Map<ID, Annual_Area_Budget__c>(
                    [ SELECT Id, Sales_Territory__c, Sales_Territory__r.Name, RecordTypeId, Budget_Year__c, Sales_Territory__r.lboc_Region_ID__c 
                    FROM Annual_Area_Budget__c WHERE Id IN :TerritoryIdSet ]  
            );

                    System.debug('@@@@aabMap2.values()---'+aabMap2.values());
 
            for(Annual_Area_Budget__c aab: aabMap2.values()){
                regionIDByAAB.put(aab.Id, aab.Sales_Territory__r.lboc_Region_ID__c);
                regionIDs.add(aab.Sales_Territory__r.lboc_Region_ID__c);
                if((aab.RecordTypeId == OOHRTId || aab.RecordTypeId == IHRTId || aab.RecordTypeId == NIHRTId) && aab.Sales_Territory__c != null && String.isNotBlank(aab.Sales_Territory__r.Name)) {
                    TerritorySet.add(aab.Sales_Territory__r.Name);
                    mapOfNewAnnualAreaBudgetsByTerrId.put(aab.Sales_Territory__r.Name, aab);
                    if (aab.RecordTypeId == OOHRTId) {
                        mapOfBudgetsAndThePOCRTForThem.put(aab.Id, pocOOHRTId);
                    } else if (aab.RecordTypeId == IHRTId){
                        mapOfBudgetsAndThePOCRTForThem.put(aab.Id, pocIHRTId);
                    }
                    else if (aab.RecordTypeId == NIHRTId){
                        mapOfBudgetsAndThePOCRTForThem.put(aab.Id, pocNIHRTId);
                    }
                }
            }

            List<In_Home_Budgets__c> globalBudgets = [SELECT Id, Budget__c, In_Store_Driver_Minimum__c, Programming_Maximum__c, 
                                                            Tier__c, Traffic_Driver_Minimum__c, Region_ID__c, Year__c FROM In_Home_Budgets__c 
                                                                    WHERE Year__c IN :yearsInUse AND Region_ID__c = :regionIDs];

            //Debulkifying to get Account Record Count from Query under 200k
            Integer TerritoryCount = 0;
            Integer TerritorySetGroupNum = 0;
            for(String TerritoryName: TerritorySet){
                if(TerritoryCount == 0){
                    Set<String> TempTerritorySet = new Set<String>();
                    TempTerritorySet.add(TerritoryName);
                    mapOfTerritorySetsByGroupNum.put(TerritorySetGroupNum, TempTerritorySet);
                }
                else {
                    mapOfTerritorySetsByGroupNum.get(TerritorySetGroupNum).add(TerritoryName);                                       
                }

                TerritoryCount++;
                //If Max num of Territories to Set reached
                if(TerritoryCount == NumOfTerritories2Set){
                    TerritoryCount = 0;
                    TerritorySetGroupNum++;
                }
            }
        
            List<Account> AccountList = new List<Account>();
            for(Integer i=0; i<=TerritorySetGroupNum; i++) {
                System.debug('i: ' + i);
                if(mapOfTerritorySetsByGroupNum.containsKey(i)){
                    Set<String> TempTerritorySet = mapOfTerritorySetsByGroupNum.get(i);
                    System.debug('---i:-----TempTerritorySet----'+TempTerritorySet);
                    if (!TempTerritorySet.isEmpty()) {
                        List<Account> TempAccountList = [
                            SELECT Id, Name, Club_Bud_Tier__c, 
                            lboc_Sales_Territory__c, lboc_Channel__c,NAZ_OnPlan_BOPOC__c, lboc_Labatt_Outlet_Id__c,OnPlan_Sales_Territory__r.lboc_Territory_ID__c
                            FROM Account
                            WHERE lboc_Sales_Territory__c In: TempTerritorySet 
                            AND RecordTypeId =: OutletRTid
                        ];
                        AccountList.addAll(TempAccountList);
                    }
                }
            }

            Integer MaxNameLength = 74;        

            System.debug('AccountList' + AccountList.size());
            System.debug(AccountList);

            for (Account a: AccountList) {
                String Name;
                if(a.Name.length()>MaxNameLength){
                    Name = a.Name.substring(0,MaxNameLength-1);
                } else {
                    Name = a.Name;
                }
                System.debug('---a.NAZ_OnPlan_BOPOC__c--- '+a.NAZ_OnPlan_BOPOC__c +'@@@@---'+a.OnPlan_Sales_Territory__r.lboc_Territory_ID__c+'@@@'+a.lboc_Labatt_Outlet_Id__c);
                if(a.NAZ_OnPlan_BOPOC__c != true){
                 
                Annual_Area_Budget__c AnnualAreaBudget = mapOfNewAnnualAreaBudgetsByTerrId.get(a.lboc_Sales_Territory__c);
                //If Account Type (Channel) is and Budget Type Match 
                if(a.lboc_Channel__c == null || 
                (a.lboc_Channel__c == 'ON' && AnnualAreaBudget.RecordTypeId == OOHRTid) ||
                (a.lboc_Channel__c == 'OFF' && AnnualAreaBudget.RecordTypeId == IHRTid) ||
                (a.lboc_Channel__c == 'OFF' && AnnualAreaBudget.RecordTypeId == NIHRTid)){  //added by Rag: IN Home
                    system.debug('test 1');
                    Annual_POC_Budget_Plan__c newPOCBudget = new Annual_POC_Budget_Plan__c();
                    newPOCBudget.Name = Name + ': ' + AnnualAreaBudget.Budget_Year__c;
                    newPOCBudget.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
                    newPOCBudget.recordTypeId = mapOfBudgetsAndThePOCRTForThem.get(AnnualAreaBudget.Id);
                    newPOCBudget.Account__c = a.Id;
                    newPOCBudget.Club_Bud_Tier__c = a.Club_Bud_Tier__c;
                    if (a.Club_Bud_Tier__c == null) {
                        newPOCBudget.Club_Bud_Tier__c = 'Tier Non-Bud';
                    }

                    for (In_Home_Budgets__c budget : globalBudgets) {
                        if (yearByAAB.get(AnnualAreaBudget.Id) == budget.Year__c && regionIDByAAB.get(AnnualAreaBudget.Id) == budget.Region_ID__c && newPOCBudget.Club_Bud_Tier__c == budget.Tier__c) {
                            newPOCBudget.POC_Budget__c = budget.Budget__c;
                        }
                    }

                    if(newPOCBudget.Club_Bud_Tier__c != NON_BUD && newPOCBudget.Club_Bud_Tier__c != null) {
                        newPOCBudget.Planned_Club_Bud_Member__c = true;
                    }
                    AnnualPOCBudgetList.add(newPOCBudget);
                    system.debug('newPOCBudget::::'+newPOCBudget);  
                }      
            	}
                else if(a.NAZ_OnPlan_BOPOC__c == true &&  a.OnPlan_Sales_Territory__r.lboc_Territory_ID__c == a.lboc_Labatt_Outlet_Id__c)
                {
                       Annual_Area_Budget__c AnnualAreaBudget = mapOfNewAnnualAreaBudgetsByTerrId.get(a.lboc_Sales_Territory__c);
                    //If Account Type (Channel) is and Budget Type Match 
                    if(a.lboc_Channel__c == null || 
                       ( AnnualAreaBudget.RecordTypeId == OOHRTid) ||
                       ( AnnualAreaBudget.RecordTypeId == IHRTid) ||
                       ( AnnualAreaBudget.RecordTypeId == NIHRTid)){  //added by Rag: IN Home
                           system.debug('test 1');
                           Annual_POC_Budget_Plan__c newPOCBudget = new Annual_POC_Budget_Plan__c();
                           newPOCBudget.Name = Name + ': ' + AnnualAreaBudget.Budget_Year__c;
                           newPOCBudget.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
                           newPOCBudget.recordTypeId = mapOfBudgetsAndThePOCRTForThem.get(AnnualAreaBudget.Id);
                           newPOCBudget.Account__c = a.Id;
                           newPOCBudget.Club_Bud_Tier__c = a.Club_Bud_Tier__c;
                           if (a.Club_Bud_Tier__c == null) {
                               newPOCBudget.Club_Bud_Tier__c = 'Tier Non-Bud';
                           }
                           
                           for (In_Home_Budgets__c budget : globalBudgets) {
                               if (yearByAAB.get(AnnualAreaBudget.Id) == budget.Year__c && regionIDByAAB.get(AnnualAreaBudget.Id) == budget.Region_ID__c && newPOCBudget.Club_Bud_Tier__c == budget.Tier__c) {
                                   newPOCBudget.POC_Budget__c = budget.Budget__c;
                               }
                           }
                           
                           if(newPOCBudget.Club_Bud_Tier__c != NON_BUD && newPOCBudget.Club_Bud_Tier__c != null) {
                               newPOCBudget.Planned_Club_Bud_Member__c = true;
                           }
                           AnnualPOCBudgetList.add(newPOCBudget);
                           system.debug('newPOCBudget::::'+newPOCBudget);  
                       }
                    
                }
            }
        }
        
        return AnnualPOCBudgetList;
    }

   /**
   * This method is used when the tier is updated on the Anuual POC Budget Plan object record.  
   * If Club_Bud_Tier__c was upgraded (e.g. Tier 2 to Tier 1) route to upgradeOrDowngradeTiers... 
   * If Club_Bud_Tier__c was downgraded (e.g. Tier 1 to Tier 2) route to downgradePOCSpendCatego...
   * @param old Annual_POC_Budget_Plan__c records before update
   * @param new Annual_POC_Budget_Plan__c records after update
   * @return void
   */
    public static void handleTiersForUpdatedPOCAnnualBudgetPlans(Map<Id, Annual_POC_Budget_Plan__c> oldAnnualPOCBudgetPlanList,
                                                                                    Map<Id, Annual_POC_Budget_Plan__c> newAnnualPOCBudgetPlanMapFromTrigger){
            
        Map<Id, Annual_POC_Budget_Plan__c> nonBudDowngradePOCBPLans  = new Map<Id, Annual_POC_Budget_Plan__c>();
        Map<Id, Annual_POC_Budget_Plan__c> clubBudDowngradePOCBPLans  = new Map<Id, Annual_POC_Budget_Plan__c>();
        Map<Id, Annual_POC_Budget_Plan__c> clubBudUpgradePOCBPlans = new Map<Id, Annual_POC_Budget_Plan__c>();
            
        //CHECK IF THE TIER HAS CHANGED BEFORE RUNNING EXTRANEOUS QUERIES
        Map<Id, Annual_POC_Budget_Plan__c> newAnnualPOCBudgetPlanMap = new Map<Id, Annual_POC_Budget_Plan__c>();
        for(Annual_POC_Budget_Plan__c pocBPlan: newAnnualPOCBudgetPlanMapFromTrigger.values()){
            if(pocBPlan.Club_Bud_Tier__c != oldAnnualPOCBudgetPlanList.get(pocBPlan.Id).Club_Bud_Tier__c){
                newAnnualPOCBudgetPlanMap.put(pocBPlan.id, pocBPlan);
            }
        }
        if(!newAnnualPOCBudgetPlanMap.isEmpty() && newAnnualPOCBudgetPlanMap != null){

            Map<Id, Annual_POC_Budget_Plan__c> annualBudgetRecTypes = new Map<Id, Annual_POC_Budget_Plan__c>
                    ([SELECT Annual_Territory_Budget__r.RecordType.Name FROM Annual_POC_Budget_Plan__c WHERE Id in: newAnnualPOCBudgetPlanMap.keyset()]); 

            for(Annual_POC_Budget_Plan__c pocBPlan: newAnnualPOCBudgetPlanMap.values()){
                // Adding null checks since tests were failing
                if( annualBudgetRecTypes.containsKey(pocBPlan.Id) 
                    && annualBudgetRecTypes.get(pocBPlan.Id).Annual_Territory_Budget__c != null 
                    && annualBudgetRecTypes.get(pocBPlan.Id).Annual_Territory_Budget__r.RecordType != null 
                    && annualBudgetRecTypes.get(pocBPlan.Id).Annual_Territory_Budget__r.RecordType.Name.equalsIgnoreCase(IH_TERRITORY)) {
                //if(annualBudgetRecTypes.get(pocBPlan.Id).Annual_Territory_Budget__r.RecordType.Name.equalsIgnoreCase(IH_TERRITORY)){
                    if(pocBPlan.Club_Bud_Tier__c != oldAnnualPOCBudgetPlanList.get(pocBPlan.Id).Club_Bud_Tier__c){
                        if((pocBPlan.Club_Bud_Tier__c.equalsIgnoreCase(NON_BUD))){
                            nonBudDowngradePOCBPLans.put(pocBPlan.Id, pocBPlan);
                        } else if(oldAnnualPOCBudgetPlanList.get(pocBPlan.Id).Club_Bud_Tier__c.equalsIgnoreCase(NON_BUD) || 
                                    Integer.valueOf(pocBPlan.Club_Bud_Tier__c.trim().right(1)) < 
                                        Integer.valueOf(oldAnnualPOCBudgetPlanList.get(pocBPlan.Id).Club_Bud_Tier__c.trim().right(1))) {
                            clubBudUpgradePOCBPlans.put(pocBPlan.Id, pocBPlan);
                        } else if(Integer.valueOf(pocBPlan.Club_Bud_Tier__c.trim().right(1)) > 
                                        Integer.valueOf(oldAnnualPOCBudgetPlanList.get(pocBPlan.Id).Club_Bud_Tier__c.trim().right(1))) {
                            clubBudDowngradePOCBPLans.put(pocBPlan.Id, pocBPlan);
                            
                        }
                    }
                }
            }
        }
        if(!nonBudDowngradePOCBPLans.isEmpty()){
            downgradePOCSpendCategoriesByTier(nonBudDowngradePOCBPLans, true);
        }

        if(!clubBudDowngradePOCBPLans.isEmpty()){
            downgradePOCSpendCategoriesByTier(clubBudDowngradePOCBPLans, false);
        }

        if(!clubBudUpgradePOCBPlans.isEmpty()){
            upgradeOrDowngradeTiersPOCAnnualBudgetPlans(clubBudUpgradePOCBPlans, false);
        }
    }

    /**
   * This method is used for preprocessing inserted Annual POC Budget Plans records in preparation for tier handling.  
   * Since triggers do not include parent object data, we need to query for the Annual Territory Budget parent. 
   * We then route the updated Annual POC Budget Plan records to their respective handlers
   * @param new Annual_POC_Budget_Plan__c records after insert
   * @return void
   */
    public static void handleTiersForInsertedPOCAnnualBudgetPlan(List<Annual_POC_Budget_Plan__c> newAnnualPOCBudgetPlan){

        Map<Id, Annual_POC_Budget_Plan__c> clubBudPlans = new Map<Id, Annual_POC_Budget_Plan__c>();
        Set<Id> areaBudgetIds = new Set<Id>();
        for (Annual_POC_Budget_Plan__c apoc : newAnnualPOCBudgetPlan) {
            areaBudgetIds.add(apoc.Annual_Territory_Budget__c);
        }
        Map<Id, Annual_Area_Budget__c> annualAreaBudgets = new Map<Id, Annual_Area_Budget__c>([SELECT Id, RecordType.DeveloperName FROM Annual_Area_Budget__c WHERE Id in : areaBudgetIds]);

        for(Annual_POC_Budget_Plan__c pocBPlan: newAnnualPOCBudgetPlan){

            if(annualAreaBudgets.get(pocBPlan.Annual_Territory_Budget__c).RecordType.DeveloperName == 'IH_Territory') {
                if(pocBPlan.Annual_Territory_Budget__c == null){
                    pocBPlan.Annual_Territory_Budget__c = annualAreaBudgets.get(pocBPlan.Annual_Territory_Budget__c).Id;

                }
                clubBudPlans.put(pocBPlan.Id,pocBPlan);
            }
        }
        if(!clubBudPlans.isEmpty()){
            upgradeOrDowngradeTiersPOCAnnualBudgetPlans(clubBudPlans, true);
        }
    }

    /**
   * This method is used for auto populating tier budget data into fields on Annual_POC_Budget_Plan__c.  
   * Fields: POC_Budget__c;In_Store_Driver_Minimum__c;Programming_Maximum__c;Traffic_Driver_Minimum__c;Variable_Maximum__c
   * @param new Annual_POC_Budget_Plan__c records after insert or after update
   * @param Boolean determining whether the records are being inserted or updated
   * @return void
   */
    public static void upgradeOrDowngradeTiersPOCAnnualBudgetPlans(Map<Id, Annual_POC_Budget_Plan__c> changedTierPOCBPLans, Boolean newRec){
        
        if(!newRec){
            changedTierPOCBPLans = new Map<Id, Annual_POC_Budget_Plan__c>([SELECT Id,  
                                     Annual_Territory_Budget__c, Club_Bud_Tier__c
                                            FROM Annual_POC_Budget_Plan__c WHERE  
                                                Id IN : changedTierPOCBPLans.keySet()]);
        }

        Set<Id> terrBudgetIds = Pluck.ids( 'Annual_Territory_Budget__c', changedTierPOCBPLans );

        Map<Id, Annual_Area_Budget__c> budgets = new Map<Id, Annual_Area_Budget__c>(
            [SELECT Id, Sales_Territory__c, Budget_Year__c FROM Annual_Area_Budget__c WHERE Id IN: terrBudgetIds]);

        Set<id> territoryIds = Pluck.ids( 'Sales_Territory__c', budgets );

        Map<Id, lboc_Sales_Territory__c> territories = new Map<Id, lboc_Sales_Territory__c>(
            [SELECT lboc_Region_ID__c, lboc_District_ID__c FROM lboc_Sales_Territory__c WHERE Id IN: territoryIds]);

        Set<String> years = new Set<String>();
        Set<String> tiers = new Set<String>();
        Set<String> districtIds = new Set<String>();
        Set<String> regiondIds = new Set<String>();
        

        for(Annual_POC_Budget_Plan__c poc: changedTierPOCBPLans.values()){
            years.add(budgets.get(poc.Annual_Territory_Budget__c).Budget_Year__c);
            tiers.add(poc.Club_Bud_Tier__c);
            districtIds.add(territories.get(budgets.get(poc.Annual_Territory_Budget__c).Sales_Territory__c).lboc_District_ID__c);
            regiondIds.add(territories.get(budgets.get(poc.Annual_Territory_Budget__c).Sales_Territory__c).lboc_Region_ID__c);
        }


        List<In_Home_Budgets__c> globalBudgets = [SELECT Id, Budget__c, In_Store_Driver_Minimum__c, Programming_Maximum__c, 
                                                Tier__c, Traffic_Driver_Minimum__c, Region_ID__c, Year__c FROM In_Home_Budgets__c 
                                                        WHERE Year__c IN :years AND Region_ID__c = :regiondIds AND Tier__c = :tiers];

        List<In_Home_District_Budget__c> variableBudgets = [SELECT Variable_Budget__c, Tier__c, District_ID__c, Year__c FROM 
                                                    In_Home_District_Budget__c WHERE District_ID__c =:districtIds AND Year__c =:years AND Tier__c =: tiers ];                                      

        /* Iterate through custom settings records to find the pocs
           selected tier and auto populate the custom settings data 
           into the Max, Min, Variable and Budget fields. */

        for(Annual_POC_Budget_Plan__c poc: changedTierPOCBPLans.values()){
            for(In_Home_Budgets__c ihBudget : globalBudgets){
                if(budgets.get(poc.Annual_Territory_Budget__c).Budget_Year__c.equalsIgnoreCase(ihBudget.Year__c) &&
                    poc.Club_Bud_Tier__c.equalsIgnoreCase(ihBudget.Tier__c) &&
                    territories.get(budgets.get(poc.Annual_Territory_Budget__c).Sales_Territory__c).lboc_Region_ID__c.equalsIgnoreCase(ihBudget.Region_ID__c)){
                    poc.POC_Budget__c = ihBudget.Budget__c;
                    poc.In_Store_Driver_Minimum__c = ihBudget.In_Store_Driver_Minimum__c;
                    poc.Programming_Maximum__c = ihBudget.Programming_Maximum__c;
                    poc.Traffic_Driver_Minimum__c = ihBudget.Traffic_Driver_Minimum__c;
                }
            }
            for(In_Home_District_Budget__c variableBudget : variableBudgets){
                if(budgets.get(poc.Annual_Territory_Budget__c).Budget_Year__c.equalsIgnoreCase(variableBudget.Year__c) &&
                    poc.Club_Bud_Tier__c.equalsIgnoreCase(variableBudget.Tier__c) &&
                    territories.get(budgets.get(poc.Annual_Territory_Budget__c).Sales_Territory__c).lboc_Region_ID__c.equalsIgnoreCase(variableBudget.District_ID__c)){
                    poc.Variable_Maximum__c = variableBudget.Variable_Budget__c;
                }
            }
        }

        if(!newRec){
            update changedTierPOCBPLans.values();
        }
    }

    /**
   * This method is used for zeroing out related POC Spend Category data if the Tier was downgraded (except for Cooler).  
   * Child objects will be deleted as well (e.g. Marketing_Kit__c and Driver_Item__c).
   * @param new Annual_POC_Budget_Plan__c records on insert or update
   * @param Boolean that indicates if selected value is Non-Bud
   * @return void
   */
    public static void downgradePOCSpendCategoriesByTier(Map<Id, Annual_POC_Budget_Plan__c> changedTierPOCBPLans, Boolean nonClubBud){
        List<POC_Spend_Category__c> pocSpendCategoriesList = new List<POC_Spend_Category__c>();

        Map<Id, List<POC_Spend_Category__c>> pocSpendCategoriesMap = new Map<Id, List<POC_Spend_Category__c>>();
        //RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Cooler_In_Home'];
        ID coolerRecordTypeId = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Cooler').getRecordTypeId();

        Set<ID> pocSpendIDs = new Set<ID>();
       
        if (!changedTierPOCBPLans.isEmpty()) {
             pocSpendCategoriesMap = 
                GroupBy.Ids( 'Annual_POC_Budget_Plan__c', [
                SELECT Id, Pre_Planning_Spend__c, Annual_POC_Budget_Plan__c, Trade_Activation_Discretionary_Spend__c, Trade_Activation_Spend__c 
                FROM POC_Spend_Category__c WHERE RecordTypeId != : coolerRecordTypeId AND Annual_POC_Budget_Plan__c IN : changedTierPOCBPLans.keySet()
            ]);


            /* Iterate through all poc spend category 
               records and zero out the spend amounts. */

            for(List<POC_Spend_Category__c> pocSpendCatList: pocSpendCategoriesMap.values()){
                for(POC_Spend_Category__c pocSpendCat: pocSpendCatList){
                    pocSpendIDs.add(pocSpendCat.Id);
                    pocSpendCat.Trade_Activation_Discretionary_Spend__c = 0;
                    pocSpendCat.Trade_Activation_Driver_Spend__c = 0;
                    pocSpendCat.Programming_Spend__c = 0;
                    pocSpendCat.Pre_Planning_Spend__c = 0;
                    pocSpendCat.Variable_Spend__c = 0;
                    pocSpendCategoriesList.add(pocSpendCat);
                }
            }
        }
        
        /* Delete all annual poc spend category 
           related records except for Coolers. */

        if(!pocSpendCategoriesList.isEmpty()){

            update pocSpendCategoriesList;

            List<Marketing_Kit__c> shoppedKits;
            shoppedKits = [SELECT Id FROM Marketing_Kit__c WHERE POC_Spend_Category__r.Annual_POC_Budget_Plan__c IN : pocSpendCategoriesMap.keySet() ];

            if(!shoppedKits.isEmpty()){
                delete shoppedKits;
            }

            List<Driver_Item__c> driverItems = new List<Driver_Item__c>();
            driverItems = [SELECT Id FROM Driver_Item__c WHERE POC_Spend_Category__c IN :pocSpendIDs ];

            if(!driverItems.isEmpty()){
                delete driverItems;
            }
        }

        if(!nonClubBud){
            upgradeOrDowngradeTiersPOCAnnualBudgetPlans(changedTierPOCBPLans, false);
        }
    }
}