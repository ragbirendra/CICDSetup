/*
    US-W-013969
    Created Method:createBudgetForBO
    Updated by: AMol P
*/
public class AnnualAreaBudgets {

    public static Annual_POC_Budget_Plan__c[] uncheckIsUpdate(Map<Id, Annual_Area_Budget__c> mapOfOldAnnualAreaBudgets, Map<Id, Annual_Area_Budget__c> mapOfNewAnnualAreaBudgets) {
        
        List<ID> listOfAnnualAreaBudgetIds = new List<ID>();
        for (Id annualAreaBudgetID : mapOfNewAnnualAreaBudgets.keySet()) {
            if (mapOfNewAnnualAreaBudgets.get(annualAreaBudgetID).Approval_Status__c != mapOfOldAnnualAreaBudgets.get(annualAreaBudgetID).Approval_Status__c 
                && mapOfNewAnnualAreaBudgets.get(annualAreaBudgetID).Approval_Status__c == 'Approved' ) {
                    listOfAnnualAreaBudgetIds.add(annualAreaBudgetID);
            }
        }

        List<Annual_POC_Budget_Plan__c> listOfAnnualPOCBudgetPlans = new List<Annual_POC_Budget_Plan__c>();
        if (!listOfAnnualAreaBudgetIds.isEmpty()) {
            listOfAnnualPOCBudgetPlans = [SELECT Id, isUpdated__c FROM Annual_POC_Budget_Plan__c WHERE Annual_Territory_Budget__c IN :listOfAnnualAreaBudgetIds];
        }
        for (Annual_POC_Budget_Plan__c annualPocBudgetPlan : listOfAnnualPOCBudgetPlans) {
            annualPocBudgetPlan.isUpdated__c = false;
        }
        return listOfAnnualPOCBudgetPlans;
    }

    public static Annual_Area_Budget__c[] rollupToAnnualAreaBudgetWithAnnualBrandAreaBudgetPlans(Map<Id, Annual_Brand_Area_Budget_Plan__c> mapOfOldAnnualBrandAreaBudgetPlans, Map<Id, Annual_Brand_Area_Budget_Plan__c> mapOfNewAnnualBrandAreaBudgetPlans) {
        Map<Id, Decimal> mapOfAnnualAreaBudgetIds = new Map<Id,Decimal>();
        for (Id annualBrandAreaBudgetPlanID : mapOfNewAnnualBrandAreaBudgetPlans.keySet()) {
            
            //If not new/insert
            if (mapOfOldAnnualBrandAreaBudgetPlans.containsKey(annualBrandAreaBudgetPlanID) &&
                 mapOfOldAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Annual_Area_Budget__c != null) {

                //If Budget Changed
                if(mapOfOldAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Brand_Budget__c != mapOfNewAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Brand_Budget__c){
                    if(mapOfAnnualAreaBudgetIds.containsKey(mapOfOldAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Annual_Area_Budget__c)){
                        mapOfAnnualAreaBudgetIds.put(mapOfOldAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Annual_Area_Budget__c, 
                            mapOfAnnualAreaBudgetIds.get(mapOfOldAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Annual_Area_Budget__c) - 
                            mapOfOldAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Brand_Budget__c);
                    } else {
                        Decimal tradeActivationBudgetDiff = 0;
                        tradeActivationBudgetDiff = tradeActivationBudgetDiff - mapOfOldAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Brand_Budget__c;
                        mapOfAnnualAreaBudgetIds.put(mapOfOldAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Annual_Area_Budget__c, tradeActivationBudgetDiff);
                    }
                }                    
            }
            
            if (mapOfNewAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Annual_Area_Budget__c != null) {
                
                //If Old Record and Budget Changed
                if(mapOfOldAnnualBrandAreaBudgetPlans.containsKey(annualBrandAreaBudgetPlanID) &&
                    mapOfOldAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Brand_Budget__c != mapOfNewAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Brand_Budget__c){
                    if(mapOfAnnualAreaBudgetIds.containsKey(mapOfNewAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Annual_Area_Budget__c)){
                        mapOfAnnualAreaBudgetIds.put(mapOfNewAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Annual_Area_Budget__c, 
                            mapOfAnnualAreaBudgetIds.get(mapOfNewAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Annual_Area_Budget__c) + 
                            mapOfNewAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Brand_Budget__c);
                    } else {
                        Decimal tradeActivationBudgetDiff = 0;
                        tradeActivationBudgetDiff = tradeActivationBudgetDiff + mapOfNewAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Brand_Budget__c;
                        mapOfAnnualAreaBudgetIds.put(mapOfNewAnnualBrandAreaBudgetPlans.get(annualBrandAreaBudgetPlanID).Annual_Area_Budget__c, tradeActivationBudgetDiff);
                    }
                }
            }
        }
        List<Annual_Area_Budget__c> retrieveParentAnnualAreaBudgets = new List<Annual_Area_Budget__c>();
        
        if (!mapOfAnnualAreaBudgetIds.keySet().isEmpty()) {
            retrieveParentAnnualAreaBudgets = [SELECT Id, Discretionary_Budget__c ,Trade_Activation_Budget__c,External_key_Dist__c FROM Annual_Area_Budget__c WHERE Id IN :mapOfAnnualAreaBudgetIds.keySet()];
           
        }     
        for (Annual_Area_Budget__c annualAreaBudget : retrieveParentAnnualAreaBudgets) {
            annualAreaBudget.Trade_Activation_Budget__c = annualAreaBudget.Trade_Activation_Budget__c + mapOfAnnualAreaBudgetIds.get(annualAreaBudget.Id);
        }
        return retrieveParentAnnualAreaBudgets;
    }

