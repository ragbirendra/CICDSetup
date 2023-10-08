/***
    * @Name				GenericDataStampingApex
    * @Author			Ragbirendra and Ankita
    * @CreatedDate		09-19-2019
    * @Description		Generic Class for taking data from user excel Load file and
    *					Load into Staging Object(POC Planning)
    *
    ***/

public class GenericDataStampingApex {
    
    public class AuraProcessingMessage { 
        
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMsg; //error msg
        @AuraEnabled public String successMsg; //success msg
        
        public AuraProcessingMessage(){
            isSuccess = true;
            errorMsg = '';
            successMsg = '';
            
        }
    }
    
    @AuraEnabled
    public static AuraProcessingMessage createBudgetBOC(string year, string bussinessLine){
        system.debug('------run batch class from aura enabled-----');
        
        Boolean allJobCompleted= true;
        ApexClass apexClass=[SELECT Id, Name FROM ApexClass WHERE Name='BatchForCreationOfBudgetBO'];
        List<AsyncApexJob> asynchJob=[Select Id,ApexClassId, Status, NumberOfErrors, JobItemsProcessed,
                                      TotalJobItems, CreatedBy.Email, ExtendedStatus
                                      from AsyncApexJob WHERE ApexClassId=:apexClass.Id];
        for(AsyncApexJob obj: asynchJob){
            if(obj.Status != 'Completed' && obj.Status != 'Aborted'&& obj.Status != 'Failed'){
                allJobCompleted=false;
            }
        }
        AuraProcessingMessage objMessageToPass =new AuraProcessingMessage();
        if(allJobCompleted){
            BatchForCreationOfBudgetBO objBO=new BatchForCreationOfBudgetBO(year, bussinessLine);
            Database.executeBatch(objBO, 10);
            objMessageToPass.isSuccess=true;
            objMessageToPass.successMsg='Back office budget load process is initiated, once it complete will send mail to Myriam Wilhelmy';
        }
        else{
            objMessageToPass.isSuccess=false;
            objMessageToPass.errorMsg='Back office budget load process is already in progress . So please try after 30 Mintues !!!';
        }
        return objMessageToPass;
    }   
        /***
    * @Method Name	    excelheaderValidation
    * @Author			Ragbirendra Upadhyay
    * @CreatedDate		09-19-2019
    * @Description		Check whether user is uploading correct excel or not,This method return
    *                   excel header value to Lightning component from Custom Meta Datatype
    ***/
    @AuraEnabled
    public static string excelheaderValidation(String uploadType){//Budget,shopkit or item
        ExcelHeader__mdt[] excelHeader;
        string headerString='';
        if(uploadType=='Budget'){
            excelHeader = [SELECT MasterLabel, QualifiedApiName, column_A__c,column_B__c,column_C__c,column_D__c,column_E__c,column_F__c,column_G__c,column_H__c,column_I__c,column_J__c FROM ExcelHeader__mdt where MasterLabel ='Budget Header'];  
            if(excelHeader.size()>0)
                headerString = excelHeader[0].column_A__c+','+excelHeader[0].column_B__c+','+excelHeader[0].column_C__c+','+excelHeader[0].column_D__c+','+excelHeader[0].column_E__c+','+excelHeader[0].column_F__c+','+excelHeader[0].column_G__c+','+excelHeader[0].column_H__c+','+excelHeader[0].column_I__c+','+excelHeader[0].column_J__c;
        }
        if(uploadType=='shoppedKit'){
            
            excelHeader = [SELECT MasterLabel, QualifiedApiName, column_A__c,column_B__c,column_C__c,column_D__c,column_E__c,column_F__c,column_G__c,column_H__c,column_I__c,column_J__c FROM ExcelHeader__mdt where MasterLabel ='shoppedKit Header'];    
            if(excelHeader.size()>0) {
                headerString =  excelHeader[0].column_A__c+','+excelHeader[0].column_B__c+','+excelHeader[0].column_C__c+','+excelHeader[0].column_D__c+','+excelHeader[0].column_E__c+','+excelHeader[0].column_F__c+','+excelHeader[0].column_G__c+','+excelHeader[0].column_H__c+','+excelHeader[0].column_I__c+','+excelHeader[0].column_J__c;
            }else{ throw new AuraHandledException('Header Validation failed');
                 }
        }
        if(uploadType=='Item'){}
        
        return headerString;
    }
        /***
    * @Method Name	    createShopKitRecords
    * @Author			Ragbirendra Upadhyay
    * @CreatedDate		09-19-2019
    * @Description		Take Shopped Kit Record from Lightning Component and create new record
    *                   in Stagging Area 
    ***/
    @AuraEnabled
    public static string createShopKitRecords(String shopkitsave){
        
        List<NAZ_OP_Shopkit_Data__c> shopkitDataList = new List<NAZ_OP_Shopkit_Data__c>();
        List<JSON2Apex> obj = JSON2Apex.parse(shopkitsave);
        List<String> externalKeyList = new List<String>();
        for(JSON2Apex j2a:obj)
        {
            NAZ_OP_Shopkit_Data__c shopkitData = new NAZ_OP_Shopkit_Data__c();
            String shoppedKitNameItem='';
            
            if(j2a.ShopkitSAPNumber=='' || j2a.ShopkitSAPNumber==null)
            {
                shoppedKitNameItem =   j2a.ShoppedKitName+'_'+j2a.ShopkitTemporaryItemNumbers+'_'+j2a.Year+'_'+j2a.BusinessLine;
            }
            else if(j2a.ShopkitTemporaryItemNumbers=='' || j2a.ShopkitTemporaryItemNumbers==null)
            {
                shoppedKitNameItem =   j2a.ShoppedKitName +'_'+j2a.ShopkitSAPNumber+'_'+j2a.Year+'_'+j2a.BusinessLine;  
            }
            
            system.debug('shoppedKitNameItem::::'+shoppedKitNameItem);
            shopkitData.externalIdField__c                = shoppedKitNameItem;
            shopkitData.Shopped_Kit_Name__c               = j2a.ShoppedKitName;
            shopkitData.Program_Name__c                   = j2a.ProgramName+'_'+j2a.Year;
            shopkitData.Shopkit_Start_Date__c             = j2a.ShopkitStartDate;
            shopkitData.Shopkit_End_Date__c               = j2a.ShopkitEndDate;
            shopkitData.Status_of_Approval__c             = 'Loaded'; 
            shopkitData.Shopkit_Price__c	              = j2a.ShopkitPrice;
            shopkitData.Shopkit_SAP_Number__c             = j2a.ShopkitSAPNumber;
            shopkitData.Shopkit_Temporary_Item_Numbers__c = j2a.ShopkitTemporaryItemNumbers;
            shopkitData.Shopkit_Qty__c                    = Integer.valueOf(j2a.ShopkitQty.trim()); 
            shopkitData.Year__c                           = j2a.Year;
            shopkitData.Business_Line__c                  = j2a.BusinessLine;
            
            if(!externalKeyList.Contains(shopkitData.externalIdField__c)){
                externalKeyList.add(shopkitData.externalIdField__c);
                shopkitDataList.add(shopkitData);  
            }
            
        }
        Database.UpsertResult[] results;
        try{
            // upsert shopkitDataList externalIdField__c;
            if(!Schema.sObjectType.NAZ_OP_Shopkit_Data__c.isCreateable()){
                throw new AuraHandledException('User does not have sufficient Permission to complete the operation');   
            }
            else{
                results = Database.upsert(shopkitDataList,NAZ_OP_Shopkit_Data__c.externalIdField__c,false);
            }
        }catch(DmlException e){ throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record'+ e.getMessage());
                              }
        
        return shopkitsave;
    }
   /***
    * @Method Name	    createItemRecords
    * @Author			Ankita Sarda
    * @CreatedDate		09-19-2019
    * @Description		Taking Item record from lightning Component and
    *                   Create record in Stagging area
    ***/ 
    
