/***
* @Name				OnPoint_CC_Product_UpdateBatch
* @Author			Ragbirendra Upadhyay
* @CreatedDate		10-31-2019
* @Description		Batch Class for Update CC Product Record from 
*					Item Object record based on SKU Number and Id of CC Product
*/
global class OnPoint_CC_Product_UpdateBatch implements Database.Batchable<sObject>,Database.stateful {
    
    String body = 'Hi '+'</br>';
    List<String> skuNumberList = new List<String>(); //taking sku number for Custom execution of Batch
    public OnPoint_CC_Product_UpdateBatch(){}
    public OnPoint_CC_Product_UpdateBatch(List<string> skuNumberLst){
        skuNumberList= skuNumberLst;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        if(skuNumberList!=null && !skuNumberList.isEmpty()){
            query = 'SELECT Id, Name , ccrz__SKU__c from ccrz__E_Product__c where ccrz__SKU__c IN:skuNumberList';
            system.debug('query::::'+query);
        }
        else{
            query = 'SELECT Id, Name , ccrz__SKU__c from ccrz__E_Product__c';    
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<ccrz__E_Product__c> scope){
        
        Map<String,Id> SKUNumberIdMap = new Map<String,Id>();
        List<Id> ids = new List<Id>();
        Map<String,Id> itemIdBasedOnItemNumMap = new Map<String,Id>();
        Map<String ,Id> stagingMainMap = new Map<String ,Id>();
        for(Staging_Main__c stm:[select SKU_Number__c,Id from Staging_Main__c])
        {
           stagingMainMap.put(stm.SKU_Number__c,stm.Id); 
        }
        for(ccrz__E_Product__c  ccrzEProduct :scope){
            
            if(String.valueOf(ccrzEProduct.Id).contains(ccrzEProduct.Name)){
                if(stagingMainMap.containsKey(ccrzEProduct.ccrz__SKU__c)){// checking into staging Main
                 SKUNumberIdMap.put(ccrzEProduct.ccrz__SKU__c,ccrzEProduct.Id);   
                }   
            } 
        }
        
        UpdateCCProduct updateCCProduct = new UpdateCCProduct();
        system.debug('----before query----');
        List<Marketing_Item__c> itemList =[select Id,Item_Number__c ,name,Brand__r.name,Is_Program_Only__c,Items_Parent_Product_Types__c,Items_Product_Type__c from Marketing_Item__c where Item_Number__c IN :SKUNumberIdMap.keySet()];  
        system.debug('---after query---'+itemList);
        // fetch item Attachment image,Item Name,Brand,Parent product Type,product type
        for(Marketing_Item__c mi:itemList){
            ids.add(mi.Id);
            itemIdBasedOnItemNumMap.put(mi.Item_Number__c,mi.Id);
        } 
        
        
        Map<Id,Attachment> attachmentMap = new Map<Id,Attachment>();
        for (Attachment att : [select Id,Name,body,parentId from Attachment where parentId IN:ids]) {   
            attachmentMap.put(att.parentId,att);
        } 
        //if(!Test.isRunningTest())
        body  = body+''+updateCCProduct.updateProduct(SKUNumberIdMap,itemList,attachmentMap,itemIdBasedOnItemNumMap);
        
    }
    global void finish(Database.BatchableContext BC){
       
        List<string> emailId = new List<string>();
        List<string> ccEmailId = new List<string>();
        body = '</br>'+'CC Product Update Batch Proccessed Successfully';
        ExcelHeader__mdt[] ccMailList = [select MasterLabel, QualifiedApiName, column_A__c FROM ExcelHeader__mdt where MasterLabel ='cc Mail Id'];
        for(ExcelHeader__mdt eh:ccMailList){
            emailId.add(eh.column_A__c);   
        }
        Mailutility.sendMail(emailId,ccEmailId,'CC Product Update Batch Result (Onplan to Onpoint)',body);
        
    }
    
}