@isTest
public class POCPKIVolDiscUpdateCtrlTest {
    
    static testMethod void myUnitTest(){
        // create onplan territory
        
        
        Id devRecordTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH Territory').getRecordTypeId();
        // Create Territory budget
        List<Annual_Area_Budget__c> aablist = new List<Annual_Area_Budget__c>();
        Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
        Annual_Area_Budget__c aab1 = new Annual_Area_Budget__c();
        aab.Budget_Year__c = '2020';
        aab.Approval_Status__c = 'Approved';
        aab.RecordTypeId = devRecordTypeId;
        aab.Drivers_Budget__c=501;
      
        aab1.Budget_Year__c = '2019';
        aab1.Approval_Status__c = 'Approved';
        aab1.RecordTypeId = devRecordTypeId;
        aab1.Drivers_Budget__c=501;
        
        aablist.add(aab);
        aablist.add(aab1);
        
        insert aablist;
        
       
        
        POCPKIVolDiscUpdateCtrl.fetchAllAABRecords('2019', 'Out of Home');
        POCPKIVolDiscUpdateCtrl.fetchAllAABRecords('2019', 'In Home');
        POCPKIVolDiscUpdateCtrl.FetchKIVolumeBudgetRecords('In Home', 2019);
        POCPKIVolDiscUpdateCtrl.FetchKIVolumeBudgetRecords('Out of Home', 2019);
        POCPKIVolDiscUpdateCtrl.updateTerrKIAndDisc(aablist);
        
    }
}