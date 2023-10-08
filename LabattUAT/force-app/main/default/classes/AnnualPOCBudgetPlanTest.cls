@isTest
private class AnnualPOCBudgetPlanTest {
    
    @testSetup static void testSetup() {
        //POCMDataFactory.LoadTestBudgets();
        //POCMDataFactory.LoadTestItemsAndPrograms();

        Account testAccount = new Account();
        testAccount.Name = 'ABC';
        insert testAccount;

        In_Home_Budgets__c tier1 = new In_Home_Budgets__c(Name='11232016',Budget__c=40000.0, In_Store_Driver_Minimum__c=5000,Programming_Maximum__c=6000,Region_ID__c='123',Tier__c='1',Traffic_Driver_Minimum__c=8000,Year__c='2016');
        In_Home_Budgets__c tier2 = new In_Home_Budgets__c(Name='21232016',Budget__c=30000.0, In_Store_Driver_Minimum__c=4000,Programming_Maximum__c=6000,Region_ID__c='123',Tier__c='2',Traffic_Driver_Minimum__c=8000,Year__c='2016');
        In_Home_Budgets__c tier3 = new In_Home_Budgets__c(Name='31232016',Budget__c=20000.0, In_Store_Driver_Minimum__c=3000,Programming_Maximum__c=6000,Region_ID__c='123',Tier__c='3',Traffic_Driver_Minimum__c=8000,Year__c='2016');
        List<In_Home_Budgets__c> csList = new List<In_Home_Budgets__c>();
        csList.add(tier1);
        csList.add(tier2);
        csList.add(tier3);
        insert csList;

        In_Home_District_Budget__c  varTier1 = new In_Home_District_Budget__c(Name='Test 1',District_ID__c='123', Tier__c='1',Variable_Budget__c=800,Year__c='2016');
        In_Home_District_Budget__c  varTier2 = new In_Home_District_Budget__c(Name='Test 2',District_ID__c='123', Tier__c='2',Variable_Budget__c=800,Year__c='2016');
        In_Home_District_Budget__c  varTier3 = new In_Home_District_Budget__c(Name='Test 3',District_ID__c='123', Tier__c='3',Variable_Budget__c=800,Year__c='2016');
         List<In_Home_District_Budget__c> varCSList = new List<In_Home_District_Budget__c>();
        varCSList.add(varTier1);
        varCSList.add(varTier2);
        varCSList.add(varTier3);
        insert varCSList;


    }
    
    static testMethod void generateRecordForEachPOCInArea() {
        List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType 
        Where (SObjectType = 'Annual_Area_Budget__c' And DeveloperName = 'Territory') OR
        (SObjectType = 'Annual_Area_Budget__c' And DeveloperName = 'IH_Territory') OR
        (SObjectType =: 'Account' And DeveloperName =: 'Outlet')];

