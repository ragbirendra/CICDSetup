/***
    * @Class Name	    UpdatePOCPlanningItemsCtrl
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		This class is used as the supporting controller for the Aura Component Bundle - UpdatePOCPlanningItemData
    					This code along with the lightning component enables the TA User to edit the fields of selected Item in the POC Planning Setup tool
    */
public with sharing class UpdatePOCPlanningItemsCtrl {
    
      /***
    * @Method Name	    UpdatePOCPlanningItemsCtrl
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Constructor method 
    */
    public UpdatePOCPlanningItemsCtrl() {

    }

      /***
    * @Method Name	    fetchItem
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Method used to fetch the id of Item when Item number is entered 
    */
    @AuraEnabled
    public static String fetchItem(String skuNumber){
        String recId = '';
        Marketing_Item__c mktItem = new Marketing_Item__c();
        if(skuNumber != null && skuNumber != ''){
            List<Marketing_Item__c> lstItems = new List<Marketing_Item__c>();
            lstItems = [SELECT Id,Item_Number__c,Temporary_Item_Number__c
                        FROM Marketing_Item__c 
                        WHERE Item_Number__c =:skuNumber OR Temporary_Item_Number__c =:skuNumber ];
            recId = lstItems[0].Id;
        }
        return recId;
    }

      /***
    * @Method Name	    SaveFile
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Method used to attach file to the selected Item record
    */
    @AuraEnabled
    public static Id SaveFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment attach = new Attachment();
        attach.parentId = parentId;
        attach.Body = EncodingUtil.base64Decode(base64Data);
        attach.Name = fileName;
        attach.ContentType = contentType;
        Insert attach;
        return attach.Id;
    }
    
      /***
    * @Method Name	    fetchURL
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Method to give id value of the POC Planning report folder
    */
    @AuraEnabled
    public static string fetchURL(){
        List<folder> ids = new List<folder>();
        string idValue='';
        ids = [Select id from folder where developername = 'poc_planning' and type = 'report' limit 1];
        if(ids.size()>0){
          idValue = ids[0].id;  
        }
        return idValue;
    }  
    
}