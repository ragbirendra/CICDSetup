/********************
 * @Class Name    POCPKIVolDiscUpdateCtrl
 * @Description   This class is used as the supporting controller for the Aura Component Bundle -POCPKIVOLDiscUpdtComponent 
 				  This code along with the lightning component will enables the  TA Admins to update the Assigned KI Volume and the Discretionary Budget for the
				  Annual Area Budget data based on a selected year and business line
 * @Part of       POC Planning Application
 * @Author        Developer@Cognizant
 * *******************/

public class POCPKIVolDiscUpdateCtrl {
    
	/***
    * @Method Name	    fetchAllAABRecords
    * @Author			Developer@Cognizant
    * @CreatedDate		10-19-2019
    * @Description		Used to fetch annual area budget records on the basis of selected year and business line
    */
    @AuraEnabled
    public static List<Annual_Area_Budget__c> fetchAllAABRecords(String selYear, String businessLine){
        List<Annual_Area_Budget__c> lstAABRec = new List<Annual_Area_Budget__c>();
        if(selYear != null && businessLine != null && selYear != '' && businessLine != ''){
            if(businessLine == 'Out of Home'){ //checked in full copy - current data vol - 224
                lstAABRec = [SELECT Id, Territory_Code__c, Assigned_KI_Volume__c, Discretionary_Budget__c 
                                FROM Annual_Area_Budget__c 
                                WHERE Budget_Year__c = :selYear
                                AND RecordType.DeveloperName = 'Territory'
                            	AND Territory_Code__c != null];
            }else if(businessLine == 'In Home'){
				lstAABRec = [SELECT Id, Territory_Code__c, Sales_Territory__r.Name, Assigned_KI_Volume__c, Discretionary_Budget__c 
                                FROM Annual_Area_Budget__c 
                                WHERE Budget_Year__c = :selYear
                                AND RecordType.DeveloperName = 'New_IH_Territory'
                            	AND Territory_Code__c != null];
            }            
        }
        return lstAABRec;
    }
    
    /***
    * @Method Name	    FetchKIVolumeBudgetRecords
    * @Author			Developer@Cognizant
    * @CreatedDate		10-19-2019
    * @Description		Used to fetch annual area budget records on the basis of selected year and business line
    */
    @AuraEnabled
    public static List<Annual_Area_Budget__c> FetchKIVolumeBudgetRecords(String selectedChArr,Integer selectedYrArr)
    {
        List<Annual_Area_Budget__c> lstAABRec = new List<Annual_Area_Budget__c>();
        
        system.debug('String.valueOf(selectedYrArr):::'+String.valueOf(selectedYrArr));
        if(selectedChArr == 'Out of Home'){
        lstAABRec =[SELECT  Territory_Code__c, Budget_Year__c,Assigned_KI_Volume__c, Discretionary_Budget__c ,Business_Line__c
                                                 FROM Annual_Area_Budget__c 
                                                 where Budget_Year__c=:String.valueOf(selectedYrArr) and RecordType.DeveloperName = 'Territory'
                   								AND Territory_Code__c != null];
            for(Annual_Area_Budget__c abb:lstAABRec)
            {
                abb.Business_Line__c='Out of Home';
            }
        }
        else if(selectedChArr == 'In Home'){
				lstAABRec = [SELECT  Territory_Code__c,Budget_Year__c, Assigned_KI_Volume__c, Discretionary_Budget__c ,Business_Line__c
                                FROM Annual_Area_Budget__c 
                                WHERE Budget_Year__c=:String.valueOf(selectedYrArr)
                                AND RecordType.DeveloperName = 'New_IH_Territory'
                            	AND Territory_Code__c != null];
            for(Annual_Area_Budget__c abb:lstAABRec)
            {
                abb.Business_Line__c='In Home';
            }
            }            
        return lstAABRec;
    }
    
    /***
    * @Method Name	    updateTerrKIAndDisc
    * @Author			Developer@Cognizant
    * @CreatedDate		10-19-2019
    * @Description		Used to update annual area budget records
    */
    @AuraEnabled
    public static List<Annual_Area_Budget__c> updateTerrKIAndDisc(List<Annual_Area_Budget__c> lstToUpdate){
        System.debug('#### list to update #### ' + lstToUpdate);
        List<Annual_Area_Budget__c> updateList = new List<Annual_Area_Budget__c>();
        updateList = lstToUpdate;
        if(lstToUpdate != null && lstToUpdate.size() > 0){
            try{
                Database.executeBatch(new TerritoryBudgetKIAndDiscUpdateBatch(lstToUpdate),10); 
            }catch(Exception ex){
                System.debug('#### exception while updating custom setting #### ' + ex.getMessage());
            	throw new AuraHandledException('Error While updating data ' + ex.getMessage());
            }
        }
        return updateList;
    }
}