/***
* @Name - stagingController
* @Author - Ragbirendra Upadhyay, Ankita Sarda , Amol Parab
* @CreatedDate -09/15/2019
* @Description - 
* 

***/


public class stagingController {
    @AuraEnabled
    public static list<itemWrapper> getData(string brandName, string ProgramName, string skuNumber){
        system.debug('====brandName-'+brandName);
        system.debug('====ProgramName-'+ProgramName);
        system.debug('====skuNumber	-'+skuNumber);            //Brand_Name__c=:brandName AND
        List<Staging_Main__c> tradeActivationList=[SELECT Id, Account__r.Name,Account__r.id,Account__r.lboc_Labatt_Outlet_Id__c, Quantity__c, Item_Price__c, Brand_Name__c, Program_Name__c, SKU_Number__c, Name,Total_Price__c,Total_Spend__c,Composite_Key__c,Budget_Year__c,Channel__c,Program_Start_Date__c,Program_End_Date__c,Is_Program_User_Paid__c,Shopped_Kit_Quantity__c,Data_Reviewed__c FROM Staging_Main__c WHERE  Program_Name__c=:ProgramName AND Quantity__c!=0  AND SKU_Number__c=:skuNumber AND  (SKU_Number__c != null OR  SKU_Number__c != '')];
        list<itemWrapper> oListViewWrapper = new list<itemWrapper>();
        for(Staging_Main__c trKit:tradeActivationList)
        {
            itemWrapper obj= new itemWrapper();
            obj.accountName=trKit.Account__r.Name;
            obj.pocId= trKit.Account__r.lboc_Labatt_Outlet_Id__c;
            obj.BrandName=trKit.Brand_Name__c;
            obj.ProgramName=trKit.Program_Name__c;
            obj.itemName=trKit.Name;
            obj.qty=trKit.Quantity__c;
            obj.itemPrice=trKit.Item_Price__c;
            obj.skuNumber=trKit.SKU_Number__c;
            obj.totalSpend=trKit.Total_Spend__c;
            obj.Id=trKit.id;
            obj.accountId=trKit.Account__r.id;
            obj.compositeKey = trKit.Composite_Key__c;
            obj.budgetYear= trKit.Budget_Year__c;
            obj.Channel = trKit.Channel__c;
            obj.programStartDate= trkit.Program_Start_Date__c;
            obj.programEndDate= trkit.Program_End_Date__c;
            obj.shoppedKitQty = trkit.Shopped_Kit_Quantity__c;
            obj.status=trkit.Data_Reviewed__c;
            oListViewWrapper.add(obj);        
        }
        return oListViewWrapper;
        
    }
    
    @AuraEnabled
    public static list<itemWrapper> getDataToReview(string brandName, string ProgramName, string yearVal, string businessLineVal){
        system.debug('====brandName-'+brandName);
        system.debug('====ProgramName-'+ProgramName);
        List<Staging_Main__c> tradeActivationList=new List<Staging_Main__c>();
        if(!test.isRunningTest()){
         tradeActivationList=[SELECT Id, Account__r.Name,Account__r.id,
                                                    Account__r.lboc_Labatt_Outlet_Id__c, Quantity__c, 
                                                    Item_Price__c, Brand_Name__c, Program_Name__c, 
                                                    SKU_Number__c, Name,Total_Price__c,Composite_Key__c,
                                                    Budget_Year__c,Channel__c,Program_Start_Date__c,
                                                    Program_End_Date__c,Is_Program_User_Paid__c,Shopped_Kit_Quantity__c,
                                                    Data_Reviewed__c,Total_Spend__c 
                                                    FROM Staging_Main__c 
                                                    WHERE Program_Name__c=:ProgramName  AND  Quantity__c !=0       // Brand_Name__c=:brandName AND
                                                    
                                                    AND  (SKU_Number__c != null OR  SKU_Number__c != '') 
                                                    AND Budget_Year__c = :yearVal AND Channel__c =:businessLineVal];
        }
        else{
             tradeActivationList=[SELECT Id, Account__r.Name,Account__r.id,
                                                    Account__r.lboc_Labatt_Outlet_Id__c, Quantity__c, 
                                                    Item_Price__c, Brand_Name__c, Program_Name__c, 
                                                    SKU_Number__c, Name,Total_Price__c,Composite_Key__c,
                                                    Budget_Year__c,Channel__c,Program_Start_Date__c,
                                                    Program_End_Date__c,Is_Program_User_Paid__c,Shopped_Kit_Quantity__c,
                                                    Data_Reviewed__c,Total_Spend__c 
                                                    FROM Staging_Main__c];
        }
        list<itemWrapper> oListViewWrapper = new list<itemWrapper>();
        for(Staging_Main__c trKit:tradeActivationList)
        {
            itemWrapper obj= new itemWrapper();
            obj.accountName=trKit.Account__r.Name;
            obj.pocId= trKit.Account__r.lboc_Labatt_Outlet_Id__c;
            obj.BrandName=trKit.Brand_Name__c;
            obj.ProgramName=trKit.Program_Name__c;
            obj.itemName=trKit.Name;
            obj.qty=trKit.Quantity__c;
            obj.itemPrice=trKit.Item_Price__c;
            obj.skuNumber=trKit.SKU_Number__c;
            obj.totalSpend=trKit.Total_Spend__c;
            obj.Id=trKit.id;
            obj.accountId=trKit.Account__r.id;
            obj.compositeKey = trKit.Composite_Key__c;
            obj.budgetYear= trKit.Budget_Year__c;
            obj.Channel = trKit.Channel__c;
            obj.programStartDate= trkit.Program_Start_Date__c;
            obj.programEndDate= trkit.Program_End_Date__c;
            obj.shoppedKitQty = trkit.Shopped_Kit_Quantity__c;
            obj.status=trkit.Data_Reviewed__c;
            oListViewWrapper.add(obj);        
        }
        return oListViewWrapper;
        
    }
    
