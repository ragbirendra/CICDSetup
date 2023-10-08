@isTest public class AnnualBrandAreaBudgetPlansTests {

    @testSetup static void testSetup() {
        RecordType TABrandRecordType = [Select Id From RecordType Where SObjectType = 'Brand__c' And DeveloperName = 'Trade_Activation' Limit 1];        
        Brand__c testBrandOne = new Brand__c();
        testBrandOne.name = 'A';
        testBrandOne.RecordTypeId = TABrandRecordType.Id;
        testBrandOne.Is_IH_Only__c = false;
        Brand__c testBrandTwo = new Brand__c();
        testBrandTwo.name = 'B';
        testBrandTwo.RecordTypeId = TABrandRecordType.Id;
        testBrandTwo.Is_IH_Only__c = false;
        List<Brand__c> testBrandList = new List<Brand__c>{testBrandOne, testBrandTwo};
        insert testBrandList;
        
        Marketing_Program__c marketingProgram = new Marketing_Program__c();
        marketingProgram.Brand__c = testBrandOne.Id;
        insert marketingProgram;
        
        String TerritoryId = String.valueOf(Math.round(Math.random()*1000));
        
        lboc_Sales_Territory__c testSalesTerritory = new lboc_Sales_Territory__c();
        testSalesTerritory.lboc_Territory_ID__c = TerritoryId;
        insert  testSalesTerritory;
        
        Integer Year = Date.today().year();        
        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = testSalesTerritory.Id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 0;
        insert AnnualAreaBudget;
        
        Annual_Brand_Area_Budget_Plan__c anBrandPlan=new Annual_Brand_Area_Budget_Plan__c();
        anBrandPlan.Annual_Area_Budget__c=AnnualAreaBudget.id;
        anBrandPlan.Brand__c=testBrandList[0].Id;
        insert anBrandPlan;
        
        Annual_Brand_Area_Budget_Plan__c AnnualAreaBrandBudget = [SELECT Id FROM Annual_Brand_Area_Budget_Plan__c WHERE Annual_Area_Budget__c =: AnnualAreaBudget.Id AND Brand__c =: testBrandList[0].Id LIMIT 1];
		
        RecordType CustomKitRecordType = [Select Id From RecordType Where SObjectType = 'Marketing_Kit__c' AND DeveloperName = 'Custom' Limit 1];
        Marketing_Kit__c shoppedKit = new Marketing_Kit__c();
        shoppedKit.RecordTypeId = CustomKitRecordType.Id;
        shoppedKit.Marketing_Program_Name__c = marketingProgram.Id;
        shoppedKit.Annual_Brand_Area_Budget_Plan__c = AnnualAreaBrandBudget.Id;
        insert shoppedKit;

        Marketing_Item__c marketingItemOne = new Marketing_Item__c();
        marketingItemOne.Brand__c = testBrandOne.Id;
        marketingItemOne.Temporary_Item_Number__c = '123123';
        marketingItemOne.Item_Number__c = '123123123';
        marketingItemOne.Price__c = 5;
        marketingItemOne.Marketing_Type__c = 'Visibility';

        Marketing_Item__c marketingItemTwo = new Marketing_Item__c();
        marketingItemTwo.Brand__c = testBrandOne.Id;
        marketingItemTwo.Temporary_Item_Number__c = '456456';
        marketingItemTwo.Item_Number__c = '456456456';
        marketingItemTwo.Price__c = 10;
        marketingItemTwo.Marketing_Type__c = 'Driver'; // Temp Set till Driver is active option again
        List<Marketing_Item__c> listOfMarketingItems = new List<Marketing_Item__c>{marketingItemOne, marketingItemTwo};
        insert listOfMarketingItems;

        Marketing_Program_Item__c marketingProgramItemOne = new Marketing_Program_Item__c();
        marketingProgramItemOne.Marketing_Program__c = marketingProgram.Id;
        marketingProgramItemOne.Marketing_Item__c = listOfMarketingItems[0].Id;

        Marketing_Program_Item__c marketingProgramItemTwo = new Marketing_Program_Item__c();
        marketingProgramItemTwo.Marketing_Program__c = marketingProgram.Id;
        marketingProgramItemTwo.Marketing_Item__c = listOfMarketingItems[1].Id;
        List<Marketing_Program_Item__c> listOfMarketingProgramItems = new List<Marketing_Program_Item__c>{marketingProgramItemOne, marketingProgramItemTwo};
        insert listOfMarketingProgramItems;

        Trade_Activation_Kit_Item__c tradeActivationKitItemVisibility = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItemVisibility.Marketing_Kit__c = shoppedKit.Id;
        tradeActivationKitItemVisibility.Quantity__c = 1;
        tradeActivationKitItemVisibility.Marketing_Program_Item__c = listOfMarketingProgramItems[0].Id;
        Trade_Activation_Kit_Item__c tradeActivationKitItemDriver = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItemDriver.Marketing_Kit__c = shoppedKit.Id;
        tradeActivationKitItemDriver.Quantity__c = 1;
        tradeActivationKitItemDriver.Marketing_Program_Item__c = listOfMarketingProgramItems[1].Id;
        List<Trade_Activation_Kit_Item__c> listOfTradeActivationKits = new List<Trade_Activation_Kit_Item__c>{tradeActivationKitItemVisibility, tradeActivationKitItemDriver};
        insert listOfTradeActivationKits;
    }

    static testMethod void generateRecordForEachBrandGeneratesNewRecords() {
        
        Annual_Area_Budget__c testAAB = [Select Id From Annual_Area_Budget__c];        

        List<Annual_Brand_Area_Budget_Plan__c> listOfAnnualBrandAreaBudgetPlans = [SELECT Id FROM Annual_Brand_Area_Budget_Plan__c WHERE Annual_Area_Budget__c = :testAAB.Id];
        //System.assertEquals(2, listOfAnnualBrandAreaBudgetPlans.size(), 'Should of only created two, one for each brand');
       // System.assert(!listOfAnnualBrandAreaBudgetPlans.isEmpty(), 'Should of assigned the Annual Brand Area Budget Plan to the passed in Annual Area Budget');
    }

    static testMethod void updateDriverAndDiscretionarySpendFromShoppedKitItems() {
        lboc_Sales_Territory__c testSalesTerritory = new lboc_Sales_Territory__c();
        insert  testSalesTerritory;

        Annual_Area_Budget__c testAAB = [Select Id From Annual_Area_Budget__c];

        List<Annual_Brand_Area_Budget_Plan__c> listOfAnnualBrandAreaBudgetPlans = [SELECT Id FROM Annual_Brand_Area_Budget_Plan__c WHERE Annual_Area_Budget__c = :testAAB.Id LIMIT 1];

        List<Marketing_Kit__c> listOfMarketingKits = [SELECT Id, Driver_Spend__c, Discretionary_Spend__c FROM Marketing_Kit__c LIMIT 1];
        // System.assertEquals(10, listOfMarketingKits[0].Driver_Spend__c);
        // System.assertEquals(5, listOfMarketingKits[0].Discretionary_Spend__c);

        listOfMarketingKits[0].Annual_Brand_Area_Budget_Plan__c = listOfAnnualBrandAreaBudgetPlans[0].Id;
        update listOfMarketingKits;

        // List<Annual_Brand_Area_Budget_Plan__c> listOfInitialAnnualBrandAreaBudgetPlans = [SELECT Id, Discretionary_Spend__c, Driver_Spend__c FROM Annual_Brand_Area_Budget_Plan__c WHERE Annual_Area_Budget__c = :testAAB.Id AND Id = :listOfAnnualBrandAreaBudgetPlans[0].Id];
        // System.assertEquals(10, listOfInitialAnnualBrandAreaBudgetPlans[0].Driver_Spend__c);
        // System.assertEquals(5, listOfInitialAnnualBrandAreaBudgetPlans[0].Discretionary_Spend__c);

        List<Trade_Activation_Kit_Item__c> listOfTradeActivationKits = [SELECT Id, Marketing_Type__c, Item_Spend__c FROM Trade_Activation_Kit_Item__c WHERE Marketing_Kit__c = :listOfMarketingKits[0].Id];
        System.debug(listOfTradeActivationKits[0]);
        if (listOfTradeActivationKits[0].Marketing_Type__c == 'Visibility') {
            listOfTradeActivationKits[1].Item_Spend__c = 100;
            listOfTradeActivationKits[0].Item_Spend__c = 50;
        } else {
            listOfTradeActivationKits[0].Item_Spend__c = 100;
            listOfTradeActivationKits[1].Item_Spend__c = 50;
        }
        Test.startTest();
            update listOfTradeActivationKits;
        Test.stopTest();

        List<Annual_Brand_Area_Budget_Plan__c> listOfUpdatedAnnualBrandAreaBudgetPlans = [SELECT Id, Discretionary_Spend__c, Driver_Spend__c FROM Annual_Brand_Area_Budget_Plan__c WHERE Annual_Area_Budget__c = :testAAB.Id AND Id = :listOfAnnualBrandAreaBudgetPlans[0].Id];
        // System.assertEquals(100, listOfUpdatedAnnualBrandAreaBudgetPlans[0].Driver_Spend__c);
        // System.assertEquals(50, listOfUpdatedAnnualBrandAreaBudgetPlans[0].Discretionary_Spend__c); // Discuss Process Builder on Update Logic
    }

}