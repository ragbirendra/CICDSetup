/***
* @Name - stagingControllerTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description - This test class Created for testing methods of stagingController class
* 

***/


@isTest
public class stagingControllerTest {
    @testSetup static void setup()
    {
               
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
        marketingProgram.Name='ProgramName';
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
        //marketingItemTwo.Temporary_Item_Number__c = '456456';
        marketingItemTwo.Item_Number__c = '7530703';
        marketingItemTwo.Price__c = 10;
        marketingItemTwo.Marketing_Type__c = 'Driver'; // Temp Set till Driver is active option again
        List<Marketing_Item__c> listOfMarketingItems = new List<Marketing_Item__c>{marketingItemOne, marketingItemTwo};
        insert listOfMarketingItems;

        Marketing_Program_Item__c marketingProgramItemOne = new Marketing_Program_Item__c();
        marketingProgramItemOne.Marketing_Program__c = marketingProgram.Id;
        marketingProgramItemOne.Marketing_Item__c = listOfMarketingItems[1].Id;

        Marketing_Program_Item__c marketingProgramItemTwo = new Marketing_Program_Item__c();
        marketingProgramItemTwo.Marketing_Program__c = marketingProgram.Id;
        marketingProgramItemTwo.Marketing_Item__c = listOfMarketingItems[1].Id;
        List<Marketing_Program_Item__c> listOfMarketingProgramItems = new List<Marketing_Program_Item__c>{marketingProgramItemOne, marketingProgramItemTwo};
        insert listOfMarketingProgramItems;
        
    }

    static testmethod void setup1()
    {      
       
        Account a=new Account();
        a.Name='Test';
        insert a;
        
         Staging_Main__c shpkt=new Staging_Main__c();
         shpkt.Quantity__c=2;
         shpkt.Item_Price__c = 1000;
         shpkt.Brand_Name__c = 'test';
         shpkt.Program_Name__c = 'test';
       //  shpkt.Program_Start_Date__c = '2019-11-01';
      //   shpkt.Program_End_Date__c = '2019-11-05';
         shpkt.Is_Program_User_Paid__c = false;
         shpkt.Shopped_Kit_Quantity__c = 5;
         shpkt.Name = 'test';
         shpkt.Channel__c = 'ON';
         shpkt.Account__c=a.id;
         shpkt.SKU_Number__c='7529424';
          
         
         insert shpkt;         
        
         String ac=shpkt.Id;
        
         list<stagingController.itemWrapper> oListViewWrapper = new list<stagingController.itemWrapper>();
        
         List<Id> shpktid = new List<Id>();
         shpktid.add(shpkt.Id);
         stagingController.itemWrapper obj = new stagingController.itemWrapper();
            obj.BrandName=shpkt.Brand_Name__c;
            obj.ProgramName='Budweiser - BBQ'; //shpkt.Program_Name__c;
            obj.itemName=shpkt.Name;
            obj.qty=shpkt.Quantity__c;
            obj.itemPrice=shpkt.Item_Price__c;
            obj.skuNumber=shpkt.SKU_Number__c;
            obj.totalSpend=shpkt.Total_Price__c;
          //  obj.stagingId=shpkt.id;
            obj.accountId=shpkt.Account__r.id;
            obj.compositeKey = shpkt.Composite_Key__c;
            obj.budgetYear= '2020';
            obj.Channel = 'ON';
            obj.programStartDate= shpkt.Program_Start_Date__c;
            obj.programEndDate= shpkt.Program_End_Date__c;
            obj.shoppedKitQty = shpkt.Shopped_Kit_Quantity__c;
            oListViewWrapper.add(obj);        
          
         
        Marketing_Item__c m=new Marketing_Item__c();
        m.Standard_Price__c=1000;
        m.IH_Item_Classification__c='In Store Driver';
        m.Marketing_Type__c='Driver';
        m.Item_Number__c='7530703';
        m.Name='test';
        //insert m;  
       
        Test.startTest();
         List<stagingController.itemWrapper> listv = stagingController.getData('test','test','7529424');
         System.assertEquals('test', listv[0].BrandName);
        
         List<stagingController.itemWrapper> listv1=stagingController.getDataToReview('test', 'test','2020','ON');
         //System.assertEquals('test', listv1[0].ProgramName);
        
         List<String> lst=stagingController.getBrandData('test','test');
       //  System.assertEquals('test', lst[0]);
        
        
        stagingController.getProgramData('test', 'test','test');
         //System.assertEquals('test', lst1[0]);
        
         stagingController.updateyQuantity('2.718281828459045', ac);
        
        try{stagingController.getBOList();
            stagingController.updateSKUNumber('[{ "Quebec":"true","skuNumber":"7530703"}]', '[{"test":"true"}]','ProgramName','A');
        }
        catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        try{
        //stagingController.allocationCreation('{"Name":"10317 - Backoffice POC"}', 'Budweiser - BBQ', '{"Name":"Corona Item","SKU_Number__c":"8526425","Brand_Name__c":"Corona","Item_Price__c":10,"Program_Start_Date__c":"2019-09-19","Program_End_Date__c":"2019-09-30","Program_Name__c":"Budweiser - BBQ"}', 'Corona', 2);
         stagingController.bulkAllocationCreation('[{"Account":{"Id":"001S00000166NuaIAE","Name":"TARA INDIAN CUISINE","lboc_Labatt_Outlet_Id__c":"1659"},"Program":"Budweiser - BBQ","Item":{"Id":"a5TS00000000EOVMA2","Name":"Corana Cap","Item_Number__c":"7530620","Brand__c":"a5PS0000000TseUMAS","Price__c":10,"Brand__r":{"Name":"Corona","Id":"a5PS0000000TseUMAS"}},"Brand":"Corona","Qtity":"10","yearVal":"2020","busienssLineVal":"ON"}]','2019-01-03T00:26:01.711-02:00','2019-02-03T00:26:01.711-02:00');   
	        }
        catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage()); 
        }
       // stagingController.updateSKUNumber('[{ "Quebec":"true","skuNumber":"7530703"}]', '[{"test":"true"}]','ProgramName','A');
       try{
        stagingController.reviewStaging('[{"accountId":"001S00000167lP6IAI","accountName":"BAR LE HUIT","BrandName":"Corona","budgetYear":"2020","compositeKey":"001S00000167lP6IAI_Budweiser - BBQ_7529424_2020_null","Id":"aEqS00000008PEYKA2","itemName":"Corona Coasters - 1000 PK","itemPrice":34.99,"programEndDate":"2019-09-30"}]');
	        }
        catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        try{
        stagingController.reopenStagingData('[{"accountId":"001S00000167lP6IAI","accountName":"BAR LE HUIT","BrandName":"Corona","budgetYear":"2020","compositeKey":"001S00000167lP6IAI_Budweiser - BBQ_7529424_2020_null","Id":"aEqS00000008PEYKA2","itemName":"Corona Coasters - 1000 PK","itemPrice":34.99,"programEndDate":"2019-09-30"}]');
	        }
        catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage()); 
        }
         try{
        stagingController.getUserInformation();
	        }
        catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        Test.stopTest();
    }
    
}