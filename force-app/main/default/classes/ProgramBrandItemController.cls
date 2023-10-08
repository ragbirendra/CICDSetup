/***
* @Name - ProgramBrandItemController
* @Author - Cognizant developers
* @CreatedDate -09/15/2019
* @Description - 
* 

***/


public class ProgramBrandItemController {
@AuraEnabled(cacheable=true)
    public static list<itemWrapper> getData(string ProgramName, string yearToCompare, string status,string selectedBusinessLine){
       
        system.debug('====ProgramName-'+ProgramName);
        List<Program_Brands_Item__c> tradeActivationList=[SELECT OwnerId,Atlantic__c,Brand_Name__c,Business_Line__c,Currency_a__c,CurrencyIsoCode,Currency_b__c,FOR_DRIVERS_ONLY__c,Full_Price_to_Rep__c,
                   IH_Item_Classification__c,Year__c,Is_Available__c,Is_IH_Only__c,Item_Description_EN__c,Item_Description_FR__c,Item_Type__c,Language__c,Menu_Category__c,
                   Ontario__c,OOH_Item_Classification__c,User_Paid__c,Parent_Product_Types__c,Product_Type__c,
                   Planning_End_Date__c,Planning_Start_Date__c,Product_Name__c,Name,Is_Program_Only__c,
                   Program_Descritpion__c,Program_End_Date__c,Program_Name__c,Program_Start_Date__c,Item_Classification__c,
                   Quantity_per_UOM__c,Quebec__c,SAP_Item_Number__c,Size__c,Standard_Price__c,Status_of_Approval__c,
                   Temp_Item_Number__c,Unit_of_Measure__c,West__c,Image_Link__c from Program_Brands_Item__c  
                                                         WHERE Program_Name__c=: ProgramName 
                                                         AND Status_of_Approval__c=: status
                                                         AND Business_Line__c =:selectedBusinessLine
                                                         AND Year__c =:yearToCompare ];//AND Program_Start_Date__c >=:yearToCompare
        list<itemWrapper> oListViewWrapper = new list<itemWrapper>();
        for(Program_Brands_Item__c pbi:tradeActivationList)
        {
            itemWrapper obj= new itemWrapper();
            
            obj.BrandName=pbi.Brand_Name__c;
            obj.ProgramName=pbi.Program_Name__c;
           // obj.itemName=pbi.Name;
            obj.Status=pbi.Status_of_Approval__c;
          	obj.SAPItemNumber=pbi.SAP_Item_Number__c;
            obj.TempItemNumber=pbi.Temp_Item_Number__c;
            obj.ProgramStartDate= pbi.Program_Start_Date__c;
            obj.ProgramEndDate= pbi.Program_End_Date__c;
            obj.PlanningStartDate= pbi.Planning_Start_Date__c;
            obj.PlanningEndDate= pbi.Planning_End_Date__c;
            obj.ProgramDescritpion=pbi.Program_Descritpion__c;
            obj.Language=pbi.Language__c;
            obj.ItemDescriptionEN= pbi.Item_Description_EN__c;
            obj.ItemDescriptionFR=pbi.Item_Description_FR__c;
            obj.StandardPrice=pbi.Standard_Price__c;
            obj.FullPriceToRep=pbi.Full_Price_to_Rep__c;
            obj.ItemClassification=pbi.Item_Classification__c;
            //obj.ItemClassification=pbi.OOH_Item_Classification__c;
            obj.MenuCategory=pbi.Menu_Category__c;
            obj.BusinessLine=pbi.Business_Line__c;
            obj.ProductName=pbi.Product_Name__c;
           
            obj.Size=pbi.Size__c;
            obj.UnitOfMeasure=pbi.Unit_of_Measure__c;
            obj.Currency2=pbi.Currency_b__c;
            obj.QuantityPerUOM=pbi.Quantity_per_UOM__c;
            obj.ItemType=pbi.Item_Type__c;
            if(pbi.Atlantic__c == true){
            obj.Atlantic= 'Yes';
            }
            if(pbi.Atlantic__c == false){
            obj.Atlantic= 'No';
            }
            if(pbi.Quebec__c == true){
            obj.Quebec= 'Yes';
            }
            if(pbi.Quebec__c == false){
            obj.Quebec= 'No';
            }
            if(pbi.Ontario__c == true){
            obj.Ontario= 'Yes';
            }
            if(pbi.Ontario__c == false){
            obj.Ontario= 'No';
            }
            if(pbi.West__c == true){
            obj.West= 'Yes';
            }
            if(pbi.West__c == false){
            obj.West= 'No';
            }
            obj.ParentProductType=pbi.Parent_Product_Types__c;
            obj.ProductType=pbi.Product_Type__c;
            obj.Year=pbi.Year__c;
            if(pbi.Is_Program_Only__c == true){
            obj.IsAllocationOnly= 'Yes';
            }
            if(pbi.Is_Program_Only__c == false){
            obj.IsAllocationOnly= 'No';
            }
             if(pbi.User_Paid__c == true){
            obj.isUserPaid= 'Yes';
            }
            if(pbi.User_Paid__c == false){
            obj.isUserPaid= 'No';
            }
            
            //obj.IsAllocationOnly=pbi.Is_Program_Only__c;
            oListViewWrapper.add(obj);        
        }
        return oListViewWrapper;
        
    }
    
