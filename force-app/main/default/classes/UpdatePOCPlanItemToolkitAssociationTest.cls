@isTest
public class UpdatePOCPlanItemToolkitAssociationTest {
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
        mktItem.Temporary_Item_Number__c = '1234567';
        
        insert mktItem;
        
        
        Marketing_Program__c mp=new Marketing_Program__c();
        mp.name='test_2020';
        mp.Brand__c=brd.id;
        
        insert mp;
        
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.Marketing_Program__c=mp.id;
        mpi.Marketing_Item__c=mktItem.id;
        
        insert mpi;
        
        list<string> demolist=new list<string>();
        demolist.add(mpi.Id);
        
        UpdatePOCPlanItemToolkitAssociation UPPT=new UpdatePOCPlanItemToolkitAssociation();
        UpdatePOCPlanItemToolkitAssociation.fetchToolkitItemMapping('7525723','2020');
        UpdatePOCPlanItemToolkitAssociation.deleteItemToolkitMapping(demolist);
        
        
    }
}