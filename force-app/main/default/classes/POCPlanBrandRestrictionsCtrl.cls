/***
    * @Class Name	    POCPlanBrandRestrictionsCtrl
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		This class is used as the supporting controller for the Aura Component Bundle - UpdatePOCPlanBrandRestrictions
    					This code along with the lightning component enables the TA User to modify brand restrictions in the POC Planning Setup tool
    */
public with sharing class POCPlanBrandRestrictionsCtrl {
     /***
    * @Method Name	    POCPlanBrandRestrictionsCtrl
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Constructor method 
    */

    public POCPlanBrandRestrictionsCtrl() {

    }

     /***
    * @Method Name	    fetchAllBrandRecords
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Method to fetch POC Planning Brand Restriction on the basis of the selected year
    */

    @AuraEnabled
    public static String fetchAllBrandRecords(String selYear){
        String brandValStr = '';
        System.debug('#### selected year in apex #### ' + selYear);
        List<Brand__c> brandList = new List<Brand__c>();
        brandList = [SELECT Id, Name FROM Brand__c];
        if(!brandList.isEmpty()){
            for(Brand__c var : brandList){
                brandValStr += var.Name + ';';
            }
            brandValStr = brandValStr.substring(0, brandValStr.lastIndexOf(';'));
            System.debug('#### final brand string built #### '  + brandValStr);
            //Restricated_Brand__c orgInst = Restricated_Brand__c.getOrgDefaults();
            //brandValStr += '_-_' + orgInst.Brand_Name__c; 
            List<POC_Planning_Brand_Restriction__c> lstBrandRest = new List<POC_Planning_Brand_Restriction__c>();
            lstBrandRest = [SELECT Id, Budget_Year__c, Restricted_Brands__c 
                            FROM POC_Planning_Brand_Restriction__c 
                            WHERE Budget_Year__c = :selYear];
            if(!lstBrandRest.isEmpty()){
                brandValStr += '_-_' + lstBrandRest[0].Restricted_Brands__c;
            }else{
                brandValStr += '_-_';
            }            
        } 
        return  brandValStr;     
    }

     /***
    * @Method Name	    saveBrandRestrictions
    * @Author			Developer@Cognizant
    * @CreatedDate		10-21-2019
    * @Description		Method to modify POC Planning Brand Restriction on the basis of the selected year
    */

    @AuraEnabled
    public static string saveBrandRestrictions(String[] newBrandVals, String selYear){
        System.debug('#### received brand vals #### ' + newBrandVals);
        String responseStr = '';
        for(String var : newBrandVals){
            System.debug('#### received brand vals in loop #### ' + var);
            responseStr += var + '$';
        }
        System.debug('#### after loop #### ' + responseStr);
        /*Restricated_Brand__c orgInst = Restricated_Brand__c.getOrgDefaults();
        //orgInst.Brand_Name__c = newBrandVals[0];
        orgInst.Brand_Name__c = responseStr.subString(0, responseStr.lastIndexOf(','));
        update orgInst;*/
        List<POC_Planning_Brand_Restriction__c> lstBrandRest = new List<POC_Planning_Brand_Restriction__c>();
        lstBrandRest = [SELECT Id, Budget_Year__c, Restricted_Brands__c 
                            FROM POC_Planning_Brand_Restriction__c 
                            WHERE Budget_Year__c = :selYear];
        if(!lstBrandRest.isEmpty()){
            lstBrandRest[0].Restricted_Brands__c = responseStr;
            update lstBrandRest[0];
        }else{
            POC_Planning_Brand_Restriction__c newObj = new POC_Planning_Brand_Restriction__c();
            newObj.Budget_Year__c = selYear;
            newObj.Restricted_Brands__c = responseStr;
            insert newObj;
        }    
        return responseStr;
    }
}