/***
* @Name				UpdateTerritoryBrandBudgetBatch
* @Author			Ragbirendra Upadhyay
* @CreatedDate		09-19-2019
* @Description		Batch Class for Update Brand Budget from 
*					Staging table to respective onPlan tables
*
***/

global class UpdateTerritoryBrandBudgetBatch implements Database.Batchable<sObject>,Database.stateful {
    
    public String body='Hi, </br></br>';
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        string sts ='UpLoading';
        String query = 'Select Territory_Code__c,Year__c,Brand__c,Territory_Brand_Budget__c,External_Id__c from BudgetLoadUI__c where Status__c =\'' + String.escapeSingleQuotes(sts) + '\'';
        //String query = 'Select id,Brand__c,External_Id__c,Brand_Budget__c,Budget_Year__c,Territory_Code__c,Annual_Area_Budget__c from Annual_Brand_Area_Budget_Plan__c where CreatedDate = THIS_YEAR or CreatedDate = NEXT_YEAR';
        system.debug('query update:::'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BudgetLoadUI__c> scope){
        
        Set<String> setExtId = new Set<String>();
        for(BudgetLoadUI__c s : scope){
            system.debug('s.External_Id__c:::'+s.External_Id__c);
            setExtId.add(s.External_Id__c);
        }
        List<Annual_Brand_Area_Budget_Plan__c> abab = new List<Annual_Brand_Area_Budget_Plan__c>([Select id,Brand__c,External_Id__c,Brand_Budget__c,Budget_Year__c,Territory_Code__c,Annual_Area_Budget__c from Annual_Brand_Area_Budget_Plan__c where External_Id__c IN: setExtId]);
        
        for(Annual_Brand_Area_Budget_Plan__c ab:abab)
        {
            for(BudgetLoadUI__c obja : scope){
                if(obja.External_Id__c == ab.External_Id__c){
                    ab.Brand_Budget__c = obja.Territory_Brand_Budget__c;
                }          
            }
        }
        
        // ****Update Brand Budget*****
        List<BudgetLoadUI__c> statusList = new List<BudgetLoadUI__c>();
        List<Database.SaveResult> results;
        try{
         results = Database.update(abab,false);  
        }catch(Exception ex){
            System.debug('#### error while updating ####'); 
        }
        List<String> externalId = new List<String>();
        // Iterate through each returned result
        integer i=0 ; 
        for (Database.SaveResult sr : results) {
            BudgetLoadUI__c bpr = new BudgetLoadUI__c();
            system.debug('abab[i].External_Id__c:::'+abab[i].External_Id__c);
            if (sr.isSuccess()) {
                bpr.Status__c = 'Success';
                bpr.External_Id__c = abab[i].External_Id__c;
                externalId.add(abab[i].External_Id__c);
                statusList.add(bpr);             
                i++;
            }
            else {
                bpr.Status__c = 'Failed';
                bpr.External_Id__c = abab[i].External_Id__c;
                body = body+' '+bpr.External_Id__c+'----'+ bpr.Status__c+'</br>';
                statusList.add(bpr);              
                i++;  
            }    
        }
        setExtId.removeAll(externalId);
        for(BudgetLoadUI__c sl:[select Status__c,External_Id__c from BudgetLoadUI__c where External_Id__c IN: setExtId])
        {
            BudgetLoadUI__c bpr = new BudgetLoadUI__c();
            bpr.Status__c = 'Failed';
            body = body+' '+sl.External_Id__c+'----'+ bpr.Status__c+'</br>';
            bpr.External_Id__c = sl.External_Id__c;
            statusList.add(bpr);
        }
        try{
        Database.UpsertResult[] resultupdate = Database.upsert(statusList, BudgetLoadUI__c.External_Id__c,false);  
        }catch(Exception ex){
            System.debug('#### error while updating ####'); 
        }
    }
    
    global void finish(Database.BatchableContext BC){
        body = body+' Budget Uploaded Successfully ! '+'</br>';
        List<string> emailId = new List<string>();
        List<string> ccEmailId = new List<string>();
        ExcelHeader__mdt[] ccMailList = [select MasterLabel, QualifiedApiName, column_A__c,column_B__c FROM ExcelHeader__mdt where MasterLabel ='cc Mail Id'];
        for(ExcelHeader__mdt eh:ccMailList){
            emailId.add(eh.column_A__c);
            ccEmailId.add(eh.column_B__c);
        }
        Mailutility.sendMail(emailId,ccEmailId,'Budget Automation Result',body);
    }
    
}