    public static Annual_Area_Budget__c[] rollupBudgetValuestoAllocated(Map<Id, Annual_Area_Budget__c> mapOfOldAnnualAreaBudgets, Map<Id, Annual_Area_Budget__c> mapOfNewAnnualAreaBudgets) {
  
        Map<ID, Annual_Area_Budget__c> mapOfBudgets = (mapOfNewAnnualAreaBudgets != null) ? mapOfNewAnnualAreaBudgets : mapOfOldAnnualAreaBudgets;
        Set<ID> parentBudgetIds = new Set<ID>();

        for (ID budgetId : mapOfBudgets.keySet()) {
            Annual_Area_Budget__c childBudget = mapOfBudgets.get(budgetId);
            if (childBudget.Parent_Budget__c != null) { 
                parentBudgetIds.add(childBudget.Parent_Budget__c); 
            }
        }

        Map<ID, Annual_Area_Budget__c> budgetsByID = new Map<ID, Annual_Area_Budget__c>([ 
            SELECT Id, Parent_Budget__c, Allocated_Driver_Budget__c,Total_District_Budget__c, Allocated_Discretionary_Budget__c, Allocated_Trade_Activation_Budget__c, Drivers_Budget__c, Discretionary_Budget__c, Trade_Activation_Budget__c
            FROM Annual_Area_Budget__c
            WHERE Id IN :parentBudgetIds OR Parent_Budget__c IN :parentBudgetIds
        ]);
        
        Map<ID, Annual_Area_Budget__c[]> childBudgetsByParentId = new Map<ID, Annual_Area_Budget__c[]>();
        for (ID childBudgetId : budgetsByID.keySet()) {
            Annual_Area_Budget__c childBudget = budgetsByID.get(childBudgetId);
            ID parentBudgetId = childBudget.Parent_Budget__c;
            if (parentBudgetId != null && parentBudgetIds.contains(budgetsByID.get(childBudgetId).Parent_Budget__c)) {
                Annual_Area_Budget__c[] childrenBudgets = childBudgetsByParentId.get(parentBudgetId);
                if (childrenBudgets == null) { 
                    childBudgetsByParentId.put(parentBudgetId, new Annual_Area_Budget__c[0]); 
                }
                (childBudgetsByParentId.get(parentBudgetId)).add(childBudget);
            }
        }

        Annual_Area_Budget__c[] answer = new Annual_Area_Budget__c[0];
        for (ID parentBudgetId : childBudgetsByParentId.keySet()) {
            Decimal allocatedDriverBudget = 0, allocatedDiscretionaryBudget = 0, allocatedTradeActivationBudget = 0;
            Annual_Area_Budget__c[] childrenBudgets = childBudgetsByParentId.get(parentBudgetId);
            if (childrenBudgets != null) {
                for (Annual_Area_Budget__c childBudget : childBudgetsByParentId.get(parentBudgetId)) {
                    if (childBudget.Drivers_Budget__c != null) { allocatedDriverBudget += childBudget.Drivers_Budget__c; }
                    if (childBudget.Discretionary_Budget__c != null) { allocatedDiscretionaryBudget += childBudget.Discretionary_Budget__c; }
                    if (childBudget.Trade_Activation_Budget__c != null) { allocatedTradeActivationBudget += childBudget.Trade_Activation_Budget__c; }
                }
            }
            Annual_Area_Budget__c parentBudget = budgetsByID.get(parentBudgetId);
            parentBudget.Allocated_Driver_Budget__c = allocatedDriverBudget;
            parentBudget.Allocated_Discretionary_Budget__c = allocatedDiscretionaryBudget;
            parentBudget.Allocated_Trade_Activation_Budget__c = allocatedTradeActivationBudget;
            //Added By Ragbirendra
            parentBudget.Total_District_Budget__c = parentBudget.Allocated_Discretionary_Budget__c + parentBudget.Allocated_Trade_Activation_Budget__c;
            answer.add(parentBudget);
        }

        return answer;
    }

