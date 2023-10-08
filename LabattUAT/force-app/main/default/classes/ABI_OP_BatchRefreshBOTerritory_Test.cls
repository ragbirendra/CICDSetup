@isTest
private class ABI_OP_BatchRefreshBOTerritory_Test {
    
    static testMethod void createData()
    {  
        //Scheduler_Configuration__mdt objMetadata=new Scheduler_Configuration__mdt();
        //objMetadata.Label='ABI_OP_BatchSchedulerOnplanBORefresh';
       // objMetadata.Enabled__c=false;
        Boolean isFlag=false;
        
        OnPoint_Territory__c opt = new OnPoint_Territory__c();
        opt.Name = 'Test data1';
        opt.Territory_Code__c = 'TD0001';
        opt.Back_Office_Territory__c = true;
        opt.CurrencyIsoCode = 'CAD';
        insert opt;
                       
        Annual_Area_Budget__c parbdgt = new Annual_Area_Budget__c();
        parbdgt.Budget_Year__c = '2019';
        parbdgt.Discretionary_Budget__c = 4000.33;
        parbdgt.Drivers_Budget__c = 500.66;
        parbdgt.District_Name__c = 'National';
        parbdgt.RecordtypeId = Schema.sObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH District').getRecordTypeId();
        
        insert parbdgt;
        
        Annual_Area_Budget__c childbdgt = new Annual_Area_Budget__c();
        childbdgt.Budget_Year__c = '2019';
        childbdgt.Discretionary_Budget__c = 4001.99;
        childbdgt.Drivers_Budget__c = 502.66;
        childbdgt.RecordTypeId = Schema.sObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        childbdgt.Parent_Budget__c = parbdgt.Id;
        insert childbdgt; 
        
        lboc_Sales_Territory__c obj = new lboc_Sales_Territory__c();
        obj.Back_Office_Territory__c= true;
        obj.Name = 'Test data1';
        obj.CurrencyIsoCode = 'CAD';
        obj.lboc_Territory_ID__c = 'TD0001';
        obj.lboc_Region__c = 'QUEBEC';
        insert obj;
        
        parbdgt.Sales_Territory__c = obj.Id;
        childbdgt.Sales_Territory__c = obj.Id;
        update parbdgt;
        update childbdgt;
        
        Account acc = new Account();
        acc.Name='Test Back office POC';
        acc.OnPoint_Sales_Territory__c = opt.Id;
        acc.OnPlan_Sales_Territory__c = obj.Id;
        insert acc;
        
        OnPoint_Territory__c objonpoint = new OnPoint_Territory__c();
        objonpoint.Name = 'Test data2';
        objonpoint.Territory_Code__c = 'TD0002';
        objonpoint.Back_Office_Territory__c = false;
        objonpoint.CurrencyIsoCode = 'CAD';
        insert objonpoint;
        
        Id batchInstanceId = Database.executeBatch(new ABI_OP_BatchRefreshBOTerritoryAndPoc(isFlag));
    }
}