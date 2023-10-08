@isTest
private without sharing class OnPlanToStagingBatchTest {

    static testMethod void myUnitTest() {
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
        ta.Item_Price__c=10;
        ta.Quantity__c=10;
        insert ta;
        
        Staging_Main__c stmObj=new Staging_Main__c();
        stmObj.Name = ta.Marketing_Program_Item__r.Marketing_Item__r.Name;
            stmObj.Brand_Name__c = ta.Marketing_Kit__r.Marketing_Program_Name__r.Brand__r.Name;
            stmObj.Item_Price__c = 10;
            stmObj.Program_Name__c = mp.Name;
            stmObj.SKU_Number__c = mi.Item_Number__c;
            stmObj.OnPoint_Brand_Name__c = ta.Marketing_Kit__r.Marketing_Program_Name__r.Brand__r.Name;
            stmObj.Account__c = ta.Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__c;
            stmObj.Program_Start_Date__c = ta.Marketing_Kit__r.Marketing_Program_Name__r.Program_Start_Date__c;
            stmObj.Program_End_Date__c = ta.Marketing_Kit__r.Marketing_Program_Name__r.Program_End_Date__c;
            stmObj.Is_Program_User_Paid__c = ta.Marketing_Kit__r.Marketing_Program_Name__r.ABI_OP_User_Paid__c;
            //stmObj.Budget_Year__c = objTRV.Budget_Year__c;
            stmObj.Quantity__c = ta.Quantity__c;
            stmObj.Total_Spend__c = stmObj.Quantity__c * stmObj.Item_Price__c; // see if this can be a formula field
            stmObj.Channel__c = ta.Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.lboc_Channel__c; // Please update to correct field
            stmObj.Composite_Key__c = stmObj.Account__c +'_'+stmObj.Program_Name__c+'_'+stmObj.SKU_Number__c+'_'+stmObj.Budget_Year__c+'_'+stmObj.Channel__c;
        
        insert stmObj;
        //onPlanToStagingBatchSchedulable obj=new onPlanToStagingBatchSchedulable();
        //obj.execute(null);
        
        OnPlanToStagingBatch bt = new OnPlanToStagingBatch();
        OnPlanToStagingBatch bt1 = new OnPlanToStagingBatch('AK Always On');
        Database.executebatch(bt);
    }
}