    public static List<Annual_Area_Budget__c> updateApproverOnChild(Map<Id, Annual_Area_Budget__c> mapOfOldAnnualAreaBudgets, Map<Id, Annual_Area_Budget__c> mapOfNewAnnualAreaBudgets) {
        if (mapOfOldAnnualAreaBudgets == null) {
            mapOfOldAnnualAreaBudgets = new Map<Id, Annual_Area_Budget__c>();
        }
        List<Id> listOfUpdatedOwnerIDs = new List<Id>();
        for (Id annualAreaBudgetID : mapOfNewAnnualAreaBudgets.keySet()) {
            if (mapOfNewAnnualAreaBudgets.get(annualAreaBudgetID).OwnerId != mapOfOldAnnualAreaBudgets.get(annualAreaBudgetID).OwnerId) {
                listOfUpdatedOwnerIDs.add(annualAreaBudgetID);
            }
        }
        
        List<Annual_Area_Budget__c> childBudgetList = new List<Annual_Area_Budget__c>();
        if (!listOfUpdatedOwnerIDs.isEmpty()) {
            childBudgetList = [SELECT Id, Approver__c, Parent_Budget__c FROM Annual_Area_Budget__c WHERE Parent_Budget__c IN :listOfUpdatedOwnerIDs];
        }

        for (Annual_Area_Budget__c childBudget : childBudgetList) {
            childBudget.Approver__c = mapOfNewAnnualAreaBudgets.get(childBudget.Parent_Budget__c).OwnerId;
        }
        return childBudgetList;
    }

    public static List<Annual_Area_Budget__c> setApproverBeforeInsert(List<Annual_Area_Budget__c> listOfNewAnnualAreaBudgets, Boolean isUpdate) {
        Set<ID> listofIDs = new Set<ID>();

        for (Annual_Area_Budget__c aab : listOfNewAnnualAreaBudgets) {
            listofIDs.add(aab.Parent_Budget__c);
        }

        Map<Id, String> mapOfOwnerID = new Map<Id, String>();

        if (!listofIDs.isEmpty()) {

            List<Annual_Area_Budget__c> parentBudgetByID = [ 
                SELECT Id, OwnerID
                FROM Annual_Area_Budget__c 
                WHERE Id IN :listofIDs
            ];

            for (Annual_Area_Budget__c parentAAB : parentBudgetByID) {
                mapOfOwnerID.put(parentAAB.Id, parentAAB.OwnerID);
            }

            for (Annual_Area_Budget__c aab : listOfNewAnnualAreaBudgets) {
                if (aab.Parent_Budget__c != null && (isUpdate && !Approval.isLocked(aab.id) || !isUpdate)) {
                    aab.Approver__c = mapOfOwnerID.get(aab.Parent_Budget__c);
                }
            }
        }
        
        return listOfNewAnnualAreaBudgets;
    }

