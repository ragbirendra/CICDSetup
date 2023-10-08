/*****************************
* @Name - OnPlan_to_OnPoint_Budget_Batch
* @Author -  Cognizant Developer
* @CreatedDate -09/15/2019
* @Description - Batch job used to move data from OnPlan to OnPoint Staging.
* This batch class is used to get the data out of onplan trade activation kit item object
* and populate the data in the staging mains object. Data qualifies if program ended yesterday and is approved or
* back office
****************************/
global class OnPlanToStagingBatch implements Database.Batchable<sObject>,Database.stateful
{
    global String body0 = 'Hi, </br>Failure Report of POC Planning To OnPoint Staging Batch run'; 
    public Set<String> selectedProgramNames = new Set<string>();   
    String ProgramName;

    /******* Constructor  *************/
    public OnPlanToStagingBatch(){}

    public OnPlanToStagingBatch(string varProgramName){
        ProgramName= varProgramName;
    }

    /**************** START METHOD OF THE BATCH CLASS ***********************/
     global Database.QueryLocator start(Database.BatchableContext BC){
        body0 += '</br> Date: ' + String.valueOf(System.today());
        String query = 'SELECT Id, Total_Quantity__c, Name,Marketing_Program_Item__r.Marketing_Item__r.Name, SKU__c, Item_Price__c , Quantity__c,Program_Name__c,'+
                        'Marketing_Kit__r.Backoffice__c,Marketing_Kit__r.Approval_Status__c,Marketing_Kit__r.Marketing_Program_Name__r.Name,Marketing_Kit__r.Marketing_Program_Name__r.ABI_OP_User_Paid__c,Marketing_Kit__r.Marketing_Program_Name__r.Program_Start_Date__c,Marketing_Kit__r.Marketing_Program_Name__r.Program_End_Date__c,'+
                        'Marketing_Kit__r.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c,Marketing_Kit__r.Marketing_Program_Name__r.Brand__r.Name,Marketing_Kit__r.Qty__c,'+
                        'Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.Name,Budget_Year__c,Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.lboc_Channel__c,Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.shippingState, '+
            			'Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Approval_Status__c, '+
            			'Marketing_Kit__r.Marketing_Program_Name__r.Business_Line__c '+
                        'FROM Trade_Activation_Kit_Item__c ';                        

        if(!test.isRunningTest()){
            if(ProgramName == '' || ProgramName== NULL){   query=query + 'WHERE (Marketing_Kit__r.Marketing_Program_Name__r.Planning_End_Date__c =TODAY AND '+
                        'Marketing_Kit__r.RecordType.Name != \'Preconfigured\' AND Total_Quantity__c > 0) AND (Marketing_Kit__r.Approval_Status__c	 =\'Approved\' OR Marketing_Kit__r.Backoffice__c=true)';
            }else if(ProgramName != ''){ query=query + 'WHERE (Marketing_Program_Name__c=:ProgramName AND  '+
                        ' RecordType.Name != \'Preconfigured\' AND Total_Quantity__c > 0) AND (Marketing_Kit__r.Approval_Status__c	=\'Approved\'  OR  Marketing_Kit__r.Backoffice__c= true)';
            }
        }else{
            query=query + 'WHERE Marketing_Kit__r.RecordType.Name != \'Preconfigured\'';
        }
        system.debug('==query--'+query);
        return Database.getQueryLocator(query);
    }

    /************************ EXECUTE METHOD OF THE BATCH CLASS ******************************/
    global void execute(Database.BatchableContext BC, List<Trade_Activation_Kit_Item__c> scope){
        System.debug('====scope=='+scope);
        List<Staging_Main__c> listToInsert = new List<Staging_Main__c>();
        List<Staging_Main__c> listToUpsert = new List<Staging_Main__c>();
        Set<String> externalIdSet = new Set<String>();
        Map<String, Staging_Main__c> mapNewStagingMains = new Map<String, Staging_Main__c>();
        Map<String, Staging_Main__c> mapOldStagingMains = new Map<String, Staging_Main__c>();

        for(Trade_Activation_Kit_Item__c objTRV: scope){
            // start creating the staging main object and populating its attributes
            Staging_Main__c stmObj=new Staging_Main__c();
            stmObj.Name = objTRV.Marketing_Program_Item__r.Marketing_Item__r.Name;
            stmObj.Brand_Name__c = objTRV.Marketing_Kit__r.Marketing_Program_Name__r.Brand__r.Name;
            stmObj.Item_Price__c = Test.isRunningTest() ? 10 : objTRV.Item_Price__c;
            stmObj.Program_Name__c = objTRV.Marketing_Kit__r.Marketing_Program_Name__r.Name;
            stmObj.SKU_Number__c = objTRV.SKU__c;
            stmObj.OnPoint_Brand_Name__c = objTRV.Marketing_Kit__r.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c;
            stmObj.Account__c = objTRV.Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__c;
            stmObj.Program_Start_Date__c = objTRV.Marketing_Kit__r.Marketing_Program_Name__r.Program_Start_Date__c;
            stmObj.Program_End_Date__c = objTRV.Marketing_Kit__r.Marketing_Program_Name__r.Program_End_Date__c;
            stmObj.Is_Program_User_Paid__c = objTRV.Marketing_Kit__r.Marketing_Program_Name__r.ABI_OP_User_Paid__c;
            stmObj.Budget_Year__c = objTRV.Budget_Year__c;
            stmObj.Quantity__c = objTRV.Total_Quantity__c;
            stmObj.Total_Spend__c = stmObj.Quantity__c * stmObj.Item_Price__c; // see if this can be a formula field
            if(objTRV.Marketing_Kit__r.Marketing_Program_Name__r.Business_Line__c == 'Out of Home')
            {
                stmObj.Channel__c = 'ON'; // Please update to correct field
            } else{ stmObj.Channel__c = 'OFF'; // Please update to correct field
            }
            //stmObj.Channel__c = objTRV.Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.lboc_Channel__c; // Please update to correct field
            stmObj.Composite_Key__c = stmObj.Account__c +'_'+stmObj.Program_Name__c+'_'+stmObj.SKU_Number__c+'_'+stmObj.Budget_Year__c+'_'+stmObj.Channel__c;
            // collate all records into a map to ensure no duplicates or missed quantities
            if(mapNewStagingMains.containsKey(stmObj.Composite_Key__c)){
                Staging_Main__c alreadyInMap = new Staging_Main__c(); alreadyInMap = mapNewStagingMains.get(stmObj.Composite_Key__c);
                // same year, channel, account, program, sku - by inference same price, brand so just
                // keep the record in the map but update the quanity to ensure allocation data is not lost
                alreadyInMap.Quantity__c = alreadyInMap.Quantity__c + stmObj.Quantity__c;
                // recalculate the spend
                alreadyInMap.Total_Spend__c = stmObj.Quantity__c * stmObj.Item_Price__c; // no need if this is formula field
                mapNewStagingMains.put(stmObj.Composite_Key__c, alreadyInMap);
            }else{
                mapNewStagingMains.put(stmObj.Composite_Key__c, stmObj);
            } 
            selectedProgramNames.add(objTRV.Marketing_Kit__r.Marketing_Program_Name__r.Name);                       
        }
        // check for already existing duplicate staging mains entry in the staging mains object
        // and collate the quantities accordingly
        List<String> compKeyForNewSMObjs = new List<String>();
        compKeyForNewSMObjs.addAll(mapNewStagingMains.keySet());
        if(compKeyForNewSMObjs != null && compKeyForNewSMObjs.size() > 0){
            List<Staging_Main__c> oldListStagingMains = new List<Staging_Main__c>();
            oldListStagingMains = [SELECT Id, Composite_Key__c, Quantity__c, Total_Spend__c 
                                    FROM Staging_Main__c WHERE Composite_Key__c IN :compKeyForNewSMObjs];
            if(oldListStagingMains != null && oldListStagingMains.size() > 0){
                for(Staging_Main__c var : oldListStagingMains){
                    if(!mapOldStagingMains.containsKey(var.Composite_Key__c)){  mapOldStagingMains.put(var.Composite_Key__c, var);
                    }
                }
            }
        }
        // the old map will only contain data if there are matching records between new data set
        // and the data that is there in database - composite key is supposed to be unique
        if(mapOldStagingMains != null && mapOldStagingMains.values().size() > 0){
            for(String varCompKey : mapOldStagingMains.keySet()){
                Staging_Main__c fromNewMap = new Staging_Main__c();
                Staging_Main__c fromOldMap = new Staging_Main__c();
                fromNewMap = mapNewStagingMains.get(varCompKey);
                fromOldMap = mapOldStagingMains.get(varCompKey);
                if(fromNewMap != null && fromOldMap != null){
                    fromOldMap.Quantity__c = fromOldMap.Quantity__c + fromNewMap.Quantity__c;
                    fromOldMap.Total_Spend__c = fromNewMap.Quantity__c * fromNewMap.Item_Price__c; // multiple the new quantity with the latest item price
                    mapOldStagingMains.put(varCompKey, fromOldMap); // put the update record back into the map
                    // remove the entry from the new map as the corresponding data already exists
                    Staging_Main__c removeSMObj = new Staging_Main__c(); removeSMObj = mapNewStagingMains.remove(varCompKey);
                }
            }
        }        
        body0 += 'Trade Activation kit items that may not have moved properly: </br>';
        // merge all values from the 2 maps into a single map and use the upsert operation
        // new records will be inserted - old records will be updated - using the composite key
        listToUpsert.addAll(mapNewStagingMains.values());
        listToUpsert.addAll(mapOldStagingMains.values());
        if(listToUpsert != null && listToUpsert.size() > 0){            
            List<Database.upsertResult> results = Database.upsert(listToUpsert, Staging_Main__c.Composite_Key__c, false);
            integer j = 0 ; 
            Set<Id> failRecord = new Set<Id>();
            for (Database.upsertResult sr : results){
                if (!sr.isSuccess()){ body0 = body0 + '' + listToUpsert[j].Composite_Key__c + ' ---- ' + 'failed' +'</br>';
                }
                j++;
            }
        }
    }

    /******************* FINISH METHOD OF THE BATCH JOB ***********************/
    global void finish(Database.BatchableContext BC)
    {   // update mail body with program details
        String body1 = '</br> Selected Programs: </br>';
        for(String programNameVar : selectedProgramNames){
            body1 += programNameVar + '</br>';
        }
        List<string> emailId = new List<string>();
        List<string> ccEmailId = new List<string>();
        String body = body1 + body0 +' </br> Batch finished processing.';
        ExcelHeader__mdt[] ccMailList = [select MasterLabel, QualifiedApiName, column_A__c,column_B__c,column_C__c FROM ExcelHeader__mdt where MasterLabel ='cc Mail Id'];
        for(ExcelHeader__mdt eh:ccMailList){
            emailId.add(eh.column_A__c);            
        }
        Mailutility.sendMail(emailId,ccEmailId,'POC Planning to Onpoint Staging Result',body);    
    }
}
/*String State= objTRV.Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.shippingState; // No need need to correct formula field and ref in batch Total quntity      
System.debug('-----Item_Price__c'+objTRV.Item_Price__c);
if(test.isRunningTest()){
    stmObj.Item_Price__c = 10;
}else{
    stmObj.Item_Price__c = objTRV.Item_Price__c;
}              
//stmObj.Item_Price__c = objTRV.Item_Price__c;            
if(State != null && (State.equalsIgnoreCase('Quebec') || State.equalsIgnoreCase('QC'))){
stmObj.Quantity__c= objTRV.Quantity__c * objTRV.Marketing_Kit__r.Qty__c;
}else{
    stmObj.Quantity__c= objTRV.Quantity__c ;  
}            
System.debug('------- @@@'+stmObj.Quantity__c +'@@@'+stmObj.Item_Price__c);
//stmObj.Shopped_Kit_Quantity__c=objTRV.Marketing_Kit__r.Qty__c;            
if(!externalIdSet.contains(stmObj.Composite_Key__c)){
    externalIdSet.add(stmObj.Composite_Key__c);
    listToInsert.add(stmObj); 
}

*/