    public class itemWrapper{
        @AuraEnabled public string recordId{get;set;} 
        @AuraEnabled public string ProgramName{get;set;} 
        @AuraEnabled public String ParentProductType{get;set;} 
        @AuraEnabled public String ProductType{get;set;} 
        @AuraEnabled public string Status{get;set;} 
        @AuraEnabled public string BrandName{get;set;}
        @AuraEnabled public string BusinessLine{get;set;} 
        @AuraEnabled public decimal FullPriceToRep{get;set;}
        @AuraEnabled public boolean IsAvailable{get;set;} 
        @AuraEnabled public boolean IsIHOnly{get;set;}
        @AuraEnabled public string ItemDescriptionEN{get;set;} 
        @AuraEnabled public string ItemDescriptionFR{get;set;} 
        @AuraEnabled public string ItemType{get;set;}
        @AuraEnabled public string Language{get;set;} 
        @AuraEnabled public string MenuCategory{get;set;} 
        @AuraEnabled public string IHItemClassification{get;set;} 
        @AuraEnabled public string OOHItemClassification{get;set;}
        @AuraEnabled public string PlanningEndDate{get;set;} 
        @AuraEnabled public string PlanningStartDate{get;set;}
        @AuraEnabled public string ProductName{get;set;} 
        @AuraEnabled public string ProgramDescritpion{get;set;} 
        @AuraEnabled public string ProgramEndDate{get;set;}
        @AuraEnabled public string ProgramStartDate{get;set;}
        @AuraEnabled public string ItemClassification{get;set;}
        @AuraEnabled public decimal Quantity{get;set;}
        @AuraEnabled public string Quebec{get;set;} 
        @AuraEnabled public string Ontario{get;set;}   
        @AuraEnabled public string Atlantic{get;set;} 
        @AuraEnabled public string West{get;set;}
        @AuraEnabled public string SAPItemNumber{get;set;} 
        @AuraEnabled public decimal StandardPrice{get;set;}
        @AuraEnabled public string TempItemNumber{get;set;} 
        @AuraEnabled public string UnitOfMeasure{get;set;} 
        @AuraEnabled public String Image{get;set;}
        @AuraEnabled public String isUserPaid{get;set;}
        @AuraEnabled public String ImageLink{get;set;}
        @AuraEnabled public String IsAllocationOnly{get;set;}
        @AuraEnabled public String rejectionComment{get;set;}
        @AuraEnabled public String Year{get;set;}
        @AuraEnabled public String Size{get;set;}
        @AuraEnabled public String Currency2{get;set;}
        @AuraEnabled public decimal QuantityPerUOM{get;set;}
        
    
    }
    
   @AuraEnabled(cacheable=true)
    public static List<string> getStatusData(string yearVal,string selectedProgram)
    {
        system.debug('yearrrr'+yearVal);
        system.debug('selectedProgram'+selectedProgram);
        List<String> listValue= new List<String>();
        Set<String> setValue= new SET<String>();
        List<Program_Brands_Item__c> tradeActivationList=[SELECT  Year__c,Program_Name__c,Status_of_Approval__c  
                                                          FROM Program_Brands_Item__c
                                                          where  Program_Name__c=:selectedProgram];
        for(Program_Brands_Item__c obj:tradeActivationList)
        {setValue.add(obj.Status_of_Approval__c); 
        }
        listValue.addAll(setValue);
        system.debug('statusvaluesss---'+listValue);
        return listValue;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<string> getBusinessLineData()
    {
        List<String> listValue= new List<String>();
        Set<String> setValue= new SET<String>();
        List<Program_Brands_Item__c> tradeActivationList=[SELECT Business_Line__c  FROM Program_Brands_Item__c];
        for(Program_Brands_Item__c obj:tradeActivationList)
        {  setValue.add(obj.Business_Line__c); 
        }
        listValue.addAll(setValue);
        return listValue;
    }
    @AuraEnabled(cacheable=true)
    public static List<string> getProgramData(string year)
    {
        List<String> listValue= new List<String>();
        Set<String> setValue= new SET<String>();
        List<Program_Brands_Item__c> tradeActivationList=[SELECT  Year__c,Program_Name__c FROM Program_Brands_Item__c where Year__c =: year];
        for(Program_Brands_Item__c obj:tradeActivationList)
        {
            setValue.add(obj.Program_Name__c); 
        }
        listValue.addAll(setValue);
        return listValue;
    }
     
    
}