/***
* @Name - GenericDataStampingApexTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description - This test class Created for testing methods of GenericDataStampingApex  class
* 

***/
@isTest
public class GenericDataStampingApexTest {
    
 
 static testMethod void myUnitTest() {
     
     
     List<JSON2Apex> obj=new List<JSON2Apex>();
     
     NAZ_OP_Shopkit_Data__c shpkt=new NAZ_OP_Shopkit_Data__c();
     shpkt.Shopkit_Qty__c=2.0;
     shpkt.externalIdField__c='Budweiser - Hockey - Promo_7525416';
     shpkt.Shopkit_SAP_Number__c='';
     insert shpkt;
       
     String pbitems = '[{'+
        '\"BrandName\":\"test\",'+
        '\"varCurrency\":\"USD\",'+
        '\"IsIHOnly\":\"true\",'+
        '\"ProgramName\":\" test\",'+
        '\"ProgramDescription \":\"test\",'+
        '\"ProgramStartDate\":\"2019-11-01\",'+
        '\"ProgramEndDate\":\"2019-11-05\",'+
        '\"PlanningStartDate\":\" 2019-11-01\",'+
        '\"PlanningEndDate \":\"2019-11-05\",'+
        '\"BusinessLine\":\"test\",'+       
        '\"TempItemNumber\":\"123\",'+
        '\"ProductName\":\"Test\",'+
        '\"Size\":\"1\",'+
        '\"Language \":\"English\",'+
        '\"UnitOfMeasure\":\" test\",'+
        '\"Currency2 \":\"USD\",'+
        '\"isUserPaid\":\"yes\",'+
        '\"QuantityPerUOM\":\"5\",'+
        '\"StandardPrice\":\" 10\",'+
        '\"FullPriceToRep\":\" 10\",'+
        '\"ItemType\":\"test\",'+
        '\"OOHItemClassification\":\"Promotional\",'+      
        '\"IHItemClassification\":\"Programming\",'+
        '\"Atlantic\":\" NO\",'+
        '\"Quebec\":\" NO\",'+
        '\"Ontario\":\" NO\",'+
        '\"West\":\" NO\",'+
        '\"MenuCategory \":\"test\",'+
        '\"ItemDescriptionEN\":\"test\",'+
        '\"ItemDescriptionFR\":\"test\",'+
        '\"IsAvailable\":\" true\",'+
         '\"IsAllocationOnly\":\" true\",'+
        '\"ParentProductType \":\"test\",'+
        '\"ProductType\":\"test\"'+           
        '}]';
     
       
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
       
        Program_Brands_Item__c p=new Program_Brands_Item__c();
        p.Brand_Name__c='Bud Light';
        p.Currency_a__c='CAD';
        p.Is_IH_Only__c=false;
        
        insert p;
     
       
      
 
   String pbitems2 = '[{'+
        '\"BrandName\":\"test\",'+
        '\"varCurrency\":\"USD\",'+
        '\"IsIHOnly\":\"true\",'+
        '\"ProgramName\":\" test\",'+
        '\"ProgramDescription \":\"test\",'+
        '\"ProgramStartDate\":\"2019-11-01\",'+
        '\"ProgramEndDate\":\"2019-11-05\",'+
        '\"PlanningStartDate\":\" 2019-11-01\",'+
        '\"PlanningEndDate \":\"2019-11-05\",'+
        '\"BusinessLine\":\"test\",'+       
        '\"TempItemNumber\":\"123\",'+
        '\"ProductName\":\"Test\",'+
        '\"Size\":\"1\",'+
        '\"Language \":\"English\",'+
        '\"UnitOfMeasure\":\" test\",'+
        '\"Currency2 \":\"USD\",'+
        '\"isUserPaid\":\"yes\",'+
        '\"QuantityPerUOM\":\"5\",'+
        '\"StandardPrice\":\" 10\",'+
        '\"FullPriceToRep\":\" 10\",'+
        '\"ItemType\":\"test\",'+
        '\"OOHItemClassification\":\"Promotional\",'+      
        '\"IHItemClassification\":\"Programming\",'+
        '\"Atlantic\":\" NO\",'+
        '\"Quebec\":\" NO\",'+
        '\"Ontario\":\" NO\",'+
        '\"West\":\" NO\",'+
        '\"MenuCategory \":\"test\",'+
        '\"ItemDescriptionEN\":\"test\",'+
        '\"ItemDescriptionFR\":\"test\",'+
        '\"DiscretionaryBudget\":\"12\",'+
        '\"TerritoryBrandBudget\":\"12\",'+
        '\"IsAvailable\":\" true\",'+
       '\"IsAllocationOnly\":\" true\",'+
        '\"ParentProductType \":\"test\",'+
        '\"ProductType\":\"test\"'+           
        '}]';  
        
       
        
        String BudgetPRheader = '[{'+
        '\"DistrictCode\":\"District Code",'+
        '\"DistrictName\":\"District Name\",'+
        '\"Year\":\"Year\",'+
        '\"DistrictRecordType\":\"District Record Type\",'+
        '\"Region\":\"Region\",'+
        '\"TerritoryName\":\"Territory Name\",'+
        '\"TerritoryCode\":\"Territory Code\",'+
        '\"DiscretionaryBudget\":\"Discretionary Budget\",'+
        '\"TerritoryRecordType\":\"Territory Record Type\",'+
        '\"Brand\":\"Brand\",'+
        '\"TerritoryBrandBudget\":\"Territory Brand Budget\"'+
        '}]';
        
        String BudgetPR = '[{'+
        '\"DistrictCode\":\"test\",'+
        '\"DistrictName\":\"test\",'+
        '\"Year\":\"2019\",'+
        '\"DistrictRecordType\":\"test\",'+
        '\"Region\":\" test\",'+
        '\"TerritoryName\":\"test\",'+
        '\"TerritoryCode\":\"test\",'+
        '\"DiscretionaryBudget\":\"20\",'+
        '\"TerritoryRecordType\":\" test\",'+
        '\"Brand\":\"test\",'+
        '\"TerritoryBrandBudget\":\"20\"'+
        '}]';
        
        BudgetLoadUI__c bl = new BudgetLoadUI__c();
        bl.ExternalKey__c = 'test_test_test_2019_test';
        insert bl;
        
        //string temp3 = GenericDataStampingApex.createBudgetPR('test');
        OnPoint_District__c od = new OnPoint_District__c();
        od.Name = '10102 - NEW BRUNSWICK (District)';
        od.District_Code__c='National';
        od.Area_Code__c ='10102';
        insert od;
     
        OnPoint_Territory__c ot = new OnPoint_Territory__c();
        ot.name = 'test';
        ot.Back_Office_Territory__c = true;
        insert ot;
        
        lboc_Sales_Territory__c lb = new lboc_Sales_Territory__c();
        lb.name ='test';
        lb.lboc_Territory_ID__c ='102';
        lb.Back_Office_Territory__c = true;
        lb.OnPoint_Territory__c =ot.Id;
        insert lb;
        
        
        Annual_Area_Budget__c ab = new Annual_Area_Budget__c();
        ab.Budget_Year__c = string.valueof(Date.today().year());
        ab.Sales_Territory__c =lb.Id;
        ab.RecordTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        
        insert ab;
        
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c brd = new Brand__c();
        brd.Name= 'Corona';
        brd.RecordTypeId=brandRecId;
        insert brd;
        
        Annual_Brand_Area_Budget_Plan__c anb = new Annual_Brand_Area_Budget_Plan__c();
        
        anb.Annual_Area_Budget__c = ab.Id;
        anb.Brand__c = brd.Id;
        anb.External_Id__c = 'test';
        insert anb;
        
        BudgetLoadUI__c bl1 = new BudgetLoadUI__c();
        bl1.ExternalKey__c = 'test_test_test_2019_test';
        bl1.Territory_Record_Type__c = 'New IH Territory';
        bl1.Year__c = '2019';
        insert bl1;
        //backofficeBudgetWrapper bl2 = new backofficeBudgetWrapper();
        Test.startTest();
     
        GenericDataStampingApex gen=new GenericDataStampingApex();
        GenericDataStampingApex.pushOnplanBatchExe();
        GenericDataStampingApex.createBudgetBOC('2020', 'Out of Home');
     	GenericDataStampingApex.excelheaderValidation('Budget');
    	GenericDataStampingApex.excelheaderValidation('shoppedKit');
     
     	String s=GenericDataStampingApex.createShopKitRecords('[{ "Quebec":"true","Atlantic":"true","Ontario":"true","West":"true","ShopkitQty":"2"}]');
        System.assertEquals('[{ "Quebec":"true","Atlantic":"true","Ontario":"true","West":"true","ShopkitQty":"2"}]', s);
     
        String a=GenericDataStampingApex.createBudgetPR(BudgetPR);
        System.assertEquals('[{"DistrictCode":"test","DistrictName":"test","Year":"2019","DistrictRecordType":"test","Region":" test","TerritoryName":"test","TerritoryCode":"test","DiscretionaryBudget":"20","TerritoryRecordType":" test","Brand":"test","TerritoryBrandBudget":"20"}]', a);
     
        list<BudgetLoadUI__c> lst= GenericDataStampingApex.FetchBudgetRecords('In Home', 2019);
        GenericDataStampingApex.FetchBackofficeBudgetRecords('Out of Home', 2020); 
           
        String b1 = GenericDataStampingApex.createItemRecords(pbitems2);
        List<String> terrCodeDistCode = GenericDataStampingApex.fetchDistAndTerrRecord();
       // System.assertEquals('[{ "Quebec":"true","Atlantic":"true","Ontario":"true","West":"true","ShopkitQty":"2"}]', b1);
        
       Test.stopTest();       
 
 
 }
 
 }