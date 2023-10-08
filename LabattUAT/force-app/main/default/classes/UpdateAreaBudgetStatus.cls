/***********
* When tomorrow's date is equal to the start date of any of the planning windows
* then the system will change the approval status of the annual area budget records so that the reps 
* can do their planning for the programs within that planing window
* Ideally run this batch with batch size = 1
* @ author: Cognizant.Developer
* On Plan/POC Planning Automation
************/
global with sharing class UpdateAreaBudgetStatus implements Database.Batchable<SObject>,database.stateful {

    global set<id> allSuccessId=new set<id>();
    global String body='Hi, </br></br>';
    public Database.QueryLocator start(Database.BatchableContext BC){
       
        List<POC_Planning_Setup_Admin__c> lstPlanningWindows = new List<POC_Planning_Setup_Admin__c>();
        lstPlanningWindows = [SELECT Id, Business_Line__c,Budget_Year__c,Plan_Start_Date__c, Plan_End_Date__c,Planning_Year__c, Type__c 
                                FROM POC_Planning_Setup_Admin__c WHERE Plan_Start_Date__c = TOMORROW];
        system.debug('lstPlanningWindows::size:::'+lstPlanningWindows.size());
        if(lstPlanningWindows != null && lstPlanningWindows.size() > 0){
            Set<String> busLineRecordType = new Set<String>();
            Set<String> budgetYear = new Set<String>();
            for(POC_Planning_Setup_Admin__c var : lstPlanningWindows){
                if(var.Business_Line__c == 'Out of Home (OOH)'){
                    busLineRecordType.add('Territory');
                    budgetYear.add(var.Budget_Year__c);
                }else if(var.Business_Line__c == 'In Home (IH)'){
                    busLineRecordType.add('New_IH_Territory');
                    budgetYear.add(var.Budget_Year__c);
                }
            }
        }
        String query,budyear='3030';
        boolean backofficeCheckBox = false;
        if(lstPlanningWindows != null && lstPlanningWindows.size() > 0){
        query = 'SELECT Id, Approval_Status__c FROM Annual_Area_Budget__c where recordType.DeveloperName IN :busLineRecordType and Budget_Year__c IN:budgetYear and Sales_Territory__r.Back_Office_Territory__c=:backofficeCheckBox';
            system.debug('query:::'+query );
        }
        else
        {
         query = 'SELECT Id, Approval_Status__c FROM Annual_Area_Budget__c where Budget_Year__c=: budyear'; 
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Annual_Area_Budget__c> scope){
          
        for(Annual_Area_Budget__c obj:scope){
            obj.Approval_Status__c ='Required';   
        }
         Database.SaveResult[] res = Database.update(scope, false);
         
            for (Database.SaveResult sr : res){
                if(sr.isSuccess()){
                    System.debug('Successfully inserted Updated: ' + sr.getId());
                    allSuccessId.add(sr.getId());
                }
                if (!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        System.debug('#### error while updating #### ' + err.getStatusCode() + ': ' + err.getMessage());
                        // do further error handling here
                    }
                }
            }
    }

    public void finish(Database.BatchableContext BC){
       List<Annual_Area_Budget__c> annAreaBudgetIds = new List<Annual_Area_Budget__c>();
        if(!allSuccessId.isEmpty()){
        body='Budget records are succesfully updated. The Id of updated records are  : </br></br> ';
        body= body + allSuccessId +'</br>';
        }
        //system.debug('allSuccessId' +allSuccessId);
        
        body = body +'Budget Approval Status Batch successfully Processed';
        // call utility method to send confirmation email to TA Admin
        List<String> EmailId = new  List<String>();
        List<String> ccEmailId = new List<String>();
        ExcelHeader__mdt[] ccMailList = [select MasterLabel, QualifiedApiName, column_A__c FROM ExcelHeader__mdt where MasterLabel ='cc Mail Id'];
        for(ExcelHeader__mdt eh:ccMailList){
            EmailId.add(eh.column_A__c);
        }
                                 
         Mailutility.sendMail(EmailId,ccEmailId,'Budget Status change Confirmation mail',body);
    }
}