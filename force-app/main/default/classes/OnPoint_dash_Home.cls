/*
Version         : 0.4
Company         : Labatt
Creation Date   : 2017-06-14
Author          : Stephen Scholtz
Description     : Controller for landing page for OnPoint sales reps
                  #onpoint #cloudcraze

Helpful links   :
    
History         : 
    2017-08-18 - [Stephen] Converted spaces to tabs to align with Dennis code style
               - added future code and new #userModelChange_August tag to keep track of changes needed for new data model
    2017-10-18 - [Stephen] Implemented the data model change, and removed some old code
    2017-10-31 - [Stephen] Added Is_Deactivated__c to the query
    2019-07-29 - [Ragbirendra] Added Query to find budget Id for Rep login to onplan

TODO:onPlan_Budget__c
    - lots more needs to go on this dashboard page, reports and other things

*/
   /**
     * Project name : Onplane enhancement
     * Modified date: 17-07-2019
     * modified By  :Ragbirendra Upadhyay
     * This method is used to redirect DSM to his reps onplan shop window
     */
public with sharing class OnPoint_dash_Home {

    // Variables
    public List<OnPoint_Territory_Role__c> communityAssignments {get;private set;}
    //public List<User> assignedCommSalesRep {get;private set;}
    public List<OnPoint_Update__c> onPointUpdates{get;set;}
    public List<Annual_Area_Budget__c> budgetList{get;set;}
    public List<lboc_Sales_Territory__c> listOPT{get;set;}
    public List<Id> tid = new List<Id>();
    public List<String> terrCode = new List<String>();
    Set<String> setOfBudget=new Set<String>();
    public List<TAUserViewRefrence__c> code {get;set;}
    public boolean isTAAdmin{get;set;}
    
    // Constructor
    public OnPoint_dash_Home() {
        communityAssignments = new List<OnPoint_Territory_Role__c>();
        for(OnPoint_Territory_Role__c optr:[
            SELECT 
                Id
                , OnPoint_Territory__c
                , OnPoint_Territory__r.Name
                , OnPoint_Territory__r.Territory_Code__c
                , OnPoint_Territory__r.CloudCraze_Community_User__c
                , OnPoint_Territory__r.CloudCraze_Community_User__r.Name
                , OnPoint_Territory__r.CloudCraze_Community_User__r.IsActive
                , OnPoint_Territory__r.CloudCraze_Community_User__r.Contact.Name
                , OnPoint_Territory__r.OwnerId
                , OnPoint_Territory__r.CloudCraze_Community_User__r.Contact.Account.Name
            FROM OnPoint_Territory_Role__c
            WHERE User__c = :UserInfo.getUserId()
            AND Is_Deactivated__c = false
            AND OnPoint_Territory__r.CloudCraze_Community_User__c !=null    
            AND OnPoint_Territory__r.CloudCraze_Community_User__r.IsActive = true
            ORDER BY OnPoint_Territory__r.CloudCraze_Community_User__r.Name
            ])  {
            communityAssignments.add(optr);
              tid.add(optr.OnPoint_Territory__r.OwnerId);
              terrCode.add(optr.OnPoint_Territory__r.Territory_Code__c);
            }
            // added by Ragbirendra
             budgetList = new List<Annual_Area_Budget__c>();
             AggregateResult[] obj = [SELECT MAX(Budget_Year__c) budgetyear, OwnerId,Sales_Territory__r.lboc_Territory_ID__c st FROM Annual_Area_Budget__c group by  OwnerId ,Sales_Territory__r.lboc_Territory_ID__c having OwnerId in : tid and Sales_Territory__r.lboc_Territory_ID__c in :terrCode];
             for (AggregateResult aggResult: obj)
             {
                 String yearOwnerIdAndTerrCode=(String)aggResult.get('budgetyear')+'_'+String.valueOf(aggResult.get('OwnerId'))+'_'+String.valueOf(aggResult.get('st'));
                 setOfBudget.add(yearOwnerIdAndTerrCode);                
              }
            List<String> duplicateCheck = new  List<String>();
            for(Annual_Area_Budget__c ab:[SELECT id, OwnerId,Territory_Code__c,Owner.Name,Budget_Year__c,Sales_Territory__r.name,Sales_Territory__r.lboc_Territory_ID__c FROM Annual_Area_Budget__c where OwnerId in : tid and Sales_Territory__r.lboc_Territory_ID__c in :terrCode]){
            String yearOwnerIdAndTerrCode = ab.Budget_Year__c+'_'+String.valueOf(ab.OwnerId) +'_'+String.valueOf(ab.Sales_Territory__r.lboc_Territory_ID__c);
             if(setOfBudget.contains(yearOwnerIdAndTerrCode)){
               
                 if(!duplicateCheck.contains(yearOwnerIdAndTerrCode)){
                     duplicateCheck.add(yearOwnerIdAndTerrCode);
                     budgetList.add(ab);
                 }
            	
            }
        }
        //Enable button for TA Admin
        user usr =[select Id,Is_TAU_Admin__c,is_TAU_User__c from user where id=:userinfo.getuserId()];
        if(usr.Is_TAU_Admin__c==true || usr.is_TAU_User__c==true || Test.isRunningTest()){
          isTAAdmin = true;  
        }
        
        // take record from custom setting for TA User Preview
        Map<String,TAUserViewRefrence__c> allCodes = TAUserViewRefrence__c.getAll();
        code = allCodes.values();
        system.debug('code::'+code.size());
        for(integer i =0;i<code.size();i++)
        {
            List<Annual_Area_Budget__c> aab = [select Id from Annual_Area_Budget__c where owner.email=:code[i].user_Email_Id__c Limit 1];
            if(aab.size()>0)
            code[i].user_Email_Id__c= aab[0].Id;
                    
        }
        
       // User objusr=[SELECT Name, Id, OnPoint_Person_Id__c  FROM User WHERE Id = : UserInfo.getUserId()];
       // string labattId=objusr.OnPoint_Person_Id__c+'%';
       // listOPT = [SELECT Name ,id FROM lboc_Sales_Territory__c WHERE Back_Office_Territory__c = true and lboc_Territory_ID__c  LIKE: labattId];
            onPointUpdates = [select id , Start_Date__c,End_Date__c,Update__c from OnPoint_Update__c where Start_Date__c<=Today and End_Date__c>=Today];//Added for Onpoint Dashboard Updates
    }
  
  
}