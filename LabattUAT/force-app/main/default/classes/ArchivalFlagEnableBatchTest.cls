@isTest 
public class ArchivalFlagEnableBatchTest 
{
    static testMethod void testArchivalEnableBatch() 
    {
       
        //Insert BudgetLoadUI,Program Brand Item and shopped Kit record

         NAZ_OP_Shopkit_Data__c shopkitData = new NAZ_OP_Shopkit_Data__c();
         
            shopkitData.externalIdField__c                = 'test_1234';
            shopkitData.Shopped_Kit_Name__c               = 'test';
            shopkitData.Program_Name__c                   = 'program';
            shopkitData.Shopkit_Start_Date__c             = '11/11/2020';
            shopkitData.Shopkit_End_Date__c               = '11/11/2020';
            shopkitData.Status_of_Approval__c             = 'Loaded'; 
            shopkitData.Shopkit_Price__c                  = '30';
            shopkitData.Shopkit_SAP_Number__c             = '1234';
            shopkitData.Shopkit_Temporary_Item_Numbers__c = 'test1';
            shopkitData.Shopkit_Qty__c                    =  2; 
            shopkitData.archival_Flag__c=false;
            
            insert shopkitData;
        
          Datetime createdatee=Datetime.now().addDays(-1200);
          Test.setCreatedDate(shopkitData.Id, createdatee);
        
           BudgetLoadUI__c BudgetData = new BudgetLoadUI__c();
            BudgetData.District_Code__c = '123';
            BudgetData.District_Name__c = 'test';
            BudgetData.Year__c = '2020';
            
            BudgetData.Business_Line__c= 'Out of Home';
            BudgetData.Region__c = 'Test';
            
            BudgetData.Territory_Name__c = 'Test2';
            BudgetData.Territory_Code__c = '123';
           // BudgetData.Territory_Record_Type__c ='OOH Terrritory';
            BudgetData.Discretionary_Budget__c = 3.44;
            BudgetData.archival_Flag__c=false;
            insert BudgetData;
            
          Datetime createdatee1=Datetime.now().addDays(-1200);
          Test.setCreatedDate(BudgetData.Id, createdatee1);
        
           Program_Brands_Item__c program=new Program_Brands_Item__c();
           program.Name='Program Brands Item Name';
           program.Brand_Name__c='Bud Light';
           program.Business_Line__c='Out of Home';
           program.archival_Flag__c=false;
           insert program;  
        
        Datetime createdatee2=Datetime.now().addDays(-1200);
          Test.setCreatedDate(program.Id, createdatee2);
        
        Test.startTest();
            ArchivalFlagEnableBatch obj = new ArchivalFlagEnableBatch();
            DataBase.executeBatch(obj);   
        Test.stopTest();
    }
}