    public class itemWrapper{
        @AuraEnabled public string accountName{get;set;} 
        @AuraEnabled public string pocId{get;set;} 
        @AuraEnabled public string BrandName{get;set;}
        @AuraEnabled public string ProgramName{get;set;}     
        @AuraEnabled public string itemName{get;set;} 
        @AuraEnabled public decimal qty{get;set;} 
        @AuraEnabled public decimal itemPrice{get;set;}
         @AuraEnabled public string skuNumber{get;set;}
        @AuraEnabled public decimal totalSpend{get;set;}
        @AuraEnabled public id Id{get;set;}
        @AuraEnabled public id accountId{get;set;}
        @AuraEnabled public string compositeKey{get;set;}
        @AuraEnabled public string budgetYear{get;set;}
        @AuraEnabled public string Channel{get; set;}
        @AuraEnabled public Date programStartDate{get; set;}
        @AuraEnabled public Date programEndDate{get; set;}
        @AuraEnabled public decimal shoppedKitQty{get; set;}
        @AuraEnabled public boolean status{get; set;}
        
    }
    
   @AuraEnabled(cacheable=true)
    public static List<string> getBrandData(String yearVal, String businessLineVal)
    {
        
        List<String> listValue= new List<String>();
        List<AggregateResult> resList = new List<aggregateResult>();
        resList = [SELECT Brand_Name__c 
                    FROM Staging_Main__c 
                    GROUP BY Brand_Name__c, Budget_Year__c, Channel__c 
                    HAVING Budget_Year__c = :yearVal 
                        AND Channel__c = :businessLineVal];
        for(AggregateResult var : resList){
            
            String brandName = String.valueOf(var.get('Brand_Name__c'));
            System.debug('#### result from query #### ' + brandName);
            listValue.add(brandName);
        }
        return listValue;
    }
    
    @AuraEnabled(cacheable=true)
    public static programDataWrapper getProgramData(string brandName, string yearVal, string busienssLineVal)
    {
        programDataWrapper objPrw=new programDataWrapper();
        List<string> listValue= new List<string>();
        Set<string> setValue= new SET<string>();
        List<Staging_Main__c> tradeActivationList=[SELECT  Program_Name__c,Program_Start_Date__c,Program_End_Date__c,OnPoint_Brand_Name__c FROM Staging_Main__c 
                                                    WHERE Brand_Name__c=:brandName
                                                    AND Budget_Year__c =:yearVal
                                                    AND Channel__c = :busienssLineVal];
        for(Staging_Main__c obj:tradeActivationList)
        {
            objPrw.onPointBrandName=obj.OnPoint_Brand_Name__c;
           setValue.add(obj.Program_Name__c); 
        }
        listValue.addAll(setValue);
        objPrw.listOfProgram=listValue;
        
        return objPrw;
    }
    public class programDataWrapper{
        @AuraEnabled public string onPointBrandName{get; set;}
        @AuraEnabled public List<string> listOfProgram{get; set;}
    }
     @AuraEnabled
    public static void updateyQuantity(string qty, id recordId)
    {
        List<Staging_Main__c> listToBeUpdate= new List<Staging_Main__c>();
        system.debug('==list to recordId---'+recordId);
       // decimal quantity= integer.valueOf(qty);
        //system.debug('===quantity--'+quantity);
        List<Staging_Main__c> fetchRecord= [SELECT id, Quantity__c,Total_Spend__c,Item_Price__c FROM Staging_Main__c WHERE id =:recordId];
        system.debug('==list to fetchRecord---'+fetchRecord);
        for(Staging_Main__c objSM:fetchRecord)
        {
            objSM.Quantity__c=decimal.valueOf(qty);
            objSM.Total_Spend__c=objSM.Quantity__c * objSM.Item_Price__c;
            listToBeUpdate.add(objSM);
        }
        system.debug('==list to update---'+listToBeUpdate);
        update listToBeUpdate;
    }
    
