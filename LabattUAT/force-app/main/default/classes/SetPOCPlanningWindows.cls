/***
    * @Class Name	    SetPOCPlanningWindows
    * @Author			Nupur Renwal
    * @CreatedDate		09-19-2019
    * @Description		This class is used as the supporting controller for the Aura Component Bundle - DefinePlanningWindows
            			This code along with the lightning component enables the TA Admin to Create Flexible Planning Window
    */

public with sharing class SetPOCPlanningWindows {
    
    /***
    * @Method Name	    fetchPlanningWindows
    * @Author			Nupur Renwal
    * @CreatedDate		09-19-2019
    * @Description		Used to Show planning window on the basis of selected year
    */
    @AuraEnabled
    public static List<POC_Planning_Setup_Admin__c> fetchPlanningWindows(String selYear){
        System.debug('#### the selected year is #### ' + selYear);
        List<POC_Planning_Setup_Admin__c> lstPlanWindows = new List<POC_Planning_Setup_Admin__c>();
        lstPlanWindows = [SELECT Id, Type__c, Budget_Year__c, Plan_Start_Date__c,Planning_Year__c ,Plan_End_Date__c,Business_Line__c
                            FROM POC_Planning_Setup_Admin__c 
                            WHERE Planning_Year__c = :String.escapeSingleQuotes(selYear)
                            ORDER BY Type__c,Plan_Start_Date__c] ;
        return lstPlanWindows;
    }
    /***
    * @Method Name	    fetchAllPlanningWindows
    * @Author			Nupur Renwal
    * @CreatedDate		09-19-2019
    * @Description		Used to Show planning window on the basis of selected year
    */
	@AuraEnabled
    public static List<POC_Planning_Setup_Admin__c> fetchAllPlanningWindows(String recId){
        List<POC_Planning_Setup_Admin__c> lstPlanWindows = new List<POC_Planning_Setup_Admin__c>();
        lstPlanWindows = [SELECT Id, Type__c, Budget_Year__c, Plan_Start_Date__c,Planning_Year__c ,Plan_End_Date__c,Business_Line__c
                            FROM POC_Planning_Setup_Admin__c 
                             WHERE Id != : String.escapeSingleQuotes(recId)
                            ORDER BY Type__c,Plan_Start_Date__c] ;
        return lstPlanWindows;
    }
    /***
    * @Method Name	    changeStringToDate
    * @Author			Nupur Renwal
    * @CreatedDate		09-19-2019
    * @Description		Used to autopopulate budget year value on the basis of selected year
    */
    @AuraEnabled
    public static Integer changeStringToDate(String BudgetDate){
        	Date BudgetYrDate; 
           BudgetYrDate = Date.valueOf(BudgetDate);
           Integer onlyYear=BudgetYrDate.year();
          system.debug('BudgetYrDate' + BudgetYrDate);
        	 return onlyYear;
        // Now we can use expirationDate
    }
    /***
    * @Method Name	    definePlanningWindow
    * @Author			Nupur Renwal
    * @CreatedDate		09-19-2019
    * @Description		Used to Define planning window on the basis of selected year
    */
    @AuraEnabled
    public static List<POC_Planning_Setup_Admin__c> definePlanningWindow(POC_Planning_Setup_Admin__c planWindowData){
        List<POC_Planning_Setup_Admin__c> lstPlanWin = new List<POC_Planning_Setup_Admin__c>();
        try{
            if(!Schema.sObjectType.POC_Planning_Setup_Admin__c.isCreateable()){
                throw new AuraHandledException('User does not have sufficient Permission to complete the operation');   
            }
            else{
                 insert planWindowData;
            }
           
			System.debug('planWindowData' +planWindowData);            
            lstPlanWin = fetchPlanningWindows(planWindowData.Planning_Year__c);
        }catch(Exception ex){
            System.debug('#### error while inserting data #### ' + ex.getMessage()); // throw aura exception may be?
            throw new AuraHandledException('Something went wrong while inserting planning windows: '+ ex.getMessage());   
        }
        return lstPlanWin;
    }
    /***
    * @Method Name	    deletePlanWindows
    * @Author			Nupur Renwal
    * @CreatedDate		09-19-2019
    * @Description		Used to Delete selected planning window 
    */
    @AuraEnabled
    public static List<POC_Planning_Setup_Admin__c> deletePlanWindows(String recId, String selYear){
        System.debug('#### record id to be deleted #### ' + recId);
        List<POC_Planning_Setup_Admin__c> lstPlanWin = new List<POC_Planning_Setup_Admin__c>();
        lstPlanWin = [SELECT Id FROM POC_Planning_Setup_Admin__c WHERE Id = : String.escapeSingleQuotes(recId)];
        try{
            delete lstPlanWin;
            lstPlanWin = fetchPlanningWindows(selYear);
        }catch(Exception ex){
            System.debug('#### error while deleting record ####'); // throw aura exception may be?
            throw new AuraHandledException('Something went wrong while deleting planning windows: '+ ex.getMessage());   
        }
        return lstPlanWin;
    }
    /***
    * @Method Name	    updatePlanWindows
    * @Author			Nupur Renwal
    * @CreatedDate		09-19-2019
    * @Description		Used to Edit selected planning window 
    */
    @AuraEnabled
    public static List<POC_Planning_Setup_Admin__c> updatePlanWindows(POC_Planning_Setup_Admin__c planWindowData, String selYear){
        System.debug('#### received data to update #### ' + planWindowData.Id);
        List<POC_Planning_Setup_Admin__c> lstPlanWin = new List<POC_Planning_Setup_Admin__c>();
        try{
            if(!Schema.sObjectType.POC_Planning_Setup_Admin__c.isUpdateable()){
                throw new AuraHandledException('User does not have sufficient Permission to complete the operation');   
            }
            else{
                   update planWindowData;
            }
          
            lstPlanWin = fetchPlanningWindows(selYear);
        }catch(Exception ex){
             System.debug('#### error while deleting record ####'); // throw aura exception may be?
             throw new AuraHandledException('Something went wrong while updating planning windows: '+ ex.getMessage());   
        }
        return lstPlanWin;
    }
}