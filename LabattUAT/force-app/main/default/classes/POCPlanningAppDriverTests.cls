@isTest private class POCPlanningAppDriverTests {

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
        
        // *** Substituted this line as no Annual_Brand_Area_Budget_Plan__c records are being created after inserting AnnualAreaBudget
        // Annual_Brand_Area_Budget_Plan__c AnnualAreaBrandBudget = [SELECT Id FROM Annual_Brand_Area_Budget_Plan__c WHERE Annual_Area_Budget__c =: AnnualAreaBudget.Id AND Brand__c =: testBrandList[0].Id];
        Annual_Brand_Area_Budget_Plan__c[] AnnualAreaBrandBudgets = [SELECT Id FROM Annual_Brand_Area_Budget_Plan__c WHERE Annual_Area_Budget__c =: AnnualAreaBudget.Id AND Brand__c =: testBrandList[0].Id];

        RecordType CustomKitRecordType = [Select Id From RecordType Where SObjectType = 'Marketing_Kit__c' AND DeveloperName = 'Custom' Limit 1];
        Marketing_Kit__c shoppedKit = new Marketing_Kit__c();
        shoppedKit.RecordTypeId = CustomKitRecordType.Id;
        shoppedKit.Marketing_Program_Name__c = marketingProgram.Id;
        // *** Substituted this line as AnnualAreaBrandBudget was null and Marketing_Kit__c can't be inserted without an Annual_Brand_Area_Budget_Plan__c
        // *** because of a validation rule on Marketing_Kit__c.
        // shoppedKit.Annual_Brand_Area_Budget_Plan__c = AnnualAreaBrandBudget.Id;
        if (AnnualAreaBrandBudgets.isEmpty()) {
            Annual_Brand_Area_Budget_Plan__c annualBrandAreaBudgetPlan = new Annual_Brand_Area_Budget_Plan__c();
            annualBrandAreaBudgetPlan.Annual_Area_Budget__c = AnnualAreaBudget.Id;
            annualBrandAreaBudgetPlan.Brand__c = testBrandList[0].Id;
            annualBrandAreaBudgetPlan.Brand_Budget__c = 0;
            insert annualBrandAreaBudgetPlan;
            shoppedKit.Annual_Brand_Area_Budget_Plan__c = annualBrandAreaBudgetPlan.Id;
        } else {
            shoppedKit.Annual_Brand_Area_Budget_Plan__c = AnnualAreaBrandBudgets[0].Id;
        }
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

        Test.startTest();
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
        Test.stopTest();
    }

    static testMethod void Driver() {
        List<RecordType> RecordTypeList = [Select Id, DeveloperName From RecordType Where (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'Territory') OR 
                                           (SObjectType =: 'Account' And DeveloperName =: 'Outlet')];
        String RecordTypeId;
        String OutletRTId;
        
        for(RecordType rt: RecordTypeList){
            if(rt.DeveloperName == 'Territory'){
                RecordTypeId = rt.Id;
            } 
            else if(rt.DeveloperName == 'Outlet'){
                OutletRTId = rt.Id;
            }
        }

        lboc_Sales_Territory__c st = new lboc_Sales_Territory__c();
        st.lboc_Region__c = 'Specialty';
        st.Name = 'Specialty';
        insert st;

        List<Account> listofAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account();
            acc.Name = 'Account ' + i;
            acc.RecordTypeId = OutletRTId;
            acc.lboc_Sales_Territory__c = st.Name;
            listofAccounts.add(acc);
        }
        insert listofAccounts;

        Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
        newAnnualAreaBudget.Budget_Year__c = '2016';
        newAnnualAreaBudget.RecordTypeId = RecordTypeId;
        newAnnualAreaBudget.Sales_Territory__c = st.Id;
        insert newAnnualAreaBudget; 

        Annual_POC_Budget_Plan__c getPOCBudget = [SELECT Id FROM Annual_POC_Budget_Plan__c WHERE Annual_Territory_Budget__c = :newAnnualAreaBudget.Id LIMIT 1];

        Test.startTest();
            List<POCPlanningAppDriver.DriverBrand> DriverList = POCPlanningApp.Driver(getPOCBudget.Id, false);
        Test.stopTest();
    }

    static testMethod void DriverFrench() {
        List<RecordType> RecordTypeList = [Select Id, DeveloperName From RecordType Where (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'Territory') OR 
                                           (SObjectType =: 'Account' And DeveloperName =: 'Outlet')];
        String RecordTypeId;
        String OutletRTId;
        
        for(RecordType rt: RecordTypeList){
            if(rt.DeveloperName == 'Territory'){
                RecordTypeId = rt.Id;
            } 
            else if(rt.DeveloperName == 'Outlet'){
                OutletRTId = rt.Id;
            }
        }

        lboc_Sales_Territory__c st = new lboc_Sales_Territory__c();
        st.lboc_Region__c = 'Specialty';
        st.Name = 'Specialty';
        insert st;

        List<Account> listofAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account();
            acc.Name = 'Account ' + i;
            acc.RecordTypeId = OutletRTId;
            acc.lboc_Sales_Territory__c = st.Name;
            listofAccounts.add(acc);
        }
        insert listofAccounts;

        Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
        newAnnualAreaBudget.Budget_Year__c = '2016';
        newAnnualAreaBudget.RecordTypeId = RecordTypeId;
        newAnnualAreaBudget.Sales_Territory__c = st.Id;
        insert newAnnualAreaBudget; 

        Annual_POC_Budget_Plan__c getPOCBudget = [SELECT Id FROM Annual_POC_Budget_Plan__c WHERE Annual_Territory_Budget__c = :newAnnualAreaBudget.Id LIMIT 1];

        Marketing_Item__c item = [SELECT Id FROM Marketing_Item__c LIMIT 1];

        Area_Item_Inventory__c inv = new Area_Item_Inventory__c();
        inv.Marketing_Item__c = item.Id;
        inv.Quantity_Allocated_to_Area__c = 10;
        inv.Quantity_Shopped__c = 0;
        inv.Labatt_Region__c = st.Name;
        insert inv;

        List<RecordType> diRC = [SELECT Id FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND DeveloperName = 'Driver_Out_of_Home'];
        POC_Spend_Category__c psc = [SELECT Id FROM POC_Spend_Category__c WHERE Annual_POC_Budget_Plan__c = :getPOCBudget.Id AND RecordTypeId = :diRC[0].Id LIMIT 1];

        Driver_Item__c driverItem = new Driver_Item__c();
        driverItem.Marketing_Item__c = item.Id;
        driverItem.POC_Spend_Category__c = psc.Id;
        driverItem.Quantity__c = 1;
        insert driverItem;

        Test.startTest();
            User u = [Select ID, LanguageLocaleKey FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];         
            u.LanguageLocaleKey = 'fr';         
            update u;

            System.runAs(u) {
                List<POCPlanningAppDriver.DriverBrand> DriverList = POCPlanningAppDriver.Driver(getPOCBudget.Id, false);
            }
        Test.stopTest();
    }

    static testMethod void OnDriverChange() {
        List<RecordType> RecordTypeList1 = [Select Id, DeveloperName From RecordType Where (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'Territory') OR
                                           (SObjectType =: 'Account' And DeveloperName =: 'Outlet')];
        String RecordTypeId;
        String OutletRTId;
        
        for(RecordType rt: RecordTypeList1){
            if(rt.DeveloperName == 'Territory'){
                RecordTypeId = rt.Id;
            } 
            else if(rt.DeveloperName == 'Outlet'){
                OutletRTId = rt.Id;
            }
        }
        
        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND DeveloperName = 'Driver_Out_of_Home'];
        lboc_Sales_Territory__c st = new lboc_Sales_Territory__c();
        st.lboc_Region__c = 'Specialty';
        st.Name = 'Specialty';
        insert st;

        List<Account> listofAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account();
            acc.Name = 'Account ' + i;
            acc.lboc_Sales_Territory__c = st.Name;
            acc.RecordTypeId = OutletRTId;
            listofAccounts.add(acc);
        }
        insert listofAccounts;

        Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
        newAnnualAreaBudget.Budget_Year__c = '2016';
        newAnnualAreaBudget.RecordTypeId = RecordTypeId;
        newAnnualAreaBudget.Sales_Territory__c = st.Id;
        insert newAnnualAreaBudget; 

        Annual_POC_Budget_Plan__c getPOCBudget = [SELECT Id FROM Annual_POC_Budget_Plan__c WHERE Annual_Territory_Budget__c = :newAnnualAreaBudget.Id LIMIT 1];
        Marketing_Item__c item = [SELECT Id FROM Marketing_Item__c LIMIT 1];
        POC_Spend_Category__c psc = [SELECT Id FROM POC_Spend_Category__c WHERE Annual_POC_Budget_Plan__c = :getPOCBudget.Id AND RecordTypeId = :recordTypeList[0].Id LIMIT 1];

        Area_Item_Inventory__c inv = new Area_Item_Inventory__c();
        inv.Marketing_Item__c = item.Id;
        inv.Quantity_Allocated_to_Area__c = 10;
        inv.Quantity_Shopped__c = 0;
        inv.Labatt_Region__c = 'Specialty';
        insert inv;

        Test.startTest();
            POCPlanningAppDriver.QtyRmngResponse DriverList = POCPlanningAppDriver.OnDriverChange(getPOCBudget.Id, item.Id, 1, 0, true, psc.Id, null, false, 'Specialty');
        Test.stopTest();
    }
    
    static testMethod void OnDriverChangeFail() {
        List<RecordType> RecordTypeList1 = [Select Id, DeveloperName From RecordType Where (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'Territory') OR
                                           (SObjectType =: 'Account' And DeveloperName =: 'Outlet')];
        String RecordTypeId;
        String OutletRTId;
        
        for(RecordType rt: RecordTypeList1){
            if(rt.DeveloperName == 'Territory'){
                RecordTypeId = rt.Id;
            } 
            else if(rt.DeveloperName == 'Outlet'){
                OutletRTId = rt.Id;
            }
        }
        
        
        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND DeveloperName = 'Driver_Out_of_Home'];
        lboc_Sales_Territory__c st = new lboc_Sales_Territory__c();
        st.lboc_Region__c = 'Specialty';
        st.Name = 'Specialty';
        insert st;

        List<Account> listofAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account();
            acc.Name = 'Account ' + i;
            acc.lboc_Sales_Territory__c = st.Name;
            acc.RecordTypeId = OutletRTId;
            listofAccounts.add(acc);
        }
        insert listofAccounts;

        Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
        newAnnualAreaBudget.Budget_Year__c = '2016';
        newAnnualAreaBudget.RecordTypeId = RecordTypeId;
        newAnnualAreaBudget.Sales_Territory__c = st.Id;
        insert newAnnualAreaBudget; 

        Annual_POC_Budget_Plan__c getPOCBudget = [SELECT Id FROM Annual_POC_Budget_Plan__c WHERE Annual_Territory_Budget__c = :newAnnualAreaBudget.Id LIMIT 1];
        Marketing_Item__c item = [SELECT Id FROM Marketing_Item__c LIMIT 1];
        POC_Spend_Category__c psc = [SELECT Id FROM POC_Spend_Category__c WHERE Annual_POC_Budget_Plan__c = :getPOCBudget.Id AND RecordTypeId = :recordTypeList[0].Id LIMIT 1];

        Area_Item_Inventory__c inv = new Area_Item_Inventory__c();
        inv.Marketing_Item__c = item.Id;
        inv.Quantity_Allocated_to_Area__c = 2;
        inv.Quantity_Shopped__c = 0;
        inv.Labatt_Region__c = 'Specialty';
        insert inv;

        Test.startTest();
            POCPlanningAppDriver.QtyRmngResponse DriverList = POCPlanningAppDriver.OnDriverChange(getPOCBudget.Id, item.Id, 10, 4, true, psc.Id, null, false, 'Specialty');
        Test.stopTest();
    }

    static testMethod void OnDriverChangeSpecialty() {
        List<RecordType> RecordTypeList1 = [Select Id, DeveloperName From RecordType Where (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'Territory') OR
                                           (SObjectType =: 'Account' And DeveloperName =: 'Outlet')];
        String RecordTypeId;
        String OutletRTId;
        
        for(RecordType rt: RecordTypeList1){
            if(rt.DeveloperName == 'Territory'){
                RecordTypeId = rt.Id;
            } 
            else if(rt.DeveloperName == 'Outlet'){
                OutletRTId = rt.Id;
            }
        }
        
        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND DeveloperName = 'Driver_Out_of_Home'];
        lboc_Sales_Territory__c st = new lboc_Sales_Territory__c();
        st.lboc_Region__c = 'Specialty';
        st.Name = 'Specialty';
        insert st;

        List<Account> listofAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account();
            acc.Name = 'Account ' + i;
            acc.lboc_Sales_Territory__c = st.Name;
            acc.RecordTypeId = OutletRTId;
            listofAccounts.add(acc);
        }
        insert listofAccounts;

        Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
        newAnnualAreaBudget.Budget_Year__c = '2016';
        newAnnualAreaBudget.RecordTypeId = RecordTypeId;
        newAnnualAreaBudget.Sales_Territory__c = st.Id;
        insert newAnnualAreaBudget; 

        Annual_POC_Budget_Plan__c getPOCBudget = [SELECT Id FROM Annual_POC_Budget_Plan__c WHERE Annual_Territory_Budget__c = :newAnnualAreaBudget.Id LIMIT 1];
        Marketing_Item__c item = [SELECT Id FROM Marketing_Item__c LIMIT 1];
        POC_Spend_Category__c psc = [SELECT Id FROM POC_Spend_Category__c WHERE Annual_POC_Budget_Plan__c = :getPOCBudget.Id AND RecordTypeId = :recordTypeList[0].Id LIMIT 1];

        Area_Item_Inventory__c inv = new Area_Item_Inventory__c();
        inv.Marketing_Item__c = item.Id;
        inv.Quantity_Allocated_to_Area__c = 10;
        inv.Quantity_Shopped__c = 0;
        inv.Specialty_Quantity_Allocated_to_Area__c = 5;
        inv.Specialty_Quantity_Shopped__c = 0;
        inv.Labatt_Region__c = 'Specialty';
        insert inv;

        Test.startTest();
            POCPlanningAppDriver.QtyRmngResponse DriverList = POCPlanningApp.OnDriverChange(getPOCBudget.Id, item.Id, 10, 4, true, psc.Id, null, false, 'Specialty');
        Test.stopTest();
    }

    static testMethod void OnDriverChangeSpecialtyFail() {
        List<RecordType> RecordTypeList1 = [Select Id, DeveloperName From RecordType Where (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'Territory') OR
                                           (SObjectType =: 'Account' And DeveloperName =: 'Outlet')];
        String RecordTypeId;
        String OutletRTId;
        
        for(RecordType rt: RecordTypeList1){
            if(rt.DeveloperName == 'Territory'){
                RecordTypeId = rt.Id;
            } 
            else if(rt.DeveloperName == 'Outlet'){
                OutletRTId = rt.Id;
            }
        }
        
        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND DeveloperName = 'Driver_Out_of_Home'];
        lboc_Sales_Territory__c st = new lboc_Sales_Territory__c();
        st.lboc_Region__c = 'Specialty';
        st.Name = 'Specialty';
        insert st;

        List<Account> listofAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account();
            acc.Name = 'Account ' + i;
            acc.lboc_Sales_Territory__c = st.Name;
            acc.RecordTypeId = OutletRTId;
            listofAccounts.add(acc);
        }
        insert listofAccounts;

        Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
        newAnnualAreaBudget.Budget_Year__c = '2016';
        newAnnualAreaBudget.RecordTypeId = RecordTypeId;
        newAnnualAreaBudget.Sales_Territory__c = st.Id;
        insert newAnnualAreaBudget; 

        Annual_POC_Budget_Plan__c getPOCBudget = [SELECT Id FROM Annual_POC_Budget_Plan__c WHERE Annual_Territory_Budget__c = :newAnnualAreaBudget.Id LIMIT 1];
        Marketing_Item__c item = [SELECT Id FROM Marketing_Item__c LIMIT 1];
        POC_Spend_Category__c psc = [SELECT Id FROM POC_Spend_Category__c WHERE Annual_POC_Budget_Plan__c = :getPOCBudget.Id AND RecordTypeId = :recordTypeList[0].Id LIMIT 1];

        Area_Item_Inventory__c inv = new Area_Item_Inventory__c();
        inv.Marketing_Item__c = item.Id;
        inv.Quantity_Allocated_to_Area__c = 10;
        inv.Quantity_Shopped__c = 0;
        inv.Specialty_Quantity_Allocated_to_Area__c = 1;
        inv.Specialty_Quantity_Shopped__c = 1;
        inv.Labatt_Region__c = 'Specialty';
        insert inv;

        Test.startTest();
            POCPlanningAppDriver.QtyRmngResponse DriverList = POCPlanningAppDriver.OnDriverChange(getPOCBudget.Id, item.Id, 1, 0, true, psc.Id, null, true, 'Specialty');
        Test.stopTest();
    }

    static testMethod void OnDriverChangeWithDriverItem() {
        List<RecordType> RecordTypeList1 = [Select Id, DeveloperName From RecordType Where (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'Territory') OR
                                           (SObjectType =: 'Account' And DeveloperName =: 'Outlet')];
        String RecordTypeId;
        String OutletRTId;
        
        for(RecordType rt: RecordTypeList1){
            if(rt.DeveloperName == 'Territory'){
                RecordTypeId = rt.Id;
            } 
            else if(rt.DeveloperName == 'Outlet'){
                OutletRTId = rt.Id;
            }
        }
        
        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE sobjecttype = 'POC_Spend_Category__c' AND DeveloperName = 'Driver_Out_of_Home'];
        lboc_Sales_Territory__c st = new lboc_Sales_Territory__c();
        st.lboc_Region__c = 'Specialty';
        st.Name = 'Specialty';
        insert st;

        List<Account> listofAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account();
            acc.Name = 'Account ' + i;
            acc.lboc_Sales_Territory__c = st.Name;
            acc.RecordTypeId = OutletRTId;
            listofAccounts.add(acc);
        }
        insert listofAccounts;

        Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
        newAnnualAreaBudget.Budget_Year__c = '2016';
        newAnnualAreaBudget.RecordTypeId = RecordTypeId;
        newAnnualAreaBudget.Sales_Territory__c = st.Id;
        insert newAnnualAreaBudget; 

        Annual_POC_Budget_Plan__c getPOCBudget = [SELECT Id FROM Annual_POC_Budget_Plan__c WHERE Annual_Territory_Budget__c = :newAnnualAreaBudget.Id LIMIT 1];
        Marketing_Item__c item = [SELECT Id FROM Marketing_Item__c LIMIT 1];
        POC_Spend_Category__c psc = [SELECT Id FROM POC_Spend_Category__c WHERE Annual_POC_Budget_Plan__c = :getPOCBudget.Id AND RecordTypeId = :recordTypeList[0].Id LIMIT 1];

        Area_Item_Inventory__c inv = new Area_Item_Inventory__c();
        inv.Marketing_Item__c = item.Id;
        inv.Quantity_Allocated_to_Area__c = 10;
        inv.Quantity_Shopped__c = 0;
        inv.Specialty_Quantity_Shopped__c = 0;
        inv.Specialty_Quantity_Allocated_to_Area__c = 0;
        inv.Labatt_Region__c = 'Specialty';
        insert inv;

        Driver_Item__c driverItem = new Driver_Item__c();
        driverItem.Marketing_Item__c = item.Id;
        driverItem.POC_Spend_Category__c = psc.Id;
        driverItem.Quantity__c = 1;
        insert driverItem;

        Test.startTest();
            POCPlanningAppDriver.QtyRmngResponse DriverList = POCPlanningAppDriver.OnDriverChange(getPOCBudget.Id, item.Id, 2, 1, true, psc.Id, driverItem.Id, false, 'Specialty');
        Test.stopTest();
    }

}