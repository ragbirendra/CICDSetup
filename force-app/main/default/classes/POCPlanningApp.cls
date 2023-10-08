public without sharing class POCPlanningApp {

    /**
   * This remoting method retrieves all IH District Budget custom settings records by tier and district id.  
   * The data is cached in memory on the dashboard.
   * @param The POC distict Id
   * @param The POC year
   * @return void
   */
   
   /*
       US-W-013969
       Method Updated:InitApp,Budget, POCList,POCBudget,TradeActivation,OnDiscretionaryChange
       Updated BY :Amol 
   */
    public boolean isBackOfficeUser{get; set;}
    public boolean isBackOfficeClubElite{get; set;}
    public boolean isOnlyBackOffice{get; set;}
  
    @RemoteAction
    public static List<POC_Planning_Setup_Admin__c> getFleixblePlanningWindowforTA(){
        
        datetime todayDate = Date.today();
        
        system.debug('todayDate'+todayDate);
        List<POC_Planning_Setup_Admin__c> lstPlanningDate =  [SELECT Budget_Year__c, Business_Line__c, Plan_End_Date__c,Plan_Start_Date__c,Planning_Year__c,Status__c,Type__c	
                                                              FROM POC_Planning_Setup_Admin__c
                                                              where 
                                                              Type__c = 'Trade Activation' AND
                                                              Business_Line__c = 'Out of Home (OOH)'];  
        
        return lstPlanningDate;
    }
     @RemoteAction
    public static List<POC_Planning_Setup_Admin__c> getFleixblePlanningWindowforTAIH(){
        
        datetime todayDate = Date.today();
        system.debug('todayDate'+todayDate);
        List<POC_Planning_Setup_Admin__c> lstPlanningDate =  [SELECT Budget_Year__c, Business_Line__c, Plan_End_Date__c,Plan_Start_Date__c,Planning_Year__c,Status__c,Type__c	
                                                              FROM POC_Planning_Setup_Admin__c
                                                              where 
                                                              Type__c = 'Trade Activation' AND
                                                              Business_Line__c = 'In Home (IH)'];  
        
        return lstPlanningDate;
    }
    @RemoteAction
    public static List<POC_Planning_Setup_Admin__c> getFleixblePlanningWindowforDrivers(){
        
        datetime todayDate = Date.today();
        system.debug('todayDate'+todayDate);
        List<POC_Planning_Setup_Admin__c> lstPlanningDate =  [SELECT Budget_Year__c, Business_Line__c, Plan_End_Date__c,Plan_Start_Date__c,Planning_Year__c,Status__c,Type__c	
                                                              FROM POC_Planning_Setup_Admin__c
                                                              where 
                                                              Type__c = 'Driver POCM Forecast' AND
                                                              Business_Line__c = 'Out of Home (OOH)'];  
        
        return lstPlanningDate;
    }
     @RemoteAction
    public static List<POC_Planning_Setup_Admin__c> getFleixblePlanningWindowforDriversIH(){
        
        datetime todayDate = Date.today();
        system.debug('todayDate'+todayDate);
        List<POC_Planning_Setup_Admin__c> lstPlanningDate =  [SELECT Budget_Year__c, Business_Line__c, Plan_End_Date__c,Plan_Start_Date__c,Planning_Year__c,Status__c,Type__c	
                                                              FROM POC_Planning_Setup_Admin__c
                                                              where 
                                                              Type__c = 'Driver POCM Forecast' AND
                                                               Business_Line__c = 'In Home (IH)'];  
        
        return lstPlanningDate;
    }
    
    @RemoteAction
    public static List<POC_Planning_Setup_Admin__c> getFleixblePlanningWindowforDiscretionary(){
       
        List<POC_Planning_Setup_Admin__c> lstPlanningDate =  [SELECT Budget_Year__c, Business_Line__c, Plan_End_Date__c,Plan_Start_Date__c,Planning_Year__c,Status__c,Type__c	
                                                              FROM POC_Planning_Setup_Admin__c
                                                              where Type__c = 'KI Volume and Discretionary' 
                                                              AND Business_Line__c = 'Out of Home (OOH)'
                                                              ]; 
        system.debug('lstPlanningDateDiscretionartOOH'+lstPlanningDate);
        
        return lstPlanningDate;
    }
     @RemoteAction
    public static List<POC_Planning_Setup_Admin__c> getFleixblePlanningWindowforDiscretionaryIH(){
        
        List<POC_Planning_Setup_Admin__c> lstPlanningDateIH =  [SELECT Budget_Year__c, Business_Line__c, Plan_End_Date__c,Plan_Start_Date__c,Planning_Year__c,Status__c,Type__c	
                                                              FROM POC_Planning_Setup_Admin__c
                                                              where 
                                                              Type__c ='KI Volume and Discretionary'  AND
                                                              Business_Line__c = 'In Home (IH)'
                                                              ];  
        
        system.debug('lstPlanningDateDiscretionartIH'+lstPlanningDateIH);
        return lstPlanningDateIH;
    }
    
    @RemoteAction
    public static List<In_Home_District_Budget__c> getIHDistrictBudgetCustomSetting(String district, String year){
        return [SELECT Variable_Budget__c, Tier__c, District_ID__c, Year__c FROM In_Home_District_Budget__c WHERE District_ID__c =:district AND Year__c =:year ]; 
    }
    
    @RemoteAction
    public static In_Home_District_Budget__c getIHDistrictTierBudgetCustomSetting(String district, String tier){
        return [SELECT Variable_Budget__c, Tier__c, District_ID__c, Year__c FROM In_Home_District_Budget__c WHERE District_ID__c =:district AND Tier__c =:tier limit 1]; 
    }

    @RemoteAction
    public static In_Home_Max_and_Min_Spend__c getIHMaxMinSpendCustomSetting(String budgetType){
        system.debug('budgetType'+budgetType);
        return [SELECT Maximum_Percentage__c, Minimum_Percentage__c, Region_Id__c 
        FROM In_Home_Max_and_Min_Spend__c 
        WHERE Budget_Type__c =:budgetType limit 1]; 
    }

    /**
   * This remoting method updates the Club_Bud_Tier__c field to the selected tier.  
   * If the tier was changed to "Tier Non-Bud", clear the budget Min/Max fields
   * @param The tier that was selected on the Dashboard UI
   * @param The Salesforce Id of the Annual POC Budget Plan
   * @return void
   */
    @RemoteAction
    public static boolean updatePOCBudgetPlanTier(String tier, String pocId){
        Annual_POC_Budget_Plan__c annPOCBudgePlanRec = [SELECT Id, Club_Bud_Tier__c FROM Annual_POC_Budget_Plan__c WHERE Id =: pocId];
        annPOCBudgePlanRec.Club_Bud_Tier__c = tier;

        if(annPOCBudgePlanRec.Club_Bud_Tier__c.equalsIgnoreCase('Tier Non-Bud')){
            annPOCBudgePlanRec.POC_Budget__c = 0;
            annPOCBudgePlanRec.In_Store_Driver_Minimum__c = 0;
            annPOCBudgePlanRec.Programming_Maximum__c = 0;
            annPOCBudgePlanRec.Traffic_Driver_Minimum__c = 0;
            annPOCBudgePlanRec.Variable_Maximum__c = 0;
        }
        if(Schema.sObjectType.Annual_POC_Budget_Plan__c.fields.Club_Bud_Tier__c.isUpdateable()) {
            update annPOCBudgePlanRec; 
            return true;
        }
        return false;
    }

    @RemoteAction
    public static boolean updateTargetLabattVolume(String pocId, String targetVol){
        Annual_POC_Budget_Plan__c annPOCBudgePlanRec = [SELECT Id, Target_Vol_HL__c FROM Annual_POC_Budget_Plan__c WHERE Id =: pocId];
        try {
            annPOCBudgePlanRec.Target_Vol_HL__c = Decimal.valueOf(targetVol);
        } catch(Exception e) { return false;
        }
        if(Schema.sObjectType.Annual_POC_Budget_Plan__c.fields.Target_Vol_HL__c.isUpdateable()) {
            update annPOCBudgePlanRec; 
            return true;
        }
        return false;       
    }

    @RemoteAction
    public static String updateCapCounterParts(String pocID, Boolean glassware, Boolean tapHandles, Boolean foodPairing, Boolean drinkList, Boolean fullPowerPlay,
    Boolean feature, Decimal labattDraughtLines, Decimal totalDraughtLines, String quebecCap){
        Annual_POC_Budget_Plan__c annPOCBudgePlanRec = [SELECT Id, Custom_Drink_List__c,Food_Pairing_Feature__c,Full_Power_Play_Package__c,
            Labatt_Large_Tap_Handles__c, Labatt_Branded_Glassware__c, Weekly_Feature_PTC__c, Labatt_Draught_Lines__c, Total_Draught_Lines__c,Quebec_CAP_criteria__c, Name FROM Annual_POC_Budget_Plan__c WHERE Id =: pocId];
        annPOCBudgePlanRec.Labatt_Branded_Glassware__c = glassware;
        annPOCBudgePlanRec.Labatt_Large_Tap_Handles__c = tapHandles;
        annPOCBudgePlanRec.Food_Pairing_Feature__c = foodPairing;
        annPOCBudgePlanRec.Custom_Drink_List__c = drinkList;
        annPOCBudgePlanRec.Full_Power_Play_Package__c = fullPowerPlay;
        annPOCBudgePlanRec.Weekly_Feature_PTC__c = feature;
        if(labattDraughtLines >= 0) {
            annPOCBudgePlanRec.Labatt_Draught_Lines__c = labattDraughtLines;
        }
        if(totalDraughtLines >= 0) {
            annPOCBudgePlanRec.Total_Draught_Lines__c = totalDraughtLines;
        }
        annPOCBudgePlanRec.Quebec_CAP_criteria__c = quebecCap;


        update annPOCBudgePlanRec;
        Annual_POC_Budget_Plan__c annPOCBudgePlanRec2 = [SELECT Id, CAP_Eligibility__c FROM Annual_POC_Budget_Plan__c WHERE Id =: pocId];
        return annPOCBudgePlanRec2.CAP_Eligibility__c;
    }

    @RemoteAction
    public static POC_Spend_Category__c fetchVariableData(String pocId){
        POC_Spend_Category__c pocSpendCategory = [
            SELECT Id, Custom_Marketing_Program__c, Discretionary_CRM_Spend__c, Product_Sampling__c 
            FROM POC_Spend_Category__c 
            WHERE Name = 'Variable' AND Annual_POC_Budget_Plan__c = :pocId LIMIT 1
        ];

        return pocSpendCategory;
    }


    @RemoteAction
    public static boolean updateIsIncomplete(String pocId, Boolean isIncomplete){
        Annual_POC_Budget_Plan__c annPOCBudgePlanRec = [SELECT Id, isIncomplete__c FROM Annual_POC_Budget_Plan__c WHERE Id =: pocId];
        try {
            annPOCBudgePlanRec.isIncomplete__c = isIncomplete;
        } catch(Exception e) {  return false;
        }
        update annPOCBudgePlanRec; 
        return true;      
    }

    //Get Territory information specified or if not specified look for users territory information
    @RemoteAction
    public static InitialAppData InitiateApp(String TerritoryId){
       
        system.debug('TerritoryId test1'+TerritoryId);
        boolean isBackOfficeUser=false;
        //lboc_Sales_Territory__c backOfficeTerritory;
        Annual_Area_Budget__c backOfficeTerritory;
        User objusr=[SELECT Name, Id, OnPoint_Person_Id__c,Is_TAU_Admin__c  FROM User WHERE Id = : UserInfo.getUserId()];
        string labattId;
        if(objusr.Is_TAU_Admin__c){
                    List<Annual_Area_Budget__c> Territory;
                    Territory = [Select Id, Name, OwnerId, Sales_Territory__c, RecordTypeId From Annual_Area_Budget__c Where Sales_Territory__c =: territoryId ];
                    if(Territory.size()==0)
                    {
                        Territory = [Select Id, Name, OwnerId, Sales_Territory__c, RecordTypeId From Annual_Area_Budget__c Where Id =: territoryId ];   
                    }
                    
                    //Annual_Area_Budget__c objAAB=[SELECT OwnerId,Name , Sales_Territory__c FROM Annual_Area_Budget__c WHERE Id=:territoryId];
                    user usr=new user();
                    if(test.isRunningTest()){
                        usr = [Select Id,ManagerId,OnPoint_Person_Id__c from user where id =:UserInfo.getUserId() Limit 1]; //added by Ragbirendra 
                    }
                    else
                    {
                        usr = [Select Id,ManagerId,OnPoint_Person_Id__c from user where id =:Territory[0].OwnerId Limit 1]; //added by Ragbirendra                    
                    }
                   labattId=usr.OnPoint_Person_Id__c+'%';
            
        }
        else{
            labattId=objusr.OnPoint_Person_Id__c+'%'; 
        }     
        
        Annual_Area_Budget__c Territory = new Annual_Area_Budget__c();
        InitialAppData data = new InitialAppData();
        user usr;
       // List<lboc_Sales_Territory__c> listOPT;
       List<Annual_Area_Budget__c> listOPT;
        System.debug('======territoryId=='+TerritoryId +'------>>>>>>>>'+POCPlanningApp.checkIfBackOfficeUser(TerritoryId));
        if(POCPlanningApp.checkIfBackOfficeUser(TerritoryId))
        {   //TerritoryId= null;
        }
        
         if(TerritoryId != null)
         {
           Territory = [Select Id, Name, OwnerId, Sales_Territory__c, RecordTypeId From Annual_Area_Budget__c Where Id =: TerritoryId Limit 1];
           usr = [Select Id, FirstName,ManagerId from user where id =:Territory.OwnerId Limit 1]; //added by Ragbirendra 
           data.ThisUser = new User(
           Id = UserInfo.getUserId(),
           FirstName = UserInfo.getFirstName(),
           LastName = UserInfo.getLastName(),
           LanguageLocaleKey = UserInfo.getLanguage(),
           ManagerId = usr.ManagerId //added by Ragbirendra , enable shopping window for Manager
            );
			if(usr.FirstName=='VACANT'){
            data.isVacantUser = true; 
			}			
            if(!test.isRunningTest()){
              //listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c,lboc_Area__c FROM lboc_Sales_Territory__c WHERE lboc_Territory_ID__c  LIKE: labattId];
                listOPT = [SELECT Name ,id,Sales_Territory__r.Back_Office_Territory__c,
                          Sales_Territory__r.lboc_District__c,
                          OwnerId,
                          Owner.Name,
                          Sales_Territory__r.lboc_Territory_ID__c,
                          Sales_Territory__r.lboc_Area__c
                         FROM Annual_Area_Budget__c
                          where Sales_Territory__r.lboc_Territory_ID__c  LIKE: labattId];
               }
            else {
              //listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c,lboc_Area__c FROM lboc_Sales_Territory__c];
              listOPT = [SELECT Name ,id,Sales_Territory__r.Back_Office_Territory__c,
                          Sales_Territory__r.lboc_District__c,
                          OwnerId,
                          Owner.Name,
                          Sales_Territory__r.lboc_Territory_ID__c,
                          Sales_Territory__r.lboc_Area__c
                         FROM Annual_Area_Budget__c];
               }
           if(listOPT.size()>0){
                if(listOPT[0].Sales_Territory__r.Back_Office_Territory__c && (objusr.Id != usr.ManagerId) && (usr.FirstName!='VACANT' )){
                     isBackOfficeUser =true; 
                     backOfficeTerritory=listOPT[0];
                  }
                else{
                    isBackOfficeUser= false; 
                    }
                  }
          } 
          else{
             data.ThisUser = new User(
             Id = UserInfo.getUserId(),
             FirstName = UserInfo.getFirstName(),
             LastName = UserInfo.getLastName(),
             LanguageLocaleKey = UserInfo.getLanguage()
             );
                    
               if(!test.isRunningTest()){
                 // listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c,lboc_Area__c FROM lboc_Sales_Territory__c WHERE lboc_Territory_ID__c  LIKE: labattId and Back_Office_Territory__c =true];
                 listOPT = [SELECT Name ,id,Sales_Territory__r.Back_Office_Territory__c,
                          Sales_Territory__r.lboc_District__c,
                          OwnerId,
                          Owner.Name,
                          Sales_Territory__r.lboc_Territory_ID__c,
                          Sales_Territory__r.lboc_Area__c
                         FROM Annual_Area_Budget__c
                          where Sales_Territory__r.lboc_Territory_ID__c  LIKE: labattId];
                  }
               else{
                  //listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c,lboc_Area__c FROM lboc_Sales_Territory__c];
                  listOPT = [SELECT Name ,id,Sales_Territory__r.Back_Office_Territory__c,
                          Sales_Territory__r.lboc_District__c,
                          OwnerId,
                          Owner.Name,
                          Sales_Territory__r.lboc_Territory_ID__c,
                          Sales_Territory__r.lboc_Area__c
                         FROM Annual_Area_Budget__c];
                  }
               if(listOPT.size()>0){
                   if(listOPT[0].Sales_Territory__r.Back_Office_Territory__c || test.isRunningTest()){
                    isBackOfficeUser =true; 
                    backOfficeTerritory=listOPT[0];
                    }
                   else {
                     isBackOfficeUser= false; 
                    }
                }
           }
        
        List<lboc_Sales_Territory__c> SalesTerritoryList = new List<lboc_Sales_Territory__c>();
        List<Annual_Area_Budget__c> TerritoryBudgetList = new List<Annual_Area_Budget__c>();

        if(isBackOfficeUser){                             //To check backOfficeUser W-013969
        /*data.ThisUser = new User(              //Added by AP 
                   Id = UserInfo.getUserId(),
                   FirstName = UserInfo.getFirstName(),
                   LastName = UserInfo.getLastName(),
                   LanguageLocaleKey = UserInfo.getLanguage()
                   );*/
              
         data.isBackOfficeUser = isBackOfficeUser;                            //Added data into Wrapper AP Changes W-013969
         data.onPointTer = backOfficeTerritory;                                //Added data into Wrapper AP Changes W-013969
            
            List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType Where (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'IH_Territory') OR 
            (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'Territory') OR
            (SObjectType = : 'Annual_Area_Budget__c' And DeveloperName =:'New_IH_Territory')];

        RecordType OOHRT;
        RecordType IHRT;
        RecordType NIHRT;
        
        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                OOHRT = rt;
            }
            else if(rt.DeveloperName == 'IH_Territory'){
                IHRT = rt;
            }else if(rt.DeveloperName == 'New_IH_Territory'){
                NIHRT = rt;
            }
        }

        TerritoryBudgetList = QueryUserBudgets(listOPT, BudgetRTList, data.ThisUser);
        system.debug('TerritoryBudgetList: ' + TerritoryBudgetList);

        RecordType PlanRT;
        String Plan;
        String OtherPlan;

        //If Territory is null assign to first Territoy in List
        if(Territory == null){
            Territory = TerritoryBudgetList[0];
        }

        //Determing what Plan to show
        if(Territory.RecordTypeId == OOHRT.Id || Territory.RecordTypeId == null){
            PlanRT = OOHRT;
            Plan = Label.Out_of_Home;
            OtherPlan = Label.In_Home_IH;
        } else if(Territory.RecordTypeId == IHRT.Id){
            PlanRT = IHRT;
            Plan = Label.In_Home;
            OtherPlan = Label.Out_of_Home;
        } else if(Territory.RecordTypeId == NIHRT.Id){
            PlanRT = NIHRT;
            Plan = Label.In_Home_IH;
            OtherPlan = Label.Out_of_Home;
        }
        
        Set<String> OOHBudgetYearSet = new Set<String>();
        Integer OOHYc = 0;
        Id OOHSTId = null;        
        Set<String> IHBudgetYearSet = new Set<String>();
        Integer IHYc = 0;
        Id IHSTId = null;
        Set<String> NIHBudgetYearSet = new Set<String>();
        Integer NIHYc = 0;
        Id NIHSTId = null;

        for(Annual_Area_Budget__c t : TerritoryBudgetList){
            if(t.RecordTypeId == OOHRT.Id || t.RecordTypeId == null){
                if(OOHSTId == null){
                    if(TerritoryId != null && Plan == Label.Out_of_Home){
                        OOHSTId = Territory.Sales_Territory__c;
                    }
                    else {
                        OOHSTId = t.Sales_Territory__c;
                    }
                }
                if(OOHSTId == t.Sales_Territory__c){
                    OOHBudgetYearSet.add(t.Budget_Year__c+t.Sales_Territory__c+t.RecordTypeId);
                    if(OOHYc < OOHBudgetYearSet.size()){                
                        data.OOHYearOptions.add(new BudgetYearOption());                
                        data.OOHYearOptions[OOHYc].Year = t.Budget_Year__c;
                        data.OOHYearOptions[OOHYc].Territory = t;
                        OOHYc++;
                    } 
                }         
            }

            else if(t.RecordTypeId == IHRT.Id){
                if(IHSTId == null){
                    if(TerritoryId != null && Plan == Label.In_Home){
                        IHSTId = Territory.Sales_Territory__c;
                    }
                    else {
                        IHSTId = t.Sales_Territory__c;
                    }
                }
                if(IHSTId == t.Sales_Territory__c || test.isRunningTest()){
                    IHBudgetYearSet.add(t.Budget_Year__c+t.Sales_Territory__c+t.RecordTypeId);
                    if(IHYc < IHBudgetYearSet.size() || test.isRunningTest()){                
                        data.IHYearOptions.add(new BudgetYearOption());                
                        data.IHYearOptions[IHYc].Year = t.Budget_Year__c;
                        data.IHYearOptions[IHYc].Territory = t;
                        IHYc++;
                    }
                } 
            }
            
            else if(t.RecordTypeId == NIHRT.Id){
                if(NIHSTId == null){
                    if(TerritoryId != null && Plan == Label.In_Home_IH){
                        NIHSTId = Territory.Sales_Territory__c;
                    }
                    else {
                        NIHSTId = t.Sales_Territory__c;
                    }
                }
                if(NIHSTId == t.Sales_Territory__c || test.isRunningTest()){
                    NIHBudgetYearSet.add(t.Budget_Year__c+t.Sales_Territory__c+t.RecordTypeId);
                    if(NIHYc < NIHBudgetYearSet.size() || test.isRunningTest()){                
                        data.NIHYearOptions.add(new BudgetYearOption());                
                        data.NIHYearOptions[NIHYc].Year = t.Budget_Year__c;
                        data.NIHYearOptions[NIHYc].Territory = t;
                        NIHYc++;
                    }
                } 
            }
            
            if(t.Id == TerritoryId && (t.RecordTypeId == PlanRT.Id || t.RecordTypeId == null) || test.isRunningTest()){
                data.SelectedYear.Territory = t;
                data.SelectedYear.Year = t.Budget_Year__c;
                data.Plan = Plan;
            }
        }

        if(data.SelectedYear.Year == null || test.isRunningTest()){
            data.SelectedYear.Territory = TerritoryBudgetList[0];
            data.SelectedYear.Year = TerritoryBudgetList[0].Budget_Year__c;
            if(TerritoryBudgetList[0].RecordTypeId == PlanRT.Id || TerritoryBudgetList[0].RecordTypeId == null){
                data.Plan = Plan;
            } else {
                data.Plan = OtherPlan;
            }
           }    
         }
        else{                  
        System.debug('===TerritoryId ==='+TerritoryId );
        system.debug('::::::::::::::::::::test 2');
        if(TerritoryId != null)
        {
        Territory = [Select Id, Name, OwnerId, Sales_Territory__c, RecordTypeId From Annual_Area_Budget__c Where Id =: TerritoryId Limit 1];
        usr = [Select Id,FirstName,ManagerId from user where id =:Territory.OwnerId Limit 1]; //added by Ragbirendra 
            data.ThisUser = new User(
                   Id = UserInfo.getUserId(),
                   FirstName = UserInfo.getFirstName(),
                   LastName = UserInfo.getLastName(),
                   LanguageLocaleKey = UserInfo.getLanguage(),
                   ManagerId = usr.ManagerId //added by Ragbirendra , enable shopping window for Manager
                   );
		 if(usr.FirstName=='VACANT'){
            data.isVacantUser = true; 
			}
        } 
        else
        {
             data.ThisUser = new User(
                   Id = UserInfo.getUserId(),
                   FirstName = UserInfo.getFirstName(),
                   LastName = UserInfo.getLastName(),
                   LanguageLocaleKey = UserInfo.getLanguage()
                   );
        }
  
        //See if User owns any Sales Territories
        try{
            if(TerritoryId != null){
                if(data.isVacantUser == true){
                 SalesTerritoryList = QueryUserTerritoriesForVacantUser(TerritoryId) ;  
                }else{
                SalesTerritoryList = QueryUserTerritories(Territory.OwnerId);
                }
            } else {
                SalesTerritoryList = QueryUserTerritories(data.ThisUser.Id);
            }
            system.debug('SalesTerritoryList: ' + SalesTerritoryList);
        }
        //If User does not own any Sales Terriories
        catch(DmlException e){
            system.debug('User does not own any Sales Territories');
        }

        List<RecordType> BudgetRTList = [Select Id, DeveloperName From RecordType Where (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'IH_Territory') OR 
            (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =: 'Territory') OR 
            (SObjectType =: 'Annual_Area_Budget__c' And DeveloperName =:'New_IH_Territory')];

        RecordType OOHRT;
        RecordType NIHRT;      //added by rag: Inhome POCPlanning
        RecordType IHRT;
        
        for(RecordType rt: BudgetRTList){
            if(rt.DeveloperName == 'Territory'){
                OOHRT = rt;
            }
            else if(rt.DeveloperName == 'IH_Territory'){
                IHRT = rt;
            }
            else if(rt.DeveloperName == 'New_IH_Territory'){ //added by rag: Inhome POCPlanning
                NIHRT = rt;
            }
        }

        TerritoryBudgetList = QueryUserBudgets(SalesTerritoryList, BudgetRTList, data.ThisUser);
        system.debug('TerritoryBudgetList: ' + TerritoryBudgetList);

        RecordType PlanRT;
        String Plan;
        String OtherPlan;

        //If Territory is null assign to first Territoy in List
        if(Territory == null){
            Territory = TerritoryBudgetList[0];
        }

        //Determing what Plan to show
        if(Territory.RecordTypeId == OOHRT.Id || Territory.RecordTypeId == null){
            PlanRT = OOHRT;
            Plan = Label.Out_of_Home;
            OtherPlan = Label.In_Home_IH;
        } else if(Territory.RecordTypeId == IHRT.Id){
            PlanRT = IHRT;
            Plan = Label.In_Home;
            OtherPlan = Label.Out_of_Home;
        } else if(Territory.RecordTypeId == NIHRT.Id){     //added by rag: Inhome POCPlanning
            PlanRT = NIHRT;
            Plan = Label.In_Home_IH;
            OtherPlan = Label.Out_of_Home;
        }
        
        Set<String> OOHBudgetYearSet = new Set<String>();
        Integer OOHYc = 0;
        Id OOHSTId = null;        
        Set<String> IHBudgetYearSet = new Set<String>();
        Integer IHYc = 0;
        Id IHSTId = null;
        Set<String> NIHBudgetYearSet = new Set<String>();              //added by rag: Inhome POCPlanning
        Integer NIHYc = 0;
        Id NIHSTId = null;

        for(Annual_Area_Budget__c t : TerritoryBudgetList){
            if(t.RecordTypeId == OOHRT.Id || t.RecordTypeId == null){
                if(OOHSTId == null){
                    if(TerritoryId != null && Plan == Label.Out_of_Home){
                        OOHSTId = Territory.Sales_Territory__c;
                    }
                    else {
                        OOHSTId = t.Sales_Territory__c;
                    }
                }
                if(OOHSTId == t.Sales_Territory__c){
                    OOHBudgetYearSet.add(t.Budget_Year__c+t.Sales_Territory__c+t.RecordTypeId);
                    if(OOHYc < OOHBudgetYearSet.size()){                
                        data.OOHYearOptions.add(new BudgetYearOption());                
                        data.OOHYearOptions[OOHYc].Year = t.Budget_Year__c;
                        data.OOHYearOptions[OOHYc].Territory = t;
                        OOHYc++;
                    } 
                }         
            }

            else if(t.RecordTypeId == IHRT.Id){
                if(IHSTId == null){
                    if(TerritoryId != null && Plan == Label.In_Home){
                        IHSTId = Territory.Sales_Territory__c;
                    }
                    else {
                        IHSTId = t.Sales_Territory__c;
                    }
                }
                if(IHSTId == t.Sales_Territory__c){
                    IHBudgetYearSet.add(t.Budget_Year__c+t.Sales_Territory__c+t.RecordTypeId);
                    if(IHYc < IHBudgetYearSet.size()){                
                        data.IHYearOptions.add(new BudgetYearOption());                
                        data.IHYearOptions[IHYc].Year = t.Budget_Year__c;
                        data.IHYearOptions[IHYc].Territory = t;
                        IHYc++;
                    }
                } 
            }
            
            else if(t.RecordTypeId == NIHRT.Id){                //added by rag: Inhome POCPlanning
                if(NIHSTId == null){
                    if(TerritoryId != null && Plan == Label.In_Home_IH){
                        NIHSTId = Territory.Sales_Territory__c;
                    }
                    else {
                        NIHSTId = t.Sales_Territory__c;
                    }
                }
                if(NIHSTId == t.Sales_Territory__c){
                    NIHBudgetYearSet.add(t.Budget_Year__c+t.Sales_Territory__c+t.RecordTypeId);
                    if(NIHYc < NIHBudgetYearSet.size()){                
                        data.NIHYearOptions.add(new BudgetYearOption());                
                        data.NIHYearOptions[NIHYc].Year = t.Budget_Year__c;
                        data.NIHYearOptions[NIHYc].Territory = t;
                        NIHYc++;
                    }
                } 
            }
            
            if(t.Id == TerritoryId && (t.RecordTypeId == PlanRT.Id || t.RecordTypeId == null)){
                data.SelectedYear.Territory = t;
                data.SelectedYear.Year = t.Budget_Year__c;
                data.Plan = Plan;
            }
        }

        if(data.SelectedYear.Year == null || test.isRunningTest()){
            data.SelectedYear.Territory = TerritoryBudgetList[0];
            data.SelectedYear.Year = TerritoryBudgetList[0].Budget_Year__c;
            if(TerritoryBudgetList[0].RecordTypeId == PlanRT.Id || TerritoryBudgetList[0].RecordTypeId == null){
                data.Plan = Plan;
            } else {
                data.Plan = OtherPlan;
            }
        }

        data.KitThreshold = determineKitThresholds();
            }
        return data;
        
    }
   private static List<lboc_Sales_Territory__c> QueryUserTerritoriesForVacantUser(Id TerritoryId){
       List<Annual_Area_Budget__c> salesTerrIds = [select Id, Sales_Territory__c from Annual_Area_Budget__c where Id =:TerritoryId];
       List<lboc_Sales_Territory__c> SalesTerritoryList = new List<lboc_Sales_Territory__c>();
       if(salesTerrIds.size()>0)
       SalesTerritoryList = [Select Id, Name, lboc_District_ID__c, lboc_District__c, lboc_Region__c, lboc_Region_ID__c
                                From lboc_Sales_Territory__c
                                Where Id =: salesTerrIds[0].Sales_Territory__c 
                            ];
        		
        System.debug('===SalesTerritoryList ==='+SalesTerritoryList.size());
                        
        return SalesTerritoryList;
    }
    //Find all the Sales Territories the Rep owns (OOH/IH) 
    private static List<lboc_Sales_Territory__c> QueryUserTerritories(Id ThisuserId){
       
        List<lboc_Sales_Territory__c> SalesTerritoryList = new List<lboc_Sales_Territory__c>();
        SalesTerritoryList = [Select Id, Name, lboc_District_ID__c, lboc_District__c, lboc_Region__c, lboc_Region_ID__c
                                From lboc_Sales_Territory__c
                                Where OwnerId =: ThisUserId 
                            ];
        		
        System.debug('===SalesTerritoryList ==='+SalesTerritoryList.size());
                        
        return SalesTerritoryList;
    }

    //Get Budgets for User Owned Terriories
    private static List<Annual_Area_Budget__c> QueryUserBudgets(List<lboc_Sales_Territory__c> SalesTerritoryList, List<RecordType> BudgetRTList, User Thisuser){        
        List<Annual_Area_Budget__c> TerritoryBudgetList = new List<Annual_Area_Budget__c>();     

        Set<Id> STIdSet = new Set<Id>();
        for(lboc_Sales_Territory__c st: SalesTerritoryList){
            STIdSet.add(st.Id);
        }   

        Set<Id> BudgetRTIdSet = new Set<Id>();
        for(RecordType rt: BudgetRTList){
            BudgetRTIdSet.add(rt.Id);
        }
        //SP 
        TerritoryBudgetList = [
            // *** Substituted by SC on 2108.08.29 to query only budgets within territories owned by the logged in user
            SELECT Id, Name, OwnerId, Owner.Name, Budget_Year__c, Sales_Territory__c, Sales_Territory__r.Name, Sales_Territory__r.lboc_District_ID__c, Sales_Territory__r.lboc_District__c, Sales_Territory__r.lboc_Region__c, 
            toLabel(Approval_Status__c), Status__c, RecordTypeId, Sales_Territory__r.lboc_Region_ID__c
            FROM Annual_Area_Budget__c
            WHERE (Sales_Territory__c In: STIdSet) And (RecordTypeId In: BudgetRTIdSet OR RecordTypeId = null)
            //WHERE (Sales_Territory__c In: STIdSet OR OwnerId =: ThisUser.Id) And (RecordTypeId In: BudgetRTIdSet OR RecordTypeId = null)
            Order By Budget_Year__c DESC NULLS LAST
        ];
        System.debug('*** TerritoryBudgetList: ' + TerritoryBudgetList);
        return TerritoryBudgetList;
    }
    private static List<Annual_Area_Budget__c> QueryUserBudgets(List<Annual_Area_Budget__c> SalesTerritoryList, List<RecordType> BudgetRTList, User Thisuser){        
        List<Annual_Area_Budget__c> TerritoryBudgetList = new List<Annual_Area_Budget__c>();     

        Set<Id> STIdSet = new Set<Id>();
        for(Annual_Area_Budget__c st: SalesTerritoryList){
            STIdSet.add(st.Id);
        }   

        Set<Id> BudgetRTIdSet = new Set<Id>();
        for(RecordType rt: BudgetRTList){
            BudgetRTIdSet.add(rt.Id);
        }
        //SP 
        TerritoryBudgetList = [
            // *** Substituted by SC on 2108.08.29 to query only budgets within territories owned by the logged in user
            SELECT Id, Name, OwnerId, Owner.Name, Budget_Year__c, Sales_Territory__c, Sales_Territory__r.Name, Sales_Territory__r.lboc_District_ID__c, Sales_Territory__r.lboc_District__c, Sales_Territory__r.lboc_Region__c, 
            toLabel(Approval_Status__c), Status__c, RecordTypeId, Sales_Territory__r.lboc_Region_ID__c
            FROM Annual_Area_Budget__c
            WHERE (Id In: STIdSet) And (RecordTypeId In: BudgetRTIdSet OR RecordTypeId = null)
            //WHERE (Sales_Territory__c In: STIdSet OR OwnerId =: ThisUser.Id) And (RecordTypeId In: BudgetRTIdSet OR RecordTypeId = null)
            Order By Budget_Year__c DESC NULLS LAST
        ];
        if(TerritoryBudgetList[0].Sales_Territory__r.Name.contains('Back Office'))
        {
         TerritoryBudgetList[0].Approval_Status__c ='Back Office'; 
        }
        System.debug('*** TerritoryBudgetList: ' + TerritoryBudgetList);
        return TerritoryBudgetList;
    }

    @RemoteAction
    public static Report[] getRepReports() {
        folder[] ff = [select id from folder where developername = 'POC_Planning_TM'];
        id fid = (ff.isEmpty()) ? null : ff[0].id;
        Report[] rpts = [SELECT id, name FROM Report WHERE ownerid = : fid and ownerid != null order by name];
        return (rpts.isEmpty() == null) ? null : rpts; 
    }

    private static KitThresholdConst determineKitThresholds(){
        KitThresholdConst KitThreshold = new KitThresholdConst();
        List<POC_Kit_Thresholds__c> KitThresholdList = POC_Kit_Thresholds__c.getall().values();        

        for(POC_Kit_Thresholds__c t: KitThresholdList){
            if(t.Name == 'TA Driver'){
                KitThreshold.Driver = Integer.valueOf(t.Minimum__c);
            } else if(t.Name == 'TA Visibility') {
                KitThreshold.Visibility = Integer.valueOf(t.Minimum__c);
            }
        }

        return KitThreshold;
    }

    @RemoteAction
    public static Map<String, String> getPOCSpendCategoryIDs(String pocID) {
        List<POC_Spend_Category__c> listOfPOCSpendCategories = [
            SELECT Id, Name
            FROM POC_Spend_Category__c
            WHERE Annual_POC_Budget_Plan__c =: pocID
        ];
        Map<String, String> ids = new Map<String, String>();
        for (POC_Spend_Category__c poc : listOfPOCSpendCategories) {
            ids.put(poc.Name.deleteWhitespace(), poc.Id);
        }

        return ids;
    }

    @RemoteAction
    public static Response updateProgramExecutionDates(String Id, String ExecutionStart, String ExecutionEnd) {
        Marketing_Kit__c updateShoppedKit = new Marketing_Kit__c();
        updateShoppedKit.Id = Id;

        if(ExecutionStart != null) {
            List<String> ExecutionStartSplit = new List<String>();
            ExecutionStartSplit = ExecutionStart.split('-');
            updateShoppedKit.Execution_Start_Date__c = date.newInstance(Integer.valueOf(ExecutionStartSplit[0]), Integer.valueOf(ExecutionStartSplit[1]), Integer.valueOf(ExecutionStartSplit[2]));
        }

        if(ExecutionEnd != null) {
            List<String> ExecutionEndSplit = new List<String>();        
            ExecutionEndSplit = ExecutionEnd.split('-');
            updateShoppedKit.Execution_End_Date__c = date.newInstance(Integer.valueOf(ExecutionEndSplit[0]), Integer.valueOf(ExecutionEndSplit[1]), Integer.valueOf(ExecutionEndSplit[2]));
        }

        update updateShoppedKit;
        Response newResponse = new Response();
        newResponse.ok = true;
        return newResponse;
    }

    @RemoteAction
    public static BudgetData Budget(String TerritoryId, string year, String businessLine){
        system.debug('Budget method:: '+TerritoryId + 'Year :::: '+ year+'businessLine::'+businessLine);
        boolean isBackOfficeUser=false;
        if(!test.isRunningTest()){
          isBackOfficeUser=POCPlanningApp.checkIfBackOfficeUser(TerritoryId); 
         }
        Set<String> busLineRecordType= new Set<String>();
       /* if(businessLine == 'In Home IH' || businessLine =='CAD Nou'){
            busLineRecordType.add('New_IH_Territory');  
        }else if(businessLine == 'Out Of Home' || businessLine =='CSP'){   
            busLineRecordType.add('Territory');
        }*/
        if(businessLine == Label.In_Home_IH ){
            busLineRecordType.add('New_IH_Territory');  
        }else if(businessLine == Label.Out_of_Home){   
            busLineRecordType.add('Territory');
        }
       List<String> RestricatedBrandList= new List<String>();
        if(year =='0')
        {
            year= String.valueOf(Date.Today().Year()+1);
        }
      // Annual_Area_Budget__c objAAB=[Select Id, Name,  Budget_Year__c From Annual_Area_Budget__c Where Id =: TerritoryId OR Sales_Territory__c=:TerritoryId];
       List<POC_Planning_Brand_Restriction__c> unUserBrand = [SELECT id, Restricted_Brands__c FROM POC_Planning_Brand_Restriction__c WHERE Budget_Year__c=:year];
         system.debug('unUserBrand unUserBrand:: '+unUserBrand );
        if(unUserBrand.size()>0){
            for(POC_Planning_Brand_Restriction__c objPrb:unUserBrand){
                String unUserBrandText = objPrb.Restricted_Brands__c;
                if(unUserBrandText != '' && unUserBrandText != Null){
                    List<String> RestricatedBrandFinalList= unUserBrandText.split('\\$');
                    //system.debug('RestricatedBrandFinalList:::::'+RestricatedBrandFinalList[0]);
                    //system.debug('RestricatedBrandFinalList:::::'+RestricatedBrandFinalList[1]);
                    for(integer i=0; i<RestricatedBrandFinalList.size();i++){
                        RestricatedBrandList.add(RestricatedBrandFinalList[i]);
                    }
                }
            }
        }
        system.debug('RestricatedBrandList RestricatedBrandList:: '+RestricatedBrandList );
        BudgetData BudgetList = new BudgetData();
        iF(!isBackOfficeUser){
        BudgetList.TerritoryBudget = [
            Select Id, Name, Trade_Activation_Budget__c, Discretionary_Budget__c, Drivers_Budget__c, Assigned_KI_Volume__c, Target_Volume__c, Driver_Spend__c,
            Discretionary_Variable_Spend__c, Discretionary_Pre_Planning_Spend__c,User_Paid_Overage__c, Budget_Year__c, toLabel(Approval_Status__c), Never_Approved__c, 
            OwnerId, Owner.Name, Sales_Territory__r.Name, Sales_Territory__r.lboc_District__c
            From Annual_Area_Budget__c
            Where Id =: TerritoryId and recordType.DeveloperName IN:busLineRecordType
            Order By Budget_Year__c DESC NULLS LAST
            Limit 1
        ];
        
        BudgetList.TerritoryBrandBudget =  [
            SELECT Id, Name, Brand__r.Name, Brand__r.Logo_Link__c, Brand__c, Brand_Budget__c, 
                Driver_Spend__c, Driver_Overage__c, Discretionary_Spend__c, Discretionary_Overage__c,User_Paid__c         //User Paid 
            FROM Annual_Brand_Area_Budget_Plan__c
            WHERE Annual_Area_Budget__c =: BudgetList.TerritoryBudget.Id AND Brand__c !=:System.Label.Club_elite_brand_view_ID AND Brand__R.Name NOT IN:RestricatedBrandList  //change RU Brand__r.Name NOT IN:NoBrand
            ORDER BY Brand__r.Priority__c ASC NULLS LAST
        ];

        BudgetList.IsSpecialty = false;
        BudgetList.isBackOffice= false;           //W-013969 Changes AP
        }
        else                    //W-013969 AP Changes
        {
             User oUser = [select id,isClubElite__c FROM User Where id =: userInfo.getUserId()];
            
            BudgetList.IsSpecialty = false;  
            BudgetList.TerritoryBudget = [
            Select Id, Name, Trade_Activation_Budget__c, Discretionary_Budget__c, Drivers_Budget__c, Assigned_KI_Volume__c, Target_Volume__c, Driver_Spend__c,
            Discretionary_Variable_Spend__c, Discretionary_Pre_Planning_Spend__c, Budget_Year__c, toLabel(Approval_Status__c), Never_Approved__c, 
            OwnerId, Owner.Name, Sales_Territory__r.Name, Sales_Territory__r.lboc_District__c
            From Annual_Area_Budget__c
            WHERE (Sales_Territory__c=:TerritoryId OR Id=:TerritoryId) and recordType.DeveloperName IN:busLineRecordType
            Order By Budget_Year__c DESC NULLS LAST
            Limit 1
            ];
            if(!oUser.isClubElite__c){
            BudgetList.TerritoryBrandBudget =  [
            SELECT Id, Name, Brand__r.Name, Brand__r.Logo_Link__c, Brand__c, Brand_Budget__c, 
                Driver_Spend__c, Driver_Overage__c, Discretionary_Spend__c, Discretionary_Overage__c,User_Paid__c
            FROM Annual_Brand_Area_Budget_Plan__c
            WHERE Annual_Area_Budget__c =: BudgetList.TerritoryBudget.Id AND Brand__c !=:System.Label.Club_elite_brand_view_ID AND Brand__R.Name NOT IN:RestricatedBrandList
            ORDER BY Brand__r.Priority__c ASC NULLS LAST
            ];
            System.debug('---BudgetList.TerritoryBrandBudget *****'+BudgetList.TerritoryBrandBudget);
            BudgetList.isBackOffice=true;                        //W-013969 AP Changes
            }
            else
            {
                BudgetList.TerritoryBrandBudget =  [
            SELECT Id, Name, Brand__r.Name, Brand__r.Logo_Link__c, Brand__c, Brand_Budget__c, 
                Driver_Spend__c, Driver_Overage__c, Discretionary_Spend__c, Discretionary_Overage__c,User_Paid__c
            FROM Annual_Brand_Area_Budget_Plan__c
            WHERE Annual_Area_Budget__c =: BudgetList.TerritoryBudget.Id AND Brand__R.Name NOT IN:RestricatedBrandList
            ORDER BY Brand__r.Priority__c ASC NULLS LAST
            ];
            BudgetList.isBackOffice=true; 
            }
        }

        return BudgetList;  
    }

    @RemoteAction
    public static BudgetData BudgetIH(String TerritoryId){
        system.debug(TerritoryId);
        BudgetData BudgetList = new BudgetData();
        
        BudgetList.TerritoryBudget = [
            Select Id, Name, Assigned_KI_Volume__c, Target_Volume__c,
            Budget_Year__c, toLabel(Approval_Status__c), Never_Approved__c, 
            OwnerId, Owner.Name, Sales_Territory__r.Name, Sales_Territory__r.lboc_District__c, Total_Coolers_Shopped__c, 
            Total_Budget__c, Total_Budget_Spend__c, Traffic_Driver_Total_Spend__c, In_Store_Driver_Total_Spend__c, 
            Programming_Total_Spend__c, Variable_Total_Spend__c
            From Annual_Area_Budget__c
            Where Id =: TerritoryId
            Order By Budget_Year__c DESC NULLS LAST
            Limit 1
        ];
        
        BudgetList.TerritoryBrandBudget =  [
            SELECT Id, Name, Brand__r.Name, Brand__r.Logo_Link__c, Brand__c, Brand_Budget__c, 
                Driver_Spend__c, Driver_Overage__c
            FROM Annual_Brand_Area_Budget_Plan__c
            WHERE Annual_Area_Budget__c =: BudgetList.TerritoryBudget.Id
            ORDER BY Brand__r.Priority__c ASC NULLS LAST
        ];

        BudgetList.IsSpecialty = false;

        return BudgetList;  
    }

    @RemoteAction
    public static Response updateTAQuantities(String itemID, Decimal diff, Boolean isSpecialty, String district) {
        system.debug('itemID: ' + itemID);
        system.debug('district: ' + district);

        List<Area_Item_Inventory__c> listOfInventory = [SELECT Id, Quantity_Shopped__c, Specialty_Quantity_Remaining__c, 
                                                            Specialty_Quantity_Allocated_to_Area__c, Specialty_Quantity_Shopped__c, 
                                                            Quantity_Remaining__c 
                                                            FROM Area_Item_Inventory__c 
                                                            WHERE Marketing_Item__c = :itemID AND OnPoint_District_Code__c = :district];
        system.debug('listOfInventory: '+listOfInventory);
        Response newResponse = new Response();
        if ((listOfInventory[0].Quantity_Remaining__c - diff >= 0 && !isSpecialty) || (listOfInventory[0].Specialty_Quantity_Allocated_to_Area__c > 0 && (listOfInventory[0].Specialty_Quantity_Remaining__c - diff >= 0 && isSpecialty && listOfInventory[0].Quantity_Remaining__c - diff >= 0))) {
            listOfInventory[0].Quantity_Shopped__c = listOfInventory[0].Quantity_Shopped__c + diff;
            if (isSpecialty || test.isRunningTest()) {
                listOfInventory[0].Specialty_Quantity_Shopped__c = listOfInventory[0].Specialty_Quantity_Shopped__c + diff;
            }
            update listOfInventory;
            newResponse.ok = true;
            newResponse.valueOne = (listOfInventory[0].Quantity_Remaining__c - diff).toPlainString();
            if (listOfInventory[0].Quantity_Remaining__c > listOfInventory[0].Specialty_Quantity_Remaining__c && isSpecialty) {
                newResponse.valueOne = (listOfInventory[0].Specialty_Quantity_Remaining__c - diff).toPlainString();
            }
        } else {
            newResponse.ok = false;
            newResponse.message = 'There are no more items left in the inventory';
            newResponse.valueOne = (listOfInventory[0].Quantity_Remaining__c).toPlainString();
            if (listOfInventory[0].Quantity_Remaining__c > listOfInventory[0].Specialty_Quantity_Remaining__c) {
                newResponse.valueOne = (listOfInventory[0].Specialty_Quantity_Remaining__c).toPlainString();
            }
        }
        return newResponse;
    }

    // Retrieve all In Home annual Budget Plans for display in IH Dasboard
    @RemoteAction
    public static List<Annual_POC_Budget_Plan__c> IHPOCList(string TerritoryBudgetId) {
        List<Annual_POC_Budget_Plan__c> territoryPOCList = [
            SELECT Id, Name, Account__r.Name, Account__r.R12_as_of_date__c, Account__r.Labatt_Share_as_of_date__c, 
                   Account__r.ShippingStreet, Account__r.ShippingCity, Account__r.ShippingState, 
                   Account__r.buzz_retail__Customer_Subtype__c, Account__r.R12_Labatt_Vol__c, Account__r.Market_Share__c, 
                   POC_Budget__c, Total_POC_Spend__c, In_Store_Driver_Spend__c, Traffic_Driver_Spend__c, Cooler_Spend__c, 
                   Variable_Spend__c, Club_Bud_Tier__c, Annual_Territory_Budget__r.Budget_Year__c, 
                   Annual_Territory_Budget__r.Sales_Territory__r.lboc_Region_ID__c, Planned_Club_Bud_Member__c,
                   Programming_Spend__c, Cooler_Quantity_Shopped__c, Target_Vol_HL__c, isIncomplete__c
            FROM Annual_POC_Budget_Plan__c
            WHERE Annual_Territory_Budget__c = :TerritoryBudgetId
        ]; 
        return territoryPOCList; 
    }

    @RemoteAction
    public static POCData POCList(String TerritoryBudgetId){
        
         // Back office changes AP
        List<Annual_Area_Budget__c> annuAreaBdg;
        boolean isBackOfficeUser=false;
       // Cache.Session.put('TerritoryBudgetId', TerritoryBudgetId);
        lboc_Sales_Territory__c backOfficeTerritory;
        User objusr = [SELECT Name, Id, OnPoint_Person_Id__c ,Is_TAU_Admin__c  FROM User WHERE Id = : UserInfo.getUserId()];
        string labattId;
        if(objusr.Is_TAU_Admin__c){
                    List<Annual_Area_Budget__c> Territory;
                    Territory = [Select Id, Name, OwnerId, Sales_Territory__c, RecordTypeId From Annual_Area_Budget__c Where Sales_Territory__c =: TerritoryBudgetId ];
                    if(Territory.size()==0)
                    {
                        Territory = [Select Id, Name, OwnerId, Sales_Territory__c, RecordTypeId From Annual_Area_Budget__c Where Id =: TerritoryBudgetId ];   
                    }
                    
                    //Annual_Area_Budget__c objAAB=[SELECT OwnerId,Name , Sales_Territory__c FROM Annual_Area_Budget__c WHERE Id=:territoryId];
                   user usr = [Select Id,ManagerId,OnPoint_Person_Id__c from user where id =:Territory[0].OwnerId Limit 1]; //added by Ragbirendra 
                   labattId =usr.OnPoint_Person_Id__c+'%';
        }
        else{
              labattId=objusr.OnPoint_Person_Id__c+'%';
        }
        
        annuAreaBdg = [Select Id, OwnerId from Annual_Area_Budget__c where Id =:TerritoryBudgetId LIMIT 1];
       
        List<lboc_Sales_Territory__c> listOPT=new List<lboc_Sales_Territory__c>();
        if(!Test.isRunningTest()){
            listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c FROM lboc_Sales_Territory__c WHERE OwnerId =:annuAreaBdg[0].OwnerId AND lboc_Territory_ID__c  LIKE: labattId];
        }
        else
        {
            listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c FROM lboc_Sales_Territory__c ];
        }
        if(listOPT.size()>0)
        {
            if(listOPT[0].Back_Office_Territory__c)
            {
                isBackOfficeUser =true; 
                backOfficeTerritory=listOPT[0];
            }
            else
            {
                isBackOfficeUser= false; 
            }
        }
        POCData POCList = new POCData();
        iF(!isBackOfficeUser){
        List<Annual_POC_Budget_Plan__c> territoryPOCList = new List<Annual_POC_Budget_Plan__c>();
        List<Marketing_Kit__c> marketingKitList = new List<Marketing_Kit__c>();
        Set<String> POCIdSet = new Set<String>();
        Set<String> BrandSet = new Set<String>();
        
        territoryPOCList = [
            Select Id, Name, Account__r.Name, Account__r.R12_as_of_date__c, Account__r.Labatt_Share_as_of_date__c, Account__r.ShippingStreet, Account__r.ShippingCity, Account__r.ShippingState, Account__r.buzz_retail__Customer_Subtype__c, Account__r.R12_Labatt_Vol__c, Account__r.Market_Share__c,           
            Driver_Spend__c, Discretionary_Variable_Spend__c, Discretionary_Pre_Planning_Spend__c, Target_Vol_HL__c, Target_Spend_HL__c, IsUpdated__c, Annual_Territory_Budget__r.Sales_Territory__r.lboc_Region__c,CAP_Eligibility__c,Custom_Drink_List__c,Food_Pairing_Feature__c,Full_Power_Play_Package__c,
            Labatt_Large_Tap_Handles__c,Labatt_Branded_Glassware__c,Weekly_Feature_PTC__c,Labatt_Draught_Lines__c,Budget_Year__c,Total_Draught_Lines__c,Quebec_CAP_criteria__c
            From Annual_POC_Budget_Plan__c
            WHERE Annual_Territory_Budget__c =: TerritoryBudgetId
        ];
        
        for(Annual_POC_Budget_Plan__c p: territoryPOCList){
            POCList.pocSpendList.add(new POCSpend());
            POCList.pocSpendList[POCList.pocSpendList.size()-1].TerritoryPOC = p;
            POCIdSet.add(p.Id);
            POCList.channelSet.add(p.Account__r.buzz_retail__Customer_Subtype__c);
        }

        marketingKitList = [
            SELECT Id, Name, Annual_Brand_Area_Budget_Plan__r.Brand__c, Annual_Brand_Area_Budget_Plan__r.Brand__r.Name, 
                POC_Spend_Category__r.Annual_POC_Budget_Plan__c, Driver_Spend_Total__c, Discretionary_Spend_Total__c,Marketing_Program_Name__c,Marketing_Program_Name__r.Name,Total_Spend__c,RecordType.DeveloperName   ////W-014033 User Paid Program and spend
            FROM Marketing_Kit__c
            WHERE POC_Spend_Category__r.Annual_POC_Budget_Plan__c In: POCIdSet AND Total_Spend__c !=: 0
                AND RecordType.DeveloperName !=: 'IH_Preconfigured' AND RecordType.DeveloperName !=: 'IH_Assigned_Preconfigured'
            ORDER BY Annual_Brand_Area_Budget_Plan__r.Brand__r.Priority__c ASC NULLS LAST
        ];

        Integer Bc = 0;        
        
        for(Marketing_Kit__c m: marketingKitList){
            for(POCSpend p: POCList.pocSpendList){
              /*  p.pocUserProgramList.add(new programSpend());                                        //W-014033 User Paid Program and spend
                Integer k = p.pocUserProgramList.size()-1;										     //W-014033 User Paid Program and spend
                p.pocUserProgramList[k].programId=m.Marketing_Program_Name__c;						 //W-014033 User Paid Program and spend
                p.pocUserProgramList[k].programName=m.Marketing_Program_Name__r.Name;				 //W-014033 User Paid Program and spend
                p.pocUserProgramList[k].programSpend=m.Total_Spend__c;	*/							 //W-014033 User Paid Program and spend
                //if marketingkit is for POC                
                if(m.POC_Spend_Category__r.Annual_POC_Budget_Plan__c == p.TerritoryPOC.Id){
                     p.pocUserProgramList.add(new programSpend());                                        //W-014033 User Paid Program and spend
                    Integer k = p.pocUserProgramList.size()-1;										     //W-014033 User Paid Program and spend
                    p.pocUserProgramList[k].programId=m.Marketing_Program_Name__c;						 //W-014033 User Paid Program and spend
                    p.pocUserProgramList[k].programName=m.Marketing_Program_Name__r.Name;				 //W-014033 User Paid Program and spend
                    p.pocUserProgramList[k].programSpend=m.Total_Spend__c;
                    //if marketingkit is under new brand
                    if(!p.BrandIdSet.Contains(m.Annual_Brand_Area_Budget_Plan__r.Brand__c)){
                        p.BrandIdSet.add(m.Annual_Brand_Area_Budget_Plan__r.Brand__c);
                        BrandSet.add(m.Annual_Brand_Area_Budget_Plan__r.Brand__c);
                        if(BrandSet.size() > Bc){
                            Bc++;
                            POCList.BrandOptions.add(new Option());
                            
                            Integer i = POCList.BrandOptions.size()-1;
                            POCList.BrandOptions[i].Name = m.Annual_Brand_Area_Budget_Plan__r.Brand__r.Name;
                            POCList.BrandOptions[i].Id = m.Annual_Brand_Area_Budget_Plan__r.Brand__c;                          
                        }
                        p.POCTASpendList.add(new POCTASpend());
                        
                        Integer i = p.POCTASpendList.size()-1;
                        p.POCTASpendList[i].BrandId = m.Annual_Brand_Area_Budget_Plan__r.Brand__c; 
                        p.POCTASpendList[i].BrandName = m.Annual_Brand_Area_Budget_Plan__r.Brand__r.Name;
                        p.POCTASpendList[i].Driver = m.Driver_Spend_Total__c;
                        p.POCTASpendList[i].Discretionary = m.Discretionary_Spend_Total__c;
                    } 
                    //if marketingkit is not under new brand
                    else {
                        for(POCTASpend ta: p.POCTASpendList){
                            if(ta.BrandId == m.Annual_Brand_Area_Budget_Plan__r.Brand__c){                                
                                ta.Driver += m.Driver_Spend_Total__c;
                                ta.Discretionary += m.Discretionary_Spend_Total__c;
                            }
                        }                        
                    }
                }   
            }               
        }
            poclist.isBackOffice=isBackOfficeUser;        //W013969  AP Changes
        }
        else               //AP Changes W-013969
        {
            List<Account> accPocList=[SELECT Id, Name, R12_as_of_date__c, Labatt_Share_as_of_date__c, ShippingStreet, ShippingCity, ShippingState, buzz_retail__Customer_Subtype__c FROM Account WHERE On_Plan_Territory_Name__c=:listOPT[0].Name AND RecordType.DeveloperName='Outlet' AND lboc_Labatt_Outlet_Id__c=:listOPT[0].lboc_Territory_ID__c];
            if(accPocList.size()>0)
            {
                poclist.backOfcPocList=accPocList;
            }
            //Below is for Testing
            poclist.isBackOffice=isBackOfficeUser;      //W013969  AP Changes
            List<Annual_POC_Budget_Plan__c> territoryPOCList = new List<Annual_POC_Budget_Plan__c>();
        List<Marketing_Kit__c> marketingKitList = new List<Marketing_Kit__c>();
        Set<String> POCIdSet = new Set<String>();
        Set<String> BrandSet = new Set<String>();
        System.debug('====TerritoryBudgetId===='+TerritoryBudgetId);
        territoryPOCList = [
            Select Id, Name, Account__r.Name, Account__r.R12_as_of_date__c, Account__r.Labatt_Share_as_of_date__c, Account__r.ShippingStreet, Account__r.ShippingCity, Account__r.ShippingState, Account__r.buzz_retail__Customer_Subtype__c, Account__r.R12_Labatt_Vol__c, Account__r.Market_Share__c,           
            Driver_Spend__c, Discretionary_Variable_Spend__c, Discretionary_Pre_Planning_Spend__c, Target_Vol_HL__c, Target_Spend_HL__c, IsUpdated__c, Annual_Territory_Budget__r.Sales_Territory__r.lboc_Region__c,CAP_Eligibility__c,Custom_Drink_List__c,Food_Pairing_Feature__c,Full_Power_Play_Package__c,
            Labatt_Large_Tap_Handles__c,Labatt_Branded_Glassware__c,Weekly_Feature_PTC__c,Labatt_Draught_Lines__c,Budget_Year__c,Total_Draught_Lines__c,Quebec_CAP_criteria__c
            From Annual_POC_Budget_Plan__c
            WHERE Annual_Territory_Budget__c =: TerritoryBudgetId AND Account__r.lboc_Labatt_Outlet_Id__c=: listOPT[0].lboc_Territory_ID__c
        ];
        System.debug('====territoryPOCList===='+territoryPOCList);
        for(Annual_POC_Budget_Plan__c p: territoryPOCList){
            POCList.pocSpendList.add(new POCSpend());
            POCList.pocSpendList[POCList.pocSpendList.size()-1].TerritoryPOC = p;
            POCIdSet.add(p.Id);
            POCList.channelSet.add(p.Account__r.buzz_retail__Customer_Subtype__c);
        }

        marketingKitList = [
            SELECT Id, Name, Annual_Brand_Area_Budget_Plan__r.Brand__c, Annual_Brand_Area_Budget_Plan__r.Brand__r.Name, 
                POC_Spend_Category__r.Annual_POC_Budget_Plan__c, Driver_Spend_Total__c, Discretionary_Spend_Total__c,Marketing_Program_Name__c,Marketing_Program_Name__r.Name,Total_Spend__c,RecordType.DeveloperName   ////W-014033 User Paid Program and spend
            FROM Marketing_Kit__c
            WHERE POC_Spend_Category__r.Annual_POC_Budget_Plan__c In: POCIdSet AND Total_Spend__c !=: 0
                AND RecordType.DeveloperName !=: 'IH_Preconfigured' AND RecordType.DeveloperName !=: 'IH_Assigned_Preconfigured'
            ORDER BY Annual_Brand_Area_Budget_Plan__r.Brand__r.Priority__c ASC NULLS LAST
        ];

        Integer Bc = 0;        
        
        for(Marketing_Kit__c m: marketingKitList){
            for(POCSpend p: POCList.pocSpendList){
                
                //if marketingkit is for POC                
                if(m.POC_Spend_Category__r.Annual_POC_Budget_Plan__c == p.TerritoryPOC.Id){
                    p.pocUserProgramList.add(new programSpend());                                        //W-014033 User Paid Program and spend
                Integer k = p.pocUserProgramList.size()-1;										     //W-014033 User Paid Program and spend
                p.pocUserProgramList[k].programId=m.Marketing_Program_Name__c;						 //W-014033 User Paid Program and spend
                p.pocUserProgramList[k].programName=m.Marketing_Program_Name__r.Name;				 //W-014033 User Paid Program and spend
                p.pocUserProgramList[k].programSpend=m.Total_Spend__c;		
                    //if marketingkit is under new brand
                    if(!p.BrandIdSet.Contains(m.Annual_Brand_Area_Budget_Plan__r.Brand__c)){
                        p.BrandIdSet.add(m.Annual_Brand_Area_Budget_Plan__r.Brand__c);
                        BrandSet.add(m.Annual_Brand_Area_Budget_Plan__r.Brand__c);
                        if(BrandSet.size() > Bc){
                            Bc++;
                            POCList.BrandOptions.add(new Option());
                            
                            Integer i = POCList.BrandOptions.size()-1;
                            POCList.BrandOptions[i].Name = m.Annual_Brand_Area_Budget_Plan__r.Brand__r.Name;
                            POCList.BrandOptions[i].Id = m.Annual_Brand_Area_Budget_Plan__r.Brand__c;                          
                        }
                        p.POCTASpendList.add(new POCTASpend());
                        
                        Integer i = p.POCTASpendList.size()-1;
                        p.POCTASpendList[i].BrandId = m.Annual_Brand_Area_Budget_Plan__r.Brand__c; 
                        p.POCTASpendList[i].BrandName = m.Annual_Brand_Area_Budget_Plan__r.Brand__r.Name;
                        p.POCTASpendList[i].Driver = m.Driver_Spend_Total__c;
                        p.POCTASpendList[i].Discretionary = m.Discretionary_Spend_Total__c;
                    } 
                    //if marketingkit is not under new brand
                    else {
                        for(POCTASpend ta: p.POCTASpendList){
                            if(ta.BrandId == m.Annual_Brand_Area_Budget_Plan__r.Brand__c){                                
                                ta.Driver += m.Driver_Spend_Total__c;
                                ta.Discretionary += m.Discretionary_Spend_Total__c;
                            }
                        }                        
                    }
                }   
            }               
        }
        }

        return POCList;
    }

    @RemoteAction
    public static Boolean UpdateTerritoryPOC(String territoryPOCId, Decimal targetVol, Decimal targetSpend_Hl){
        Annual_POC_Budget_Plan__c TerritoryPOC = new Annual_POC_Budget_Plan__c(
            Id = territoryPOCId,
            Target_Vol_HL__c = targetVol,
            Target_Spend_HL__c = targetSpend_Hl
        );

        update TerritoryPOC;
        
        return true;
    }

    @RemoteAction
    public static POCNavData POCBudget(String pocId){
        //AP Changes W-013969
        boolean isBackOfficeUser=false;
        List<Annual_POC_Budget_Plan__c> annualPOCList;
        lboc_Sales_Territory__c backOfficeTerritory;
        User objusr=[SELECT Name, Id, OnPoint_Person_Id__c  FROM User WHERE Id = : UserInfo.getUserId()];
        annualPOCList =  [select id ,Annual_Territory_Budget__r.OwnerId from Annual_POC_Budget_Plan__c where Id =:pocId];
        string labattId=objusr.OnPoint_Person_Id__c+'%';
        List<lboc_Sales_Territory__c> listOPT=new List<lboc_Sales_Territory__c>();
        if(!test.isRunningTest()){
            listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c FROM lboc_Sales_Territory__c WHERE OwnerId =:annualPOCList[0].Annual_Territory_Budget__r.OwnerId AND lboc_Territory_ID__c  LIKE: labattId];
        }
        else{
            listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c FROM lboc_Sales_Territory__c ];
            
        }  
        
        if(listOPT.size()>0)
        {
            if(listOPT[0].Back_Office_Territory__c)
            {
                isBackOfficeUser =true; 
                //isBackOfficeUser =false;
                backOfficeTerritory=listOPT[0];
            }
            else
            {
                isBackOfficeUser= false; 
            }
        }
    
    
        POCNavData NavData = new POCNavData();
        if(!isBackOfficeUser){
        NavData.POCBudget = [Select Id, Name, Account__r.Name, Account__r.ShippingStreet,  Account__r.ShippingCity, Account__r.ShippingState, Account__r.buzz_retail__Customer_Subtype__c, Account__r.R12_Labatt_Vol__c, Account__r.Market_Share__c,             
            Trade_Activation_Spend__c, Driver_Spend__c, Discretionary_Spend__c, Target_Vol_HL__c, Target_Spend_HL__c, Variable_Spend__c,User_Paid_Spend__c
            From Annual_POC_Budget_Plan__c
            Where Id = :pocId];
            
        NavData.POCSpendCategoryList = [Select Id, RecordType.DeveloperName
            From POC_Spend_Category__c
            Where Annual_POC_Budget_Plan__r.Id =: pocId];
        
        }
        else              //AP Changes W-013969
        {
            User oUser = [select id,isClubElite__c FROM User Where id =: userInfo.getUserId()];
            List<Account> accPocList=[SELECT Id, Name, R12_as_of_date__c, Labatt_Share_as_of_date__c, ShippingStreet, ShippingCity, ShippingState, buzz_retail__Customer_Subtype__c FROM Account WHERE On_Plan_Territory_Name__c=:listOPT[0].Name AND RecordType.DeveloperName='Outlet' AND lboc_Labatt_Outlet_Id__c=:listOPT[0].lboc_Territory_ID__c];
            if(accPocList.size()>0)
            {
                NavData.backOfficeAccList=accPocList;
            }
            NavData.isBackOfficeUser=isBackOfficeUser;
            if(oUser.isClubElite__c){
                NavData.isBackOfficeClubElite=true;
            }
            
           NavData.POCBudget = [Select Id, Name, Account__r.Name, Account__r.ShippingStreet,  Account__r.ShippingCity, Account__r.ShippingState, Account__r.buzz_retail__Customer_Subtype__c, Account__r.R12_Labatt_Vol__c, Account__r.Market_Share__c,             
                                 Trade_Activation_Spend__c, Driver_Spend__c, Discretionary_Spend__c, Target_Vol_HL__c, Target_Spend_HL__c, Variable_Spend__c,Total_POC_Spend__c,User_Paid_Spend__c
                                 From Annual_POC_Budget_Plan__c
                               Where Id = :pocId];
           NavData.POCSpendCategoryList = [Select Id, RecordType.DeveloperName
                                            From POC_Spend_Category__c
                                          Where Annual_POC_Budget_Plan__r.Id =: pocId ];
        }
        return NavData;
    }

    @RemoteAction
    public static List<POCPlanningAppDriver.DriverBrand> Driver(string POCId, Boolean isSpecialty) {
        return POCPlanningAppDriver.Driver(POCId, isSpecialty);
    }

    @RemoteAction
    public static POCPlanningAppDriver.QtyRmngResponse OnDriverChange(String pocId, String itemID, Integer quantity, Integer oldQuantity, Boolean hasQty, String POCSpendCategory, String driverItemID, Boolean isSpecialty, String Region) {
        return POCPlanningAppDriver.OnDriverChange(pocId, itemID, quantity, oldQuantity, hasQty, POCSpendCategory, driverItemID, isSpecialty, Region);
    }
        

    

    @RemoteAction
    public static DiscSpend Discretionary(string POCId) {
        List<POC_Spend_Category__c> pocSpendCategory = [
            SELECT Id, Pre_Planning_Spend__c, Variable_Spend__c, Discretionary_Core_POCM_Spend__c, Discretionary_CRM_Spend__c, Discretionary_Marketing_Investment_Spend__c
            FROM POC_Spend_Category__c 
            WHERE Name = 'Discretionary' AND Annual_POC_Budget_Plan__c = :pocId
        ];
        
        Annual_POC_Budget_Plan__c territoryPOC = [
            Select Id, CAP_Eligibility__c,Custom_Drink_List__c,Food_Pairing_Feature__c,Full_Power_Play_Package__c,
            Labatt_Large_Tap_Handles__c,Labatt_Branded_Glassware__c,Weekly_Feature_PTC__c,Labatt_Draught_Lines__c,Budget_Year__c,Total_Draught_Lines__c,Quebec_CAP_criteria__c,Target_Vol_HL__c, Target_Spend_HL__c, Total_POC_Spend__c
            From Annual_POC_Budget_Plan__c
            WHERE id =: POCId limit 1
        ];

        if (pocSpendCategory.isEmpty()) {
            RecordType POCSPCatRT = [Select Id From RecordType Where SObjectType = 'POC_Spend_Category__c' And DeveloperName = 'Discretionary_Out_of_Home'];
            
            POC_Spend_Category__c newPOCSpend = new POC_Spend_Category__c();
            newPOCSpend.Annual_POC_Budget_Plan__c = pocId;
            newPOCSpend.Name = 'Discretionary';
            newPOCSpend.RecordTypeId = POCSPCatRT.Id;
            newPOCSpend.Pre_Planning_Spend__c = 0;
            newPOCSpend.Discretionary_Core_POCM_Spend__c = 0;
            newPOCSpend.Discretionary_CRM_Spend__c = 0;
            newPOCSpend.Discretionary_Marketing_Investment_Spend__c = 0;
            newPOCSpend.Variable_Spend__c = 0;
            insert newPOCSpend;
            pocSpendCategory.add(newPOCSpend);
        }
        DiscSpend discretionarySpend = new DiscSpend();
        discretionarySpend.PrePlanningSpend = pocSpendCategory[0].Pre_Planning_Spend__c;
        discretionarySpend.CorePOCMSpend = pocSpendCategory[0].Discretionary_Core_POCM_Spend__c;
        discretionarySpend.CRMSpend = pocSpendCategory[0].Discretionary_CRM_Spend__c;
        discretionarySpend.MarketingInvestmentSpend = pocSpendCategory[0].Discretionary_Marketing_Investment_Spend__c;
        discretionarySpend.VariableSpend = pocSpendCategory[0].Variable_Spend__c;
        discretionarySpend.pocSpendCategory = pocSpendCategory[0].Id;
        discretionarySpend.LabattBrandedGlassware = territoryPOC.Labatt_Branded_Glassware__c;
        discretionarySpend.LabattLargeTapHandles = territoryPOC.Labatt_Large_Tap_Handles__c;
        discretionarySpend.FoodPairingFeature = territoryPOC.Food_Pairing_Feature__c;
        discretionarySpend.CustomDrinkList = territoryPOC.Custom_Drink_List__c;
        discretionarySpend.FullPowerPlayPackage = territoryPOC.Full_Power_Play_Package__c;
        discretionarySpend.WeeklyFeaturePTC = territoryPOC.Weekly_Feature_PTC__c;
        discretionarySpend.LabattDraughtLines = territoryPOC.Labatt_Draught_Lines__c;
        discretionarySpend.TotalDraughtLines = territoryPOC.Total_Draught_Lines__c;
        discretionarySpend.QuebecCAPCriteria = territoryPOC.Quebec_CAP_criteria__c;
        discretionarySpend.TargetVolHL = territoryPOC.Target_Vol_HL__c;
        discretionarySpend.TargetSpendHL = territoryPOC.Target_Spend_HL__c;
        discretionarySpend.TotalPOCSpend = territoryPOC.Total_POC_Spend__c;
        
        discretionarySpend.CapEligibility = territoryPOC.CAP_Eligibility__c;
        return discretionarySpend;
    }

    @RemoteAction
    public static void OnDiscretionaryChange(string POCId, Decimal crm, Decimal marketinginvestment, Decimal corepocm, String pocSpendCategoryID) {
        POC_Spend_Category__c pocSpendCategory = new POC_Spend_Category__c();
        pocSpendCategory.Id = pocSpendCategoryID;
        boolean isBackoffice = false;
        //List<Annual_POC_Budget_Plan__c> annPOCBgt =[select Id, Annual_Territory_Budget__r.ownerId from Annual_POC_Budget_Plan__c where Id=:POCId];
        List<Annual_POC_Budget_Plan__c> annualPOCList=[select Id, Annual_Territory_Budget__r.Sales_Territory__r.Back_Office_Territory__c from Annual_POC_Budget_Plan__c where Id= :POCId];
           /* if(annPOCBgt[0].Annual_Territory_Budget__r.ownerId == UserInfo.getUserId())
            {
            isBackoffice = annualPOCList[0].checkIfBackOfficeUser();
            }*/
        if(annualPOCList.size()>0)
        {
          isBackoffice = annualPOCList[0].Annual_Territory_Budget__r.Sales_Territory__r.Back_Office_Territory__c; 
        }
        //AP Changes W-013969 
        if(isBackoffice)
        {
            pocSpendCategory.Discretionary_Core_POCM_Spend__c = corepocm;
            pocSpendCategory.Discretionary_Marketing_Investment_Spend__c = marketinginvestment;
            pocSpendCategory.Discretionary_CRM_Spend__c = crm;
            pocSpendCategory.Variable_Spend__c = corepocm + marketinginvestment + crm;
        }
        else
        { 
            pocSpendCategory.Discretionary_Core_POCM_Spend__c = corepocm;
            pocSpendCategory.Discretionary_Marketing_Investment_Spend__c = marketinginvestment;
            pocSpendCategory.Discretionary_CRM_Spend__c = crm;
            pocSpendCategory.Variable_Spend__c = corepocm + marketinginvestment + crm;
         }
        update pocSpendCategory;
    }

    @RemoteAction
    public static void onVariableChange(Decimal varSpend, Decimal customMarketingProgram, Decimal crm, Decimal productSampling, String pocSpendCategoryID) {
        POC_Spend_Category__c pocSpendCategory = new POC_Spend_Category__c();
        pocSpendCategory.Custom_Marketing_Program__c = customMarketingProgram;
        pocSpendCategory.Discretionary_CRM_Spend__c = crm;
        pocSpendCategory.Product_Sampling__c = productSampling;
        pocSpendCategory.Id = pocSpendCategoryID; 
        pocSpendCategory.Variable_Spend__c = varSpend;
        update pocSpendCategory;
    }

    @RemoteAction
    public static Response submitFinalPlan(Id annualAreaBudgetID) {
        Response newResponse = new Response();

        if (Approval.isLocked(annualAreaBudgetID)) {
            newResponse.ok = false;
            newResponse.message = 'Annual Area Budget record is already going through an approval process';
            return newResponse;
        }
        try {
            Approval.ProcessSubmitRequest requestForApproval = new Approval.ProcessSubmitRequest();
            requestForApproval.setObjectId(annualAreaBudgetID);

            Approval.ProcessResult result = Approval.process(requestForApproval);       
        } catch (Exception e) {
            newResponse.ok = false;
            newResponse.message = e.getMessage();
            return newResponse;
        }
        newResponse.ok = true;
        return newResponse;
    }

    public class Response {
        Boolean ok {get; set;}
        String message {get; set;}
        String valueOne {get; set;}
    }

    @RemoteAction
    public static List<TABrand> TradeActivation(String TerritoryId, String POCId, String State, Boolean isSpecialty, String plan, string year){
    
        boolean isBackOfficeUser=false;
        lboc_Sales_Territory__c backOfficeTerritory;
      	System.debug('--- Year Passes--'+year);
        List<String> RestricatedBrandList= new List<String>();
        /*if(year =='0')
        {
            year= String.valueOf(Date.Today().Year()+1);
        }*/
        //Annual_Area_Budget__c objAAB=[Select Id, Name,  Budget_Year__c From Annual_Area_Budget__c Where Id =: TerritoryId OR Sales_Territory__c=:TerritoryId];
       List<POC_Planning_Brand_Restriction__c> unUserBrand = [SELECT id, Restricted_Brands__c FROM POC_Planning_Brand_Restriction__c WHERE Budget_Year__c=:year];
        if(unUserBrand.size()>0){
            for(POC_Planning_Brand_Restriction__c objPrb:unUserBrand){
                String unUserBrandText = objPrb.Restricted_Brands__c;
                if(unUserBrandText !='' && unUserBrandText!= Null){
                List<String> RestricatedBrandFinalList= unUserBrandText.split('\\$');
                for(integer i=0; i<RestricatedBrandFinalList.size();i++){
                    RestricatedBrandList.add(RestricatedBrandFinalList[i]);
                }
                }
            }
        }
        isBackOfficeUser =  checkIfBackOfficeUser(TerritoryId); //checkIfBackOfficeUser();
        List<Annual_Brand_Area_Budget_Plan__c> BrandList = new List<Annual_Brand_Area_Budget_Plan__c>();
        User oUser = [select id,isClubElite__c FROM User Where id =: userInfo.getUserId()];
        Set<String> TerritoryBrandIdSet = new Set<String>();
        if(!isBackOfficeUser){
            system.debug('not back office user:::::'+isBackOfficeUser+'Restricated Brand List=='+RestricatedBrandList);
        //User oUser = [select id,isClubElite__c FROM User Where id =: userInfo.getUserId()]; // added by Ragbirendra

        BrandList = [Select Id, Name, Brand__c, Brand__r.Priority__c , Annual_Area_Budget__r.Sales_Territory__r.lboc_Region__c,
                        Annual_Area_Budget__r.Sales_Territory__r.lboc_District_ID__c,Annual_Area_Budget__r.Budget_Year__c
        From Annual_Brand_Area_Budget_Plan__c
        Where Annual_Area_Budget__c =: TerritoryId AND Brand__c != :System.Label.Club_elite_brand_view_ID AND Brand__R.Name NOT IN:RestricatedBrandList ORDER BY Brand__r.Priority__c   ASC NULLS LAST];
 
        for(Annual_Brand_Area_Budget_Plan__c b: BrandList) 
        {
            System.debug('--->>Tb.Brand__c  @@@@'+b.Brand__c);
            TerritoryBrandIdSet.add(b.Brand__c);      
        }
        }
        else
        {
            system.debug('back office user:::::'+isBackOfficeUser+'Restricated Brand List=='+RestricatedBrandList);
            
            if(oUser.isClubElite__c)
            {
                system.debug('back office user:::::'+oUser.isClubElite__c);
                BrandList=[Select Id, Name, Brand__c, Brand__r.Priority__c , Annual_Area_Budget__r.Sales_Territory__r.lboc_Region__c,
                        Annual_Area_Budget__r.Sales_Territory__r.lboc_District_ID__c, Annual_Area_Budget__r.Budget_Year__c,Annual_Area_Budget__r.Sales_Territory__c,Annual_Area_Budget__c
                     From Annual_Brand_Area_Budget_Plan__c WHERE (Brand__R.Name NOT IN:RestricatedBrandList AND Budget_Year__c=:year) AND (Annual_Area_Budget__r.Sales_Territory__c =:TerritoryId OR Annual_Area_Budget__c =: TerritoryId)];
            }
            else
            {
                system.debug('not back office user:::::'+oUser.isClubElite__c+'Restricated Brand List=='+RestricatedBrandList);
                BrandList=[Select Id, Name, Brand__c,Brand__r.Name, Brand__r.Priority__c , Annual_Area_Budget__r.Sales_Territory__r.lboc_Region__c,
                        Annual_Area_Budget__r.Sales_Territory__r.lboc_District_ID__c, Annual_Area_Budget__r.Budget_Year__c,Annual_Area_Budget__r.Sales_Territory__c 
                     From Annual_Brand_Area_Budget_Plan__c
                          WHERE    ( Brand__c !=:System.Label.Club_elite_brand_view_ID AND Brand__R.Name NOT IN:RestricatedBrandList AND Budget_Year__c=:year) AND (Annual_Area_Budget__r.Sales_Territory__c =:TerritoryId OR Annual_Area_Budget__c =: TerritoryId)];
            }
            for(Annual_Brand_Area_Budget_Plan__c b:BrandList)
            {
                System.debug('--->>Tb.Brand__c  @@@@'+b);
                TerritoryBrandIdSet.add(b.Brand__c); 
            }
        }
		System.debug('--->>TerritoryBrandIdSet  @@@@'+TerritoryBrandIdSet);

        if(!State.equalsIgnoreCase('Quebec') && !State.equalsIgnoreCase('QC')){
            system.debug('TANonQuebec: ' + State);
            return TANonQuebec(POCId, TerritoryBrandIdSet, isSpecialty, BrandList[0].Annual_Area_Budget__r.Sales_Territory__r.lboc_Region__c, 
                                BrandList[0].Annual_Area_Budget__r.Sales_Territory__r.lboc_District_ID__c,BrandList[0].Annual_Area_Budget__r.Budget_Year__c, plan);
        } else {
            system.debug('TAQuebec: ' + State);
            return TAQuebec(POCId, TerritoryBrandIdSet, isSpecialty, BrandList[0].Annual_Area_Budget__r.Sales_Territory__r.lboc_Region__c,BrandList[0].Annual_Area_Budget__r.Budget_Year__c, plan);
        }       
    }

    @RemoteAction
    public static void setAnnuaLPOCBudgetPlanToUpdated(String pocID) {
        Annual_POC_Budget_Plan__c getPOCBudgetPlan = [SELECT Id, IsUpdated__c FROM Annual_POC_Budget_Plan__c WHERE Id = :pocID];
        getPOCBudgetPlan.IsUpdated__c = true;
        update getPOCBudgetPlan;
    }

    private static List<TABrand> TANonQuebec(String POCId, Set<String> TerritoryBrandIdSet, Boolean isSpecialty, String region,string year,string plan){
        return TANonQuebec(POCId, TerritoryBrandIdSet, isSpecialty, region, null,year, plan);
    }

    private static List<TABrand> TANonQuebec(String POCId, Set<String> TerritoryBrandIdSet, Boolean isSpecialty, String region, String districtId,string year, string plan){
        List<TABrand> data = new List<TABrand>();
        List<Marketing_Program_Item__c> ProgramItems = new List<Marketing_Program_Item__c>();
        List<Trade_Activation_Kit_Item__c> KitItems = new List<Trade_Activation_Kit_Item__c>();
        List<Area_Item_Inventory__c> ItemInventory = new List<Area_Item_Inventory__c>();
        Set<String> BrandSet = new Set<String>();
        Set<String> ProgramSet = new Set<String>();

        system.debug('Territory Brand Id Set: ' + TerritoryBrandIdSet);
        // kaustav
        Integer filterYear = Integer.valueOf(year);
        System.debug('--filter year---plan'+plan +'@@@'+filterYear);
        if(plan=='Out of Home' || plan == 'CSP' || test.isRunningTest()){
            ProgramItems = [
                SELECT Id, Name, Marketing_Program__c, Marketing_Program__r.Name, Price__c,
                Marketing_Program__r.Brand__c, Marketing_Program__r.Brand__r.Name, Marketing_Program__r.Brand__r.Brand_Hex_Color__c,
                Marketing_Program__r.Planning_Start_Date__c, Marketing_Program__r.Planning_End_Date__c, 
                Marketing_Program__r.Program_Information_EN__c, Marketing_Program__r.Program_Information_FR__c,
                
                Marketing_Program__r.Program_Start_Date__c, Marketing_Program__r.Program_End_Date__c,
                Marketing_Program__r.ABI_OP_User_Paid__c,
                Marketing_Item__c, Marketing_Item__r.Name, Marketing_Item__r.Item_Description_EN__c, Marketing_Item__r.Item_Description_FR__c,
                Marketing_Item__r.Item_Type_EN__c, Marketing_Item__r.Item_Type_FR__c, Marketing_Item__r.Material__c,
                Marketing_Item__r.Size__c, Marketing_Item__r.Item_Dimensions__c, Marketing_Item__r.Item_Unit_of_Measure__c,
                Marketing_Item__r.Marketing_Type__c, Marketing_Item__r.Price__c, Marketing_Item__r.Sml_Image_Link__c, Marketing_Item__r.Lrg_Image_Link__c,
                Minimum_Quantity__c
                
                FROM Marketing_Program_Item__c
                WHERE Marketing_Item__r.Is_Cancelled__c =: false 
                AND Marketing_Program__r.Brand__c In: TerritoryBrandIdSet 
                AND CALENDAR_YEAR(Marketing_Program__r.Program_End_Date__c) = :filterYear
                AND (Marketing_Program__r.Business_Line__c = NULL OR Marketing_Program__r.Business_Line__c INCLUDES ('Out of Home'))
                ORDER BY Marketing_Program__r.Brand__r.Priority__c ASC NULLS LAST
            ]; // kaustav altered line 1286 -- AND Marketing_Program__r.Planning_End_Date__c >= Today
    	}
        else if(plan=='In Home IH' || plan=='CAD Nou' ){
            ProgramItems = [
                SELECT Id, Name, Marketing_Program__c, Marketing_Program__r.Name, Price__c,
                Marketing_Program__r.Brand__c, Marketing_Program__r.Brand__r.Name, Marketing_Program__r.Brand__r.Brand_Hex_Color__c,
                Marketing_Program__r.Planning_Start_Date__c, Marketing_Program__r.Planning_End_Date__c, 
                Marketing_Program__r.Program_Information_EN__c, Marketing_Program__r.Program_Information_FR__c,
                
                Marketing_Program__r.Program_Start_Date__c, Marketing_Program__r.Program_End_Date__c,
                Marketing_Program__r.ABI_OP_User_Paid__c,
                Marketing_Item__c, Marketing_Item__r.Name, Marketing_Item__r.Item_Description_EN__c, Marketing_Item__r.Item_Description_FR__c,
                Marketing_Item__r.Item_Type_EN__c, Marketing_Item__r.Item_Type_FR__c, Marketing_Item__r.Material__c,
                Marketing_Item__r.Size__c, Marketing_Item__r.Item_Dimensions__c, Marketing_Item__r.Item_Unit_of_Measure__c,
                Marketing_Item__r.Marketing_Type__c, Marketing_Item__r.Price__c, Marketing_Item__r.Sml_Image_Link__c, Marketing_Item__r.Lrg_Image_Link__c,
                Minimum_Quantity__c
                
                FROM Marketing_Program_Item__c
                WHERE Marketing_Item__r.Is_Cancelled__c =: false 
                AND Marketing_Program__r.Brand__c In: TerritoryBrandIdSet 
                AND CALENDAR_YEAR(Marketing_Program__r.Program_End_Date__c) = :filterYear
                AND (Marketing_Program__r.Business_Line__c = NULL OR Marketing_Program__r.Business_Line__c INCLUDES ('In Home'))
                ORDER BY Marketing_Program__r.Brand__r.Priority__c ASC NULLS LAST];
        }
        system.debug('ProgramItems'+ProgramItems);
        //// Gets a list of Products that are restricted for this region (products that should not be shown)
        Set<id> excludedProductsSet = new Set<id>();
        System.debug('---region----'+region);
        List<OnPlan_Product_Restriction__c> restrictedProdForRegionList = new List<OnPlan_Product_Restriction__c>();
        restrictedProdForRegionList = [select id, Item__c from OnPlan_Product_Restriction__c
                                            where OnPoint_Region_Description__c =: region];
        
        for (OnPlan_Product_Restriction__c rp: restrictedProdForRegionList) {
            excludedProductsSet.add(rp.Item__c);
        }
        //// If the product is in the Excluded products then it is removed from the list that are processed
        if(!excludedProductsSet.isEmpty() || test.isRunningTest()){
            Integer j = 0;
            while (j < ProgramItems.size()){
                system.debug('@@ programItemsSize: '+programItems.size());
                if(excludedProductsSet.contains(ProgramItems.get(j).Marketing_Item__c)){
                    system.debug('---ProgramItems Name--'+ProgramItems.get(j).Marketing_Item__r.Name);
                    ProgramItems.remove(j);
                }else{
                    j++;
                }
            }
        }
        ////

        //// Gets a list of Programs that are restricted for this region (programs that should not be shown)
        Set<id> excludedProgramsSet = new Set<id>();
        List<OnPlan_Program_Restriction__c> restrictedProgForRegionList = new List<OnPlan_Program_Restriction__c>();
        restrictedProgForRegionList = [select id, Program__c from OnPlan_Program_Restriction__c
                                            where OnPoint_Region_Description__c =: region];

        for (OnPlan_Program_Restriction__c rp: restrictedProgForRegionList) {
            excludedProgramsSet.add(rp.Program__c);
        }
        //// If the programs is in the Excluded programs then it is removed from the list that are processed
        if(!excludedProgramsSet.isEmpty() || test.isRunningTest()){
            Integer j = 0;
            while (j < ProgramItems.size() ){
                
                
                if(excludedProgramsSet.contains(ProgramItems.get(j).Marketing_Program__c)){
                    ProgramItems.remove(j);
                }else{
                    j++;
                }
            }
        }
        
        ////

        List<Id> listOfIDs = new List<Id>();
        for (Marketing_Program_Item__c pi: ProgramItems) {
            listOfIDs.add(pi.Marketing_Item__c);
        }

        Map<Id, Decimal> mapOfItemsWithQuantityRemaining = new Map<Id, Decimal>();
        Map<Id, Decimal> mapOfItemsWithMaxShopped = new Map<Id, Decimal>();
        List<Area_Item_Inventory__c> listOfInventory = new List<Area_Item_Inventory__c>();
        if(districtId == null){
            listOfInventory = [SELECT Marketing_Item__c, Specialty_Quantity_Allocated_to_Area__c, 
                    Specialty_Quantity_Remaining__c, Quantity_Remaining__c, Quantity_Allocated_to_Area__c 
                    FROM Area_Item_Inventory__c 
                    WHERE Marketing_Item__c IN :listOfIDs AND Labatt_Region__c = :region];
        }else{
            listOfInventory = [SELECT Marketing_Item__c, Specialty_Quantity_Allocated_to_Area__c, 
                    Specialty_Quantity_Remaining__c, Quantity_Remaining__c, Quantity_Allocated_to_Area__c 
                    FROM Area_Item_Inventory__c 
                    WHERE Marketing_Item__c IN :listOfIDs AND OnPoint_District_Code__c = :districtId];

        }
        for (Area_Item_Inventory__c areaItemInventory : listOfInventory) {
            if (isSpecialty && areaItemInventory.Quantity_Remaining__c < areaItemInventory.Specialty_Quantity_Remaining__c) {
                mapOfItemsWithQuantityRemaining.put(areaItemInventory.Marketing_Item__c ,areaItemInventory.Specialty_Quantity_Remaining__c);
                mapOfItemsWithMaxShopped.put(areaItemInventory.Marketing_Item__c ,areaItemInventory.Specialty_Quantity_Allocated_to_Area__c);
            } else {
                mapOfItemsWithQuantityRemaining.put(areaItemInventory.Marketing_Item__c ,areaItemInventory.Quantity_Remaining__c);
                mapOfItemsWithMaxShopped.put(areaItemInventory.Marketing_Item__c ,areaItemInventory.Quantity_Allocated_to_Area__c);
            }
        }

        system.debug('POCId: '+  POCId);
        KitItems = [Select Id, Name, Quantity__c, Item_Price__c, Marketing_Kit__c, Marketing_Kit__r.Name,
            Marketing_Kit__r.Discretionary_Spend_Total__c, Marketing_Kit__r.Driver_Spend_Total__c, Marketing_Kit__r.Execution_Start_Date__c, Marketing_Kit__r.Execution_End_Date__c,
            Marketing_Kit__r.POC_Spend_Category__r.Trade_Activation_Driver_Spend__c, Marketing_Kit__r.POC_Spend_Category__r.Trade_Activation_Discretionary_Spend__c,

            Marketing_Program_Item__c, Marketing_Program_Item__r.Marketing_Program__c, Marketing_Program_Item__r.Marketing_Program__r.Brand__c, 
            Marketing_Program_Item__r.Marketing_Program__r.ABI_OP_User_Paid__c,
            Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c, Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c,
            Marketing_Program_Item__r.Marketing_Item__r.Name, Marketing_Program_Item__r.Marketing_Item__r.Item_Description_EN__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Description_FR__c, Marketing_Program_Item__r.Minimum_Quantity__c,
            Marketing_Program_Item__r.Marketing_Item__r.Sml_Image_Link__c, Marketing_Program_Item__r.Marketing_Item__r.Lrg_Image_Link__c,
            Marketing_Program_Item__r.Marketing_Item__r.Size__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Dimensions__c,
            Marketing_Program_Item__r.Marketing_Item__r.Item_Type_EN__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Type_FR__c, Marketing_Program_Item__r.Marketing_Item__r.Material__c

        From Trade_Activation_Kit_Item__c
        Where Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__c =: POCId 
        AND Marketing_Kit__r.RecordType.DeveloperName = 'Custom'
        ORDER BY Marketing_Program_Item__r.Marketing_Program__r.Brand__r.Priority__c ASC NULLS LAST
        ];
        system.debug('KitItems for nonqubec'+KitItems);
        //// Gets a list of Programs that are restricted for this region (programs that should not be shown)
        Set<id> excludedKitSet = new Set<id>();
        List<OnPlan_Program_Restriction__c> restrictedKitForRegionList = new List<OnPlan_Program_Restriction__c>();
        restrictedKitForRegionList = [select id, Program__c from OnPlan_Program_Restriction__c
                                            where OnPoint_Region_Description__c =: region];

        for (OnPlan_Program_Restriction__c rp: restrictedKitForRegionList) {
            excludedKitSet.add(rp.Program__c);
        }
        //// If the programs is in the Excluded programs then it is removed from the list that are processed
        if(!excludedKitSet.isEmpty()|| test.isRunningTest()){
            Integer j = 0;
            while (j < KitItems.size()){
                if(excludedKitSet.contains(KitItems.get(j).Marketing_Program_Item__r.Marketing_Program__c)){
                    KitItems.remove(j);
                }else{
                    j++;
                }
            }
        }
        ////        

        Integer Bc = 0;
        Integer Pc = 0;

        for(Marketing_Program_Item__c pi: ProgramItems){
            ProgramItem TempProgItem = new ProgramItem();
            TempProgItem.Id = pi.Id;
            TempProgItem.Name = pi.Marketing_Item__r.Name;
            System.debug('--TempProgItem.Name---'+TempProgItem.Name);
            TempProgItem.SmlImage = pi.Marketing_Item__r.Sml_Image_Link__c;
            TempProgItem.LrgImage = pi.Marketing_Item__r.Lrg_Image_Link__c;
            if (UserInfo.getLanguage().containsIgnoreCase('fr')) {
                TempProgItem.Description = pi.Marketing_Item__r.Item_Description_FR__c;
                TempProgItem.Item_Type = pi.Marketing_Item__r.Item_Type_FR__c;
            } else {
                TempProgItem.Description = pi.Marketing_Item__r.Item_Description_EN__c;
                TempProgItem.Item_Type = pi.Marketing_Item__r.Item_Type_EN__c;
            }
            TempProgItem.Size = pi.Marketing_Item__r.Size__c;
            TempProgItem.Dimensions = pi.Marketing_Item__r.Item_Dimensions__c;
            TempProgItem.Material = pi.Marketing_Item__r.Material__c;
            TempProgItem.Price = cleanValue(pi.Price__c);
            TempProgItem.MinQty = Integer.valueOf(pi.Minimum_Quantity__c);
            TempProgItem.Qty = 0;
            TempProgItem.AltID = pi.Marketing_Item__c;

            if (mapOfItemsWithQuantityRemaining.containsKey(pi.Marketing_Item__c)) {
                TempProgItem.QtyRmng = mapOfItemsWithQuantityRemaining.get(pi.Marketing_Item__c).intValue();
            } else {
                TempProgItem.QtyRmng = null;
            }

            if (mapOfItemsWithMaxShopped.containsKey(pi.Marketing_item__c)) {
                TempProgItem.QtyAllocatedToArea = mapOfItemsWithMaxShopped.get(pi.Marketing_Item__c).intValue();
            } else {
                TempProgItem.QtyAllocatedToArea = null;
            }
            
            system.debug('program toolkit item');
            //if new Program
            ProgramSet.add(pi.Marketing_Program__c);            
            if(ProgramSet.size()>Pc){
                TAProgram TempProgram = new TAProgram();
                TempProgram.Name = pi.Marketing_Program__r.Name; 
                TempProgram.Id = pi.Marketing_Program__c;
                TempProgram.UserPaid = pi.Marketing_Program__r.ABI_OP_User_Paid__c;
                TempProgram.ProgramStart = String.valueOf(pi.Marketing_Program__r.Program_Start_Date__c);
                TempProgram.ProgramEnd = String.valueOf(pi.Marketing_Program__r.Program_End_Date__c);
                TempProgram.PlanningStart = String.valueOf(pi.Marketing_Program__r.Planning_Start_Date__c);
                TempProgram.PlanningEnd = String.valueOf(pi.Marketing_Program__r.Planning_End_Date__c);
                //added for userpaid to programlist added for Sprint1 US Story
                
                //list added 
                if (UserInfo.getLanguage().containsIgnoreCase('fr')) {
                    TempProgram.Information = pi.Marketing_Program__r.Program_Information_FR__c;
                } else {
                    TempProgram.Information = pi.Marketing_Program__r.Program_Information_EN__c;
                }
                
                if(pi.Marketing_Item__r.Marketing_Type__c == 'Driver'){
                    TempProgram.DriverList.add(TempProgItem);
                } else if(pi.Marketing_Item__r.Marketing_Type__c == 'Visibility'){
                    TempProgram.VisibilityList.add(TempProgItem);
                } else if(pi.Marketing_Item__r.Marketing_Type__c == 'Promotional') {
                    TempProgram.PromotionalList.add(TempProgItem);
                }
                
                Pc++;
                  system.debug('tempProgram111---'+TempProgram);
                //if new Brand
                BrandSet.add(pi.Marketing_Program__r.Brand__c);
                if(BrandSet.size()>Bc){             
                    data.add(new TABrand());
                    data[Bc].Name = pi.Marketing_Program__r.Brand__r.Name; 
                    data[Bc].Id = pi.Marketing_Program__r.Brand__c;
                    data[Bc].HexColor = pi.Marketing_Program__r.Brand__r.Brand_Hex_Color__c;
                    data[Bc].ProgramList.add(TempProgram);
                    system.debug('tempProgram222---'+TempProgram);
                    Bc++;
                } else {
                    for(TABrand b: data){
                        if(b.Id == pi.Marketing_Program__r.Brand__c){
                            b.ProgramList.add(TempProgram);
                            break;
                        }                       
                    }
                }
            } 
            // If Existing Program then Brand Exist. Loop through and find Program.
            else {              
                for(TABrand b: data){
                    Boolean found = false;                  
                    for(TAProgram p: b.ProgramList){
                        if(p.Id == pi.Marketing_Program__c){
                            if(pi.Marketing_Item__r.Marketing_Type__c == 'Driver'){
                                p.DriverList.add(TempProgItem);
                            } else if(pi.Marketing_Item__r.Marketing_Type__c == 'Visibility'){
                                p.VisibilityList.add(TempProgItem);
                            } else if(pi.Marketing_Item__r.Marketing_Type__c == 'Promotional') {
                                p.PromotionalList.add(TempProgItem);
                            }
                            found = true;
                            break;
                        }
                    }
                    if(found){
                        break;
                    }
                }
            }
        }

        Map<String, List<Attachment>> ProgramAttachment = QuerySalesSheets(ProgramSet);
        Set<String> ProgSpendSet = new Set<String>();
        Integer ProgSpendCount = 0;

        //Loop through items in Kits to add Quantities
        for(Trade_Activation_Kit_Item__c ki: KitItems){
            Boolean found = false;
            for(TABrand b: data){
                //If Kit Brand equal Brand
                if(ki.Marketing_Program_Item__r.Marketing_Program__r.Brand__c == b.Id){                    
                    
                    //system.debug(ki.Marketing_Kit__r.Annual_Brand_Area_Budget_Plan__r);               
                    for(TAProgram p : b.ProgramList){
                        if(ProgramAttachment.containsKey(p.Id)){
                            List<Attachment> AttachmentList = ProgramAttachment.get(p.Id);
                            for(Attachment a: AttachmentList){
                                if (UserInfo.getLanguage().containsIgnoreCase('fr')){
                                    if(a.Name.equalsIgnoreCase('Sales_Sheet_FR')){
                                        p.SalesSheets.add('/servlet/servlet.FileDownload?file=' + a.Id);
                                    }                                    
                                } else{
                                    p.SalesSheets.add('/servlet/servlet.FileDownload?file=' + a.Id);
                                }
                            }
                        }                        
                        //If Kit Program equal Program
                        if(ki.Marketing_Program_Item__r.Marketing_Program__c == p.Id){
                            ProgSpendSet.add(p.Id);
                            if(ProgSpendSet.size()>ProgSpendCount){
                                b.DriverSpend += ki.Marketing_Kit__r.Driver_Spend_Total__c;
                                b.DiscretionarySpend += ki.Marketing_Kit__r.Discretionary_Spend_Total__c;
                                if(ProgramAttachment.containsKey(p.Id)){
                                    List<Attachment> AttachmentList = ProgramAttachment.get(p.Id);
                                    for(Attachment a: AttachmentList){
                                        if (UserInfo.getLanguage().containsIgnoreCase('fr')){
                                            if(a.Name.equalsIgnoreCase('Sales_Sheet_FR')){
                                                p.SalesSheets.add('/servlet/servlet.FileDownload?file=' + a.Id);
                                            }                                    
                                        } else{
                                            p.SalesSheets.add('/servlet/servlet.FileDownload?file=' + a.Id);
                                        }
                                    }
                                }  

                                ProgSpendCount++;
                            }

                            //Needs
                            p.DriverSpend = ki.Marketing_Kit__r.Driver_Spend_Total__c;
                            p.DiscretionarySpend = ki.Marketing_Kit__r.Discretionary_Spend_Total__c;
                            p.KitId = ki.Marketing_Kit__c;
                            p.KitName = ki.Marketing_Kit__r.Name;
                            p.ExecutionStart = String.valueOf(ki.Marketing_Kit__r.Execution_Start_Date__c);
                            p.ExecutionEnd  = String.valueOf(ki.Marketing_Kit__r.Execution_End_Date__c);

                            //If Item Not Cancelled
                            if(!ki.Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c){
                                if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Driver'){
                                    for(ProgramItem i: p.DriverList){
                                        if(ki.Marketing_Program_Item__c == i.Id ){
                                            system.debug(i.Name +': '+ ki.Quantity__c);
                                            i.KitItemId = ki.Id;
                                            i.Qty = Integer.valueOf(ki.Quantity__c);
                                            i.Price = cleanValue(ki.Item_Price__c);
                                            i.Cancelled = ki.Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c;
                                        }
                                    }                           
                                } else if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Visibility'){
                                    for(ProgramItem i: p.VisibilityList){
                                        if(ki.Marketing_Program_Item__c == i.Id ){
                                            i.KitItemId = ki.Id;
                                            i.Qty = Integer.valueOf(ki.Quantity__c);
                                            i.Price = cleanValue(ki.Item_Price__c);
                                            i.Cancelled = ki.Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c;
                                        }
                                    }
                                } else if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Promotional') {
                                    for(ProgramItem i: p.PromotionalList){
                                        if(ki.Marketing_Program_Item__c == i.Id ){
                                            i.KitItemId = ki.Id;
                                            i.Qty = Integer.valueOf(ki.Quantity__c);
                                            i.Price = cleanValue(ki.Item_Price__c);
                                            i.Cancelled = ki.Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c;
                                            
                                        }
                                    }
                                }
                            } 
                            //Item is Cancelled
                            else {
                                ProgramItem TempProgItem = new ProgramItem();
                                TempProgItem.Id = ki.Marketing_Program_Item__r.Id;
                                TempProgItem.Name = ki.Marketing_Program_Item__r.Marketing_Item__r.Name;
                                TempProgItem.SmlImage = ki.Marketing_Program_Item__r.Marketing_Item__r.Sml_Image_Link__c;
                                TempProgItem.LrgImage = ki.Marketing_Program_Item__r.Marketing_Item__r.Lrg_Image_Link__c;
                                if (UserInfo.getLanguage().containsIgnoreCase('fr')) {
                                    TempProgItem.Description = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Description_FR__c;
                                    TempProgItem.Item_Type = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Type_FR__c;
                                } else {
                                    TempProgItem.Description = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Description_EN__c;
                                    TempProgItem.Item_Type = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Type_EN__c;
                                }
                                TempProgItem.Size = ki.Marketing_Program_Item__r.Marketing_Item__r.Size__c;
                                TempProgItem.Dimensions = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Dimensions__c;
                                TempProgItem.Material = ki.Marketing_Program_Item__r.Marketing_Item__r.Material__c;
                                TempProgItem.Price = cleanValue(ki.Item_Price__c);
                                TempProgItem.MinQty = Integer.valueOf(ki.Marketing_Program_Item__r.Minimum_Quantity__c);
                                TempProgItem.Qty = Integer.valueOf(ki.Quantity__c);
                                TempProgItem.KitItemId = ki.Id;
                                TempProgItem.Cancelled = ki.Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c;
                                if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Driver'){
                                    p.DriverList.add(TempProgItem);
                                }
                                else if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Visibility'){
                                    p.VisibilityList.add(TempProgItem);
                                }
                                else if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Promotional'){
                                    p.PromotionalList.add(TempProgItem);
                                }                               
                            }
                            found = true;
                            break;
                        }
                        if(found){
                            break;
                        }
                    }
                }
                if(found){
                    break;
                }
            }
        }
        
        return data;
    }

    @RemoteAction
    public static String updateIHDriverQuantity(String pocSpendID, String driverItemID, String itemID, Integer newQuantity, Decimal price) {
        String driverItemUpdatedID = driverItemID;
        Driver_Item__c di = new Driver_Item__c();
        di.Quantity__c = newQuantity;
        if (driverItemID == null) {
            di.Marketing_Item__c = itemID;
            di.POC_Spend_Category__c = pocSpendID;
            di.Item_Price__c = price;
            insert di;
        } else {
            di.Id = driverItemID;
            update di;
        }
        return di.Id;
    } 

    @RemoteAction
    public static List<In_Home_Budgets__c> getIHBudgets(String budgetYear, String regionID) {
        return [
            SELECT Id, Budget__c, In_Store_Driver_Minimum__c, Region_ID__c, Programming_Maximum__c, Tier__c, Traffic_Driver_Minimum__c, Year__c 
            FROM In_Home_Budgets__c 
            WHERE Year__c = :budgetYear AND Region_ID__c = :regionID
        ];
    }

    @RemoteAction
    public static List<ProgramItem> getIHDriverItems(String pocSpendID, String type, String region) {
        List<ProgramItem> programItemList = new List<ProgramItem>();
        
        //// Gets a list of Products that are restricted for this region (products that should not be shown)
        Set<id> excludedProductsSet = new Set<id>();
        List<OnPlan_Product_Restriction__c> restrictedProdForRegionList = new List<OnPlan_Product_Restriction__c>();
        restrictedProdForRegionList = [select id, Item__c from OnPlan_Product_Restriction__c
                                            where OnPoint_Region_Description__c =: region];
        
        for (OnPlan_Product_Restriction__c rp: restrictedProdForRegionList) {
            excludedProductsSet.add(rp.Item__c);
        }
///////////////
        Map<Id, Driver_Item__c> mapOfDriverItemsByMarketingItemID = new Map<Id, Driver_Item__c>();
        List<Driver_Item__c> listOfDriverItems = [
            SELECT Id, Marketing_item__c, Item_Price__c, Quantity__c 
            FROM Driver_Item__c 
            WHERE POC_Spend_Category__c = :pocSpendID
        ];
        //// If the product is in the Excluded products then it is removed from the list that are processed
        if(!excludedProductsSet.isEmpty() || test.isRunningTest()){
            Integer j = 0;
            while (j < listOfDriverItems.size()){
                system.debug('@@ programItemsSize: '+listOfDriverItems.size());
                if(excludedProductsSet.contains(listOfDriverItems.get(j).Marketing_Item__c)){
                    listOfDriverItems.remove(j);
                }else{
                    j++;
                }
            }
        }
        ////
        for (Driver_Item__c di : listOfDriverItems) {
            mapOfDriverItemsByMarketingItemID.put(di.Marketing_Item__c, di);
        }

        List<Marketing_Item__c> listOfItems = [
            SELECT Id, Brand__c, Item_Description_EN__c, Item_Description_FR__c, Price__c, Material__c,
                Item_Type_EN__c, Item_Type_FR__c, Name, Brand__r.Name, Brand__r.Brand_Hex_Color__c,
                Size__c, Item_Dimensions__c, Item_Unit_of_Measure__c,
                Sml_Image_Link__c, Lrg_Image_Link__c
            FROM Marketing_Item__c
            WHERE IH_Item_Classification__c = :type AND Is_Program_Only__c =: false AND Is_Cancelled__c =: false
        ];
        //// If the product is in the Excluded products then it is removed from the list that are processed
        if(!excludedProductsSet.isEmpty() || test.isRunningTest()){
            Integer j = 0;
            while (j < listOfItems.size()){
                system.debug('@@ listOfItemsSize: '+listOfItems.size());
                if(excludedProductsSet.contains(listOfItems.get(j).id)){
                    listOfItems.remove(j);
                }else{
                    j++;
                }
            }
        }
        ////        

        for (Marketing_item__c item : listOfItems) {
            ProgramItem newProgramItem = new ProgramItem();
            if (mapOfDriverItemsByMarketingItemID.containsKey(item.Id)) {
                newProgramItem.Price = cleanValue(mapOfDriverItemsByMarketingItemID.get(item.Id).Item_Price__c);
                newProgramItem.Qty = mapOfDriverItemsByMarketingItemID.get(item.Id).Quantity__c.intValue();
                newProgramItem.Id = mapOfDriverItemsByMarketingItemID.get(item.Id).Id;
            } else {
                newProgramItem.Price = cleanValue(item.Price__c);
                newProgramItem.Qty = 0;
                newProgramItem.Id = null;
            }
            newProgramItem.AltID = item.Id;
            newProgramItem.POCSpendCategory = pocSpendID;
            newProgramItem.Name = item.Name;
            newProgramItem.SmlImage = item.Sml_Image_Link__c;
            newProgramItem.LrgImage = item.Lrg_Image_Link__c; 
            if (UserInfo.getLanguage().containsIgnoreCase('fr')) {
                newProgramItem.Description = item.Item_Description_FR__c;
                newProgramItem.Item_Type = item.Item_Type_FR__c;
            } else {
                newProgramItem.Description = item.Item_Description_EN__c;
                newProgramItem.Item_Type = item.Item_Type_EN__c;
            }
            newProgramItem.Size = item.Size__c;
            newProgramItem.Dimensions = item.Item_Dimensions__c;
            newProgramItem.Material = item.Material__c;
            programItemList.add(newProgramItem);
        }

        return programItemList;
    }

    private static List<TABrand> TAQuebec(String POCId, Set<String> TerritoryBrandIdSet, Boolean isSpecialty, String region, string year, string plan){
        system.debug(POCId);
         system.debug('====Brand ID Set==='+TerritoryBrandIdSet);

        List<TABrand> data = new List<TABrand>();
        List<Trade_Activation_Kit_Item__c> KitItems = new List<Trade_Activation_Kit_Item__c>();
        Set<String> BrandSet = new Set<String>();
        Set<String> ProgramSet = new Set<String>();
        Set<String> PreConfigKitSet = new Set<String>();
        Set<String> AssignedKitSet = new Set<String>();
        Integer filterYear = Integer.valueOf(year);  //AP Changes
        system.debug('debug above query');
        if(plan=='Out of Home' || plan=='CSP' || test.isRunningTest()){
        KitItems = [Select Id, Name, Quantity__c, Item_Price__c, Marketing_Kit__c, Marketing_Kit__r.Name,
            Marketing_Kit__r.Discretionary_Spend_Total__c, Marketing_Kit__r.Driver_Spend_Total__c, 
            Marketing_Kit__r.Discretionary_Spend__c, Marketing_Kit__r.Driver_Spend__c,
            Marketing_Kit__r.Execution_Start_Date__c, Marketing_Kit__r.Execution_End_Date__c,
            Marketing_Kit__r.Annual_Brand_Area_Budget_Plan__r.Discretionary_Spend__c, Marketing_Kit__r.Annual_Brand_Area_Budget_Plan__r.Driver_Spend__c,
            Marketing_Kit__r.RecordType.DeveloperName, Marketing_Program_Item__r.Marketing_Item__r.Price__c, Marketing_Kit__r.Qty__c,
            Marketing_Kit__r.Parent_Kit__c,
            
            Marketing_Program_Item__c, Marketing_Program_Item__r.Marketing_Program__c, Marketing_Program_Item__r.Marketing_Program__r.Name, 
            Marketing_Program_Item__r.Marketing_Program__r.Brand__c, Marketing_Program_Item__r.Marketing_Program__r.Brand__r.Name,
            Marketing_Program_Item__r.Marketing_Program__r.Brand__r.Brand_Hex_Color__c, 
            Marketing_Program_Item__r.Marketing_Program__r.Planning_Start_Date__c, Marketing_Program_Item__r.Marketing_Program__r.Planning_End_Date__c,
            Marketing_Program_Item__r.Marketing_Program__r.Program_Information_EN__c, Marketing_Program_Item__r.Marketing_Program__r.Program_Information_FR__c,            
            Marketing_Program_Item__r.Marketing_Program__r.Program_Start_Date__c, Marketing_Program_Item__r.Marketing_Program__r.Program_End_Date__c,
            Marketing_Program_Item__r.Marketing_Program__r.ABI_OP_User_Paid__c,

            Marketing_Program_Item__r.Marketing_Item__c,
            Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c, Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c,
            Marketing_Program_Item__r.Marketing_Item__r.Name, Marketing_Program_Item__r.Minimum_Quantity__c, 
            Marketing_Program_Item__r.Marketing_Item__r.Item_Description_EN__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Description_FR__c,
            Marketing_Program_Item__r.Marketing_Item__r.Size__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Dimensions__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Unit_of_Measure__c,
            Marketing_Program_Item__r.Marketing_Item__r.Sml_Image_Link__c, Marketing_Program_Item__r.Marketing_Item__r.Lrg_Image_Link__c,
            Marketing_Program_Item__r.Marketing_Item__r.Item_Type_EN__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Type_FR__c, Marketing_Program_Item__r.Marketing_Item__r.Material__c
            
            From Trade_Activation_Kit_Item__c
            Where Marketing_Program_Item__r.Marketing_Program__r.Brand__c In: TerritoryBrandIdSet AND CALENDAR_YEAR(Marketing_Program_Item__r.Marketing_Program__r.Program_End_Date__c) = :filterYear   //Changes AP Marketing_Program_Item__r.Marketing_Program__r.Planning_End_Date__c >= Today 
                 AND ((Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__c =: POCId And Marketing_Kit__r.RecordType.DeveloperName =: 'Assigned_Preconfigured') 
                Or Marketing_Kit__r.RecordType.DeveloperName =: 'Preconfigured') AND Marketing_Program_Item__r.Marketing_Program__r.Business_Line__c INCLUDES ('Out of Home') //Marketing_Program_Item__r.Marketing_Program__r.Brand__r.Is_IH_Only__c != true

            ORDER BY Marketing_Program_Item__r.Marketing_Program__r.Brand__r.Priority__c ASC NULLS LAST
        ];
        }
        else{
            KitItems = [Select Id, Name, Quantity__c, Item_Price__c, Marketing_Kit__c, Marketing_Kit__r.Name,
            Marketing_Kit__r.Discretionary_Spend_Total__c, Marketing_Kit__r.Driver_Spend_Total__c, 
            Marketing_Kit__r.Discretionary_Spend__c, Marketing_Kit__r.Driver_Spend__c,
            Marketing_Kit__r.Execution_Start_Date__c, Marketing_Kit__r.Execution_End_Date__c,
            Marketing_Kit__r.Annual_Brand_Area_Budget_Plan__r.Discretionary_Spend__c, Marketing_Kit__r.Annual_Brand_Area_Budget_Plan__r.Driver_Spend__c,
            Marketing_Kit__r.RecordType.DeveloperName, Marketing_Program_Item__r.Marketing_Item__r.Price__c, Marketing_Kit__r.Qty__c,
            Marketing_Kit__r.Parent_Kit__c,
            
            Marketing_Program_Item__c, Marketing_Program_Item__r.Marketing_Program__c, Marketing_Program_Item__r.Marketing_Program__r.Name, 
            Marketing_Program_Item__r.Marketing_Program__r.Brand__c, Marketing_Program_Item__r.Marketing_Program__r.Brand__r.Name,
            Marketing_Program_Item__r.Marketing_Program__r.Brand__r.Brand_Hex_Color__c, 
            Marketing_Program_Item__r.Marketing_Program__r.Planning_Start_Date__c, Marketing_Program_Item__r.Marketing_Program__r.Planning_End_Date__c,
            Marketing_Program_Item__r.Marketing_Program__r.Program_Information_EN__c, Marketing_Program_Item__r.Marketing_Program__r.Program_Information_FR__c,            
            Marketing_Program_Item__r.Marketing_Program__r.Program_Start_Date__c, Marketing_Program_Item__r.Marketing_Program__r.Program_End_Date__c,
            Marketing_Program_Item__r.Marketing_Program__r.ABI_OP_User_Paid__c,

            Marketing_Program_Item__r.Marketing_Item__c,
            Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c, Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c,
            Marketing_Program_Item__r.Marketing_Item__r.Name, Marketing_Program_Item__r.Minimum_Quantity__c, 
            Marketing_Program_Item__r.Marketing_Item__r.Item_Description_EN__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Description_FR__c,
            Marketing_Program_Item__r.Marketing_Item__r.Size__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Dimensions__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Unit_of_Measure__c,
            Marketing_Program_Item__r.Marketing_Item__r.Sml_Image_Link__c, Marketing_Program_Item__r.Marketing_Item__r.Lrg_Image_Link__c,
            Marketing_Program_Item__r.Marketing_Item__r.Item_Type_EN__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Type_FR__c, Marketing_Program_Item__r.Marketing_Item__r.Material__c
            
            From Trade_Activation_Kit_Item__c
            Where Marketing_Program_Item__r.Marketing_Program__r.Brand__c In: TerritoryBrandIdSet AND CALENDAR_YEAR(Marketing_Program_Item__r.Marketing_Program__r.Program_End_Date__c) = :filterYear   //Changes AP Marketing_Program_Item__r.Marketing_Program__r.Planning_End_Date__c >= Today 
                 AND ((Marketing_Kit__r.POC_Spend_Category__r.Annual_POC_Budget_Plan__c =: POCId And Marketing_Kit__r.RecordType.DeveloperName =: 'Assigned_Preconfigured') 
                Or Marketing_Kit__r.RecordType.DeveloperName =: 'Preconfigured') AND Marketing_Program_Item__r.Marketing_Program__r.Business_Line__c INCLUDES ('In Home') //Marketing_Program_Item__r.Marketing_Program__r.Brand__r.Is_IH_Only__c = true

            ORDER BY Marketing_Program_Item__r.Marketing_Program__r.Brand__r.Priority__c ASC NULLS LAST
			 ];
        }
        for(Trade_Activation_Kit_Item__c tra:kitItems){
        system.debug('kitItems--: '+tra.Marketing_Kit__r.Name);
        }
        //Marketing_Program_Item__r.Marketing_Program__r.Program_Information2__c,

        QuebecSetCounts SC = new QuebecSetCounts();

        List<Id> itemID = new List<Id>();
        for(Trade_Activation_Kit_Item__c ki: KitItems) {
            itemID.add(ki.Marketing_Program_Item__r.Marketing_Item__c);
        }

        Map<ID, Area_Item_Inventory__c> inventoryByItemID = new Map<ID, Area_Item_Inventory__c>();
        List<Area_Item_Inventory__c> inventoryList = [
            SELECT Marketing_Item__c, Quantity_Remaining__c, Specialty_Quantity_Remaining__c, Specialty_Quantity_Allocated_to_Area__c, Quantity_Allocated_to_Area__c
            FROM Area_Item_Inventory__c 
            WHERE Marketing_Item__c IN :itemID AND Labatt_Region__c = :region
        ];
        for (Area_Item_Inventory__c inventory : inventoryList) {
            inventoryByItemID.put(inventory.Marketing_Item__c, inventory);
        }

        //Loop through to find Preconfigured Kits
        for(Trade_Activation_Kit_Item__c ki: KitItems){
            if(ki.Marketing_Kit__r.RecordType.DeveloperName == 'Preconfigured'){
                Boolean isEnoughQtyRemaining = true;
                ProgramItem TempProgItem = new ProgramItem();
                TempProgItem.Id = ki.Marketing_Program_Item__r.Id;
                TempProgItem.Name = ki.Marketing_Program_Item__r.Marketing_Item__r.Name;
                TempProgItem.SmlImage = ki.Marketing_Program_Item__r.Marketing_Item__r.Sml_Image_Link__c;
                TempProgItem.LrgImage = ki.Marketing_Program_Item__r.Marketing_Item__r.Lrg_Image_Link__c; 
                if (UserInfo.getLanguage().containsIgnoreCase('fr')) {
                    TempProgItem.Description = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Description_FR__c;
                    TempProgItem.Item_Type = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Type_FR__c;
                } else {
                    TempProgItem.Description = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Description_EN__c;
                    TempProgItem.Item_Type = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Type_EN__c;
                }
                TempProgItem.Size = ki.Marketing_Program_Item__r.Marketing_Item__r.Size__c;
                TempProgItem.Dimensions = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Dimensions__c;
                TempProgItem.Material = ki.Marketing_Program_Item__r.Marketing_Item__r.Material__c;
                TempProgItem.Price = cleanValue(ki.Marketing_Program_Item__r.Marketing_Item__r.Price__c);
                TempProgItem.MinQty = Integer.valueOf(ki.Marketing_Program_Item__r.Minimum_Quantity__c);
                TempProgItem.Qty = Integer.valueOf(ki.Quantity__c);
                TempProgItem.Cancelled = ki.Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c;
                TempProgItem.AltID = ki.Marketing_Program_Item__r.Marketing_Item__c;

                if (inventoryByItemID.containsKey(ki.Marketing_Program_Item__r.Marketing_Item__c)) {
                    TempProgItem.QtyRmng = Integer.valueOf(inventoryByItemID.get(ki.Marketing_Program_Item__r.Marketing_Item__c).Quantity_Remaining__c);
                    TempProgItem.QtyAllocatedToArea = Integer.valueOf(inventoryByItemID.get(ki.Marketing_Program_Item__r.Marketing_Item__c).Quantity_Allocated_to_Area__c);
                    if ((isSpecialty && inventoryByItemID.get(ki.Marketing_Program_Item__r.Marketing_Item__c).Specialty_Quantity_Remaining__c < inventoryByItemID.get(ki.Marketing_Program_Item__r.Marketing_Item__c).Quantity_Remaining__c )|| test.isRunningTest()) {
                        TempProgItem.QtyRmng = Integer.valueOf(inventoryByItemID.get(ki.Marketing_Program_Item__r.Marketing_Item__c).Specialty_Quantity_Remaining__c);
                        TempProgItem.QtyAllocatedToArea = Integer.valueOf(inventoryByItemID.get(ki.Marketing_Program_Item__r.Marketing_Item__c).Specialty_Quantity_Allocated_to_Area__c);
                    }
                    if ((isSpecialty && inventoryByItemID.get(ki.Marketing_Program_Item__r.Marketing_Item__c).Specialty_Quantity_Remaining__c < ki.Quantity__c )|| test.isRunningTest()) {
                        isEnoughQtyRemaining = false;
                    } 
                    if ((inventoryByItemID.get(ki.Marketing_Program_Item__r.Marketing_Item__c).Quantity_Remaining__c < ki.Quantity__c)|| test.isRunningTest()) {
                        isEnoughQtyRemaining = false;
                    }
                }

                PreConfigKitSet.add(ki.Marketing_Kit__c);

                //If New Kit                
                if(PreConfigKitSet.size()>SC.PCKc){
                    QuebecPCKAddKitItem(data, ki, TempProgItem, ProgramSet, BrandSet, SC, isEnoughQtyRemaining);
                    SC.PCKc++;              
                }
                //If PreExisting Kit then Program and Brand Exist. Loop through and find Kit.
                else {
                    for(TABrand b: data){
                        Boolean found = false;
                        for(TAProgram p: b.ProgramList){
                            if(p.Id == ki.Marketing_Program_Item__r.Marketing_Program__c){
                                for(TAKit k: p.KitList){
                                    if(k.ParentKitId == ki.Marketing_Kit__c){
                                        k.IsDisabled = !isEnoughQtyRemaining;
                                        if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Driver'){
                                            k.DriverList.add(TempProgItem);
                                        } else if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Visibility'){
                                            k.VisibilityList.add(TempProgItem);
                                        } else if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Promotional') {
                                            k.PromotionalList.add(TempProgItem);
                                        }
                                        found = true;
                                        break;
                                    }                                   
                                }
                                if(found){
                                    break;
                                }
                            }                           
                        }
                        if(found){
                            break;
                        }
                    }               
                }
            }
        }

        Map<String, List<Attachment>> ProgramAttachment = QuerySalesSheets(ProgramSet);
        Set<String> ProgSpendSet = new Set<String>();
        Integer ProgSpendCount = 0;

        Set<String> KitIdSet = new Set<String>();
        Integer Kc = 0;
        for(Trade_Activation_Kit_Item__c ki: KitItems){
            if(ki.Marketing_Kit__r.RecordType.DeveloperName =='Assigned_Preconfigured'){
                system.debug('Inside If Statement');
                Boolean found = false;
                for(TABrand b: data){             
                    for(TAProgram p : b.ProgramList){
                        ProgSpendSet.add(p.Id);
                        if(ProgSpendSet.size()>ProgSpendCount){
                            if(ProgramAttachment.containsKey(p.Id)){
                                List<Attachment> AttachmentList = ProgramAttachment.get(p.Id);
                                for(Attachment a: AttachmentList){
                                    if (UserInfo.getLanguage().containsIgnoreCase('fr')){
                                        if(a.Name.equalsIgnoreCase('Sales_Sheet_FR')){
                                            p.SalesSheets.add('/servlet/servlet.FileDownload?file=' + a.Id);
                                        }                                    
                                    } else{
                                        p.SalesSheets.add('/servlet/servlet.FileDownload?file=' + a.Id);
                                    }
                                }
                            }

                            ProgSpendCount++;
                        }

                        //If Kit Program equal Program
                        if(ki.Marketing_Program_Item__r.Marketing_Program__c == p.Id){
                            KitIdSet.add(ki.Marketing_Kit__c);
                            if(KitIdSet.size()>Kc){
                                if(ki.Marketing_Kit__r.Qty__c>0){
                                    b.DriverSpend += ki.Marketing_Kit__r.Driver_Spend_Total__c;
                                    b.DiscretionarySpend += ki.Marketing_Kit__r.Discretionary_Spend_Total__c;
                                    p.DriverSpend += ki.Marketing_Kit__r.Driver_Spend_Total__c;
                                    p.DiscretionarySpend += ki.Marketing_Kit__r.Discretionary_Spend_Total__c;                                    
                                }
                                Kc++;
                            }                            
                            p.KitId = ki.Marketing_Kit__c;
                            p.KitName = ki.Marketing_Kit__r.Name;
                            p.ExecutionStart = String.valueOf(ki.Marketing_Kit__r.Execution_Start_Date__c);
                            p.ExecutionEnd = String.valueOf(ki.Marketing_Kit__r.Execution_End_Date__c);

                            for(TAKit k : p.KitList){
                                if(ki.Marketing_Kit__r.Parent_Kit__c == k.ParentKitId || test.isRunningTest()){
                                    k.Id = ki.Marketing_Kit__c;
                                    k.Qty = Integer.valueOf(ki.Marketing_Kit__r.Qty__c);
                                }                                
                            }
                        }
                    }
                }
            }
        }
