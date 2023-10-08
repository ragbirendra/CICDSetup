/***
* @Name - OnPlan_to_OnPoint_Budget_Batch
* @Author -  Amol Parab
* @CreatedDate -09/15/2019
* @Description - 
* 

***/
global class  BatchForCreationOfBudgetBO implements Database.Batchable<sObject>,Database.stateful
{
    public String body='Hi, </br></br>';
     public String yearOfBudget;
    public String blOfBudget;
    Set<id> failRecord = new Set<id>();
    public boolean allRecordCompleted=false;

    public BatchForCreationOfBudgetBO(String year, String bussinessLine) {
        yearOfBudget = year;
        blOfBudget = bussinessLine;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    { 
        String query;
        if(!test.isRunningTest()){
            query = 'SELECT id , Name, lboc_Territory_ID__c,OwnerId FROM lboc_Sales_Territory__c WHERE Back_Office_Territory__c=true AND Owner.isActive=true';
        }
        else{
            query = 'SELECT id , Name, lboc_Territory_ID__c,OwnerId FROM lboc_Sales_Territory__c WHERE Back_Office_Territory__c=true ';
        } 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<lboc_Sales_Territory__c> scope)
    { 
        System.debug('---blOfBudgetblOfBudget@@@@@'+blOfBudget);
        List<Annual_Area_Budget__c> listOfNewBudget=new List<Annual_Area_Budget__c>();
        Id OOHRT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        Id IHRT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH Territory').getRecordTypeId();
        Id DORT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH District').getRecordTypeId();
        Id DIRT = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('New IH District').getRecordTypeId();
        Id recordTypeIdToQuery;
        Id recordTypeIdToQueryParent;
        if(blOfBudget =='OutOfHome'){
            recordTypeIdToQuery= OOHRT;
            recordTypeIdToQueryParent =DORT;
        }
        else if(blOfBudget =='InHome'){
            recordTypeIdToQuery= IHRT;
            recordTypeIdToQueryParent =DIRT;
        }
        List<string> externalId= new List<string>();
        SET<ID> TerritoryId=new SET<Id>();
        for(lboc_Sales_Territory__c objST: scope){
            TerritoryId.add(objST.id);
        }
        List<Annual_Area_Budget__c> parentBudget=new List<Annual_Area_Budget__c>();
        List<Annual_Area_Budget__c> externalBudgetKey=[SELECT External_key_Dist__c,Budget_Year__c,RecordTypeId,Sales_Territory__c,District_Code__c FROM Annual_Area_Budget__c WHERE Budget_Year__c=:yearOfBudget AND RecordTypeId=:recordTypeIdToQuery  AND Sales_Territory__c IN:TerritoryId ] ;  // BL needs to add
        foR(Annual_Area_Budget__c obAAB:externalBudgetKey){
            if(obAAB.RecordTypeId==recordTypeIdToQueryParent){  //obAAB.District_Code__c=='National'
                parentBudget.add(obAAB);
            }
            else{
            	externalId.add(obAAB.External_key_Dist__c);
            }
            
        }
        System.debug(' @@@ Parent Budet @@'+parentBudget);
        System.debug(' @@@ Budget @@'+externalId);
       // List<Annual_Area_Budget__c> parentBudget=new List<Annual_Area_Budget__c>();
        /*if(!test.isRunningTest()){
         parentBudget=[SELECT id,Name,RecordType.DeveloperName from Annual_Area_Budget__c WHERE District_Name__c='National' AND Budget_Year__c=:yearOfBudget AND RecordTypeId=:recordTypeIdToQuery];
        }
        else
        {
          parentBudget=[SELECT id,Name, RecordType.DeveloperName from Annual_Area_Budget__c WHERE District_Name__c='National' AND Budget_Year__c=:String.valueOf(System.Today().year())];   
        }*/
        Map<string, Annual_Area_Budget__c> mapOfParentBudget=new MAP<string, Annual_Area_Budget__c>();
       
        if( parentBudget.isEmpty() ){
            if(blOfBudget =='OutOfHome'){
            Annual_Area_Budget__c objAABParent=new Annual_Area_Budget__c ();
            objAABParent.Budget_Year__c=String.valueOf(yearOfBudget);
            objAABParent.District_Name__c='National';
            objAABParent.District_Code__c='National';
            objAABParent.External_key_Dist__c=objAABParent.District_Code__c+'_'+objAABParent.Budget_Year__c+'_'+Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosById().get(DORT).getName();
            objAABParent.RecordTypeId=DORT;
            //insert objAABParent;
            parentBudget.add(objAABParent);
            }
            else if(blOfBudget =='InHome'){
            
            Annual_Area_Budget__c objAABParentIH=new Annual_Area_Budget__c ();
            objAABParentIH.Budget_Year__c=String.valueOf(yearOfBudget);
            objAABParentIH.District_Name__c='National';
            objAABParentIH.District_Code__c='National';
			objAABParentIH.External_key_Dist__c=objAABParentIH.District_Code__c+'_'+objAABParentIH.Budget_Year__c+'_'+Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosById().get(DIRT).getName();
            objAABParentIH.RecordTypeId=DIRT;
            //insert objAABParentIH;
            parentBudget.add(objAABParentIH);
            }
            //insert parentBudget;
            List<Database.upsertResult> resultToUpdate =Database.upsert(parentBudget, Annual_Area_Budget__c.External_key_Dist__c);
            System.debug('-----resultToUpdate Parent---'+resultToUpdate);
             for(Annual_Area_Budget__c aab:[SELECT id,Name,RecordType.DeveloperName from Annual_Area_Budget__c WHERE District_Name__c='National' AND Budget_Year__c=:yearOfBudget AND RecordTypeId=:recordTypeIdToQueryParent]){
            System.debug('-----aab.RecordType.DeveloperName---'+aab.RecordType.DeveloperName);
            mapOfParentBudget.put(aab.RecordType.DeveloperName, aab);
       		 }
        }
        else{
             for(Annual_Area_Budget__c aab:parentBudget){
            System.debug('-----aab.RecordType.DeveloperName---'+aab.RecordType.DeveloperName);
            mapOfParentBudget.put(aab.RecordType.DeveloperName, aab);
             }
        }
        System.debug('-----parentBudget---'+parentBudget);
        List<String> territoryCode= new List<String>();
        System.debug('-----mapOfParentBudget---'+mapOfParentBudget);
        for(lboc_Sales_Territory__c obTerritory: scope)
        {
            if(blOfBudget =='OutOfHome'){
                territoryCode.add(obTerritory.lboc_Territory_ID__c);
                Annual_Area_Budget__c objAAB=new Annual_Area_Budget__c ();
                objAAB.Budget_Year__c=String.valueOf(yearOfBudget);
                objAAB.District_Code__c ='National';
                objAAB.Parent_Budget__c=mapOfParentBudget.get('District').id;
                objAAB.Sales_Territory__c=obTerritory.id;
                objAAB.OwnerId=obTerritory.OwnerId;
                objAAB.RecordTypeId=OOHRT;
                objAAB.Territory_Code__c=obTerritory.lboc_Territory_ID__c;
                objAAB.External_key_Dist__c=objAAB.District_Code__c+'_'+obTerritory.lboc_Territory_ID__c+'_'+yearOfBudget+'_OOH Territory';
                if(!externalId.contains(objAAB.External_key_Dist__c)){
                    listOfNewBudget.add(objAAB);
            	}
            }
            else if(blOfBudget =='InHome'){
                Annual_Area_Budget__c objAABIH=new Annual_Area_Budget__c ();
                objAABIH.Budget_Year__c=String.valueOf(yearOfBudget);
                objAABIH.District_Code__c ='National';
                objAABIH.Parent_Budget__c=mapOfParentBudget.get('New_IH_District').id;
                objAABIH.Sales_Territory__c=obTerritory.id;
                objAABIH.OwnerId=obTerritory.OwnerId;
                objAABIH.RecordTypeId=IHRT;
                objAABIH.Territory_Code__c=obTerritory.lboc_Territory_ID__c;
                objAABIH.External_key_Dist__c=objAABIH.District_Code__c+'_'+obTerritory.lboc_Territory_ID__c+'_'+yearOfBudget+'_New IH Territory';
                if(!externalId.contains(objAABIH.External_key_Dist__c)){
                    listOfNewBudget.add(objAABIH);
                }
            }
            
            
        }
        List<Database.upsertResult> results = Database.upsert(listOfNewBudget,Annual_Area_Budget__c.External_key_Dist__c);
        integer i=0 ; 
        System.debug('======upsert result---'+results);
       for (Database.upsertResult sr : results) {
           if (!sr.isSuccess()) {
               failRecord.add(sr.getId());
               body = body+''+scope[i]+'----'+ 'failed' +'</br>';
                    for(Database.Error err : sr.getErrors()) {                     
                        body = body + err.getMessage()+'Fields that affected this error: ' + err.getFields()  +'</br>';
                    }
           }
           i++;
           
       }
        if(failRecord.isEmpty()){
            //for(integer j=0; j< listOfNewBudget.size(); i++){
            allRecordCompleted=true;
          // body = body +' Backoffice territory budget record created successfully' +'</br>';  // listOfNewBudget[j].Sales_Territory__c +
           //}
        }
        
        
    }
    global void finish(Database.BatchableContext BC)
    {
        if(allRecordCompleted=true){
            body = body +' Backoffice territory budget record created successfully' +'</br>';
        }
        List<string> emailId = new List<string>();
        List<string> ccEmailId = new List<string>();
        //user usr = [select id,email from user where id=:UserInfo.getUserId()];
        //emailId.add(usr.email);
        ExcelHeader__mdt[] ccMailList = [select MasterLabel, QualifiedApiName, column_A__c,column_B__c,column_C__c FROM ExcelHeader__mdt where MasterLabel ='cc Mail Id'];
        for(ExcelHeader__mdt eh:ccMailList){
            emailId.add(eh.column_A__c);
        }
        Mailutility.sendMail(emailId,ccEmailId,'Backoffice Budget Automation Result',body);
    }

}