/***
* @Name				ShoppedKitItemApprovalListView
* @Author			Ragbirendra Upadhyay
* @CreatedDate		09-19-2019
* @Description		This class is used to take data from shopped Kit stagging object and
                    insert or update data in marketing_Kit and Trade Activation Kit Item
                    It also Include data Approval and rejection Logic.
*
***/
public class ShoppedKitItemApprovalListView {
     
   
     /***
    * @Method Name	    listValues
    * @Author			Ragbirendra upadhyay
    * @CreatedDate		09-19-2019
    * @Description		store value in Wrapper class
    */
    @AuraEnabled
    public static list<listViewWrapper> listValues(string objectInfo){
        
        list<listViewWrapper> oListViewWrapper = new list<listViewWrapper>();
        
        for(ListView lv : [SELECT id, Name, DeveloperName FROM ListView
                           WHERE sObjectType = : String.escapeSingleQuotes(objectInfo) ORDER By Name ASC]){ 
                               listViewWrapper oWrapper = new listViewWrapper();
                               oWrapper.label = lv.Name;
                               oWrapper.developerName = lv.DeveloperName;
                               oListViewWrapper.add(oWrapper);
                           }
        
        return oListViewWrapper; 
    }
 
     
    public class listViewWrapper{
        @AuraEnabled public string label{get;set;} 
        @AuraEnabled public string developerName{get;set;} 
    }
    /*** 
    * @Method Name	    getPickListVals
    * @Author			Ragbirendra upadhyay
    * @CreatedDate		09-19-2019
    * @Description		getting record based on picklist value
    */
    @AuraEnabled(cacheable=true)
    public static list<picklistValWrapper> getPickListVals(){
        list<NAZ_OP_Shopkit_Data__c> lst = [Select id ,Shopped_Kit_Name__c,Program_Name__c,Shopkit_Start_Date__c,Status_of_Approval__c,
                                            Shopkit_End_Date__c,Shopkit_SAP_Number__c,Shopkit_Temporary_Item_Numbers__c,
                                            Shopkit_Price__c,Shopkit_Qty__c,ShoppedKitItem__c,Comment__c,Business_Line__c,Year__c from NAZ_OP_Shopkit_Data__c];
        list<picklistValWrapper> oListViewWrapper = new list<picklistValWrapper>();
        
        if(!lst.isEmpty()){
            for(NAZ_OP_Shopkit_Data__c pc:lst){
                picklistValWrapper oWrapper = new picklistValWrapper();
                oWrapper.recordId = pc.id;
                oWrapper.programName = pc.Program_Name__c;
                oWrapper.shopedkitName = pc.Shopped_Kit_Name__c;
                oWrapper.approvalStatus = pc.Status_of_Approval__c;
                oWrapper.shopkitStartDate = pc.Shopkit_Start_Date__c;
                oWrapper.shopkitEndDate = pc.Shopkit_End_Date__c;
                oWrapper.shopkitSAPNumber = pc.Shopkit_SAP_Number__c;
                oWrapper.shopkitTemporaryItemNumbers = pc.Shopkit_Temporary_Item_Numbers__c;
                oWrapper.shopkitPrice = pc.Shopkit_Price__c;
                oWrapper.shopkitQty =pc.Shopkit_Qty__c;
                oWrapper.comment =pc.Comment__c;
                oWrapper.businessLine =pc.Business_Line__c;
                oWrapper.Year =pc.Year__c;
                oListViewWrapper.add(oWrapper);
                
            }
        }
        system.debug('oListViewWrapper'+oListViewWrapper);
        //List<Account> accounts = (List<Account>) JSON.deserialize(s, List<Account>.class);
        
        // return (List<Program_Brands_Item__c>) JSON.deserialize(oListViewWrapper,List<Program_Brands_Item__c>.class) ;
        return oListViewWrapper;
    }
    public class picklistValWrapper{
        @AuraEnabled public string recordId{get;set;} 
        @AuraEnabled public string programName{get;set;} 
        @AuraEnabled public string approvalStatus{get;set;}
        @AuraEnabled public string shopedkitName{get;set;} 
        @AuraEnabled public string shopkitStartDate{get;set;}
        @AuraEnabled public string shopkitEndDate{get;set;} 
        @AuraEnabled public string shopkitSAPNumber{get;set;}
        @AuraEnabled public string shopkitTemporaryItemNumbers{get;set;}
        @AuraEnabled public string shopkitPrice{get;set;}
        @AuraEnabled public decimal shopkitQty{get;set;}
        @AuraEnabled public string comment{get;set;}
        @AuraEnabled public string businessLine{get;set;}
        @AuraEnabled public string Year{get;set;}
    }
    /*** 
    * @Method Name	    getFilteredvals
    * @Author			Ragbirendra upadhyay
    * @CreatedDate		09-19-2019
    * @Description		getting Records based on the value of program name and status name 
    */
    @AuraEnabled(cacheable=true)
    Public static List<picklistValWrapper> getFilteredvals(String selectedProgramName, String selectedStatusName,String selectedChannelName,String selectedYearValue) {
        
        list<NAZ_OP_Shopkit_Data__c>  filteredLst = new List<NAZ_OP_Shopkit_Data__c>();
        User userDetail = [SELECT id,profile.name,is_TAU_User__c,Is_TAU_Admin__c,email FROM User WHERE id=:userInfo.getUserId()];
            if(userDetail.Is_TAU_Admin__c)
            {
                filteredLst = [Select id ,Shopped_Kit_Name__c,Program_Name__c,Shopkit_Start_Date__c,
                               Shopkit_End_Date__c,Shopkit_SAP_Number__c,Shopkit_Temporary_Item_Numbers__c,
                               Shopkit_Price__c,Shopkit_Qty__c,Status_of_Approval__c,Comment__c,Business_Line__c from NAZ_OP_Shopkit_Data__c 
                               WHERE (Program_Name__c=:selectedProgramName AND Status_of_Approval__c =:selectedStatusName and Business_Line__c=:selectedChannelName and Year__c=:selectedYearValue)];
            } 
        else
        {
            filteredLst = [Select id ,Shopped_Kit_Name__c,Program_Name__c,Shopkit_Start_Date__c,
                           Shopkit_End_Date__c,Shopkit_SAP_Number__c,Shopkit_Temporary_Item_Numbers__c,
                           Shopkit_Price__c,Shopkit_Qty__c,Status_of_Approval__c,Comment__c,Business_Line__c from NAZ_OP_Shopkit_Data__c 
                           WHERE (Program_Name__c=:selectedProgramName AND Status_of_Approval__c =:selectedStatusName and Business_Line__c=:selectedChannelName and Year__c=:selectedYearValue )
                           and (LastModifiedById=:userInfo.getUserId() or LastModifiedBy.Is_TAU_Admin__c=true)];
            
        }
        System.debug('filteredLst'+filteredLst);
        list<picklistValWrapper> oListViewWrapper = new list<picklistValWrapper>();
        if(!filteredLst.isEmpty()){
            for(NAZ_OP_Shopkit_Data__c pc:filteredLst){
                picklistValWrapper oWrapper = new picklistValWrapper();
                oWrapper.recordId = pc.id;
                oWrapper.programName = pc.Program_Name__c;
                oWrapper.approvalStatus = pc.Status_of_Approval__c;
                oWrapper.shopedkitName = pc.Shopped_Kit_Name__c;
                oWrapper.shopkitStartDate = pc.Shopkit_Start_Date__c;
                oWrapper.shopkitEndDate = pc.Shopkit_End_Date__c;
                oWrapper.shopkitSAPNumber = pc.Shopkit_SAP_Number__c;
                oWrapper.shopkitTemporaryItemNumbers = pc.Shopkit_Temporary_Item_Numbers__c;
                oWrapper.shopkitPrice = pc.Shopkit_Price__c;
                oWrapper.shopkitQty = pc.Shopkit_Qty__c;
                oWrapper.comment = pc.Comment__c;
                oWrapper.businessLine =pc.Business_Line__c;
               
                oListViewWrapper.add(oWrapper);
            }
        }
        return oListViewWrapper;
    }
   /*** 
    * @Method Name	    FetchUserInfo
    * @Author			Ragbirendra upadhyay
    * @CreatedDate		09-19-2019
    * @Description		Fetch User Info
    */
    @AuraEnabled
    public static user FetchUserInfo(){
        user userInfo =[SELECT id,profile.name,is_TAU_User__c,Is_TAU_Admin__c FROM User WHERE id=:userInfo.getUserId()];
        System.Debug('userInfo=======>'+userInfo);
        return userInfo;
    }
    /*** Done
    * @Method Name	    recordsApproval
    * @Author			Ragbirendra upadhyay
    * @CreatedDate		09-19-2019
    * @Description		records Approval
    */
    @AuraEnabled
    public static void recordsApproval(String selectedProgramName,String selectedStatusName, string selectedChannelName,String selectedYearName){
        system.debug('selectedProgramName::'+selectedProgramName);
        system.debug('selectedStatusName::'+selectedStatusName);
        system.debug('selectedChannelName::'+selectedChannelName);
        system.debug('selectedYearName::'+selectedYearName);
        Id id1;List<NAZ_OP_Shopkit_Data__c> pbiList;
        List<User> usr = [SELECT id,email,is_TAU_User__c,Is_TAU_Admin__c FROM User where id=:userInfo.getUserId()];
        pbiList= [SELECT id ,ownerId, Status_of_Approval__c FROM NAZ_OP_Shopkit_Data__c WHERE Program_Name__c =:selectedProgramName and Status_of_Approval__c =:System.Label.ABI_OP_SubmitForApproval AND Business_Line__c =:selectedChannelName  AND  Year__c =: selectedYearName];
        if(usr.size()>0 && usr[0].Is_TAU_Admin__c == true && pbiList.size()==0){
            pbiList= [SELECT id ,ownerId,Business_Line__c, Status_of_Approval__c FROM NAZ_OP_Shopkit_Data__c 
                      WHERE  Program_Name__c =:selectedProgramName 
                      AND (Status_of_Approval__c =:System.Label.ABI_OP_LoadedStatus OR Status_of_Approval__c='Rejected' or Status_of_Approval__c='Failed')
                      AND Business_Line__c =:selectedChannelName 
                      AND  Year__c =: selectedYearName ];
        }
        if(pbiList.size()>0)
            id1 = pbiList[0].ownerId;
        for(NAZ_OP_Shopkit_Data__c pbi:pbiList){
            
            pbi.Status_of_Approval__c = System.Label.ABI_OP_ApprovedStatus;
            
        }
        upsert pbiList;
        List<User> recepientLst = [SELECT id,email,is_TAU_User__c,Is_TAU_Admin__c FROM User where Id =:id1];
        System.debug('recipientLst===============>'+recepientLst);
        List<string> toAddress = new List<string>();
        
        for(integer i=0;i<recepientLst.size();i++){
            toAddress.add(recepientLst[i].email);
        }
        string url = System.Label.ApprovalURLItemAndShoppedKitItem;
        System.debug('toAddress===============>'+toAddress);
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setSubject('Program Approval Request');
        mail.setHtmlBody('The following Shopped kit program gets Approved :</br>' +' '+ selectedProgramName + '</br>'+
                         'Check Status: <a href='+url+'>click here.</a>');
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        System.debug('allmsg==========>'+allmsg);
        
        try {
            Messaging.sendEmail(allmsg,false);   
            return;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }  
    }
    /*** Done
    * @Method Name	    recordsRejection
    * @Author			Ragbirendra upadhyay
    * @CreatedDate		09-19-2019
    * @Description		records Rejection
    */
    @AuraEnabled
    public static void recordsRejection(String selectedProgramName,String comments,string selectedChannelName,String selectedYearValue){
        Id id1;
        List<User> usr = [SELECT id,email,is_TAU_User__c,Is_TAU_Admin__c FROM User where id=:userInfo.getUserId()];
        
        List<NAZ_OP_Shopkit_Data__c> pbiList;
        pbiList= [SELECT id,ownerId,Status_of_Approval__c,Comment__c FROM NAZ_OP_Shopkit_Data__c WHERE Program_Name__c =:selectedProgramName and Status_of_Approval__c =:System.Label.ABI_OP_SubmitForApproval and Business_Line__c=:selectedChannelName and Year__c=:selectedYearValue];
        if(usr.size()>0 && usr[0].Is_TAU_Admin__c ==true && pbiList.size()==0)
        pbiList= [SELECT id ,ownerId, Status_of_Approval__c 
                  FROM NAZ_OP_Shopkit_Data__c 
                  WHERE Program_Name__c =:selectedProgramName and Status_of_Approval__c =:System.Label.ABI_OP_LoadedStatus and Business_Line__c=:selectedChannelName and Year__c=:selectedYearValue];
       
        if(pbiList.size()>0)
        id1 = pbiList[0].ownerId;
        for(NAZ_OP_Shopkit_Data__c pbi:pbiList){
            
            pbi.Comment__c = comments;
            pbi.Status_of_Approval__c = System.Label.ABI_OP_RejectedStatus;
 
        }
        upsert pbiList;
        
        List<User> recepientLst = [SELECT id,email,is_TAU_User__c,Is_TAU_Admin__c FROM User where Id = : id1];
        //Program_Brands_Item__c pbi= [SELECT id FROM Program_Brands_Item__c];
        System.debug('recipientLst===============>'+recepientLst);
        List<string> toAddress = new List<string>();
        
        for(integer i=0;i<recepientLst.size();i++){
            toAddress.add(recepientLst[i].email);
        }
            string url = System.Label.ApprovalURLItemAndShoppedKitItem;
        System.debug('toAddress===============>'+toAddress);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setSubject('Program Approval Request');
        mail.setHtmlBody('The following Shopped Kit program gets Rejected :</br>' +' '+ selectedProgramName + '</br>'+'Rejection Reason:: '+comments+'</br>'+
                         'For Status: <a href='+url+'>click here.</a>');
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        System.debug('allmsg==========>'+allmsg);
        
        try {
            Messaging.sendEmail(allmsg,false);   
            return;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }  
    }
    /*** Done 
     
    * @Method Name	    ApproveRecords
    * @Author			Ragbirendra upadhyay
    * @CreatedDate		09-19-2019
    * @Description		Approve Records
    */
    @AuraEnabled
    public static void ApproveRecords(string selectedProgramName,string selectedStatusName,string selectedChannelName,String selectedYearValue){
        
        List<NAZ_OP_Shopkit_Data__c> pbiList;
        pbiList= [SELECT id,Status_of_Approval__c FROM NAZ_OP_Shopkit_Data__c WHERE Program_Name__c =: selectedProgramName and Status_of_Approval__c =: selectedStatusName and Business_Line__c=:selectedChannelName and Year__c=:selectedYearValue];
        System.debug('pbiList===============>'+pbiList);
        
        for(integer i=0;i<pbiList.size();i++){
                if(pbiList[i].Status_of_Approval__c==System.Label.ABI_OP_LoadedStatus || pbiList[i].Status_of_Approval__c==System.Label.ABI_OP_RejectedStatus|| pbiList[i].Status_of_Approval__c==System.Label.ABI_OP_FailedStatus)
                {
                pbiList[i].Status_of_Approval__c = System.Label.ABI_OP_SubmitForApproval;
                }  
           }

        system.debug('pbiList::::'+pbiList);
        upsert pbiList;
        
        List<User> recepientLst = [SELECT id,email,is_TAU_User__c,Is_TAU_Admin__c FROM User where Is_TAU_Admin__c = true];
        
        System.debug('recipientLst===============>'+recepientLst);
        List<string> toAddress = new List<string>();
        
        for(integer i=0;i<recepientLst.size();i++){
            toAddress.add(recepientLst[i].email);
        }
        string url = System.Label.ApprovalURLItemAndShoppedKitItem;
        System.debug('toAddress===============>'+toAddress);
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setSubject('Shoppedkit Approval Request');
        mail.setHtmlBody('Shopped Kit needs your Approval :which is Associated with' +' '+ selectedProgramName + '</br>'+
                         'To approve <a href='+url+'>click here.</a>');
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        System.debug('allmsg==========>'+allmsg);
        
        try {
            Messaging.sendEmail(allmsg,false);   
            return;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }  
        
    }
    /*** 
    * @Method Name	    SaveRejectLoadedFailedRecord
    * @Author			Ragbirendra upadhyay
    * @CreatedDate		09-19-2019
    * @Description		Save Reject Loaded Failed Record
    */
    @AuraEnabled
    public static void SaveRejectLoadedFailedRecord(List<picklistValWrapper> saveupdateddata,String selectedSta)
    {
       system.debug('Test 1::'+ saveupdateddata);
        List<NAZ_OP_Shopkit_Data__c> updateStatusList = new List<NAZ_OP_Shopkit_Data__c>();
        List<Id> ids = new List<Id>();
        if(saveupdateddata.size()>0){
            for(picklistValWrapper val:saveupdateddata)
            {
            NAZ_OP_Shopkit_Data__c ShopkitData = new NAZ_OP_Shopkit_Data__c();
            ShopkitData.Id = val.recordId;
             ids.add(val.recordId);
             if(val.shopkitStartDate!=null) {
              ShopkitData.Shopkit_Start_Date__c = val.shopkitStartDate; 
             }
             if(val.shopkitEndDate!=null){
              ShopkitData.Shopkit_End_Date__c = val.shopkitEndDate; 
             }
             if(val.shopkitPrice!=null){
              ShopkitData.Shopkit_Price__c = val.shopkitPrice; 
             }
             if(val.shopkitQty!=null){
              ShopkitData.Shopkit_Qty__c = val.shopkitQty; 
             }
             if(selectedSta == System.Label.ABI_OP_SubmitForApproval) {
             ShopkitData.Status_of_Approval__c = System.Label.ABI_OP_SubmitForApproval;
                 if(val.comment!=null){ShopkitData.Comment__c = val.comment; }
             }
           
             updateStatusList.add(ShopkitData);
            }
            try{
            update updateStatusList;
            }catch(DmlException e){
            throw new AuraHandledException('Please Contact to Admin: Something went wrong while Updating record'+ e.getMessage());
        }
        }
       
    }
    /*** 
    * @Method Name	    ExportShoppedKitRecord
    * @Author			Ragbirendra upadhyay
    * @CreatedDate		09-19-2019
    * @Description		Export Stagging ShoppedKit Record
    */
    /*Used to export custom object Record Based on channel and Year*/
    @AuraEnabled(cacheable=true)
    public static List<string> getStatusData()
    {
        List<String> listValue= new List<String>();
        Set<String> setValue= new SET<String>();
        List<NAZ_OP_Shopkit_Data__c> tradeActivationList=[SELECT  Status_of_Approval__c  FROM NAZ_OP_Shopkit_Data__c];
        for(NAZ_OP_Shopkit_Data__c obj:tradeActivationList)
        {setValue.add(obj.Status_of_Approval__c); 
        }
        listValue.addAll(setValue);
        return listValue;
    }
    @AuraEnabled(cacheable=true)
    public static List<string> getProgramData()
    {
        List<String> listValue= new List<String>();
        Set<String> setValue= new SET<String>();
        List<NAZ_OP_Shopkit_Data__c> tradeActivationList=[SELECT  Program_Name__c FROM NAZ_OP_Shopkit_Data__c ];
        for(NAZ_OP_Shopkit_Data__c obj:tradeActivationList)
        {setValue.add(obj.Program_Name__c); 
        }
        listValue.addAll(setValue);
        return listValue;
    }
    
