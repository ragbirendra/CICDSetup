@isTest
public class UpdatePOCPlanningItemsCtrlTest {
static testMethod void myUnitTest(){
    
    RecordType rt = [select id, DeveloperName from RecordType where SobjectType = 'Brand__c' and DeveloperName = 'Trade_Activation' Limit 1];
      
        Brand__c brd = new Brand__c();
        brd.Name = 'Corona';
        brd.RecordTypeID = rt.id;
        insert brd;
    
    Marketing_Item__c mktItem = new Marketing_Item__c();
    
    mktItem.Name='Corona - CoastersTest';
   	mktItem.brand__c = brd.id;
    mktItem.Item_Number__c ='7525723';
    mktItem.Price__c= 3.98;
    mktItem.Is_Available__c= true;
    mktItem.Item_Description_EN__c='Coron Corona Test';
    mktItem.Item_Description_FR__c='Corona Test';
    mktItem.Item_Unit_of_Measure__c='Qty';
    mktItem.Items_Product_Type__c='Test type';
 
    insert mktItem;
    
        
    Attachment att = new Attachment();
      	att.Name = 'test';
      	Blob b=Blob.valueOf('Unit Test Attachment Body');
        att.body = Blob.valueOf('Unit Test Attachment Body');
        att.parentId = mktItem.id;
    
        insert att;
        
    UpdatePOCPlanningItemsCtrl tezst =new UpdatePOCPlanningItemsCtrl();
    UpdatePOCPlanningItemsCtrl.fetchItem('7525723');
    UpdatePOCPlanningItemsCtrl.SaveFile(mktItem.id,'test','test attachment','application/pdf');
	UpdatePOCPlanningItemsCtrl.fetchURL();
    
	}
       
}