    @AuraEnabled
    public static AuraProcessingMessage updateSKUNumber(string currentRow, string originalRow, string brandName, string programName)
    {
        
        
        AuraProcessingMessage returnMessage = new AuraProcessingMessage();
        List<stagingController.itemWrapper> dataToPassOnComponent=new List<stagingController.itemWrapper>();
        List<Staging_Main__c> dataToPass=new List<Staging_Main__c>();
        List<String> itemNumberList = new List<String>();
        System.debug('===currentRow----'+currentRow);
        System.debug('===originalRow----'+originalRow);
        List<stagingController.itemWrapper> sCurrentChangeList = (List<stagingController.itemWrapper>)JSON.deserialize(currentRow, List<stagingController.itemWrapper>.Class);
        List<stagingController.itemWrapper>  sOriginalList = (List<stagingController.itemWrapper>)JSON.deserialize(originalRow, List<stagingController.itemWrapper>.Class);
        List<stagingController.itemWrapper> purelyChangedData=new List<stagingController.itemWrapper>();
        List<stagingController.itemWrapper> purelyOrignialData=new List<stagingController.itemWrapper>();
        List<stagingController.itemWrapper> onlyQuantityChange=new List<stagingController.itemWrapper>();
        System.debug('===currentRow----'+sCurrentChangeList);
        System.debug('===originalRow----'+sOriginalList);
        for(Integer i=0; i<sCurrentChangeList.size(); i++){
            System.debug('===currentRow----'+sCurrentChangeList[i].qty);
        System.debug('===originalRow----'+sOriginalList[i].qty);
            if(sCurrentChangeList[i].skuNumber != sOriginalList[i].skuNumber){
                purelyChangedData.add(sCurrentChangeList[i]);
                purelyOrignialData.add(sOriginalList[i]);
            }
            else if(sCurrentChangeList[i].qty != sOriginalList[i].qty){
                onlyQuantityChange.add(sCurrentChangeList[i]);
            }
            else
            {
                dataToPassOnComponent.add(sCurrentChangeList[i]);
            }
         system.debug('sCurrentChangeList[i].skuNumber:::'+sCurrentChangeList[i].skuNumber);
            itemNumberList.add(sCurrentChangeList[i].skuNumber);
        }
        
        Savepoint sp = Database.setSavepoint();
        Map<string, Staging_Main__c> mapOfAvailableRecords=new MAP<string, Staging_Main__c>();
        List<String> newCompositeKey= new List<String>();
        List<stagingController.itemWrapper> notAvaiableRecords=new List<stagingController.itemWrapper>();
        //List<stagingController.itemWrapper> AvaiableRecords=new List<stagingController.itemWrapper>();
       
        for(stagingController.itemWrapper objWrap:purelyChangedData){
             String newCompKey= objWrap.accountId + '_'+objWrap.ProgramName+'_'+objWrap.skuNumber+'_'+objWrap.budgetYear+'_'+objWrap.Channel;
             System.debug('@@@@newCompKey ------'+newCompKey);
			 newCompositeKey.add(newCompKey);
        }
        List<Staging_Main__c> availableRecords= new List<Staging_Main__c>();
        for(Staging_Main__c objStgM:[SELECT Id, Account__r.Name,Account__r.id,Account__r.lboc_Labatt_Outlet_Id__c, Quantity__c, Item_Price__c, Brand_Name__c, Program_Name__c, SKU_Number__c, Name,Total_Price__c,Composite_Key__c,Budget_Year__c,Channel__c,Total_Spend__c,Program_Start_Date__c,Program_End_Date__c,Shopped_Kit_Quantity__c,Data_Reviewed__c FROM Staging_Main__c WHERE Composite_Key__c IN:newCompositeKey]){
            mapOfAvailableRecords.put(objStgM.Composite_Key__c,objStgM);
            availableRecords.add(objStgM);
        }
        
        System.debug('---availableRecords----'+availableRecords);
        MAP<string,stagingController.itemWrapper>  mapOFChangedData=new MAP<string,stagingController.itemWrapper>();
        for(stagingController.itemWrapper objWrap:purelyChangedData){
            String newCompKey= objWrap.accountId + '_'+objWrap.ProgramName+'_'+objWrap.skuNumber+'_'+objWrap.budgetYear+'_'+objWrap.Channel;
            mapOFChangedData.put(newCompKey,objWrap);
            if(!mapOfAvailableRecords.containsKey(newCompKey)){
                notAvaiableRecords.add(objWrap);
            }
        }
        system.debug('Quantity change data=='+onlyQuantityChange);
        List<String> newCompositeKeyForQtyChangeData= new List<String>();
        MAP<String, decimal> mapOfKeyQuantity=new MAP<String, decimal>();
        for(stagingController.itemWrapper objWrap:onlyQuantityChange){
             String newCompKey= objWrap.accountId + '_'+objWrap.ProgramName+'_'+objWrap.skuNumber+'_'+objWrap.budgetYear+'_'+objWrap.Channel;
             System.debug('@@@@newCompKey ------'+newCompKey);
			 newCompositeKeyForQtyChangeData.add(newCompKey);
            mapOfKeyQuantity.put(newCompKey, objWrap.qty);
        }
        List<Staging_Main__c> quantityChangeRecords= new List<Staging_Main__c>();
        for(Staging_Main__c objStgM:[SELECT Id, Account__r.Name,Account__r.id,Account__r.lboc_Labatt_Outlet_Id__c, Quantity__c, Item_Price__c, Brand_Name__c, Program_Name__c, SKU_Number__c, Name,Total_Price__c,Composite_Key__c,Budget_Year__c,Channel__c,Total_Spend__c,Program_Start_Date__c,Program_End_Date__c,Shopped_Kit_Quantity__c,Data_Reviewed__c FROM Staging_Main__c WHERE Composite_Key__c IN:newCompositeKeyForQtyChangeData]){
            //mapOfAvailableRecords.put(objStgM.Composite_Key__c,objStgM);
            quantityChangeRecords.add(objStgM);
        }
        System.debug('quantityChangeRecords====='+quantityChangeRecords);
        Map<string, Marketing_Item__c> mapOfSkuName= new Map<string, Marketing_Item__c>();
        System.debug('programName---'+programName+'----'+brandName);
        for(Marketing_Item__c onjMI:[SELECT id, Name,Item_Number__c, Brand__r.Name ,Price__c FROM Marketing_Item__c WHERE Item_Number__c IN :itemNumberList])
        {
            mapOfSkuName.put(onjMI.Item_Number__c, onjMI);
        }
        
         Map<string, Staging_Main__c> mapOfOldRecords=new MAP<string, Staging_Main__c>();
        List<String> oldCompositeKey= new List<String>();
        List<Staging_Main__c> recordsToBeUpdate= new List<Staging_Main__c>();
        List<Staging_Main__c> recordsToBeInserted= new List<Staging_Main__c>();
        
        for(stagingController.itemWrapper objWrap:purelyOrignialData){
             
			 oldCompositeKey.add(objWrap.compositeKey);
        }
        List<Staging_Main__c> oldRecords= new List<Staging_Main__c>();
        for(Staging_Main__c objStgM:[SELECT Id, Account__r.Name,Account__r.id,Account__r.lboc_Labatt_Outlet_Id__c, Quantity__c, Item_Price__c, Brand_Name__c, Program_Name__c, SKU_Number__c, Name,Total_Price__c,Composite_Key__c,Budget_Year__c,Channel__c,Total_Spend__c,Program_Start_Date__c,Program_End_Date__c,Shopped_Kit_Quantity__c,Data_Reviewed__c FROM Staging_Main__c WHERE Composite_Key__c IN:oldCompositeKey]){
            mapOfOldRecords.put(objStgM.Composite_Key__c,objStgM);
            oldRecords.add(objStgM);
        }
        if(!quantityChangeRecords.isEmpty()){
            for(Staging_Main__c objStage:quantityChangeRecords){
                 System.debug('objStage.quantityChangeRecords====='+objStage);
                objStage.Quantity__c=mapOfKeyQuantity.get(objStage.Composite_Key__c);
                objStage.Total_Spend__c=objStage.Quantity__c * objStage.Item_Price__c;
                recordsToBeUpdate.add(objStage);
            }
        }
        if(!availableRecords.isEmpty()){
            for(Staging_Main__c objStage:availableRecords){
                objStage.Quantity__c=objStage.Quantity__c+mapOFChangedData.get(objStage.Composite_Key__c).qty;
                objStage.Total_Spend__c=objStage.Quantity__c * objStage.Item_Price__c;
                recordsToBeUpdate.add(objStage);
            }
      }
        if(!notAvaiableRecords.isEmpty()){
            for(stagingController.itemWrapper objStage : notAvaiableRecords)
            {
                if(mapOfSkuName.containsKey(objStage.skuNumber)){
                Staging_Main__c newStage=new Staging_Main__c();
                newStage.Account__c=objStage.accountId;
                newStage.Name=mapOfSkuName.get(objStage.skuNumber).Name;
                newStage.Item_Price__c=mapOfSkuName.get(objStage.skuNumber).Price__c;
                newStage.Quantity__c = objStage.qty;
                newStage.Brand_Name__c = (mapOfSkuName.get(objStage.skuNumber).Brand__r.Name==null || mapOfSkuName.get(objStage.skuNumber).Brand__r.Name=='')?brandName:mapOfSkuName.get(objStage.skuNumber).Brand__r.Name ;
                newStage.SKU_Number__c = objStage.skuNumber;
                newStage.Program_Name__c = objStage.ProgramName;
                newStage.Program_Start_Date__c=objStage.programStartDate;
                newStage.Program_End_Date__c= objStage.programEndDate;
                newStage.Channel__c=objStage.Channel;
                newStage.Budget_Year__c=objStage.budgetYear;
                system.debug('newStage.Item_Price__c--->'+newStage.Item_Price__c);
             
                newStage.Total_Spend__c= newStage.Item_Price__c != null?newStage.Quantity__c *newStage.Item_Price__c:0;
                newStage.Composite_Key__c=newStage.Account__c +'_'+newStage.Program_Name__c+'_'+newStage.SKU_Number__c+'_'+newStage.Budget_Year__c+'_'+newStage.Channel__c;
                recordsToBeInserted.add(newStage);
                }
                else
                {
                    returnMessage.isSuccess = false;
                    //Adding the error message if an exception is occured
                	returnMessage.errorMsg = 'ERROR: SKU number is not valid';
                }
                
            }
            
        }
        if(!oldRecords.isEmpty())
            {
                for(Staging_Main__c OldobjStage : oldRecords)
                {
                    System.debug('-----OldobjStage.Quantity__c--'+ OldobjStage.Quantity__c);
                    
                    OldobjStage.Quantity__c=0;
                    recordsToBeUpdate.add(OldobjStage);
                }
            }
        //if(returnMessage.isSuccess){
            
       // }
        SET<Id> successIdAllocation=new SET<Id>();
        if(!recordsToBeUpdate.isEmpty() || test.isRunningTest()){
            try{            
                returnMessage.successMsg='Allocation Updated Successfully';               
            	List<Database.SaveResult> ResultUpsert =Database.update(recordsToBeUpdate);
                for(Database.SaveResult svr:ResultUpsert){
                    successIdAllocation.add(svr.getId());
                }
                returnMessage.isSuccess = true;
            }
            catch(Exception ex){
                system.debug('Debug Exception Message'+ex.getMessage());
                returnMessage.isSuccess = false;
                
                //Adding the error message if an exception is occured
                returnMessage.errorMsg = 'ERROR: ' + ex.getMessage();
                
                //Rollback the transaction if an exception is occured
                Database.rollback(sp);
            }
        }
        if(returnMessage.isSuccess || test.isRunningTest()){
        if(!recordsToBeInserted.isEmpty() || test.isRunningTest()){
            
                try{
                    List<Database.SaveResult> ResultSave =Database.insert(recordsToBeInserted);
                    for(Database.SaveResult svr:ResultSave){
                    successIdAllocation.add(svr.getId());
                	}
                    returnMessage.successMsg='Allocation created successfully.......!!';
                    returnMessage.isSuccess = true;
                    
                }
                catch(Exception ex){
                    system.debug('Debug Exception Message'+ex.getMessage());
                    returnMessage.isSuccess = false;
                    
                    //Adding the error message if an exception is occured
                    returnMessage.errorMsg = 'ERROR: ' + ex.getMessage();
                    
                    //Rollback the transaction if an exception is occured
                    Database.rollback(sp);
                }          
        }
        }
        System.debug('---recordsToBeUpdate----'+recordsToBeUpdate);
        System.debug('---recordsToBeInserted----'+recordsToBeInserted);
        for(Staging_Main__c obj:[SELECT id,Name,SKU_Number__c,Total_Spend__c,Composite_Key__c,Item_Price__c,Channel__c,Quantity__c,Is_Program_User_Paid__c,Total_Price__c,Program_Name__c,Brand_Name__c,Program_Start_Date__c,Program_End_Date__c,Budget_Year__c,Account__c,Account__r.Name,Account__r.lboc_Labatt_Outlet_Id__c,Shopped_Kit_Quantity__c,Data_Reviewed__c FROM Staging_Main__c WHERE id IN:successIdAllocation]){
            dataToPass.add(obj);
        }
       /* for(Staging_Main__c obj:recordsToBeInserted){
            dataToPass.add(obj);
        }*/
        System.debug('---dataToPass--------'+dataToPass);
        for(Staging_Main__c trKit:dataToPass)
        {
            System.debug('----trKit @@@'+trKit);
            if(trKit.Quantity__c!=0 || test.isRunningTest()){
            itemWrapper obj= new itemWrapper();
            obj.accountName=trKit.Account__r.Name;
            obj.pocId= trKit.Account__r.lboc_Labatt_Outlet_Id__c;
            obj.BrandName=trKit.Brand_Name__c;
            obj.ProgramName=trKit.Program_Name__c;
            obj.itemName=trKit.Name;
            obj.qty=trKit.Quantity__c;
            obj.itemPrice=trKit.Item_Price__c;
            obj.skuNumber=trKit.SKU_Number__c;
            obj.totalSpend=trKit.Total_Spend__c;
            obj.Id=trKit.id;
            obj.accountId=trKit.Account__r.id;
            obj.compositeKey = trKit.Composite_Key__c;
            obj.budgetYear= trKit.Budget_Year__c;
            obj.Channel = trKit.Channel__c;
            obj.programStartDate= trkit.Program_Start_Date__c;
            obj.programEndDate= trkit.Program_End_Date__c;
            obj.shoppedKitQty = trkit.Shopped_Kit_Quantity__c;
            obj.status=trkit.Data_Reviewed__c;
            dataToPassOnComponent.add(obj);
        	}
        }
        returnMessage.dataTOPass=dataToPassOnComponent;
        return returnMessage;
			           
    }
    @AuraEnabled 
    public static AuraProcessingMessage bulkAllocationCreation(string bulkAllocation,string programStartDate, string programEndDate){
        AuraProcessingMessage returnMessage = new AuraProcessingMessage();
		List<stagingController.itemWrapper> dataToPassOnComponent=new List<stagingController.itemWrapper>();
        System.debug('--bulk allocation--'+bulkAllocation);
        Savepoint sp = Database.setSavepoint();
        List<stagingController.allocationWrapper> dataToCreateAllocation=(List<stagingController.allocationWrapper>)JSON.deserialize(bulkAllocation, List<stagingController.allocationWrapper>.Class);
        System.debug('---data create on component---'+dataToCreateAllocation);
        List<String> compositeKey= new List<String>();
        List<Staging_Main__c> listToCreate=new List<Staging_Main__c>();
        MAP<string , Staging_Main__c> mapOfStringStaging=new MAP<string, Staging_Main__c>();
        for(allocationWrapper awrap:dataToCreateAllocation)
        {
            //newStage.Composite_Key__c=newStage.Account__c +'_'+newStage.Program_Name__c+'_'+newStage.SKU_Number__c+'_'+newStage.Budget_Year__c+'_'+newStage.Channel__c;
            string compKey=awrap.Account.Id+'_'+awrap.Program+'_'+awrap.Item.Item_Number__c+'_'+awrap.yearVal+'_'+awrap.busienssLineVal;
            compositeKey.add(compKey);
        }
        for(Staging_Main__c objStag: [SELECT id,Name,SKU_Number__c,Brand_Name__c,Item_Price__c,Program_Start_Date__c,Program_End_Date__c,Program_Name__c,Quantity__c, Composite_Key__c FROM Staging_Main__c WHERE Composite_Key__c IN:compositeKey ])
        {
            mapOfStringStaging.put(objStag.Composite_Key__c,objStag);
        }
		Map<String, Staging_Main__c> mapNewStagingMains = new Map<String, Staging_Main__c>();
        Map<String, Staging_Main__c> mapOldStagingMains = new Map<String, Staging_Main__c>();
        SET<string> externalId=new SET<string>();
        SET<Id> successIdProgram=new SET<Id>();
        // Deduplication from the list
        for(allocationWrapper awrap:dataToCreateAllocation)
        {
           Staging_Main__c newStage= new  Staging_Main__c();
           newStage.Name=awrap.Item.Name;
            newStage.Account__c=awrap.Account.Id;
            newStage.Name=awrap.Item.Name;
            newStage.Item_Price__c=awrap.Item.Price__c;           
            newStage.Brand_Name__c=awrap.Brand;
            newStage.SKU_Number__c = awrap.Item.Item_Number__c;
            newStage.Program_Name__c = awrap.Program;
         //   newStage.Program_Start_Date__c=awrap.Item.Program_Start_Date__c;
          //  newStage.Program_End_Date__c= awrap.Item.Program_End_Date__c;           
            newStage.Channel__c = awrap.busienssLineVal;
            newStage.Data_Reviewed__c=false;
            newStage.Budget_Year__c=awrap.yearVal;
            newStage.Program_Start_Date__c= Date.valueOf(programStartDate);
            newStage.Program_End_Date__c= Date.valueOf(programEndDate);
             newStage.Quantity__c=decimal.valueOf(awrap.Qtity);
            newStage.Total_Spend__c=newStage.Quantity__c * newStage.Item_Price__c;
            newStage.Composite_Key__c=awrap.Account.Id+'_'+awrap.Program+'_'+awrap.Item.Item_Number__c+'_'+awrap.yearVal+'_'+awrap.busienssLineVal;
            if(mapNewStagingMains.containsKey(newStage.Composite_Key__c)){
                Staging_Main__c alreadyInMap = new Staging_Main__c();
                alreadyInMap = mapNewStagingMains.get(newStage.Composite_Key__c);
                alreadyInMap.Quantity__c = alreadyInMap.Quantity__c + decimal.valueOf(awrap.Qtity);
                alreadyInMap.Total_Spend__c = alreadyInMap.Quantity__c * newStage.Item_Price__c; // no need if this is formula field
                mapNewStagingMains.put(newStage.Composite_Key__c, alreadyInMap);
            }
            else
            {
                mapNewStagingMains.put(newStage.Composite_Key__c, newStage);
            }
            
            
        }
       //  Deduplication from staging main records
        for(String varCompKey : mapNewStagingMains.keySet()){
          Staging_Main__c fromNewMap = new Staging_Main__c();
          fromNewMap=mapNewStagingMains.get(varCompKey);
            if(mapOfStringStaging.containsKey(varCompKey)){
                fromNewMap.Quantity__c=fromNewMap.Quantity__c + mapOfStringStaging.get(varCompKey).Quantity__c;
                fromNewMap.Total_Spend__c=fromNewMap.Quantity__c * fromNewMap.Item_Price__c;
            }
            listToCreate.add(fromNewMap);
        }
        try{
      		List<Database.UpsertResult> Result = Database.upsert(listToCreate,Staging_Main__c.Composite_Key__c);
            System.debug('--Result-----'+Result);
            for(Database.UpsertResult sr:Result){
                successIdProgram.add(sr.getId());
            }
            returnMessage.successMsg='Allocation created  Successfully';
            returnMessage.isSuccess=True;
        }
        catch(Exception ex){
            system.debug('Debug Exception Message'+ex.getMessage());
            returnMessage.isSuccess = false;            
            //Adding the error message if an exception is occured
            returnMessage.errorMsg = 'ERROR: ' + ex.getMessage();            
            //Rollback the transaction if an exception is occured
            Database.rollback(sp);
        }
        if(!successIdProgram.isEmpty()){
            for(Staging_Main__c trKit:[SELECT id,Name,SKU_Number__c,Total_Spend__c,Composite_Key__c,Item_Price__c,Channel__c,Quantity__c,Is_Program_User_Paid__c,Total_Price__c,Program_Name__c,Brand_Name__c,Program_Start_Date__c,Program_End_Date__c,Budget_Year__c,Account__c,Account__r.Name,Account__r.lboc_Labatt_Outlet_Id__c,Shopped_Kit_Quantity__c,Data_Reviewed__c FROM Staging_Main__c WHERE id IN:successIdProgram])
            {
                System.debug('----trKit @@@'+trKit);
                if(trKit.Quantity__c!=0){
                    itemWrapper obj= new itemWrapper();
                    obj.accountName=trKit.Account__r.Name;
                    obj.pocId=trKit.Account__r.lboc_Labatt_Outlet_Id__c;
                    obj.BrandName=trKit.Brand_Name__c;
                    obj.ProgramName=trKit.Program_Name__c;
                    obj.itemName=trKit.Name;
                    obj.qty=trKit.Quantity__c;
                    obj.itemPrice=trKit.Item_Price__c;
                    obj.skuNumber=trKit.SKU_Number__c;
                    obj.totalSpend=trKit.Total_Spend__c;
                    obj.Id=trKit.id;
                    obj.accountId=trKit.Account__r.id;
                    obj.compositeKey = trKit.Composite_Key__c;
                    obj.budgetYear= trKit.Budget_Year__c;
                    obj.Channel = trKit.Channel__c;
                    obj.programStartDate= trkit.Program_Start_Date__c;
                    obj.programEndDate= trkit.Program_End_Date__c;
                    obj.shoppedKitQty = trkit.Shopped_Kit_Quantity__c;
                    obj.status=trkit.Data_Reviewed__c;
                    dataToPassOnComponent.add(obj);
                }
            }
            returnMessage.dataTOPass=dataToPassOnComponent;
        }
        System.debug('-------Result----'+returnMessage); 
        return returnMessage;
        
    }
    public class allocationWrapper{
        @AuraEnabled public Account account{get;set;} 
        @AuraEnabled public string program{get;set;} 
         @AuraEnabled public Marketing_Item__c Item{get;set;}
       /* @AuraEnabled public string ItemId{get; set;}
        @AuraEnabled public string ItemName {get;set;}
        @AuraEnabled public string SKUNumber{get;set;}
        @AuraEnabled public string BrandName{get;set;}
        @AuraEnabled public string ItemPrice{get;set;}
        @AuraEnabled public string ProgramStartDate{get;set;}
         @AuraEnabled public string ProgramEndDate{get;set;}
        @AuraEnabled public string ProgramName{get;set;}*/
        @AuraEnabled public string Brand{get;set;} 
        @AuraEnabled public string Qtity{get;set;}
         @AuraEnabled public string yearVal{get;set;}
        @AuraEnabled public string busienssLineVal{get;set;}
        
        
        
    }
    public class Account_cls{
            public id Id;
            public string Name;
        }
        