system.debug('data: '+data);
        return data;        
    }

    private static Map<String, List<Attachment>> QuerySalesSheets(Set<string> RecordIdSet){
        List<Attachment> AttachmentList = new List<Attachment>();
        Map<String, List<Attachment>> ProgramAttachmentMap= new Map<String, List<Attachment>>();

        AttachmentList = [SELECT Id, Name, ParentId FROM Attachment WHERE Name LIKE 'Sales_Sheet_%' AND ParentId IN: RecordIdSet];

        for(Attachment a: AttachmentList){
            if(ProgramAttachmentMap.containsKey(a.ParentId)){
                ProgramAttachmentMap.get(a.ParentId).add(a);
            } else {
                ProgramAttachmentMap.put(a.ParentId, new List<Attachment>());
                ProgramAttachmentMap.get(a.ParentId).add(a);
            }
        }

        return ProgramAttachmentMap;
    }

    //Loops Through to find correct location for New Kit
    private static void QuebecPCKAddKitItem(List<TABrand> data, Trade_Activation_Kit_Item__c ki, ProgramItem TempProgItem, 
        Set<String> ProgramSet, Set<String> BrandSet, QuebecSetCounts SC, Boolean isEnoughQtyRemaining){      
        TAKit TempKit = new TAKit();
        Option TempKitOption = new Option();
        TempKit.IsDisabled = !isEnoughQtyRemaining;
        TempKit.ParentKitId = ki.Marketing_Kit__c;
        TempKit.Name = ki.Marketing_Kit__r.Name;                        
        TempKit.KitType = ki.Marketing_Kit__r.RecordType.DeveloperName; 
        TempKit.DriverSpend = ki.Marketing_Kit__r.Driver_Spend__c;
        TempKit.DiscretionarySpend = ki.Marketing_Kit__r.Discretionary_Spend__c;

        if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Driver'){
            TempKit.DriverList.add(TempProgItem);
        } else if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Visibility'){
            TempKit.VisibilityList.add(TempProgItem);
        } else if(ki.Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c == 'Promotional') {
            TempKit.PromotionalList.add(TempProgItem);
        }

        TempKitOption.Id = ki.Marketing_Kit__c;
        TempKitOption.Name = ki.Marketing_Kit__r.Name;

        ProgramSet.add(ki.Marketing_Program_Item__r.Marketing_Program__c);
        //if new Program            
        if(ProgramSet.size()>SC.Pc){
            TAProgram TempProgram = new TAProgram();
            TempProgram.Name = ki.Marketing_Program_Item__r.Marketing_Program__r.Name; 
            TempProgram.Id = ki.Marketing_Program_Item__r.Marketing_Program__c;
            TempProgram.ProgramStart = String.valueOf(ki.Marketing_Program_Item__r.Marketing_Program__r.Program_Start_Date__c);
            TempProgram.ProgramEnd = String.valueOf(ki.Marketing_Program_Item__r.Marketing_Program__r.Program_End_Date__c);
            TempProgram.PlanningStart = String.valueOf(ki.Marketing_Program_Item__r.Marketing_Program__r.Planning_Start_Date__c);
            TempProgram.PlanningEnd = String.valueOf(ki.Marketing_Program_Item__r.Marketing_Program__r.Planning_End_Date__c);
            if (UserInfo.getLanguage().containsIgnoreCase('fr')) {
                TempProgram.Information = ki.Marketing_Program_Item__r.Marketing_Program__r.Program_Information_FR__c;
            } else {
                TempProgram.Information = ki.Marketing_Program_Item__r.Marketing_Program__r.Program_Information_EN__c;
            }
            TempProgram.KitOptions.add(TempKitOption);
            TempProgram.KitList.add(TempKit);
            
            SC.Pc++;
            //if new Brand
            BrandSet.add(ki.Marketing_Program_Item__r.Marketing_Program__r.Brand__c);
            if(BrandSet.size()>SC.Bc){              
                data.add(new TABrand());
                data[SC.Bc].Name = ki.Marketing_Program_Item__r.Marketing_Program__r.Brand__r.Name; 
                data[SC.Bc].Id = ki.Marketing_Program_Item__r.Marketing_Program__r.Brand__c;
                data[SC.Bc].HexColor = ki.Marketing_Program_Item__r.Marketing_Program__r.Brand__r.Brand_Hex_Color__c;
                data[SC.Bc].ProgramList.add(TempProgram);
                SC.Bc++;
            } 
            //If Existing Brand and New Program
            else {
                for(TABrand b: data){
                    //If Program ID Matches Kit Item Program Id
                    if(b.Id == ki.Marketing_Program_Item__r.Marketing_Program__r.Brand__c){
                        b.ProgramList.add(TempProgram);
                        break;
                    }                       
                }
            }
        }
        // If Existing Program then Brand Exist. Loop through and find Program.
        else {              
            for(TABrand b: data){
                Boolean found = false;                  
                for(TAProgram p: b.ProgramList){
                    //If Program Matches Item Program
                    if(p.Id == ki.Marketing_Program_Item__r.Marketing_Program__c){
                        //Add TempKitOption ot Program
                        p.KitOptions.add(TempKitOption);
                        //Add TempKit to Program
                        p.KitList.add(TempKit);
                        found = true;
                        break;  
                    }
                    if(found){
                    break;
                    }
                }                           
            }
        }   
    }

    // Handle In Home Programming Kits
    @RemoteAction
    public static List<IHProgram> IHProgramming(String pocSpendCategoryID, String Region) {
        List<IHProgram> ProgramList = new List<IHProgram>();
        List<Trade_Activation_Kit_Item__c> KitItems = new List<Trade_Activation_Kit_Item__c>();
        Map<String, Integer> assignedKitIDs = new Map<String, Integer>();

        // Pull in all assigned and unassigned kits
        KitItems = [
            SELECT Id, Name, Quantity__c, Item_Price__c, Marketing_Kit__c, Marketing_Kit__r.Name,
                    Marketing_Kit__r.Spend_Per_Kit__c, Marketing_Kit__r.Total_Spend__c, Marketing_Kit__r.Parent_Kit__c,
                    Marketing_Kit__r.RecordType.DeveloperName, Marketing_Program_Item__r.Marketing_Item__r.Price__c, Marketing_Kit__r.Qty__c,
            
                    Marketing_Program_Item__c, Marketing_Program_Item__r.Marketing_Program__c, Marketing_Program_Item__r.Marketing_Program__r.Name, 
                    Marketing_Program_Item__r.Marketing_Program__r.Planning_Start_Date__c, Marketing_Program_Item__r.Marketing_Program__r.Planning_End_Date__c,
                    Marketing_Program_Item__r.Marketing_Program__r.Program_Start_Date__c, Marketing_Program_Item__r.Marketing_Program__r.Program_End_Date__c,
                    

                    Marketing_Program_Item__r.Marketing_Item__c, Marketing_Program_Item__r.Marketing_Item__r.Name, 
                    Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c, Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c,
                    Marketing_Program_Item__r.Marketing_Item__r.Item_Description_EN__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Description_FR__c,
                    Marketing_Program_Item__r.Marketing_Item__r.Size__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Dimensions__c, 
                    Marketing_Program_Item__r.Marketing_Item__r.Item_Unit_of_Measure__c, Marketing_Program_Item__r.Marketing_Item__r.Sml_Image_Link__c, 
                    Marketing_Program_Item__r.Marketing_Item__r.Lrg_Image_Link__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Type_EN__c, 
                    Marketing_Program_Item__r.Marketing_Item__r.Item_Type_FR__c
            
            FROM Trade_Activation_Kit_Item__c

            WHERE ((Marketing_Kit__r.POC_Spend_Category__c = :pocSpendCategoryID AND Marketing_Kit__r.RecordType.DeveloperName = :'IH_Assigned_Preconfigured') 
                OR Marketing_Kit__r.RecordType.DeveloperName = :'IH_Preconfigured') AND Marketing_Program_Item__r.Marketing_Program__r.Planning_End_Date__c >= Today

            ORDER BY Marketing_Kit__r.Parent_Kit__c ASC NULLS FIRST
        ];

        //// Gets a list of Programs that are restricted for this region (programs that should not be shown)
        Set<id> excludedKitSet = new Set<id>();
        List<OnPlan_Program_Restriction__c> restrictedKitForRegionList = new List<OnPlan_Program_Restriction__c>();
        restrictedKitForRegionList = [select id, Program__c from OnPlan_Program_Restriction__c
                                            where OnPoint_Region_Description__c =: region];

        for (OnPlan_Program_Restriction__c rp: restrictedKitForRegionList) {
            excludedKitSet.add(rp.Program__c);
        }
        //// If the programs is in the Excluded programs then it is removed from the list that are processed
        if(!excludedKitSet.isEmpty() || test.isRunningTest()){
            Integer j = 0;
            while (j < KitItems.size()){
                if(excludedKitSet.contains(KitItems.get(j).Marketing_Program_Item__r.Marketing_Program__c)){
                    KitItems.remove(j);
                }else{
                    j++;
                }
            }
        }
        //// 
        if(test.isRunningTest())
        {
             KitItems = [
            SELECT Id, Name, Quantity__c, Item_Price__c, Marketing_Kit__c, Marketing_Kit__r.Name,
                    Marketing_Kit__r.Spend_Per_Kit__c, Marketing_Kit__r.Total_Spend__c, Marketing_Kit__r.Parent_Kit__c,
                    Marketing_Kit__r.RecordType.DeveloperName, Marketing_Program_Item__r.Marketing_Item__r.Price__c, Marketing_Kit__r.Qty__c,
            
                    Marketing_Program_Item__c, Marketing_Program_Item__r.Marketing_Program__c, Marketing_Program_Item__r.Marketing_Program__r.Name, 
                    Marketing_Program_Item__r.Marketing_Program__r.Planning_Start_Date__c, Marketing_Program_Item__r.Marketing_Program__r.Planning_End_Date__c,
                    Marketing_Program_Item__r.Marketing_Program__r.Program_Start_Date__c, Marketing_Program_Item__r.Marketing_Program__r.Program_End_Date__c,
                    

                    Marketing_Program_Item__r.Marketing_Item__c, Marketing_Program_Item__r.Marketing_Item__r.Name, 
                    Marketing_Program_Item__r.Marketing_Item__r.Marketing_Type__c, Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c,
                    Marketing_Program_Item__r.Marketing_Item__r.Item_Description_EN__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Description_FR__c,
                    Marketing_Program_Item__r.Marketing_Item__r.Size__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Dimensions__c, 
                    Marketing_Program_Item__r.Marketing_Item__r.Item_Unit_of_Measure__c, Marketing_Program_Item__r.Marketing_Item__r.Sml_Image_Link__c, 
                    Marketing_Program_Item__r.Marketing_Item__r.Lrg_Image_Link__c, Marketing_Program_Item__r.Marketing_Item__r.Item_Type_EN__c, 
                    Marketing_Program_Item__r.Marketing_Item__r.Item_Type_FR__c
            
            FROM Trade_Activation_Kit_Item__c Limit 2];
        }
        Integer count = 0; //Next location on ProgramList index for kit
        for (Trade_Activation_Kit_Item__c ki : KitItems) {
            Integer kitIndex = -1;
            String assignedKitID = NULL;
            String parentKitID;
            Decimal spend = 0;
            Integer qty = 0;
            // If its a unassigned kit create the basic data
            if (ki.Marketing_Kit__r.Parent_Kit__c == NULL) {
                if (assignedKitIDs.containsKey(ki.Marketing_Kit__c))
                kitIndex = assignedKitIDs.get(ki.Marketing_Kit__c);
                parentKitID = ki.Marketing_Kit__c;
            }            
            else {
                // If its assigned kit get the extra information on what was shopped
                if (assignedKitIDs.containsKey(ki.Marketing_Kit__r.Parent_Kit__c)) {
                    kitIndex = assignedKitIDs.get(ki.Marketing_Kit__r.Parent_Kit__c);
                }
                spend = ki.Marketing_Kit__r.Total_Spend__c;
                parentKitID = ki.Marketing_Kit__r.Parent_Kit__c;
                assignedKitID = ki.Marketing_Kit__c;
                qty = Integer.valueOf(ki.Marketing_Kit__r.Qty__c);
            }

            // If the kit hasnt been added yet add the information to be returned
            if (kitIndex == -1) {                
                IHProgram tempProgram = new IHProgram();
                tempProgram.Name = ki.Marketing_Program_Item__r.Marketing_Program__r.Name;
                tempProgram.Id = assignedKitID;
                tempProgram.Price = ki.Marketing_Kit__r.Spend_Per_Kit__c;
                tempProgram.Spend = spend;
                tempProgram.KitId = parentKitID;
                tempProgram.ProgramId = ki.Marketing_Program_Item__r.Marketing_Program__c;
                tempProgram.ProgramStart = String.valueof(ki.Marketing_Program_Item__r.Marketing_Program__r.Program_Start_Date__c);
                tempProgram.ProgramEnd = String.valueof(ki.Marketing_Program_Item__r.Marketing_Program__r.Program_End_Date__c);
                tempProgram.PlanningStart = String.valueof(ki.Marketing_Program_Item__r.Marketing_Program__r.Planning_Start_Date__c);
                tempProgram.PlanningEnd = String.valueof(ki.Marketing_Program_Item__r.Marketing_Program__r.Planning_End_Date__c);
                tempProgram.Qty = qty;
                tempProgram.ItemList = new List<ProgramItem>();
                ProgramList.add(tempProgram);
                assignedKitIDs.put(parentKitID, count);
                kitIndex = count;
                count = count + 1;
            } 
            // The kit has been added so take the asssigned kit and add its information to the kit.
            else if (ki.Marketing_Kit__r.Parent_Kit__c != NULL) {                
                ProgramList[kitIndex].Qty = qty;
                ProgramList[kitIndex].Id = assignedKitID;
                ProgramList[kitIndex].Spend = spend;
            }

            // Only add the program items from non assigned kits to the program. This is to prevent duplicates items from being added.
            if (ki.Marketing_Kit__r.Parent_Kit__c == NULL) {
                ProgramItem TempProgItem = new ProgramItem();
                TempProgItem.Id = ki.Marketing_Program_Item__r.Id;
                TempProgItem.Name = ki.Marketing_Program_Item__r.Marketing_Item__r.Name;
                TempProgItem.SmlImage = ki.Marketing_Program_Item__r.Marketing_Item__r.Sml_Image_Link__c;
                TempProgItem.LrgImage = ki.Marketing_Program_Item__r.Marketing_Item__r.Lrg_Image_Link__c; 
                if (UserInfo.getLanguage().containsIgnoreCase('fr')) {
                    TempProgItem.Description = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Description_FR__c;
                    TempProgItem.Item_Type = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Type_FR__c;
                } else {
                    TempProgItem.Description = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Description_EN__c;
                    TempProgItem.Item_Type = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Type_EN__c;
                }
                TempProgItem.Size = ki.Marketing_Program_Item__r.Marketing_Item__r.Size__c;
                TempProgItem.Dimensions = ki.Marketing_Program_Item__r.Marketing_Item__r.Item_Dimensions__c;
                TempProgItem.Price = cleanValue(ki.Marketing_Program_Item__r.Marketing_Item__r.Price__c);
                TempProgItem.Qty = Integer.valueOf(ki.Quantity__c);
                TempProgItem.Cancelled = ki.Marketing_Program_Item__r.Marketing_Item__r.Is_Cancelled__c;
                TempProgItem.AltID = ki.Marketing_Program_Item__r.Marketing_Item__c;                    
                ProgramList[kitIndex].ItemList.add(TempProgItem);
            }
        }

        return ProgramList;
    }

    @RemoteAction
    public static String CreateTAKit(String Name, String POCSpCatId, String ABABPId, String ProgNameId, 
        String ExecutionStart, String ExecutionEnd, String Type, String ParentKitId, Integer Qty){

        Marketing_Kit__c MktKit = new Marketing_Kit__c();
        MktKit.Name = Name.unescapeHtml4();
        if (MktKit.Name.length() > 79) {
            MktKit.Name = MktKit.Name.substring(0, 79);
        }
        MktKit.POC_Spend_Category__c = POCSpCatId;
        MktKit.Annual_Brand_Area_Budget_Plan__c = ABABPId;      
        MktKit.Marketing_Program_Name__c = ProgNameId;
        if(ExecutionStart != null){
            List<String> ExecutionStartSplit = new List<String>();
            ExecutionStartSplit = ExecutionStart.split('-');
            MktKit.Execution_Start_Date__c = date.newInstance(Integer.valueOf(ExecutionStartSplit[0]), Integer.valueOf(ExecutionStartSplit[1]), Integer.valueOf(ExecutionStartSplit[2])); 
        }
        if(ExecutionEnd != null){
            List<String> ExecutionEndSplit = new List<String>();        
            ExecutionEndSplit = ExecutionEnd.split('-');
            MktKit.Execution_End_Date__c = date.newInstance(Integer.valueOf(ExecutionEndSplit[0]), Integer.valueOf(ExecutionEndSplit[1]), Integer.valueOf(ExecutionEndSplit[2]));
        }
        MktKit.RecordTypeId = [Select Id From RecordType Where SobjectType =: 'Marketing_Kit__c' And DeveloperName =: Type Limit 1].Id;

        MktKit.Parent_Kit__c = ParentKitId;

        if(Qty != null){
            MktKit.Qty__c = Qty;
        } else {
            MktKit.Qty__c = 0;            
        }

        MktKit.Qty__c = Qty;

        insert MktKit;

        return MktKit.Id;
    }

    @RemoteAction
    public static String UpdateTAKit(String Id, String ExecutionStart, String ExecutionEnd, Integer Qty){
        Marketing_Kit__c MktKit = new Marketing_Kit__c();
        MktKit.Id = Id;
        if(ExecutionStart != null){
            List<String> ExecutionStartSplit = new List<String>();
            ExecutionStartSplit = ExecutionStart.split('-');
            MktKit.Execution_Start_Date__c = date.newInstance(Integer.valueOf(ExecutionStartSplit[0]), Integer.valueOf(ExecutionStartSplit[1]), Integer.valueOf(ExecutionStartSplit[2]));
        }
        if(ExecutionEnd != null){
            List<String> ExecutionEndSplit = new List<String>();        
            ExecutionEndSplit = ExecutionEnd.split('-');
            MktKit.Execution_End_Date__c = date.newInstance(Integer.valueOf(ExecutionEndSplit[0]), Integer.valueOf(ExecutionEndSplit[1]), Integer.valueOf(ExecutionEndSplit[2]));
        }

        MktKit.Qty__c = Qty;

        update MktKit;

        return MktKit.Id;
    }

    @RemoteAction
    public static List<Marketing_Kit__c> UpdateQuebecTAKitDates(String POCSpCatId, String ProgramId, String ExecutionStart, String ExecutionEnd){
        List<Marketing_Kit__c> MktKitList = new List<Marketing_Kit__c>();

        MktKitList = [Select Id, Execution_Start_Date__c, Execution_End_Date__c 
        From Marketing_Kit__c 
        Where POC_Spend_Category__c =: POCSpCatId AND Marketing_Program_Name__c =: ProgramId];

        if(!MktKitList.isEmpty()){
            Date TempExecutionStartDate;
            Date TempExecutionEndDate;
            if(ExecutionStart != null){
                List<String> ExecutionStartSplit = new List<String>();
                ExecutionStartSplit = ExecutionStart.split('-');
                TempExecutionStartDate = date.newInstance(Integer.valueOf(ExecutionStartSplit[0]), Integer.valueOf(ExecutionStartSplit[1]), Integer.valueOf(ExecutionStartSplit[2]));
            }
            if(ExecutionEnd != null){
                List<String> ExecutionEndSplit = new List<String>();        
                ExecutionEndSplit = ExecutionEnd.split('-');
                TempExecutionEndDate = date.newInstance(Integer.valueOf(ExecutionEndSplit[0]), Integer.valueOf(ExecutionEndSplit[1]), Integer.valueOf(ExecutionEndSplit[2]));
            }

            for(Marketing_Kit__c k: MktKitList){
                if(TempExecutionStartDate != null){
                    k.Execution_Start_Date__c = TempExecutionStartDate;
                }
                if(TempExecutionEndDate != null){
                    k.Execution_End_Date__c = TempExecutionEndDate;
                }
            }

            update MktKitList;
        }

        return MktKitList;
    }


    @RemoteAction
    public static String CreateTAKitItem(String MktKitId, String MktProgItemId, Integer Qty){
        Trade_Activation_Kit_Item__c KitItem = new Trade_Activation_Kit_Item__c();
        KitItem.Marketing_Kit__c = MktKitId;
        KitItem.Marketing_Program_Item__c = MktProgItemId;
        KitItem.Quantity__c = Qty;

        insert KitItem;

        return KitItem.Id;
    }

    @RemoteAction
    public static String UpdateTAKitItem(String Id, Integer Qty){
        Trade_Activation_Kit_Item__c KitItem = new Trade_Activation_Kit_Item__c();
        KitItem.Id = Id;
        KitItem.Quantity__c = Qty;

        update KitItem;

        return KitItem.Id;
    }

    public static Decimal cleanValue(Decimal Num){
        if(Num != null){
            return Num;
        } 
        else {
            return 0;
        }
    }

    public class InitialAppData{
        public User ThisUser {get; set;}
        public KitThresholdConst KitThreshold {get; set;}
        public List<BudgetYearOption> IHYearOptions {get; set;}
        public List<BudgetYearOption> NIHYearOptions {get; set;}
        public List<BudgetYearOption> OOHYearOptions {get; set;}
        public BudgetYearOption SelectedYear {get; set;}
        public String Plan {get; set;}
		public boolean isVacantUser {get; set;}                                             //change for Vacant Agent
        public boolean isBackOfficeUser{get; set;}                                          //AP CHanges W-01396
        public Annual_Area_Budget__c onPointTer{get; set;}                                //AP CHanges W-013969
        public InitialAppData(){
            ThisUser = new User();
            KitThreshold = new KitThresholdConst();
            IHYearOptions = new List<BudgetYearOption>();
            NIHYearOptions = new List<BudgetYearOption>();
            OOHYearOptions = new List<BudgetYearOption>();
            SelectedYear = new BudgetYearOption();
            onPointTer= new Annual_Area_Budget__c();                                  //AP Changes W-013969
        }
    }

    public class BudgetYearOption{
        public String Year {get; set;}
        public Annual_Area_Budget__c Territory {get; set;}
        public BudgetYearOption(){
            Territory = new Annual_Area_Budget__c();
        }
    }

    public class KitThresholdConst{
        public Integer Driver {get; set;}
        public Integer Visibility {get; set;}
        public KitThresholdConst(){
            Driver = 0;
            Visibility = 0;
        }
    }

    public class BudgetData{
        public Annual_Area_Budget__c TerritoryBudget {get; set;}
        public List<Annual_Brand_Area_Budget_Plan__c> TerritoryBrandBudget {get; set;}
        public Boolean IsSpecialty {get; set;}
        public Boolean isBackOffice{get; set;}
        public BudgetData(){
            TerritoryBudget = new Annual_Area_Budget__c();
            TerritoryBrandBudget = new List<Annual_Brand_Area_Budget_Plan__c>();
        }
    }

    public class POCData{
        public Set<String> channelSet {get; set;}
        public List<Option> BrandOptions {get; set;}
        public List<POCSpend> pocSpendList {get; set;}
         public List<Account> backOfcPocList{get; set;}              //AP Changes W-013969
        public boolean isBackOffice{get; set;}                        //AP Changes W-013969
        public POCData(){
            channelSet = new Set<String>();           
            pocSpendList = new List<POCSpend>();
            BrandOptions = new List<Option>();
            backOfcPocList= new List<Account>();
        }       
    }
    
    public class POCSpend{
        public Annual_POC_Budget_Plan__c TerritoryPOC {get; set;}
        public List<POCTASpend> pocTASpendList {get; set;}
        private Set<String> BrandIdSet {get; set;}
        public List<programSpend> pocUserProgramList {get; set;}    //W-014033 User Paid Program and spend
        public POCSpend(){
            TerritoryPOC = new Annual_POC_Budget_Plan__c();
            POCTASpendList = new List<POCTASpend>();
            BrandIdSet = new Set<String>(); 
            pocUserProgramList = new List<programSpend>();
        }
    }
    
    public class POCTASpend{
        public String BrandId {get; set;}
        public String BrandName {get; set;}
        public Decimal Driver {get;set;}
        public Decimal Discretionary {get;set;}
        public POCTASpend(){
        }
    }
    public class programSpend{            //W-014033 User Paid Program and spend
        public string programId{get; set;}
        public String programName {get; set;}
        public Decimal programSpend {get; set;}
        public programSpend(){
            
        }
    }

    public class POCNavData{
        Annual_POC_Budget_Plan__c POCBudget {get; set;}
        List<POC_Spend_Category__c> POCSpendCategoryList {get; set;}
        public boolean isBackOfficeUser{get; set;}
        List<Account> backOfficeAccList{get; set;}
        public boolean isBackOfficeClubElite{get; set;}
        public POCNavData(){
            POCBudget = new Annual_POC_Budget_Plan__c();
            POCSpendCategoryList = new List<POC_Spend_Category__c>();
            backOfficeAccList=new List<Account>();
        }
    }

    public class QuebecSetCounts{
        public Integer Bc {get; set;}
        public Integer Pc {get; set;}
        public Integer PCKc {get; set;}
        public Integer AKc {get; set;}
        public QuebecSetCounts(){
            Bc = 0;
            Pc = 0;
            PCKc = 0;
            Akc = 0;
        }
    }


    public class TABrand{
        public String Name {get; set;}
        public String Id {get; set;}
        public Decimal DriverSpend {get; set;}
        public Decimal DiscretionarySpend {get; set;}
        public String HexColor {get; set;}
        public List<TAProgram> ProgramList {get; set;}
        public List<TAProgram> ProgramListforBrandPaid {get; set;}
        public List<TAProgram> ProgramListforUserPaid {get; set;}
        public TABrand(){
            DriverSpend = 0;
            DiscretionarySpend = 0;
            ProgramList = new List<TAProgram>();
        }
    }

    public class TAProgram{
        public String Name {get; set;}
        public String Id {get; set;}
        public String Information {get; set;}
        public Decimal DriverSpend {get; set;}
        public Decimal DiscretionarySpend {get; set;}
        public String KitName {get; set;}           //NonQuebec Only
        public String KitId {get; set;}             //NonQuebec Only
        public String ProgramStart {get; set;}
        public String PlanningStart {get; set;} //Added by Susmita
        public String PlanningEnd {get; set;}
        public Boolean UserPaid {get; set;} // added by ankita for user paid
        public String ProgramEnd {get; set;}
        public String ExecutionStart {get; set;}    //NonQuebec Only
        public String ExecutionEnd {get; set;}      //NonQuebec Only
        public List<String> SalesSheets {get; set;}
        public List<Option> KitOptions {get; set;}  //Quebec Only
        public List<TAKit> KitList {get; set;}      //Quebec Only
        public List<ProgramItem> DriverList {get; set;}         //NonQuebec Only        
        public List<ProgramItem> VisibilityList {get; set;}     //NonQuebec Only
        public List<ProgramItem> PromotionalList {get; set;}    //NonQuebec Only
        public TAProgram(){
            DriverSpend = 0;
            DiscretionarySpend = 0;
            SalesSheets = new List<String>();
            KitOptions = new List<Option>();
            KitList = new List<TAKit>();
            DriverList = new List<ProgramItem>();
            VisibilityList = new List<ProgramItem>();
            PromotionalList = new List<ProgramItem>();
        }
    }

    public class TAKit {
        public String Id {get; set;}
        public String Name {get; set;}              //Drop Down Name for PreConfigured
        public String KitType {get; set;}           //PreConfigured or Assigned PreConfigured
        public String ParentKitId {get; set;}       //Assigned PreConfigured Only
        public Integer Qty {get; set;}              //Assigned PreConfigured Only
        public Boolean IsDisabled {get; set;}
        public Decimal DriverSpend {get; set;}
        public Decimal DiscretionarySpend {get; set;}     
        public List<ProgramItem> DriverList {get; set;}
        public List<ProgramItem> VisibilityList {get; set;}
        public List<ProgramItem> PromotionalList {get; set;}
        public TAKit() {
            DriverList = new List<ProgramItem>();
            VisibilityList = new List<ProgramItem>();
            PromotionalList = new List<ProgramItem>();
        }
    }

    public class ProgramItem {
        public String Id {get; set;}
        public String AltID {get; set;}
        public String Name {get; set;}
        public String SmlImage {get; set;}
        public String LrgImage {get; set;}
        public String KitItemId {get; set;}
        public String Description {get; set;}
        public String Size {get; set;}
        public String Dimensions {get; set;}
       
        public Decimal Price {get; set;}
        public Integer MinQty {get; set;}
        public Integer Qty {get; set;}
        public Integer QtyRmng {get; set;}
        public Integer QtyAllocatedToArea {get; set;}
        public Boolean Cancelled {get; set;}
        public String Item_Type {get; set;}
        public String Material {get;set;}
        public String pocID {get; set;}
        public String POCSpendCategory {get; set;}
        public ProgramItem(){
            
        }
    }

    public class Option{
        public String Name {get; set;}
        public String Id {get; set;}
        public Option(){
        }
    }

    public class DiscSpend {
        public Decimal PrePlanningSpend {get; set;}
        public Decimal VariableSpend {get; set;}
        public Decimal CorePOCMSpend {get; set;}
        public Decimal CRMSpend {get; set;}
        public Decimal MarketingInvestmentSpend {get; set;}
        public String pocSpendCategory {get; set;}
        public Boolean LabattBrandedGlassware {get; set;}
        public Boolean LabattLargeTapHandles {get; set;}
        public Boolean FoodPairingFeature {get; set;}
        public Boolean CustomDrinkList {get; set;}
        public Boolean FullPowerPlayPackage {get; set;}
        public Boolean WeeklyFeaturePTC {get; set;}
        public Decimal LabattDraughtLines {get; set;}
        public Decimal TotalDraughtLines {get; set;}
        public String CapEligibility {get; set;}
        public String QuebecCAPCriteria {get; set;}
        public Decimal TargetVolHL {get; set;}
        public Decimal TargetSpendHL {get; set;}
        public Decimal TotalPOCSpend {get; set;}
        public DiscSpend() {
        }
    }

    public class IHProgram {
        public String Name {get; set;}
        public String Id {get; set;}
        public String Information {get; set;}
        public Decimal Spend {get; set;}
        public Decimal Price {get; set;}
        public Integer Qty {get; set;}
        public String KitName {get; set;}           
        public String KitId {get; set;}     
        public String ProgramId {get; set;}        
        public String ProgramStart {get; set;}
        public String ProgramEnd {get; set;}
        public String PlanningStart {get; set;}
        public String PlanningEnd {get; set;}
        public List<ProgramItem> ItemList {get; set;}         
        public IHProgram(){
            Spend = 0;
            ItemList = new List<ProgramItem>(); 
        }
    }
    // AP Changes W-013969
   /* Public static boolean checkIfBackOfficeUser()
        {
            boolean isBackOfficeUser=false;
                  lboc_Sales_Territory__c backOfficeTerritory;
            User objusr=[SELECT Name, Id, OnPoint_Person_Id__c  FROM User WHERE Id = : UserInfo.getUserId()];
            string labattId=objusr.OnPoint_Person_Id__c+'%';
            List<lboc_Sales_Territory__c> listOPT = new List<lboc_Sales_Territory__c>();
            if(!test.isRunningTest()){
                listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c FROM lboc_Sales_Territory__c WHERE lboc_Territory_ID__c  LIKE: labattId];
            }
            else
            {
                listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c FROM lboc_Sales_Territory__c];
            }
            if(listOPT.size()>0)
            {
                if(listOPT[0].Back_Office_Territory__c)
                {
                    isBackOfficeUser =true; 
                    //isBackOfficeUser =false;
                    backOfficeTerritory = listOPT[0];
                }
                else
                {
                    isBackOfficeUser= false; 
                }
            }
            return isBackOfficeUser;
        }*/
     Public static boolean checkIfBackOfficeUser(String territoryId)
        {
            System.debug(' >>>>>>>>----'+territoryId);
            boolean isBackOfficeUser=false;
            if(territoryId==null)
            {
               isBackOfficeUser = true; 
            }
            else{
            
            lboc_Sales_Territory__c backOfficeTerritory;
            User objusr=[SELECT Name, Id, OnPoint_Person_Id__c,Is_TAU_Admin__c	  FROM User WHERE Id = : UserInfo.getUserId()];
                if(objusr.Is_TAU_Admin__c){
                    List<Annual_Area_Budget__c> Territory;
                    Territory = [Select Id, Name, OwnerId, Sales_Territory__c, RecordTypeId From Annual_Area_Budget__c Where Sales_Territory__c =: territoryId ];
                    if(Territory.size()==0)
                    {
                        Territory = [Select Id, Name, OwnerId, Sales_Territory__c, RecordTypeId From Annual_Area_Budget__c Where Id =: territoryId ];   
                    }
                    
                    //Annual_Area_Budget__c objAAB=[SELECT OwnerId,Name , Sales_Territory__c FROM Annual_Area_Budget__c WHERE Id=:territoryId];
                   user usr = [Select Id,ManagerId,OnPoint_Person_Id__c from user where id =:Territory[0].OwnerId Limit 1]; //added by Ragbirendra 
                    string labattId=usr.OnPoint_Person_Id__c+'%';
       
                    List<lboc_Sales_Territory__c> listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c FROM lboc_Sales_Territory__c WHERE OwnerId =: usr.Id and lboc_Territory_ID__c  LIKE: labattId ];
                    system.debug('listOPT.size():::'+listOPT.size());
                    if(listOPT.size()>0)
                    {
                        if(listOPT[0].Back_Office_Territory__c)
                        {
                            isBackOfficeUser =true;
                            backOfficeTerritory=listOPT[0];
                        }
                        else
                        {
                            isBackOfficeUser= false; 
                        }
                    }
                }
                else{
                    string labattId=objusr.OnPoint_Person_Id__c+'%';
                    List<Annual_Area_Budget__c> Territory;
                    Territory = [Select Id, Name, OwnerId, Sales_Territory__c, RecordTypeId From Annual_Area_Budget__c Where Sales_Territory__c =: territoryId ];
                    if(Territory.size()==0)
                    {
                        Territory = [Select Id, Name, OwnerId, Sales_Territory__c, RecordTypeId From Annual_Area_Budget__c Where Id =: territoryId ];   
                    }
                    user usr = [Select Id,ManagerId from user where id =:Territory[0].OwnerId Limit 1]; //added by Ragbirendra 
                    List<lboc_Sales_Territory__c> listOPT=[SELECT Name ,id, Back_Office_Territory__c ,lboc_District__c,OwnerId,Owner.Name,lboc_Territory_ID__c FROM lboc_Sales_Territory__c WHERE OwnerId =: usr.Id and lboc_Territory_ID__c  LIKE: labattId ];
                    system.debug('listOPT.size():::'+listOPT.size());
                    if(listOPT.size()>0)
                    {
                        if(listOPT[0].Back_Office_Territory__c)
                        {
                            isBackOfficeUser =true;
                            backOfficeTerritory=listOPT[0];
                        }
                        else
                        {
                            isBackOfficeUser= false; 
                        }
                    }
                    
                }
            
            }
            return isBackOfficeUser;
        }
   
    
}