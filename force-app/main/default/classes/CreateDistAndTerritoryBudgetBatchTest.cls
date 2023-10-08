/***
* @Name - CreateDistAndTerritoryBudgetBatchTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description - This test class Created for testing methods of CreateDistAndTerritoryBudgetBatch  class
* 

***/

@isTest
public class CreateDistAndTerritoryBudgetBatchTest {
    
     @testSetup static void setup()
     {
         List<BudgetLoadUI__c> BudgetLoadUI= new List<BudgetLoadUI__c>();
         List<Annual_Area_Budget__c> AnuAreaBud= new List<Annual_Area_Budget__c>();
        
        OnPoint_District__c od = new OnPoint_District__c();
        od.Name = '10102 - NEW BRUNSWICK (District)';
        od.District_Code__c='10102';
        od.Area_Code__c ='10102';
        insert od;
        
        lboc_Sales_Territory__c lb = new lboc_Sales_Territory__c();
        lb.name ='test';
        lb.lboc_Territory_ID__c ='102';
        insert lb;
        
        for(Integer i=0 ;i <2;i++)
        {
            BudgetLoadUI__c acc = new BudgetLoadUI__c();
            acc.District_Name__c ='Name'+i;
            acc.District_Code__c='10102';
            acc.Territory_Code__c='102';
            acc.Business_Line__c='Out of Home';
            acc.District_Record_Type__c='OOH District';
            acc.Territory_Record_Type__c='OOH Territory';
            acc.Status__c='New';
            acc.Year__c = string.valueof(date.today().year());
            BudgetLoadUI.add(acc);
            
            Annual_Area_Budget__c anb = new Annual_Area_Budget__c();
            anb.External_key_Dist__c = acc.District_Code__c+'_'+date.today().year()+acc.Business_Line__c;
            anb.Budget_Year__c = string.valueof(date.today().year());
            AnuAreaBud.add(anb);
            
        }
        insert AnuAreaBud;
        insert BudgetLoadUI;
        
     }

    static testMethod void myUnitTest() 
    {
              
        CreateDistAndTerritoryBudgetBatch obj = new CreateDistAndTerritoryBudgetBatch();        
        Test.startTest();        
        DataBase.executeBatch(obj);             
        Test.stopTest();
    }
}