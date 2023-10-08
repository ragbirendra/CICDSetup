/*Program Name POC Planning 2019
Project Name  POC Planning 2019
Author : Aastha A
Data : 05/08/2019
Description  :<Batch class for US W-013971 : Daily refresh of territories and Back Office POCs in OnPlan for BO Users>*/


global class ABI_OP_BatchRefreshBOTerritoryAndPoc implements Database.Batchable<sObject>, Database.Stateful {
    private Boolean isEnableFlag;
    
    public ABI_OP_BatchRefreshBOTerritoryAndPoc(Boolean isFlag){
        isEnableFlag = isFlag;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'Select Id from OnPoint_Territory__c where Back_Office_Territory__c =true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OnPoint_Territory__c> scope)
    {   
        //Scheduler_Configuration__mdt isEnabled;
     //if(!test.isRunningTest()){
       //  isEnabled = [Select Enabled__c from Scheduler_Configuration__mdt where Label='ABI_OP_BatchSchedulerOnplanBORefresh'];
     //}
     //else{
       //  isEnabled = [Select Enabled__c from Scheduler_Configuration__mdt ];
     //}
     
     //if((isEnabled.Enabled__c!=null && isEnabled.Enabled__c == true) || test.isRunningTest() ){
     if((isEnableFlag!=null && isEnableFlag == true) || test.isRunningTest() ){
         
         List<lboc_Sales_Territory__c> listOfTerritory = new List<lboc_Sales_Territory__c>();
         Map<Id,Id> mapAccountOnPointTerr = new Map<Id,ID>();
         List<Id> listOfsuccessRecords = new List<Id>();
         
         List<OnPoint_Territory__c> onptAccts = [Select id,OwnerId,Name,Territory_Code__c,Back_Office_Territory__c,CurrencyIsoCode,(Select id from accounts__r) from OnPoint_Territory__c where id IN:scope];
         
         Set<Id> optId = new Set<Id>();
         List<string> territoryCode=new List<string>();
         for(OnPoint_Territory__c onPointTerritory : onptAccts){
             optId.add(onPointTerritory.Id);
             territoryCode.add(onPointTerritory.Territory_Code__c);
         }
         
         Map<Id,Account> mapRelatedAcc = new Map<Id,Account>([SELECT Id,Name,OwnerId,OnPoint_Sales_Territory__c FROM Account WHERE OnPoint_Sales_Territory__c IN :optId AND lboc_Labatt_Outlet_Id__c IN:territoryCode]);
         
         for(Id accId : mapRelatedAcc.keySet()){
             Id optTerId = mapRelatedAcc.get(accId).OnPoint_Sales_Territory__c;
             mapAccountOnPointTerr.put(accId,optTerId);
         }
         
         if(!onptAccts.isEmpty())
         {
             for(OnPoint_Territory__c onPointTerritory : onptAccts)
             {                                 
                 // Creating and updating Sales Territory
                 lboc_Sales_Territory__c OnPlanTerritory = new lboc_Sales_Territory__c();
                 OnPlanTerritory.lboc_Territory_ID__c = onPointTerritory.Territory_Code__c;
                 OnPlanTerritory.Name = onPointTerritory.Name;
                 OnPlanTerritory.Back_Office_Territory__c = onPointTerritory.Back_Office_Territory__c;
                 OnPlanTerritory.CurrencyIsoCode = onPointTerritory.CurrencyIsoCode;
                 OnPlanTerritory.OnPoint_Territory__c = onPointTerritory.Id; 
                 OnPlanTerritory.OwnerId = onPointTerritory.OwnerId;
                 listOfTerritory.add(OnPlanTerritory);
             } 
         }
         
                 
         Schema.SObjectField extId = lboc_Sales_Territory__c.lboc_Territory_ID__c; 
         Database.UpsertResult [] srList = Database.Upsert(listOfTerritory,extId, false);
         
         
         if(!srList.isEmpty())
         {
             for (Database.UpsertResult  sr : srList) {
                 listOfsuccessRecords.add(sr.getId());
             }
             
         }
         
         List<lboc_Sales_Territory__c> listofSalesTerritory =[Select Id,OnPoint_Territory__c from lboc_Sales_Territory__c Where Id IN :listOfsuccessRecords];
         List<Account> relatedAccounts = [Select id,OnPoint_Sales_Territory__c,OwnerId,OnPlan_Sales_Territory__c from account where ID In:mapAccountOnPointTerr.keySet()];
         List<Account> Updatedaccount = new List<Account>();
         
         for(lboc_Sales_Territory__c lbocST :listofSalesTerritory){
             for(Account ra :relatedAccounts){
                 if(lbocST.OnPoint_Territory__c == ra.OnPoint_Sales_Territory__c ) {
                     ra.OnPlan_Sales_Territory__c =lbocST.id;
                     Updatedaccount.add(ra);
                 }
             }
         }
         
         Update Updatedaccount;
     }
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
    
}