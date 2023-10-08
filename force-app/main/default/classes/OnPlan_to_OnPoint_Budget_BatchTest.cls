/***
* @Name - OnPlan_to_OnPoint_Budget_BatchTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description - This test class Created for testing method of OnPlan_to_OnPoint_Budget_Batch  class
* 

***/


@isTest 
public class OnPlan_to_OnPoint_Budget_BatchTest
{
    static testMethod void myUnitTestForKeithGoose() 
    {
               
        List<OnPoint_District__c> districtList = OnPoint_TestUtil.createDistrict(1);
        insert districtList;
        
        List<OnPoint_Territory__c> territoryList = OnPoint_TestUtil.createTerritory(1, districtList[0].id);
        insert territoryList;
        
        Id WsRecId = [Select Id, Name from RecordType where developername = 'IH_Assigned_Preconfigured' limit 1].Id;
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c brd = new Brand__c();
        brd.Name= 'Keith,Goose,ShockTop';
        brd.OnPoint_Brand_Name__c ='Keith,Goose,ShockTop';
        brd.RecordTypeId=brandRecId;
        insert brd;
        
        Brand__c brd1 = new Brand__c();
        brd1.Name= 'Alexander Keith\'s';
        brd1.OnPoint_Brand_Name__c ='Alexander Keith\'s';
        brd1.RecordTypeId=brandRecId;
        insert brd1;
        
        Brand__c brd2 = new Brand__c();
        brd2.Name= 'Goose Island';
        brd2.OnPoint_Brand_Name__c ='Goose Island';
        brd2.RecordTypeId=brandRecId;
        insert brd2;
        
        Brand__c brd3 = new Brand__c();
        brd3.Name= 'Shock Top';
        brd3.OnPoint_Brand_Name__c ='Shock Top';
        brd3.RecordTypeId=brandRecId;
        insert brd3;
        
        OnPoint_Brand__c obBrand=new OnPoint_Brand__c();
        obBrand.Name='Keith,Goose,ShockTop';
        obBrand.Brand_Name__c='Keith,Goose,ShockTop';
        insert obBrand;
        OnPoint_Brand__c obBrand1=new OnPoint_Brand__c();
        obBrand1.Name='Alexander Keith\'s';
        obBrand1.Brand_Name__c='Alexander Keith\'s';
        insert obBrand1;
        OnPoint_Brand__c obBrand2=new OnPoint_Brand__c();
        obBrand2.Name='Goose Island';
        obBrand2.Brand_Name__c='Goose Island';
        insert obBrand2;
        OnPoint_Brand__c obBrand3=new OnPoint_Brand__c();
        obBrand3.Name='Shock Top';
        obBrand3.Brand_Name__c='Shock Top';
        insert obBrand3;
        
        Account accToInsert = TestUtils.createTestAccount('Test_Account','Outlet', null);
        accToInsert.lboc_Channel__c='ON';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert;
        
        Account accToInsert2 = TestUtils.createTestAccount('Test_Account2','Outlet', null);
        accToInsert2.lboc_Channel__c='OFF';
        accToInsert2	.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert2;
        
        Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
        aab.Budget_Year__c = '2019';
        insert aab;
        
        Annual_POC_Budget_Plan__c apb=new Annual_POC_Budget_Plan__c();
        apb.Account__c=accToInsert.Id;
        apb.Annual_Territory_Budget__c=aab.id;    
        insert apb;
        
        Annual_POC_Budget_Plan__c apb2=new Annual_POC_Budget_Plan__c();
        apb2.Account__c=accToInsert2.Id;
        apb2.Annual_Territory_Budget__c=aab.id;    
        insert apb2;
        
        
        Id pocRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation_Out_of_Home' limit 1].Id;

        POC_Spend_Category__c pocObj=new POC_Spend_Category__c();
        pocObj.Annual_POC_Budget_Plan__c=apb.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj;
        
        POC_Spend_Category__c pocObj2=new POC_Spend_Category__c();
        pocObj2.Annual_POC_Budget_Plan__c=apb2.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj2;
        
        Annual_Brand_Area_Budget_Plan__c app = new Annual_Brand_Area_Budget_Plan__c();
        app.Brand__c = brd.Id;
        app.Annual_Area_Budget__c = aab.Id;
        insert app;
        
        Id occrec = [Select Id from RecordType where developername = 'Brand_Cost_Center' limit 1].Id;
        OnPoint_Cost_Centers__c occ = new OnPoint_Cost_Centers__c();
        occ.Name = 'Keith,Goose,ShockTop';
        occ.Type__c = 'Keith,Goose,ShockTop';
        occ.Brand__c=obBrand.id;
        //occ.User_Friendly_Name__c='Corona';
        occ.RecordTypeId= occrec;
        insert occ;
        OnPoint_Cost_Centers__c occ1 = new OnPoint_Cost_Centers__c();
        occ1.Name = 'Alexander Keith\'s';
        occ1.Type__c = 'Alexander Keith\'s';
        occ1.Brand__c=obBrand1.id;
        //occ.User_Friendly_Name__c='Corona';
        occ1.RecordTypeId= occrec;
        insert occ1;
        OnPoint_Cost_Centers__c occ2 = new OnPoint_Cost_Centers__c();
        occ2.Name = 'Goose Island';
        occ2.Type__c = 'Goose Island';
        occ2.Brand__c=obBrand2.id;
        //occ.User_Friendly_Name__c='Corona';
        occ2.RecordTypeId= occrec;
        insert occ2;
        OnPoint_Cost_Centers__c occ3 = new OnPoint_Cost_Centers__c();
        occ3.Name = 'Shock Top';
        occ3.Type__c = 'Shock Top';
        occ3.Brand__c=obBrand3.id;
        //occ.User_Friendly_Name__c='Corona';
        occ3.RecordTypeId= occrec;
        insert occ3;
        
        OnPoint_GLs__c ogl= new OnPoint_GLs__c();
        ogl.Name='Brand On Premise';
        ogl.User_Friendly_Name__c='Brand On Premise';
        ogl.GL_Code__c='ogl_2020';
        insert ogl;
        
       
            
        OnPoint_GLs__c ogl1= new OnPoint_GLs__c();
        ogl1.Name='Brand Retail';
        ogl1.User_Friendly_Name__c='Brand Retail';
        ogl1.GL_Code__c='ogl_2022';
        insert ogl1;
        
        Marketing_Item__c mi = new Marketing_Item__c();
        mi.Name = 'Keith,Goose,ShockTop - Coasters';
        mi.Brand__c = brd.Id;
        mi.Full_Price_to_Rep__c = 10;
        mi.IH_Item_Classification__c = 'Cooler';
        
        insert mi;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        
        mp.Name = 'Budweiser - Hockey';
        mp.Brand__c = brd.Id;
        mp.Business_Line__c = 'Out of Home';
        mp.Planning_End_Date__c = Date.today();
        mp.Planning_Start_Date__c = Date.today();
        mp.Program_End_Date__c = Date.today();
        mp.Program_Start_Date__c = Date.today();
        
        insert mp;
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.ExternalKey__c = '123';
        mpi.Marketing_Program__c = mp.Id;
        mpi.Marketing_Item__c = mi.Id;
        insert mpi;
        
        Marketing_Kit__c mk = new Marketing_Kit__c();
        mk.Name = 'test';
        mk.Marketing_Program_Name__c = mp.Id;
        mk.RecordTypeId = WsRecId;
        mk.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk.POC_Spend_Category__c=pocObj.id;
        insert mk;
        
        Marketing_Kit__c mk2 = new Marketing_Kit__c();
        mk2.Name = 'test';
        mk2.Marketing_Program_Name__c = mp.Id;
        mk2.RecordTypeId = WsRecId;
        mk2.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk2.POC_Spend_Category__c=pocObj.id;
        insert mk2;
        
        OnPlan_to_OnPoint_Budget_Batch btch = new OnPlan_to_OnPoint_Budget_Batch();
        
        Test.startTest();
        
        Database.executebatch(btch);
        
        Test.stopTest();
    }
    static testMethod void myUnitTest() 
    {
               
        List<OnPoint_District__c> districtList = OnPoint_TestUtil.createDistrict(1);
        insert districtList;
        
        List<OnPoint_Territory__c> territoryList = OnPoint_TestUtil.createTerritory(1, districtList[0].id);
        insert territoryList;
        
        Id WsRecId = [Select Id, Name from RecordType where developername = 'IH_Assigned_Preconfigured' limit 1].Id;
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c brd = new Brand__c();
        brd.Name= 'Corona';
        brd.OnPoint_Brand_Name__c ='Corona';
        brd.RecordTypeId=brandRecId;
        insert brd;
        
        OnPoint_Brand__c obBrand=new OnPoint_Brand__c();
        obBrand.Name='Corona';
        obBrand.Brand_Name__c='Corona';
        insert obBrand;
        
        Account accToInsert = TestUtils.createTestAccount('Test_Account','Outlet', null);
        accToInsert.lboc_Channel__c='ON';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert;
        
        Account accToInsert2 = TestUtils.createTestAccount('Test_Account2','Outlet', null);
        accToInsert2.lboc_Channel__c='OFF';
        accToInsert2	.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert2;
        
        Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
        aab.Budget_Year__c = '2019';
        insert aab;
        
        Annual_POC_Budget_Plan__c apb=new Annual_POC_Budget_Plan__c();
        apb.Account__c=accToInsert.Id;
        apb.Annual_Territory_Budget__c=aab.id;    
        insert apb;
        
        Annual_POC_Budget_Plan__c apb2=new Annual_POC_Budget_Plan__c();
        apb2.Account__c=accToInsert2.Id;
        apb2.Annual_Territory_Budget__c=aab.id;    
        insert apb2;
        
        
        Id pocRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation_Out_of_Home' limit 1].Id;

        POC_Spend_Category__c pocObj=new POC_Spend_Category__c();
        pocObj.Annual_POC_Budget_Plan__c=apb.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj;
        
        POC_Spend_Category__c pocObj2=new POC_Spend_Category__c();
        pocObj2.Annual_POC_Budget_Plan__c=apb2.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj2;
        
        Annual_Brand_Area_Budget_Plan__c app = new Annual_Brand_Area_Budget_Plan__c();
        app.Brand__c = brd.Id;
        app.Annual_Area_Budget__c = aab.Id;
        insert app;
        
        Id occrec = [Select Id from RecordType where developername = 'Brand_Cost_Center' limit 1].Id;
        OnPoint_Cost_Centers__c occ = new OnPoint_Cost_Centers__c();
        occ.Name = 'Corona';
        occ.Type__c = 'Corona';
        occ.Brand__c=obBrand.id;
        //occ.User_Friendly_Name__c='Corona';
        occ.RecordTypeId= occrec;
        insert occ;
        
        OnPoint_GLs__c ogl= new OnPoint_GLs__c();
        ogl.Name='Brand On Premise';
        ogl.User_Friendly_Name__c='Brand On Premise';
        ogl.GL_Code__c='ogl_2020';
        insert ogl;
        
       
            
        OnPoint_GLs__c ogl1= new OnPoint_GLs__c();
        ogl1.Name='Brand Retail';
        ogl1.User_Friendly_Name__c='Brand Retail';
        ogl1.GL_Code__c='ogl_2022';
        insert ogl1;
        
        Marketing_Item__c mi = new Marketing_Item__c();
        mi.Name = 'Corona - Coasters';
        mi.Brand__c = brd.Id;
        mi.Full_Price_to_Rep__c = 10;
        mi.IH_Item_Classification__c = 'Cooler';
        
        insert mi;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        
        mp.Name = 'Budweiser - Hockey';
        mp.Brand__c = brd.Id;
        mp.Business_Line__c = 'Out of Home';
        mp.Planning_End_Date__c = Date.today();
        mp.Planning_Start_Date__c = Date.today();
        mp.Program_End_Date__c = Date.today();
        mp.Program_Start_Date__c = Date.today();
        
        insert mp;
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.ExternalKey__c = '123';
        mpi.Marketing_Program__c = mp.Id;
        mpi.Marketing_Item__c = mi.Id;
        insert mpi;
        
        Marketing_Kit__c mk = new Marketing_Kit__c();
        mk.Name = 'test';
        mk.Marketing_Program_Name__c = mp.Id;
        mk.RecordTypeId = WsRecId;
        mk.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk.POC_Spend_Category__c=pocObj.id;
        insert mk;
        
        Marketing_Kit__c mk2 = new Marketing_Kit__c();
        mk2.Name = 'test';
        mk2.Marketing_Program_Name__c = mp.Id;
        mk2.RecordTypeId = WsRecId;
        mk2.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk2.POC_Spend_Category__c=pocObj.id;
        insert mk2;
        
        OnPlan_to_OnPoint_Budget_Batch btch = new OnPlan_to_OnPoint_Budget_Batch();
        
        Test.startTest();
        
        Database.executebatch(btch);
        
        Test.stopTest();
    }
     static testMethod void myUnitTestSecond() 
    {
        
        List<OnPoint_District__c> districtList = OnPoint_TestUtil.createDistrict(1);
        insert districtList;
        
        List<OnPoint_Territory__c> territoryList = OnPoint_TestUtil.createTerritory(1, districtList[0].id);
        insert territoryList;
        
        List<OnPoint_Territory_Budget__c> terrBudgetList = OnPoint_TestUtil.createTerritoryBudget(territoryList[0]);
        insert terrBudgetList;
 
        
        Id WsRecId = [Select Id, Name from RecordType where developername = 'IH_Assigned_Preconfigured' limit 1].Id;
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c brd = new Brand__c();
        brd.Name= 'Corona';
        brd.OnPoint_Brand_Name__c ='Corona';
        brd.RecordTypeId=brandRecId;
        insert brd;
        
        OnPoint_Brand__c obBrand=new OnPoint_Brand__c();
        obBrand.Name='Corona';
        obBrand.Brand_Name__c='Corona';
        insert obBrand;
        
        Account accToInsert = TestUtils.createTestAccount('Test_Account','Outlet', null);
        accToInsert.lboc_Channel__c='ON';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert;
        
        Account accToInsert2 = TestUtils.createTestAccount('Test_Account2','Outlet', null);
        accToInsert2.lboc_Channel__c='OFF';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert2;
        
        Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
        aab.Budget_Year__c = '2019';
        insert aab;
        
        Annual_POC_Budget_Plan__c apb=new Annual_POC_Budget_Plan__c();
        apb.Account__c=accToInsert.Id;
        apb.Annual_Territory_Budget__c=aab.id;    
        insert apb;
        
        Annual_POC_Budget_Plan__c apb2=new Annual_POC_Budget_Plan__c();
        apb2.Account__c=accToInsert2.Id;
        apb2.Annual_Territory_Budget__c=aab.id;    
        insert apb2;
        
        Id pocRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation_Out_of_Home' limit 1].Id;

        POC_Spend_Category__c pocObj=new POC_Spend_Category__c();
        pocObj.Annual_POC_Budget_Plan__c=apb.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj;
        
        POC_Spend_Category__c pocObj2=new POC_Spend_Category__c();
        pocObj2.Annual_POC_Budget_Plan__c=apb2.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj2;
        
        Annual_Brand_Area_Budget_Plan__c app = new Annual_Brand_Area_Budget_Plan__c();
        app.Brand__c = brd.Id;
        app.Annual_Area_Budget__c = aab.Id;
        insert app;
        
        Id occrec = [Select Id from RecordType where developername = 'Brand_Cost_Center' limit 1].Id;
        OnPoint_Cost_Centers__c occ = new OnPoint_Cost_Centers__c();
        occ.Name = 'Corona';
        occ.Type__c = 'Corona';
        occ.Brand__c=obBrand.id;
        //occ.User_Friendly_Name__c='Corona';
        occ.RecordTypeId= occrec;
        insert occ;
        
        OnPoint_GLs__c ogl= new OnPoint_GLs__c();
        ogl.Name='Brand On Premise';
        ogl.User_Friendly_Name__c='Brand On Premise';
        ogl.GL_Code__c='ogl_2020';
        insert ogl;
        
       
            
        OnPoint_GLs__c ogl1= new OnPoint_GLs__c();
        ogl1.Name='Brand Retail';
        ogl1.User_Friendly_Name__c='Brand Retail';
        ogl1.GL_Code__c='ogl_2022';
        insert ogl1;
        
        Marketing_Item__c mi = new Marketing_Item__c();
        mi.Name = 'Corona - Coasters';
        mi.Brand__c = brd.Id;
        mi.Full_Price_to_Rep__c = 10;
        mi.IH_Item_Classification__c = 'Cooler';
        
        insert mi;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        
        mp.Name = 'Budweiser - Hockey';
        mp.Brand__c = brd.Id;
        mp.Business_Line__c = 'Out of Home';
        mp.Planning_End_Date__c = Date.today();
        mp.Planning_Start_Date__c = Date.today();
        mp.Program_End_Date__c = Date.today();
        mp.Program_Start_Date__c = Date.today();
        
        insert mp;
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.ExternalKey__c = '123';
        mpi.Marketing_Program__c = mp.Id;
        mpi.Marketing_Item__c = mi.Id;
        insert mpi;
        
        Marketing_Kit__c mk = new Marketing_Kit__c();
        mk.Name = 'test';
        mk.Marketing_Program_Name__c = mp.Id;
        mk.RecordTypeId = WsRecId;
        mk.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk.POC_Spend_Category__c=pocObj.id;
        insert mk;
        
        Marketing_Kit__c mk2 = new Marketing_Kit__c();
        mk2.Name = 'test';
        mk2.Marketing_Program_Name__c = mp.Id;
        mk2.RecordTypeId = WsRecId;
        mk2.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk2.POC_Spend_Category__c=pocObj.id;
        insert mk2;
        
        OnPlan_to_OnPoint_Budget_Batch btch = new OnPlan_to_OnPoint_Budget_Batch();
        
        Test.startTest();
        
        Database.executebatch(btch);
        
        Test.stopTest();
    }
    
