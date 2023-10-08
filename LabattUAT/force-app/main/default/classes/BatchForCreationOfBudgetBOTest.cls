@isTest
public class BatchForCreationOfBudgetBOTest {
    
     static testMethod void testMethod1(){
         Annual_Area_Budget__c objAABParent=new Annual_Area_Budget__c ();
            objAABParent.Budget_Year__c=String.valueOf('2019');
            objAABParent.District_Name__c='National';
            objAABParent.RecordTypeId=Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH District').getRecordTypeId();
         //insert objAABParent;
         
         lboc_Sales_Territory__c lboc = new lboc_Sales_Territory__c();
        lboc.lboc_Territory_ID__c = '64312';
         lboc.Back_Office_Territory__c=true;
        insert lboc;
         
         
         
         test.startTest();
         BatchForCreationOfBudgetBO objBO=new BatchForCreationOfBudgetBO('2019', 'OutOfHome');
        Database.executeBatch(objBO);
         test.stopTest();
         
         
         
     }
    static testMethod void testMethod2(){
        Annual_Area_Budget__c objAABParent=new Annual_Area_Budget__c ();
            objAABParent.Budget_Year__c=String.valueOf('2019');
            objAABParent.District_Name__c='National';
            objAABParent.RecordTypeId=Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH District').getRecordTypeId();
       //  insert objAABParent;
         
         lboc_Sales_Territory__c lboc = new lboc_Sales_Territory__c();
        lboc.lboc_Territory_ID__c = '64312';
         lboc.Back_Office_Territory__c=true;
        insert lboc;
         
         
         test.startTest();
         BatchForCreationOfBudgetBO objBOA=new BatchForCreationOfBudgetBO('2019', 'InHome');
        Database.executeBatch(objBOA);
         test.stopTest();
    }
	
}