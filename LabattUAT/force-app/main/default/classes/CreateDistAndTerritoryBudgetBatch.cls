/***
* @Name				LoadBudgetProductRestrictionOnOnplan
* @Author			Ragbirendra Upadhyay
* @CreatedDate		09-19-2019
* @Description		Batch Class for loading Budget from 
*					Staging table to respective onPlan tables
*
***/

global class CreateDistAndTerritoryBudgetBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string sts1 ='New';
        string sts2 ='Updated';
        String query;
        if(!Test.isRunningTest()) {     
        	 query = 'SELECT Id, Brand__c, Name,District_Code__c, District_Name__c, District_Record_Type__c, ExternalKey__c, Region__c, Status__c, Territory_Brand_Budget__c, Territory_Code__c, Territory_Name__c, Discretionary_Budget__c ,Territory_Record_Type__c, Year__c FROM BudgetLoadUI__c where (Status__c =\'' + String.escapeSingleQuotes(sts1) + '\''+' or Status__c =\'' + String.escapeSingleQuotes(sts2) + '\''+')';
             system.debug('query::::'+query);
        }
        else{
             query = 'SELECT Id, Brand__c, Name,District_Code__c, District_Name__c, District_Record_Type__c, ExternalKey__c, Region__c, Status__c, Territory_Brand_Budget__c, Territory_Code__c, Territory_Name__c, Discretionary_Budget__c ,Territory_Record_Type__c, Year__c FROM BudgetLoadUI__c ';
 
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BudgetLoadUI__c> scope){
        
        //change status to Processing
        for(BudgetLoadUI__c bl:scope)
        {
           bl.Status__c ='Processing';
        }
        update scope;
        List<Annual_Area_Budget__c> listOfBudgets = new List<Annual_Area_Budget__c>();
        List<String> distCodeList = new List<String>();
        List<String> teriCodeList = new List<String>();
        Map<String,String> mapDistrictId = new Map<String,String>();
        Map<String,String> mapTerritoryId = new Map<String,String>();
        List<String> externalKeyList = new List<String>();
       
        for(BudgetLoadUI__c bpr:scope)
        {
         distCodeList.add(bpr.District_Code__c);  
         teriCodeList.add(bpr.Territory_Code__c); 
        }
        
        
        for(OnPoint_District__c var : [Select Id,District_Code__c from OnPoint_District__c where District_Code__c IN :distCodeList])
        {
            mapDistrictId.put(var.District_Code__c,var.Id);
        }
        //Add district Id in Map for Backoffice user
        List<OnPoint_District__c> opd =[Select Id,name from OnPoint_District__c where name='NATIONAL' Limit 1];
        if(opd.size()>0){
        mapDistrictId.put('National',opd[0].Id);    
        }
        
        for(lboc_Sales_Territory__c var : [Select Id,lboc_Territory_ID__c,Back_Office_Territory__c from lboc_Sales_Territory__c where lboc_Territory_ID__c IN: teriCodeList])
        {
            mapTerritoryId.put(var.lboc_Territory_ID__c,var.Id);
        }
        //****District Budgets****
        
          for(AggregateResult ag : [Select count(Territory_Brand_Budget__c),District_Code__c,District_Name__c,Year__c,District_Record_Type__c From BudgetLoadUI__c Where (Status__c ='Processing') and District_Record_Type__c Like '%District%' GROUP BY District_Code__c,District_Name__c,District_Record_Type__c,Year__c]){
                                   if(distCodeList.contains((String)ag.get('District_Code__c'))){
                                      Annual_Area_Budget__c budgets = new Annual_Area_Budget__c();
                                      budgets.Budget_Year__c = (String)(ag.get('Year__c'));
                                      budgets.District_Name__c = (String)ag.get('District_Name__c');
                                      budgets.District_Code__c = (String)ag.get('District_Code__c');
                                      
                                      Id varId = mapDistrictId.get((String)ag.get('District_Code__c'));
                                      budgets.District__c = varId;
                                       
                                      budgets.External_key_Dist__c = (String)ag.get('District_Code__c')+'_'+(String)(ag.get('Year__c'))+'_'+(String)ag.get('District_Record_Type__c');
                                      externalKeyList.add(budgets.External_key_Dist__c);//used to take Id after dist budget insert
              						  if(ag.get('District_Record_Type__c') != null && Schema.sObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get((String)ag.get('District_Record_Type__c')) != null)
                                      	budgets.RecordTypeId = Schema.sObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get((String)ag.get('District_Record_Type__c')).getRecordTypeId();
                                      if(budgets.District_Code__c != NULL || budgets.District_Code__c !='')
                                      {
                                      system.debug('Dist budgets::'+budgets);
                                      listOfBudgets.add(budgets);
                                      }
                                   }//end of if
                                  }

            //Upsert listOfBudgets External_key_Dist__c;
        
           //error description store in custom object
        try{
           Database.UpsertResult[] results = Database.upsert(listOfBudgets, Annual_Area_Budget__c.External_key_Dist__c,false);
        }catch(Exception ex){
            System.debug('#### error while updating ####'); 
        }
        //****Territory Budgets****
        String externalKeyDist='';
        List<Annual_Area_Budget__c> listOfBudgetsterr = new List<Annual_Area_Budget__c>();
        Map<String,String> parentIdMap = new Map<String,String>();
        for(Annual_Area_Budget__c aab:[select Id,External_key_Dist__c from Annual_Area_Budget__c where External_key_Dist__c IN:externalKeyList]){
           parentIdMap.put(aab.External_key_Dist__c,aab.Id);
        }
        
        for(AggregateResult ag : [Select Territory_Code__c,District_Name__c,District_Code__c,Year__c,Territory_Record_Type__c,Max(Discretionary_Budget__c) DBC From BudgetLoadUI__c Where (Status__c ='Processing') and Territory_Record_Type__c Like '%Territory%' GROUP BY Territory_Code__c, District_Name__c,District_Code__c,Territory_Record_Type__c,Year__c]){
                         if(teriCodeList.contains((String)ag.get('Territory_Code__c'))){
                                      Annual_Area_Budget__c budgets = new Annual_Area_Budget__c();
                                      budgets.Budget_Year__c = (String)(ag.get('Year__c'));
                                      budgets.District_Name__c = (String)ag.get('District_Name__c');
                                      budgets.District_Code__c = (String)ag.get('District_Code__c');
                                      budgets.Territory_Code__c = (String)ag.get('Territory_Code__c');
                                      Id varId = mapTerritoryId.get((String)ag.get('Territory_Code__c'));
                                      budgets.Sales_Territory__c = varId;
                                      budgets.Discretionary_Budget__c = ((Decimal)ag.get('DBC'));                                      
                                      budgets.External_key_Dist__c = (String)ag.get('District_Code__c')+'_'+(String)ag.get('Territory_Code__c')+'_'+(String)(ag.get('Year__c'))+'_'+(String)ag.get('Territory_Record_Type__c');
                                      if(ag.get('Territory_Record_Type__c') != null && Schema.sObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get((String)ag.get('Territory_Record_Type__c')) != null)  {
                                          
                                      budgets.RecordTypeId = Schema.sObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get((String)ag.get('Territory_Record_Type__c')).getRecordTypeId();}
                                       if(ag.get('Territory_Record_Type__c')=='OOH Territory'){
                                         externalKeyDist = (String)ag.get('District_Code__c')+'_'+(String)(ag.get('Year__c'))+'_'+'OOH District';   
                                           }	                
                                      else{
                                      externalKeyDist = (String)ag.get('District_Code__c')+'_'+(String)(ag.get('Year__c'))+'_'+'New IH District';
                                           }
                                      system.debug('externalKeyDist::::'+ externalKeyDist);
                                      budgets.Parent_Budget__c = parentIdMap.get(externalKeyDist) ;
                                      listOfBudgetsterr.add(budgets);
                                      
                                  }
                           }
          // Upsert listOfBudgetsterr External_key_Dist__c;
          Database.UpsertResult[] result = Database.upsert(listOfBudgetsterr, Annual_Area_Budget__c.External_key_Dist__c,false);
        for(BudgetLoadUI__c bl:scope)
        {
           bl.Status__c ='UpLoading';
        }
        update scope; 
    }
    
    global void finish(Database.BatchableContext BC){
       Database.executeBatch(new UpdateTerritoryBrandBudgetBatch(),99); 
    }
    
}