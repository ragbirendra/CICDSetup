/***
* @Name - ShoppedKitItemApprovalListViewTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description - This test class Created for testing methods of ShoppedKitItemApprovalListView class
* 

***/

@isTest
class ShoppedKitItemApprovalListViewTest {
    
   
   static testMethod void myUnitTest() {
        
        NAZ_OP_Shopkit_Data__c shpkt = new NAZ_OP_Shopkit_Data__c();
        shpkt.Program_Name__c = 'Test'+'_'+'2020';
        shpkt.Shopped_Kit_Name__c = 'test';
        shpkt.Status_of_Approval__c = 'Submitted for Approval';
        shpkt.Shopkit_Start_Date__c = '2019-11-01';
        shpkt.Shopkit_End_Date__c = '2019-11-05';
        shpkt.Shopkit_SAP_Number__c = 'test';
        shpkt.Shopkit_Temporary_Item_Numbers__c = 'test';
        shpkt.Shopkit_Price__c = '10';
        shpkt.Shopkit_Qty__c = 5;
        shpkt.Business_Line__c = 'Out of Home';
        shpkt.Year__c = '2020';
        insert shpkt;
       
        
        NAZ_OP_Shopkit_Data__c shp = new NAZ_OP_Shopkit_Data__c();
        shp.Program_Name__c = 'TestTest_2020';
        shp.Shopped_Kit_Name__c = 'test';
        shp.Status_of_Approval__c = 'Submitted for Approval';
        shp.Shopkit_Start_Date__c = '2019-11-01';
        shp.Shopkit_End_Date__c = '2019-11-05';
        shp.Shopkit_SAP_Number__c = 'test';
        shp.Shopkit_Temporary_Item_Numbers__c = 'test';
        shp.Shopkit_Price__c = '10';
        shp.Shopkit_Qty__c = 5;
        shp.Business_Line__c = 'Out of Home';
        shp.Year__c = '2020';
        insert shp;  
                      
        List<Id> shpktid = new List<Id>();
        shpktid.add(shpkt.Id);
       
        
        list<ShoppedKitItemApprovalListView.picklistValWrapper> oListViewWrapper = new list<ShoppedKitItemApprovalListView.picklistValWrapper>();
        ShoppedKitItemApprovalListView.picklistValWrapper oWrapper = new ShoppedKitItemApprovalListView.picklistValWrapper();
        oWrapper.recordId = shpkt.id;
        oWrapper.programName = shpkt.Program_Name__c;
        oWrapper.approvalStatus = shpkt.Status_of_Approval__c;
        oWrapper.shopedkitName = shpkt.Shopped_Kit_Name__c;
        oWrapper.shopkitStartDate = shpkt.Shopkit_Start_Date__c;
        oWrapper.shopkitEndDate = shpkt.Shopkit_End_Date__c;
        oWrapper.shopkitSAPNumber = shpkt.Shopkit_SAP_Number__c;
        oWrapper.shopkitTemporaryItemNumbers = shpkt.Shopkit_Temporary_Item_Numbers__c;
        oWrapper.shopkitPrice = shpkt.Shopkit_Price__c;
        oWrapper.shopkitQty = shpkt.Shopkit_Qty__c;
        oWrapper.year = shpkt.Year__c;
        oListViewWrapper.add(oWrapper);  
       
        Test.startTest();
       
        List<ShoppedKitItemApprovalListView.listViewWrapper> listv = ShoppedKitItemApprovalListView.listValues('Account');
    //    System.assertEquals(listv.size(), 2);
       
        List<ShoppedKitItemApprovalListView.picklistValWrapper> plistv = ShoppedKitItemApprovalListView.getPickListVals();
        System.assertEquals('Submitted for Approval', plistv[0].approvalStatus);
       
        List<ShoppedKitItemApprovalListView.picklistValWrapper> splistv = ShoppedKitItemApprovalListView.getFilteredvals('Test_2020','Submitted for Approval','Out of Home','2020'); 
         System.assertEquals('Submitted for Approval', splistv[0].approvalStatus);
       
        user u = ShoppedKitItemApprovalListView.FetchUserInfo();             
        ShoppedKitItemApprovalListView.recordsApproval('Test','Submitted for Approval','Out of Home','2020');      
        ShoppedKitItemApprovalListView.recordsRejection('TestTest_2020','Hi','Out of Home','2020');
        ShoppedKitItemApprovalListView.ApproveRecords('Test_2020','Loaded','Out of Home','2020');
        ShoppedKitItemApprovalListView.SaveRejectLoadedFailedRecord(oListViewWrapper,'Submitted for Approval');
       
       Test.stopTest();
        
   }
   
   static testMethod void myUnitTest2() {

      
       NAZ_OP_Shopkit_Data__c shpkt2 = new NAZ_OP_Shopkit_Data__c();
        shpkt2.Program_Name__c = 'newTest'+'_'+'2020';
        shpkt2.Shopped_Kit_Name__c = 'test';
        shpkt2.Status_of_Approval__c = 'Approved';
        shpkt2.Shopkit_Start_Date__c = '2019-11-11';
        shpkt2.Shopkit_End_Date__c = '2019-12-11';
        shpkt2.Shopkit_SAP_Number__c = '123456';
        shpkt2.Shopkit_Price__c = '10';
        shpkt2.Shopkit_Qty__c = 5;
        shpkt2.Business_Line__c = 'Out of Home';
        shpkt2.externalIdField__c = 'test_123456_2020_Out of Home';
        shpkt2.Year__c = '2020';
        
        insert shpkt2;
        
        List<Id> shpktlst = new List<Id>();
        shpktlst.add(shpkt2.Id);
        
       
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c br = new Brand__c();
        br.Name = 'Test';
        br.RecordTypeId=brandRecId; 
        insert br;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        mp.Name = 'newTest_2020';
        mp.Brand__c = br.id;
        insert mp;
        
        Marketing_Item__c mi = new Marketing_Item__c();
        mi.Name = 'test';
        mi.brand__c = br.id;
        mi.IH_Item_Classification__c = 'Programming';
        mi.Marketing_Type__c = 'Visibility';
        mi.Item_Number__c = '123456';
        insert mi;
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.ExternalKey__c = 'newTest_2020_123456_Out of Home';
        mpi.Marketing_Item__c = mi.id;
        mpi.Marketing_Program__c = mp.id;
        insert mpi;
       
        Test.startTest();
        
        ShoppedKitItemApprovalListView.PushToOnPlan(shpktlst);
        
        Test.stopTest();
   
   }
}