@isTest
public class UpdateAreaBudgetStatusTest {
 static testMethod void myUnitTest() {

     POC_Planning_Setup_Admin__c ppsa = new POC_Planning_Setup_Admin__c();
     Date myDate = Date.today();
     
     ppsa.Plan_Start_Date__c = mydate.addDays(2);
     ppsa.Plan_End_Date__c = mydate.addDays(2);
     ppsa.Business_Line__c = 'In Home (IH)';
     ppsa.Budget_Year__c = '2020';
     ppsa.Type__c = 'Driver POCM Forecast';
     insert ppsa;
     
     Id devRecordTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH Territory').getRecordTypeId();
     
     Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
     aab.Budget_Year__c = '2020';
     aab.Approval_Status__c = 'Approved';
     aab.RecordTypeId = devRecordTypeId;
     insert aab;
     
     system.debug('****'+aab);
     
     UpdateAreaBudgetStatus btch = new UpdateAreaBudgetStatus();
     Database.executebatch(btch);
 }
}