    public static List<Annual_Area_Budget__c> updateAnnualAreaBudgetOwner(Map<Id, lboc_Sales_Territory__c> mapOfOldSalesTerritories, Map<Id, lboc_Sales_Territory__c> mapOfNewSalesTerritories){
        
        List<Annual_Area_Budget__c> aabList = new List<Annual_Area_Budget__c>();
        String Year = String.valueOf(Date.today().Year());
        Set<Id> STIdSet = new Set<Id>();
        for(Id STId: mapOfNewSalesTerritories.keySet()){
            system.debug('test 0');
            if(mapOfOldSalesTerritories.get(STId).OwnerID != mapOfNewSalesTerritories.get(STId).OwnerID){
                system.debug('test 1');
                STIdSet.add(STId);
            }
        }
        if(!STIdSet.isEmpty()){
            // *** Substituted by SC on 2108.08.29 to include IH territories and any budget year in the resulting Annual_Area_Budget__c records
            // *** RecordType aabRT = [SELECT Id, DeveloperName FROM RecordType 
            // *** WHERE SObjectType = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory' Limit 1];
            
            //*** Removed to free up queries
            //RecordType[] aabRT = [SELECT Id FROM RecordType 
            //WHERE SObjectType = 'Annual_Area_Budget__c' AND DeveloperName IN ('IH_Territory', 'Territory')];
            //System.debug('*** aabRT: ' + aabRT);
            
            Id IHTerritoryRecTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('IH Territory').getRecordTypeId();
            Id OOHTerritoryRecTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
            Id NIHTerritoryRecTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH Territory').getRecordTypeId();
             //added by ragbirendra for New IH changes
            
            aabList = [SELECT Id, Name, Sales_Territory__c, OwnerID, Budget_Year__c
            From Annual_Area_Budget__c
            // *** Where Sales_Territory__c In: STIdSet And Budget_Year__c >=: Year and RecordTypeId =: aabRt.Id];
            //*** Removed to free up queries
            //Where Sales_Territory__c In: STIdSet And RecordTypeId IN: aabRt];
            Where Sales_Territory__c In: STIdSet And (RecordTypeId =: IHTerritoryRecTypeId OR RecordTypeId =: OOHTerritoryRecTypeId OR RecordTypeId =:NIHTerritoryRecTypeId)];
            System.debug('*** aabList: ' + aabList);
            for(Annual_Area_Budget__c aab: aabList){
                aab.OwnerId = mapOfNewSalesTerritories.get(aab.Sales_Territory__c).OwnerId;
            }
            System.debug('*** aabList: ' + aabList);
        }
        return aabList;
    }