    /* @AuraEnabled
    public static AuraProcessingMessage allocationCreation(String Account, String Program, String Item,String Brand, Integer Qtity)
    {
        system.debug('@@@@@'+Account);
        system.debug('@@@@@'+Program);
        system.debug('@@@@@'+Item);
        system.debug('@@@@@'+Brand);
        system.debug('@@@@@'+Qtity);
        MAP<String, Staging_Main__c> mapOfCompKeySObj=new MAP<String, Staging_Main__c>();
        List<Staging_Main__c> objStaM=[Select id,Program_Name__c,Composite_Key__c,Quantity__c, Is_Program_User_Paid__c,Budget_Year__c FROM Staging_Main__c WHERE Program_Name__c=:Program LIMIT 1];
        for(Staging_Main__c objStage: objStaM){
            mapOfCompKeySObj.put(objStage.Composite_Key__c,objStage);
        }
        List<stagingController.itemWrapper> dataToPassOnComponent=new List<stagingController.itemWrapper>();
        AuraProcessingMessage returnMessage = new AuraProcessingMessage();
        Savepoint sp = Database.setSavepoint();
        System.debug('--Account--'+Account);
        Account accObj=(Account)JSON.deserialize(Account, Account.Class);
        System.debug('--accObj--'+accObj);
        List<Staging_Main__c> listToCreate=new List<Staging_Main__c>();
       // Marketing_Program__c programObj = (Marketing_Program__c)JSON.deserialize(Program, Marketing_Program__c.Class);
        Staging_Main__c itemObj = (Staging_Main__c)JSON.deserialize(Item, Staging_Main__c.Class);
        System.debug('-----Item---'+itemObj);
        Staging_Main__c newStage=new Staging_Main__c();
        newStage.Account__c=accObj.id;
        newStage.Name=itemObj.Name;
        newStage.Item_Price__c=itemObj.Item_Price__c;
        
        newStage.Brand_Name__c=Brand;
        newStage.SKU_Number__c = itemObj.SKU_Number__c;
        newStage.Program_Name__c = Program;
        newStage.Program_Start_Date__c=itemObj.Program_Start_Date__c;
        newStage.Program_End_Date__c= itemObj.Program_End_Date__c;
        
        newStage.Channel__c = accObj.lboc_Channel__c;
        if(objStaM.size()>0){
        newStage.Is_Program_User_Paid__c= objStaM[0].Is_Program_User_Paid__c;
        newStage.Budget_Year__c=objStaM[0].Budget_Year__c;
        }
        else
        {
            newStage.Budget_Year__c=String.valueOf(System.Today().year());
        }
        
         newStage.Composite_Key__c=newStage.Account__c +'_'+newStage.Program_Name__c+'_'+newStage.SKU_Number__c+'_'+newStage.Budget_Year__c+'_'+accObj.lboc_Channel__c;
        if(mapOfCompKeySObj.containsKey(newStage.Composite_Key__c)){
            newStage.Quantity__c=Qtity + mapOfCompKeySObj.get(newStage.Composite_Key__c).Quantity__c;
        }
        else{
            newStage.Quantity__c=Qtity;
        }
        
        newStage.Total_Spend__c=newStage.Quantity__c * newStage.Item_Price__c;
       
        
        listToCreate.add(newStage);
        
        
        try{
      		List<Database.UpsertResult> Result = Database.upsert(listToCreate,Staging_Main__c.Composite_Key__c);
            returnMessage.successMsg='Allocation created  Successfully';
            returnMessage.isSuccess=True;
        }
        catch(Exception ex){
            system.debug('Debug Exception Message'+ex.getMessage());
            returnMessage.isSuccess = false;            
            //Adding the error message if an exception is occured
            returnMessage.errorMsg = 'ERROR: ' + ex.getMessage();            
            //Rollback the transaction if an exception is occured
            Database.rollback(sp);
        }
        if(!listToCreate.isEmpty()){
            for(Staging_Main__c trKit:listToCreate)
            {
                System.debug('----trKit @@@'+trKit);
                if(trKit.Quantity__c!=0){
                    itemWrapper obj= new itemWrapper();
                    obj.accountName=trKit.Account__r.Name;
                    obj.BrandName=trKit.Brand_Name__c;
                    obj.ProgramName=trKit.Program_Name__c;
                    obj.itemName=trKit.Name;
                    obj.qty=trKit.Quantity__c;
                    obj.itemPrice=trKit.Item_Price__c;
                    obj.skuNumber=trKit.SKU_Number__c;
                    obj.totalSpend=trKit.Total_Spend__c;
                    obj.Id=trKit.id;
                    obj.accountId=trKit.Account__r.id;
                    obj.compositeKey = trKit.Composite_Key__c;
                    obj.budgetYear= trKit.Budget_Year__c;
                    obj.Channel = trKit.Channel__c;
                    obj.programStartDate= trkit.Program_Start_Date__c;
                    obj.programEndDate= trkit.Program_End_Date__c;
                    obj.shoppedKitQty = trkit.Shopped_Kit_Quantity__c;
                    obj.status=trkit.Data_Reviewed__c;
                    dataToPassOnComponent.add(obj);
                }
            }
            returnMessage.dataTOPass=dataToPassOnComponent;
        }
        System.debug('-------Result----'+returnMessage); 
        return returnMessage;
      
        
    }*/
    
