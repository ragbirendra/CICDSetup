/***
* @Name - ProductBrandItemListViewApex
* @Author - Cognizant Developers
* @CreatedDate -09/15/2019
* @Description - 
* 

***/
public without sharing class ProductBrandItemListViewApex {
    /*apex method to fetch wrapper of list view*/ 
    
    /***
* @Method Name	    listValues
* @Author			Ankita Sarda
* @CreatedDate		09-19-2019
* @Description		apex method to fetch wrapper of list view
*/
    @AuraEnabled
    public static list<listViewWrapper> listValues(string objectInfo){
        
        list<listViewWrapper> oListViewWrapper = new list<listViewWrapper>();
        
        for(ListView lv : [SELECT id, Name, DeveloperName FROM ListView
                           WHERE sObjectType = : objectInfo ORDER By Name ASC]){ 
                               listViewWrapper oWrapper = new listViewWrapper();
                               oWrapper.label = lv.Name;
                               oWrapper.developerName = lv.DeveloperName;
                               oListViewWrapper.add(oWrapper);
                           }
        
        return oListViewWrapper; 
    }
    
    /***
* @Method Name	    saveUpdateditemRecords
* @Author			Ankita Sarda
* @CreatedDate		09-19-2019
* @Description		apex method to save the updated PBI record when it is rejected
*/
    
    @AuraEnabled
    public static string saveUpdateditemRecords(String brandToSave, String comment){
        system.debug('brandToSave----1234'+brandToSave);
        String forYes = 'true';
        String forNo = 'false';
        List<Program_Brands_Item__c> PBItemsList = new List<Program_Brands_Item__c>();
        List<JSON2ApexPBItems> obj = JSON2ApexPBItems.parse(brandToSave);
        
        
     /*   List<contentVersion> lstOfCV = new List<contentVersion>([Select id,title from contentVersion]);
        Map<String,String> mapOfCV = new Map<String,String>();
        for(contentVersion cv : lstOfCV){  
            mapOfCV.put(cv.title.substringBefore('_'), cv.id);
        }
        system.debug('$$$mapOfCV$$$'+mapOfCV);
*/
        for(JSON2ApexPBItems j2a:obj)
        {
            Program_Brands_Item__c PBItems = new Program_Brands_Item__c();
            
            String PBIExternalKey ='';
            system.debug('String.valueOf(j2a.SAPItemNumber'+j2a.SAPItemNumber);
            system.debug('String.valueOf(j2a.TempItemNumber)'+j2a.TempItemNumber);
            system.debug('UserPaid Value'+j2a.isUserPaid);
            system.debug('QuantityPerUOM Value'+j2a.QuantityPerUOM);
            system.debug('StandardPrice Value'+j2a.StandardPrice);
            system.debug('ItemDescriptionEN Value'+j2a.ItemDescriptionEN);
            system.debug('ProgramEndDate Value'+j2a.ProgramEndDate);
            system.debug('Year Value'+j2a.Year);
            //External key here is a unique key between Brand Name + Program Name + (sap item number/ temp item number)
            
            if(j2a.isUserPaid.equalsIgnoreCase(forYes)){
                if(j2a.SAPItemNumber=='' || j2a.SAPItemNumber==null)
                {
                    PBIExternalKey = j2a.ProgramName+'_'+j2a.ProgramName+'_'+ j2a.TempItemNumber+'_'+j2a.BusinessLine;  
                    system.debug('inside line 67 if' + PBIExternalKey);
                }
                else if(j2a.TempItemNumber=='' || j2a.TempItemNumber==null)
                {PBIExternalKey =  j2a.ProgramName+'_'+j2a.ProgramName+'_'+ j2a.SAPItemNumber+'_'+j2a.BusinessLine;  
                 system.debug('inside line 71 if' + PBIExternalKey);
                }
                
            }
            if(j2a.isUserPaid.equalsIgnoreCase(forNo)){
                if(j2a.SAPItemNumber=='' || j2a.SAPItemNumber==null)
                { PBIExternalKey = j2a.ProgramName+'_'+ j2a.TempItemNumber+'_'+j2a.BusinessLine; 
                 system.debug('inside line 77 if' + PBIExternalKey) ;
                }
                else if(j2a.TempItemNumber=='' || j2a.TempItemNumber==null)
                {
                    PBIExternalKey =  j2a.ProgramName+'_'+ j2a.SAPItemNumber+'_'+j2a.BusinessLine; 
                    system.debug('inside line 82 if ' + PBIExternalKey);
                }  
                
            }
            
            system.debug('PBIExternalKey is '+PBIExternalKey);
            PBItems.External_Id_for_PBI__c  = PBIExternalKey;
            PBItems.Currency_a__c =  j2a.varCurrency;
            PBItems.Program_Descritpion__c = j2a.ProgramDescription;
            //PBItems.Program_Start_Date__c = j2a.ProgramStartDate;
            //PBItems.Program_End_Date__c = j2a.ProgramEndDate;
            //PBItems.Planning_Start_Date__c = j2a.PlanningStartDate;
            //PBItems.Planning_End_Date__c = j2a.PlanningEndDate;
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
            PBItems.Atlantic__c = Boolean.valueOf(j2a.Atlantic);
            PBItems.Quebec__c = Boolean.valueOf(j2a.Quebec);
            PBItems.Ontario__c = Boolean.valueOf(j2a.Ontario);
            PBItems.West__c = Boolean.valueOf(j2a.West);
            PBItems.Item_Description_EN__c = j2a.ItemDescriptionEN;
            PBItems.Item_Description_FR__c = j2a.ItemDescriptionFR;
            //PBItems.Year__c = j2a.Year;
            system.debug('StandardPrice Value'+PBItems.Standard_Price__c);
            system.debug('Program_End_Date__c Value'+PBItems.Program_End_Date__c);
            PBItemsList.add(PBItems);
            
        }
        system.debug('PBItemsList'+PBItemsList);
        Database.UpsertResult[] results;
        try{
            if(!Schema.sObjectType.Program_Brands_Item__c.isCreateable()){
                throw new AuraHandledException('User does not have sufficient Permission to complete the operation');   
            }
            else{
                results = Database.upsert(PBItemsList,Program_Brands_Item__c.External_Id_for_PBI__c,false);
            }
        }catch(DmlException e){  throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record'+ e.getMessage());
                              }
        return brandToSave;
    }
    
    /*wrapper class to store listView details*/ 
    public class listViewWrapper{
        @AuraEnabled public string label{get;set;} 
        @AuraEnabled public string developerName{get;set;} 
    }
    /***
* @Method Name	    getPickListVals
* @Author			Ankita Sarda
* @CreatedDate		09-19-2019
* @Description		apex method to fetch wrapper of list view
*/
    @AuraEnabled(cacheable=true)
    public static list<picklistValWrapper> getPickListVals(){
        
        list<Program_Brands_Item__c> lst = new List<Program_Brands_Item__c>();
        User u = [SELECT Id,is_TAU_User__c,is_TAU_Admin__c FROM User WHERE Id =: UserInfo.getUserId()];
        
        System.debug('RM==========='+u.is_TAU_User__c);
        if(u.is_TAU_Admin__c == true && u.is_TAU_User__c == false ){
            
            lst = [select id,OwnerId,Atlantic__c,Brand_Name__c,Business_Line__c,Currency_a__c,CurrencyIsoCode,Currency_b__c,FOR_DRIVERS_ONLY__c,Full_Price_to_Rep__c,
                   IH_Item_Classification__c,Is_Available__c,Is_IH_Only__c,Item_Description_EN__c,Item_Description_FR__c,Item_Type__c,Language__c,Menu_Category__c,
                   Ontario__c,OOH_Item_Classification__c,Is_Program_Only__c,Year__c,
                   Planning_End_Date__c,Planning_Start_Date__c,Product_Name__c,Name,
                   Program_Descritpion__c,Program_End_Date__c,Program_Name__c,Program_Start_Date__c,
                   Quantity_per_UOM__c,Quebec__c,SAP_Item_Number__c,Size__c,Standard_Price__c,Status_of_Approval__c,
                   Temp_Item_Number__c,Unit_of_Measure__c,West__c,Image_Link__c,Item_Classification__c 
                   from Program_Brands_Item__c   
                   WHERE (Status_of_Approval__c=:System.Label.ABI_OP_ApprovedStatus 
                          OR Status_of_Approval__c=:System.Label.ABI_OP_SubmitForApproval 
                          OR Status_of_Approval__c= 'Completed'
                          OR Status_of_Approval__c= 'Loaded'
                          OR OwnerId=:UserInfo.getUserId()
                          OR LastModifiedById=:userInfo.getUserId())
                  ];
        }else if(u.is_TAU_User__c == true && u.is_TAU_Admin__c == false){
            
            lst = [select id,OwnerId,Atlantic__c,Brand_Name__c,Business_Line__c,Currency_a__c,CurrencyIsoCode,Currency_b__c,FOR_DRIVERS_ONLY__c,Full_Price_to_Rep__c,
                   IH_Item_Classification__c,Is_Available__c,Is_IH_Only__c,Item_Description_EN__c,Item_Description_FR__c,Item_Type__c,Language__c,Menu_Category__c,
                   Ontario__c,OOH_Item_Classification__c,Is_Program_Only__c,Year__c,
                   Planning_End_Date__c,Planning_Start_Date__c,Product_Name__c,Name,
                   Program_Descritpion__c,Program_End_Date__c,Program_Name__c,Program_Start_Date__c,
                   Quantity_per_UOM__c,Quebec__c,SAP_Item_Number__c,Size__c,Standard_Price__c,Status_of_Approval__c,
                   Temp_Item_Number__c,Unit_of_Measure__c,West__c,Image_Link__c,Item_Classification__c 
                   from Program_Brands_Item__c   
                   WHERE (LastModifiedById=:userInfo.getUserId() or LastModifiedBy.Is_TAU_Admin__c=true)//OwnerId=:UserInfo.getUserId()
                  ];            
        }
        System.debug('lst'+lst);
        list<picklistValWrapper> oListViewWrapper = new list<picklistValWrapper>();
        
        if(!lst.isEmpty()){
            for(Program_Brands_Item__c pc:lst){
                picklistValWrapper oWrapper = new picklistValWrapper();
                oWrapper.recordId = pc.id;
                oWrapper.programName = pc.Program_Name__c;
                oWrapper.ProductName = pc.Product_Name__c;
                oWrapper.Status = pc.Status_of_Approval__c;
                oWrapper.BrandName = pc.Brand_Name__c;
                oWrapper.BusinessLine = pc.Business_Line__c;
                oWrapper.FullPriceToRep = pc.Full_Price_to_Rep__c;
                oWrapper.IHItemClassification = pc.IH_Item_Classification__c;
                oWrapper.IsAvailable = pc.Is_Available__c;
                oWrapper.IsIHOnly = pc.Is_IH_Only__c;
                oWrapper.ItemClassification = pc.Item_Classification__c;
                oWrapper.ItemDescriptionEN = pc.Item_Description_EN__c;
                oWrapper.ItemDescriptionFR = pc.Item_Description_FR__c;
                oWrapper.ItemType = pc.Item_Type__c;
                oWrapper.Language = pc.Language__c;
                oWrapper.MenuCategory = pc.Menu_Category__c;
                oWrapper.OOHItemClassification = pc.OOH_Item_Classification__c;
                oWrapper.Ontario = pc.Ontario__c;
                oWrapper.PlanningEndDate = pc.Planning_End_Date__c;
                oWrapper.PlanningStartDate = pc.Planning_Start_Date__c;
                oWrapper.ProgramDescritpion = pc.Program_Descritpion__c;
                oWrapper.ProgramEndDate = pc.Program_End_Date__c;
                oWrapper.ProgramStartDate = pc.Program_Start_Date__c;
                oWrapper.Quantity = pc.Quantity_per_UOM__c;
                oWrapper.Quebec = pc.Quebec__c;
                oWrapper.SAPItemNumber = pc.SAP_Item_Number__c;
                oWrapper.StandardPrice = pc.Standard_Price__c;
                oWrapper.TempItemNumber = pc.Temp_Item_Number__c;
                oWrapper.UnitofMeasure = pc.Unit_of_Measure__c;
                oWrapper.West = pc.West__c;
                oWrapper.IsAllocationOnly = pc.Is_Program_Only__c;    
                oWrapper.ImageLink = pc.Image_Link__c;
                oWrapper.Year=pc.Year__c;
                oListViewWrapper.add(oWrapper);
            }
        }
        system.debug('oListViewWrapper'+oListViewWrapper);
        return oListViewWrapper;
        
        
    }
    public class picklistValWrapper{
        @AuraEnabled public string recordId{get;set;} 
        @AuraEnabled public string programName{get;set;} 
        @AuraEnabled public string Status{get;set;} 
        @AuraEnabled public string BrandName{get;set;}
        @AuraEnabled public string BusinessLine{get;set;} 
        @AuraEnabled public decimal FullPriceToRep{get;set;}
        @AuraEnabled public boolean IsAvailable{get;set;} 
        @AuraEnabled public boolean IsIHOnly{get;set;}
        @AuraEnabled public string ItemDescriptionEN{get;set;} 
        @AuraEnabled public string ItemDescriptionFR{get;set;} 
        @AuraEnabled public string ItemType{get;set;}
        @AuraEnabled public string Language{get;set;} 
        @AuraEnabled public string MenuCategory{get;set;} 
        @AuraEnabled public string IHItemClassification{get;set;} 
        @AuraEnabled public string OOHItemClassification{get;set;}
        @AuraEnabled public string PlanningEndDate{get;set;} 
        @AuraEnabled public string PlanningStartDate{get;set;}
        @AuraEnabled public string ProductName{get;set;} 
        @AuraEnabled public string ProgramDescritpion{get;set;} 
        @AuraEnabled public string ProgramEndDate{get;set;}
        @AuraEnabled public string ProgramStartDate{get;set;}
        @AuraEnabled public string ItemClassification{get;set;}
        @AuraEnabled public decimal Quantity{get;set;}
        @AuraEnabled public boolean Quebec{get;set;} 
        @AuraEnabled public boolean Ontario{get;set;}   @AuraEnabled public boolean Atlantic{get;set;} 
        @AuraEnabled public boolean West{get;set;}
        @AuraEnabled public string SAPItemNumber{get;set;} 
        @AuraEnabled public decimal StandardPrice{get;set;}
        @AuraEnabled public string TempItemNumber{get;set;} 
        @AuraEnabled public string UnitofMeasure{get;set;} 
        @AuraEnabled public String Image{get;set;}
        @AuraEnabled public Boolean isUserPaid{get;set;}
        @AuraEnabled public String ImageLink{get;set;}
        @AuraEnabled public Boolean IsAllocationOnly{get;set;}
        @AuraEnabled public String rejectionComment{get;set;}
        @AuraEnabled public String Year{get;set;}
    }
    /***
* @Method Name	    getFilteredvals
* @Author			Ankita Sarda
* @CreatedDate		09-19-2019
* @Description		apex method to fetch wrapper of list view
*/
    @AuraEnabled(cacheable=true)
    Public static List<picklistValWrapper> getFilteredvals(String selectedProgramName, String selectedStatusName,string selectedBusinessLine,string selectedBudgetYear) {
        
        list<Program_Brands_Item__c>  filteredLst = new List<Program_Brands_Item__c>();
        User u = [SELECT Id,is_TAU_User__c,is_TAU_Admin__c FROM User WHERE Id =: UserInfo.getUserId()];
        if(u.is_TAU_User__c == true && u.is_TAU_Admin__c==false){
            filteredLst =   [select id,OwnerId,Atlantic__c,Brand_Name__c,Business_Line__c,Currency_a__c,CurrencyIsoCode,Currency_b__c,FOR_DRIVERS_ONLY__c,Full_Price_to_Rep__c,IH_Item_Classification__c,Is_Available__c,Is_IH_Only__c,Item_Description_EN__c,Item_Description_FR__c,Item_Type__c,Language__c,Menu_Category__c,Ontario__c,OOH_Item_Classification__c,
                             Planning_End_Date__c,Planning_Start_Date__c,Product_Name__c,Name,User_Paid__c,
                             Program_Descritpion__c,Program_End_Date__c,Program_Name__c,Program_Start_Date__c,
                             Quantity_per_UOM__c,Quebec__c,SAP_Item_Number__c,Size__c,Standard_Price__c,Status_of_Approval__c,
                             Temp_Item_Number__c,Unit_of_Measure__c,West__c,Is_Program_Only__c,Image_Link__c,rejectionComment__c,Item_Classification__c ,Year__c
                             from Program_Brands_Item__c
                             WHERE Program_Name__c=:selectedProgramName 
                             AND Status_of_Approval__c =:selectedStatusName 
                             AND  Business_Line__c=:selectedBusinessLine
                             AND Year__c=:selectedBudgetYear
                             AND (LastModifiedById=:userInfo.getUserId() or LastModifiedBy.Is_TAU_Admin__c=true)];//OwnerId=:UserInfo.getUserId() ];
            
            
        }else if(u.is_TAU_User__c == false && u.is_TAU_Admin__c == true){
            filteredLst =  [select id,OwnerId,Atlantic__c,Brand_Name__c,Business_Line__c,Currency_a__c,CurrencyIsoCode,Currency_b__c,FOR_DRIVERS_ONLY__c,Full_Price_to_Rep__c,IH_Item_Classification__c,Is_Available__c,Is_IH_Only__c,Item_Description_EN__c,Item_Description_FR__c,Item_Type__c,Language__c,Menu_Category__c,Ontario__c,OOH_Item_Classification__c,
                            Planning_End_Date__c,Planning_Start_Date__c,Product_Name__c,Name,User_Paid__c,
                            Program_Descritpion__c,Program_End_Date__c,Program_Name__c,Program_Start_Date__c,
                            Quantity_per_UOM__c,Quebec__c,SAP_Item_Number__c,Size__c,Standard_Price__c,Status_of_Approval__c,
                            Temp_Item_Number__c,Unit_of_Measure__c,West__c,Image_Link__c,Is_Program_Only__c,rejectionComment__c,Item_Classification__c ,Year__c
                            from Program_Brands_Item__c
                            WHERE (Status_of_Approval__c =:selectedStatusName
                            AND Program_Name__c=:selectedProgramName 
                            AND Business_Line__c=:selectedBusinessLine
                            AND Year__c=:selectedBudgetYear)
                           ];
         }
        System.debug('filteredLst'+filteredLst);
        list<picklistValWrapper> oListViewWrapper = new list<picklistValWrapper>();
        if(!filteredLst.isEmpty()){
            for(Program_Brands_Item__c pc:filteredLst){
                picklistValWrapper oWrapper = new picklistValWrapper();
                oWrapper.recordId = pc.id;
                oWrapper.programName = pc.Program_Name__c;
                oWrapper.ProductName = pc.Product_Name__c;
                oWrapper.Status = pc.Status_of_Approval__c;
                oWrapper.BrandName = pc.Brand_Name__c;
                oWrapper.BusinessLine = pc.Business_Line__c;
                oWrapper.FullPriceToRep = pc.Full_Price_to_Rep__c;
                oWrapper.IHItemClassification = pc.IH_Item_Classification__c;
                oWrapper.ItemClassification = pc.Item_Classification__c;
                oWrapper.IsAvailable = pc.Is_Available__c;
                oWrapper.IsIHOnly = pc.Is_IH_Only__c;
                oWrapper.ItemDescriptionEN = pc.Item_Description_EN__c;
                oWrapper.ItemDescriptionFR = pc.Item_Description_FR__c;
                oWrapper.ItemType = pc.Item_Type__c;
                oWrapper.Language = pc.Language__c;
                oWrapper.MenuCategory = pc.Menu_Category__c;
                oWrapper.OOHItemClassification = pc.OOH_Item_Classification__c;
                oWrapper.PlanningEndDate = pc.Planning_End_Date__c;
                oWrapper.PlanningStartDate = pc.Planning_Start_Date__c;
                oWrapper.ProgramDescritpion = pc.Program_Descritpion__c;
                oWrapper.ProgramEndDate = pc.Program_End_Date__c;
                oWrapper.ProgramStartDate = pc.Program_Start_Date__c;
                oWrapper.Quantity = pc.Quantity_per_UOM__c;
                oWrapper.SAPItemNumber = pc.SAP_Item_Number__c;
                oWrapper.StandardPrice = pc.Standard_Price__c;
                oWrapper.TempItemNumber = pc.Temp_Item_Number__c;
                oWrapper.UnitofMeasure = pc.Unit_of_Measure__c;
                oWrapper.West = pc.West__c;
                oWrapper.Atlantic = pc.Atlantic__c;
                oWrapper.Quebec = pc.Quebec__c;
                oWrapper.Ontario = pc.Ontario__c;
                oWrapper.ImageLink = pc.Image_Link__c;
                oWrapper.isUserPaid = pc.User_Paid__c;
                oWrapper.IsAllocationOnly = pc.Is_Program_Only__c;                
                oWrapper.rejectionComment=pc.rejectionComment__c;
                oWrapper.Year=pc.Year__c;
                oListViewWrapper.add(oWrapper);
            }
        }
        return oListViewWrapper;
    }
    
    
    /***
* @Method Name	    FetchUserInfo
* @Author			Ankita Sarda
* @CreatedDate		09-19-2019
* @Description		apex method to fetch User Information
*/
    @AuraEnabled
    public static user FetchUserInfo(){
        
        user userInfo =[SELECT id,Name,is_TAU_User__c,Is_TAU_Admin__c, profile.name FROM User WHERE id=:userInfo.getUserId()];
        System.Debug('userInfo=======>'+userInfo);
        return userInfo;
    }
    
    /***
* @Method Name	    recordsApproval
* @Author			Susmita Panda
* @CreatedDate		09-19-2019
* @Description		Method to let Uers submit records for Approval to the Admin and send notification mail to the admin and user
*/
    @AuraEnabled
    public static void recordsApproval(string selectedProgramName, string selectedStatusName, string selectedBusinessLine, string selectedYear){
        List<Program_Brands_Item__c> pbiList = new List<Program_Brands_Item__c>(); 
        user uInfo =[SELECT id,Name,is_TAU_User__c,Is_TAU_Admin__c, profile.name FROM User WHERE id=:userInfo.getUserId()];
        system.debug('selectedProgramName'+selectedProgramName);
         system.debug('selectedStatusName'+selectedStatusName); 
        system.debug('selectedBusinessLine'+selectedBusinessLine);
         system.debug('selectedYear'+selectedYear);
        if(uInfo.is_TAU_User__c == true && uInfo.Is_TAU_Admin__c == false){
            pbiList= [SELECT id,Status_of_Approval__c, Year__c FROM Program_Brands_Item__c 
                      WHERE Program_Name__c =: selectedProgramName 
                      AND Status_of_Approval__c =:System.Label.ABI_OP_SubmitForApproval
                      AND Business_Line__c=:selectedBusinessLine 
                      AND Year__c=:selectedYear ];
        }else if(uInfo.is_TAU_User__c == false && uInfo.Is_TAU_Admin__c == true){
            pbiList= [SELECT id,Status_of_Approval__c,Business_Line__c 
                      FROM Program_Brands_Item__c 
                      WHERE Program_Name__c =: selectedProgramName 
                      AND Status_of_Approval__c =:selectedStatusName
                      AND Business_Line__c=:selectedBusinessLine
                      AND Year__c=:selectedYear  ];
        }
        system.debug('pbiList----'+pbiList);
        for(Program_Brands_Item__c pbi:pbiList){
            pbi.Status_of_Approval__c = System.Label.ABI_OP_ApprovedStatus;
        }
        try {
            upsert pbiList;
        } catch (Exception e) {
            System.debug('#####  ' + e.getMessage());
            throw new AuraHandledException('Error while Updating records' + e.getMessage());
        }  
        
        List<Program_Brands_Item__c> usrLst = [SELECT OwnerId FROM Program_Brands_Item__c WHERE Program_Name__c=:selectedProgramName];
        Set<id> setOfUser = new Set<id>();
        for(Program_Brands_Item__c pbi :usrLst){
            setOfUser.add(pbi.OwnerId);
        }
        List<User> recepientLst = [SELECT id,email,is_TAU_User__c,Is_TAU_Admin__c FROM User 
                                   WHERE is_TAU_User__c = true
                                   AND Is_TAU_Admin__c = false AND id IN:setOfUser
                                  ];
        
        System.debug('recipientLst===============>'+recepientLst);
        List<string> toAddress = new List<string>();
        
        for(integer i=0;i<recepientLst.size();i++){
            toAddress.add(recepientLst[i].email);
        }
        string url = System.Label.ProgramBrandItemURL ;//+'/programName='+selectedProgramName+'&Status='+selectedStatusName;
        System.debug('toAddress===============>'+toAddress);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setSubject('Records Approved');
        mail.setHtmlBody('The following program has been Approved :</br>' +' '+ selectedProgramName + '</br>'+
                         'To check the status, <a href='+url+'>click here.</a>');
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        try {
            Messaging.sendEmail(allmsg,false);   
            return;
        } catch (Exception e) {
            System.debug('#### exception in approving records #### ' + e.getMessage());
            throw new AuraHandledException('Error While approving records ' + e.getMessage());
        }  
    }
    /***
* @Method Name	    recordsRejection
* @Author			Nupur Renwal
* @CreatedDate		09-19-2019
* @Description		apex method to fetch wrapper of list view
*/
    @AuraEnabled
    public static void recordsRejection(string selectedProgramName, string comments,string selectedStatusName, string selectedBusinessLine, string selectedYear){
        System.debug('-----------------Rejection comment------------------------------------'+comments);
        List<Program_Brands_Item__c> pbiList = new List<Program_Brands_Item__c>();
        if(selectedStatusName == System.Label.ABI_OP_SubmitForApproval){
            pbiList= [SELECT id,Status_of_Approval__c FROM Program_Brands_Item__c
                      WHERE Program_Name__c =: selectedProgramName 
                      AND Status_of_Approval__c =:System.Label.ABI_OP_SubmitForApproval
                      AND Business_Line__c=:selectedBusinessLine
                      AND Year__c=:selectedYear ];
            for(Program_Brands_Item__c pbi:pbiList){
                pbi.rejectionComment__c = comments;  
                pbi.Status_of_Approval__c = System.Label.ABI_OP_RejectedStatus;
                
            }
            upsert pbiList;
        }
        if(selectedStatusName == System.Label.ABI_OP_LoadedStatus){
            pbiList= [SELECT id,Status_of_Approval__c,Business_Line__c FROM Program_Brands_Item__c
                      WHERE Program_Name__c =: selectedProgramName 
                      AND Status_of_Approval__c =:System.Label.ABI_OP_LoadedStatus
                      AND Business_Line__c =:selectedBusinessLine
                      AND Year__c=:selectedYear ];
            
            
            for(Program_Brands_Item__c pbi:pbiList){
                pbi.rejectionComment__c = comments;   pbi.Status_of_Approval__c = System.Label.ABI_OP_RejectedStatus;
                
            }
            upsert pbiList;
        }
        
        List<Program_Brands_Item__c> usrLst = [SELECT OwnerId 
                                               FROM Program_Brands_Item__c 
                                               WHERE Program_Name__c=:selectedProgramName
                                               AND Status_of_Approval__c =:System.Label.ABI_OP_LoadedStatus
                                               AND Business_Line__c =:selectedBusinessLine
                                               AND Year__c=:selectedYear ];
        Set<id> setOfUser = new Set<id>();
        for(Program_Brands_Item__c pbi :usrLst){
            setOfUser.add(pbi.OwnerId);
        }
        List<User> recepientLst = [SELECT id,email,is_TAU_User__c,Is_TAU_Admin__c FROM User 
                                   WHERE is_TAU_User__c = true
                                   AND Is_TAU_Admin__c = false AND Id IN:setOfUser
                                  ];
        //Program_Brands_Item__c pbi= [SELECT id FROM Program_Brands_Item__c];
        System.debug('recipientLst===============>'+recepientLst);
        List<string> toAddress = new List<string>();
        
        for(integer i=0;i<recepientLst.size();i++){  toAddress.add(recepientLst[i].email);
                                                  }
        string url = System.Label.ProgramBrandItemURL;
        
        System.debug('toAddress===============>'+toAddress);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setSubject('Records Rejected');
        mail.setHtmlBody('The following program has been rejected :</br>' +' '+ selectedProgramName + '</br>'+
                         'To check the rejection reason, <a href='+url+'>click here.</a>');
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        System.debug('allmsg==========>'+allmsg);
        
        try {
            Messaging.sendEmail(allmsg,false);   
            
            System.debug('mail sent==========>');
            return;
        } catch (Exception e) {
            
            System.debug(e.getMessage());
        }  
    }
    
    /***
* @Method Name	    submitRecordsForApproval
* @Author			Ankita Sarda
* @CreatedDate		09-19-2019
* @Description		apex method to fetch wrapper of list view
*/
    @AuraEnabled
    public static void submitRecordsForApproval(string selectedProgramName,string selectedStatus, string selectedBusinessLine, string selectedYear){
        
        List<Program_Brands_Item__c> pbiList = new List<Program_Brands_Item__c>();
        pbiList = [SELECT id,Status_of_Approval__c,Business_Line__c FROM Program_Brands_Item__c 
                   WHERE Program_Name__c =: selectedProgramName
                   AND Business_Line__c=:selectedBusinessLine 
                   AND Year__c=:selectedYear
                  ];   
        
        
        System.debug('pbiList===============>'+pbiList);
        
        for(Program_Brands_Item__c pbi:pbiList){
            pbi.Status_of_Approval__c = System.Label.ABI_OP_SubmitForApproval;
        }
        try{
            if(!Schema.sObjectType.Program_Brands_Item__c.isCreateable()){
                throw new AuraHandledException('User does not have sufficient Permission to complete the operation');   
            }
            else{
                upsert pbiList;
            }
        }catch(DmlException e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        List<User> recepientLst = [SELECT id,email,is_TAU_User__c,Is_TAU_Admin__c FROM User 
                                   WHERE is_TAU_User__c = false
                                   AND Is_TAU_Admin__c = true];
        //Program_Brands_Item__c pbi= [SELECT id FROM Program_Brands_Item__c];
        System.debug('recipientLst===============>'+recepientLst);
        List<string> toAddress = new List<string>();
        
        for(integer i=0;i<recepientLst.size();i++){
            toAddress.add(recepientLst[i].email);
        }
        string url = System.Label.ProgramBrandItemURL;//+'?programName='+selectedProgramName+'&Status='+selectedStatus;
        //+'/programName='+selectedProgramName+'&Status='+selectedStatusName;
        //toAddress.add(recepientLst.email);
        System.debug('url===============>'+url);
        // EmailTemplate et = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'Program_Sent_for_Approval'];
        // System.debug('et===============>'+et);     
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //mail.setTemplateId(et.Id);
        mail.setToAddresses(toAddress);
        mail.setSubject('Program Approval Request');
        mail.setHtmlBody('The following program needs your Approval :</br>' +' '+ selectedProgramName + '</br>'+
                         'To approve <a href='+url+'>click here.</a>');
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        System.debug('allmsg==========>'+allmsg);
        
        try {
            Messaging.sendEmail(allmsg,false);   
            
            System.debug('mail sent==========>');
            return;
        } catch (Exception e) {
            
            System.debug(e.getMessage());
        }  
    }
    
    
    /***
* @Method Name	    deleteRecord
* @Author			Cognizant Developers
* @CreatedDate		09-19-2019
* @Description		method to delete record from preview page.
Objects Brand,Toolkit and Item. 
*/
    @AuraEnabled
    Public static void deleteRecord(Id recordId){
        
        List<Program_Brands_Item__c>  LstProgramBrandItems = [select id from Program_Brands_Item__c where id =:recordId ];
        try{
            delete LstProgramBrandItems;
        }catch(DmlException e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }
    
    
    
    /***
* @Method Name	    PushToOnPlan1
* @Author			Ankita Sarda
* @CreatedDate		09-19-2019
* @Description		Method to Push Data from Staging Object Program Brands Item to Onplan
Objects Brand,Toolkit and Item.
*/    
    @AuraEnabled
    Public static list<Program_Brands_Item__c> PushToOnPlan1(List<Id> IdList){
        system.debug('test1'+IdList);
        
        List<Program_Brands_Item__c> LstProgramBrandItems= [SELECT ID,Is_Program_Only__c,SAP_Item_Number__c,CurrencyIsoCode,Brand_Name__c,Business_Line__c,Program_Name__c,Status_of_Approval__c,
                                                            Year__c,Full_Price_to_Rep__c,IH_Item_Classification__c,West__c,Quebec__c,Atlantic__c,Ontario__c,User_Paid__c,Image_Link__c,
                                                            Is_Available__c,Is_IH_Only__c,Item_Description_EN__c,Item_Description_FR__c,Item_Type__c,Language__c,	
                                                            Menu_Category__c,OOH_Item_Classification__c,Planning_End_Date__c,Planning_Start_Date__c,Product_Name__c,
                                                            Program_Descritpion__c,Program_End_Date__c,Program_Start_Date__c,Quantity_per_UOM__c ,Temp_Item_Number__c,Unit_of_Measure__c,
                                                            Standard_Price__c,Size__c,Product_Type__c,Parent_Product_Types__c,Item_Classification__c 
                                                            FROM Program_Brands_Item__c 
                                                            WHERE Status_of_Approval__c = :System.Label.ABI_OP_ApprovedStatus AND Id IN:IdList];
        System.debug('***program brand items***'+LstProgramBrandItems);
        
        ///* to insert the brand if user paid in true*********
        list<Brand__c> brandlstUserPaid = new list<Brand__c>();
        set<Brand__c> setUserPaidBrand = new set<Brand__c>();
        Id devRecordTypeId = Schema.SObjectType.Brand__c.getRecordTypeInfosByName().get('Trade Activation').getRecordTypeId(); 
        system.debug('devRecordTypeId'+devRecordTypeId);
        for(Program_Brands_Item__c pbilst : LstProgramBrandItems){
            if(pbilst.User_Paid__c == true){
                Brand__c brand = new Brand__c();
                brand.RecordTypeId = devRecordTypeId;
                brand.User_Paid__c = true;
                brand.Name = pbilst.Program_Name__c ;
                brand.Brand_Name_External_Id__c = pbilst.Program_Name__c;
                brand.OnPoint_Brand_Name__c = pbilst.Brand_Name__c;
                //brandlstUserPaid.add(brand);
                setUserPaidBrand.add(brand);
            }
            system.debug('setUserPaidBrand'+setUserPaidBrand);
        }
        brandlstUserPaid.addAll(setUserPaidBrand);
        system.debug('brandlstUserPaid'+brandlstUserPaid);
        Database.UpsertResult [] UserPaidBrandsresults = Database.Upsert(brandlstUserPaid,Brand__c.Brand_Name_External_Id__c, false);
        system.debug('UserPaidBrandsresults'+UserPaidBrandsresults);
        
        list<Brand__c> brandLst = [Select Id,Name,OnPoint_Brand_Name__c,User_Paid__c from Brand__c];
        
        Map<String,String> mapBrandId = new Map<String,String>();
        Map<String,String> mapOnpointBrandId = new Map<String,String>();
        for(Brand__c brnd :brandLst ){
            mapBrandId.put(brnd.Name,brnd.Id);
            mapOnpointBrandId.put(brnd.OnPoint_Brand_Name__c,brnd.Id);
        }  
        system.debug('mapBrandId'+mapBrandId);
        //*************************Marketing_Program__c toolkit/ Program*************************
        
        List<Marketing_Program__c> LstToolKits = new List<Marketing_Program__c>(); 
        Set<String> setToolKitName = new Set<String>();
        
        for(Program_Brands_Item__c pbic : LstProgramBrandItems){
            Marketing_Program__c mktprog = new Marketing_Program__c();
            if(pbic.User_Paid__c == false){
                if(mapBrandId.containsKey(pbic.Brand_Name__c)){
                    system.debug('Test 4');
                    mktprog.Brand__c = mapBrandId.get(pbic.Brand_Name__c);
                }
            }
            if(pbic.User_Paid__c == true){
                if(mapBrandId.containsKey(pbic.Program_Name__c)){
                    system.debug('Test 4');
                    mktprog.Brand__c = mapBrandId.get(pbic.Program_Name__c);
                }
            }   
            mktprog.CurrencyIsoCode = pbic.CurrencyIsoCode;
            mktprog.Business_Line__c = pbic.Business_Line__c;
            
            mktprog.Planning_End_Date__c = Date.ValueOf(pbic.Planning_End_Date__c);
            //console.log(pbic.Planning_End_Date__c);
            mktprog.Planning_Start_Date__c = Date.ValueOf(pbic.Planning_Start_Date__c);
            mktprog.Program_Start_Date__c = Date.ValueOf(pbic.Program_Start_Date__c);//08/15/2021 MM/DD/
            mktprog.Program_End_Date__c = Date.ValueOf(pbic.Program_End_Date__c);//11/29/2021
            mktprog.Program_Information_EN__c = pbic.Program_Descritpion__c;
            mktprog.Name = pbic.Program_Name__c;
            if(pbic.User_Paid__c == true){
                mktprog.Is_User_Paid__c = true;
            }
            
            if(pbic.User_Paid__c == false){
                mktprog.Is_User_Paid__c = false;
            }
            if(pbic.User_Paid__c == true){
                mktprog.Is_User_Paid__c = true;
            }
            if(pbic.User_Paid__c == true){
                mktprog.ABI_OP_User_Paid__c = true;
            }
            if(pbic.User_Paid__c == false){
                mktprog.ABI_OP_User_Paid__c = false;
            }
            mktprog.External_Id_Toolkit_Name__c = pbic.Program_Name__c+'_'+pbic.Business_Line__c+'_'+pbic.User_Paid__c;
            
            
            if(!setToolKitName.contains(mktprog.External_Id_Toolkit_Name__c)){
                setToolKitName.add(mktprog.External_Id_Toolkit_Name__c); 
                LstToolKits.add(mktprog);
            }
            system.Debug('LstToolKits'+LstToolKits);
        }
        Schema.SObjectField MPextId = Marketing_Program__c.External_Id_Toolkit_Name__c;
        try{
            //Database.UpsertResult [] MPresults = Database.Upsert(LstToolKits,MPextId, false);
            //system.debug('MPresultstest'+MPresults);
            if(!Schema.sObjectType.Marketing_Program__c.isCreateable()){
                throw new AuraHandledException('User does not have sufficient Permission to complete the operation');   
            }
            else{
                Database.UpsertResult [] MPresults = Database.Upsert(LstToolKits,MPextId, false);
            }
            
        }catch(DmlException e){ throw new AuraHandledException('Please Contact your Admin: Something went wrong while Saving toolkit record'+ e.getMessage());
                              }
        
        //################ Item ###########################
        
        List<Marketing_Item__c> LstItems = new List<Marketing_Item__c>();
        for(Program_Brands_Item__c pbic : LstProgramBrandItems){
            Marketing_Item__c mktItem = new Marketing_Item__c();
            //mktItem.Brand__c = mapBrandId.get(pbic.Brand_Name__c);
            /*  if(pbic.User_Paid__c == false){
if(mapBrandId.containsKey(pbic.Brand_Name__c)){
system.debug('Test 4');
mktItem.Brand__c = mapBrandId.get(pbic.Brand_Name__c);
}
}
if(pbic.User_Paid__c == true){*/
            if(mapBrandId.containsKey(pbic.Brand_Name__c)){
                system.debug('Test 4');
                mktItem.Brand__c = mapBrandId.get(pbic.Brand_Name__c);
            }
            
            
            if(pbic.Quebec__c == true){
                mktItem.Is_Quebec_Only__c = true;
            }
            if(pbic.Quebec__c == false){
                mktItem.Is_Quebec_Only__c = false;
            }
            
            mktItem.CurrencyIsoCode = pbic.CurrencyIsoCode;
            mktItem.Price__c = pbic.Full_Price_to_Rep__c;
            mktItem.Standard_Price__c = pbic.Standard_Price__c;
            mktItem.Marketing_Type__c = pbic.Item_Classification__c;
            mktItem.IH_Item_Classification__c = pbic.Item_Classification__c;
            mktItem.Is_Available__c = pbic.Is_Available__c;
            if(pbic.Is_Program_Only__c == true){
                mktItem.Is_Program_Only__c = true;
            }
            if(pbic.Is_Program_Only__c == false){
                mktItem.Is_Program_Only__c = false;
            }
            //mktItem.Is_Program_Only__c =  pbic.Is_Program_Only__c;
            mktItem.Is_Quebec_Only__c = pbic.Quebec__c;
            mktItem.Item_Description_EN__c = pbic.Item_Description_EN__c;
            mktItem.Item_Description_FR__c = pbic.Item_Description_FR__c;
            mktItem.Name = pbic.Product_Name__c;
            mktItem.Temporary_Item_Number__c = pbic.Temp_Item_Number__c;
            mktItem.Item_Number__c = pbic.SAP_Item_Number__c; 
            mktItem.Item_Type_EN__c = pbic.Item_Type__c;
            mktItem.Item_Unit_of_Measure__c = pbic.Unit_of_Measure__c;
            mktItem.Language__c = pbic.Language__c;
            mktItem.Menu_Category__c = pbic.Menu_Category__c;
            mktItem.Quantity_Per_UOM__c = pbic.Quantity_per_UOM__c;
            mktItem.Items_Parent_Product_Types__c = pbic.Parent_Product_Types__c;
            mktItem.Items_Product_Type__c = pbic.Product_Type__c;
            mktItem.Size__c = pbic.Size__c;
            
            LstItems.add(mktItem);
        }    
        List<Marketing_Item__c> LstItemsTemp = new List<Marketing_Item__c>();
        List<Marketing_Item__c> LstItemsSAP = new List<Marketing_Item__c>();
        //map to get a unique set of records and Ids
        // Map<list<Marketing_Item__c>, >() mapItemRecordsSapID = new 
        //Map<>() mapItemRecordsTempID= 
        for(Marketing_Item__c ls : LstItems){
            if(String.isBlank(ls.Item_Number__c)){
                LstItemsTemp.add(ls);
            }
            else{
                LstItemsSAP.add(ls);
            }
        }
        
        system.debug('LstItemsSAP'+LstItemsSAP);
        system.debug('LstItemsTemp'+LstItemsTemp);
        Schema.SObjectField extIdItem1 = Marketing_Item__c.Item_Number__c; 
        Schema.SObjectField extIdItem2 = Marketing_Item__c.Temporary_Item_Number__c; 
        try{
            if(!Schema.sObjectType.Marketing_Item__c.isCreateable()){
                throw new AuraHandledException('User does not have sufficient Permission to complete the operation');   
            }
            else{
                Database.UpsertResult [] resultsItem = Database.Upsert(LstItemsSAP,extIdItem1, false);
                system.debug('resultsItem'+resultsItem);
                Database.UpsertResult [] resultsItem2 = Database.Upsert(LstItemsTemp,extIdItem2, false);
                system.debug('resultsItem2'+resultsItem2);
            }
        }catch(DmlException e){ 
            throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record '+ e.getMessage());
        }
        //################ Toolkit Items ###########################.// mapping of temp items pending
        
        Map<String,String> mapProgId = new Map<String,String>();
        // for toolkit, LstToolKits
        // for items LstItemsTemp && LstItemsSAP
        // list<Marketing_Program__c> listMrkProgItems = [Select Id,Name,Brand__c,External_Id_Toolkit_Name__c from Marketing_Program__c];
        // for(Marketing_Program__c prog : listMrkProgItems ){ 
        for(Marketing_Program__c prog : LstToolKits ){ 
            system.debug('test 1'+prog.Name +' '+ prog.id);
            mapProgId.put(prog.Name+'_'+prog.Business_Line__c,prog.Id);
        }
        system.debug('mapProgId-------'+mapProgId);
        Map<String,String> mapItemId = new Map<String,String>();
        // for(Marketing_Item__c items : [Select Id,Item_Number__c,Temporary_Item_Number__c from Marketing_Item__c]){ 
        for(Marketing_Item__c items : LstItemsTemp){ 
            system.debug('test 2'+items.Id+' '+items.Item_Number__c);
            if(items.Item_Number__c == null || items.Item_Number__c == ''){  mapItemId.put(items.Temporary_Item_Number__c,items.Id);
                                                                          }
        }
        for(Marketing_Item__c items : LstItemsSAP){ 
            system.debug('test 2'+items.Id+' '+items.Item_Number__c);
            if(items.Temporary_Item_Number__c == null || items.Temporary_Item_Number__c == ''){
                mapItemId.put(items.Item_Number__c,items.Id);
            }
        }
        system.debug('mapItemId-------'+mapItemId);
        
        /*********** inserting Toolkit Items **************/
        List<Marketing_Program_Item__c> lstMktProgItem = new List<Marketing_Program_Item__c>();
        boolean isUserPaid = false;
        String userPaidYear;
        for(Program_Brands_Item__c pbi : LstProgramBrandItems)
        {
            Marketing_Program_Item__c mpi =new Marketing_Program_Item__c();
            if(pbi.SAP_Item_Number__c == null || pbi.SAP_Item_Number__c == ''){
                mpi.Marketing_Item__c = mapItemId.get(pbi.Temp_Item_Number__c);
            }
            if(pbi.Temp_Item_Number__c == null || pbi.Temp_Item_Number__c == ''){
                mpi.Marketing_Item__c = mapItemId.get(pbi.SAP_Item_Number__c);
            }
            
            mpi.Marketing_Program__c = mapProgId.get(pbi.Program_Name__c+'_'+pbi.Business_Line__c);
            
            if(pbi.User_Paid__c == false){
                if(pbi.SAP_Item_Number__c == '' || pbi.SAP_Item_Number__c == null){
                    mpi.ExternalKey__c = pbi.Program_Name__c+'_'+ pbi.Temp_Item_Number__c+'_'+ pbi.Business_Line__c;
                }else if(pbi.Temp_Item_Number__c == '' || pbi.Temp_Item_Number__c == null){
                    mpi.ExternalKey__c = pbi.Program_Name__c+'_'+pbi.SAP_Item_Number__c+'_'+ pbi.Business_Line__c; 
                }
            }
            if(pbi.User_Paid__c == true){
                isUserPaid = true;
                userPaidYear = pbi.Year__c;
                if(pbi.SAP_Item_Number__c == '' || pbi.SAP_Item_Number__c == null){
                    mpi.ExternalKey__c = pbi.Program_Name__c+'_'+pbi.Program_Name__c+'_'+ pbi.Temp_Item_Number__c+'_'+ pbi.Business_Line__c; 
                }else  if(pbi.Temp_Item_Number__c == '' || pbi.Temp_Item_Number__c == null){
                    mpi.ExternalKey__c = pbi.Program_Name__c+'_'+pbi.Program_Name__c+'_'+ pbi.SAP_Item_Number__c+'_'+ pbi.Business_Line__c ; 
                }
            }
            
            lstMktProgItem.add(mpi);
        }
        system.debug('lstMktProgItem'+lstMktProgItem);
        Schema.SObjectField MPTextId = Marketing_Program_Item__c.ExternalKey__c; 
        system.debug(' Marketing_Program_Item__c.ExternalKey__c'+ MPTextId);
        
        Database.UpsertResult [] MPTresults;
        
        try{
        MPTresults = Database.Upsert(lstMktProgItem,Marketing_Program_Item__c.ExternalKey__c,false);
        }
        catch(DmlException e){
            throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record '+ e.getMessage());
        }
        system.debug('MPTresults'+MPTresults);
        
        // Update territory budget for user Paid Brand Budget creation
        if(isUserPaid==true)
        {
         Database.executeBatch(new TerritoryBudgetUpdateBatch(userPaidYear),10);   
        }
        
        
        /**************to change status to completed or failed ***********/
        
        list<Program_Brands_Item__c> pbStatsUpdate = new list<Program_Brands_Item__c>();
        for(Integer index = 0, size = MPTresults.size(); index < size; index++) {
            Program_Brands_Item__c pbiObj = new Program_Brands_Item__c();
            if(MPTresults[index].isSuccess()) {  
                system.debug('MPTresults[index]'+MPTresults[index].isSuccess());
                pbiObj.Status_of_Approval__c = System.Label.ABI_OP_CompletedStatus;
                pbiObj.External_Id_for_PBI__c = lstMktProgItem[index].ExternalKey__c;
            }else{
                pbiObj.Status_of_Approval__c = System.Label.ABI_OP_FailedStatus;
                pbiObj.External_Id_for_PBI__c = lstMktProgItem[index].ExternalKey__c;
            }
            pbStatsUpdate.add(pbiObj);
        }
        system.debug('pbStatsUpdate'+lstMktProgItem);
        //Database.UpsertResult [] statusUpdate = Database.upsert(pbStatsUpdate, Program_Brands_Item__c.External_Id_for_PBI__c,false);
        
        //system.debug('statusUpdate'+statusUpdate);
        try{
            if(!Schema.sObjectType.Program_Brands_Item__c.isCreateable()){
                throw new AuraHandledException('User does not have sufficient Permission to complete the operation');   
            }
            else{
                Database.UpsertResult [] statusUpdate = Database.upsert(pbStatsUpdate, Program_Brands_Item__c.External_Id_for_PBI__c,false);
            }
        }catch(DmlException e){
            throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record '+ e.getMessage());
        }
        /****Product Restriction Insert****/
        //Atlantic - 90041 \\ Ontario - 20186 \\ Quebec - 1 \\ west - 31685
        Map<string,List<OnPoint_District__c>> mapOfItemIdandRegion =  new Map<string,List<OnPoint_District__c>>();
        List<OnPlan_Product_Restriction__c> lstOnPlan_ProdRestriction = new list<OnPlan_Product_Restriction__c>();
        Map<string, List<OnPoint_District__c>> mapOfCodeAndDistrict = new Map<string, List<OnPoint_District__c>>();
        Map<String, ABI_OP_District_Codes__c> mapRegionCodes = ABI_OP_District_Codes__c.getAll();
        system.debug('mapRegionCodes----'+mapRegionCodes);
        // system.debug('mapRegionCodesatlantice'+mapRegionCodes.get('Atlantic Region Code').Region_Code__c);
        ABI_OP_District_Codes__c varObj = new ABI_OP_District_Codes__c();
        
        /* inserting Atlantic */
        list<String> atlanticRegionLst = new list<String>();
        
        for(OnPoint_District__c objOPD:[select Name,Region_Code__c,Region_Description__c,District_Code__c FROM OnPoint_District__c])
        {
            if(mapOfCodeAndDistrict.containsKey(objOPD.Region_Code__c)) {
                List<OnPoint_District__c> opdList= mapOfCodeAndDistrict.get(objOPD.Region_Code__c);
                opdList.add(objOPD);
                mapOfCodeAndDistrict.put(objOPD.Region_Code__c,opdList);
            }
            else{
                mapOfCodeAndDistrict.put(objOPD.Region_Code__c, new List<OnPoint_District__c> { objOPD });
            }
            // mapOfRegionCode.put(objOPD.Region_Description__c, objOPD.Region_Code__c);
            
        }
        Map<string, Marketing_Item__c> mapListOfItem=new MAP<string, Marketing_Item__c>();
        /*using the already inserted list of Marketing Items here */
        // for items LstItemsTemp && LstItemsSAP
        // for(Marketing_Item__c objMIT:[select id,Name from Marketing_Item__c]){
        for(Marketing_Item__c objMIT:LstItemsTemp){
            mapListOfItem.put(objMIT.Name, objMIT);
        }
        for(Marketing_Item__c objMIT:LstItemsSAP){
            mapListOfItem.put(objMIT.Name, objMIT);
        }
        system.debug('mapListOfItemProductRestriction'+mapListOfItem);
        system.debug('mapOfCodeAndDistrict'+mapOfCodeAndDistrict);
        Map<string, List<Program_Brands_Item__c>> mapOfAtlantaRestProduct = new Map<string, List<Program_Brands_Item__c>>();
        
        for(Program_Brands_Item__c pbidistrict : LstProgramBrandItems){
            if(pbidistrict.Atlantic__c == true){
                system.debug('atlantic is true');
                //   varObj = mapRegionCodes.get('Atlantic Region Code');
                //  list<OnPoint_District__c> lstDst = mapOfCodeAndDistrict.get(varobj.Region_Code__c);
                // system.debug('lstDstAtlantic'+lstDst);
                list<OnPoint_District__c> lstDst = mapOfCodeAndDistrict.get('90041');
                if(lstDst.size() >0 && lstDst != null){
                    for(OnPoint_District__c od: lstDst){
                        OnPlan_Product_Restriction__c prdRest = new OnPlan_Product_Restriction__c();
                        prdRest.Item__c = mapListOfItem.get(pbidistrict.Product_Name__c).id;
                        prdRest.OnPoint_District__c = od.id;
                        prdRest.External_Key_for_PR__c = mapListOfItem.get(pbidistrict.Product_Name__c).id+'_'+od.id;
                        lstOnPlan_ProdRestriction.add(prdRest);
                    }
                }
            }
            if(pbidistrict.Ontario__c == true){
                system.debug('ontario is true');
                //list<OnPoint_District__c> lstDst = mapOfCodeAndDistrict.get(mapRegionCodes.get('Ontario Region Code').Region_Code__c);
               // varObj = mapRegionCodes.get('Ontario Region Code');
               // list<OnPoint_District__c> lstDst = mapOfCodeAndDistrict.get(varobj.Region_Code__c);
                list<OnPoint_District__c> lstDst = mapOfCodeAndDistrict.get('20186');
                if(lstDst.size() >0 && lstDst != null){
                    for(OnPoint_District__c od: lstDst){
                        OnPlan_Product_Restriction__c prdRest = new OnPlan_Product_Restriction__c();
                        prdRest.Item__c = mapListOfItem.get(pbidistrict.Product_Name__c).id;
                        prdRest.OnPoint_District__c = od.id;
                        prdRest.External_Key_for_PR__c = mapListOfItem.get(pbidistrict.Product_Name__c).id+'_'+od.id;
                        lstOnPlan_ProdRestriction.add(prdRest);
                    }
                }
            }
            if(pbidistrict.West__c == true){
                system.debug('west is true');
                // list<OnPoint_District__c> lstDst = mapOfCodeAndDistrict.get(mapRegionCodes.get('West Region Code').Region_Code__c);
               // varObj = mapRegionCodes.get('West Region Code');
               // list<OnPoint_District__c> lstDst = mapOfCodeAndDistrict.get(varobj.Region_Code__c);
               list<OnPoint_District__c> lstDst = mapOfCodeAndDistrict.get('31685');
                if(lstDst.size() >0 && lstDst != null){
                    for(OnPoint_District__c od: lstDst){
                        OnPlan_Product_Restriction__c prdRest = new OnPlan_Product_Restriction__c();
                        prdRest.Item__c = mapListOfItem.get(pbidistrict.Product_Name__c).id;
                        prdRest.OnPoint_District__c = od.id;
                        prdRest.External_Key_for_PR__c = mapListOfItem.get(pbidistrict.Product_Name__c).id+'_'+od.id;
                        lstOnPlan_ProdRestriction.add(prdRest);
                    }
                }
            }
            if(pbidistrict.Quebec__c == true){
                system.debug('quebec is true');
                // list<OnPoint_District__c> lstDst = mapOfCodeAndDistrict.get(mapRegionCodes.get('Quebec Region Code').Region_Code__c);
                //  varObj = mapRegionCodes.get('Quebec Region Code');
                //  list<OnPoint_District__c> lstDst = mapOfCodeAndDistrict.get(varobj.Region_Code__c);	
                list<OnPoint_District__c> lstDst = mapOfCodeAndDistrict.get('1');
                if(lstDst.size() >0 && lstDst != null){
                    for(OnPoint_District__c od: lstDst){
                        OnPlan_Product_Restriction__c prdRest = new OnPlan_Product_Restriction__c();
                        prdRest.Item__c = mapListOfItem.get(pbidistrict.Product_Name__c).id;
                        prdRest.OnPoint_District__c = od.id;
                        prdRest.External_Key_for_PR__c = mapListOfItem.get(pbidistrict.Product_Name__c).id+'_'+od.id;
                        lstOnPlan_ProdRestriction.add(prdRest);
                    }
                }
            }
            
        }
        
        system.debug('lstOnPlan_ProdRestriction'+lstOnPlan_ProdRestriction); 
        //upsert lstOnPlan_ProdRestriction;
        // Database.UpsertResult [] upsertPR = Database.upsert(lstOnPlan_ProdRestriction, OnPlan_Product_Restriction__c.External_Key_for_PR__c,false);
        //system.debug('upsertPR'+upsertPR);
        try{
            if(!Schema.sObjectType.OnPlan_Product_Restriction__c.isCreateable()){
                throw new AuraHandledException('User does not have sufficient Permission to complete the operation');   
            }
            else{
                Database.UpsertResult [] upsertPR = Database.upsert(lstOnPlan_ProdRestriction, OnPlan_Product_Restriction__c.External_Key_for_PR__c,false);
            }
        }catch(DmlException e){
            throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record '+ e.getMessage());
        }
        //***************************Attachment Insert****************************************
        
        system.Debug('*******Inside Attachment Insert Code*********');
        list<string> setOfSAPIds = new list<string>();
        for(Marketing_Item__c var : LstItemsSAP){
            if(var.Item_Number__c != null){
                setOfSAPIds.add(var.Item_Number__c);
            }
        }
        for(Marketing_Item__c var : LstItemsTemp){
            if(var.Temporary_Item_Number__c != null){   
                SYSTEM.debug('var.Temporary_Item_Number__c != null setOfSAPIds');
                setOfSAPIds.add(var.Temporary_Item_Number__c);
            }
        }
        
        system.debug('setOfSAPIds'+setOfSAPIds);
        //can remove this query to optimise // add id list in where clause
        List<Program_Brands_Item__c> lstOfURLs = [Select SAP_Item_Number__c,Image_link__c,Temp_Item_Number__c,Status_of_Approval__c 
                                                  from Program_Brands_Item__c 
                                                  where 
                                                  (SAP_Item_Number__c IN :setOfSAPIds 
                                                   OR  Temp_Item_Number__c IN : setOfSAPIds)
                                                 ];
        
        
        system.debug('lstOfURLs'+lstOfURLs);
        Map<String,String> mapOfURLs = new Map<String,String>();
        for(Program_Brands_Item__c var : lstOfURLs){
            if(var.Image_link__c != null){
                system.debug('var.Image_link__c'+var.Image_link__c);
                if(var.SAP_Item_Number__c != null){
                    mapOfURLs.put(var.SAP_Item_Number__c, var.Image_link__c.substringAfterLast('='));
                }
                if(var.Temp_Item_Number__c != null){ 
                    system.debug('var.Temp_Item_Number__c != null mapOfURLs'+ var.Image_link__c);
                    mapOfURLs.put(var.Temp_Item_Number__c, var.Image_link__c.substringAfterLast('='));
                }
            }
        }
        system.debug('mapOfURLs'+mapOfURLs);
        List<contentVersion> lstCV = new List<contentVersion>([Select id,VersionData,Title from contentVersion where Id IN:mapOfURLs.values()]);
        Map<Id,contentVersion> mapOfCV = new Map<Id,contentVersion>();
        mapOfCV.putAll(lstCV);
        system.debug('mapOfCV'+mapOfCV);
        List<Attachment> lstAtch = new List<Attachment>();
        /*List<Marketing_Item__c> lst1 = new List<Marketing_Item__c>([Select id,Temporary_Item_Number__c,Item_Number__c 
from Marketing_Item__c 
where Item_Number__c IN :setOfSAPIds AND
Temporary_Item_Number__c IN:setOfSAPIds ]); */
        Map<String,String> mapOfItems = new Map<String,String>();
        for(Marketing_Item__c var : LstItemsSAP){
            if(var.Item_Number__c != null){
                mapOfItems.put(var.Item_Number__c, var.Id);
            }
        }
        for(Marketing_Item__c var : LstItemsTemp){
            if(var.Temporary_Item_Number__c != null){  
                mapOfItems.put(var.Temporary_Item_Number__c, var.Id);
            }
        }
        system.debug('mapOfItems---->'+mapOfItems);
        for(String var :setOfSAPIds){
            Attachment atch = new Attachment();
            Id ids;
            system.debug('mapOfURLs.get(var)'+mapOfURLs.get(var));
            if(mapOfURLs.get(var) != 'null'){
                system.debug('inside else');
                ids = Id.valueOf(mapOfURLs.get(var));
                system.debug('ids---->'+ids);
                atch.Body = mapOfCV.get(ids).VersionData;
                atch.Name = mapOfCV.get(ids).Title;
                atch.ParentId = mapOfItems.get(var);
                system.debug('atch.ParentId'+atch.ParentId);
                lstAtch.add(atch);
                system.debug('atch'+lstAtch);
            }
        }
        try{
            if(lstAtch.size() >0){
                system.debug('inserted images');
                Insert lstAtch;
            } 
        }catch(Exception e){
            System.debug('#### exception while images setting #### ' + e.getMessage());
            throw new AuraHandledException('Error While updating item attachments ' + e.getMessage());
        }
        return pbStatsUpdate;
    } 
    
    
}