/***
* @Name				ArchivalFlagEnableBatch
* @Author			Ragbirendra Upadhyay
* @CreatedDate		09-19-2019
* @Description		Batch Class for Update Archival Flag to True on
stagging object(budgetLoadUI,Program Brand Item and shopkit)
*
***/
global class ArchivalFlagEnableBatch implements Database.Batchable<sObject>{
    
    string objectAPIName ='BudgetLoadUI__c';
    public ArchivalFlagEnableBatch(){}
    public ArchivalFlagEnableBatch(string objectName){
        objectAPIName = objectName;
    }
    global Database.QueryLocator start(Database.BatchableContext ctx) {
        string queryString ='Select Id , archival_Flag__c from ' + objectAPIName + ' where archival_Flag__c = false and CALENDAR_YEAR(CreatedDate) <='+System.Label.Stagging_Record_Archival_Year;
        return Database.getQueryLocator(queryString);
    }
    global void execute(Database.BatchableContext ctx, List<sObject> scope){
        
        List<sObject> UpdateList= new List<sObject>();
            if(objectAPIName=='BudgetLoadUI__c'){
                for(BudgetLoadUI__c bl:(List<BudgetLoadUI__c>)scope){
                    bl.archival_Flag__c = true;
                }
             }
             if(objectAPIName=='Program_Brands_Item__c'){
                for(Program_Brands_Item__c pbi:(List<Program_Brands_Item__c>)scope){
                    pbi.archival_Flag__c = true;
                }
             }
            if(objectAPIName=='NAZ_OP_Shopkit_Data__c'){
                for(NAZ_OP_Shopkit_Data__c sd:(List<NAZ_OP_Shopkit_Data__c>)scope){
                    sd.archival_Flag__c = true;
                }
             }
        update scope;  
    }
    global void finish(Database.BatchableContext ctx){
      AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          from AsyncApexJob where Id =:ctx.getJobId()];
        
        String body ='records processed ' + a.TotalJobItems +'with '+ a.NumberOfErrors + ' failures.';
        List<string> emailId = new List<string>();
        List<string> ccEmailId = new List<string>();
        ExcelHeader__mdt[] ccMailList = [select MasterLabel, QualifiedApiName, column_A__c,column_B__c FROM ExcelHeader__mdt where MasterLabel ='cc Mail Id'];
        for(ExcelHeader__mdt eh:ccMailList){
            emailId.add(eh.column_A__c); 
            ccEmailId.add(eh.column_B__c);
        }
        Mailutility.sendMail(emailId,ccEmailId,'Record Archival in Stagging Area Batch result (POC Planning)',body);  
    }
}