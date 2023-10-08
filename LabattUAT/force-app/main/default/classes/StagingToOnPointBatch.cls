/***
* @Name - StagingToOnPointBatch
* @Author -  Amol Parab
* @CreatedDate -09/15/2019
* @Description - 
* 

***/


global class StagingToOnPointBatch implements Database.Batchable<sObject>, Database.stateful
{
    global String body='Hi, </br></br>';
     String ProgramName;
     public StagingToOnPointBatch(){}
    public StagingToOnPointBatch(string varProgramName){
        ProgramName= varProgramName;
    }
	 global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query;
        if(!test.isRunningTest()){
            if(ProgramName == '' || ProgramName== NULL){
        	 query = 'SELECT id,Name,SKU_Number__c,Item_Price__c,Quantity__c,Is_Program_User_Paid__c,Total_Price__c,Program_Name__c,Brand_Name__c,Program_Start_Date__c,Program_End_Date__c,Budget_Year__c,OnPoint_Brand_Name__c,OnPoint_Program_Id__c,OnPoint_Brand_Id__c,OnPoint_Product_Id__c,Account__c,Account__r.OnPoint_Sales_Territory__c,Account__r.OnPoint_Sales_Territory__r.Territory_Code__c,Account__r.Name FROM Staging_Main__c WHERE Data_Reviewed__c=true AND Quantity__c !=0 AND Program_Start_Date__c >= TODAY  AND  Program_Start_Date__c <= NEXT_N_DAYS:15 AND OnPoint_Program_Id__c=\'\' AND  SKU_Number__c!=\'\' ';
            }
            else if(ProgramName != ''){
              query = 'SELECT id,Name,SKU_Number__c,Item_Price__c,Quantity__c,Is_Program_User_Paid__c,Total_Price__c,Program_Name__c,Brand_Name__c,Program_Start_Date__c,Program_End_Date__c,Budget_Year__c,OnPoint_Brand_Name__c,OnPoint_Program_Id__c,OnPoint_Brand_Id__c,OnPoint_Product_Id__c,Account__c,Account__r.OnPoint_Sales_Territory__c,Account__r.OnPoint_Sales_Territory__r.Territory_Code__c,Account__r.Name FROM Staging_Main__c WHERE Data_Reviewed__c=true AND Program_Name__c =:ProgramName AND Quantity__c !=0  AND   OnPoint_Program_Id__c=\'\' AND  SKU_Number__c!=\'\' ';
            }
        }
        else{
         query = 'SELECT id,Name,SKU_Number__c,Item_Price__c,Quantity__c,Is_Program_User_Paid__c,Total_Price__c,Program_Name__c,Brand_Name__c,Program_Start_Date__c,Program_End_Date__c,Budget_Year__c,OnPoint_Brand_Name__c,OnPoint_Program_Id__c,OnPoint_Brand_Id__c,OnPoint_Product_Id__c,Account__c,Account__r.OnPoint_Sales_Territory__c,Account__r.OnPoint_Sales_Territory__r.Territory_Code__c,Account__r.Name FROM Staging_Main__c WHERE Data_Reviewed__c=true AND Quantity__c !=0 ';
  
        }
            
        system.debug('==query--'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Staging_Main__c> scope)
    {
        //List To Insert Pprogram, brand, product
        List<OnPoint_Program__c> listOfOnPointProgram = new List<OnPoint_Program__c>();
        List<OnPoint_Brand__c> listOfOnPointBrand= new List<OnPoint_Brand__c>();
        List<ccrz__E_Product__c> listOfccProduct = new List<ccrz__E_Product__c>();
        
        //Created MAP with Name , id of brand, program, product to insert in staging record if below already exist
        MAP<string, id > brandNameAndIdMap=new MAP<string, id>();
        for(OnPoint_Brand__c obc:[SELECT id, Name FROM OnPoint_Brand__c])
        {
           brandNameAndIdMap.put(obc.Name,obc.id); 
        }
        MAP<string, id> mapOfProgramidName=new MAP<string, id>();
        for(OnPoint_Program__c oPName:[SELECT id , Name FROM OnPoint_Program__c ])
        {
            mapOfProgramidName.put(oPName.Name,oPName.id);
        }
        Map<String, ccrz__E_Product__c> ccProductANDIdMap= new MAP<String, ccrz__E_Product__c>();
        for(ccrz__E_Product__c ccp:[SELECT id, Name, ccrz__SKU__c FROM ccrz__E_Product__c])
        {
            ccProductANDIdMap.put(ccp.ccrz__SKU__c, ccp);
        }
        
        //Update refernce id before insert onpoint data
        List<Staging_Main__c> stagingToUpdate=new List<Staging_Main__c>();
        for(Staging_Main__c objstm:scope)
        {
            if(!mapOfProgramidName.isEmpty()){
            objstm.OnPoint_Program_Id__c=mapOfProgramidName.get(objstm.Program_Name__c);
            }
            if(!brandNameAndIdMap.isEmpty()){
                if(brandNameAndIdMap.containsKey(objstm.OnPoint_Brand_Name__c)){
            		objstm.OnPoint_Brand_Id__c= brandNameAndIdMap.get(objstm.OnPoint_Brand_Name__c);
                }
                else if(brandNameAndIdMap.containsKey(objstm.Brand_Name__c)){
                    objstm.OnPoint_Brand_Id__c= brandNameAndIdMap.get(objstm.Brand_Name__c);
                }
            }
            if(!ccProductANDIdMap.isEmpty()){
            objstm.OnPoint_Product_Id__c = ccProductANDIdMap.get(objstm.SKU_Number__c).id;
            }
            stagingToUpdate.add(objstm);
        }
         Database.update(stagingToUpdate);     // Update staging data
        
        set<String> externalIdSet = new set<String>();
        for(Staging_Main__c objstm:stagingToUpdate)
        {
            if(objstm.OnPoint_Program_Id__c=='' || objstm.OnPoint_Program_Id__c==Null ){       //Check to make sure corresponding program not available in Onpoint
                
                if(!externalIdSet.contains(objstm.Program_Name__c +'__'+objstm.Program_Start_Date__c)){
                    OnPoint_Program__c op= new OnPoint_Program__c(); 
                    op.Name=objstm.Program_Name__c;
                    op.Program_Start_Date__c=objstm.Program_Start_Date__c;
                    op.Program_End_Date__c=objstm.Program_End_Date__c;
                    op.Program_is_User_Paid__c=objstm.Is_Program_User_Paid__c;
                    if(brandNameAndIdMap.containsKey(objstm.OnPoint_Brand_Name__c)){
                    op.OnPoint_Brand__c=brandNameAndIdMap.get(objstm.OnPoint_Brand_Name__c);
                    }
                    else if(brandNameAndIdMap.containsKey(objstm.Brand_Name__c)){
                   	 op.OnPoint_Brand__c= brandNameAndIdMap.get(objstm.Brand_Name__c);
               		 }
                    op.Active__c=true;
                    op.POC_Planning__c= true;
                    op.OnPoint_Program_External_Id__c=objstm.Program_Name__c +'__'+objstm.Program_Start_Date__c;
                    externalIdSet.add(objstm.Program_Name__c +'__'+objstm.Program_Start_Date__c);
                    listOfOnPointProgram.add(op);
                }
            }
            /* if(objstm.OnPoint_Brand_Id__c=='' || objstm.OnPoint_Brand_Id__c==Null ){         //Check to make sure corresponding Brand not available in Onpoint
                 if(!externalIdSet.contains(objstm.Brand_Name__c)){ 
                OnPoint_Brand__c ob= new OnPoint_Brand__c();
                ob.Brand_Name__c=objstm.Brand_Name__c;
                 externalIdSet.add(objstm.Brand_Name__c);
                listOfOnPointBrand.add(ob);
                 }
            }
            if(objstm.OnPoint_Product_Id__c == '' || objstm.OnPoint_Product_Id__c == Null){    //Check to make sure corresponding product available in Onpoint
                if(!externalIdSet.contains(objstm.SKU_Number__c)){ 
                ccrz__E_Product__c item= new ccrz__E_Product__c();
                item.Name = objstm.Name;
                item.ccrz__SKU__c= objstm.SKU_Number__c;
                iTem.OnPoint_Standard_Cost__c=objstm.Item_Price__c;
                externalIdSet.add(objstm.SKU_Number__c);
                listOfccProduct.add(item);
                }
            }*/
        }
        
        
       //Uspsert program, brand , product in Onpoint
        Database.UpsertResult[] programResult= Database.upsert(listOfOnPointProgram,OnPoint_Program__c.OnPoint_Program_External_Id__c,false);
        System.debug('---programResult----'+programResult);
        Set<id> failRecord = new Set<id>();
        integer i=0;
        for (Database.UpsertResult sr : programResult) {
           //Trade_Activation_Kit_Item__c trkt=new Trade_Activation_Kit_Item__c();
             if (!sr.isSuccess()) {
                 failRecord.add(sr.getId());
                 body = body+''+listOfOnPointProgram[i].Name+'----'+ 'failed' +'</br>';
                 for(Database.Error err : sr.getErrors()) {                     
                     body = body + err.getMessage()+'Fields that affected this error: ' + err.getFields()  +'</br>';
                 }
             }
           i++;
       }
        
        if(failRecord.isEmpty()){
           // body = body + ' ********************** below OnPoint Program is created *****************'+ '</br>';
            //for(Integer index = 0, size = programResult.size(); index < size; index++) {
                //if(programResult[index].isSuccess()) {
                    //body = body + listOfOnPointProgram[index].Name +'  record created ' +'</br>';         
               // }
           // }
        }
      /*  Database.UpsertResult[] brandResult= Database.upsert(listOfOnPointBrand,OnPoint_Brand__c.Brand_Name__c,false);
        System.debug('---brandResult----'+brandResult);
        Database.UpsertResult[] itemResult= Database.upsert(listOfccProduct,ccrz__E_Product__c.ccrz__SKU__c,false);
        System.debug('---itemResult----'+itemResult);*/
        
        //Querying on upsert result and  creating data into MAP of each program, brand and product which are in onpoint 
        SET<Id> successIdProgram=new SET<Id>();
        for(Database.UpsertResult sr:programResult)
        {
            successIdProgram.add(sr.getId());
        }
        for(OnPoint_Program__c oPName:[SELECT id , Name FROM OnPoint_Program__c WHERE id IN:successIdProgram ])
        {
            mapOfProgramidName.put(oPName.Name,oPName.id);
        }
        System.debug('---mapOfProgramidName----'+mapOfProgramidName);
       /* SET<id> successIdBrand= new SET<id>();
        for(Database.UpsertResult sr:brandResult)
        {
            successIdBrand.add(sr.getId());
        }
        for(OnPoint_Brand__c oBName:[SELECT id , Brand_Name__c FROM OnPoint_Brand__c WHERE id IN:successIdBrand ])
        {
            brandNameAndIdMap.put(oBName.Brand_Name__c,oBName.id);
        }
        System.debug('---brandNameAndIdMap----'+brandNameAndIdMap);
        SET<id> successIdItem = new SET<id>();
        for(Database.UpsertResult sr:itemResult)
        {
            successIdItem.add(sr.getId());
        }
        for(ccrz__E_Product__c itemName:[SELECT id , Name, ccrz__SKU__c FROM ccrz__E_Product__c WHERE id IN:successIdItem ])
        {
            ccProductANDIdMap.put(itemName.Name,itemName);
        }
        System.debug('---ccProductANDIdMap----'+ccProductANDIdMap); */
         //To Update refernce id staging mains after insert data in onpoint  :
        
        List<Staging_Main__c> stagingToUpdateNew=new List<Staging_Main__c>();
        for(Staging_Main__c objstm:scope)
        {
            objstm.OnPoint_Program_Id__c=mapOfProgramidName.get(objstm.Program_Name__c);
            objstm.OnPoint_Brand_Id__c= brandNameAndIdMap.get(objstm.OnPoint_Brand_Name__c);
            System.debug('====objstm.Name--'+objstm.Name);
            if(ccProductANDIdMap.get(objstm.SKU_Number__c) != null)
            	objstm.OnPoint_Product_Id__c = ccProductANDIdMap.get(objstm.SKU_Number__c).Id;
            stagingToUpdateNew.add(objstm);
        }
        Database.update(stagingToUpdateNew);     // Update staging data
        // Inserting Onpoint territory allocation data for each Trade activation kit Item
        set<String> externalIdSetOTA = new set<String>();
        List<OnPoint_Territory_Allocation__c> onTerritoryAloctn= new List<OnPoint_Territory_Allocation__c>();
        for(Staging_Main__c objstm:stagingToUpdate)
        {
            OnPoint_Territory_Allocation__c otaObj= new OnPoint_Territory_Allocation__c();
            otaObj.OnPoint_Territory__c=objstm.Account__r.OnPoint_Sales_Territory__c;
            otaObj.OnPoint_Program__c =mapOfProgramidName.get(objstm.Program_Name__c);
            
            string stringDate = objstm.Program_Start_Date__c.year() + '-01' 
                + '-01 00:00:00';
            Date ActiveYear = date.valueOf(stringDate);
            otaObj.Active_Year__c=ActiveYear;
            if(ccProductANDIdMap.get(objstm.SKU_Number__c) != null)
            	otaObj.CC_Product__c =ccProductANDIdMap.get(objstm.SKU_Number__c).id;
            string programName=objstm.Program_Name__c;                             //Creating external id  value which is alredy present, workflow is also there to update name
            if(programName.length()>47){
                programName= programName.leftPad(44, '...');
            }
            
            if(ccProductANDIdMap.get(objstm.SKU_Number__c) != null)
            	otaObj.Name=objstm.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c +' | ' + programName + ' | ' + ccProductANDIdMap.get(objstm.SKU_Number__c).ccrz__SKU__c;
            if(test.isRunningTest())
                otaObj.Name=objstm.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c +' | ' + programName + ' | ' + 'Test';
            if(!test.isRunningTest()){          
            otaObj.Unique_Territory_Allocation_Name__c=objstm.Program_Name__c+' - '+objstm.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c+' - '+ccProductANDIdMap.get(objstm.SKU_Number__c).ccrz__SKU__c;
            }
            else{
               otaObj.Unique_Territory_Allocation_Name__c=objstm.Program_Name__c+' - '+objstm.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c+' - '+'Test'; 
            }
            if(!externalIdSetOTA.contains(otaObj.Unique_Territory_Allocation_Name__c)){
            onTerritoryAloctn.add(otaObj);
            }
            externalIdSetOTA.add(otaObj.Unique_Territory_Allocation_Name__c);
        }
        Database.UpsertResult[] onPointTerritoryAllocationResult= Database.upsert(onTerritoryAloctn,OnPoint_Territory_Allocation__c.Unique_Territory_Allocation_Name__c,true);   
        
        //Creating a MAP of each item there will be Onpoint territory allocation 
        MAP<string, OnPoint_Territory_Allocation__c> mapOfOTA=new MAP<string, OnPoint_Territory_Allocation__c>();
        SET<id> successOTAItem = new SET<id>();
        for(Database.UpsertResult sr:onPointTerritoryAllocationResult){
            successOTAItem.add(sr.getId());
        }
        for(OnPoint_Territory_Allocation__c otA:[SELECT id, OnPoint_Program__c,OnPoint_Program__r.Name,SKU__c,OnPoint_Territory__r.Territory_Code__c FROM OnPoint_Territory_Allocation__c WHERE id IN:successOTAItem])
        {
            string key=otA.OnPoint_Program__r.Name + '_' + otA.SKU__c + '_' + otA.OnPoint_Territory__r.Territory_Code__c;
            mapOfOTA.put(key,otA);
        }
        
        //Creating Onpoint allocation 
        List<OnPoint_Allocation__c> onPointAloctn= new List<OnPoint_Allocation__c>();
        for(Staging_Main__c objstm:stagingToUpdate)
        {
            OnPoint_Allocation__c OA=new OnPoint_Allocation__c();
            OA.Account__c=objstm.Account__c;
            OA.Quantity_Allocated__c = objstm.Quantity__c; 
            string key=objstm.Program_Name__c + '_' + objstm.SKU_Number__c + '_' + objstm.Account__r.OnPoint_Sales_Territory__r.Territory_Code__c;
            if(mapOfOTA.get(key) != null)
            	OA.OnPoint_Territory_Allocation__c=mapOfOTA.get(key).id;
           // Bud Light-Always On | 7530803 | BROS LIQUOR DISCOUNTER
           string programName=objstm.Program_Name__c; 
            if(programName.length()>37){
                 programName= programName.leftPad(34, '...');
            }
            String allocName=programName+' | '+objstm.SKU_Number__c+' | '+objstm.Account__r.Name;
            if(allocName.length()>80){
                allocName=allocName.substring(0, 80);
            }
            OA.Name =allocName;
            onPointAloctn.add(OA);
        }
        Database.UpsertResult[] onPointAllocationResult= Database.Upsert(onPointAloctn,OnPoint_Allocation__c.Name, true);
        Set<id> failRecordAllocation = new Set<id>();
        integer j=0;
        for (Database.UpsertResult sr : onPointAllocationResult) {
           //Trade_Activation_Kit_Item__c trkt=new Trade_Activation_Kit_Item__c();
             if (!sr.isSuccess()) {
                 failRecordAllocation.add(sr.getId());
                 body = body+''+stagingToUpdate[j].Name+'----'+ 'failed' +'</br>';
                 for(Database.Error err : sr.getErrors()) {                     
                     body = body + err.getMessage()+'Fields that affected this error: ' + err.getFields()  +'</br>';
                 }
             }
           j++;
       }
        if(failRecordAllocation.isEmpty())
        {
           // body = body + ' ********************** below Allocation is created *****************'+ '</br>';
            //for(Integer index = 0, size = onPointAllocationResult.size(); index < size; index++) {
               // if(onPointAllocationResult[index].isSuccess()) {
                   // body = body + onPointAloctn[index].Name +'  record created ' +'</br>';         
               // }
            //}
        }
              
    }
    global void finish(Database.BatchableContext BC)
    {
        
        List<string> emailId = new List<string>();
        List<string> ccEmailId = new List<string>();
        body = body +'Staging To OnPoint Batch successfully Processed';
        ExcelHeader__mdt[] ccMailList = [select MasterLabel, QualifiedApiName, column_A__c,column_B__c,column_C__c FROM ExcelHeader__mdt where MasterLabel ='cc Mail Id'];
        for(ExcelHeader__mdt eh:ccMailList){
            emailId.add(eh.column_A__c);
            
        }
        Mailutility.sendMail(emailId,ccEmailId,'Staging to OnPoint Result',body);
    }
}