        RecordType OOHRT;
        RecordType IHRT;
        RecordType OutletRT;

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                OOHRT = rt;
            }
            else if(rt.DeveloperName == 'IH_Territory') {
                IHRT = rt;
            }
            else if(rt.DeveloperName == 'Outlet'){
                OutletRT = rt;
            }
        }
        String Year = String.valueOf(Date.Today().Year());
        Integer AcctNum = 5;

        lboc_Sales_Territory__c st1 = new lboc_Sales_Territory__c();
        st1.lboc_Region__c = 'Specialty1';
        st1.Name = 'Specialty1';
        lboc_Sales_Territory__c st2 = new lboc_Sales_Territory__c();
        st2.lboc_Region__c = 'Specialty2';
        st2.Name = 'Specialty2';
        List<lboc_Sales_Territory__c> STList = new List<lboc_Sales_Territory__c>{st1, st2};
        insert STList;

        List<Account> listofAccounts = new List<Account>();
        for (Integer i = 0; i < AcctNum; i++) {
            Account acc = new Account();
            acc.Name = 'Account1 ' + i + 1;
            acc.RecordTypeId = OutletRT.Id;
            acc.lboc_Sales_Territory__c = st1.Name;
            listofAccounts.add(acc);
        }
        for (Integer i = 0; i < AcctNum; i++) {
            Account acc = new Account();
            acc.Name = 'Account2 ' + i;
            acc.RecordTypeId = OutletRT.Id;
            acc.lboc_Sales_Territory__c = st2.Name;
            listofAccounts.add(acc);
        }
        insert listofAccounts;

        Test.startTest();
            Annual_Area_Budget__c newAnnualAreaOOHBudget = new Annual_Area_Budget__c();
            newAnnualAreaOOHBudget.Budget_Year__c = Year;
            newAnnualAreaOOHBudget.RecordTypeId = OOHRT.Id;
            newAnnualAreaOOHBudget.Sales_Territory__c = st1.Id;
            Annual_Area_Budget__c newAnnualAreaIHBudget = new Annual_Area_Budget__c();
            newAnnualAreaIHBudget.Budget_Year__c = Year;
            newAnnualAreaIHBudget.RecordTypeId = IHRT.Id;
            newAnnualAreaIHBudget.Sales_Territory__c = st2.Id;
            List<Annual_Area_Budget__c> AnnualAreaBudgetList = new List<Annual_Area_Budget__c>{newAnnualAreaOOHBudget, newAnnualAreaIHBudget};
            insert AnnualAreaBudgetList;       
        Test.stopTest();

        List<Annual_POC_Budget_Plan__c> listOFAnnualPOCBudgets = [SELECT Id FROM Annual_POC_Budget_Plan__c 
        WHERE Annual_Territory_Budget__c = :newAnnualAreaOOHBudget.Id OR Annual_Territory_Budget__c = :newAnnualAreaIHBudget.Id];
        System.assert(!listOFAnnualPOCBudgets.isEmpty());
        System.assertEquals(listofAccounts.size(), listOFAnnualPOCBudgets.size());        
    }   

    static testMethod void testHandleTiersForUpdatedPOCAnnualBudgetPlans(){

        List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType 
        Where (SObjectType = 'Annual_Area_Budget__c' And DeveloperName = 'Territory') OR
        (SObjectType = 'Annual_Area_Budget__c' And DeveloperName = 'IH_Territory') OR
        (SObjectType =: 'Account' And DeveloperName =: 'Outlet')];

        RecordType OOHRT;
        RecordType IHRT;
        RecordType OutletRT;

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                OOHRT = rt;
            }
            else if(rt.DeveloperName == 'IH_Territory') {
                IHRT = rt;
            }
            else if(rt.DeveloperName == 'Outlet'){
                OutletRT = rt;
            }
        }

        String Year = String.valueOf(Date.Today().Year());
        Integer AcctNum = 5;

        lboc_Sales_Territory__c st1 = new lboc_Sales_Territory__c();
        st1.lboc_Region_ID__c = '123';
        st1.lboc_Region__c = 'Specialty1';
        st1.Name = 'Specialty1';
        lboc_Sales_Territory__c st2 = new lboc_Sales_Territory__c();
        st2.lboc_Region__c = 'Specialty2';
        st2.Name = 'Specialty2';
        List<lboc_Sales_Territory__c> STList = new List<lboc_Sales_Territory__c>{st1, st2};
        insert STList;

        List<Account> listofAccounts = new List<Account>();
        for (Integer i = 0; i < AcctNum; i++) {
            Account acc = new Account();
            acc.Name = 'Account1 ' + i + 1;
            acc.RecordTypeId = OutletRT.Id;
            acc.lboc_Sales_Territory__c = st1.Name;
            listofAccounts.add(acc);
        }
        for (Integer i = 0; i < AcctNum; i++) {
            Account acc = new Account();
            acc.Name = 'Account2 ' + i;
            acc.RecordTypeId = OutletRT.Id;
            acc.lboc_Sales_Territory__c = st2.Name;
            listofAccounts.add(acc);
        }
        insert listofAccounts;

        Map<Id, Annual_POC_Budget_Plan__c> oldAnnualPOCBudgetPlanList = new Map<Id, Annual_POC_Budget_Plan__c>();
        Map<Id, Annual_POC_Budget_Plan__c> newAnnualPOCBudgetPlanMap  = new Map<Id, Annual_POC_Budget_Plan__c>();

        AnnualPOCBudgetPlan.triggerBypass = true;

        Annual_Area_Budget__c areaBudget = new Annual_Area_Budget__c();
        areaBudget.RecordTypeId = IHRT.Id;
        areaBudget.Budget_Year__c = '2016';
        areaBudget.Sales_Territory__c = st1.Id;
        insert areaBudget;

        Annual_POC_Budget_Plan__c pocBudgetPlan = new Annual_POC_Budget_Plan__c();
        pocBudgetPlan.Annual_Territory_Budget__c = areaBudget.Id;
        pocBudgetPlan.Club_Bud_Tier__c = 'Tier 1';
        pocBudgetPlan.Account__c = listofAccounts[0].Id;
        insert pocBudgetPlan;

        newAnnualPOCBudgetPlanMap.put(pocBudgetPlan.Id, pocBudgetPlan);

        pocBudgetPlan = [SELECT Annual_Territory_Budget__c, Club_Bud_Tier__c, 
                                Account__c FROM Annual_POC_Budget_Plan__c WHERE ID = : pocBudgetPlan.Id];
        pocBudgetPlan.Club_Bud_Tier__c = 'Tier 2';

        oldAnnualPOCBudgetPlanList.put(pocBudgetPlan.Id, pocBudgetPlan);

        Test.startTest();
        AnnualPOCBudgetPlan.handleTiersForUpdatedPOCAnnualBudgetPlans(oldAnnualPOCBudgetPlanList, 
                                                                                newAnnualPOCBudgetPlanMap);
        
        List<POC_Spend_Category__c> pocSpendCatList = [SELECT Id, Trade_Activation_Discretionary_Spend__c,
                                                                Trade_Activation_Driver_Spend__c, Pre_Planning_Spend__c,
                                                                    Variable_Spend__c FROM POC_Spend_Category__c 
                                                                        WHERE Annual_POC_Budget_Plan__c = : pocBudgetPlan.Id];
        
        System.assertEquals(6, pocSpendCatList.size());

        for(POC_Spend_Category__c pocSpend: pocSpendCatList){
            System.assertEquals(0, pocSpend.Trade_Activation_Discretionary_Spend__c);
            System.assertEquals(0, pocSpend.Trade_Activation_Driver_Spend__c);
            System.assertEquals(0, pocSpend.Pre_Planning_Spend__c);
            System.assertEquals(0, pocSpend.Variable_Spend__c);
            
        }

        pocBudgetPlan = [SELECT Id, Club_Bud_Tier__c FROM Annual_POC_Budget_Plan__c WHERE Id = : pocBudgetPlan.Id];
        pocBudgetPlan.Club_Bud_Tier__c = 'Tier 2';
        update pocBudgetPlan;

        newAnnualPOCBudgetPlanMap.clear();
        newAnnualPOCBudgetPlanMap.put(pocBudgetPlan.Id, pocBudgetPlan);

        pocBudgetPlan = [SELECT Annual_Territory_Budget__c, Club_Bud_Tier__c, 
                                Account__c FROM Annual_POC_Budget_Plan__c WHERE ID = : pocBudgetPlan.Id];
        pocBudgetPlan.Club_Bud_Tier__c = 'Tier 1';

        oldAnnualPOCBudgetPlanList.clear();
        oldAnnualPOCBudgetPlanList.put(pocBudgetPlan.Id, pocBudgetPlan);

     
        AnnualPOCBudgetPlan.handleTiersForUpdatedPOCAnnualBudgetPlans(oldAnnualPOCBudgetPlanList, 
                                                                                newAnnualPOCBudgetPlanMap);

        pocSpendCatList = [SELECT Id, Trade_Activation_Discretionary_Spend__c,
                                                                Trade_Activation_Driver_Spend__c, Pre_Planning_Spend__c,
                                                                    Variable_Spend__c FROM POC_Spend_Category__c 
                                                                        WHERE Annual_POC_Budget_Plan__c = : pocBudgetPlan.Id];

        System.assertEquals(6, pocSpendCatList.size());

        for(POC_Spend_Category__c pocSpend: pocSpendCatList){
            System.assertEquals(0, pocSpend.Trade_Activation_Discretionary_Spend__c);
            System.assertEquals(0, pocSpend.Trade_Activation_Driver_Spend__c);
            System.assertEquals(0, pocSpend.Pre_Planning_Spend__c);
            System.assertEquals(0, pocSpend.Variable_Spend__c);
            
        }

        pocBudgetPlan = [SELECT Id, Club_Bud_Tier__c FROM Annual_POC_Budget_Plan__c WHERE Id = : pocBudgetPlan.Id];
        pocBudgetPlan.Club_Bud_Tier__c = 'Tier Non-Bud';
        update pocBudgetPlan;

        newAnnualPOCBudgetPlanMap.clear();
        newAnnualPOCBudgetPlanMap.put(pocBudgetPlan.Id, pocBudgetPlan);

        pocBudgetPlan = [SELECT Annual_Territory_Budget__c, Club_Bud_Tier__c, 
                                Account__c FROM Annual_POC_Budget_Plan__c WHERE ID = : pocBudgetPlan.Id];
        pocBudgetPlan.Club_Bud_Tier__c = 'Tier 1';

        oldAnnualPOCBudgetPlanList.clear();
        oldAnnualPOCBudgetPlanList.put(pocBudgetPlan.Id, pocBudgetPlan);

     
        AnnualPOCBudgetPlan.handleTiersForUpdatedPOCAnnualBudgetPlans(oldAnnualPOCBudgetPlanList, 
                                                                                newAnnualPOCBudgetPlanMap);

        pocSpendCatList = [SELECT Id, Trade_Activation_Discretionary_Spend__c,
                                                                Trade_Activation_Driver_Spend__c, Pre_Planning_Spend__c,
                                                                    Variable_Spend__c FROM POC_Spend_Category__c 
                                                                        WHERE Annual_POC_Budget_Plan__c = : pocBudgetPlan.Id];

        System.assertEquals(6, pocSpendCatList.size());

        for(POC_Spend_Category__c pocSpend: pocSpendCatList){
            System.assertEquals(0, pocSpend.Trade_Activation_Discretionary_Spend__c);
            System.assertEquals(0, pocSpend.Trade_Activation_Driver_Spend__c);
            System.assertEquals(0, pocSpend.Pre_Planning_Spend__c);
            System.assertEquals(0, pocSpend.Variable_Spend__c);
            
        }
        Test.stopTest();

        AnnualPOCBudgetPlan.triggerBypass = false;

    }

    static testMethod void testHandleTiersForInsertedPOCAnnualBudgetPlan(){

         List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType 
        Where (SObjectType = 'Annual_Area_Budget__c' And DeveloperName = 'Territory') OR
        (SObjectType = 'Annual_Area_Budget__c' And DeveloperName = 'IH_Territory') OR
        (SObjectType =: 'Account' And DeveloperName =: 'Outlet')];

        RecordType OOHRT;
        RecordType IHRT;
        RecordType OutletRT;

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                OOHRT = rt;
            }
            else if(rt.DeveloperName == 'IH_Territory') {
                IHRT = rt;
            }
            else if(rt.DeveloperName == 'Outlet'){
                OutletRT = rt;
            }
        }

        String Year = String.valueOf(Date.Today().Year());
        Integer AcctNum = 5;

        lboc_Sales_Territory__c st1 = new lboc_Sales_Territory__c();
        st1.lboc_Region__c = 'Specialty1';
        st1.Name = 'Specialty1';
        lboc_Sales_Territory__c st2 = new lboc_Sales_Territory__c();
        st2.lboc_Region__c = 'Specialty2';
        st2.Name = 'Specialty2';
        List<lboc_Sales_Territory__c> STList = new List<lboc_Sales_Territory__c>{st1, st2};
        insert STList;

        List<Account> listofAccounts = new List<Account>();
        for (Integer i = 0; i < AcctNum; i++) {
            Account acc = new Account();
            acc.Name = 'Account1 ' + i + 1;
            acc.RecordTypeId = OutletRT.Id;
            acc.lboc_Sales_Territory__c = st1.Name;
            listofAccounts.add(acc);
        }
        for (Integer i = 0; i < AcctNum; i++) {
            Account acc = new Account();
            acc.Name = 'Account2 ' + i;
            acc.RecordTypeId = OutletRT.Id;
            acc.lboc_Sales_Territory__c = st2.Name;
            listofAccounts.add(acc);
        }
        insert listofAccounts;

        Map<Id, Annual_POC_Budget_Plan__c> oldAnnualPOCBudgetPlanList = new Map<Id, Annual_POC_Budget_Plan__c>();
        Map<Id, Annual_POC_Budget_Plan__c> newAnnualPOCBudgetPlanMap  = new Map<Id, Annual_POC_Budget_Plan__c>();

        AnnualPOCBudgetPlan.triggerBypass = true;

        Annual_Area_Budget__c areaBudget = new Annual_Area_Budget__c();
        areaBudget.RecordTypeId = IHRT.Id;
        areaBudget.Budget_Year__c = '2016';
        areaBudget.Sales_Territory__c = st1.Id;
        insert areaBudget;

        Annual_POC_Budget_Plan__c pocBudgetPlan = new Annual_POC_Budget_Plan__c();
        pocBudgetPlan.Annual_Territory_Budget__c = areaBudget.Id;
        pocBudgetPlan.Club_Bud_Tier__c = 'Tier 1';
        pocBudgetPlan.Account__c = listofAccounts[0].Id;
        insert pocBudgetPlan;

        pocBudgetPlan = [SELECT Id,Annual_Territory_Budget__r.Sales_Territory__c, Annual_Territory_Budget__c, Club_Bud_Tier__c, Account__c FROM 
                                                                            Annual_POC_Budget_Plan__c WHERE Id =: pocBudgetPlan.Id];
        List<Annual_POC_Budget_Plan__c> newAnnualPOCBudgetPlan = new List<Annual_POC_Budget_Plan__c>();
        newAnnualPOCBudgetPlan.add(pocBudgetPlan);

        Test.startTest();
            AnnualPOCBudgetPlan.handleTiersForInsertedPOCAnnualBudgetPlan(newAnnualPOCBudgetPlan);
        Test.stopTest();

        List<POC_Spend_Category__c> pocSpendCatList = [SELECT Id, Trade_Activation_Discretionary_Spend__c,
                                                                Trade_Activation_Driver_Spend__c, Pre_Planning_Spend__c,
                                                                    Variable_Spend__c FROM POC_Spend_Category__c 
                                                                        WHERE Annual_POC_Budget_Plan__c = : pocBudgetPlan.Id];
                                                                        
        System.assertEquals(6, pocSpendCatList.size());

        for(POC_Spend_Category__c pocSpend: pocSpendCatList){
            System.assertEquals(0, pocSpend.Trade_Activation_Discretionary_Spend__c);
            System.assertEquals(0, pocSpend.Trade_Activation_Driver_Spend__c);
            System.assertEquals(0, pocSpend.Pre_Planning_Spend__c);
            System.assertEquals(0, pocSpend.Variable_Spend__c);
            
        }

    }
}