    @AuraEnabled
    public static List<NAZ_OP_Shopkit_Data__c> ExportShoppedKitRecord(String selectedYrArr,String selectedChannel,String selectedStatus,String selectedProgram )
    {    
        List<NAZ_OP_Shopkit_Data__c> listShoppedKit =[select Shopped_Kit_Name__c,Program_Name__c,Shopkit_Start_Date__c,Shopkit_End_Date__c,Shopkit_Price__c,Shopkit_SAP_Number__c,Shopkit_Temporary_Item_Numbers__c,Shopkit_Qty__c,Year__c,Business_Line__c from NAZ_OP_Shopkit_Data__c where Year__c =:selectedYrArr and Business_Line__c =:selectedChannel and Program_Name__c=:selectedProgram and Status_of_Approval__c=:selectedStatus];
        return listShoppedKit;
    }
   /*================================================================================================
==================================================================================================
******Push to Onplan Method******
Author:     Ragbirendra Upadhyay
Purpose:    Method to Push Data from Staging Object to Onplan
Shopped Kit and shoppedKit Item
==================================================================================================
==================================================================================================*/
    /*** 
    * @Method Name	    PushToOnPlan
    * @Author			Ragbirendra upadhyay
    * @CreatedDate		09-19-2019
    * @Description		push record from stagging object to POC Planning object
    */
    @AuraEnabled
    Public static void PushToOnPlan(List<Id> IdList){
        
         
         List<NAZ_OP_Shopkit_Data__c> LstShopedKitItems= [Select id ,Shopped_Kit_Name__c,Program_Name__c,Shopkit_Start_Date__c,Shopkit_End_Date__c,Shopkit_SAP_Number__c,Shopkit_Temporary_Item_Numbers__c,Shopkit_Price__c,Shopkit_Qty__c,ShoppedKitItem__c,Year__c,Business_Line__c from NAZ_OP_Shopkit_Data__c WHERE Status_of_Approval__c =:System.Label.ABI_OP_ApprovedStatus  AND Id IN:IdList];
         System.debug('***stagging shoppkit items***'+LstShopedKitItems);
         List<Marketing_Kit__c> upsertshopKitList = new List<Marketing_Kit__c>();
         set<String> externalIdSet = new set<String>();
         Id recordTypeId =[SELECT Id FROM RecordType WHERE DeveloperName = 'PreConfigured' AND sObjectType = 'Marketing_Kit__c'].Id;
         List<String> toolKitNameList = new List<String>();
         Map<String,Id> toolKitMap = new Map<String,Id>();
         
         for(NAZ_OP_Shopkit_Data__c a : LstShopedKitItems)
         {
           String toolKitName='';
           toolKitName = a.Program_Name__c;
           toolKitNameList.add(toolKitName);
         }
         List<Marketing_Program__c> toolkitIdList =[select Id , Name,Business_Line__c from Marketing_Program__c where Name IN :toolKitNameList];
         
         for(Marketing_Program__c mp:toolkitIdList)
         {
           toolKitMap.put(mp.name+'_'+mp.Business_Line__c,mp.Id);  
         }
         for(NAZ_OP_Shopkit_Data__c a : LstShopedKitItems)
         {  
             Marketing_Kit__c shopKit         = new Marketing_Kit__c();
             if(externalIdSet.contains(a.Shopped_Kit_Name__c+'_'+a.Program_Name__c+'_'+a.Business_Line__c))
             {
                 continue;
             }
             shopKit.ExternalId__c            = a.Shopped_Kit_Name__c+'_'+a.Program_Name__c+'_'+a.Business_Line__c;
             shopKit.Name                     = a.Shopped_Kit_Name__c+'_'+a.Year__c;
             
             shopKit.Execution_Start_Date__c  = Date.ValueOf(a.Shopkit_Start_Date__c);
             shopKit.Execution_End_Date__c    = Date.ValueOf(a.Shopkit_End_Date__c);
             shopKit.RecordTypeId             = recordTypeId;
             if(toolKitMap.containsKey(a.Program_Name__c+'_'+a.Business_Line__c))
             {
             system.debug('Test 4');
             shopKit.Marketing_Program_Name__c= toolKitMap.get(a.Program_Name__c+'_'+a.Business_Line__c);
             }
             //shopKit.Marketing_Program_Name__c= toolKitMap.get(a.Program_Name__c);
             externalIdSet.add(shopKit.ExternalId__c);
             upsertshopKitList.add(shopKit);
          }
             
         
      try{
          upsert upsertshopKitList ExternalId__c;
        }catch(DmlException e){
            throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record'+ e.getMessage());
        }
        //################ Shopped kit Item ###########################
        
       List<String> shoppedKitExternalKeyList = new List<String>();
       List<String> toolKitItemExternalKeyList = new List<String>();
       List<Trade_Activation_Kit_Item__c> upsertShoppedKitItemList = new List<Trade_Activation_Kit_Item__c>();
      
       Map<String,Id> shoppedKitIdMap = new Map<String,Id>();
       Map<String,Id> toolKitItemIdMap = new Map<String,Id>();
       set<String> externalIdSet1 = new set<String>();
       Map<String,boolean> isUserPaidProgram = new Map<String,boolean>();
        for(Marketing_Program__c mp:[select id,name,ABI_OP_User_Paid__c from Marketing_Program__c where name IN:toolKitNameList])
       {
        isUserPaidProgram.put(mp.name, mp.ABI_OP_User_Paid__c);   
       }
        
      //fetching shopped Kit Id and toolkit item id
       for(NAZ_OP_Shopkit_Data__c a : LstShopedKitItems) 
       {
          String shoppedKitExternalKey='';
          String toolKitItemExternalKey='';
          shoppedKitExternalKey = a.Shopped_Kit_Name__c+'_'+a.Program_Name__c+'_'+a.Business_Line__c;
          //create toolkit item external key
          
           if(a.Shopkit_SAP_Number__c=='' || a.Shopkit_SAP_Number__c==null)
            {
                if(isUserPaidProgram.get(a.Program_Name__c))
                {
                toolKitItemExternalKey =   a.Program_Name__c+'_'+a.Program_Name__c+'_'+a.Shopkit_Temporary_Item_Numbers__c+'_'+a.Business_Line__c;
                }
                else{
                  toolKitItemExternalKey =   a.Program_Name__c+'_'+a.Shopkit_Temporary_Item_Numbers__c+'_'+a.Business_Line__c;  
                }
            }
           
            else if((a.Shopkit_Temporary_Item_Numbers__c=='') || (a.Shopkit_Temporary_Item_Numbers__c==null))
            {
               if( isUserPaidProgram.get(a.Program_Name__c))
               {
                toolKitItemExternalKey =   a.Program_Name__c+'_'+a.Program_Name__c+'_'+a.Shopkit_SAP_Number__c+'_'+a.Business_Line__c;
               }
                else{
                  toolKitItemExternalKey =   a.Program_Name__c+'_'+a.Shopkit_SAP_Number__c+'_'+a.Business_Line__c;   
                }
                
            }
           else{
             //throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record');  
           }
          shoppedKitExternalKeyList.add(shoppedKitExternalKey);
          toolKitItemExternalKeyList.add(toolKitItemExternalKey);
       }
       List<Marketing_Kit__c> shopKitIdList =[select Id , ExternalId__c from Marketing_Kit__c where ExternalId__c IN :shoppedKitExternalKeyList];
       List<Marketing_Program_Item__c> toolKitItemIdList = [select Id , ExternalKey__c from Marketing_Program_Item__c where ExternalKey__c IN :toolKitItemExternalKeyList];
       for(Marketing_Kit__c mk:shopKitIdList)
       {
          shoppedKitIdMap.put(mk.ExternalId__c,mk.Id); 
       }
       for(Marketing_Program_Item__c mpi:toolKitItemIdList)
       {
          toolKitItemIdMap.put(mpi.ExternalKey__c,mpi.Id);  
       }
        
        //upserting record in trade Activation Kit item i.e shopped kit item
        for(NAZ_OP_Shopkit_Data__c b : LstShopedKitItems)
        {
           Trade_Activation_Kit_Item__c shoppedKitItem = new Trade_Activation_Kit_Item__c();
           String tempSAPExternalKey='';
           String externalKeyForKitItem ='';
 
           if(b.Shopkit_SAP_Number__c=='' || b.Shopkit_SAP_Number__c==null )
           {
               externalKeyForKitItem = b.Shopped_Kit_Name__c+'_'+b.Shopkit_Temporary_Item_Numbers__c+'_'+b.Year__c+'_'+b.Business_Line__c;
               if(isUserPaidProgram.get(b.Program_Name__c))
               {
               tempSAPExternalKey =   b.Program_Name__c+'_'+b.Program_Name__c+'_'+b.Shopkit_Temporary_Item_Numbers__c+'_'+b.Business_Line__c;    
               }else{
                 tempSAPExternalKey =   b.Program_Name__c+'_'+b.Shopkit_Temporary_Item_Numbers__c+'_'+b.Business_Line__c;  
               }
                
               
                system.debug('test 5'+tempSAPExternalKey);
           }
           else if(b.Shopkit_Temporary_Item_Numbers__c=='' || b.Shopkit_Temporary_Item_Numbers__c==null)
           {
               externalKeyForKitItem = b.Shopped_Kit_Name__c+'_'+b.Shopkit_SAP_Number__c+'_'+b.Year__c+'_'+b.Business_Line__c;
               if(isUserPaidProgram.get(b.Program_Name__c))
               {
               tempSAPExternalKey =   b.Program_Name__c+'_'+b.Program_Name__c+'_'+b.Shopkit_SAP_Number__c+'_'+b.Business_Line__c;    
               }
               else{
                   tempSAPExternalKey =   b.Program_Name__c+'_'+b.Shopkit_SAP_Number__c+'_'+b.Business_Line__c;  
               }
                
           }
          
            else{
               // throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record 1');
            }
           if(externalIdSet1.contains(externalKeyForKitItem))
           {
               continue;
           }
           if(shoppedKitIdMap.containsKey(b.Shopped_Kit_Name__c+'_'+b.Program_Name__c+'_'+b.Business_Line__c))
           {
            shoppedKitItem.Marketing_Kit__c =  shoppedKitIdMap.get(b.Shopped_Kit_Name__c+'_'+b.Program_Name__c+'_'+b.Business_Line__c); 
           }
           
           if(toolKitItemIdMap.containsKey(tempSAPExternalKey))
           {
             shoppedKitItem.Marketing_Program_Item__c =  toolKitItemIdMap.get(tempSAPExternalKey);
           }
          
           shoppedKitItem.ExternalKey__c = externalKeyForKitItem;
           shoppedKitItem.Item_Price__c  = decimal.valueOf(b.Shopkit_Price__c);
           shoppedKitItem.Quantity__c    = b.Shopkit_Qty__c;
           externalIdSet1.add(externalKeyForKitItem);
           upsertShoppedKitItemList.add(shoppedKitItem);
           system.debug('shoppedKitItem::'+shoppedKitItem.ExternalKey__c);
        }
        
         // upsert upsertShoppedKitItemList ExternalKey__c;
         Database.UpsertResult[] results;
         try{
           results = Database.upsert(upsertShoppedKitItemList, Trade_Activation_Kit_Item__c.ExternalKey__c,false);
         }catch(DmlException e){
            throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record'+ e.getMessage());
         }
          //status update
         String body ='Hi,</br></br>';
         List<NAZ_OP_Shopkit_Data__c> customshoppedKitDataList = new List<NAZ_OP_Shopkit_Data__c>();
         for(Integer index = 0, size = results.size(); index < size; index++) {
         NAZ_OP_Shopkit_Data__c customshoppedKitData = new NAZ_OP_Shopkit_Data__c();
         if(results[index].isSuccess()) {
         body = body + upsertShoppedKitItemList[index].ExternalKey__c +' ----- success </br>';
         customshoppedKitData.Status_of_Approval__c = System.Label.ABI_OP_CompletedStatus;
         customshoppedKitData.externalIdField__c = upsertShoppedKitItemList[index].ExternalKey__c;
         }
         else
         {
           body = body + upsertShoppedKitItemList[index].ExternalKey__c +' ----- error </br>'; 
           customshoppedKitData.Status_of_Approval__c = System.Label.ABI_OP_FailedStatus;
           customshoppedKitData.externalIdField__c = upsertShoppedKitItemList[index].ExternalKey__c;
         }
         customshoppedKitDataList.add(customshoppedKitData);
      }//end of loop*/
        body ='Thanks </br>';
         List<string> emailId = new List<string>();
        List<string> ccEmailId = new List<string>();
        user usr = [select id,email from user where id=:UserInfo.getUserId()];
        emailId.add(usr.email);
        ExcelHeader__mdt[] ccMailList = [select MasterLabel, QualifiedApiName, column_A__c FROM ExcelHeader__mdt where MasterLabel ='cc Mail Id'];
        for(ExcelHeader__mdt eh:ccMailList){
            ccEmailId.add(eh.column_A__c);
        }
       /*
        try{
          Mailutility.sendMail(emailId,ccEmailId,'Shopped Kit Item Load Automation Result',body);
         }catch(DmlException e){
            throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record'+ e.getMessage());
         }*/
  
        try{
          Database.upsert(customshoppedKitDataList, NAZ_OP_Shopkit_Data__c.externalIdField__c,false);
         }catch(DmlException e){
            throw new AuraHandledException('Please Contact to Admin: Something went wrong while Saving record'+ e.getMessage());
         }
    }
}