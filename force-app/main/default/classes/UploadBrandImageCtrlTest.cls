@isTest
public class UploadBrandImageCtrlTest {
    static testMethod void myUnitTest(){
         RecordType rt = [select id, DeveloperName from RecordType where SobjectType = 'Brand__c' and DeveloperName = 'Trade_Activation' Limit 1];
      
        Brand__c brd = new Brand__c();
        brd.Name = 'Corona';
        brd.RecordTypeID = rt.id;
        insert brd;
        
        Attachment att = new Attachment();
      	att.Name = 'test';

        att.body = Blob.valueOf('Unit Test Attachment Body');
        att.parentId = brd.id;
    
        insert att;
        UploadBrandImageCtrl tezst =new UploadBrandImageCtrl();
        UploadBrandImageCtrl.fetchBrandDetail();
        UploadBrandImageCtrl.fetchBrandId('Corona');
        UploadBrandImageCtrl.SaveFile(brd.id,'test','test attachment','application/pdf');
    }
}