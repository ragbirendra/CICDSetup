@isTest
public class UpdatePOCPlanningShoppedKitCtrlTest {
    static testMethod void myUnitTest(){
        
        
        RecordType rt = [select id, DeveloperName from RecordType where SobjectType = 'Brand__c' and DeveloperName = 'Trade_Activation' Limit 1];
        RecordType rt1 = [select id, DeveloperName from RecordType where SobjectType = 'Marketing_Kit__c' and DeveloperName = 'Preconfigured' Limit 1];
        
        Brand__c brd = new Brand__c();
        brd.Name = 'Corona';
        brd.RecordTypeID = rt.id;
        insert brd;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        mp.Name = 'newTest_2020';
        mp.Business_Line__c='In Home';
        mp.Brand__c = brd.id;
        insert mp;
        
        Marketing_Kit__c mkc = new Marketing_Kit__c();
        mkc.Name = 'shopped Kit Name2_2020';
        mkc.RecordTypeID = rt1.Id;
        mkc.Marketing_Program_Name__c =	mp.Id;
       

        list<string> demolist=new list<string>();
        demolist.add(mkc.Id);
        UpdatePOCPlanningShoppedKitCtrl.getPickListVals('newTest_2020','2020');
        UpdatePOCPlanningShoppedKitCtrl.fetchToolkitItemMapping('newTest_2020','2020','In Home');
        UpdatePOCPlanningShoppedKitCtrl.deleteItemToolkitMapping(demolist);
        
        
    }
}