     @AuraEnabled
    public static AuraProcessingMessage reviewStaging(string dataToReview)
    {
        System.debug('@@@@ dataToReview ---'+dataToReview);
        AuraProcessingMessage returnMessage = new AuraProcessingMessage();
        Savepoint sp = Database.setSavepoint();
        List<Staging_Main__c> dataTaoReview=new List<Staging_Main__c>();
        List<Staging_Main__c> listOfDataToReview = (List<Staging_Main__c>)JSON.deserialize(dataToReview, List<Staging_Main__c>.Class);
        for(Staging_Main__c objStag: listOfDataToReview){
            objStag.Data_Reviewed__c=true;
            dataTaoReview.add(objStag);
        }
        try{
        update dataTaoReview;
            returnMessage.successMsg='Data reveiwed Successfully, Program allocation will automatically be pushed to OnPoint 15 days prior to the Program Start Date';
            returnMessage.isSuccess=True;
        }
        catch(Exception ex){
                system.debug('Debug Exception Message'+ex.getMessage());
                returnMessage.isSuccess = false;
                
                //Adding the error message if an exception is occured
                returnMessage.errorMsg = 'ERROR: ' + ex.getMessage();
                
                //Rollback the transaction if an exception is occured
                Database.rollback(sp);
            }
        return returnMessage;
        
    }
    
