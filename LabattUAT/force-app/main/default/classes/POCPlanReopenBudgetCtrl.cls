/***
    * @Class Name	    POCPlanReopenBudgetCtrl
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		This class is used as the supporting controller for the Aura Component Bundle - POCPlanReopenBudget
   						This code along with the lightning component enables the TA Admin to show and update Budget Data
    */
public with sharing class POCPlanReopenBudgetCtrl {
    
     /***
    * @Method Name	    POCPlanReopenBudgetCtrl
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Constructor method 
    */
    public POCPlanReopenBudgetCtrl() {

    }

     /***
    * @Method Name	    fetchAnnAreaBudgetRec
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Method used to fetch annual area budget record on basis od Owner First Name , Last Name and Budget Year 
    */
    @AuraEnabled
    public static List<Annual_Area_Budget__c> fetchAnnAreaBudgetRec(String budYear, String ownerFirstName, String ownerLastName){        
        List<Annual_Area_Budget__c> areaBudlist = new List<Annual_Area_Budget__c>();
        areaBudlist = [SELECT Id, Name, Territory_Code__c, Sales_Territory__r.Name, recordType.Name, Approval_Status__c 
                        FROM Annual_Area_Budget__c
                        WHERE Budget_Year__c = :budYear
                            AND Owner.FirstName = :ownerFirstName 
                       		AND Owner.LastName = :ownerLastName ];

        return areaBudlist;
    }

     /***
    * @Method Name	    updateAnnAreaBudget
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Used to update annual area budget record
    */
    @AuraEnabled
    public static Annual_Area_Budget__c updateAnnAreaBudget(Annual_Area_Budget__c budgetRecordToUpdate){
        System.debug('#### received data in update method #### ' + budgetRecordToUpdate);
        try{
            update budgetRecordToUpdate;
        }catch(Exception ex){
            System.debug('#### error while updating record #### ' + ex.getMessage());
            // handle error - throw aura handled exception
        }
        return budgetRecordToUpdate;
    }
}