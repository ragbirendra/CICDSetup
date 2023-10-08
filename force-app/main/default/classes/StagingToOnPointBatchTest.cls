/***
* @Name - StagingToOnPointBatchTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description - This test class Created for testing methods of StagingToOnPointBatch  class
* 

***/

@isTest
public class StagingToOnPointBatchTest {
    
     @testSetup static void setup()
     {
           Account accobj = new Account(Name='test');
         insert accobj;
         List<Staging_Main__c> BudgetLoadUI= new List<Staging_Main__c>();
        for(Integer i=0 ;i <20;i++)
        {
            Staging_Main__c acc = new Staging_Main__c();
            acc.Program_Name__c ='Name'+i;
            acc.Brand_Name__c='test'+i;
            if(i == 0)
                acc.OnPoint_Product_Id__c = null;
            else
            	acc.OnPoint_Program_Id__c='Success'+i;
            acc.Account__c = accobj.Id;
            acc.Data_Reviewed__c=true;
            acc.Program_Start_Date__c= System.today();
            acc.Program_Start_Date__c= System.today()+15;
            BudgetLoadUI.add(acc);
        }
        
        insert BudgetLoadUI;          
     }

     static testMethod void myUnitTest() {
                
        StagingToOnPointBatch bt = new StagingToOnPointBatch();         
        Test.startTest();     
        Database.executebatch(bt);             
        Test.stopTest();         
         
     }
    
}