    static testMethod void myUnitTestThree() 
    {
        
        
        List<OnPoint_District__c> districtList = OnPoint_TestUtil.createDistrict(1);
        insert districtList;
        
        List<OnPoint_Territory__c> territoryList = OnPoint_TestUtil.createTerritory(1, districtList[0].id);
        
        insert territoryList;
        
        List<OnPoint_Territory_Budget__c> terrBudgetList = OnPoint_TestUtil.createTerritoryBudget(territoryList[0]);
        insert terrBudgetList;
 
        
        Id WsRecId = [Select Id, Name from RecordType where developername = 'IH_Assigned_Preconfigured' limit 1].Id;
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c brd = new Brand__c();
        brd.Name= 'Corona';
        brd.OnPoint_Brand_Name__c ='Corona';
        brd.RecordTypeId=brandRecId;
        insert brd;
        
        OnPoint_Brand__c obBrand=new OnPoint_Brand__c();
        obBrand.Name='Corona';
        obBrand.Brand_Name__c='Corona';
        insert obBrand;
        
        Account accToInsert = TestUtils.createTestAccount('Test_Account','Outlet', null);
        accToInsert.lboc_Channel__c='ON';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert;
        
        Account accToInsert2 = TestUtils.createTestAccount('Test_Account2','Outlet', null);
        accToInsert2.lboc_Channel__c='OFF';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert2;
        
        Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
        aab.Budget_Year__c = '2019';
        insert aab;
        
        Annual_POC_Budget_Plan__c apb=new Annual_POC_Budget_Plan__c();
        apb.Account__c=accToInsert.Id;
        apb.Annual_Territory_Budget__c=aab.id;    
        insert apb;
        
        Annual_POC_Budget_Plan__c apb2=new Annual_POC_Budget_Plan__c();
        apb2.Account__c=accToInsert2.Id;
        apb2.Annual_Territory_Budget__c=aab.id;    
        insert apb2;
        
        Id pocRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation_Out_of_Home' limit 1].Id;

        POC_Spend_Category__c pocObj=new POC_Spend_Category__c();
        pocObj.Annual_POC_Budget_Plan__c=apb.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj;
        
        POC_Spend_Category__c pocObj2=new POC_Spend_Category__c();
        pocObj2.Annual_POC_Budget_Plan__c=apb2.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj2;
        
        Annual_Brand_Area_Budget_Plan__c app = new Annual_Brand_Area_Budget_Plan__c();
        app.Brand__c = brd.Id;
        app.Annual_Area_Budget__c = aab.Id;
        insert app;
        
        Id occrec = [Select Id from RecordType where developername = 'Brand_Cost_Center' limit 1].Id;
        OnPoint_Cost_Centers__c occ = new OnPoint_Cost_Centers__c();
        occ.Name = 'Corona';
        occ.Type__c = 'Corona';
        occ.Brand__c=obBrand.id;
        //occ.User_Friendly_Name__c='Corona';
        occ.RecordTypeId= occrec;
        insert occ;
        
        OnPoint_GLs__c ogl= new OnPoint_GLs__c();
        ogl.Name='Brand On Premise';
        ogl.User_Friendly_Name__c='Brand On Premise';
        ogl.GL_Code__c='ogl_2020';
        insert ogl;
        
       
            
        OnPoint_GLs__c ogl1= new OnPoint_GLs__c();
        ogl1.Name='Brand Retail';
        ogl1.User_Friendly_Name__c='Brand Retail';
        ogl1.GL_Code__c='ogl_2022';
        insert ogl1;
        
        OnPoint_Budget__c objOB  = new OnPoint_Budget__c();
        objOB.OnPoint_Territory_Budget__c=terrBudgetList[0].id;
        objOB.Type__c='Trade Activation On Prem';
        objOB.GL__c=ogl.id;
        objOB.Cost_Center__c=occ.id;
        Decimal year=System.Today().year()+1;
        objOB.Unique_Budget_Code__c='T Code 0 - Trade Activation On Prem - Corona - 2020 - ON';
        insert objOB;
        
        Marketing_Item__c mi = new Marketing_Item__c();
        mi.Name = 'Corona - Coasters';
        mi.Brand__c = brd.Id;
        mi.Full_Price_to_Rep__c = 10;
        mi.IH_Item_Classification__c = 'Cooler';
        
        insert mi;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        
        mp.Name = 'Budweiser - Hockey';
        mp.Brand__c = brd.Id;
        mp.Business_Line__c = 'Out of Home';
        mp.Planning_End_Date__c = Date.today();
        mp.Planning_Start_Date__c = Date.today();
        mp.Program_End_Date__c = Date.today();
        mp.Program_Start_Date__c = Date.today();
        
        insert mp;
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.ExternalKey__c = '123';
        mpi.Marketing_Program__c = mp.Id;
        mpi.Marketing_Item__c = mi.Id;
        insert mpi;
        
        Marketing_Kit__c mk = new Marketing_Kit__c();
        mk.Name = 'test';
        mk.Marketing_Program_Name__c = mp.Id;
        mk.RecordTypeId = WsRecId;
        mk.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk.POC_Spend_Category__c=pocObj.id;
        insert mk;
        
        Marketing_Kit__c mk2 = new Marketing_Kit__c();
        mk2.Name = 'test';
        mk2.Marketing_Program_Name__c = mp.Id;
        mk2.RecordTypeId = WsRecId;
        mk2.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk2.POC_Spend_Category__c=pocObj.id;
        insert mk2;
        
        OnPlan_to_OnPoint_Budget_Batch btch = new OnPlan_to_OnPoint_Budget_Batch();
        
        Test.startTest();
        
        Database.executebatch(btch);
        
        Test.stopTest();
        
    }
    
    
     static testMethod void myUnitTestFour() 
     {
       
        
        List<OnPoint_District__c> districtList = OnPoint_TestUtil.createDistrict(1);
        insert districtList;
        
        List<OnPoint_Territory__c> territoryList = OnPoint_TestUtil.createTerritory(1, districtList[0].id);
        
        insert territoryList;
        
        List<OnPoint_Territory_Budget__c> terrBudgetList = OnPoint_TestUtil.createTerritoryBudget(territoryList[0]);
        insert terrBudgetList;
 
        
        Id WsRecId = [Select Id, Name from RecordType where developername = 'IH_Assigned_Preconfigured' limit 1].Id;
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c brd = new Brand__c();
        brd.Name= 'Corona';
        brd.OnPoint_Brand_Name__c ='Corona';
        brd.RecordTypeId=brandRecId;
        insert brd;
        
        OnPoint_Brand__c obBrand=new OnPoint_Brand__c();
        obBrand.Name='Corona';
        obBrand.Brand_Name__c='Corona';
        insert obBrand;
        
        Account accToInsert = TestUtils.createTestAccount('Test_Account','Outlet', null);
        accToInsert.lboc_Channel__c='ON';
        accToInsert.lboc_Labatt_Outlet_Id__c='8523';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert;
        
        Account accToInsert2 = TestUtils.createTestAccount('Test_Account2','Outlet', null);
        accToInsert2.lboc_Channel__c='ON';
        accToInsert2.lboc_Labatt_Outlet_Id__c='7896';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert2;
        
        Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
        aab.Budget_Year__c = '2019';
        insert aab;
        
        Annual_POC_Budget_Plan__c apb=new Annual_POC_Budget_Plan__c();
        apb.Account__c=accToInsert.Id;
        apb.Annual_Territory_Budget__c=aab.id;    
        insert apb;
        
        Annual_POC_Budget_Plan__c apb2=new Annual_POC_Budget_Plan__c();
        apb2.Account__c=accToInsert2.Id;
        apb2.Annual_Territory_Budget__c=aab.id;    
        insert apb2;
        
        Id pocRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation_Out_of_Home' limit 1].Id;

        POC_Spend_Category__c pocObj=new POC_Spend_Category__c();
        pocObj.Annual_POC_Budget_Plan__c=apb.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj;
        
        POC_Spend_Category__c pocObj2=new POC_Spend_Category__c();
        pocObj2.Annual_POC_Budget_Plan__c=apb2.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj2;
        
        Annual_Brand_Area_Budget_Plan__c app = new Annual_Brand_Area_Budget_Plan__c();
        app.Brand__c = brd.Id;
        app.Annual_Area_Budget__c = aab.Id;
        insert app;
        
        Id occrec = [Select Id from RecordType where developername = 'Brand_Cost_Center' limit 1].Id;
        OnPoint_Cost_Centers__c occ = new OnPoint_Cost_Centers__c();
        occ.Name = 'Corona';
        occ.Type__c = 'Corona';
        occ.Brand__c=obBrand.id;
        //occ.User_Friendly_Name__c='Corona';
        occ.RecordTypeId= occrec;
        insert occ;
        
        OnPoint_GLs__c ogl= new OnPoint_GLs__c();
        ogl.Name='Brand On Premise';
        ogl.User_Friendly_Name__c='Brand On Premise';
        ogl.GL_Code__c='ogl_2020';
        insert ogl;
        
       
            
        OnPoint_GLs__c ogl1= new OnPoint_GLs__c();
        ogl1.Name='Brand Retail';
        ogl1.User_Friendly_Name__c='Brand Retail';
        ogl1.GL_Code__c='ogl_2022';
        insert ogl1;
        
        OnPoint_Budget__c objOB  = new OnPoint_Budget__c();
        objOB.OnPoint_Territory_Budget__c=terrBudgetList[0].id;
        objOB.Type__c='Trade Activation On Prem';
        objOB.GL__c=ogl.id;
        objOB.Cost_Center__c=occ.id;
        Decimal year=System.Today().year()+1;
        objOB.Unique_Budget_Code__c='T Code 0 - Trade Activation On Prem - Corona - 2021 - ON';
        insert objOB;
        
        OnPoint_POC_Budget__c obp=new OnPoint_POC_Budget__c();
        obp.POC__c=accToInsert.id;
        obp.Budget__c=objOB.id;
        obp.POC_Budget_Unique_Code__c=accToInsert.lboc_Labatt_Outlet_Id__c+' - Corona';
        obp.Planned_Budget__c=90;
        insert obp;
        
        OnPoint_POC_Budget__c obp2=new OnPoint_POC_Budget__c();
        obp2.POC__c=accToInsert2.id;
        obp2.Budget__c=objOB.id;
        obp2.POC_Budget_Unique_Code__c=accToInsert2.lboc_Labatt_Outlet_Id__c+' - Corona';
        obp2.Planned_Budget__c=90;
        insert obp2;
        
        Marketing_Item__c mi = new Marketing_Item__c();
        mi.Name = 'Corona - Coasters';
        mi.Brand__c = brd.Id;
        mi.Full_Price_to_Rep__c = 10;
        mi.IH_Item_Classification__c = 'Cooler';
        
        insert mi;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        
        mp.Name = 'Budweiser - Hockey';
        mp.Brand__c = brd.Id;
        mp.Business_Line__c = 'Out of Home';
        mp.Planning_End_Date__c = Date.today();
        mp.Planning_Start_Date__c = Date.today();
        mp.Program_End_Date__c = Date.today();
        mp.Program_Start_Date__c = Date.today();
        
        insert mp;
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.ExternalKey__c = '123';
        mpi.Marketing_Program__c = mp.Id;
        mpi.Marketing_Item__c = mi.Id;
        insert mpi;
        
        Marketing_Kit__c mk = new Marketing_Kit__c();
        mk.Name = 'test';
        mk.Marketing_Program_Name__c = mp.Id;
        mk.RecordTypeId = WsRecId;
        mk.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk.POC_Spend_Category__c=pocObj.id;
        insert mk;
        
        Marketing_Kit__c mk2 = new Marketing_Kit__c();
        mk2.Name = 'test';
        mk2.Marketing_Program_Name__c = mp.Id;
        mk2.RecordTypeId = WsRecId;
        mk2.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk2.POC_Spend_Category__c=pocObj.id;
        insert mk2;
        
        OnPlan_to_OnPoint_Budget_Batch btch = new OnPlan_to_OnPoint_Budget_Batch();      
        OnPlan_to_OnPoint_Budget_Batch btch1 = new OnPlan_to_OnPoint_Budget_Batch('Program1');
        
        Test.startTest();
        Database.executebatch(btch);
        Database.executebatch(btch1);
        Test.stopTest();
    }
    static testMethod void myUnitTestFive() 
    {
       
        
        List<OnPoint_District__c> districtList = OnPoint_TestUtil.createDistrict(1);
        insert districtList;
        
        List<OnPoint_Territory__c> territoryList = OnPoint_TestUtil.createTerritory(1, districtList[0].id);
        
        insert territoryList;
        
        List<OnPoint_Territory_Budget__c> terrBudgetList = OnPoint_TestUtil.createTerritoryBudget(territoryList[0]);
        insert terrBudgetList;
 
        
        Id WsRecId = [Select Id, Name from RecordType where developername = 'IH_Assigned_Preconfigured' limit 1].Id;
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c brd = new Brand__c();
        brd.Name= 'Corona';
        brd.OnPoint_Brand_Name__c ='Corona';
        brd.RecordTypeId=brandRecId;
        insert brd;
        
        OnPoint_Brand__c obBrand=new OnPoint_Brand__c();
        obBrand.Name='Corona';
        obBrand.Brand_Name__c='Corona';
        insert obBrand;
        
        Account accToInsert = TestUtils.createTestAccount('Test_Account','Outlet', null);
        accToInsert.lboc_Channel__c='ON';
        accToInsert.lboc_Labatt_Outlet_Id__c='8523';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert;
        
        Account accToInsert2 = TestUtils.createTestAccount('Test_Account2','Outlet', null);
        accToInsert2.lboc_Channel__c='ON';
        accToInsert2.lboc_Labatt_Outlet_Id__c='7896';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert2;
        
        Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
        aab.Budget_Year__c = '2019';
        insert aab;
        
        Annual_POC_Budget_Plan__c apb=new Annual_POC_Budget_Plan__c();
        apb.Account__c=accToInsert.Id;
        apb.Annual_Territory_Budget__c=aab.id;    
        insert apb;
        
        Annual_POC_Budget_Plan__c apb2=new Annual_POC_Budget_Plan__c();
        apb2.Account__c=accToInsert2.Id;
        apb2.Annual_Territory_Budget__c=aab.id;    
        insert apb2;
        
        Id pocRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation_Out_of_Home' limit 1].Id;

        POC_Spend_Category__c pocObj=new POC_Spend_Category__c();
        pocObj.Annual_POC_Budget_Plan__c=apb.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj;
        
        POC_Spend_Category__c pocObj2=new POC_Spend_Category__c();
        pocObj2.Annual_POC_Budget_Plan__c=apb2.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj2;
        
        Annual_Brand_Area_Budget_Plan__c app = new Annual_Brand_Area_Budget_Plan__c();
        app.Brand__c = brd.Id;
        app.Annual_Area_Budget__c = aab.Id;
        insert app;
        
        Id occrec = [Select Id from RecordType where developername = 'Brand_Cost_Center' limit 1].Id;
        OnPoint_Cost_Centers__c occ = new OnPoint_Cost_Centers__c();
        occ.Name = 'Corona';
        occ.Type__c = 'Corona';
        occ.Brand__c=obBrand.id;
        //occ.User_Friendly_Name__c='Corona';
        occ.RecordTypeId= occrec;
        insert occ;
        
        OnPoint_GLs__c ogl= new OnPoint_GLs__c();
        ogl.Name='Brand On Premise';
        ogl.User_Friendly_Name__c='Brand On Premise';
        ogl.GL_Code__c='ogl_2020';
        insert ogl;
        
       
            
        OnPoint_GLs__c ogl1= new OnPoint_GLs__c();
        ogl1.Name='Brand Retail';
        ogl1.User_Friendly_Name__c='Brand Retail';
        ogl1.GL_Code__c='ogl_2022';
        insert ogl1;
        
        OnPoint_Budget__c objOB  = new OnPoint_Budget__c();
        objOB.OnPoint_Territory_Budget__c=terrBudgetList[0].id;
        objOB.Type__c='Trade Activation On Prem';
        objOB.GL__c=ogl.id;
        objOB.Cost_Center__c=occ.id;
        Decimal year=System.Today().year()+1;
        objOB.Unique_Budget_Code__c='T Code 0 - Trade Activation On Prem - Corona - 2020 - ON';
        insert objOB;
        
        OnPoint_POC_Budget__c obp=new OnPoint_POC_Budget__c();
        obp.POC__c=accToInsert.id;
        obp.Budget__c=objOB.id;
        obp.POC_Budget_Unique_Code__c=accToInsert.lboc_Labatt_Outlet_Id__c+' - Corona';
        obp.Planned_Budget__c=90;
        //Decimal year=System.Today().year()+1;
        insert obp;
        
        OnPoint_POC_Budget__c obp2=new OnPoint_POC_Budget__c();
        obp2.POC__c=accToInsert2.id;
        obp2.Budget__c=objOB.id;
        obp2.POC_Budget_Unique_Code__c=accToInsert2.lboc_Labatt_Outlet_Id__c+' - Corona';
        obp2.Planned_Budget__c=90;
        //Decimal year=System.Today().year()+1;
        insert obp2;
        
        Marketing_Item__c mi = new Marketing_Item__c();
        mi.Name = 'Corona - Coasters';
        mi.Brand__c = brd.Id;
        mi.Full_Price_to_Rep__c = 10;
        mi.IH_Item_Classification__c = 'Cooler';
        
        insert mi;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        
        mp.Name = 'Budweiser - Hockey';
        mp.Brand__c = brd.Id;
        mp.Business_Line__c = 'Out of Home';
        mp.Planning_End_Date__c = Date.today();
        mp.Planning_Start_Date__c = Date.today();
        mp.Program_End_Date__c = Date.today();
        mp.Program_Start_Date__c = Date.today();
        
        insert mp;
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.ExternalKey__c = '123';
        mpi.Marketing_Program__c = mp.Id;
        mpi.Marketing_Item__c = mi.Id;
        insert mpi;
        
        Marketing_Kit__c mk = new Marketing_Kit__c();
        mk.Name = 'test';
        mk.Marketing_Program_Name__c = mp.Id;
        mk.RecordTypeId = WsRecId;
        mk.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk.POC_Spend_Category__c=pocObj.id;
        insert mk;
        
        Marketing_Kit__c mk2 = new Marketing_Kit__c();
        mk2.Name = 'test';
        mk2.Marketing_Program_Name__c = mp.Id;
        mk2.RecordTypeId = WsRecId;
        mk2.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk2.POC_Spend_Category__c=pocObj.id;
        insert mk2;
        
        OnPlan_to_OnPoint_Budget_Batch btch = new OnPlan_to_OnPoint_Budget_Batch();      
        OnPlan_to_OnPoint_Budget_Batch btch1 = new OnPlan_to_OnPoint_Budget_Batch('Program1');
        
        Test.startTest();
       // Database.executebatch(btch);
        Database.executebatch(btch1);
        Test.stopTest();
    }
    static testMethod void myUnitTestSix() 
    {
               
        List<OnPoint_District__c> districtList = OnPoint_TestUtil.createDistrict(1);
        insert districtList;
        
        List<OnPoint_Territory__c> territoryList = OnPoint_TestUtil.createTerritory(1, districtList[0].id);
        insert territoryList;
        
        Id WsRecId = [Select Id, Name from RecordType where developername = 'IH_Assigned_Preconfigured' limit 1].Id;
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c brd = new Brand__c();
        brd.Name= 'Corona';
        brd.OnPoint_Brand_Name__c ='Corona';
        brd.RecordTypeId=brandRecId;
        insert brd;
        
        OnPoint_Brand__c obBrand=new OnPoint_Brand__c();
        obBrand.Name='Corona';
        obBrand.Brand_Name__c='Corona';
        insert obBrand;
        
        Account accToInsert = TestUtils.createTestAccount('Test_Account','Outlet', null);
        accToInsert.lboc_Channel__c='OFF';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert;
        
        Account accToInsert2 = TestUtils.createTestAccount('Test_Account2','Outlet', null);
        accToInsert2.lboc_Channel__c='OFF';
        accToInsert2	.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert2;
        
        Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
        aab.Budget_Year__c = '2019';
        insert aab;
        
        Annual_POC_Budget_Plan__c apb=new Annual_POC_Budget_Plan__c();
        apb.Account__c=accToInsert.Id;
        apb.Annual_Territory_Budget__c=aab.id;    
        insert apb;
        
        Annual_POC_Budget_Plan__c apb2=new Annual_POC_Budget_Plan__c();
        apb2.Account__c=accToInsert2.Id;
        apb2.Annual_Territory_Budget__c=aab.id;    
        insert apb2;
        
        
        Id pocRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation_Out_of_Home' limit 1].Id;

        POC_Spend_Category__c pocObj=new POC_Spend_Category__c();
        pocObj.Annual_POC_Budget_Plan__c=apb.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj;
        
        POC_Spend_Category__c pocObj2=new POC_Spend_Category__c();
        pocObj2.Annual_POC_Budget_Plan__c=apb2.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj2;
        
        Annual_Brand_Area_Budget_Plan__c app = new Annual_Brand_Area_Budget_Plan__c();
        app.Brand__c = brd.Id;
        app.Annual_Area_Budget__c = aab.Id;
        insert app;
        
        Id occrec = [Select Id from RecordType where developername = 'Brand_Cost_Center' limit 1].Id;
        OnPoint_Cost_Centers__c occ = new OnPoint_Cost_Centers__c();
        occ.Name = 'Corona';
        occ.Type__c = 'Corona';
        occ.Brand__c=obBrand.id;
        //occ.User_Friendly_Name__c='Corona';
        occ.RecordTypeId= occrec;
        insert occ;
        
        OnPoint_GLs__c ogl= new OnPoint_GLs__c();
        ogl.Name='Brand On Premise';
        ogl.User_Friendly_Name__c='Brand On Premise';
        ogl.GL_Code__c='ogl_2020';
        insert ogl;
        
       
            
        OnPoint_GLs__c ogl1= new OnPoint_GLs__c();
        ogl1.Name='Brand Retail';
        ogl1.User_Friendly_Name__c='Brand Retail';
        ogl1.GL_Code__c='ogl_2022';
        insert ogl1;
        
        Marketing_Item__c mi = new Marketing_Item__c();
        mi.Name = 'Corona - Coasters';
        mi.Brand__c = brd.Id;
        mi.Full_Price_to_Rep__c = 10;
        mi.IH_Item_Classification__c = 'Cooler';
        
        insert mi;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        
        mp.Name = 'Budweiser - Hockey';
        mp.Brand__c = brd.Id;
        mp.Business_Line__c = 'Out of Home';
        mp.Planning_End_Date__c = Date.today();
        mp.Planning_Start_Date__c = Date.today();
        mp.Program_End_Date__c = Date.today();
        mp.Program_Start_Date__c = Date.today();
        
        insert mp;
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.ExternalKey__c = '123';
        mpi.Marketing_Program__c = mp.Id;
        mpi.Marketing_Item__c = mi.Id;
        insert mpi;
        
        Marketing_Kit__c mk = new Marketing_Kit__c();
        mk.Name = 'test';
        mk.Marketing_Program_Name__c = mp.Id;
        mk.RecordTypeId = WsRecId;
        mk.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk.POC_Spend_Category__c=pocObj.id;
        insert mk;
        
        Marketing_Kit__c mk2 = new Marketing_Kit__c();
        mk2.Name = 'test';
        mk2.Marketing_Program_Name__c = mp.Id;
        mk2.RecordTypeId = WsRecId;
        mk2.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk2.POC_Spend_Category__c=pocObj.id;
        insert mk2;
        
        OnPlan_to_OnPoint_Budget_Batch btch = new OnPlan_to_OnPoint_Budget_Batch();
        
        Test.startTest();
        
        Database.executebatch(btch);
        
        Test.stopTest();
    }
     static testMethod void myUnitTestSecondReplica() 
    {
        
        List<OnPoint_District__c> districtList = OnPoint_TestUtil.createDistrict(1);
        insert districtList;
        
        List<OnPoint_Territory__c> territoryList = OnPoint_TestUtil.createTerritory(1, districtList[0].id);
        insert territoryList;
        
        List<OnPoint_Territory_Budget__c> terrBudgetList = OnPoint_TestUtil.createTerritoryBudget(territoryList[0]);
        insert terrBudgetList;
 
        
        Id WsRecId = [Select Id, Name from RecordType where developername = 'IH_Assigned_Preconfigured' limit 1].Id;
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c brd = new Brand__c();
        brd.Name= 'Corona';
        brd.OnPoint_Brand_Name__c ='Corona';
        brd.RecordTypeId=brandRecId;
        insert brd;
        
        OnPoint_Brand__c obBrand=new OnPoint_Brand__c();
        obBrand.Name='Corona';
        obBrand.Brand_Name__c='Corona';
        insert obBrand;
        
        Account accToInsert = TestUtils.createTestAccount('Test_Account','Outlet', null);
        accToInsert.lboc_Channel__c='OFF';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert;
        
        Account accToInsert2 = TestUtils.createTestAccount('Test_Account2','Outlet', null);
        accToInsert2.lboc_Channel__c='OFF';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert2;
        
        Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
        aab.Budget_Year__c = '2019';
        insert aab;
        
        Annual_POC_Budget_Plan__c apb=new Annual_POC_Budget_Plan__c();
        apb.Account__c=accToInsert.Id;
        apb.Annual_Territory_Budget__c=aab.id;    
        insert apb;
        
        Annual_POC_Budget_Plan__c apb2=new Annual_POC_Budget_Plan__c();
        apb2.Account__c=accToInsert2.Id;
        apb2.Annual_Territory_Budget__c=aab.id;    
        insert apb2;
        
        Id pocRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation_Out_of_Home' limit 1].Id;

        POC_Spend_Category__c pocObj=new POC_Spend_Category__c();
        pocObj.Annual_POC_Budget_Plan__c=apb.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj;
        
        POC_Spend_Category__c pocObj2=new POC_Spend_Category__c();
        pocObj2.Annual_POC_Budget_Plan__c=apb2.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj2;
        
        Annual_Brand_Area_Budget_Plan__c app = new Annual_Brand_Area_Budget_Plan__c();
        app.Brand__c = brd.Id;
        app.Annual_Area_Budget__c = aab.Id;
        insert app;
        
        Id occrec = [Select Id from RecordType where developername = 'Brand_Cost_Center' limit 1].Id;
        OnPoint_Cost_Centers__c occ = new OnPoint_Cost_Centers__c();
        occ.Name = 'Corona';
        occ.Type__c = 'Corona';
        occ.Brand__c=obBrand.id;
        //occ.User_Friendly_Name__c='Corona';
        occ.RecordTypeId= occrec;
        insert occ;
        
        OnPoint_GLs__c ogl= new OnPoint_GLs__c();
        ogl.Name='Brand On Premise';
        ogl.User_Friendly_Name__c='Brand On Premise';
        ogl.GL_Code__c='ogl_2020';
        insert ogl;
        
       
            
        OnPoint_GLs__c ogl1= new OnPoint_GLs__c();
        ogl1.Name='Brand Retail';
        ogl1.User_Friendly_Name__c='Brand Retail';
        ogl1.GL_Code__c='ogl_2022';
        insert ogl1;
        
        Marketing_Item__c mi = new Marketing_Item__c();
        mi.Name = 'Corona - Coasters';
        mi.Brand__c = brd.Id;
        mi.Full_Price_to_Rep__c = 10;
        mi.IH_Item_Classification__c = 'Cooler';
        
        insert mi;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        
        mp.Name = 'Budweiser - Hockey';
        mp.Brand__c = brd.Id;
        mp.Business_Line__c = 'Out of Home';
        mp.Planning_End_Date__c = Date.today();
        mp.Planning_Start_Date__c = Date.today();
        mp.Program_End_Date__c = Date.today();
        mp.Program_Start_Date__c = Date.today();
        
        insert mp;
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.ExternalKey__c = '123';
        mpi.Marketing_Program__c = mp.Id;
        mpi.Marketing_Item__c = mi.Id;
        insert mpi;
        
        Marketing_Kit__c mk = new Marketing_Kit__c();
        mk.Name = 'test';
        mk.Marketing_Program_Name__c = mp.Id;
        mk.RecordTypeId = WsRecId;
        mk.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk.POC_Spend_Category__c=pocObj.id;
        insert mk;
        
        Marketing_Kit__c mk2 = new Marketing_Kit__c();
        mk2.Name = 'test';
        mk2.Marketing_Program_Name__c = mp.Id;
        mk2.RecordTypeId = WsRecId;
        mk2.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk2.POC_Spend_Category__c=pocObj.id;
        insert mk2;
        
        OnPlan_to_OnPoint_Budget_Batch btch = new OnPlan_to_OnPoint_Budget_Batch();
        
        Test.startTest();
        
        Database.executebatch(btch);
        
        Test.stopTest();
    }
    static testMethod void myUnitTestEight() 
    {
        
        List<OnPoint_District__c> districtList = OnPoint_TestUtil.createDistrict(1);
        insert districtList;
        
        List<OnPoint_Territory__c> territoryList = OnPoint_TestUtil.createTerritory(1, districtList[0].id);
        insert territoryList;
        
        List<OnPoint_Territory_Budget__c> terrBudgetList = OnPoint_TestUtil.createTerritoryBudget(territoryList[0]);
        insert terrBudgetList;
 
        
        Id WsRecId = [Select Id, Name from RecordType where developername = 'IH_Assigned_Preconfigured' limit 1].Id;
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c brd = new Brand__c();
        brd.Name= 'Corona';
        brd.OnPoint_Brand_Name__c ='Corona';
        brd.RecordTypeId=brandRecId;
        brd.User_Paid__c=true;
        insert brd;
        
        OnPoint_Brand__c obBrand=new OnPoint_Brand__c();
        obBrand.Name='Corona';
        obBrand.Brand_Name__c='Corona';
        insert obBrand;
        
        Account accToInsert = TestUtils.createTestAccount('Test_Account','Outlet', null);
        accToInsert.lboc_Channel__c='OFF';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert;
        
        Account accToInsert2 = TestUtils.createTestAccount('Test_Account2','Outlet', null);
        accToInsert2.lboc_Channel__c='OFF';
        accToInsert.OnPoint_Sales_Territory__c=territoryList[0].id;
        insert accToInsert2;
        
        Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
        aab.Budget_Year__c = '2019';
        insert aab;
        
        Annual_POC_Budget_Plan__c apb=new Annual_POC_Budget_Plan__c();
        apb.Account__c=accToInsert.Id;
        apb.Annual_Territory_Budget__c=aab.id;    
        insert apb;
        
        Annual_POC_Budget_Plan__c apb2=new Annual_POC_Budget_Plan__c();
        apb2.Account__c=accToInsert2.Id;
        apb2.Annual_Territory_Budget__c=aab.id;    
        insert apb2;
        
        Id pocRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation_Out_of_Home' limit 1].Id;

        POC_Spend_Category__c pocObj=new POC_Spend_Category__c();
        pocObj.Annual_POC_Budget_Plan__c=apb.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj;
        
        POC_Spend_Category__c pocObj2=new POC_Spend_Category__c();
        pocObj2.Annual_POC_Budget_Plan__c=apb2.id;
        pocObj.RecordTypeId=pocRecId;
        insert pocObj2;
        
        Annual_Brand_Area_Budget_Plan__c app = new Annual_Brand_Area_Budget_Plan__c();
        app.Brand__c = brd.Id;
        app.Annual_Area_Budget__c = aab.Id;
        insert app;
        
        Id occrec = [Select Id from RecordType where developername = 'Territory_Cost_Center' limit 1].Id;
        OnPoint_Cost_Centers__c occ = new OnPoint_Cost_Centers__c();
        occ.Name = 'Corona';
        occ.Type__c = 'User Paid Off Prem';
        occ.Territory__c=territoryList[0].id;        
        occ.Brand__c=obBrand.id;
       // occ.User_Friendly_Name__c='Corona';
        occ.RecordTypeId = occrec;
        insert occ;
        
         OnPoint_Cost_Centers__c occ1 = new OnPoint_Cost_Centers__c();
        occ1.Name = 'Corona';
        occ1.Type__c = 'User Retail';
        occ1.Territory__c=territoryList[0].id;        
        occ1.Brand__c=obBrand.id;
        //occ.User_Friendly_Name__c='Corona';
        occ1.RecordTypeId= occrec;
        insert occ1;
        
        OnPoint_GLs__c ogl= new OnPoint_GLs__c();
        ogl.Name='User Retail';
        ogl.User_Friendly_Name__c='User Retail';
        ogl.GL_Code__c='ogl_2020';
        insert ogl;
        
       
            
        OnPoint_GLs__c ogl1= new OnPoint_GLs__c();
        ogl1.Name='User On Premise';
        ogl1.User_Friendly_Name__c='User On Premise';
        ogl1.GL_Code__c='ogl_2022';
        insert ogl1;
        
        Marketing_Item__c mi = new Marketing_Item__c();
        mi.Name = 'Corona - Coasters';
        mi.Brand__c = brd.Id;
        mi.Full_Price_to_Rep__c = 10;
        mi.IH_Item_Classification__c = 'Cooler';
        
        insert mi;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        
        mp.Name = 'Budweiser - Hockey';
        mp.Brand__c = brd.Id;
        mp.Business_Line__c = 'In Home';
        mp.Planning_End_Date__c = Date.today();
        mp.Planning_Start_Date__c = Date.today();
        mp.Program_End_Date__c = Date.today();
        mp.Program_Start_Date__c = Date.today();
        
        insert mp;
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.ExternalKey__c = '123';
        mpi.Marketing_Program__c = mp.Id;
        mpi.Marketing_Item__c = mi.Id;
        insert mpi;
        
        Marketing_Kit__c mk = new Marketing_Kit__c();
        mk.Name = 'test';
        mk.Marketing_Program_Name__c = mp.Id;
        mk.RecordTypeId = WsRecId;
        mk.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk.POC_Spend_Category__c=pocObj.id;
        insert mk;
        
        Marketing_Kit__c mk2 = new Marketing_Kit__c();
        mk2.Name = 'test';
        mk2.Marketing_Program_Name__c = mp.Id;
        mk2.RecordTypeId = WsRecId;
        mk2.Annual_Brand_Area_Budget_Plan__c = app.id;
        mk2.POC_Spend_Category__c=pocObj.id;
        insert mk2;
        
        OnPlan_to_OnPoint_Budget_Batch btch = new OnPlan_to_OnPoint_Budget_Batch();
        
        Test.startTest();
        
        Database.executebatch(btch);
        
        Test.stopTest();
    }
    
}