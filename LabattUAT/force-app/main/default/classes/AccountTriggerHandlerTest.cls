@isTest
private class AccountTriggerHandlerTest {
    
    //testing code from AccountTriggerHandler
    static testMethod void insertAndUpdateAccount(){
        Profile profileId = [SELECT Id,Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        List<User> testUsers = [select id from user where isactive = true AND Profile.Name ='System Administrator' limit 2];
        system.assertEquals(2,testUsers.size());
        
        lboc_Sales_Territory__c lboc = new lboc_Sales_Territory__c();
        lboc.lboc_Territory_ID__c = '1234533444544';
        insert lboc;
        
        lboc_Sales_Territory__c lboc2 = new lboc_Sales_Territory__c();
        lboc2.lboc_Territory_ID__c = '12345334445445';
        lboc2.Name = lboc.Id;
        insert lboc2;
        
        
        Id IHRecordTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('IH Territory').getRecordTypeId();
        Id OOHRecordTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        List<Annual_Area_Budget__c> annAreaBudget = new List<Annual_Area_Budget__c>();
        Annual_Area_Budget__c annAreaBudget1 = new Annual_Area_Budget__c();
        annAreaBudget1.RecordTypeId = IHRecordTypeId;
        annAreaBudget1.Budget_Year__c = String.valueOf(Date.Today().Year());
        annAreaBudget1.Sales_Territory__c = lboc2.id;
        annAreaBudget.add(annAreaBudget1);
        Annual_Area_Budget__c annAreaBudget2 = new Annual_Area_Budget__c();
        annAreaBudget2.RecordTypeId = OOHRecordTypeId;
        annAreaBudget2.Budget_Year__c = String.valueOf(Date.Today().Year());
        annAreaBudget2.Sales_Territory__c = lboc2.id;
        annAreaBudget.add(annAreaBudget2);
        insert annAreaBudget;
        system.assertEquals(0,[select count() from Annual_POC_Budget_Plan__c]);
        
        
        //test createPOCBudgetPlans()
        List<Account> acc = new List<Account>();
        acc = AB_TestDataFactory.createAccounts(1,'Outlet', False);
        acc[0].Captaincy_Survey_Last_Updated_By__c = 'testUpdate';
        acc[0].OwnerId = testUsers[0].id;
        acc[0].lboc_Sales_Territory__c = lboc.id;
        insert acc;
        //system.assertEquals(1,acc.size());
        //system.assertEquals(2,[select count() from Annual_POC_Budget_Plan__c]);
        
        system.assertEquals(0,[select count() from Captaincy_Survey_Fields__c]);
        Captaincy_Survey_Fields__c cFields = new Captaincy_Survey_Fields__c();
        cFields.Field_API_Name__c = 'Captaincy_Survey_Last_Updated_By__c';
        cFields.Name = 'Captaincy Survey: Last Updated By';
        insert cFields;
        //system.assertEquals(1,[select count() from Captaincy_Survey_Fields__c]);
        //system.assertEquals(0,[select count() from Captaincy_Survey_History__c]);
        
        buzz_retail__Asset__c buzzRetail = new buzz_retail__Asset__c();
        buzzRetail.buzz_retail__Account__c = acc[0].id;
        buzzRetail.Ownerid = testUsers[0].id;
        insert buzzRetail;
        
        acc[0].Captaincy_Survey_Last_Updated_By__c = 'testUpdate 1';
        acc[0].Ownerid = testUsers[1].id;
        acc[0].lboc_Sales_Territory__c = lboc2.id;
        acc[0].BillingStreet = 'test';
        acc[0].BillingCity = 'test';
        acc[0].BillingState = 'test';
        acc[0].BillingCountry = 'test';
        acc[0].BillingPostalCode = 'test';
        update acc;
        
        buzz_retail__Asset__c buzzRet = [select ownerid from buzz_retail__Asset__c limit 1];
        //system.assertEquals(testUsers[1].id,buzzRet.Ownerid);
        
        List<Annual_POC_Budget_Plan__c> updatedBudgets = [SELECT Annual_Territory_Budget__c, Annual_Territory_Budget__r.Name, Account__c, RecordTypeId FROM Annual_POC_Budget_Plan__c];
        for(Annual_POC_Budget_Plan__c pbp : updatedBudgets){
            system.assertEquals(pbp.Account__c,acc[0].Id);
            if(pbp.RecordTypeId == Schema.SObjectType.Annual_POC_Budget_Plan__c.getRecordTypeInfosByName().get('IH POC Budget Plan').getRecordTypeId())
                system.assertEquals(pbp.Annual_Territory_Budget__c,annAreaBudget1.Id);
            else if(pbp.RecordTypeId == Schema.SObjectType.Annual_POC_Budget_Plan__c.getRecordTypeInfosByName().get('OOH POC Budget Plan').getRecordTypeId())
                system.assertEquals(pbp.Annual_Territory_Budget__c,annAreaBudget2.Id);
            
        }
        //system.assertEquals(1,[select count() from Captaincy_Survey_History__c]);
        
    }
    
    static testMethod void insertAndUpdateAccount2(){
        Profile profileId = [SELECT Id,Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        List<User> testUsers = [select id from user where isactive = true AND Profile.Name ='System Administrator' limit 2];
        
        Captaincy_Survey_Fields__c cFields = new Captaincy_Survey_Fields__c();
        cFields.Field_API_Name__c = 'Captaincy_Survey_Last_Updated_By__c';
        cFields.Name = 'Captaincy Survey: Last Updated By';
        insert cFields;
        
        //test createPOCBudgetPlans()
        test.startTest();
        List<Account> acc = new List<Account>();
        acc = AB_TestDataFactory.createAccounts(1,'Outlet', False);
        acc[0].Captaincy_Survey_Last_Updated_By__c = 'testUpdate';
        acc[0].OwnerId = testUsers[0].id;
        insert acc;
        
        acc[0].Captaincy_Survey_Last_Updated_By__c = 'testUpdate 1';
        acc[0].Ownerid = testUsers[1].id;
        acc[0].BillingStreet = 'test';
        acc[0].BillingCity = 'test';
        acc[0].BillingState = 'test';
        acc[0].BillingCountry = 'test';
        acc[0].BillingPostalCode = 'test';
        update acc;
        test.stopTest();
        
    }
    static testMethod void testresetOldAccs(){
        List<Account> acc = new List<Account>();
        acc = AB_TestDataFactory.createAccounts(1,'OnCall Ship To', False);
        acc[0].EDWID_US__c = '123456';
        //acc[0].GSC_Place_ID__c = '7777777';
        //RA 9/6/2018 - Update Field / API name for managed package
        acc[0].gsc_mc__GSC_Id__c = '7777777';
        insert acc;
        
        List<Account> acc1 = new List<Account>();
        acc1 = AB_TestDataFactory.createAccounts(1,'OnCall Ship To', False);
        acc1[0].OldPartyId__c = '1234567';		//RA 9/19/2018 update since it is unique
        acc1[0].EDWID_US__c = '1234567';		//RA 9/19/2018 update since it is unique
        //RA 9/6/2018 - Update Field / API name for managed package
        acc1[0].gsc_mc__GSC_Id__c = '8888888';
        //acc1[0].GSC_Place_ID__c = '8888888';
        insert acc1;
        
    }
    
    
    //Testing code from AB_AccountUpdate
    static testMethod void testAccountForABAccountUpdate(){
        List<Account> acc = new List<Account>();
        acc = AB_TestDataFactory.createAccounts(1,'OnCall Ship To', False);
        acc[0].EDWID_US__c = '123456';
        //acc[0].GSC_Place_ID__c = '7777777';
        //RA 9/6/2018 - Update Field / API name for managed package
        acc[0].gsc_mc__GSC_Id__c = '7777777';
        insert acc;
        
        List<Account> acc1 = new List<Account>();
        acc1 = AB_TestDataFactory.createAccounts(1,'OnCall Ship To', False);
        acc1[0].OldPartyId__c = '1234567';		//RA 9/19/2018 update since it is unique
        acc1[0].EDWID_US__c = '1234567';		//RA 9/19/2018 update since it is unique
        //RA 9/6/2018 - Update Field / API name for managed package
        acc1[0].gsc_mc__GSC_Id__c = '8888888';
        //acc1[0].GSC_Place_ID__c = '8888888';
        insert acc1;
        
        //RA 9/6/2018, 9/15/2018 - Update Field / API name for managed package
        //Account a = [select GSC_Place_ID__c,Remote_Survey_Vendor_Enabled__c from Account where id =: acc1[0].id];
        //Account oldAcc = [select GSC_Place_ID__c,Remote_Survey_Vendor_Enabled__c from Account where id =: acc[0].id];
        Account a = [select gsc_mc__GSC_Id__c,gsc_mc__Sync_to_GoSpotCheck__c from Account where id =: acc1[0].id];
        Account oldAcc = [select gsc_mc__GSC_Id__c,gsc_mc__Sync_to_GoSpotCheck__c from Account where id =: acc[0].id];
        
        //RA 10/20/2018 - Remove reference to old fields
        //system.assertEquals('8888888',a.GSC_Place_ID__c);
        //system.assertEquals(False,a.Remote_Survey_Vendor_Enabled__c);
        system.assertEquals(True,a.gsc_mc__Sync_to_GoSpotCheck__c);
        //system.assertEquals('7777777',oldAcc.GSC_Place_ID__c);
        //system.assertEquals(False,oldAcc.Remote_Survey_Vendor_Enabled__c);
        system.assertEquals(True,oldAcc.gsc_mc__Sync_to_GoSpotCheck__c);
        system.assertEquals(1,[select count() from PocXRef__c]);
    }
    
    
    //Testing code from Oncall_AccounttriggerHandler
    
    
    static testMethod void testAccountForOnCallAccountTriggerHandler(){
        init1();
        Price_List__c priceList = new Price_List__c(Name = 'New PL', Price_List_Code__c = '6666');
        insert priceList;
        
        OnCall_Route__c r = new OnCall_Route__c(Name = 'New Route', TS_Route_Code__c = 'Test Route NO Match');
        insert r;
        
        List<Frequency__c> freqList = new List<Frequency__c>();
        Frequency__c freqA = new Frequency__c(Name = 'A1', Frequency_Code__c = 'A1', Active__c = true, Day_of_Week__c = 'Monday', 
                                              Frequency_of_Weeks__c = 1, Frequency_Start_Date__c = date.ValueOf('2016-07-25'));
        freqList.add(freqA);
        Frequency__c freqb = new Frequency__c(Name = 'B1', Frequency_Code__c = 'B1', Active__c = true, Day_of_Week__c = 'Monday', 
                                              Frequency_of_Weeks__c = 2, Frequency_Start_Date__c = date.ValueOf('2016-07-25'));
        freqList.add(freqB);
        insert freqList;
        
        Id recAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('OnCall POC / Sold To').getRecordTypeId();
        Id recDCAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('OnCall Distribution Center').getRecordTypeId();
        
        OnPoint_District__c dist = new OnPoint_District__c(Name='test');
        insert dist;
        
        OnPoint_Territory__c ter = new OnPoint_Territory__c(Name='test', District__c=dist.Id);
        insert ter;
        
        //OnPoint_Territory__c ter1 = new OnPoint_Territory__c(Name='test', District__c=dist.Id);-femi
        //insert ter1; - femi
        
        system.debug('@@@ insert accA');
        List<Account> testAcclist = new List<Account>();
        Account accA = new Account(Name='Test 7/11 SoldTo', RecordTypeId=recDCAcc, DC_Code__c = 'Test DC',DC_Description__c = 'TEST UdpateDC' );
        //insert accA;
        testAcclist.add(accA);
        
        system.debug('@@@ insert accB');
        Account accB = new Account(Name='Test 7/11 SoldTo', DC_Code__c = 'Test DC',DC_Description__c = 'TEST UdpateDC',Customer_Number__c = '002999999',KATR2__c='12345' );
        accB.OnCall_Ignore_PL_POCFilter__c = false;
        accB.RecordTypeId = [Select Id from RecordType where sObjectType = 'Account' and Name = 'OnCall Ship To'].id;
        //insert accB;        
        testAcclist.add(accB);
        
        system.debug('@@@ insert accC');
        Account accC = new Account(Name='Test 7/11 SoldTo', RecordTypeId=recAcc, DC_Code__c = 'Test DC',DC_Description__c = 'TEST UdpateDC',Customer_Number__c = '003999999', 
                                   lboc_Labatt_Outlet_Id__c='test', OnPoint_Territory_Code__c='1234567', OnPoint_Sales_Territory__c=ter.Id, OnCall_Route_Code__c='1234567',
                                   Ship_To_Account__c=accB.Id );
        
        accC.RecordTypeId = [Select Id from RecordType where sObjectType = 'Account' and Name = 'Outlet'].id;
        //insert accC;
        testAcclist.add(accC);
        
        insert testAcclist;
        
        system.debug('@@@ update accA');
        testAcclist[0].Order_Block__c = '1234';
        
        system.debug('@@@ update accB');
        testAcclist[1].KATR2__c = '234556';
        testAcclist[1].DC_Code__c = '2222';
        
        system.debug('@@@ update accC');
        testAcclist[2].RecordTypeId = [Select Id from RecordType where sObjectType = 'Account' and Name = 'OnCall POC / Sold To'].id;
        testAcclist[2].lboc_Labatt_Outlet_Id__c = 'test1111';
        testAcclist[2].OnPoint_Territory_Code__c = '7654321';
        testAcclist[2].OnPoint_Sales_Territory__c = ter.Id;
        testAcclist[2].OnCall_Ignore_PL_POCFilter__c = false;
        testAcclist[2].OnCall_Route_Code__c = '76543';
        testAcclist[2].Ship_To_Account__c = accB.Id;
        testAcclist[2].DC_Code_from_SAP__c = '7777777';
        
        update testAcclist;
        //update accA;      
        //update accB;
        //update accC;
        AccountTriggerHandler.updateShipToDCCode(new List<Account>{testAcclist[1]});
        AccountTriggerHandler.updatedShipToKATR2(new List<Account>{testAcclist[1]});
        /* Account accD = new Account(Name='Test updateDC', DC_Code__c = 'Test DC',DC_Description__c = 'TEST UdpateDC',Customer_Number__c = '0029999998',KATR2__c='123458' );
accD.RecordTypeId = [Select Id from RecordType where sObjectType = 'Account' and Name = 'OnCall Distribution Center'].id;
insert accD;*/
        
        List<Account> accList = new List<Account>();
        
        Account accnt = new Account(Name='Test 7/11', RecordTypeId=recAcc, DC_Code_from_SAP__c = '2222', DC_Name__c = 'DC Code', DSM_ID__c = '1111', 
                                    DSM_First_Name__c = 'DSM First Name', DSM_Last_Name__c = 'DSM Last Name', TM_ID__c = '3333',
                                    TM_First_Name__c = 'TM First Name', TM_Last_Name__c = 'Last Name', Sales_Area_ID__c = '4444', 
                                    Sales_Area_Description__c = 'Sales area description', Banner_ID__c = '5555', Banner_Description__c = 'Banner Desc5151', 
                                    KDKG2__c = '6666', Customer_Segment__c = '7777',OnCall_Route_Code__c = 'Test Route',Ship_To_Account__c = accA.id,Call_Frequency_Code_SAP__c = 'A1',
                                    Delivery_Frequency_Code_SAP__c = 'B1',KATR2__c = '2344444',OnCall_Ignore_PL_POCFilter__c = False, Order_Block__c = '33334455');
        
        accList.add(accnt);
        system.debug('@@@ insert accList');
        Test.startTest();
        insert accList;
        
        Account acc = [select PO_Required__c,Price_List__c,TS_Route__c,OnCall_Route_Code__c,DC_Code_from_SAP__c,DC_Description__c,Call_Frequency__c,
                       Delivery_Frequency__c,KATR2__c,RecordTypeId from Account where id =: accList[0].Id];
        //updatePOCProposalList
        //system.assertEquals(POCfltr1.Table_Control_Header__c,accnt.Proposal_List__c);
        
        //updatePOCPORequired
        system.assertEquals(True,acc.PO_Required__c);
        
        //updatePriceList
        system.assertEquals(priceList.Id,acc.Price_List__c);
        
        //updateRouteCode
        //system.assertEquals(2,[select count() from OnCall_Route__c]);
        OnCall_Route__c rNew = [select id from OnCall_Route__c where TS_Route_Code__c =: acc.OnCall_Route_Code__c];
        system.assertEquals(rNew.id, acc.TS_Route__c);
        
        //populateSoldToDCCode
        system.assertEquals('Test DC',acc.DC_Code_from_SAP__c);
        
        //updateDC
        system.assertEquals('TEST UdpateDC', acc.DC_Description__c);
        
        //updateFrequency
        system.assertEquals(freqA.id,acc.Call_Frequency__c);
        system.assertEquals(freqB.id,acc.Delivery_Frequency__c);
        
        //update Account
        acc.KATR2__c = null;
        acc.OnCall_Ignore_PL_POCFilter__c = True;
        acc.KDKG2__c = '77777';
        acc.DC_Code_from_SAP__c = null;
        acc.Call_Frequency_Code_SAP__c = null;
        acc.Order_Block__c = '333666666';
        //acc.DC_Account__c = null;
        //update acc;
        
        // following code added to increase code coverage 
        list<Account> testAccounts = [Select Id, Name, RecordTypeId
                                      from Account];
        AccountTriggerHandler.createPOCBudgetPlans(testAccounts);
        
        
    }
    
    
    
    
    
    //Testing code from Oncall_AccounttriggerHandler
    
    static testMethod void testAccountForTeleUS(){
        init1();
        List<Frequency__c> freqList = new List<Frequency__c>();
        Frequency__c freqA = new Frequency__c(Name = 'A1', Frequency_Code__c = 'A1', Active__c = true, Day_of_Week__c = 'Monday', 
                                              Frequency_of_Weeks__c = 1, Frequency_Start_Date__c = date.ValueOf('2016-07-25'));
        freqList.add(freqA);
        Frequency__c freqb = new Frequency__c(Name = 'B1', Frequency_Code__c = 'B1', Active__c = true, Day_of_Week__c = 'Monday', 
                                              Frequency_of_Weeks__c = 2, Frequency_Start_Date__c = date.ValueOf('2016-07-25'));
        freqList.add(freqB);
        insert freqList;
        
        Id recTypePOC = Schema.SObjectType.Account.getRecordTypeInfosByName().get('POC').getRecordTypeId();
        Id recTypeTeleUS = Schema.SObjectType.Call__c.getRecordTypeInfosByName().get('TeleSales US').getRecordTypeId();               
        system.debug('@@@ teleUS call:'+recTypeTeleUS+ '  POC:'+recTypePOC);
        Account accA = new Account(Name='Test TeleUS', RecordTypeId=recTypePOC, Call_Frequency__c = freqA.Id, Delivery_Frequency__c=freqb.Id, Seasonal__c = TRUE,
                                   Off_Season_Start_Month__c = '01', Off_Season_Start_Day__c = '01', Off_Season_End_Month__c = '04', Off_Season_End_Day__c = '01' );
        insert accA;
        Call__c  callRecF = new Call__c( Name = 'Testing', RecordTypeId = recTypeTeleUS, POC__c = accA.Id, Date__c = System.today().addDays(5) );
        insert callRecF;
        system.debug('@@@ change frequency');
        accA.Call_Frequency__c = freqB.Id;
        update accA;      
        list<Call__c> afterChgF = [Select Id, Name from Call__c where POC__c =: accA.Id];
        // system.assertEquals(afterChgF.size(),0);
        Call__c  callRecS = new Call__c( Name = 'Testing', RecordTypeId = recTypeTeleUS, POC__c = accA.Id, Date__c = System.today().addDays(5) );
        insert callRecS;
        system.debug('@@@ change seasonal');
        accA.Off_Season_Start_Month__c = '02';
        update accA;
        list<Call__c> afterChgS = [Select Id, Name from Call__c where POC__c =: accA.Id];
        //system.assertEquals(afterChgS.size(),0);
        
    }
    
    
    
    
    static testMethod void testAccountForOnCall_Init2()
    {
        
        init2();
        Id recAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('OnCall POC / Sold To').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        
        Account accnt = new Account(Name='Test 7/11', RecordTypeId=recAcc, DC_Code_from_SAP__c = '2222', DC_Name__c = 'DC Code', DSM_ID__c = '1111', 
                                    DSM_First_Name__c = 'DSM First Name', DSM_Last_Name__c = 'DSM Last Name', TM_ID__c = '3333',
                                    TM_First_Name__c = 'TM First Name', TM_Last_Name__c = 'Last Name', Sales_Area_ID__c = '4444', Seasonal__c = TRUE,
                                    Sales_Area_Description__c = 'Sales area description', Banner_ID__c = '5555', Banner_Description__c = 'Banner Desc5151', 
                                    KDKG2__c = '6666', Customer_Segment__c = '7777',OnCall_Route_Code__c = 'Test Route',Call_Frequency_Code_SAP__c = 'A1',
                                    Delivery_Frequency_Code_SAP__c = 'B1',KATR2__c = '10',OnCall_Ignore_PL_POCFilter__c = False, Order_Block__c = '33334455', No_Call__c = False,
                                    Off_Season_Start_Month__c = '10',Off_Season_Start_Day__c = '15',Off_Season_End_Month__c = '03',
                                    Off_Season_End_Day__c = '10',Customer_Number__c = '005999999');
        
        accList.add(accnt);
        insert accList;
        
        accnt.KATR2__c = null;
        update accnt;
        
        Account acc = [select Proposal_List__c from Account where id =: accList[0].Id];
        
        DOI_Header__c doiHeader = [select id from DOI_Header__c LIMIT 1];
        system.assertEquals(doiHeader.Id,acc.Proposal_List__c);
        accnt.KDKG2__c = '7777';
        accnt.DC_Code_from_SAP__c = '121212';
        update accnt;
        accnt.DC_Code_from_SAP__c = null;
        update accnt;
        
        list<Account> testAccounts = [Select Id, Name
                                      from Account];
        AccountTriggerHandler.updateCallOrderBlock(testAccounts);
    }
    
    static testMethod void testAccountForOnCall_RecordTypeChange()
    {
        
        Id recAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('OnCall Ship To').getRecordTypeId();        
        
        Account accA = new Account(Name='Test 7/11 SoldTo', RecordTypeId=recAcc, DC_Code__c = 'Test DC',DC_Description__c = 'TEST UdpateDC',KATR2__c = '0009999' );
        insert accA;
        
        
        List<Account> accList = new List<Account>();
        
        Account accnt = new Account(Name='Test 7/11', RecordTypeId=recAcc, DC_Code_from_SAP__c = '2222', DC_Name__c = 'DC Code', DSM_ID__c = '1111', 
                                    DSM_First_Name__c = 'DSM First Name', DSM_Last_Name__c = 'DSM Last Name', TM_ID__c = '3333',
                                    TM_First_Name__c = 'TM First Name', TM_Last_Name__c = 'Last Name', Sales_Area_ID__c = '4444', Seasonal__c = TRUE,
                                    Sales_Area_Description__c = 'Sales area description', Banner_ID__c = '5555', Banner_Description__c = 'Banner Desc5151', 
                                    KDKG2__c = '6666', Customer_Segment__c = '7777',OnCall_Route_Code__c = 'Test Route',Ship_To_Account__c = accA.id,Call_Frequency_Code_SAP__c = 'A1',
                                    Delivery_Frequency_Code_SAP__c = 'B1',KATR2__c = '2344444',OnCall_Ignore_PL_POCFilter__c = False, Order_Block__c = '33334455', No_Call__c = False,
                                    Off_Season_Start_Month__c = '10',Off_Season_Start_Day__c = '10',Off_Season_End_Month__c = '03',
                                    Off_Season_End_Day__c = '10', DC_Account__c = null);
        
        accList.add(accnt);
        insert accList;
        
        Account acc = [select KATR2__c from Account where id =: accList[0].Id];
        Call__c call = onCall_TestUtilityMethods.createCall(accList[0].Id);
        call.date__c = system.today() + 6;
        insert call;
        
        acc.KATR2__c = null;
        acc.DC_Code__c = 'test';
        //acc.Call_Frequency__c = 'A2';
        acc.No_Call__c = True;
        acc.Off_Season_Start_Month__c = '11';
        update acc;
        
        //system.assertEquals(0,[select count() from Call__C]);
        
    }
    
    //Testing code from AccountSummaryTrigger
    static testMethod void testAccountForAccountSummaryTrigger(){
        Id recAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Decision Point').getRecordTypeId();
        
        Account accA = new Account(Name='Test 7/11 SoldTo', RecordTypeId=recAcc, DC_Code__c = 'Test DC',DC_Description__c = 'TEST UdpateDC',Customer_Number__c = '001999999' );
        insert accA;
        
        
        
        //system.assertEquals(1,[select count() from lboc_Account_Detail__c]);
        system.assertEquals(1,[Select count() from lboc_Account_Performance__c where lboc_Account__c =: accA.id]);
        lboc_Account_Detail__c lbocAccDet = [select lboc_Account__c from lboc_Account_Detail__c];
        lboc_Account_Performance__c lbocAccPerf = [select lboc_Account__c from lboc_Account_Performance__c];
        system.assertEquals(lbocAccDet.lboc_Account__c, accA.Id);
        system.assertEquals(lbocAccPerf.lboc_Account__c, accA.Id);
    }
    
    static testmethod void init1(){
        DOI_Max_Budget__c doiMaxBudget = new DOI_Max_Budget__c(Maximum_Discount_Budget__c = 10000, Internal_Order_Number__c = 'Test');
        insert doiMaxBudget;
        Id recPL = [Select Id from RecordType where sObjectType = 'DOI_Header__c' and Name = 'PO Required'].id;
        DOI_Header__c tch2 = new DOI_Header__c();
        tch2.RecordTypeId = recPL;
        tch2.Name = 'Test TCH PO Required';
        tch2.DOI_Max_Budget__c = doiMaxBudget.id;
        tch2.Active__c = TRUE;
        tch2.Default_Proposal_List__c = 'On Default';
        insert tch2;
        
        POC_Filter__c pfl = new POC_Filter__c();
        pfl.Table_Control_Header__c = tch2.id;
        pfl.District_Sales_Manager_ID__c = '1111';
        pfl.Distribution_Center_ID__c = '2222';
        pfl.Sales_Representative_ID__c = '3333';
        pfl.Region_ID__c = '4444';
        pfl.Banner_ID__c = '5555';
        pfl.Price_List__c = '6666';
        pfl.Segment__c = '7777';
        pfl.Active__c = true;
        
        insert pfl;
        
    }
    
    static testmethod void init2(){
        DOI_Max_Budget__c doiMaxBudget = new DOI_Max_Budget__c(Maximum_Discount_Budget__c = 10000, Internal_Order_Number__c = 'Test');
        insert doiMaxBudget;
        Id recPL = [Select Id from RecordType where sObjectType = 'DOI_Header__c' and Name = 'Proposal List'].id;
        DOI_Header__c tch2 = new DOI_Header__c();
        tch2.RecordTypeId = recPL;
        tch2.Name = 'Test TCH PO Required';
        tch2.DOI_Max_Budget__c = doiMaxBudget.id;
        tch2.Active__c = TRUE;
        tch2.Default_Proposal_List__c = 'On Default';
        tch2.Are_You_Sure__c = True;
        insert tch2;
        
        POC_Filter__c pfl = new POC_Filter__c();
        pfl.Table_Control_Header__c = tch2.id;
        pfl.District_Sales_Manager_ID__c = '1111';
        pfl.Distribution_Center_ID__c = '2222';
        pfl.Sales_Representative_ID__c = '3333';
        pfl.Region_ID__c = '4444';
        pfl.Banner_ID__c = '5555';
        pfl.Price_List__c = '6666';
        pfl.Segment__c = '7777';
        pfl.Active__c = true;
        insert pfl;        
        
    }
    
    static testMethod void AccountOwnerUpdateTest() {
        Account acc =new Account();
        acc.name='Test';
        acc.type = 'Wholesaler';
        acc.EDWID_US__c='151386309';
        //acc.GSC_Place_ID__c='8702453'; 
        //RA
        acc.gsc_mc__GSC_Id__c='8702453'; 
        insert acc;
        
        Account acc1 =new Account();
        acc1.name='Test';
        acc1.EDWID_US__c='1513863091';		//RA 9/19/2018 - Upate since it is unique
        acc1.OldPartyId__c='1513863091'; 	//RA 9/19/2018 - Upate since it is unique
        acc1.type = 'POC';
        acc1.Wholesaler__c = acc.id;
        insert acc1;
    }
    
}