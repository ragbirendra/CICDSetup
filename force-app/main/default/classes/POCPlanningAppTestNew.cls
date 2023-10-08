@isTest public class POCPlanningAppTestNew {
	 @isTest static void test_getIHDistrictBudgetCustomSetting(){
        //TestElements te = prepareTestElements();
        POCPlanningApp objPocplan = new POCPlanningApp();
        objPocplan.isBackOfficeUser = false;
        objPocplan.isBackOfficeClubElite = false;
        objPocplan.isOnlyBackOffice = false;
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'TestRegion';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;
        
        String Year = String.valueOf(Date.today().year());
		//lboc_Sales_Territory__c SalesTerritory=[SELECT id, lboc_District_ID__c FROM lboc_Sales_Territory__c LIMIT 1];
        test.startTest();
        POCPlanningApp.getIHDistrictBudgetCustomSetting(SalesTerritory.lboc_District_ID__c, Year);
        test.stopTest();
    }
    
    @isTest static void test_InitiateApp() {
        Restricated_Brand__c roObject= new Restricated_Brand__c();
		roObject.Brand_Name__c='Test';
        insert roObject;

        Integer Year = Integer.valueOf(Date.today().year());
        
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'Quebec';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;
        
        List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c'];
        RecordType TerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                TerritoryRT = rt;
                break;
            }
        }

        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = TerritoryRT.Id;
        insert AnnualAreaBudget;

       
        

        POC_Kit_Thresholds__c pockitthreshdr = new POC_Kit_Thresholds__c();
        pockitthreshdr.Name = 'TA Driver';
        pockitthreshdr.Allows_For__c = 'test';
        pockitthreshdr.Minimum__c = 100;
        insert pockitthreshdr;

        POC_Kit_Thresholds__c pockitthreshvs = new POC_Kit_Thresholds__c();
        pockitthreshvs.Name = 'TA Visibility';
        pockitthreshvs.Allows_For__c = 'test';
        pockitthreshvs.Minimum__c = 100;
        insert pockitthreshvs;
        
        POC_Planning_Brand_Restriction__c pocBrandRest=new POC_Planning_Brand_Restriction__c();
        pocBrandRest.Budget_Year__c=String.valueOf(Date.today().year());
        pocBrandRest.Restricted_Brands__c='Bud Light, Corona';
        insert pocBrandRest;
        
		//Annual_Area_Budget__c AnnualAreaBudget = [SELECT id FROM Annual_Area_Budget__c LIMIT 1];
        test.startTest();
        POCPlanningApp.InitialAppData OOHdata = POCPlanningApp.InitiateApp(AnnualAreaBudget.Id);
        String YearNew = String.valueOf(Date.today().year());
        String businessLine ='Out of Home';
        //test_Budget
        POCPlanningApp.Budget(AnnualAreaBudget.Id,YearNew,businessLine);
        //test_IHPOCList
        POCPlanningApp.IHPOCList(AnnualAreaBudget.Id);
        
        test.stopTest();
 
    }
    ///////////////////////
    @isTest static void test_InitiateAppBO() {
        
        Integer Year = Integer.valueOf(Date.today().year());
        
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'Quebec';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;
        
        List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c'];
        RecordType TerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                TerritoryRT = rt;
                break;
            }
        }
        
        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = TerritoryRT.Id;
        insert AnnualAreaBudget;

       
        

        POC_Kit_Thresholds__c pockitthreshdr = new POC_Kit_Thresholds__c();
        pockitthreshdr.Name = 'TA Driver';
        pockitthreshdr.Allows_For__c = 'test';
        pockitthreshdr.Minimum__c = 100;
        insert pockitthreshdr;

        POC_Kit_Thresholds__c pockitthreshvs = new POC_Kit_Thresholds__c();
        pockitthreshvs.Name = 'TA Visibility';
        pockitthreshvs.Allows_For__c = 'test';
        pockitthreshvs.Minimum__c = 100;
        insert pockitthreshvs;
        
		//Annual_Area_Budget__c AnnualAreaBudget = [SELECT id FROM Annual_Area_Budget__c LIMIT 1];
        test.startTest();
        POCPlanningApp.InitialAppData OOHdata = POCPlanningApp.InitiateApp(null);
        test.stopTest();
 
    }////////////////
     @isTest static void test_InitiateApp_IH() {

        Integer Year = Integer.valueOf(Date.today().year());
        test.startTest();
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'Quebec';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;
        
        List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c'];
        
        RecordType IHTerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'IH_Territory'){
                IHTerritoryRT = rt;
                break;
            }
        }

        Annual_Area_Budget__c AnnualAreaBudgetIH = new Annual_Area_Budget__c();
        AnnualAreaBudgetIH.Sales_Territory__c = SalesTerritory.Id;
        AnnualAreaBudgetIH.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudgetIH.RecordTypeId = IHTerritoryRT.Id;

        insert AnnualAreaBudgetIH;

        //test.startTest();
        POCPlanningApp.InitialAppData IHdata = POCPlanningApp.InitiateApp(AnnualAreaBudgetIH.Id);
        POCPlanningApp.BudgetIH(AnnualAreaBudgetIH.Id);
        POCPlanningApp.IHProgram ih = new POCPlanningApp.IHProgram();
        ih.Information = 'test';
        ih.KitName = 'test';
        ih.Name='test';
        ih.Id = '11111111111';
        ih.Price=555;
        ih.Qty = 1;
        ih.KitId = 'kitId';
        ih.ProgramId = 'ProgramId';
        ih.ProgramStart = 'start';
        ih.ProgramEnd = 'end';
        
        test.stopTest();
 
    }
    @isTest static void test_UpdateTAKit() {
        Integer Year = Integer.valueOf(Date.today().year());
        Date Today = date.today(); 
         
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'Quebec';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;
        
        List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c'];
        RecordType TerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                TerritoryRT = rt;
                break;
            }
        }
        
        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = TerritoryRT.Id;
        insert AnnualAreaBudget;
        
        String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
        insert a;
        
        Annual_POC_Budget_Plan__c TerritoryPOC = new Annual_POC_Budget_Plan__c();
        TerritoryPOC.Account__c = a.Id;
        TerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
        insert TerritoryPOC;
    
        RecordType TABrandRecordType = [Select Id From RecordType Where SObjectType = 'Brand__c' And DeveloperName = 'Trade_Activation' Limit 1];

        Brand__c b = new Brand__c();
        b.Name = 'Test Brand';
        b.Is_IH_Only__c = false;
        b.RecordTypeId = TABrandRecordType.Id;
        insert b;

        Annual_Brand_Area_Budget_Plan__c AnnualBrandAreaBudget = new Annual_Brand_Area_Budget_Plan__c();
        AnnualBrandAreaBudget.Annual_Area_Budget__c = AnnualAreaBudget.Id;
        AnnualBrandAreaBudget.Brand__c = b.Id;
        AnnualBrandAreaBudget.Brand_Budget__c = 0;
        insert AnnualBrandAreaBudget;

        Id taRecordTypeId = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Programming').getRecordTypeId();
        POC_Spend_Category__c POCTASpCat = new POC_Spend_Category__c();
        POCTASpCat.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCTASpCat.RecordTypeId = taRecordTypeId;
        insert POCTASpCat;
    
        Marketing_Program__c Program = new Marketing_Program__c();
        Program.Name = 'TestProgram';
        Program.Brand__c = b.Id;
        insert Program;
        
        List<RecordType> KitRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Marketing_Kit__c'];
        RecordType CustomKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Custom'){
                CustomKitRT = rt;
            }
        }

        Marketing_Kit__c CustomShoppedKit = new Marketing_Kit__c();
        CustomShoppedKit.RecordTypeId = CustomKitRT.Id;
        CustomShoppedKit.Marketing_Program_Name__c = Program.Id;
        CustomShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        CustomShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        CustomShoppedKit.Qty__c = 2;
        insert CustomShoppedKit;
        
        Marketing_Item__c MarketingItem = new Marketing_Item__c();
        MarketingItem.Brand__c = b.Id;
        MarketingItem.Temporary_Item_Number__c = '12313';
        MarketingItem.Item_Number__c = '12312313';
        MarketingItem.Price__c = 5;
        MarketingItem.Marketing_Type__c = 'Driver';
        MarketingItem.IH_Item_Classification__c = 'In Store Driver';
        insert MarketingItem;
        
        Marketing_Program_Item__c ProgramItem = new Marketing_Program_Item__c();
        ProgramItem.Marketing_Program__c = Program.Id;
        ProgramItem.Marketing_Item__c = MarketingItem.Id;
        insert ProgramItem;
        
        List<Trade_Activation_Kit_Item__c> tradeActivationKitItemsList = new List<Trade_Activation_Kit_Item__c>();
        
        Trade_Activation_Kit_Item__c tradeActivationKitItem3 = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem3.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem3.Marketing_Kit__c = CustomShoppedKit.id;
        tradeActivationKitItem3.Quantity__c = 1;
        tradeActivationKitItem3.Marketing_Type__c = 'Promotional';
        tradeActivationKitItem3.Item_Spend__c = 12;
        tradeActivationKitItemsList.add(tradeActivationKitItem3);
        
        Trade_Activation_Kit_Item__c tradeActivationKitItem4 = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem4.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem4.Marketing_Kit__c = CustomShoppedKit.id;
        tradeActivationKitItem4.Quantity__c = 1;
        tradeActivationKitItem4.Marketing_Type__c = 'Driver';
        tradeActivationKitItem4.Item_Spend__c = 12;
        tradeActivationKitItemsList.add(tradeActivationKitItem4);
        
        insert tradeActivationKitItemsList;
        
        test.startTest();
        POCPlanningApp.UpdateTAKit(CustomShoppedKit.Id, Today.year()+'-'+Today.month()+'-'+Today.day(), Today.year()+'-'+Today.month()+'-'+Today.day(), 1);
        test.stopTest();
    
        
    }
    @isTest static void test_CreateTAKitItem() {

        Integer Year = Integer.valueOf(Date.today().year());

        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'TestRegion';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;

        String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
        insert a;

        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory'].id;
        insert AnnualAreaBudget;

        Annual_POC_Budget_Plan__c TerritoryPOC = new Annual_POC_Budget_Plan__c();
        TerritoryPOC.Account__c = a.Id;
        TerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
        insert TerritoryPOC;

        Id taRecordTypeId = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Programming').getRecordTypeId();
        POC_Spend_Category__c POCTASpCat = new POC_Spend_Category__c();
        POCTASpCat.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCTASpCat.Name = 'Variable';
        POCTASpCat.RecordTypeId = taRecordTypeId;        
        insert POCTASpCat;

        RecordType TABrandRecordType = [Select Id From RecordType Where SObjectType = 'Brand__c' And DeveloperName = 'Trade_Activation' Limit 1];

        Brand__c b = new Brand__c();
        b.Name = 'Test Brand';
        b.Is_IH_Only__c = false;
        b.RecordTypeId = TABrandRecordType.Id;
        insert b;

        Annual_Brand_Area_Budget_Plan__c AnnualBrandAreaBudget = new Annual_Brand_Area_Budget_Plan__c();
        AnnualBrandAreaBudget.Annual_Area_Budget__c = AnnualAreaBudget.Id;
        AnnualBrandAreaBudget.Brand__c = b.Id;
        AnnualBrandAreaBudget.Brand_Budget__c = 0;
        insert AnnualBrandAreaBudget;

        Marketing_Program__c Program = new Marketing_Program__c();
        Program.Name = 'TestProgram';
        Program.Brand__c = b.Id;
        Program.Program_End_Date__c = date.today().addDays(2);
        insert Program;

        Marketing_Item__c MarketingItem = new Marketing_Item__c();
        MarketingItem.Brand__c = b.Id;
        MarketingItem.Temporary_Item_Number__c = '12313';
        MarketingItem.Item_Number__c = '12312313';
        MarketingItem.Price__c = 5;
        MarketingItem.Marketing_Type__c = 'Driver';
        MarketingItem.IH_Item_Classification__c = 'In Store Driver';
        insert MarketingItem;

        OnPoint_District__c onPointDistrict = new OnPoint_District__c();
        onPointDistrict.District_Code__c = SalesTerritory.lboc_Region__c;
        onPointDistrict.Name = 'TEST onPointDistrict';
        insert onPointDistrict;

        Area_Item_Inventory__c AreaItemInventory = new Area_Item_Inventory__c ();
        AreaItemInventory.Marketing_Item__c = MarketingItem.Id;
        AreaItemInventory.Quantity_Shopped__c = 0;
        AreaItemInventory.Quantity_Allocated_to_Area__c = 100;
        AreaItemInventory.Specialty_Quantity_Shopped__c = 0;
        AreaItemInventory.Specialty_Quantity_Allocated_to_Area__c = 100;
        AreaItemInventory.Labatt_Region__c = SalesTerritory.lboc_Region__c;
        AreaItemInventory.OnPoint_District__c = onPointDistrict.id;
        insert AreaItemInventory;

        Marketing_Program_Item__c ProgramItem = new Marketing_Program_Item__c();
        ProgramItem.Marketing_Program__c = Program.Id;
        ProgramItem.Marketing_Item__c = MarketingItem.Id;
        insert ProgramItem;

        List<RecordType> KitRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Marketing_Kit__c'];
        RecordType CustomKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Custom'){
                CustomKitRT = rt;
            }
        }

        Marketing_Kit__c CustomShoppedKit = new Marketing_Kit__c();
        CustomShoppedKit.RecordTypeId = CustomKitRT.Id;
        CustomShoppedKit.Marketing_Program_Name__c = Program.Id;
        CustomShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        CustomShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        insert CustomShoppedKit;

        Trade_Activation_Kit_Item__c tradeActivationKitItemDriver = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItemDriver.Marketing_Kit__c = CustomShoppedKit.Id;
        tradeActivationKitItemDriver.Quantity__c = 1;
        tradeActivationKitItemDriver.Marketing_Program_Item__c =  ProgramItem.Id;
        insert tradeActivationKitItemDriver;

        test.startTest();
        POCPlanningApp.CreateTAKitItem(CustomShoppedKit.Id, ProgramItem.Id, 1);
        //test_UpdateTAKitItem
        POCPlanningApp.UpdateTAKitItem(tradeActivationKitItemDriver.Id, 2);
        //test_updateProgramExecutionDates
        Date Today = date.today();
        POCPlanningApp.updateProgramExecutionDates(CustomShoppedKit.Id, Today.year()+'-'+Today.month()+'-'+Today.day(), Today.year()+'-'+Today.month()+'-'+Today.day());
        //test_updateTAQuantities
        POCPlanningApp.updateTAQuantities(MarketingItem.Id, 2, false, SalesTerritory.lboc_Region__c);
        POCPlanningApp.updateTAQuantities(MarketingItem.Id, 200, false, SalesTerritory.lboc_Region__c);
        //test_UpdateQuebecTAKitDates
        POCPlanningApp.UpdateQuebecTAKitDates(POCTASpCat.Id, Program.Id, Today.year()+'-'+Today.month()+'-'+Today.day(), Today.year()+'-'+Today.month()+'-'+Today.day());
        //test_updateIsIncomplete
        POCPlanningApp.updateIsIncomplete(TerritoryPOC.id,true);
        POCPlanningApp.fetchVariableData(TerritoryPOC.id);
        
        test.stopTest();
    }
    @isTest static void getIHBudgets() {

        Integer Year = Integer.valueOf(Date.today().year());

        test.startTest();
        POCPlanningApp.getIHBudgets(Year +'', 'TestRegionId');
        test.stopTest();
    }

    @isTest static void test_getRepReports(){

        test.startTest();
        POCPlanningApp.getRepReports();
        test.stopTest();
    }

    @isTest static void test_Discretionary(){

        Integer Year = Integer.valueOf(Date.today().year());

        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'TestRegion';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;

        String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
        insert a;

        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory'].id;
        insert AnnualAreaBudget;

        Annual_POC_Budget_Plan__c TerritoryPOC = new Annual_POC_Budget_Plan__c();
        TerritoryPOC.Account__c = a.Id;
        TerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
        insert TerritoryPOC;

        POC_Spend_Category__c POCDiscrSpCat = new POC_Spend_Category__c();
        POCDiscrSpCat.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCDiscrSpCat.RecordTypeId = [Select Id From RecordType Where SObjectType =: 'POC_Spend_Category__c' And DeveloperName =: 'Discretionary_Out_of_Home' Limit 1].Id;
        insert POCDiscrSpCat;

        POC_Spend_Category__c POCDriverSpCat = new POC_Spend_Category__c();
        POCDriverSpCat.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCDriverSpCat.RecordTypeId = [Select Id From RecordType Where SObjectType =: 'POC_Spend_Category__c' And DeveloperName =: 'Driver_Out_of_Home' Limit 1].Id;
        insert POCDriverSpCat;

        test.startTest();
        POCPlanningApp.Discretionary(TerritoryPOC.Id);
        delete POCDiscrSpCat;
        delete [SELECT id FROM POC_Spend_Category__c WHERE Name = 'Discretionary'];
        POCPlanningApp.Discretionary(TerritoryPOC.Id);
        //test_OnDiscretionaryChange
        POCPlanningApp.OnDiscretionaryChange(TerritoryPOC.Id, 100, 100, 100, POCDriverSpCat.Id);
        //test_submitFinalPlan
        AnnualAreaBudget.Approver__c = [SELECT Id FROM USER where id != :UserInfo.getUserId() AND IsActive=true LIMIT 1].Id;
        update AnnualAreaBudget;
        POCPlanningApp.submitFinalPlan(AnnualAreaBudget.Id);
        //test_setAnnuaLPOCBudgetPlanToUpdated

        POCPlanningApp.setAnnuaLPOCBudgetPlanToUpdated(TerritoryPOC.Id);

        //test_onVariableChange
        POCPlanningApp.onVariableChange(50.00,50.00,50.00,50.00, POCDriverSpCat.Id);
        test.stopTest();
    }
    @isTest static void test_submitFinalPlan_LockFailure(){

        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'TestRegion';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;

        test.startTest();
        POCPlanningApp.POCTASpend pocta = new POCPlanningApp.POCTASpend();
        pocta.Driver = 0.00;
        pocta.Discretionary = 0.00;
        pocta.BrandId = '12321345';
        pocta.BrandName = 'A Brand is here';

        Approval.lock(SalesTerritory.Id);


        POCPlanningApp.submitFinalPlan(SalesTerritory.Id);
        //test_submitFinalPlanApproverFailure
        POCPlanningApp.submitFinalPlan(SalesTerritory.Id);
        test.stopTest();
    }

    @isTest static void test_updateIHDriverQuantityWithoutDriverItem() {

        Integer Year = Integer.valueOf(Date.today().year());

        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'TestRegion';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;

        String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
        insert a;

        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory'].id;
        insert AnnualAreaBudget;

        Annual_POC_Budget_Plan__c TerritoryPOC = new Annual_POC_Budget_Plan__c();
        TerritoryPOC.Account__c = a.Id;
        TerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
        insert TerritoryPOC;

        test.StartTest();
        Brand__c retrieveBrand = new Brand__c();
        retrieveBrand.Name = 'Test Brand';
        retrieveBrand.Is_IH_Only__c = false;
        insert retrieveBrand;

        Marketing_Item__c newMarketingItem = new Marketing_Item__c();
        newMarketingItem.IH_Item_Classification__c = 'Cooler';
        newMarketingItem.Marketing_Type__c = 'Driver';
        newMarketingItem.Brand__c = retrieveBrand.Id;
        insert newMarketingItem;

        POC_Spend_Category__c POCDriverSpCat = new POC_Spend_Category__c();
        POCDriverSpCat.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCDriverSpCat.RecordTypeId = [Select Id From RecordType Where SObjectType =: 'POC_Spend_Category__c' And DeveloperName =: 'Driver_Out_of_Home' Limit 1].Id;
        insert POCDriverSpCat;

        ID getID = POCPlanningApp.updateIHDriverQuantity(POCDriverSpCat.Id, null, newMarketingItem.Id, 2, 50);

        test.StopTest();
    }
    @isTest static void test_updateIHDriverQuantityWithDriverItem() {
        test.StartTest();

        String Year = String.valueOf(Date.today().year());
        Brand__c retrieveBrand = new Brand__c();
        retrieveBrand.Name = 'test brand';
        insert retrieveBrand;

        Marketing_Item__c newMarketingItem = new Marketing_Item__c();
        newMarketingItem.IH_Item_Classification__c = 'Cooler';
        newMarketingItem.Marketing_Type__c = 'Driver';
        newMarketingItem.Brand__c = retrieveBrand.Id;
        newMarketingItem.Is_Program_Only__c = false;
        insert newMarketingItem;
        
        Annual_Area_Budget__c budget = new Annual_Area_Budget__c();
        budget.Budget_Year__c = String.valueOf(Year);
        insert budget;
        
        Account acc = new Account();
        acc.Name = 'test acc';
        insert acc;
        
        
        Annual_POC_Budget_Plan__c poc = new Annual_POC_Budget_Plan__c();
        poc.Name = 'test poc';
        poc.Annual_Territory_Budget__c = budget.Id;
        poc.Account__c = acc.id;
        insert poc;
        
        Id recordTypeId = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'POC_Spend_Category__c' AND DeveloperName='Driver_Out_of_Home' LIMIT 1][0].Id;
        
        POC_Spend_Category__c POCDriverSpCat = new POC_Spend_Category__c();
        POCDriverSpCat.Name = 'Test POC_Spend_Category__c';
        POCDriverSpCat.Annual_POC_Budget_Plan__c = poc.Id;
        POCDriverSpCat.RecordTypeId= recordTypeId;
        insert POCDriverSpCat;
        
        
        Driver_Item__c di = new Driver_Item__c();
        di.Quantity__c = 2;
        di.Marketing_Item__c = newMarketingItem.Id;
        di.POC_Spend_Category__c = POCDriverSpCat.Id;
        di.Item_Price__c = 50;
        insert di;

        ID getID = POCPlanningApp.updateIHDriverQuantity(POCDriverSpCat.Id, di.Id, newMarketingItem.Id, 4, 50);
     

        List<Driver_Item__c> getDriverItem = [SELECT Id, Quantity__c, POC_Spend_Category__c, Marketing_Item__c FROM Driver_Item__c WHERE Id = :di.Id];
        System.assert(getDriverItem.size() == 1);
        System.assertEquals(4, getDriverItem[0].Quantity__c);
        System.assertEquals(newMarketingItem.Id, getDriverItem[0].Marketing_Item__c);
        
        //test_getIHDriverItems
        POCPlanningApp.getIHDriverItems(POCDriverSpCat.Id, 'Cooler', 'Ontario');
        //updateTargetLabattVolume
        POCPlanningApp.updateTargetLabattVolume(poc.id,'123');
        POCPlanningApp.updateCapCounterParts(poc.id,true,true,true,true,true,true,123,123,'Exclusif 100%');
        test.StopTest();
    }

    @isTest static void getIHDistrictTierBudgetCustomSetting(){

        String Year = String.valueOf(Date.today().year());

        In_Home_District_Budget__c DistTierBudget = new In_Home_District_Budget__c();
        DistTierBudget.Name = 'TestDistT';
        DistTierBudget.District_ID__c = 'TestDistrictId';
        DistTierBudget.Year__c = Year;
        DistTierBudget.Tier__c = 'Tier';
        DistTierBudget.Variable_Budget__c = 1000;
        insert  DistTierBudget;

        In_Home_Max_and_Min_Spend__c homeMaxMinSpend = new In_Home_Max_and_Min_Spend__c();
        homeMaxMinSpend.Budget_Type__c = 'Test';
        homeMaxMinSpend.Name = 'Test';
        insert homeMaxMinSpend;

        test.StartTest();
        POCPlanningApp.getIHDistrictTierBudgetCustomSetting('TestDistrictId','Tier');
        POCPlanningApp.getIHMaxMinSpendCustomSetting('Test');
        test.StopTest();
    }
    @isTest static void test_IHProgramming(){

        String Year = String.valueOf(Date.today().year());

        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'TestRegion';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;

        String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
        insert a;

        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory'].id;
        insert AnnualAreaBudget;

        Annual_POC_Budget_Plan__c poc = new Annual_POC_Budget_Plan__c();
        poc.Name = 'test poc';
        poc.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
        poc.Account__c = a.id;
        insert poc;
        
        Id recordTypeIdIH = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'POC_Spend_Category__c' AND DeveloperName='Programming_In_Home' LIMIT 1][0].Id;
        POC_Spend_Category__c POCDriverSpCat = new POC_Spend_Category__c();
        POCDriverSpCat.Name = 'Test POC_Spend_Category__c';
        POCDriverSpCat.Annual_POC_Budget_Plan__c = poc.Id;
        POCDriverSpCat.RecordTypeId= recordTypeIdIH;
        insert POCDriverSpCat;

        RecordType TABrandRecordType = [Select Id From RecordType Where SObjectType = 'Brand__c' And DeveloperName = 'Trade_Activation' Limit 1];

        Brand__c b = new Brand__c();
        b.Name = 'Test Brand';
        b.Is_IH_Only__c = false;
        b.RecordTypeId = TABrandRecordType.Id;
        insert b;

        Annual_Brand_Area_Budget_Plan__c AnnualBrandAreaBudget = new Annual_Brand_Area_Budget_Plan__c();
        AnnualBrandAreaBudget.Annual_Area_Budget__c = AnnualAreaBudget.Id;
        AnnualBrandAreaBudget.Brand__c = b.Id;
        AnnualBrandAreaBudget.Brand_Budget__c = 0;
        insert AnnualBrandAreaBudget;

        Marketing_Program__c Program = new Marketing_Program__c();
        Program.Name = 'TestProgram';
        Program.Brand__c = b.Id;
        Program.Program_End_Date__c = date.today().addDays(2);
        insert Program;

        List<RecordType> KitRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Marketing_Kit__c'];
        RecordType Assigned_PreconfiguredKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='IH_Assigned_Preconfigured'){
                Assigned_PreconfiguredKitRT = rt;
            }
        }

        Marketing_Kit__c Assigned_PreconfiguredShoppedKit = new Marketing_Kit__c();
        Assigned_PreconfiguredShoppedKit.RecordTypeId = Assigned_PreconfiguredKitRT.Id;
        Assigned_PreconfiguredShoppedKit.Marketing_Program_Name__c = Program.Id;
        Assigned_PreconfiguredShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        Assigned_PreconfiguredShoppedKit.POC_Spend_Category__c = POCDriverSpCat.Id;
        insert Assigned_PreconfiguredShoppedKit;

        //
        RecordType PreconfiguredKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='IH_Preconfigured'){
                PreconfiguredKitRT = rt;
            }
        }

        Marketing_Kit__c PreconfiguredShoppedKit = new Marketing_Kit__c();
        PreconfiguredShoppedKit.RecordTypeId = PreconfiguredKitRT.Id;
        PreconfiguredShoppedKit.Marketing_Program_Name__c = Program.Id;
        PreconfiguredShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        PreconfiguredShoppedKit.POC_Spend_Category__c = POCDriverSpCat.Id;
        PreconfiguredShoppedKit.Parent_Kit__c = Assigned_PreconfiguredShoppedKit.id;
        insert PreconfiguredShoppedKit;

        Marketing_Item__c MarketingItem = new Marketing_Item__c();
        MarketingItem.Brand__c = b.Id;
        MarketingItem.Temporary_Item_Number__c = '12313';
        MarketingItem.Item_Number__c = '12312313';
        MarketingItem.Price__c = 5;
        MarketingItem.Marketing_Type__c = 'Driver';
        MarketingItem.IH_Item_Classification__c = 'In Store Driver';
        insert MarketingItem;

        Marketing_Program_Item__c ProgramItem = new Marketing_Program_Item__c();
        ProgramItem.Marketing_Program__c = Program.Id;
        ProgramItem.Marketing_Item__c = MarketingItem.Id;
        insert ProgramItem;

        Trade_Activation_Kit_Item__c tradeActivationKitItem = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem.Marketing_Kit__c = Assigned_PreconfiguredShoppedKit.id;
        tradeActivationKitItem.Quantity__c = 1;
        insert tradeActivationKitItem;

        Trade_Activation_Kit_Item__c tradeActivationKitItem2 = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem2.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem2.Marketing_Kit__c = PreconfiguredShoppedKit.id;
        tradeActivationKitItem2.Quantity__c = 1;
        insert tradeActivationKitItem2;

        OnPoint_District__c distr = new OnPoint_District__c();
        distr.District_Description__c = 'TestRegion';
        insert distr;

        OnPlan_Program_Restriction__c onplanprogramrestr = new OnPlan_Program_Restriction__c();
        onplanprogramrestr.Program__c = Program.id;
        onplanprogramrestr.OnPoint_District__c = distr.id;
        insert onplanprogramrestr;

        system.debug('11111111111111 ' + onplanprogramrestr.OnPoint_Region_Description__c);

        test.StartTest();
        POCPlanningApp.IHProgramming(POCDriverSpCat.Id,'TestRegion');
        test.StopTest();
    }
     @isTest static void test_POCList(){

        String Year = String.valueOf(Date.today().year());

        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'TestRegion';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;

        String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
        insert a;

        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c' AND DeveloperName = 'Territory'].id;
        insert AnnualAreaBudget;
        
        RecordType TABrandRecordType = [Select Id From RecordType Where SObjectType = 'Brand__c' And DeveloperName = 'Trade_Activation' Limit 1];

        Brand__c b = new Brand__c();
        b.Name = 'Test Brand';
        b.Is_IH_Only__c = false;
        b.RecordTypeId = TABrandRecordType.Id;
        insert b;

        Annual_Brand_Area_Budget_Plan__c AnnualBrandAreaBudget = new Annual_Brand_Area_Budget_Plan__c();
        AnnualBrandAreaBudget.Annual_Area_Budget__c = AnnualAreaBudget.Id;
        AnnualBrandAreaBudget.Brand__c = b.Id;
        AnnualBrandAreaBudget.Brand_Budget__c = 0;
        insert AnnualBrandAreaBudget;

        Marketing_Program__c Program = new Marketing_Program__c();
        Program.Name = 'TestProgram';
        Program.Brand__c = b.Id;
        Program.Program_End_Date__c = date.today().addDays(2);
        insert Program;

        List<RecordType> KitRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Marketing_Kit__c'];
        RecordType CustomKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Custom'){
                CustomKitRT = rt;
            }
        }

        Annual_POC_Budget_Plan__c TerritoryPOC = new Annual_POC_Budget_Plan__c();
        TerritoryPOC.Account__c = a.Id;
        TerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
        insert TerritoryPOC;

        Id taRecordTypeId = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Programming').getRecordTypeId();
        POC_Spend_Category__c POCTASpCat = new POC_Spend_Category__c();
        POCTASpCat.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCTASpCat.RecordTypeId = taRecordTypeId;
        insert POCTASpCat;

        Marketing_Kit__c CustomShoppedKit = new Marketing_Kit__c();
        CustomShoppedKit.RecordTypeId = CustomKitRT.Id;
        CustomShoppedKit.Marketing_Program_Name__c = Program.Id;
        CustomShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        CustomShoppedKit.Qty__c = 2;
        CustomShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        insert CustomShoppedKit;

        Marketing_Item__c MarketingItem = new Marketing_Item__c();
        MarketingItem.Brand__c = b.Id;
        MarketingItem.Temporary_Item_Number__c = '12313';
        MarketingItem.Item_Number__c = '12312313';
        MarketingItem.Price__c = 5;
        MarketingItem.Marketing_Type__c = 'Driver';
        MarketingItem.IH_Item_Classification__c = 'In Store Driver';
        insert MarketingItem;

        Marketing_Program_Item__c ProgramItem = new Marketing_Program_Item__c();
        ProgramItem.Marketing_Program__c = Program.Id;
        ProgramItem.Marketing_Item__c = MarketingItem.Id;
        insert ProgramItem;

        Trade_Activation_Kit_Item__c tradeActivationKitItem = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem.Marketing_Kit__c = CustomShoppedKit.id;
        tradeActivationKitItem.Quantity__c = 1;
        insert tradeActivationKitItem;

        test.StartTest();
        POCPlanningApp.POCList(AnnualAreaBudget.Id);
        test.StopTest();
    }
    @isTest static void test_TradeActivationVis(){
        
         Restricated_Brand__c roObject= new Restricated_Brand__c();
		roObject.Brand_Name__c='Test';
        insert roObject;
        
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'TestRegion';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;
        
        List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c'];
        RecordType IHTerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'IH_Territory'){
                IHTerritoryRT = rt;
                break;
            }
        }
        
        Integer Year = Integer.valueOf(Date.today().year());

        RecordType TerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                TerritoryRT = rt;
                break;
            }
        }

        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = TerritoryRT.Id;
        insert AnnualAreaBudget;
        
        String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
        insert a;

        Annual_POC_Budget_Plan__c TerritoryPOC = new Annual_POC_Budget_Plan__c();
        TerritoryPOC.Account__c = a.Id;
        TerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
        insert TerritoryPOC;
        
        RecordType TABrandRecordType = [Select Id From RecordType Where SObjectType = 'Brand__c' And DeveloperName = 'Trade_Activation' Limit 1];

        Brand__c b = new Brand__c();
        b.Name = 'Test Brand';
        b.Is_IH_Only__c = false;
        b.RecordTypeId = TABrandRecordType.Id;
        insert b;

        Annual_Brand_Area_Budget_Plan__c AnnualBrandAreaBudget = new Annual_Brand_Area_Budget_Plan__c();
        AnnualBrandAreaBudget.Annual_Area_Budget__c = AnnualAreaBudget.Id;
        AnnualBrandAreaBudget.Brand__c = b.Id;
        AnnualBrandAreaBudget.Brand_Budget__c = 0;
        insert AnnualBrandAreaBudget;

        Id taRecordTypeId = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Programming').getRecordTypeId();
        POC_Spend_Category__c POCTASpCat = new POC_Spend_Category__c();
        POCTASpCat.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCTASpCat.RecordTypeId = taRecordTypeId;
        insert POCTASpCat;

        Marketing_Program__c Program = new Marketing_Program__c();
        Program.Name = 'TestProgram';
        Program.Brand__c = b.Id;
        Program.Program_End_Date__c = date.today().addDays(2);
        insert Program;

        List<RecordType> KitRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Marketing_Kit__c'];
        RecordType CustomKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Custom'){
                CustomKitRT = rt;
            }
        }

        Marketing_Kit__c CustomShoppedKit = new Marketing_Kit__c();
        CustomShoppedKit.RecordTypeId = CustomKitRT.Id;
        CustomShoppedKit.Marketing_Program_Name__c = Program.Id;
        CustomShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        CustomShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        insert CustomShoppedKit;

        Marketing_Item__c MarketingItem = new Marketing_Item__c();
        MarketingItem.Brand__c = b.Id;
        MarketingItem.Temporary_Item_Number__c = '12313';
        MarketingItem.Item_Number__c = '12312313';
        MarketingItem.Price__c = 5;
        MarketingItem.Marketing_Type__c = 'Visibility';
        MarketingItem.IH_Item_Classification__c = 'In Store Driver';
        insert MarketingItem;

        Marketing_Program_Item__c ProgramItem = new Marketing_Program_Item__c();
        ProgramItem.Marketing_Program__c = Program.Id;
        ProgramItem.Marketing_Item__c = MarketingItem.Id;
        insert ProgramItem;

        Marketing_Program_Item__c ProgramItem2 = new Marketing_Program_Item__c();
        ProgramItem2.Marketing_Program__c = Program.Id;
        ProgramItem2.Marketing_Item__c = MarketingItem.Id;
        insert ProgramItem2;

        List<Trade_Activation_Kit_Item__c> tradeActivationKitItemsList = new List<Trade_Activation_Kit_Item__c>();
        Trade_Activation_Kit_Item__c tradeActivationKitItem = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem.Marketing_Kit__c = CustomShoppedKit.id;
        tradeActivationKitItem.Quantity__c = 1;
        tradeActivationKitItemsList.add(tradeActivationKitItem);

        insert tradeActivationKitItemsList;
        
        OnPoint_District__c distr = new OnPoint_District__c();
        distr.District_Description__c = 'Quebec';
        insert distr;
        
        OnPlan_Product_Restriction__c restriction = new OnPlan_Product_Restriction__c(Item__c=MarketingItem.Id, Name='test', OnPoint_District__c=distr.Id );
        insert restriction;
        
        POC_Planning_Brand_Restriction__c pocBrandRest=new POC_Planning_Brand_Restriction__c();
        pocBrandRest.Budget_Year__c=String.valueOf(Date.today().year());
        pocBrandRest.Restricted_Brands__c='Bud Light, Corona';
        insert pocBrandRest;
        
         String YearNew = String.valueOf(Date.today().year());
        POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Ontario', true,'Out Of Home', YearNew);
        POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Quebec', false,'Out Of Home', YearNew);

        User u = new User();
        u.Id = UserInfo.getUserId();
        u.LanguageLocaleKey = 'fr';
       // update u;

        //POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Ontario', true);
        //POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Quebec', false);
               
    }
    @isTest static void test_TradeActivationPromCanceled(){
         Restricated_Brand__c roObject= new Restricated_Brand__c();
		roObject.Brand_Name__c='Test';
        insert roObject;
        
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'TestRegion';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;
        
        List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c'];
        RecordType IHTerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'IH_Territory'){
                IHTerritoryRT = rt;
                break;
            }
        }
        
        Integer Year = Integer.valueOf(Date.today().year());

        RecordType TerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                TerritoryRT = rt;
                break;
            }
        }

        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = TerritoryRT.Id;
        insert AnnualAreaBudget;
        
        String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
        insert a;

        Annual_POC_Budget_Plan__c TerritoryPOC = new Annual_POC_Budget_Plan__c();
        TerritoryPOC.Account__c = a.Id;
        TerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
        insert TerritoryPOC;
        
        RecordType TABrandRecordType = [Select Id From RecordType Where SObjectType = 'Brand__c' And DeveloperName = 'Trade_Activation' Limit 1];

        Brand__c b = new Brand__c();
        b.Name = 'Test Brand';
        b.Is_IH_Only__c = false;
        b.RecordTypeId = TABrandRecordType.Id;
        insert b;
        Brand__c b2 = new Brand__c();
        b2.Name = 'Test Brand2';
        b2.Is_IH_Only__c = false;
        b2.RecordTypeId = TABrandRecordType.Id;
        insert b2;

        Annual_Brand_Area_Budget_Plan__c AnnualBrandAreaBudget = new Annual_Brand_Area_Budget_Plan__c();
        AnnualBrandAreaBudget.Annual_Area_Budget__c = AnnualAreaBudget.Id;
        AnnualBrandAreaBudget.Brand__c = b.Id;
        AnnualBrandAreaBudget.Brand_Budget__c = 0;
        insert AnnualBrandAreaBudget;


        Id taRecordTypeId = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Programming').getRecordTypeId();
        POC_Spend_Category__c POCTASpCat = new POC_Spend_Category__c();
        POCTASpCat.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCTASpCat.RecordTypeId = taRecordTypeId;
        insert POCTASpCat;

        Marketing_Program__c Program = new Marketing_Program__c();
        Program.Name = 'TestProgram';
        Program.Brand__c = b.Id;
        Program.Program_End_Date__c = date.today().addDays(2);
        insert Program;

        Marketing_Program__c ProgramOne = new Marketing_Program__c();
        ProgramOne.Brand__c = b.Id;

        Marketing_Program__c ProgramTwo = new Marketing_Program__c();
        ProgramTwo.Brand__c = b2.Id;
        List<Marketing_Program__c> listOfPrograms = new List<Marketing_Program__c>{ProgramOne, ProgramTwo};
        insert listOfPrograms;

        List<RecordType> KitRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Marketing_Kit__c'];
        RecordType CustomKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Custom'){
                CustomKitRT = rt;
            }
        }

        Marketing_Kit__c CustomShoppedKit = new Marketing_Kit__c();
        CustomShoppedKit.RecordTypeId = CustomKitRT.Id;
        CustomShoppedKit.Marketing_Program_Name__c = Program.Id;
        CustomShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        CustomShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        insert CustomShoppedKit;

        Marketing_Item__c MarketingItem = new Marketing_Item__c();
        MarketingItem.Brand__c = b.Id;
        MarketingItem.Temporary_Item_Number__c = '12313';
        MarketingItem.Item_Number__c = '12312313';
        MarketingItem.Price__c = 5;
        MarketingItem.Is_Cancelled__c = true;
        MarketingItem.Marketing_Type__c = 'Driver';
        MarketingItem.IH_Item_Classification__c = 'In Store Driver';
        insert MarketingItem;

        Marketing_Item__c marketingItemOne = new Marketing_Item__c();
        marketingItemOne.Brand__c = b.Id;
        marketingItemOne.Temporary_Item_Number__c = '123123';
        marketingItemOne.Item_Number__c = '123123123';
        marketingItemOne.Price__c = 5;
        marketingItemOne.Marketing_Type__c = 'Driver';
        Marketing_Item__c marketingItemTwo = new Marketing_Item__c();
        marketingItemTwo.Brand__c = b.Id;
        marketingItemTwo.Temporary_Item_Number__c = '456456';
        marketingItemTwo.Item_Number__c = '456456456';
        marketingItemTwo.Price__c = 10;
        marketingItemTwo.Marketing_Type__c = 'Visibility';
        marketingItemTwo.IH_Item_Classification__c = 'In Store Driver';

        Marketing_Item__c marketingItemThree = new Marketing_Item__c();
        marketingItemThree.Brand__c = b.Id;
        marketingItemThree.Temporary_Item_Number__c = '4564568';
        marketingItemThree.Item_Number__c = '4564564568';
        marketingItemThree.Price__c = 10;
        marketingItemThree.Marketing_Type__c = 'Promotional';
        marketingItemThree.IH_Item_Classification__c = 'In Store Driver';

        Marketing_Item__c marketingItemOneB2 = new Marketing_Item__c();
        marketingItemOneB2.Brand__c = b2.Id;
        marketingItemOneB2.Temporary_Item_Number__c = '1231232';
        marketingItemOneB2.Item_Number__c = '1231231232';
        marketingItemOneB2.Price__c = 5;
        marketingItemOneB2.Marketing_Type__c = 'Driver';

        List<Marketing_Item__c> listOfMarketingItems = new List<Marketing_Item__c>{marketingItemOne, marketingItemTwo, marketingItemThree, marketingItemOneB2};
        insert listOfMarketingItems;

        Marketing_Program_Item__c marketingProgramItemOne = new Marketing_Program_Item__c();
        marketingProgramItemOne.Marketing_Program__c = Program.Id;
        marketingProgramItemOne.Marketing_Item__c = marketingItemOne.Id;
        Marketing_Program_Item__c marketingProgramItemTwo = new Marketing_Program_Item__c();
        marketingProgramItemTwo.Marketing_Program__c = Program.Id;
        marketingProgramItemTwo.Marketing_Item__c = marketingItemTwo.Id;

        Marketing_Program_Item__c marketingProgramItemThree = new Marketing_Program_Item__c();
        marketingProgramItemThree.Marketing_Program__c = Program.Id;
        marketingProgramItemThree.Marketing_Item__c = marketingItemThree.Id;

        Marketing_Program_Item__c marketingProgramItemOneP1 = new Marketing_Program_Item__c();
        marketingProgramItemOneP1.Marketing_Program__c = ProgramOne.Id;
        marketingProgramItemOneP1.Marketing_Item__c = marketingItemOne.Id;

        Marketing_Program_Item__c marketingProgramItemOneP2 = new Marketing_Program_Item__c();
        marketingProgramItemOneP2.Marketing_Program__c = ProgramTwo.Id;
        marketingProgramItemOneP2.Marketing_Item__c = marketingItemOneB2.Id;

        List<Marketing_Program_Item__c> listOfMarketingProgramItems = new List<Marketing_Program_Item__c>{marketingProgramItemOne, marketingProgramItemTwo, marketingProgramItemThree, marketingProgramItemOneP1, marketingProgramItemOneP2};
        insert listOfMarketingProgramItems;

        Marketing_Program_Item__c ProgramItem = new Marketing_Program_Item__c();
        ProgramItem.Marketing_Program__c = Program.Id;
        ProgramItem.Marketing_Item__c = MarketingItem.Id;
        insert ProgramItem;



        List<Trade_Activation_Kit_Item__c> tradeActivationKitItemsList = new List<Trade_Activation_Kit_Item__c>();
        Trade_Activation_Kit_Item__c tradeActivationKitItem = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem.Marketing_Kit__c = CustomShoppedKit.id;
        tradeActivationKitItem.Quantity__c = 1;
        tradeActivationKitItemsList.add(tradeActivationKitItem);
        
        insert tradeActivationKitItemsList;

        User u = new User();
        u.Id = UserInfo.getUserId();
        u.LanguageLocaleKey = 'fr';
       // update u;

        //POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Ontario', true);
        //POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Quebec', false);


    }
     @isTest static void test_TradeActivationPromCanceledVis(){
         
          Restricated_Brand__c roObject= new Restricated_Brand__c();
		roObject.Brand_Name__c='Test';
        insert roObject;
         
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'TestRegion';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;
        
        List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c'];
        RecordType IHTerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'IH_Territory'){
                IHTerritoryRT = rt;
                break;
            }
        }
        
        Integer Year = Integer.valueOf(Date.today().year());

        RecordType TerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                TerritoryRT = rt;
                break;
            }
        }

        Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = TerritoryRT.Id;
        insert AnnualAreaBudget;
        
        String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
        insert a;

        Annual_POC_Budget_Plan__c TerritoryPOC = new Annual_POC_Budget_Plan__c();
        TerritoryPOC.Account__c = a.Id;
        TerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
        insert TerritoryPOC;
        
        RecordType TABrandRecordType = [Select Id From RecordType Where SObjectType = 'Brand__c' And DeveloperName = 'Trade_Activation' Limit 1];

        Brand__c b = new Brand__c();
        b.Name = 'Test Brand';
        b.Is_IH_Only__c = false;
        b.RecordTypeId = TABrandRecordType.Id;
        insert b;
        Brand__c b2 = new Brand__c();
        b2.Name = 'Test Brand2';
        b2.Is_IH_Only__c = false;
        b2.RecordTypeId = TABrandRecordType.Id;
        insert b2;

        Annual_Brand_Area_Budget_Plan__c AnnualBrandAreaBudget = new Annual_Brand_Area_Budget_Plan__c();
        AnnualBrandAreaBudget.Annual_Area_Budget__c = AnnualAreaBudget.Id;
        AnnualBrandAreaBudget.Brand__c = b.Id;
        AnnualBrandAreaBudget.Brand_Budget__c = 0;
        insert AnnualBrandAreaBudget;


        Id taRecordTypeId = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Programming').getRecordTypeId();
        POC_Spend_Category__c POCTASpCat = new POC_Spend_Category__c();
        POCTASpCat.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCTASpCat.RecordTypeId = taRecordTypeId;
        insert POCTASpCat;

        Marketing_Program__c Program = new Marketing_Program__c();
        Program.Name = 'TestProgram';
        Program.Brand__c = b.Id;
        Program.Program_End_Date__c = date.today().addDays(2);
        insert Program;

        Marketing_Program__c ProgramOne = new Marketing_Program__c();
        ProgramOne.Brand__c = b.Id;

        Marketing_Program__c ProgramTwo = new Marketing_Program__c();
        ProgramTwo.Brand__c = b2.Id;
        List<Marketing_Program__c> listOfPrograms = new List<Marketing_Program__c>{ProgramOne, ProgramTwo};
        insert listOfPrograms;

        List<RecordType> KitRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Marketing_Kit__c'];
        RecordType CustomKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Custom'){
                CustomKitRT = rt;
            }
        }

        Marketing_Kit__c CustomShoppedKit = new Marketing_Kit__c();
        CustomShoppedKit.RecordTypeId = CustomKitRT.Id;
        CustomShoppedKit.Marketing_Program_Name__c = Program.Id;
        CustomShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        CustomShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        insert CustomShoppedKit;

        Marketing_Item__c MarketingItem = new Marketing_Item__c();
        MarketingItem.Brand__c = b.Id;
        MarketingItem.Temporary_Item_Number__c = '12313';
        MarketingItem.Item_Number__c = '12312313';
        MarketingItem.Price__c = 5;
        MarketingItem.Is_Cancelled__c = true;
        MarketingItem.Marketing_Type__c = 'Promotional';
        MarketingItem.IH_Item_Classification__c = 'In Store Driver';
        insert MarketingItem;

        Marketing_Item__c marketingItemOne = new Marketing_Item__c();
        marketingItemOne.Brand__c = b.Id;
        marketingItemOne.Temporary_Item_Number__c = '123123';
        marketingItemOne.Item_Number__c = '123123123';
        marketingItemOne.Price__c = 5;
        marketingItemOne.Marketing_Type__c = 'Driver';
        Marketing_Item__c marketingItemTwo = new Marketing_Item__c();
        marketingItemTwo.Brand__c = b.Id;
        marketingItemTwo.Temporary_Item_Number__c = '456456';
        marketingItemTwo.Item_Number__c = '456456456';
        marketingItemTwo.Price__c = 10;
        marketingItemTwo.Marketing_Type__c = 'Visibility';
        marketingItemTwo.IH_Item_Classification__c = 'In Store Driver';

        List<Marketing_Item__c> listOfMarketingItems = new List<Marketing_Item__c>{marketingItemOne, marketingItemTwo};
        insert listOfMarketingItems;

        Marketing_Program_Item__c marketingProgramItemOne = new Marketing_Program_Item__c();
        marketingProgramItemOne.Marketing_Program__c = Program.Id;
        marketingProgramItemOne.Marketing_Item__c = marketingItemOne.Id;
        Marketing_Program_Item__c marketingProgramItemTwo = new Marketing_Program_Item__c();
        marketingProgramItemTwo.Marketing_Program__c = Program.Id;
        marketingProgramItemTwo.Marketing_Item__c = marketingItemTwo.Id;

        Marketing_Program_Item__c marketingProgramItemOneP1 = new Marketing_Program_Item__c();
        marketingProgramItemOneP1.Marketing_Program__c = ProgramOne.Id;
        marketingProgramItemOneP1.Marketing_Item__c = marketingItemOne.Id;

        List<Marketing_Program_Item__c> listOfMarketingProgramItems = new List<Marketing_Program_Item__c>{marketingProgramItemOne, marketingProgramItemTwo, marketingProgramItemOneP1};
        insert listOfMarketingProgramItems;

        Marketing_Program_Item__c ProgramItem = new Marketing_Program_Item__c();
        ProgramItem.Marketing_Program__c = Program.Id;
        ProgramItem.Marketing_Item__c = MarketingItem.Id;
        insert ProgramItem;



        List<Trade_Activation_Kit_Item__c> tradeActivationKitItemsList = new List<Trade_Activation_Kit_Item__c>();
        Trade_Activation_Kit_Item__c tradeActivationKitItem = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem.Marketing_Kit__c = CustomShoppedKit.id;
        tradeActivationKitItem.Quantity__c = 1;
        tradeActivationKitItemsList.add(tradeActivationKitItem);
        
        insert tradeActivationKitItemsList;
         
         POC_Planning_Brand_Restriction__c pocBrandRest=new POC_Planning_Brand_Restriction__c();
        pocBrandRest.Budget_Year__c=String.valueOf(Date.today().year());
        pocBrandRest.Restricted_Brands__c='Bud Light, Corona';
        insert pocBrandRest;
         
		String YearNew = String.valueOf(Date.today().year());
        POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Ontario', true,'Out Of Home', YearNew);
        POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Quebec', false,'Out Of Home', YearNew);

    }
    @isTest static void test_AnnualPOCBudgetPlanTrigger(){
    
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'Quebec';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;
        
        List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Annual_Area_Budget__c'];
        RecordType IHTerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'IH_Territory'){
                IHTerritoryRT = rt;
                break;
            }
        }
        
        Integer Year = Integer.valueOf(Date.today().year());
        Annual_Area_Budget__c AnnualAreaBudgetIH = new Annual_Area_Budget__c();
        AnnualAreaBudgetIH.Sales_Territory__c = SalesTerritory.Id;
        AnnualAreaBudgetIH.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudgetIH.RecordTypeId = IHTerritoryRT.Id;
        insert AnnualAreaBudgetIH;
                
        String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
        insert a;
        
        On_Plan_CAP__c plancap = new On_Plan_CAP__c();
        plancap.Year_of_CAP_program__c = String.valueOf(Year);
        plancap.Region_ID__c = 'TestRegionId';
        plancap.Name = '2017-Atlantic-Bronze';
        plancap.Cap_Eligible__c = 'Bronze';
        plancap.CAP_Tier_Value__c = 5;
        /*plancap.Custom_Drink_List__c = true;
        plancap.Food_Pairing_Feature__c = true;
        plancap.Labatt_Branded_Glassware__c = true;
        plancap.Labatt_Large_Tap_Handles__c = true;
        plancap.Weekly_Feature_PTC__c = true;
        plancap.Maximum_Regional_Investment_Threshold__c = 1;
        plancap.Minimum_Target_Volume__c = 5;
        plancap.Minimum_Number_of_Labatt_Lines__c = 5;
        plancap.Quebec_CAP_criteria__c = 'Exclusif 100%';*/
        insert plancap;
        
        Annual_POC_Budget_Plan__c IHTerritoryPOC = new Annual_POC_Budget_Plan__c();
        IHTerritoryPOC.Account__c = a.Id;
        IHTerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudgetIH.Id;
        IHTerritoryPOC.RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Annual_POC_Budget_Plan__c' And DeveloperName =: 'OOH_POC_Budget_Plan' Limit 1].Id;
        
        
        lboc_Sales_Territory__c SalesTerritory2 = new lboc_Sales_Territory__c();
        SalesTerritory2.Name = 'TestST';
        SalesTerritory2.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory2.lboc_Region__c = 'QUEBEC (Region)';
        SalesTerritory2.lboc_Region_ID__c = 'QUEBEC (Region)';
        insert SalesTerritory2;
        
        Annual_Area_Budget__c AnnualAreaBudgetIH2 = new Annual_Area_Budget__c();
        AnnualAreaBudgetIH2.Sales_Territory__c = SalesTerritory2.Id;
        AnnualAreaBudgetIH2.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudgetIH2.RecordTypeId = IHTerritoryRT.Id;
        insert AnnualAreaBudgetIH2;
        
        Annual_POC_Budget_Plan__c IHTerritoryPOC2 = new Annual_POC_Budget_Plan__c();
        IHTerritoryPOC2.Account__c = a.Id;
        IHTerritoryPOC2.Annual_Territory_Budget__c = AnnualAreaBudgetIH2.Id;
        IHTerritoryPOC2.RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Annual_POC_Budget_Plan__c' And DeveloperName =: 'OOH_POC_Budget_Plan' Limit 1].Id;
        List<Annual_POC_Budget_Plan__c> listOfPOCbudgets = new List<Annual_POC_Budget_Plan__c>{IHTerritoryPOC2, IHTerritoryPOC};
        insert listOfPOCbudgets ;
    }@isTest static void getPOCSpendCategoryIDs() {
        
        Restricated_Brand__c roObject= new Restricated_Brand__c();
		roObject.Brand_Name__c='Test';
        insert roObject;
    
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'Quebec';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
        insert SalesTerritory;
        
        Id IHTerritoryRT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('IH Territory').getRecordTypeId();        
        Id TerritoryRT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        //Id TerritoryRT1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Territory').getRecordTypeId();
       // RecordType IHTerritoryRT = new RecordType();

        /*for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'IH_Territory'){
                IHTerritoryRT = rt;
                break;
            }
        }*/
              
        Integer Year = Integer.valueOf(Date.today().year());
        Annual_Area_Budget__c AnnualAreaBudgetIH = new Annual_Area_Budget__c();
        AnnualAreaBudgetIH.Sales_Territory__c = SalesTerritory.Id;
        AnnualAreaBudgetIH.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudgetIH.RecordTypeId = IHTerritoryRT;
        insert AnnualAreaBudgetIH;

       /* RecordType TerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                TerritoryRT = rt;
                break;
            }
        }*/
        

         Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = TerritoryRT;
        insert AnnualAreaBudget;
        
        //String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;
        //System.debug('@@@@.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
        //system.debug('@@@@ RecordTypeId1: '+RecordTypeId1);

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
        insert a;
    
        Annual_POC_Budget_Plan__c IHTerritoryPOC = new Annual_POC_Budget_Plan__c();
        IHTerritoryPOC.Account__c = a.Id;
        IHTerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudgetIH.Id;
        insert IHTerritoryPOC;

        Annual_POC_Budget_Plan__c TerritoryPOC = new Annual_POC_Budget_Plan__c();
        TerritoryPOC.Account__c = a.Id;
        TerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
        insert TerritoryPOC;
        
        Id TABrandRecordType = Schema.SObjectType.Brand__c.getRecordTypeInfosByName().get('Trade Activation').getRecordTypeId();
        
        Brand__c b = new Brand__c();
        b.Name = 'Test Brand';
        b.Is_IH_Only__c = false;
        b.RecordTypeId = TABrandRecordType;
        insert b;

        Annual_Brand_Area_Budget_Plan__c AnnualBrandAreaBudget = new Annual_Brand_Area_Budget_Plan__c();
        AnnualBrandAreaBudget.Annual_Area_Budget__c = AnnualAreaBudget.Id;
        AnnualBrandAreaBudget.Brand__c = b.Id;
        AnnualBrandAreaBudget.Brand_Budget__c = 0;
        insert AnnualBrandAreaBudget;


        Id taRecordTypeId = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Programming').getRecordTypeId();
        POC_Spend_Category__c POCTASpCat = new POC_Spend_Category__c();
        POCTASpCat.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCTASpCat.RecordTypeId = taRecordTypeId;
        insert POCTASpCat;

        Marketing_Program__c Program = new Marketing_Program__c();
        Program.Name = 'TestProgram';
        Program.Brand__c = b.Id;
        Program.Program_End_Date__c = date.today().addDays(2);
        Program.Planning_End_Date__c = date.today().addDays(2);
        insert Program;

        //List<RecordType> KitRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Marketing_Kit__c'];
        Id CustomKitRT = Schema.SObjectType.Marketing_Kit__c.getRecordTypeInfosByName().get('Custom').getRecordTypeId();
        Id Assigned_PreconfiguredKitRT = Schema.SObjectType.Marketing_Kit__c.getRecordTypeInfosByName().get('Assigned Preconfigured').getRecordTypeId();
        Id PreconfiguredKitRT = Schema.SObjectType.Marketing_Kit__c.getRecordTypeInfosByName().get('Preconfigured').getRecordTypeId();
        
       /* RecordType CustomKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Custom'){
                CustomKitRT = rt;
            }
        }*/
        
        Marketing_Kit__c CustomShoppedKit = new Marketing_Kit__c();
        CustomShoppedKit.RecordTypeId = CustomKitRT;
        CustomShoppedKit.Marketing_Program_Name__c = Program.Id;
        CustomShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        CustomShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        CustomShoppedKit.Qty__c = 2;
        
       /* RecordType Assigned_PreconfiguredKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Assigned_Preconfigured'){
                Assigned_PreconfiguredKitRT = rt;
            }
        }*/
        
        Marketing_Kit__c Assigned_PreconfiguredShoppedKit = new Marketing_Kit__c();
        Assigned_PreconfiguredShoppedKit.RecordTypeId = Assigned_PreconfiguredKitRT;
        Assigned_PreconfiguredShoppedKit.Marketing_Program_Name__c = Program.Id;
        Assigned_PreconfiguredShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        Assigned_PreconfiguredShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        Assigned_PreconfiguredShoppedKit.Qty__c = 2;
        
        /*RecordType PreconfiguredKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Preconfigured'){
                PreconfiguredKitRT = rt;
            }
        }*/
        
        Marketing_Kit__c PreconfiguredShoppedKit = new Marketing_Kit__c();
        PreconfiguredShoppedKit.RecordTypeId = PreconfiguredKitRT;
        PreconfiguredShoppedKit.Marketing_Program_Name__c = Program.Id;
        PreconfiguredShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        PreconfiguredShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        PreconfiguredShoppedKit.Qty__c = 2;
        List<Marketing_Kit__c> ListOfPMarketingKits = new List<Marketing_Kit__c>{PreconfiguredShoppedKit, Assigned_PreconfiguredShoppedKit, CustomShoppedKit};
        insert ListOfPMarketingKits;


        Marketing_Item__c MarketingItem = new Marketing_Item__c();
        MarketingItem.Brand__c = b.Id;
        MarketingItem.Temporary_Item_Number__c = '12313';
        MarketingItem.Item_Number__c = '12312313';
        MarketingItem.Price__c = 5;
        MarketingItem.Marketing_Type__c = 'Driver';
        MarketingItem.IH_Item_Classification__c = 'In Store Driver';
        insert MarketingItem;

        Area_Item_Inventory__c AreaItem = new Area_Item_Inventory__c();
        AreaItem.Labatt_Region__c = 'Quebec';
        AreaItem.Marketing_Item__c = MarketingItem.id;
        AreaItem.Quantity_Allocated_to_Area__c = 123;
        insert AreaItem;

        Marketing_Program_Item__c ProgramItem = new Marketing_Program_Item__c();
        ProgramItem.Marketing_Program__c = Program.Id;
        ProgramItem.Marketing_Item__c = MarketingItem.Id;

        Marketing_Program_Item__c ProgramItem2 = new Marketing_Program_Item__c();
        ProgramItem2.Marketing_Program__c = Program.Id;
        ProgramItem2.Marketing_Item__c = MarketingItem.Id;
        List<Marketing_Program_Item__c> ListOfPrograItem = new List<Marketing_Program_Item__c>{ProgramItem, ProgramItem2};
        insert ListOfPrograItem;

        List<Trade_Activation_Kit_Item__c> tradeActivationKitItemsList = new List<Trade_Activation_Kit_Item__c>();
        Trade_Activation_Kit_Item__c tradeActivationKitItem = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem.Marketing_Kit__c = Assigned_PreconfiguredShoppedKit.id;
        tradeActivationKitItem.Quantity__c = 1;
        tradeActivationKitItemsList.add(tradeActivationKitItem);

        Trade_Activation_Kit_Item__c tradeActivationKitItem2 = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem2.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem2.Marketing_Kit__c = PreconfiguredShoppedKit.id;
        tradeActivationKitItem2.Quantity__c = 1;
        tradeActivationKitItemsList.add(tradeActivationKitItem2);

        Trade_Activation_Kit_Item__c tradeActivationKitItem4 = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem4.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem4.Marketing_Kit__c = PreconfiguredShoppedKit.id;
        tradeActivationKitItem4.Quantity__c = 1;
        tradeActivationKitItemsList.add(tradeActivationKitItem4);

        Trade_Activation_Kit_Item__c tradeActivationKitItem3 = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem3.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem3.Marketing_Kit__c = CustomShoppedKit.id;
        tradeActivationKitItem3.Quantity__c = 1;
        tradeActivationKitItem3.Marketing_Type__c = 'Visibility';
        tradeActivationKitItem3.Item_Spend__c = 12;
        tradeActivationKitItemsList.add(tradeActivationKitItem3);
        
        insert tradeActivationKitItemsList;
        
        
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        Attachment AttachOne = new Attachment();
        AttachOne.Name = 'Sales_Sheet_FR';
        AttachOne.body = bodyBlob;
        AttachOne.parentId = Program.Id;
        Attachment AttachTwo = new Attachment();

        AttachTwo.Name = 'Sales_Sheet_EN';
        AttachTwo.body = bodyBlob;
        AttachTwo.parentId = Program.Id;

        List<Attachment> ListOfAttach= new List<Attachment>{AttachOne, AttachTwo};
        //insert ListOfAttach;

        test.startTest();
        
        POCPlanningApp.getPOCSpendCategoryIDs(IHTerritoryPOC.Id);
        //updatePOCBudgetPlanTier
        POCPlanningApp.updatePOCBudgetPlanTier('Tier Non-Bud',IHTerritoryPOC.Id);
        //test_UpdateTerritoryPOC
        POCPlanningApp.UpdateTerritoryPOC(TerritoryPOC.Id, 1000, 1000);
        //test_POCBudget
        POCPlanningApp.POCBudget(TerritoryPOC.Id);
        //
        POCPlanningApp.Driver(TerritoryPOC.Id,false);
        //test_TradeActivation
        
        POC_Planning_Brand_Restriction__c pocBrandRest=new POC_Planning_Brand_Restriction__c();
        pocBrandRest.Budget_Year__c=String.valueOf(Date.today().year());
        pocBrandRest.Restricted_Brands__c='Bud Light, Corona';
        insert pocBrandRest;
        
        
        String YearNew = String.valueOf(Date.today().year());

        POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Ontario', true,'Out Of Home', YearNew);
        POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Quebec', false,'Out Of Home', YearNew);

        User u = new User();
        u.Id = UserInfo.getUserId();
        u.LanguageLocaleKey = 'fr';
     //   update u;
        MarketingItem.Is_Cancelled__c = True;
        update MarketingItem;

       // POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Ontario', true);
        //POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Quebec', false);

        //test_CreateTAKit
        Date Today = date.today(); 
        POCPlanningApp.CreateTAKit('dfgjkhslfdjhkgjsdfgjkhlhsdfjkhlgjhksdfgjhksdfjkhlgjksdfgjkhsdfjkhgsdsdfsdijqweiodsdjkhfasjkdlfgklsdfgklj', POCTASpCat.Id, AnnualBrandAreaBudget.Id, Program.Id, Today.year() +'-'+Today.month()+'-'+Today.day(), Today.year()+'-'+Today.month()+'-'+Today.day(), 'Custom', null, 0);
        POCPlanningApp.CreateTAKit('TestKit', POCTASpCat.Id, AnnualBrandAreaBudget.Id, Program.Id, Today.year()+'-'+Today.month()+'-'+Today.day(), Today.year()+'-'+Today.month()+'-'+Today.day(), 'Custom', null, null);
       
       
        POCTASpCat.RecordTypeId=[Select Id, DeveloperName From RecordType Where SObjectType = 'POC_Spend_Category__c' AND DeveloperName='In_Store_Driver_In_Home' LIMIT 1].Id;
        update POCTASpCat;
        POCPlanningApp.OnDriverChange('111111', MarketingItem.Id, 1,2, false, POCTASpCat.Id, null, false, 'Ontario');
        
    }
     @isTest static void getPOCSpendCategoryIDsTest() {
         Restricated_Brand__c roObject= new Restricated_Brand__c();
		roObject.Brand_Name__c='Test';
        insert roObject;
         
    	Id DistrictRT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH District').getRecordTypeId();
        Integer Year1 = Integer.valueOf(Date.today().year());
        Annual_Area_Budget__c AnnualAreaBudgetOD = new Annual_Area_Budget__c();
        //AnnualAreaBudgetIH.Sales_Territory__c = SalesTerritory.Id;
        AnnualAreaBudgetOD.Budget_Year__c = String.valueOf(Year1);
        AnnualAreaBudgetOD.RecordTypeId = DistrictRT;
        AnnualAreaBudgetOD.District_Name__c='National';
        //insert AnnualAreaBudgetOD;
         
        lboc_Sales_Territory__c SalesTerritory = new lboc_Sales_Territory__c();
        SalesTerritory.Name = 'TestST';
        SalesTerritory.lboc_District_ID__c = 'TestDistrictId';
        SalesTerritory.lboc_Region__c = 'Quebec';
        SalesTerritory.lboc_Region_ID__c = 'TestRegionId';
         SalesTerritory.Back_Office_Territory__c=true;
        SalesTerritory.OwnerId=UserInfo.getUserId();
        SalesTerritory.lboc_Territory_ID__c='694312';
        insert SalesTerritory;
        
        Id IHTerritoryRT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('IH Territory').getRecordTypeId();        
        Id TerritoryRT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        //Id TerritoryRT1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Territory').getRecordTypeId();
       // RecordType IHTerritoryRT = new RecordType();

        /*for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'IH_Territory'){
                IHTerritoryRT = rt;
                break;
            }
        }*/
              
        Integer Year = Integer.valueOf(Date.today().year());
        Annual_Area_Budget__c AnnualAreaBudgetIH = new Annual_Area_Budget__c();
        AnnualAreaBudgetIH.Sales_Territory__c = SalesTerritory.Id;
        AnnualAreaBudgetIH.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudgetIH.RecordTypeId = IHTerritoryRT;
        insert AnnualAreaBudgetIH;

       /* RecordType TerritoryRT = new RecordType();

        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                TerritoryRT = rt;
                break;
            }
        }*/
        

         Annual_Area_Budget__c AnnualAreaBudget = new Annual_Area_Budget__c();
        AnnualAreaBudget.Sales_Territory__c = SalesTerritory.id;
        AnnualAreaBudget.Budget_Year__c = String.valueOf(Year);
        AnnualAreaBudget.Assigned_KI_Volume__c = 1000;
        AnnualAreaBudget.RecordTypeId = TerritoryRT;
        insert AnnualAreaBudget;
        
        //String RecordTypeId = [Select Id From RecordType Where SObjectType =: 'Account' And DeveloperName =: 'Outlet' Limit 1].Id;
        //System.debug('@@@@.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
        //system.debug('@@@@ RecordTypeId1: '+RecordTypeId1);

        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = RecordTypeId;
        a.lboc_Sales_Territory__c = SalesTerritory.id;
        a.lboc_Region__c = SalesTerritory.lboc_Region__c;
          a.lboc_Labatt_Outlet_Id__c='694312';
        insert a;
    
        Annual_POC_Budget_Plan__c IHTerritoryPOC = new Annual_POC_Budget_Plan__c();
        IHTerritoryPOC.Account__c = a.Id;
        IHTerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudgetIH.Id;
        insert IHTerritoryPOC;

        Annual_POC_Budget_Plan__c TerritoryPOC = new Annual_POC_Budget_Plan__c();
        TerritoryPOC.Account__c = a.Id;
        TerritoryPOC.Annual_Territory_Budget__c = AnnualAreaBudget.Id;
        insert TerritoryPOC;
        
        Id TABrandRecordType = Schema.SObjectType.Brand__c.getRecordTypeInfosByName().get('Trade Activation').getRecordTypeId();
        
        Brand__c b = new Brand__c();
        b.Name = 'Test Brand';
        b.Is_IH_Only__c = false;
        b.RecordTypeId = TABrandRecordType;
        insert b;

        Annual_Brand_Area_Budget_Plan__c AnnualBrandAreaBudget = new Annual_Brand_Area_Budget_Plan__c();
        AnnualBrandAreaBudget.Annual_Area_Budget__c = AnnualAreaBudget.Id;
        AnnualBrandAreaBudget.Brand__c = b.Id;
        AnnualBrandAreaBudget.Brand_Budget__c = 0;
        insert AnnualBrandAreaBudget;


        Id taRecordTypeId = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Programming').getRecordTypeId();
        POC_Spend_Category__c POCTASpCat = new POC_Spend_Category__c();
        POCTASpCat.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCTASpCat.RecordTypeId = taRecordTypeId;
         POCTASpCat.Variable_Spend__c=0;
        insert POCTASpCat;
         
         Id taRecordTypeIdD = Schema.SObjectType.POC_Spend_Category__c.getRecordTypeInfosByName().get('Discretionary').getRecordTypeId();
        POC_Spend_Category__c POCTASpCatD = new POC_Spend_Category__c();
        POCTASpCatD.Annual_POC_Budget_Plan__c = TerritoryPOC.id;
        POCTASpCatD.RecordTypeId = taRecordTypeIdD;
         POCTASpCatD.Variable_Spend__c=0;
        insert POCTASpCatD;

        Marketing_Program__c Program = new Marketing_Program__c();
        Program.Name = 'TestProgram';
        Program.Brand__c = b.Id;
        Program.Program_End_Date__c = date.today().addDays(2);
        Program.Planning_End_Date__c = date.today().addDays(2);
        insert Program;

        //List<RecordType> KitRTList = [Select Id, DeveloperName From RecordType Where SObjectType = 'Marketing_Kit__c'];
        Id CustomKitRT = Schema.SObjectType.Marketing_Kit__c.getRecordTypeInfosByName().get('Custom').getRecordTypeId();
        Id Assigned_PreconfiguredKitRT = Schema.SObjectType.Marketing_Kit__c.getRecordTypeInfosByName().get('Assigned Preconfigured').getRecordTypeId();
        Id PreconfiguredKitRT = Schema.SObjectType.Marketing_Kit__c.getRecordTypeInfosByName().get('Preconfigured').getRecordTypeId();
        
       /* RecordType CustomKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Custom'){
                CustomKitRT = rt;
            }
        }*/
        
        Marketing_Kit__c CustomShoppedKit = new Marketing_Kit__c();
        CustomShoppedKit.RecordTypeId = CustomKitRT;
        CustomShoppedKit.Marketing_Program_Name__c = Program.Id;
        CustomShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        CustomShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        CustomShoppedKit.Qty__c = 2;
        
       /* RecordType Assigned_PreconfiguredKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Assigned_Preconfigured'){
                Assigned_PreconfiguredKitRT = rt;
            }
        }*/
        
        Marketing_Kit__c Assigned_PreconfiguredShoppedKit = new Marketing_Kit__c();
        Assigned_PreconfiguredShoppedKit.RecordTypeId = Assigned_PreconfiguredKitRT;
        Assigned_PreconfiguredShoppedKit.Marketing_Program_Name__c = Program.Id;
        Assigned_PreconfiguredShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        Assigned_PreconfiguredShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        Assigned_PreconfiguredShoppedKit.Qty__c = 2;
        
        /*RecordType PreconfiguredKitRT = new RecordType();
        for(RecordType rt: KitRTList){
            if(rt.DeveloperName =='Preconfigured'){
                PreconfiguredKitRT = rt;
            }
        }*/
        
        Marketing_Kit__c PreconfiguredShoppedKit = new Marketing_Kit__c();
        PreconfiguredShoppedKit.RecordTypeId = PreconfiguredKitRT;
        PreconfiguredShoppedKit.Marketing_Program_Name__c = Program.Id;
        PreconfiguredShoppedKit.Annual_Brand_Area_Budget_Plan__c =  AnnualBrandAreaBudget.Id;
        PreconfiguredShoppedKit.POC_Spend_Category__c = POCTASpCat.Id;
        PreconfiguredShoppedKit.Qty__c = 2;
        List<Marketing_Kit__c> ListOfPMarketingKits = new List<Marketing_Kit__c>{PreconfiguredShoppedKit, Assigned_PreconfiguredShoppedKit, CustomShoppedKit};
        insert ListOfPMarketingKits;


        Marketing_Item__c MarketingItem = new Marketing_Item__c();
        MarketingItem.Brand__c = b.Id;
        MarketingItem.Temporary_Item_Number__c = '12313';
        MarketingItem.Item_Number__c = '12312313';
        MarketingItem.Price__c = 5;
        MarketingItem.Marketing_Type__c = 'Driver';
        MarketingItem.IH_Item_Classification__c = 'In Store Driver';
        insert MarketingItem;

        Area_Item_Inventory__c AreaItem = new Area_Item_Inventory__c();
        AreaItem.Labatt_Region__c = 'Quebec';
        AreaItem.Marketing_Item__c = MarketingItem.id;
        AreaItem.Quantity_Allocated_to_Area__c = 123;
        insert AreaItem;

        Marketing_Program_Item__c ProgramItem = new Marketing_Program_Item__c();
        ProgramItem.Marketing_Program__c = Program.Id;
        ProgramItem.Marketing_Item__c = MarketingItem.Id;

        Marketing_Program_Item__c ProgramItem2 = new Marketing_Program_Item__c();
        ProgramItem2.Marketing_Program__c = Program.Id;
        ProgramItem2.Marketing_Item__c = MarketingItem.Id;
        List<Marketing_Program_Item__c> ListOfPrograItem = new List<Marketing_Program_Item__c>{ProgramItem, ProgramItem2};
        insert ListOfPrograItem;

        List<Trade_Activation_Kit_Item__c> tradeActivationKitItemsList = new List<Trade_Activation_Kit_Item__c>();
        Trade_Activation_Kit_Item__c tradeActivationKitItem = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem.Marketing_Kit__c = Assigned_PreconfiguredShoppedKit.id;
        tradeActivationKitItem.Quantity__c = 1;
        tradeActivationKitItemsList.add(tradeActivationKitItem);

        Trade_Activation_Kit_Item__c tradeActivationKitItem2 = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem2.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem2.Marketing_Kit__c = PreconfiguredShoppedKit.id;
        tradeActivationKitItem2.Quantity__c = 1;
        tradeActivationKitItemsList.add(tradeActivationKitItem2);

        Trade_Activation_Kit_Item__c tradeActivationKitItem4 = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem4.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem4.Marketing_Kit__c = PreconfiguredShoppedKit.id;
        tradeActivationKitItem4.Quantity__c = 1;
        tradeActivationKitItemsList.add(tradeActivationKitItem4);

        Trade_Activation_Kit_Item__c tradeActivationKitItem3 = new Trade_Activation_Kit_Item__c();
        tradeActivationKitItem3.Marketing_Program_Item__c = ProgramItem.id;
        tradeActivationKitItem3.Marketing_Kit__c = CustomShoppedKit.id;
        tradeActivationKitItem3.Quantity__c = 1;
        tradeActivationKitItem3.Marketing_Type__c = 'Visibility';
        tradeActivationKitItem3.Item_Spend__c = 12;
        tradeActivationKitItemsList.add(tradeActivationKitItem3);
        
        insert tradeActivationKitItemsList;
        
        
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        Attachment AttachOne = new Attachment();
        AttachOne.Name = 'Sales_Sheet_FR';
        AttachOne.body = bodyBlob;
        AttachOne.parentId = Program.Id;
        Attachment AttachTwo = new Attachment();

        AttachTwo.Name = 'Sales_Sheet_EN';
        AttachTwo.body = bodyBlob;
        AttachTwo.parentId = Program.Id;

        List<Attachment> ListOfAttach= new List<Attachment>{AttachOne, AttachTwo};
        //insert ListOfAttach;

        test.startTest();
        
        POCPlanningApp.getPOCSpendCategoryIDs(IHTerritoryPOC.Id);
        //updatePOCBudgetPlanTier
        POCPlanningApp.updatePOCBudgetPlanTier('Tier Non-Bud',IHTerritoryPOC.Id);
        //test_UpdateTerritoryPOC
        POCPlanningApp.UpdateTerritoryPOC(TerritoryPOC.Id, 1000, 1000);
        //test_POCBudget
        POCPlanningApp.POCBudget(TerritoryPOC.Id);
        //
        POCPlanningApp.Driver(TerritoryPOC.Id,false);
        //test_TradeActivation
        //
        POC_Planning_Brand_Restriction__c pocBrandRest=new POC_Planning_Brand_Restriction__c();
        pocBrandRest.Budget_Year__c=String.valueOf(Date.today().year());
        pocBrandRest.Restricted_Brands__c='Bud Light, Corona';
        insert pocBrandRest;
        
        String YearNew = String.valueOf(Date.today().year());

        POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Ontario', true,'Out Of Home', YearNew);
        POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Quebec', false,'Out Of Home', YearNew);

        User u = new User();
        u.Id = UserInfo.getUserId();
        u.LanguageLocaleKey = 'fr';
     //   update u;
        MarketingItem.Is_Cancelled__c = True;
        update MarketingItem;

       // POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Ontario', true);
        //POCPlanningApp.TradeActivation(AnnualAreaBudget.Id, TerritoryPOC.Id, 'Quebec', false);

        //test_CreateTAKit
        Date Today = date.today(); 
        POCPlanningApp.CreateTAKit('dfgjkhslfdjhkgjsdfgjkhlhsdfjkhlgjhksdfgjhksdfjkhlgjksdfgjkhsdfjkhgsdsdfsdijqweiodsdjkhfasjkdlfgklsdfgklj', POCTASpCat.Id, AnnualBrandAreaBudget.Id, Program.Id, Today.year() +'-'+Today.month()+'-'+Today.day(), Today.year()+'-'+Today.month()+'-'+Today.day(), 'Custom', null, 0);
        POCPlanningApp.CreateTAKit('TestKit', POCTASpCat.Id, AnnualBrandAreaBudget.Id, Program.Id, Today.year()+'-'+Today.month()+'-'+Today.day(), Today.year()+'-'+Today.month()+'-'+Today.day(), 'Custom', null, null);
       
       
        POCTASpCat.RecordTypeId=[Select Id, DeveloperName From RecordType Where SObjectType = 'POC_Spend_Category__c' AND DeveloperName='In_Store_Driver_In_Home' LIMIT 1].Id;
        update POCTASpCat;
        POCPlanningApp.OnDriverChange('111111', MarketingItem.Id, 1,2, false, POCTASpCat.Id, null, false, 'Ontario');
        
    }
    
}