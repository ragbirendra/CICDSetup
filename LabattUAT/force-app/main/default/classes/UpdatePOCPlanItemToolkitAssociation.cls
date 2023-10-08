/***
    * @Class Name	    UpdatePOCPlanItemToolkitAssociation
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		This class is used as the supporting controller for the Aura Component Bundle - UpdtPOCPlanItemProgramAssociation
    					This code along with the lightning component enables the TA Admin to remove any association for a selected Item in the POC Planning Setup tool
    */
public with sharing class UpdatePOCPlanItemToolkitAssociation {

       /***
    * @Method Name	    UpdatePOCPlanItemToolkitAssociation
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Constructor method 
    */
    public UpdatePOCPlanItemToolkitAssociation() {

    }

       /***
    * @Method Name	    fetchToolkitItemMapping
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Method to fetch the Item to Program Association based on the SKU Number
    					entered by the user on the UI
    */
    @AuraEnabled
    public static List<Marketing_Program_Item__c> fetchToolkitItemMapping(String skuNumber,String selectedYear){
        System.debug('#### sku number to search #### ' + skuNumber);
        List<Marketing_Program_Item__c> lstAssociation = new List<Marketing_Program_Item__c>();
        String yearMatch='%_'+selectedYear;
        if(skuNumber != null && skuNumber != ''){
            List<Marketing_Item__c> lstItem = new List<Marketing_Item__c>();
            lstItem = [SELECT Id FROM Marketing_Item__c WHERE Item_Number__c = :skuNumber];
            // expecting only one item as SKU Numbers should be unique
            if(!lstItem.isEmpty()){
                lstAssociation = [SELECT Id, Marketing_Program__c, Marketing_Program__r.Name 
                                    FROM Marketing_Program_Item__c
                                    WHERE Marketing_Item__c =:lstItem[0].Id and Marketing_Program__r.name Like:yearMatch];
            }
        }
        return lstAssociation;
    }

       /***
    * @Method Name	    deleteItemToolkitMapping
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Method to delete the association between the program and the item record
    					if operation is successful - it returns a ;; separated string of the assoication id records
    					or else return a failure 
    */
    @AuraEnabled
    public static string deleteItemToolkitMapping(String[] associationIds){
        String result = '';
        System.debug('#### program Ids #### ' + associationIds);
        List<Marketing_Program_Item__c> lstItem = new List<Marketing_Program_Item__c>();
        lstItem = [SELECT Id FROM Marketing_Program_Item__c WHERE Id IN :associationIds];
        System.debug('#### got the record #### ' + lstItem);
        if(!lstItem.isEmpty()){
            try{
                delete lstItem;
                for(Marketing_Program_Item__c var : lstItem){
                    result += var.Id + ';;';
                }
                result = result.subString(0,result.lastIndexOf(';;'));
            }catch(Exception ex){
                System.debug('#### error while deleting #### ' + ex.getMessage() );
                // throw aura exception
                result = 'failure';
            }            
        }
        return result;
    }

}