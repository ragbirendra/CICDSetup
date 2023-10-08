/***
    * @Class Name	    UpdatePOCPlanningPreviewUserCtrl
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		This class is used as the supporting controller for the Aura Component Bundle - UpdatePOCPlanningPreviewUser
    					This code along with the lightning component enables the TA Admin to show and update POCP Preview user
    */
public with sharing class UpdatePOCPlanningPreviewUserCtrl {
    
     /***
    * @Method Name	    UpdatePOCPlanningPreviewUserCtrl
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Constructor method 
    */
    public UpdatePOCPlanningPreviewUserCtrl() {

    }

     /***
    * @Method Name	    fetchSetupPreviewUsers
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Used to show POCP Preview user 
    */
    @AuraEnabled
    public static List<TAUserViewRefrence__c> fetchSetupPreviewUsers(){
        String returnValue = '';
        List<TAUserViewRefrence__c> prevUserList = new List<TAUserViewRefrence__c>();
        prevUserList = [SELECT Id, Name, previewAs__c, user_Email_Id__c 
                        FROM TAUserViewRefrence__c];
        return prevUserList;
    }

     /***
    * @Method Name	    savePreviewOpr
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Used to update POCP Preview user 
    */
    @AuraEnabled
    public static List<TAUserViewRefrence__c> savePreviewOpr(List<TAUserViewRefrence__c> lstPrevValues){
        try{
            update lstPrevValues;
        }catch(Exception ex){
            System.debug('#### exception while updating custom setting #### ' + ex.getMessage());
            throw new AuraHandledException('Error While updating data ' + ex.getMessage());            
        }
        return lstPrevValues;
    }
}