    public static void beforeInsertOrUpdate(List<Annual_Area_Budget__c> newProductInventoryItems){
        Id IHDistrictRecTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('IH District').getRecordTypeId();
        Id NIHDistrictRecTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH District').getRecordTypeId();
        Id OOHDistrictRecTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH District').getRecordTypeId();
        Id IHTerritoryRecTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('IH Territory').getRecordTypeId();
        Id NIHTerritoryRecTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH Territory').getRecordTypeId();
        Id OOHTerritoryRecTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
     
        List<OnPoint_District__c> districtList = new List<OnPoint_District__c>();
        List<lboc_Sales_Territory__c> territoryList = new List<lboc_Sales_Territory__c>();
        Set<id> distIdSet = new Set<id>();
        Set<id> terrIdSet = new Set<id>();
        Map<id,id> distIdToOwnerId = new Map<id,id>();
        Map<id,id> terrIdToOwnerId = new Map<id,id>();
        for(Annual_Area_Budget__c budget: newProductInventoryItems){
            if(budget.RecordTypeId == IHDistrictRecTypeId || budget.RecordTypeId == OOHDistrictRecTypeId || budget.RecordTypeId == NIHDistrictRecTypeId ){
                distIdSet.add(budget.District__c);
            }else if(budget.RecordTypeId == IHTerritoryRecTypeId || budget.RecordTypeId == OOHTerritoryRecTypeId || budget.RecordTypeId == NIHTerritoryRecTypeId ){
                terrIdSet.add(budget.Sales_Territory__c);
            }
        }
        if(!distIdSet.isEmpty()){
            districtList = [select id, OwnerId from OnPoint_District__c where id IN: distIdSet];
            system.debug('@@ districtList: '+districtList);
            for(OnPoint_District__c dist:districtList){
                distIdToOwnerId.put(dist.id, dist.OwnerId);
            }
        }
        
        if(!terrIdSet.isEmpty()){
            territoryList = [select id, OwnerId from lboc_Sales_Territory__c where id IN: terrIdSet];
            for(lboc_Sales_Territory__c terr: territoryList ){
                terrIdToOwnerId.put(terr.id, terr.OwnerId);
            }
        }
        system.debug('@@ distIdToOwnerId 1: '+distIdToOwnerId);

        for(Annual_Area_Budget__c budget: newProductInventoryItems){
            if(budget.RecordTypeId == IHDistrictRecTypeId || budget.RecordTypeId == OOHDistrictRecTypeId || budget.RecordTypeId == NIHDistrictRecTypeId){
                system.debug('@@ distIdToOwnerId 2: '+distIdToOwnerId);
                if(distIdToOwnerId.get(budget.District__c) != null){
                    system.debug('@@ distIdToOwnerId 3: '+distIdToOwnerId.get(budget.District__c));
                    budget.OwnerId = distIdToOwnerId.get(budget.District__c);
                }
            }else if(budget.RecordTypeId == IHTerritoryRecTypeId || budget.RecordTypeId == OOHTerritoryRecTypeId || budget.RecordTypeId == NIHTerritoryRecTypeId){
                if(terrIdToOwnerId.get(budget.Sales_Territory__c) != null){
                    budget.OwnerId = terrIdToOwnerId.get(budget.Sales_Territory__c);
                }
            }
        }

    }
    public static void createBudgetForBO(List<lboc_Sales_Territory__c > newSTList)
    {
        System.debug('=== in create budget==');
        List<Annual_Area_Budget__c> listOfNewBudget=new List<Annual_Area_Budget__c>();
        Id OOHRT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        Id IHRT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH Territory').getRecordTypeId();
        Id DORT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH District').getRecordTypeId();
        Id DIRT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH District').getRecordTypeId();
        
        List<string> externalId= new List<string>();
        List<Annual_Area_Budget__c> externalBudgetKey=[SELECT External_key_Dist__c FROM Annual_Area_Budget__c WHERE Budget_Year__c=:String.valueOf(System.Today().year()+1)];
        foR(Annual_Area_Budget__c obAAB:externalBudgetKey){
            externalId.add(obAAB.External_key_Dist__c);
        }
        
        List<Annual_Area_Budget__c> parentBudget=new List<Annual_Area_Budget__c>();
         if(!test.isRunningTest()){
         parentBudget=[SELECT id,Name,RecordType.DeveloperName from Annual_Area_Budget__c WHERE District_Name__c='National' AND Budget_Year__c=:String.valueOf(System.Today().year()+1)];
        }
        else
        {
          parentBudget=[SELECT id,Name,RecordType.DeveloperName from Annual_Area_Budget__c WHERE District_Name__c='National' AND Budget_Year__c=:String.valueOf(System.Today().year())];   
        }
         Map<string, Annual_Area_Budget__c> mapOfParentBudget=new MAP<string, Annual_Area_Budget__c>();
        
         if( parentBudget.isEmpty() ){
            Annual_Area_Budget__c objAABParent=new Annual_Area_Budget__c ();
            objAABParent.Budget_Year__c=String.valueOf(System.Today().year()+1);
            objAABParent.District_Name__c='National';
            objAABParent.District_Code__c='National';
            objAABParent.External_key_Dist__c=objAABParent.District_Code__c+'_'+objAABParent.Budget_Year__c+'_'+Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosById().get(DORT).getName();
            objAABParent.RecordTypeId=DORT;
            //insert objAABParent;
            parentBudget.add(objAABParent);
            Annual_Area_Budget__c objAABParentIH=new Annual_Area_Budget__c ();
            objAABParentIH.Budget_Year__c=String.valueOf(System.Today().year()+1);
            objAABParentIH.District_Name__c='National';
            objAABParentIH.District_Code__c='National';
			objAABParentIH.External_key_Dist__c=objAABParentIH.District_Code__c+'_'+objAABParentIH.Budget_Year__c+'_'+Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosById().get(DIRT).getName();
            objAABParentIH.RecordTypeId=DIRT;
            //insert objAABParentIH;
            parentBudget.add(objAABParentIH);
            //insert parentBudget;
            Database.upsert(parentBudget, Annual_Area_Budget__c.External_key_Dist__c);
            
             for(Annual_Area_Budget__c aab:[SELECT id,Name,RecordType.DeveloperName from Annual_Area_Budget__c WHERE District_Name__c='National' AND Budget_Year__c=:String.valueOf(System.Today().year()+1)]){
            System.debug('-----aab.RecordType.DeveloperName---'+aab.RecordType.DeveloperName);
            mapOfParentBudget.put(aab.RecordType.DeveloperName, aab);
       		 }
        }
        else{
             for(Annual_Area_Budget__c aab:parentBudget){
            System.debug('-----aab.RecordType.DeveloperName---'+aab.RecordType.DeveloperName);
            mapOfParentBudget.put(aab.RecordType.DeveloperName, aab);
             }
        }
        
        System.debug('=== in create budget=='+parentBudget);
        for(lboc_Sales_Territory__c obTerritory: newSTList)
        {
          if(obTerritory.Back_Office_Territory__c)
          
          {
           System.debug('=== in about to createbudget==');   
              Annual_Area_Budget__c objAAB=new Annual_Area_Budget__c ();
              objAAB.Budget_Year__c=String.valueOf(System.Today().year()+1);
              objAAB.District_Code__c ='National';
              objAAB.Parent_Budget__c=mapOfParentBudget.get('District').id;
              objAAB.Sales_Territory__c=obTerritory.id;
              objAAB.OwnerId=obTerritory.OwnerId;
              objAAB.RecordTypeId=OOHRT;
              objAAB.Territory_Code__c=obTerritory.lboc_Territory_ID__c;
              objAAB.External_key_Dist__c=objAAB.District_Code__c+'_'+obTerritory.lboc_Territory_ID__c+'_'+String.valueOf(System.Today().year()+1)+'_OOH Territory';
              if(!externalId.contains(objAAB.External_key_Dist__c)){
                  listOfNewBudget.add(objAAB);
              }
              
              Annual_Area_Budget__c objAABIH=new Annual_Area_Budget__c ();
                objAABIH.Budget_Year__c=String.valueOf(System.Today().year()+1);
                objAABIH.District_Code__c ='National';
                objAABIH.Parent_Budget__c=mapOfParentBudget.get('New_IH_District').id;
                objAABIH.Sales_Territory__c=obTerritory.id;
                objAABIH.OwnerId=obTerritory.OwnerId;
                objAABIH.RecordTypeId=IHRT;
                objAABIH.Territory_Code__c=obTerritory.lboc_Territory_ID__c;
                objAABIH.External_key_Dist__c=objAABIH.District_Code__c+'_'+obTerritory.lboc_Territory_ID__c+'_'+String.valueOf(System.Today().year()+1)+'_New IH Territory';
                if(!externalId.contains(objAABIH.External_key_Dist__c)){
                    listOfNewBudget.add(objAABIH);
                }
          }
        }
        List<Database.upsertResult> results = Database.upsert(listOfNewBudget,Annual_Area_Budget__c.External_key_Dist__c);
    }
    /*
    Description:Update Shopkit when approval status changed from submitted for Approval to Approved
    Created Method:updateApprovalStatusOnShopkit
    Updated by: Cognizant Dev Team
    */
    public static List<Marketing_Kit__c> updateApprovalStatusOnShopkit(Map<Id, Annual_Area_Budget__c> mapOfOldAnnualAreaBudgets, Map<Id, Annual_Area_Budget__c> mapOfNewAnnualAreaBudgets)
    {
        List<Marketing_Kit__c> mkList = new List<Marketing_Kit__c>();
        List<ID> listOfAnnualAreaBudgetIds = new List<ID>();
        for (Id annualAreaBudgetID : mapOfNewAnnualAreaBudgets.keySet()) {
            if (mapOfNewAnnualAreaBudgets.get(annualAreaBudgetID).Approval_Status__c =='Approved' 
                && (mapOfOldAnnualAreaBudgets.get(annualAreaBudgetID).Approval_Status__c == 'Submitted for Approval' ||
                   mapOfOldAnnualAreaBudgets.get(annualAreaBudgetID).Approval_Status__c == 'Required')){
                    listOfAnnualAreaBudgetIds.add(annualAreaBudgetID);
                }
        } 
        if(!listOfAnnualAreaBudgetIds.isEmpty()){
            //Map<ID, Annual_Brand_Area_Budget_Plan__c> ababMap = new Map<ID, Annual_Brand_Area_Budget_Plan__c>([select Id from Annual_Brand_Area_Budget_Plan__c where Annual_Area_Budget__c IN : listOfAnnualAreaBudgetIds]);
            mkList =[select Id, Approval_Status__c 
                     From Marketing_Kit__c
                     where Annual_Brand_Area_Budget_Plan__r.Annual_Area_Budget__c IN:listOfAnnualAreaBudgetIds 
                     AND (recordType.DeveloperName ='Custom' or recordType.DeveloperName='Assigned_Preconfigured') 
                     AND Approval_Status__c != 'Approved' 
                     AND Marketing_Program_Name__r.Planning_Start_Date__c <=Today 
                     AND Marketing_Program_Name__r.Planning_End_Date__c >= Today];
            system.debug('mkList:::'+mkList);
        }
        if(!mkList.isEmpty()){
            for(Marketing_Kit__c mk:mkList){
                mk.Approval_Status__c ='Approved';   
            }
        }
        return mkList;
    }
    

}