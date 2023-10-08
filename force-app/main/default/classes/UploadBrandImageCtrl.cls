/***
    * @Class Name	    UploadBrandImageCtrl
    * @Author			Nupur Renwal
    * @CreatedDate		10-21-2019
    * @Description		This class is used as the supporting controller for the Aura Component Bundle - UploadBrandImage
    					This code along with the lightning component enables the TA Admin to Upload image on Brand records
    */
public with sharing class UploadBrandImageCtrl {
    
     /***
    * @Method Name	    UploadBrandImageCtrl
    * @Author			Nupur Renwal
    * @CreatedDate		10-21-2019
    * @Description		Constructor method 
    */
    public UploadBrandImageCtrl() {

    }

    /***
    * @Method Name	    fetchBrandDetail
    * @Author			Nupur Renwal
    * @CreatedDate		10-21-2019
    * @Description		Used to fetch all the brands name 
    */
    @AuraEnabled
    public static List<String> fetchBrandDetail(){
        String recId = '';
        List<Brand__c> lstItems = new List<Brand__c>();
        List<String> brandName= new List<String>();
        lstItems = [SELECT  Name FROM Brand__c ];
       // recId = lstItems[0].Id;
        for(Brand__c bc :lstItems){
            brandName.add(bc.Name);
        }
        return brandName;
    }
    
  /***
    * @Method Name	    fetchBrandId
    * @Author			Nupur Renwal
    * @CreatedDate		10-21-2019
    * @Description		Used to fetch Id of the selected brand  whose image will be uploaded
    */
    @AuraEnabled
    public static String fetchBrandId(String brandName){
        String recId = '';
        List<Brand__c> lstItems = new List<Brand__c>();
       
        lstItems = [SELECT  Id FROM Brand__c  where Name=:brandName];
       recId = lstItems[0].Id;
        return recId;
    }
  
    /***
    * @Class Name	    SaveFile
    * @Author			Nupur Renwal
    * @CreatedDate		10-21-2019
    * @Description		Used to Upload image on the given brand id 
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
}