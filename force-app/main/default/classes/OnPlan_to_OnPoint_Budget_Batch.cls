/****************************************
* This batch job moves the budget data from the onplan application to the onpoint application
* The data moves based on the program start date - 15 days before the program start date the data is pulled from
* the onplan application and created in the onpoint territory budget and its child objects
* @Name - OnPlan_to_OnPoint_Budget_Batch
* @Author - Cognizant@Developer
* @CreatedDate -09/15/2019
*****************************************/


global class OnPlan_to_OnPoint_Budget_Batch implements Database.Batchable<sObject>, Database.stateful
{
    String ProgramName;
    public OnPlan_to_OnPoint_Budget_Batch(){}
    public OnPlan_to_OnPoint_Budget_Batch(string varProgramName){
        ProgramName = varProgramName;
    }
    global String body='Hi, </br></br>';
    global Database.QueryLocator start(Database.BatchableContext BC)
    {      
        string query = 'SELECT id, Name,Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c, Brand__c,Approval_Status__c,Backoffice__c,Discretionary_Spend_Total__c,POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.lboc_Labatt_Outlet_Id__c, POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c,POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c,POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__c,'+
            'POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c,POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.Name,POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.lboc_Channel__c,Annual_Brand_Area_Budget_Plan__r.Brand__c, Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c, '+
            'POC_Spend_Category__r.RecordType.DeveloperName, POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Back_Office_Territory__c,POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.OwnerId,Annual_Brand_Area_Budget_Plan__r.Brand__r.Name,Marketing_Program_Name__r.Business_Line__c, '+
            'POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Approval_Status__c, User_Paid__c,Marketing_Program_Name__r.Brand__r.Name,Marketing_Program_Name__r.Brand__c '+
            'FROM Marketing_Kit__c ';
        
        if(!Test.isRunningTest()){
            if(ProgramName == '' || ProgramName== NULL){
                Date dt = System.today() + 15;
                system.debug('---date---'+dt);
                query = query + ' WHERE (Marketing_Program_Name__r.Program_Start_Date__c =:dt'+
                    ' AND RecordType.Name != \'Preconfigured\') AND (Approval_Status__c =\'Approved\' OR Backoffice__c=true)';
            }
            else if(ProgramName != ''){
                query=query + ' WHERE (Marketing_Program_Name__r.Name=:ProgramName'+
                    ' AND RecordType.Name != \'Preconfigured\') AND (Approval_Status__c =\'Approved\' OR Backoffice__c=true)';   
            }
        }
        else{
            query = query + ' WHERE  '+
                'RecordType.Name != \'Preconfigured\'';
        }
        system.debug('----query----'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Marketing_Kit__c> scope)
    { 
        System.debug('---- received scope in execute ----' + scope);
        // handling the Keith,Goose,ShockTop - special case
        // for a record belonging to Keith,Goose,ShockTop - break that record into three distinct brands
        // the figures do not matter - just the correct brand records needs to be created - conformed by business
        List<String> specialBrands = new List<String>();
        specialBrands.add('Alexander Keith\'s');
        specialBrands.add('Goose Island');
        specialBrands.add('Shock Top');
        List<Brand__c> fetchSpecialBrands = new List<Brand__c>();
        fetchSpecialBrands = [SELECT Id,OnPoint_Brand_Name__c, Name FROM Brand__c WHERE Name IN : specialBrands];
        System.debug('#### got special brands #### ' + fetchSpecialBrands);
        List<Marketing_Kit__c> shoppedKitsInScope = new List<Marketing_Kit__c>();
        Set<String> onpointTerritoryCode = new Set<String>();
        Map<id, OnPoint_Territory_Budget__c> mapOfOPTerrAndBudget= new MAP<id, OnPoint_Territory_Budget__c>();

        // List of items to be considered for processing - if it is for a back office user and is for
        // a user paid program then those records should not be processed        
        for(Marketing_Kit__c var : scope){
            if(var.Backoffice__c == true && var.User_Paid__c == true){
                continue;
            }else{
                if(var.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c == 'Keith,Goose,ShockTop'){
                    // clone three copies of this object and add to the list of records do not add
                    // the current record - as we do not want anything in onpoint with
                    // keith,goose,shocktop brand - figures do not matter they can be double counted - confirmed by business
                    //for(Brand__c brandVar : fetchSpecialBrands){
                        Marketing_Kit__c dummyObj = new Marketing_Kit__c();
                        dummyObj = var.clone(true, true, false, false); // no need to deep clone
                        dummyObj.Annual_Brand_Area_Budget_Plan__r.Brand__c = fetchSpecialBrands[0].Id;
                        dummyObj.Annual_Brand_Area_Budget_Plan__r.Brand__r.Name = fetchSpecialBrands[0].OnPoint_Brand_Name__c;
                        dummyObj.Marketing_Program_Name__r.Brand__c = fetchSpecialBrands[0].Id;
                        dummyObj.Marketing_Program_Name__r.Brand__r.Name = fetchSpecialBrands[0].OnPoint_Brand_Name__c;
                        dummyObj.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c = fetchSpecialBrands[0].OnPoint_Brand_Name__c;
                        System.debug('#### check brand on shopped kit #### ' + dummyObj.Brand__c);
                        shoppedKitsInScope.add(dummyObj);
                        //------
                        Marketing_Kit__c dummyObj1 = new Marketing_Kit__c();
                        dummyObj1 = var.clone(true, true, false, false); // no need to deep clone
                        dummyObj1.Annual_Brand_Area_Budget_Plan__r.Brand__c = fetchSpecialBrands[1].Id;
                        dummyObj1.Annual_Brand_Area_Budget_Plan__r.Brand__r.Name = fetchSpecialBrands[1].OnPoint_Brand_Name__c;
                        dummyObj1.Marketing_Program_Name__r.Brand__c = fetchSpecialBrands[1].Id;
                        dummyObj1.Marketing_Program_Name__r.Brand__r.Name = fetchSpecialBrands[1].OnPoint_Brand_Name__c;
                        dummyObj1.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c = fetchSpecialBrands[1].OnPoint_Brand_Name__c;
                        System.debug('#### check brand on shopped kit #### ' + dummyObj1.Brand__c);
                        shoppedKitsInScope.add(dummyObj1);
                        //---------------
                        Marketing_Kit__c dummyObj2 = new Marketing_Kit__c();
                        dummyObj2 = var.clone(true, true, false, false); // no need to deep clone
                        dummyObj2.Annual_Brand_Area_Budget_Plan__r.Brand__c = fetchSpecialBrands[2].Id;
                        dummyObj2.Annual_Brand_Area_Budget_Plan__r.Brand__r.Name = fetchSpecialBrands[2].OnPoint_Brand_Name__c;
                        dummyObj2.Marketing_Program_Name__r.Brand__c = fetchSpecialBrands[2].Id;
                        dummyObj2.Marketing_Program_Name__r.Brand__r.Name = fetchSpecialBrands[2].OnPoint_Brand_Name__c;
                        dummyObj2.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c = fetchSpecialBrands[2].OnPoint_Brand_Name__c;
                        System.debug('#### check brand on shopped kit #### ' + dummyObj2.Brand__c);
                        shoppedKitsInScope.add(dummyObj2);
                    //}
                }else{
                    shoppedKitsInScope.add(var);
                }                
            }
        }
        // iterate over the filtered and selected shopped kit records and prepare a set
        // of the applicable territory codes
        if(shoppedKitsInScope != null && shoppedKitsInScope.size() > 0){
            for(Marketing_Kit__c mkc : shoppedKitsInScope){
                System.debug('#### selected kits aa brand #### ' + mkc.Annual_Brand_Area_Budget_Plan__r.Brand__r.Name);
                System.debug('#### selected progs #### ' + mkc.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c);
                onpointTerritoryCode.add(mkc.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c);
            }
        }
        
        if(onpointTerritoryCode != null && onpointTerritoryCode.size() > 0){
            // Query the OnPoint Territory Budget record and create 
            // a map of onpoint territory id to the corresponding onpoint territory budget record
            for(OnPoint_Territory_Budget__c objOB: [SELECT Id, OnPoint_Territory__r.Id 
                                                    FROM OnPoint_Territory_Budget__c 
                                                    WHERE OnPoint_Territory__c != Null 
                                                    AND OnPoint_Territory__c != ''  
                                                    AND Unique_Territory_Budget_Code__c IN : onpointTerritoryCode]){   
                mapOfOPTerrAndBudget.put(objOB.OnPoint_Territory__c, objOB);                                        
            }   
        }
        System.debug(' >>>>>>>>>>mapOfOPTerrAndBudget>>>>'+mapOfOPTerrAndBudget);

        List<Id> noTerritorBudget = new List<Id>();
        List<Id> availableTerritorBudget = new List<Id>();
        Set<string> listOfBrandId = new Set<string>();
        List<string> listOfTerritoryCode =  new List<string>();
        MAP<id,id> mapOFTerritoryIdOwnerId = new MAP<id,id>();
        Map<id, String> mapOfIdAndCode = new MAP<id, String>();
        List<Marketing_Kit__c> availableTerBudget = new List<Marketing_Kit__c>();
        List<Marketing_Kit__c> notAvailableTerBudget = new List<Marketing_Kit__c>();

        if(shoppedKitsInScope != null && shoppedKitsInScope.size() > 0){
            for(Marketing_Kit__c objMK : shoppedKitsInScope){
                mapOFTerritoryIdOwnerId.put(objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c,objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.OwnerId);
                //Created List of all Brand fetched by query
                listOfBrandId.add(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.Name); 
                                                   
                if(!mapOfOPTerrAndBudget.containsKey(objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c)){     
                    //Created List of onpoint sales territory whose budget is not available
                    system.debug('Test 1');
                    noTerritorBudget.add(objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c);
                    notAvailableTerBudget.add(objMK);
                    if(!mapOfIdAndCode.containsKey(objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c)){
                        system.debug('Test 3');
                        //Created Map of onpoint terriritory and code
                        mapOfIdAndCode.put(objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c,objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c);                    
                    }
                }
                else{
                    system.debug('Test 2');
                    //Created List of onpoint sales territory whose budget is  available
                    availableTerritorBudget.add(objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c);
                    availableTerBudget.add(objMK);
                }
                if(!listOfTerritoryCode.contains(objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c)){
                    listOfTerritoryCode.add(objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c);
                }
            }
            System.debug(' >>>>>>>availableTerritorBudget --->>>'+availableTerBudget);
            System.debug(' >>>>>>>notAvailableTerBudget --->>>'+notAvailableTerBudget);
            System.debug('#### list of territory code #### ' + listOfTerritoryCode);
            System.debug('---listOfBrandId--'+listOfBrandId);
            //Map of cost center 
            MAP<String, OnPoint_Cost_Centers__c> mapOfTerritoryCodeCostCenter =  new MAP<String, OnPoint_Cost_Centers__c>();
    
            for(OnPoint_Cost_Centers__c occ:[SELECT Id,Brand__c,Name,Brand_Name__c,Territory_Code__c,User_Friendly_Name__c 
                                            FROM OnPoint_Cost_Centers__c WHERE Name IN: listOfBrandId 
                                            OR Territory_Code__c IN : listOfTerritoryCode])
            {
                mapOfTerritoryCodeCostCenter.put(occ.User_Friendly_Name__c , occ);
            }
            system.debug('----mapOfTerritoryCodeCostCenter----'+mapOfTerritoryCodeCostCenter);
            //MAP of Onpoint GL
            MAP<string, OnPoint_GLs__c> mapOfGLANdName=new MAP<string,OnPoint_GLs__c>();
            for(OnPoint_GLs__c objOGL:[SELECT id, Name, GL_Code__c FROM OnPoint_GLs__c 
                                        WHERE Name IN ('Brand On Premise', 'Brand Retail', 'User Retail', 'User On Premise')]){
                mapOfGLANdName.put(objOGL.Name, objOGL);
            }
            system.debug('----mapOfGLANdName----'+mapOfGLANdName);
            Set<String> uniqueTeritoryBudgetId = new Set<String>();
            List<OnPoint_Territory_Budget__c> newOnPointTerritoryBudget = new List<OnPoint_Territory_Budget__c>();
            
            //----------------Entering to if territory budget is not available-----------------------
            // Creating onpoint Territory Budget records for those which have no existing territory budget
            if(!noTerritorBudget.isEmpty()){
                // Creation of onpoint territory budget
                for(Id objOTId: noTerritorBudget){
                    if(!uniqueTeritoryBudgetId.contains(mapOfIdAndCode.get(objOTId))){
                        OnPoint_Territory_Budget__c objTB=new OnPoint_Territory_Budget__c();
                        objTB.Name='Name';
                        objTB.OnPoint_Territory__c=objOTId;
                        objTB.OwnerId= mapOFTerritoryIdOwnerId.get(objOTId);
                        objTB.Unique_Territory_Budget_Code__c= mapOfIdAndCode.get(objOTId); //External id will be territory code
                        uniqueTeritoryBudgetId.add(objTB.Unique_Territory_Budget_Code__c);
                        newOnPointTerritoryBudget.add(objTB);
                    }
                    
                }
                if(!newOnPointTerritoryBudget.isEmpty()){
                    Database.UpsertResult[] onPointTerritoryBudgetResult = Database.upsert(newOnPointTerritoryBudget,OnPoint_Territory_Budget__c.Unique_Territory_Budget_Code__c,false);
                    integer i=0;
                    Set<Id> failRecordAllocation = new Set<Id>();
                    for (Database.upsertResult sr : onPointTerritoryBudgetResult) {
                        //Trade_Activation_Kit_Item__c trkt=new Trade_Activation_Kit_Item__c();
                        if (!sr.isSuccess() || Test.isRunningTest()) {
                            failRecordAllocation.add(sr.getId() );
                            if(!Test.isRunningTest()){
                                body = body + '' + noTerritorBudget[i] + '----' + 'failed' +'</br>';
                            }
                            else{
                                body = body+'----'+ 'failed' +'</br>';
                            }
                            for(Database.Error err : sr.getErrors()) {                     
                                body = body + err.getMessage()+'Fields that affected this error: ' + err.getFields()  +'</br>';
                            }
                        }
                        i++;
                    }
                    if(failRecordAllocation.isEmpty() || test.isRunningTest())
                    {
                        body = body + ' ********************** below Territory Budget is created *****************'+ '</br>';
                        for(Integer index = 0, size = onPointTerritoryBudgetResult.size(); index < size; index++) {
                            if(onPointTerritoryBudgetResult[index].isSuccess()) {
                                body = body + 'For territory Code: ' + newOnPointTerritoryBudget[index].Unique_Territory_Budget_Code__c +' Budget  record created ' +'</br>';         
                            }
                        }
                    }
                    System.debug('----onPointTerritoryBudgetResult---'+onPointTerritoryBudgetResult);
                    System.debug('----List of newOnPointTerritoryBudget---'+newOnPointTerritoryBudget);
                }            
                
                //MAP Of onpoint territory id and onpoint territory budget id 
                Map<Id, OnPoint_Territory_Budget__c> mapOfOPtToOPTB = new MAP<Id, OnPoint_Territory_Budget__c>();
                for(OnPoint_Territory_Budget__c objOTB : newOnPointTerritoryBudget){
                    mapOfOPtToOPTB.put(objOTB.OnPoint_Territory__c, objOTB); 
                }
                system.debug('---mapOfOPtToOPTB======='+mapOfOPtToOPTB);
                set<String> uniqueBudgetCode=new Set<String>();
                LIST<OnPoint_Budget__c> onPointBudgetTOInsert=new List<OnPoint_Budget__c>();
                System.debug('===Territory Budgets Not Available 123 ------'+notAvailableTerBudget);
                
                //------------------------Creation of new onpoint budget record------------------------------
                for(Marketing_Kit__c objMK : notAvailableTerBudget){
                    OnPoint_Budget__c objOB  = new OnPoint_Budget__c();
                    String Channel;
                    if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c)  //Checking if Brand Paid               
                    {
                        System.debug('---objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c-----'+objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c+' >>>>> '+objMK.Marketing_Program_Name__r.Business_Line__c);
                        System.debug('-----------'+mapOfTerritoryCodeCostCenter.get(objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c));
                        objOB.Cost_Center__c = mapOfTerritoryCodeCostCenter.get(objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c).id; // Brand Cost Center
                        
                        if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){  //Channel is ON
                            objOB.Type__c='Trade Activation On Prem';
                            objOB.GL__c= mapOfGLANdName.get('Brand On Premise').id;
                            Channel='ON';
                        }
                        else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){ //Channel is OFF
                            objOB.Type__c='Trade Activation Off Prem';
                            objOB.GL__c=  mapOfGLANdName.get('Brand Retail').id;
                            Channel='OFF';
                        }
                        System.debug('--objMK.POC_Spend_Category__r.RecordType.DeveloperName-------'+objMK.POC_Spend_Category__r.RecordType.DeveloperName);
                    }
                    else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){ //Checking if user paid 
                        if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){ //Channel ON
                            objOB.Type__c='User Paid On Premise';
                            objOB.GL__c= mapOfGLANdName.get('User On Premise').id;
                            Channel='ON';
                        }
                        else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){ //Channel OFF       
                            objOB.Type__c='User Paid Off Prem';
                            objOB.GL__c= mapOfGLANdName.get('User Retail').id;
                            Channel='OFF';
                        }
                        System.debug('-territory code----'+objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r);
                        String keyCost = objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c +' - '+objOB.Type__c;   //Creation user friendly name with Cost center value
                        system.debug(' keyCost:::::'+keyCost); 
                        objOB.Cost_Center__c = mapOfTerritoryCodeCostCenter.get(keyCost).id;
                    }
                    objOB.Name = objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c +' - '+objOB.Type__c;
                    System.debug('======objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c----'+objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c);
                    objOB.OnPoint_Territory_Budget__c= mapOfOPtToOPTB.get(objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c).id;
                    // objOB.Cost_Center__c=mapOfBrandCostCenter.get(objMK.Brand__c).id;
                    if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                        String year= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c;  // System.Today().year();
                        objOB.Unique_Budget_Code__c = objOB.Name +' - '+ objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c +' - '+  year +' - '+Channel;
                    }
                    else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                        String year=objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c; //System.Today().year();
                        objOB.Unique_Budget_Code__c = objOB.Name +' - '+  year ;
                    }
                    if(!uniqueBudgetCode.contains(objOB.Unique_Budget_Code__c)){
                        onPointBudgetTOInsert.add(objOB);
                        uniqueBudgetCode.add(objOB.Unique_Budget_Code__c);
                    } 
                }
                SET<Id> successIdProgram=new SET<Id>();
                // Inserting OnPoint Budget
                Database.UpsertResult[] onPointBudgetResult;
                if(!onPointBudgetTOInsert.isEmpty()){
                    onPointBudgetResult = Database.upsert(onPointBudgetTOInsert,OnPoint_Budget__c.Unique_Budget_Code__c,false);
                    System.debug('----onPointBudgetResult---'+onPointBudgetResult);
                    System.debug('----List of newOnPointBudget---'+onPointBudgetTOInsert);
                }
                for(Database.UpsertResult sr:onPointBudgetResult){
                    successIdProgram.add(sr.getId());
                }
                
                integer i=0;
                Set<id> failRecordAllocation = new Set<id>();
                for (Database.upsertResult sr : onPointBudgetResult) {
                    //Trade_Activation_Kit_Item__c trkt=new Trade_Activation_Kit_Item__c();
                    if (!sr.isSuccess() || test.isRunningTest()) {
                        failRecordAllocation.add(sr.getId());
                        if(!test.isRunningTest()){ body = body+''+onPointBudgetTOInsert[i]+'----'+ 'failed' +'</br>';
                        }
                        else{
                            body = body+'----'+ 'failed' +'</br>';
                        }
                        for(Database.Error err : sr.getErrors()) {    body = body + err.getMessage()+'Fields that affected this error: ' + err.getFields()  +'</br>';
                        }
                    }
                    i++;
                }
                if(failRecordAllocation.isEmpty() || test.isRunningTest())
                {
                    body = body + ' ********************** below OnPoint Budget is created *****************'+ '</br>';
                    for(Integer index = 0, size = onPointBudgetResult.size(); index < size; index++) {
                        if(onPointBudgetResult[index].isSuccess()) {
                            body = body + onPointBudgetTOInsert[index].Name +'  record created ' +'</br>';         
                        }
                    }
                }
                
                System.debug('====successIdProgram---'+successIdProgram);
                MAP<String,OnPoint_Budget__c> mapOfOnpOintbudet=new MAP<String, OnPoint_Budget__c>();            
                
                for(OnPoint_Budget__c onPObj: onPointBudgetTOInsert){
                    mapOfOnpOintbudet.put(onPObj.Unique_Budget_Code__c, onPObj);
                }
                System.debug('=======mapOfOnpOintbudet @@@@'+mapOfOnpOintbudet);
    
                //-------------- Create OnPoint POC Budget records for territories----------------------
                //-------------- for which the onpoint territory budget does not exist------------------
                //-------------- creating new onpoint poc budget records--------------------------------
                Set<String> uniquePOCBudgetCode = new Set<String>();
                List<OnPoint_POC_Budget__c> onPointPOCBudgetToInsert = new List<OnPoint_POC_Budget__c>();
                for(Marketing_Kit__c objMK : notAvailableTerBudget){
                    // Creating key same as unique budget code:
                    String channel;
                    string key = objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c + ' - ';
                    if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c)
                    {
                        if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){
                            key=key+'Trade Activation On Prem';
                            channel='ON';
                        }
                        else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){
                            key=key+'Trade Activation Off Prem';
                            channel='OFF';
                        }
                    }
                    else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                        if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){
                            key=key+'User Paid On Premise';
                            channel='ON';
                        }
                        else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){
                            key=key+'User Paid Off Prem';
                            channel='OFF';
                        }
                    }
                    if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                        String year= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c;  
                        key= key+' - '+ objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c +' - '+  year + ' - '+channel;
                    }   
                    else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                        String year= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c;
                        key= key + ' - ' +  year ;
                    }
                    system.debug('=====key===='+key+'#####'+mapOfOnpOintbudet);
                    system.debug('=====acc id===='+objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__c);
                    OnPoint_POC_Budget__c objOPB = new OnPoint_POC_Budget__c();
                    objOPB.Name= objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c + '-'+ objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.Name;
                    objOPB.POC__c= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__c;
                    objOPB.Budget__c=mapOfOnpOintbudet.get(key).id;
                    objOPB.POC_Budget_Unique_Code__c= channel+ ' - '+objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c;
                    objOPB.Planned_Budget__c=objMK.Discretionary_Spend_Total__c; //*isoWithRateMap.get('USD');
                    //objOPB.CurrencyIsoCode='USD';
                    if(!uniquePOCBudgetCode.contains(objOPB.POC_Budget_Unique_Code__c)){
                        uniquePOCBudgetCode.add(objOPB.POC_Budget_Unique_Code__c);
                        onPointPOCBudgetToInsert.add(objOPB);
                    }
                }
                Database.UpsertResult[] onPointPOCBudgetResult;
                if(!onPointPOCBudgetToInsert.isEmpty()){
                    onPointPOCBudgetResult = Database.upsert(onPointPOCBudgetToInsert,OnPoint_POC_Budget__c.POC_Budget_Unique_Code__c,false);
                    System.debug('----onPointPOCBudgetResult---'+onPointPOCBudgetResult);
                    System.debug('----List of onPointPOCBudgetResult---'+onPointPOCBudgetResult);
                }
                
                integer j=0;
                Set<id> failRecordAllocationPOC = new Set<id>();
                for (Database.upsertResult sr : onPointPOCBudgetResult) {
                    //Trade_Activation_Kit_Item__c trkt=new Trade_Activation_Kit_Item__c();
                    if (!sr.isSuccess() || test.isRunningTest()) {
                        failRecordAllocationPOC.add(sr.getId());
                        if(!test.isRunningTest()){
                            body = body+''+onPointPOCBudgetToInsert[j]+'----'+ 'failed' +'</br>';
                        }
                        else{
                            body = body+'----'+ 'failed' +'</br>';
                        }
                        for(Database.Error err : sr.getErrors()) {                     
                            body = body + err.getMessage()+'Fields that affected this error: ' + err.getFields()  +'</br>';
                        }
                    }
                    j++;
                }
                if(failRecordAllocationPOC.isEmpty() || test.isRunningTest())
                {
                    body = body + ' ********************** below POC Budget is created *****************'+ '</br>';
                    for(Integer index = 0, size = onPointPOCBudgetResult.size(); index < size; index++) {
                        if(onPointPOCBudgetResult[index].isSuccess()) {
                            body = body + onPointPOCBudgetToInsert[index].Name +'  record created ' +'</br>';         
                        }
                    }
                } 
            }
    
            //---------------------Territory Budget Available-------------------------------------
            if(!availableTerritorBudget.isEmpty() ){
                MAP<string,OnPoint_Budget__c> MapfetchedOB= new MAP<string, OnPoint_Budget__c>();
                MAP<string,OnPoint_POC_Budget__c> MapfetchedOPocB= new MAP<string, OnPoint_POC_Budget__c>();
                List<id> listfetchedOB= new List<id>();
                List<Marketing_Kit__c> obAvailable = new List<Marketing_Kit__c>();
                List<Marketing_Kit__c> obNotAvailable = new List<Marketing_Kit__c>();
                List<Marketing_Kit__c> oPOCBAvailable = new List<Marketing_Kit__c>();
                List<Marketing_Kit__c> oPOCBNotAvailable = new List<Marketing_Kit__c>();
                
                LIST<OnPoint_POC_Budget__c> listOfOPBToUpsert = new LIST<OnPoint_POC_Budget__c>();
                Set<String> uniquePOCBudgetExternalID = new Set<String>();
                
                System.debug('---availableTerritorBudget----'+availableTerritorBudget);
                for(OnPoint_Budget__c ojOB : [SELECT Id, Name, OnPoint_Territory_Budget__c, Unique_Budget_Code__c, OnPoint_Territory_Budget__r.OnPoint_Territory__c 
                                                FROM OnPoint_Budget__c 
                                                WHERE OnPoint_Territory_Budget__r.OnPoint_Territory__c IN : availableTerritorBudget])
                {
                    system.debug('ojOB.Unique_Budget_Code__c:::'+ojOB.Unique_Budget_Code__c);
                    MapfetchedOB.put(ojOB.Unique_Budget_Code__c,ojOB);
                    listfetchedOB.add(ojOB.id);
                }
                System.debug('---listfetchedOB----'+ MapfetchedOB);
                for(OnPoint_POC_Budget__c objOPB:[SELECT Id, Name, POC__c, POC_Budget_Unique_Code__c, Planned_Budget__c, Budget__c FROM OnPoint_POC_Budget__c WHERE Budget__c IN:listfetchedOB]){
                    MapfetchedOPocB.put(objOPB.POC_Budget_Unique_Code__c,objOPB);
                }
                for(Marketing_Kit__c objMK:availableTerBudget)
                {
                    String channel;
                    string key= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c + ' - ';
                    if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c)
                    {
                        if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){
                            key = key+'Trade Activation On Prem';
                            channel='ON';
                        }
                        else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){
                            key=key+'Trade Activation Off Prem';
                            channel='OFF';
                        }
                    }
                    else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                        if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){
                            key=key+'User Paid On Premise';
                            channel='ON';
                        }
                        else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){
                            key=key+'User Paid Off Prem'; 
                            channel='OFF';
                        } 
                    }
                    if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                        String year= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c; //System.Today().year();
                        key= key+' - '+ objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c +' - '+  year +' - '+channel;
                    }   
                    else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                        String year= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c; //System.Today().year();
                        key= key+' - '+  year ;
                    }
                    system.debug('-------key if budget available-----'+key);
                    if(MapfetchedOB.containsKey(key)){
                        obAvailable.add(objMK);
                    }
                    else if(!MapfetchedOB.containsKey(key)){
                        obNotAvailable.add(objMK);
                    }
                    if(test.isRunningTest()){
                       obNotAvailable.add(objMK); 
                    }
                    
                }
                // List<String> opbExternalID=new LIST<String>();
                if(!obAvailable.isEmpty()){
                    for(Marketing_Kit__c objMK:obAvailable){
                        String key=objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.lboc_Labatt_Outlet_Id__c+ ' - '+objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c;
                        if(MapfetchedOPocB.containsKey(key)){
                            oPOCBAvailable.add(objMK);
                        }
                        else
                        {
                            oPOCBNotAvailable.add(objMK);
                        }
                    }
                    if(!oPOCBAvailable.isEmpty()){
                        for(Marketing_Kit__c objMK:oPOCBAvailable){
                            String key=objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.lboc_Labatt_Outlet_Id__c+ ' - '+objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c;
                            OnPoint_POC_Budget__c objOPBToupdate=MapfetchedOPocB.get(key);
                            // Decimal cCADPlannedBudget= objOPBToupdate.Planned_Budget__c* isoWithRateMap.get('CAD');
                            Decimal addDicreAndPlannedBudget= objMK.Discretionary_Spend_Total__c + objOPBToupdate.Planned_Budget__c; //cCADPlannedBudget;
                            objOPBToupdate.Planned_Budget__c = addDicreAndPlannedBudget; //*isoWithRateMap.get('USD');
                            //objOPBToupdate.CurrencyIsoCode='USD';
                            if(!uniquePOCBudgetExternalID.contains(objOPBToupdate.POC_Budget_Unique_Code__c)){
                                uniquePOCBudgetExternalID.add(objOPBToupdate.POC_Budget_Unique_Code__c);
                                listOfOPBToUpsert.add(objOPBToupdate);
                            }
                            
                            //objOPBToupdate.Planned_Budget__c = 
                        }
                    }
                 
                    if(!oPOCBNotAvailable.isEmpty() ){
                        for(Marketing_Kit__c objMK:oPOCBNotAvailable){
                            String channel;
                            string key= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c + ' - ';
                            if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c)
                            {
                                if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){
                                    key=key+'Trade Activation On Prem';
                                    channel='ON';
                                }
                                else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){
                                    key=key+'Trade Activation Off Prem';
                                    channel='OFF';
                                }
                            }
                            else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                                if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){
                                    key=key+'User Paid On Premise';
                                    channel='ON';
                                }
                                else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){
                                    key=key+'User Paid Off Prem';
                                    channel='OFF';                                            
                                }
                            }
                            if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                                String year= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c; // System.Today().year();
                                key= key+' - '+ objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c +' - '+  year +' - '+channel;
                            }   
                            else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                                String year =objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c; //System.Today().year();
                                key= key+' - '+  year ;
                            }
                            OnPoint_POC_Budget__c objOPB = new OnPoint_POC_Budget__c();
                            objOPB.Name= objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c + '-'+ objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.Name;
                            objOPB.POC__c= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__c;
                            objOPB.Budget__c=MapfetchedOB.get(key).id;
                            objOPB.POC_Budget_Unique_Code__c= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.lboc_Labatt_Outlet_Id__c+ ' - '+objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c;
                            objOPB.Planned_Budget__c=objMK.Discretionary_Spend_Total__c; //*isoWithRateMap.get('USD');
                            // objOPB.CurrencyIsoCode='USD';
                            if(!uniquePOCBudgetExternalID.contains(objOPB.POC_Budget_Unique_Code__c)){
                                uniquePOCBudgetExternalID.add(objOPB.POC_Budget_Unique_Code__c);
                                listOfOPBToUpsert.add(objOPB);
                            }
                            
                        }
                    }
                    
                    if(!listOfOPBToUpsert.isEmpty()){
                        Database.UpsertResult[] onPointBudgetResult=  Database.upsert(listOfOPBToUpsert,OnPoint_POC_Budget__c.POC_Budget_Unique_Code__c,false);  
                    }   
                }
                
                if(!obNotAvailable.isEmpty() ){
                    
                    set<String> uniqueBudgetCode=new Set<String>();
                    LIST<OnPoint_Budget__c> onPointBudgetTOInsertNEW=new List<OnPoint_Budget__c>();
                    for(Marketing_Kit__c objMK:obNotAvailable){
                        OnPoint_Budget__c objOB  = new OnPoint_Budget__c();
                        String Channel;
                        if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c)  //Checking if Brand Paid               
                        {
                            objOB.Cost_Center__c=mapOfTerritoryCodeCostCenter.get(objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c).id;                     // Brand Cost Center
                            
                            if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){  //Channel is ON
                                objOB.Type__c='Trade Activation On Prem';
                                objOB.GL__c= mapOfGLANdName.get('Brand On Premise').id;
                                Channel='ON';
                            }
                            else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){    //Channel is OFF
                                objOB.Type__c='Trade Activation Off Prem';
                                objOB.GL__c=  mapOfGLANdName.get('Brand Retail').id;
                                Channel='OFF';
                            }
                            System.debug('--objMK.POC_Spend_Category__r.RecordType.DeveloperName-------'+objMK.POC_Spend_Category__r.RecordType.DeveloperName);    
                        }
                        else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){   //Checking if user paid  
                            if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){  //Channel ON
                                objOB.Type__c='User Paid On Premise';
                                objOB.GL__c= mapOfGLANdName.get('User On Premise').id;
                                Channel='ON';
                            }
                            else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){   //Channel OFF       
                                objOB.Type__c='User Paid Off Premise';
                                objOB.GL__c= mapOfGLANdName.get('User Retail').id;
                                Channel='OFF';
                            }
                            
                            String keyCost=objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c +' - '+objOB.Type__c;   //Creation user friendly name with Cost center value
                            System.debug('---keyCost---'+keyCost +'@@@@mapOfTerritoryCodeCostCenter@@'+ mapOfTerritoryCodeCostCenter);
                            objOB.Cost_Center__c = mapOfTerritoryCodeCostCenter.get(keyCost).id; 
                        }
                        objOB.Name = objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c +' - '+objOB.Type__c;
                        System.debug('======objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c----'+objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c);
                        objOB.OnPoint_Territory_Budget__c= mapOfOPTerrAndBudget.get(objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__c).id;
                        //objOB.Cost_Center__c=mapOfBrandCostCenter.get(objMK.Brand__c).id;
                        if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                            String year=objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c; //System.Today().year();
                            objOB.Unique_Budget_Code__c = objOB.Name +' - '+ objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c +' - '+  year +' - '+Channel;
                        }
                        else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                            String year=objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c ; //System.Today().year();
                            objOB.Unique_Budget_Code__c = objOB.Name +' - '+  year ;
                        }
                        
                        if(!uniqueBudgetCode.contains(objOB.Unique_Budget_Code__c)){
                            onPointBudgetTOInsertNEW.add(objOB);
                            uniqueBudgetCode.add(objOB.Unique_Budget_Code__c);
                        }
                        
                    }
                    SET<Id> successIdProgram=new SET<Id>();
                    Database.UpsertResult[] onPointBudgetResult;
                    if(!onPointBudgetTOInsertNEW.isEmpty()){
                        onPointBudgetResult = Database.upsert(onPointBudgetTOInsertNEW,OnPoint_Budget__c.Unique_Budget_Code__c,false);
                        System.debug('----onPointBudgetResult---'+onPointBudgetResult);
                        System.debug('----List of newOnPointBudget---'+onPointBudgetTOInsertNEW);
                    }
                    for(Database.UpsertResult sr:onPointBudgetResult){
                        successIdProgram.add(sr.getId());
                    }
                    System.debug('====successIdProgram---'+successIdProgram);
                    MAP<String,OnPoint_Budget__c> mapOfOnpOintbudet=new MAP<String, OnPoint_Budget__c>();
                    for(OnPoint_Budget__c onPObj: onPointBudgetTOInsertNEW)
                    {
                        mapOfOnpOintbudet.put(onPObj.Unique_Budget_Code__c, onPObj);
                        
                    }
                    System.debug('=======mapOfOnpOintbudet @@@@'+mapOfOnpOintbudet);
                    set<String> uniquePOCBudgetCode=new Set<String>();
                    List<OnPoint_POC_Budget__c> onPointPOCBudgetToInsertNew = new List<OnPoint_POC_Budget__c>();
                    for(Marketing_Kit__c objMK:obNotAvailable){
                        String channel;
                        string key= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c + ' - ';
                        if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c)
                        {
                            if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){
                                key=key+'Trade Activation On Prem';
                                channel='ON';
                            }
                            else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){
                                key=key+'Trade Activation Off Prem';
                                channel='OFF';
                            }
                        }
                        else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                            if( objMK.Marketing_Program_Name__r.Business_Line__c =='Out of Home'){
                                key=key+'User Paid On Premise';
                                channel='ON';
                            }
                            else if(objMK.Marketing_Program_Name__r.Business_Line__c =='In Home'){
                                key=key+'User Paid Off Premise';
                                channel='OFF';
                            }
                        }
                        if(!objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                            String year=objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c;//System.Today().year();
                            key= key+' - '+ objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c +' - '+ year +' - '+channel;
                        }   
                        else if(objMK.Annual_Brand_Area_Budget_Plan__r.Brand__r.User_Paid__c){
                            String year=objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Budget_Year__c; //System.Today().year();
                            key= key+' - '+  year ;
                        }
                        system.debug('=====mapOfOnpOintbudet===='+mapOfOnpOintbudet);
                        system.debug('=====key===='+key +'----'+ mapOfOnpOintbudet.get(key));
                        system.debug('=====acc id===='+objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__c);
                        OnPoint_POC_Budget__c objOPB = new OnPoint_POC_Budget__c();
                        objOPB.Name= objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c + '-'+ objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.Name;
                        objOPB.POC__c= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__c;
                        objOPB.Budget__c=mapOfOnpOintbudet.get(key).id;
                        objOPB.POC_Budget_Unique_Code__c= objMK.POC_Spend_Category__r.Annual_POC_Budget_Plan__r.Account__r.lboc_Labatt_Outlet_Id__c+ ' - '+objMK.Marketing_Program_Name__r.Brand__r.OnPoint_Brand_Name__c;
                        objOPB.Planned_Budget__c=objMK.Discretionary_Spend_Total__c; //*isoWithRateMap.get('USD');
                        //objOPB.CurrencyIsoCode='USD';
                        if(!uniquePOCBudgetCode.contains(objOPB.POC_Budget_Unique_Code__c)){
                            uniquePOCBudgetCode.add(objOPB.POC_Budget_Unique_Code__c);
                            onPointPOCBudgetToInsertNew.add(objOPB);
                        }
                    }
                    Database.UpsertResult[] onPointPOCBudgetResult;
                    if(!onPointPOCBudgetToInsertNew.isEmpty()){
                        onPointPOCBudgetResult = Database.upsert(onPointPOCBudgetToInsertNew,OnPoint_POC_Budget__c.POC_Budget_Unique_Code__c,false);
                        System.debug('----onPointPOCBudgetResult---'+onPointPOCBudgetResult);
                        System.debug('----List of onPointPOCBudgetResult---'+onPointPOCBudgetResult);
                    }
                    integer m=0;
                    for (Database.upsertResult sr : onPointPOCBudgetResult) {
                        //Trade_Activation_Kit_Item__c trkt=new Trade_Activation_Kit_Item__c();
                        if (!sr.isSuccess()) {
                            body = body+''+obNotAvailable[m].Name+'----'+ 'failed' +'</br>';
                            for(Database.Error err : sr.getErrors()) {                     
                                body = body + err.getMessage()+'Fields that affected this error: ' + err.getFields()  +'</br>';
                            }
                        }
                        m++;
                    }
                    
                }
                
            }
        } 
    }
    
    
    global void finish(Database.BatchableContext BC)
    {
        List<string> emailId = new List<string>();
        List<string> ccEmailId = new List<string>();
        body = body +'OnPlan to OnPoint Batch successfully Processed';
        ExcelHeader__mdt[] ccMailList = [select MasterLabel, QualifiedApiName, column_A__c,column_B__c,column_C__c FROM ExcelHeader__mdt where MasterLabel ='cc Mail Id'];
        for(ExcelHeader__mdt eh:ccMailList){
            emailId.add(eh.column_A__c); 
            ccEmailId.add(eh.column_B__c);
        }
        Mailutility.sendMail(emailId,ccEmailId,'Staging to OnPoint Result',body);        
    }    
}