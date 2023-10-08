/***
    * @Class Name	    UpdatePOCPlanningShoppedKitCtrl
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		This class is used as the supporting controller for the Aura Component Bundle - UpdatePOCPlanningShoppedKitData
    					This code along with the lightning component enables the TA Admin to remove Shopkit Item Mapping for a selected Shopkit name in the POC Planning Setup tool					
    */

public with sharing class UpdatePOCPlanningShoppedKitCtrl {

       /***
    * @Method Name	    UpdatePOCPlanningShoppedKitCtrl
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Constructor method 
    */
    public UpdatePOCPlanningShoppedKitCtrl() {
    }
    
     @AuraEnabled(cacheable=true)
    public static String[] getPickListVals(String selectedChannelName,String selectedYearValue){
        system.debug('selectedChannelName:::'+selectedChannelName);
        system.debug('selectedYearValue:::'+selectedYearValue);
        String selectedProgramNameyear = '%_'+selectedYearValue;
        String[] ProgramNameArray = new List<String>();
        list<Marketing_Program__c> lst = [Select Id,name from Marketing_Program__c where  Name like :selectedProgramNameyear AND Business_Line__c=:selectedChannelName];
        system.debug('lst:::'+lst);
        for(Marketing_Program__c mp:lst){
           ProgramNameArray.add(mp.name);
        }
        
        return ProgramNameArray;
    }
    
       /***
    * @Method Name	    fetchToolkitItemMapping
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Used to fetch Shopkit item Mapping
    */
    @AuraEnabled
    public static List<Marketing_Kit__c> fetchToolkitItemMapping(String selectedProgramName,String selectedYear,String selectedBusinessLine){
        System.debug('#### sku number to search #### ' + selectedProgramName);
        List<Marketing_Kit__c> lstItem = new List<Marketing_Kit__c>();
        
        if(selectedProgramName != null && selectedProgramName != ''){ 
           
            Map<Id,Marketing_Program__c> programList =new Map<Id,Marketing_Program__c>([select Id ,name from Marketing_Program__c where name like :selectedProgramName and Business_Line__c=:selectedBusinessLine ]);
            lstItem = [SELECT Id, Name FROM Marketing_Kit__c WHERE Marketing_Program_Name__c IN :programList.keySet() and RecordType.DeveloperName ='Preconfigured'];
        }
        return lstItem;
    }

       /***
    * @Method Name	    deleteItemToolkitMapping
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Used to delete Shopkit and shopkit item Mapping
    */
    @AuraEnabled
    public static string deleteItemToolkitMapping(String[] associationIds){
        List<Marketing_Kit__c> lstItem = new List<Marketing_Kit__c>();
        lstItem = [SELECT Id FROM Marketing_Kit__c WHERE Id IN :associationIds];
        delete lstItem;
        return '';
    }

}