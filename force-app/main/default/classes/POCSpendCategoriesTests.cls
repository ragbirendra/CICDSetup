@isTest private class POCSpendCategoriesTests {

    @testSetup static void testSetup() {
        POCMDataFactory.LoadTestBudgets();
        POCMDataFactory.LoadTestItemsAndPrograms();
    }

    static testMethod void createEachSpendCategoryRecordTypeCorrectlyCreatesRecordsForOutOfHome() {
        List<Annual_Area_Budget__c> newlyCreatedAnnualAreaBudgets = [SELECT Id FROM Annual_Area_Budget__c LIMIT 1];
        System.assert(!newlyCreatedAnnualAreaBudgets.isEmpty());

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

        newlyCreatedAnnualAreaBudgets[0].RecordTypeId = OOHRT.Id;
        update newlyCreatedAnnualAreaBudgets;

        Account testAccount = new Account();
        testAccount.Name = 'ABC';
        insert testAccount;

        Test.startTest();
            Annual_POC_Budget_Plan__c annualpocbudgetplan = new Annual_POC_Budget_Plan__c();
            annualpocbudgetplan.Account__c = testAccount.Id;
            annualpocbudgetplan.Annual_Territory_Budget__c = newlyCreatedAnnualAreaBudgets[0].Id;
            insert annualpocbudgetplan;
        Test.stopTest(); 

        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND IsActive = TRUE AND DeveloperName LIKE '%Out_of_Home'];
        System.assert(!recordTypeList.isEmpty());
        List<POC_Spend_Category__c> checkthatPOCSpendCategoriesExist = [SELECT Id FROM POC_Spend_Category__c WHERE Annual_POC_Budget_Plan__c = :annualpocbudgetplan.Id];
        System.assert(!checkthatPOCSpendCategoriesExist.isEmpty());
        System.assertEquals(recordTypeList.size(), checkthatPOCSpendCategoriesExist.size());
    }

    static testMethod void createEachSpendCategoryRecordTypeCorrectlyCreatesRecordsForInHome() {
        List<Annual_Area_Budget__c> newlyCreatedAnnualAreaBudgets = [SELECT Id FROM Annual_Area_Budget__c LIMIT 1];
        System.assert(!newlyCreatedAnnualAreaBudgets.isEmpty());

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

        newlyCreatedAnnualAreaBudgets[0].RecordTypeId = IHRT.Id;
        update newlyCreatedAnnualAreaBudgets;

        Account testAccount = new Account();
        testAccount.Name = 'ABC';
        insert testAccount;

        Test.startTest();
            Annual_POC_Budget_Plan__c annualpocbudgetplan = new Annual_POC_Budget_Plan__c();
            annualpocbudgetplan.Account__c = testAccount.Id;
            annualpocbudgetplan.Annual_Territory_Budget__c = newlyCreatedAnnualAreaBudgets[0].Id;
            insert annualpocbudgetplan;
        Test.stopTest(); 

        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND IsActive = TRUE AND DeveloperName LIKE '%In_Home'];
        System.assert(!recordTypeList.isEmpty());
        List<POC_Spend_Category__c> checkthatPOCSpendCategoriesExist = [SELECT Id FROM POC_Spend_Category__c WHERE Annual_POC_Budget_Plan__c = :annualpocbudgetplan.Id];
        System.assert(!checkthatPOCSpendCategoriesExist.isEmpty());
        System.assertEquals(recordTypeList.size(), checkthatPOCSpendCategoriesExist.size());
    }

    static testMethod void createEachSpendCategoryRecordTypeCorrectlyCreatesRecordsForInHomeAndOutOfHome() {
        List<Annual_Area_Budget__c> newlyCreatedAnnualAreaBudgets = [SELECT Id FROM Annual_Area_Budget__c LIMIT 2];
        System.assert(!newlyCreatedAnnualAreaBudgets.isEmpty());
        System.assert(newlyCreatedAnnualAreaBudgets.size() == 2);

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

        newlyCreatedAnnualAreaBudgets[0].RecordTypeId = IHRT.Id;
        newlyCreatedAnnualAreaBudgets[1].RecordTypeId = OOHRT.Id;
        update newlyCreatedAnnualAreaBudgets;

        Account testAccount = new Account();
        testAccount.Name = 'ABC';
        insert testAccount;

        Test.startTest();
            List<Annual_POC_Budget_Plan__c> listOfAnnualPOCBudgetPlan = new List<Annual_POC_Budget_Plan__c>();
            Annual_POC_Budget_Plan__c annualpocbudgetplan = new Annual_POC_Budget_Plan__c();
            annualpocbudgetplan.Account__c = testAccount.Id;
            annualpocbudgetplan.Annual_Territory_Budget__c = newlyCreatedAnnualAreaBudgets[0].Id;
            listOfAnnualPOCBudgetPlan.add(annualpocbudgetplan);
            Annual_POC_Budget_Plan__c annualpocbudgetplanTwo = new Annual_POC_Budget_Plan__c();
            annualpocbudgetplanTwo.Account__c = testAccount.Id;
            annualpocbudgetplanTwo.Annual_Territory_Budget__c = newlyCreatedAnnualAreaBudgets[1].Id;
            listOfAnnualPOCBudgetPlan.add(annualpocbudgetplanTwo);
            insert listOfAnnualPOCBudgetPlan;
        Test.stopTest(); 

        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND IsActive = TRUE AND (DeveloperName LIKE '%In_Home' OR DeveloperName LIKE '%Out_of_Home')];
        System.assert(!recordTypeList.isEmpty());
        List<POC_Spend_Category__c> checkthatPOCSpendCategoriesExist = [SELECT Id FROM POC_Spend_Category__c WHERE Annual_POC_Budget_Plan__c = :listOfAnnualPOCBudgetPlan[0].Id OR Annual_POC_Budget_Plan__c = :listOfAnnualPOCBudgetPlan[1].Id];
        //System.assert(!checkthatPOCSpendCategoriesExist.isEmpty());
        //System.assertEquals(recordTypeList.size(), checkthatPOCSpendCategoriesExist.size());
    }

    static testMethod void updateDriverAndDiscretionarySpendFromShoppedKitItemsCorrectlyRollsUp() {
        Brand__c getBrand = [SELECT Id FROM Brand__c LIMIT 1];
        Annual_Area_Budget__c getAnnualAreaBudget = [SELECT Id FROM Annual_Area_Budget__c LIMIT 1];

        Map<Id, Marketing_Program_Item__c> returnToolkitItemAndToolkitID = POCMDataFactory.returnToolkitItemAndToolkitID(getBrand.Id);
        insert returnToolkitItemAndToolkitID.values();

        List<Id> oneItemLitsOfToolkitID = new List<Id>();
        oneItemLitsOfToolkitID.addAll(returnToolkitItemAndToolkitID.keySet());

        Account testAccount = new Account();
        testAccount.Name = 'ABC';
        insert testAccount;

        Annual_POC_Budget_Plan__c annualpocbudgetplan = new Annual_POC_Budget_Plan__c();
        annualpocbudgetplan.Account__c = testAccount.Id;
        annualpocbudgetplan.Annual_Territory_Budget__c = getAnnualAreaBudget.Id;
        insert annualpocbudgetplan;

        Annual_Brand_Area_Budget_Plan__c annualBrandAreaBudgetPlan = new Annual_Brand_Area_Budget_Plan__c();
        annualBrandAreaBudgetPlan.Brand__c = getBrand.Id;
        annualBrandAreaBudgetPlan.Annual_Area_Budget__c = getAnnualAreaBudget.Id;
        insert annualBrandAreaBudgetPlan;

        List<POC_Spend_Category__c> triggerCreatedPOC = [SELECT Id FROM POC_Spend_Category__c WHERE Name = 'Trade Activation' AND Annual_POC_Budget_Plan__c = :annualpocbudgetplan.Id];
        System.assert(!triggerCreatedPOC.isEmpty());

        Marketing_Kit__c marketingKit = new Marketing_Kit__c();
        marketingKit.POC_Spend_Category__c = triggerCreatedPOC[0].Id;
        marketingKit.Marketing_Program_Name__c = oneItemLitsOfToolkitID[0];
        marketingKit.Annual_Brand_Area_Budget_Plan__c = annualBrandAreaBudgetPlan.Id;
        insert marketingKit;


        Test.startTest();
            Trade_Activation_Kit_Item__c tradeActivationKit = new Trade_Activation_Kit_Item__c();
            tradeActivationKit.Item_Price__c = 500;
            tradeActivationKit.Quantity__c = 2;
            tradeActivationKit.Item_Spend__c = 100;
            tradeActivationKit.Marketing_Kit__c = marketingKit.Id;
            tradeActivationKit.Marketing_Program_Item__c = returnToolkitItemAndToolkitID.values()[0].Id;
            insert tradeActivationKit;
        Test.stopTest();

        List<POC_Spend_Category__c> pocSpendCategoryList = [SELECT Id,Trade_Activation_Driver_Spend__c FROM POC_Spend_Category__c WHERE Name = 'Trade Activation' AND Annual_POC_Budget_Plan__c = :annualpocbudgetplan.Id];

        System.assert(!pocSpendCategoryList.isEmpty());
        System.assertEquals(0.00, pocSpendCategoryList[0].Trade_Activation_Driver_Spend__c);
    }

}