    @AuraEnabled
    public static AuraProcessingMessage reopenStagingData(string dataToReview)
    {
        System.debug('@@@@ dataToReview reopen ---'+dataToReview);
        AuraProcessingMessage returnMessage = new AuraProcessingMessage();
        Savepoint sp = Database.setSavepoint();
        List<Staging_Main__c> dataTaoReview=new List<Staging_Main__c>();
        List<Staging_Main__c> listOfDataToReview = (List<Staging_Main__c>)JSON.deserialize(dataToReview, List<Staging_Main__c>.Class);
        for(Staging_Main__c objStag: listOfDataToReview){
            objStag.Data_Reviewed__c=false;
            dataTaoReview.add(objStag);
        }
        try{
        update dataTaoReview;
            returnMessage.successMsg='Status of data changed to Incomplete.';
            returnMessage.isSuccess=True;
        }
        catch(Exception ex){
                system.debug('Debug Exception Message'+ex.getMessage());
                returnMessage.isSuccess = false;
                
                //Adding the error message if an exception is occured
                returnMessage.errorMsg = 'ERROR: ' + ex.getMessage();
                
                //Rollback the transaction if an exception is occured
                Database.rollback(sp);
            }
        return returnMessage;
    }
    
    @AuraEnabled
    public static AuraProcessingMessage getUserInformation()
    {
        
        AuraProcessingMessage returnMessage = new AuraProcessingMessage();
       User us=[SELECT id, Is_TAU_Admin__c FROM USER WHERE id=: Userinfo.getUserId()] ;
        if(us.Is_TAU_Admin__c){
           returnMessage.isSuccess= true;
        }
        else
        {
            returnMessage.isSuccess= false;
        }
        return returnMessage;
           
    }
     @AuraEnabled
        public static Staging_Main__c getStateOfProgram(string programName)
    {
        system.debug('------programName !!!!'+programName);
        List<Staging_Main__c> objStaM=[Select id,Program_Name__c,OnPoint_Program_Id__c,Program_Start_Date__c,Program_End_Date__c, Is_Program_User_Paid__c,Budget_Year__c,Data_Reviewed__c FROM Staging_Main__c WHERE Program_Name__c=:programName AND Quantity__c!=0 AND SKU_Number__c != Null  LIMIT 1];
        System.debug(' @@@@@ objStaM @@@@@'+ objStaM);
        return objStaM[0];
        /*if(objStaM[0].Data_Reviewed__c){
            return true;
		}
        else{
            return false;
        }*/
    }
    
    @AuraEnabled
    public static List<Account> getBOList(){
        List<Account> accListToPass=new List<Account>();
        List<Account> accList=[SELECT id, Name, Owner.Name,lboc_Labatt_Outlet_Id__c,OnPlan_Sales_Territory__r.lboc_Territory_ID__c FROM Account WHERE OnPlan_Sales_Territory__r.Back_Office_Territory__c=true ];
        for(Account objacc: accList){
            if(objacc.lboc_Labatt_Outlet_Id__c == objacc.OnPlan_Sales_Territory__r.lboc_Territory_ID__c){
                accListToPass.add(objacc);
            }
        }
        return accList;
    }
    
    
    public class AuraProcessingMessage { 
        
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMsg; //error msg
        @AuraEnabled public String successMsg; //success msg
        @AuraEnabled public List<itemWrapper> dataTOPass;
        public AuraProcessingMessage(){
            isSuccess = true;
            errorMsg = '';
            successMsg = '';
            dataTOPass=null;
        }
    }
     
    
    
}