    @AuraEnabled
    public static string createItemRecords(String brandToSave){
        String forYes = 'YES';
        String forNo = 'NO';
        system.debug('brandToSave----1234'+brandToSave);
        
            List<Program_Brands_Item__c> PBItemsList = new List<Program_Brands_Item__c>();
            Set<Program_Brands_Item__c> PBItemsSet = new Set<Program_Brands_Item__c>();
            List<JSON2ApexPBItems> obj = JSON2ApexPBItems.parse(brandToSave);
            List<String> ItemName= new List<String>();
                        /* for(JSON2ApexPBItems j2a:obj)
            {
            if(j2a.TempItemNumber != '' || j2a.TempItemNumber != Null){
            ItemName.add(j2a.TempItemNumber+'_'+j2a.ProductName);
            }
            if(j2a.SAPItemNumber != '' || j2a.SAPItemNumber != Null){
            ItemName.add(j2a.SAPItemNumber+'_'+j2a.ProductName);
            }
            }*/
            system.debug('ItemName----1234'+ItemName);
            List<String> externalKeyListforItems = new List<String>();
            List<contentVersion> lstOfCV = new List<contentVersion>([Select id,title,ContentDocumentId, ContentDocument.LatestPublishedVersionId from contentVersion WHERE  FirstPublishLocationId IN (SELECT id FROM  ContentWorkspace  WHERE Name='POC Planning Image Setup')]);
            Map<String,String> mapOfCV = new Map<String,String>();
            for(contentVersion cv : lstOfCV){
                mapOfCV.put(cv.title.substringBefore('_'), cv.id);
                system.debug(' cv.ContentDocumentId'+ cv.ContentDocumentId);
                system.debug(' cv.id'+ cv.id);
            }
            system.debug('$$$mapOfCV$$$'+mapOfCV);
            
            for(JSON2ApexPBItems j2a:obj)
            {
                Program_Brands_Item__c PBItems = new Program_Brands_Item__c();
                
                String PBIExternalKey ='';
                //External key here is a unique key between Brand Name + Program Name + (sap item number/ temp item number)
                if(j2a.isUserPaid.equalsIgnoreCase(forYes)){
                    if(j2a.SAPItemNumber=='' || j2a.SAPItemNumber==null)
                    {
                        PBIExternalKey = j2a.ProgramName+'_'+j2a.Year+'_'+j2a.ProgramName+'_'+j2a.Year+'_'+ j2a.TempItemNumber+'_'+j2a.BusinessLine;  
                    }
                    else if(j2a.TempItemNumber=='' || j2a.TempItemNumber==null)
                    {
                        PBIExternalKey =  j2a.ProgramName+'_'+j2a.Year+'_'+j2a.ProgramName+'_'+j2a.Year+'_'+ j2a.SAPItemNumber+'_'+j2a.BusinessLine;  
                    }
                }
                if(j2a.isUserPaid.equalsIgnoreCase(forNo)){
                    if(j2a.SAPItemNumber=='' || j2a.SAPItemNumber==null)
                    {
                        PBIExternalKey = j2a.ProgramName+'_'+j2a.Year+'_'+ j2a.TempItemNumber+'_'+j2a.BusinessLine;  
                    }
                    else if(j2a.TempItemNumber=='' || j2a.TempItemNumber==null)
                    {
                        PBIExternalKey = j2a.ProgramName+'_'+j2a.Year+'_'+ j2a.SAPItemNumber+'_'+j2a.BusinessLine;   
                    }   
                }
                // PBItems.External_Id_for_PBI_on_Ownership__c = j2a.ProgramName+'_'+j2a.Year+'_'+ j2a.SAPItemNumber+'_'+j2a.BusinessLine+'_'+userInfo.getUserId();
                
                system.debug('PBIExternalKey'+PBIExternalKey);
                PBItems.External_Id_for_PBI__c  = PBIExternalKey;
                //PBItems.Brand_Name__c = j2a.BrandName;
                if(j2a.BrandName.contains(';')){
                 PBItems.Brand_Name__c = j2a.BrandName.replace(';',',');
                 }
                else{	
                PBItems.Brand_Name__c = j2a.BrandName;
                 }
                PBItems.Currency_a__c =  j2a.varCurrency;
                if(j2a.SAPItemNumber=='' || j2a.SAPItemNumber==null)
                {
                    PBItems.Image_Link__c = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+mapOfCV.get(j2a.TempItemNumber);
                    //'/sfc/servlet.shepherd/version/download/'+mapOfCV.get(j2a.TempItemNumber);
                }
                else if(j2a.TempItemNumber=='' || j2a.TempItemNumber==null)
                {
                    PBItems.Image_Link__c = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+mapOfCV.get(j2a.SAPItemNumber);
                    //'/sfc/servlet.shepherd/version/download/'+mapOfCV.get(j2a.SAPItemNumber);  
                }
                
                PBItems.Program_Name__c = j2a.ProgramName+'_'+ j2a.Year;
                PBItems.Program_Descritpion__c = j2a.ProgramDescription;
                PBItems.Program_Start_Date__c = j2a.ProgramStartDate;
                PBItems.Program_End_Date__c = j2a.ProgramEndDate;
                PBItems.Planning_Start_Date__c = j2a.PlanningStartDate;
                PBItems.Planning_End_Date__c = j2a.PlanningEndDate;
                PBItems.Item_Classification__c = j2a.ItemClassification;
                if(j2a.isUserPaid.equalsIgnoreCase(forYes)){
                    PBItems.User_Paid__c = true;
                }else if(j2a.isUserPaid.equalsIgnoreCase(forNo)){   PBItems.User_Paid__c = false;
                                                                }
                PBItems.Business_Line__c = j2a.BusinessLine;
                if(j2a.SAPItemNumber=='' || j2a.SAPItemNumber == null){
                    system.debug('no sap id');
                }else{
                    PBItems.SAP_Item_Number__c =  j2a.SAPItemNumber ;  
                }
                if(j2a.TempItemNumber == '' || j2a.TempItemNumber == null  ){
                    system.debug('no temp id');
                }else{
                    PBItems.Temp_Item_Number__c = j2a.TempItemNumber ; 
                }
                PBItems.Product_Name__c = j2a.ProductName;
                PBItems.Size__c = j2a.Size;
                PBItems.Language__c = j2a.Language;
                PBItems.Unit_of_Measure__c = j2a.UnitOfMeasure;
                PBItems.Currency_b__c = j2a.Currency2;
                PBItems.Quantity_per_UOM__c =  Integer.valueOf(j2a.QuantityPerUOM);
                PBItems.Standard_Price__c = Double.valueOf(j2a.StandardPrice);
                PBItems.Full_Price_to_Rep__c = Double.valueOf(j2a.FullPriceToRep);
                PBItems.Item_Type__c = j2a.ItemType;
                PBItems.OOH_Item_Classification__c = j2a.ItemClassification;
                PBItems.IH_Item_Classification__c = j2a.ItemClassification;
                if(j2a.Atlantic.equalsIgnoreCase(forYes)){
                    PBItems.Atlantic__c = true;
                }else if(j2a.Atlantic.equalsIgnoreCase(forNo)){
                    PBItems.Atlantic__c = false;
                }
                if(j2a.Quebec.equalsIgnoreCase(forYes)){
                    PBItems.Quebec__c = true;
                }else if(j2a.Quebec.equalsIgnoreCase(forNo)){
                    PBItems.Quebec__c = false;
                }
                if(j2a.Ontario.equalsIgnoreCase(forYes)){
                    PBItems.Ontario__c = true;
                }else if(j2a.Ontario.equalsIgnoreCase(forNo)){
                    PBItems.Ontario__c = false;
                }
                if(j2a.West.equalsIgnoreCase(forYes)){
                    PBItems.West__c = true;
                }else if(j2a.West.equalsIgnoreCase(forNo)){
                    PBItems.West__c = false;
                }
                PBItems.Menu_Category__c = j2a.MenuCategory;
                PBItems.Item_Description_EN__c = j2a.ItemDescriptionEN;
                PBItems.Item_Description_FR__c = j2a.ItemDescriptionFR;
                                    /*if(j2a.IsProgramOnly.equalsIgnoreCase(forYes)){
                    PBItems.Is_Program_Only__c	 = true;
                    }else if(j2a.IsProgramOnly.equalsIgnoreCase(forNo)){
                    PBItems.Is_Program_Only__c	 = false;
                    } */
                if(j2a.IsAllocationOnly.equalsIgnoreCase(forYes)){
                    PBItems.Is_Program_Only__c	 = true;
                }else if(j2a.IsAllocationOnly.equalsIgnoreCase(forNo)){
                    PBItems.Is_Program_Only__c	 = false;
                }
                // PBItems.Is_Available__c = Boolean.valueOf(j2a.IsAvailable);
                PBItems.Status_of_Approval__c = 'Loaded';
                PBItems.Parent_Product_Types__c = j2a.ParentProductType;
                PBItems.Product_Type__c = j2a.ProductType;
                PBItems.Year__c = j2a.Year;
                PBItemsSet.add(PBItems);
            }
            PBItemsList.addAll(PBItemsSet);
            system.debug('PBItemsList'+PBItemsList);
            Database.UpsertResult[] results;
            try{
                //upsert PBItemsList External_Id_for_PBI__c;
                if(!Schema.sObjectType.Program_Brands_Item__c.isCreateable()){
                    throw new AuraHandledException('User does not have sufficient Permission to complete the operation');   
                }
                else{
                    results = Database.upsert(PBItemsList,Program_Brands_Item__c.External_Id_for_PBI__c,false);
                }
            }catch(DmlException e){ 
                throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving Item records'+ e.getMessage());
             }
        
        return brandToSave;
    }
        /***
    * @Method Name	    createBudgetPR
    * @Author			Ragbirendra Upadhyay
    * @CreatedDate		09-19-2019
    * @Description		Take Budget Record from Lightning Component and create new record
    *                   in Stagging Area 
    ***/
    @AuraEnabled
    public static string createBudgetPR(String recordsToSave){
        
        List<BudgetLoadUI__c> BudgetPRList = new List<BudgetLoadUI__c>();
        List<String> externalIdList = new List<String>();
        List<String> externalKeyList = new List<String>();	
        List<JsonToApexForBudget> ObjectToSave = JsonToApexForBudget.parse(recordsToSave);
        
        Map<String, BudgetLoadUI__c> externalKeyMap = new Map<String, BudgetLoadUI__c>(); 
        ExcelHeader__mdt[] brandKeithGooseShockTop = [select MasterLabel, QualifiedApiName, column_A__c FROM ExcelHeader__mdt where MasterLabel ='Brand Name KeithGooseShocktop'];
        for(BudgetLoadUI__c objBPR : [select Id,ExternalKey__c from BudgetLoadUI__c])
            externalKeyMap.put(objBPR.ExternalKey__c, objBPR);
        
        //ExcelHeader__mdt[] ccMailId = [select MasterLabel, QualifiedApiName, column_A__c FROM ExcelHeader__mdt where MasterLabel ='Brand Name KeithGooseShocktop'];
        for(JsonToApexForBudget j2a:ObjectToSave)
        {
            
            BudgetLoadUI__c BudgetData = new BudgetLoadUI__c();
            BudgetData.District_Code__c = j2a.DistrictCode;
            BudgetData.District_Name__c = j2a.DistrictName;
            BudgetData.Year__c = j2a.Year;
            
            BudgetData.Business_Line__c = j2a.BusinessLine;
            BudgetData.Region__c = j2a.Region;
            
            BudgetData.Territory_Name__c = j2a.TerritoryName;
            BudgetData.Territory_Code__c = j2a.TerritoryCode;
            if(j2a.BusinessLine =='Out of Home')
            {
                BudgetData.District_Record_Type__c = 'OOH District';
                BudgetData.Territory_Record_Type__c ='OOH Territory';
            }
            if(j2a.BusinessLine =='In Home')
            {
                BudgetData.District_Record_Type__c = 'New IH District';
                BudgetData.Territory_Record_Type__c ='New IH Territory';
            }
            BudgetData.Discretionary_Budget__c = Decimal.valueOf(j2a.DiscretionaryBudget);
            if(j2a.Brand.contains(';')){
                BudgetData.Brand__c = j2a.Brand.replace(';',',');
            }
            else{	
                BudgetData.Brand__c = j2a.Brand;
            }
            
            BudgetData.Territory_Brand_Budget__c = Decimal.valueOf(j2a.TerritoryBrandBudget);
            
            if(externalKeyMap.containsKey(j2a.DistrictCode+'_'+j2a.TerritoryCode+'_'+BudgetData.Brand__c+'_'+j2a.Year+'_'+BudgetData.Territory_Record_Type__c)){
                BudgetData.Status__c = 'Updated';    
            }else{
                BudgetData.Status__c = 'New';}
            BudgetData.External_Id__c = j2a.TerritoryCode+'_'+j2a.Year+'_'+BudgetData.Brand__c+'_'+BudgetData.Territory_Record_Type__c;
            BudgetData.ExternalKey__c = j2a.DistrictCode+'_'+j2a.TerritoryCode+'_'+BudgetData.Brand__c+'_'+j2a.Year+'_'+BudgetData.Territory_Record_Type__c;
            
            if(!externalIdList.Contains(BudgetData.External_Id__c) && !externalKeyList.Contains(BudgetData.ExternalKey__c) ){
                externalIdList.add(BudgetData.External_Id__c);
                externalKeyList.add(BudgetData.ExternalKey__c);
                BudgetPRList.add(BudgetData);
            }
            
            
        }
        
        Database.UpsertResult[] results;
        try{
            if(!Schema.sObjectType.BudgetLoadUI__c.isCreateable()){
                throw new AuraHandledException('User does not have sufficient Permission to complete the operation');   
            }
            else{
                results = Database.upsert(BudgetPRList,BudgetLoadUI__c.ExternalKey__c,false);
            }
        }catch(DmlException e){
            throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record '+ e.getMessage());
        }
        return recordsToSave;
    }
        /***
    * @Method Name	    FetchBudgetRecords
    * @Author			Ragbirendra Upadhyay
    * @CreatedDate		09-19-2019
    * @Description		Used to export Budget record from  
                        Stagging object Based on channel and Year
    */
    @AuraEnabled
    public static List<BudgetLoadUI__c> FetchBudgetRecords(String selectedChArr,Integer selectedYrArr)
    {
        
        system.debug('String.valueOf(selectedYrArr):::'+String.valueOf(selectedYrArr));
        List<BudgetLoadUI__c> listBudget =[select District_Code__c,District_Name__c,Year__c, Business_Line__c,Region__c,Territory_Name__c,Territory_Code__c,Discretionary_Budget__c,Brand__c,Territory_Brand_Budget__c from BudgetLoadUI__c where Year__c=:String.valueOf(selectedYrArr) and Business_Line__c=: selectedChArr];
        return listBudget;
    }
        /***
    * @Method Name	    pushOnplanBatchExe
    * @Author			Ragbirendra Upadhyay
    * @CreatedDate		09-19-2019
    * @Description		User Intiate Budget Creation trigger from UI
    */
    @AuraEnabled
    public static void pushOnplanBatchExe()
    {
        Boolean allJobCompleted= true;
        String className='createDistAndTerritoryBudgetBatch';
        ApexClass apexClass=[SELECT Id, Name FROM ApexClass WHERE Name=:String.escapeSingleQuotes(className)];
        List<AsyncApexJob> asynchJob=[Select Id,ApexClassId, Status, NumberOfErrors, JobItemsProcessed,
                                      TotalJobItems, CreatedBy.Email, ExtendedStatus
                                      from AsyncApexJob WHERE ApexClassId=:apexClass.Id];
        for(AsyncApexJob obj: asynchJob){ 
            if(obj.Status != 'Completed'  && obj.Status != 'Aborted'&& obj.Status != 'Failed'){
                allJobCompleted=false;
            }
        }
        system.debug('asynchJob::::'+asynchJob.size()); 
        
        
        system.debug('allJobCompleted 2'+allJobCompleted);
        if(allJobCompleted == false){
            throw new AuraHandledException('Budget load process is already in progress . So please try after 30 Mintues !!!');
        }
        else{
            CreateDistAndTerritoryBudgetBatch createDistAndTerritoryBudgetBatch = new CreateDistAndTerritoryBudgetBatch() ;
            ID batchprocessid = Database.executeBatch(createDistAndTerritoryBudgetBatch,10);    
        }
        
        
    }
     /***
    * @Method Name	    FetchBackofficeBudgetRecords
    * @Author			Ragbirendra Upadhyay
    * @CreatedDate		09-19-2019
    * @Description		Used to export Backoffice Budget record from  
                        Annual Brand Budget Plan object Based on channel and Year
    */
    @AuraEnabled
    public static List<backofficeBudgetWrapper> FetchBackofficeBudgetRecords(String selectedChArr,Integer selectedYrArr)
    {  
        string recordtypeValue;
        if(selectedChArr =='Out of Home'){
         recordtypeValue ='OOH Territory';   
        }
        if(selectedChArr == 'In Home'){
          recordtypeValue ='New IH Territory';  
        }
        system.debug('String.valueOf(selectedYrArr):::'+String.valueOf(selectedYrArr));
        system.debug('String.valueOf(selectedChArr):::'+String.valueOf(selectedChArr));
        List<backofficeBudgetWrapper> backofficeWrapper = new List<backofficeBudgetWrapper>();
        List<Annual_Brand_Area_Budget_Plan__c> listBudget =[select 
                                                            Brand_Budget__c,
                                                            Annual_Area_Budget__r.Recordtype.name,
                                                            Annual_Area_Budget__r.Sales_Territory_Name__c,
                                                            Annual_Area_Budget__r.Discretionary_Budget__c,
                                                            Brand__r.name,
                                                            Budget_Year__c,
                                                            Annual_Area_Budget__r.Sales_Territory__r.lboc_Territory_ID__c
                                                            from Annual_Brand_Area_Budget_Plan__c 
                                                            where Budget_Year__c=:String.valueOf(selectedYrArr) 
                                                                   and Annual_Area_Budget__r.Recordtype.name =: recordtypeValue 
                                                                   and Annual_Area_Budget__r.Sales_Territory__r.OnPoint_Territory__r.Back_Office_Territory__c =true];
       
        
        if((listBudget!=null && listBudget.size()>0)|| test.isRunningTest()){
            for(Annual_Brand_Area_Budget_Plan__c abab:listBudget){
              backofficeBudgetWrapper bobw = new backofficeBudgetWrapper(); 
                bobw.DistrictCode = 'National' ;
                bobw.DistrictName = 'National' ;
                bobw.Year = abab.Budget_Year__c;
                bobw.BusinessLine = selectedChArr ;
                bobw.Region = 'Natioanl' ;
                bobw.TerritoryName = abab.Annual_Area_Budget__r.Sales_Territory_Name__c ;
                bobw.TerritoryCode = abab.Annual_Area_Budget__r.Sales_Territory__r.lboc_Territory_ID__c;
                bobw.DiscretionaryBudget = abab.Annual_Area_Budget__r.Discretionary_Budget__c ;
                
                string brandname = abab.Brand__r.name;
                if(brandname.contains(','))
                {
                brandname = brandname.replace(',',';');    
                }
                bobw.Brand = brandname ;
                bobw.TerritoryBrandBudget = abab.Brand_Budget__c ;
                backofficeWrapper.add(bobw);
            }
        }
        else{
          throw new AuraHandledException('No Record for Selected year and channel ! Please create Backoffice Budget and Try Again');  
        }
         return backofficeWrapper;
    }
   
