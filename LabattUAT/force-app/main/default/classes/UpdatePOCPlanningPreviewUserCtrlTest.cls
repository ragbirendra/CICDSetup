@isTest
public class UpdatePOCPlanningPreviewUserCtrlTest {
    static testMethod void myUnitTest(){
        
        List<TAUserViewRefrence__c> prevUserTotalList = new List<TAUserViewRefrence__c>();
        TAUserViewRefrence__c  prevUserList = new TAUserViewRefrence__c();
        prevUserList.Name='Test';
        prevUserList.previewAs__c='Preview as Test';
        prevUserList.user_Email_Id__c='Test@labatt.com';
        insert prevUserList;
        
        TAUserViewRefrence__c  prevUserList1 = new TAUserViewRefrence__c();
        prevUserList1.Name='TestAgain';
        prevUserList1.previewAs__c='Preview as TestAgain';
        prevUserList1.user_Email_Id__c='TestAgain@labatt.com';
        insert prevUserList1;
        UpdatePOCPlanningPreviewUserCtrl.fetchSetupPreviewUsers();
        
        prevUserList1.user_Email_Id__c='TestAgainUpdate@labatt.com';
        prevUserTotalList.add(prevUserList);
        prevUserTotalList.add(prevUserList1);
        
        UpdatePOCPlanningPreviewUserCtrl.savePreviewOpr(prevUserTotalList);
        UpdatePOCPlanningPreviewUserCtrl testz= new UpdatePOCPlanningPreviewUserCtrl();
    }
}