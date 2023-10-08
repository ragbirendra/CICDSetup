@isTest private class AnnualAreaBudgetsTests {

    @testSetup static void testSetup() {
        POCMDataFactory.LoadTestBudgets();
        POCMDataFactory.LoadTestItemsAndPrograms();

        Account testAccount = new Account();
        testAccount.Name = 'ABC';
        insert testAccount;
    }

    static testMethod void uncheckIsUpdate() {
        Annual_Area_Budget__c getAnnualAreaBudget = [SELECT Id, Status__c FROM Annual_Area_Budget__c LIMIT 1];
        getAnnualAreaBudget.Approval_Status__c = 'Approved';

        Account getAccount = [SELECT Id FROM Account LIMIT 1];

        Annual_POC_Budget_Plan__c newAnnualAreaBudget = new Annual_POC_Budget_Plan__c();
        newAnnualAreaBudget.isUpdated__c = true;
        newAnnualAreaBudget.Account__c = getAccount.Id;
        newAnnualAreaBudget.Annual_Territory_Budget__c = getAnnualAreaBudget.Id;
        insert newAnnualAreaBudget;

        Test.startTest();
            update getAnnualAreaBudget;
        Test.stopTest();

        Annual_POC_Budget_Plan__c getUpdatedPOCBudget = [SELECT Id, isUpdated__c FROM Annual_POC_Budget_Plan__c WHERE Id = :newAnnualAreaBudget.Id];

        System.assert(!getUpdatedPOCBudget.isUpdated__c);
    }

    static testMethod void rollupToAnnualAreaBudgetWithAnnualBrandAreaBudgetPlans() {
        Brand__c getBrand = [SELECT Id FROM Brand__c LIMIT 1];
        Annual_Area_Budget__c getAnnualAreaBudget = [SELECT Id, Trade_Activation_Budget__c FROM Annual_Area_Budget__c LIMIT 1];

        Annual_Brand_Area_Budget_Plan__c annualBrandAreaBudgetPlan = new Annual_Brand_Area_Budget_Plan__c();
        annualBrandAreaBudgetPlan.Brand__c = getBrand.Id;
        annualBrandAreaBudgetPlan.Annual_Area_Budget__c = getAnnualAreaBudget.Id;
        annualBrandAreaBudgetPlan.Brand_Budget__c = 0;
        insert annualBrandAreaBudgetPlan;

        Test.startTest();
            Annual_Brand_Area_Budget_Plan__c getInsertedBrandPlan = [SELECT Id, Brand_Budget__c FROM Annual_Brand_Area_Budget_Plan__c WHERE Id = :annualBrandAreaBudgetPlan.Id];
            getInsertedBrandPlan.Brand_Budget__c = 50;
            update getInsertedBrandPlan;
        Test.stopTest();

        Annual_Area_Budget__c getUpdatedAnnualAreaBudget = [SELECT Id, Trade_Activation_Budget__c FROM Annual_Area_Budget__c WHERE Id = :getAnnualAreaBudget.Id LIMIT 1];
       // System.AssertEquals(50 + getAnnualAreaBudget.Trade_Activation_Budget__c, getUpdatedAnnualAreaBudget.Trade_Activation_Budget__c);

    }

    static testMethod void rollupBudgetValuestoAllocated() {
        Annual_Area_Budget__c getAnnualAreaBudget = [SELECT Id, Trade_Activation_Budget__c, Discretionary_Budget__c, Drivers_Budget__c, Parent_Budget__c FROM Annual_Area_Budget__c LIMIT 1];

        RecordType recordType = [SELECT Id FROM RecordType WHERE sobjecttype = 'Annual_Area_Budget__c' AND DeveloperName = 'District'];
        Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
        newAnnualAreaBudget.Budget_Year__c = '2016';
        newAnnualAreaBudget.RecordTypeId = recordType.Id;
        insert newAnnualAreaBudget;

        getAnnualAreaBudget.Drivers_Budget__c = 0;
        getAnnualAreaBudget.Discretionary_Budget__c = 0;
        getAnnualAreaBudget.Trade_Activation_Budget__c = 0;
        getAnnualAreaBudget.Parent_Budget__c = newAnnualAreaBudget.Id;
        update getAnnualAreaBudget;

        Test.startTest();
            getAnnualAreaBudget.Drivers_Budget__c = 10;
            getAnnualAreaBudget.Discretionary_Budget__c = 10;
            getAnnualAreaBudget.Trade_Activation_Budget__c = 10;
            update getAnnualAreaBudget;
        Test.stopTest();

        Annual_Area_Budget__c updatednewAnnualAreaBudget = [SELECT Id, Allocated_Discretionary_Budget__c, Allocated_Driver_Budget__c, Allocated_Trade_Activation_Budget__c FROM Annual_Area_Budget__c WHERE Id = :newAnnualAreaBudget.Id];

        System.assertEquals(10, updatednewAnnualAreaBudget.Allocated_Discretionary_Budget__c);
        System.assertEquals(10, updatednewAnnualAreaBudget.Allocated_Driver_Budget__c);
        System.assertEquals(10, updatednewAnnualAreaBudget.Allocated_Trade_Activation_Budget__c);
    }

    static testMethod void generateRecordForEachPOCInArea() {
        String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'Territory' Limit 1].Id;

        lboc_Sales_Territory__c st = new lboc_Sales_Territory__c();
        st.lboc_Region__c = 'Specialty';
        st.Name = 'Specialty';
        insert st;

        RecordType OutletRT = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1];
        List<Account> listofAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account();
            acc.Name = 'Account ' + i;
            acc.RecordTypeId = OutletRT.Id;
            acc.lboc_Sales_Territory__c = st.Name;
            listofAccounts.add(acc);
        }
        insert listofAccounts;

        Test.startTest();
            Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
            newAnnualAreaBudget.Budget_Year__c = '2016';
            newAnnualAreaBudget.RecordTypeId = RecordTypeId;
            newAnnualAreaBudget.Sales_Territory__c = st.Id;
            insert newAnnualAreaBudget;
        Test.stopTest();

        List<Annual_POC_Budget_Plan__c> listOFAnnualPOCBudgets = [SELECT Id FROM Annual_POC_Budget_Plan__c WHERE Annual_Territory_Budget__c = :newAnnualAreaBudget.Id];
        System.assert(!listOFAnnualPOCBudgets.isEmpty());
        System.assertEquals(listofAccounts.size(), listOFAnnualPOCBudgets.size());
    }

    static testMethod void setApproverBeforeInsert() {
        Annual_Area_Budget__c getAnnualAreaBudget = [SELECT Id, Approver__c, OwnerID FROM Annual_Area_Budget__c LIMIT 1];
        RecordType recordType = [SELECT Id FROM RecordType WHERE sobjecttype = 'Annual_Area_Budget__c' AND DeveloperName = 'District'];
        getAnnualAreaBudget.RecordTypeId = recordType.Id;
        getAnnualAreaBudget.OwnerID = UserInfo.getUserId();
        update getAnnualAreaBudget;

        RecordType recordTypeTerritory = [SELECT Id FROM RecordType WHERE sobjecttype = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory'];

        Test.startTest();
            Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
            newAnnualAreaBudget.Budget_Year__c = '2016';
            newAnnualAreaBudget.Parent_Budget__c = getAnnualAreaBudget.Id;
            newAnnualAreaBudget.RecordTypeId = recordTypeTerritory.Id;
            insert newAnnualAreaBudget;
        Test.stopTest();

        Annual_Area_Budget__c getUpdatedAnnualAreaBudget = [SELECT Id, Approver__c FROM Annual_Area_Budget__c WHERE Id = :newAnnualAreaBudget.Id];
        System.assert(getUpdatedAnnualAreaBudget.Approver__c == UserInfo.getUserId());
    }

    static testMethod void updateApproverOnChild() {
        Annual_Area_Budget__c getAnnualAreaBudget = [SELECT Id, OwnerID FROM Annual_Area_Budget__c LIMIT 1];
        System.debug(getAnnualAreaBudget.OwnerID);
        RecordType recordType = [SELECT Id FROM RecordType WHERE sobjecttype = 'Annual_Area_Budget__c' AND DeveloperName = 'District'];
        getAnnualAreaBudget.RecordTypeId = recordType.Id;
        getAnnualAreaBudget.OwnerID = UserInfo.getUserId();
        update getAnnualAreaBudget;

        RecordType recordTypeTerritory = [SELECT Id FROM RecordType WHERE sobjecttype = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory'];

            Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
            newAnnualAreaBudget.Budget_Year__c = '2016';
            newAnnualAreaBudget.Parent_Budget__c = getAnnualAreaBudget.Id;
            newAnnualAreaBudget.RecordTypeId = recordTypeTerritory.Id;
            insert newAnnualAreaBudget;

        Annual_Area_Budget__c getUpdatedAnnualAreaBudget = [SELECT Id, Approver__c FROM Annual_Area_Budget__c WHERE Id = :newAnnualAreaBudget.Id];
        System.assert(getUpdatedAnnualAreaBudget.Approver__c == UserInfo.getUserId());

        Annual_Area_Budget__c getUpdatedSystemAnnualAreaBudget = [SELECT Id, OwnerID FROM Annual_Area_Budget__c WHERE Id = :getAnnualAreaBudget.Id];
        User randomUser = [select Id from User where id != :UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND isActive=True LIMIT 1];

        Test.startTest();
            getUpdatedSystemAnnualAreaBudget.OwnerID = randomUser.Id;
            update getUpdatedSystemAnnualAreaBudget;
        Test.stopTest();

        System.debug(randomUser);
        System.debug(UserInfo.getUserId());

        Annual_Area_Budget__c getUpdatedAgainAnnualAreaBudget = [SELECT Id, Approver__c FROM Annual_Area_Budget__c WHERE Id = :getUpdatedAnnualAreaBudget.Id];
        //System.assert(getUpdatedAnnualAreaBudget.Approver__c !=  UserInfo.getUserId());
        System.assert(getUpdatedAgainAnnualAreaBudget.Approver__c !=  UserInfo.getUserId());
    }

    static testMethod void updateAnnualAreaBudgetOwner() {
        lboc_Sales_Territory__c st = new lboc_Sales_Territory__c();
        st.lboc_Region__c = 'Specialty';
        st.Name = 'Specialty';
        st.OwnerId = UserInfo.getUserId();
        insert st;

        Annual_Area_Budget__c newAnnualAreaBudget = new Annual_Area_Budget__c();
        RecordType aabRT = [
            SELECT Id, DeveloperName FROM RecordType
            WHERE SObjectType = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory'
            Limit 1
        ];
        newAnnualAreaBudget.RecordTypeId = aabRT.Id;
        newAnnualAreaBudget.Budget_Year__c =  String.valueOf(Date.today().Year());
        newAnnualAreaBudget.OwnerId = UserInfo.getUserId();
        newAnnualAreaBudget.Sales_Territory__c = st.Id;
        insert newAnnualAreaBudget;

        Test.startTest();
            User randomUser = [SELECT Id FROM User WHERE id != :UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND isActive=True LIMIT 1];
            st.OwnerId = randomUser.Id;
            update st;
        Test.stopTest();

        Annual_Area_Budget__c getAnnualAreaBudget = [SELECT Id, OwnerId FROM Annual_Area_Budget__c WHERE Id = :newAnnualAreaBudget.Id];
        System.assertEquals(randomUser.Id, getAnnualAreaBudget.OwnerId);
    }
    static testMethod void BOBudgetMethodTest(){
         Annual_Area_Budget__c parbdgt = new Annual_Area_Budget__c();
        parbdgt.Budget_Year__c = '2019';
        parbdgt.Discretionary_Budget__c = 4000.33;
        parbdgt.Drivers_Budget__c = 500.66;
        parbdgt.District_Name__c = 'National';
        parbdgt.RecordtypeId = Schema.sObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH District').getRecordTypeId();
        //insert parbdgt;
        
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'Quebec';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        SalesTerritory.Back_Office_Territory__c=true;
        insert SalesTerritory;
    }

}