      /***
    * @Method Name	    fetchDistAndTerrRecord
    * @Author			Ragbirendra Upadhyay
    * @CreatedDate		09-19-2019
    * @Description		fetch Dist And Terr Record
    */
    @AuraEnabled
    public static List<String> fetchDistAndTerrRecord()
    {  
        List<OnPoint_District__c> onPoinDisList = [Select Id,District_Code__c from OnPoint_District__c];
        List<lboc_Sales_Territory__c> salesterrList = [Select Id,lboc_Territory_ID__c from lboc_Sales_Territory__c];
            List<String> terrAndDistCodeList = new List<String>();
        for(OnPoint_District__c od:onPoinDisList){
            terrAndDistCodeList.add(od.District_Code__c); 
        }
        terrAndDistCodeList.add('territoryCodeStarted');
        for(lboc_Sales_Territory__c st:salesterrList)
        {
            terrAndDistCodeList.add(st.lboc_Territory_ID__c); 
        }
        system.debug('terrAndDistCodeList'+terrAndDistCodeList);
        return terrAndDistCodeList;
    }
    public class backofficeBudgetWrapper{
        @AuraEnabled public string DistrictCode{get;set;} 
        @AuraEnabled public string DistrictName{get;set;} 
        @AuraEnabled public string Year{get;set;}
        @AuraEnabled public string BusinessLine{get;set;} 
        @AuraEnabled public string Region{get;set;}
        @AuraEnabled public string TerritoryName{get;set;} 
        @AuraEnabled public string TerritoryCode{get;set;}
        @AuraEnabled public decimal DiscretionaryBudget{get;set;}
        @AuraEnabled public string Brand{get;set;}
        @AuraEnabled public decimal TerritoryBrandBudget{get;set;}
       
        
    }
    
}