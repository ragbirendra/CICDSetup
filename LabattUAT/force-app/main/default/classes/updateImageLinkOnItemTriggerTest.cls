@isTest
public class updateImageLinkOnItemTriggerTest {
    static testmethod void setup()
    {
        Id WsRecId = [Select Id, Name from RecordType where developername = 'IH_Assigned_Preconfigured' limit 1].Id;
		Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
		Brand__c brd = new Brand__c();
        brd.Name= 'Corona';
        brd.RecordTypeId=brandRecId;
        insert brd;
        
        Marketing_Item__c mi = new Marketing_Item__c();
        mi.Name = 'Corona - Coasters';
        mi.Brand__c = brd.Id;
        mi.Full_Price_to_Rep__c = 10;
        mi.IH_Item_Classification__c = 'Cooler';
        
        insert mi;
        
        Marketing_Program__c mp = new Marketing_Program__c();
        
        mp.Name = 'Budweiser - Hockey';
        mp.Brand__c = brd.Id;
        mp.Business_Line__c = 'Out of Home';
        mp.Planning_End_Date__c = Date.today();
        mp.Planning_Start_Date__c = Date.today();
        mp.Program_End_Date__c = Date.today();
        mp.Program_Start_Date__c = Date.today();
        
        insert mp;
        
        Marketing_Program_Item__c mpi = new Marketing_Program_Item__c();
        mpi.ExternalKey__c = '123';
        mpi.Marketing_Program__c = mp.Id;
        mpi.Marketing_Item__c = mi.Id;
        insert mpi;
        
        Marketing_Kit__c mk = new Marketing_Kit__c();
        mk.Name = 'test';
        mk.Marketing_Program_Name__c = mp.Id;
        mk.RecordTypeId = WsRecId;
        insert mk;
        
        Trade_Activation_Kit_Item__c ta = new Trade_Activation_Kit_Item__c();
        ta.Marketing_Kit__c = mk.Id;
        ta.Marketing_Program_Item__c = mpi.Id;
        insert ta;
        
        Attachment attachment1 = new Attachment(Body=blob.valueOf('Test Attachment 1'), 
                        Name = 'Attachment_' + DateTime.Now(), 
                        parentId= mi.Id);
    insert attachment1;   
    }
}