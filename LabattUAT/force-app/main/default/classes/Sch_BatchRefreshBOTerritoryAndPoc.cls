global class Sch_BatchRefreshBOTerritoryAndPoc implements Schedulable {
    global void execute(SchedulableContext sc){
        boolean flag = true;
       	//TimeZone tz = UserInfo.getTimeZone();
		//System.debug('Display name: ' + tz.getDisplayName());
		//Datetime dateTimeInGMT=System.now();
		//System.debug('Datetime in GMT TimeZone : '+dateTimeInGMT);		
        
        Datetime todayDatetime =Datetime.now();
        
        List<POC_Planning_Setup_Admin__c> fetchDate= [SELECT Id, Type__c, Budget_Year__c, Plan_Start_Date__c,Planning_Year__c ,Plan_End_Date__c,Business_Line__c
                            FROM POC_Planning_Setup_Admin__c 
                             where Plan_Start_Date__c >= LAST_N_YEARS:6];
        
       
        
        
        system.debug('fetchDate' +fetchDate);
       
        system.debug('todayDatetime' +todayDatetime);
       
        if(fetchDate !=null){
        for(POC_Planning_Setup_Admin__c fd :fetchDate ){
           	 Datetime dt= fd.Plan_Start_Date__c;
            system.debug( 'Value of Start time in GMT '+dt.timeGmt());
             Datetime edt=fd.Plan_End_Date__c;
            system.debug('fd.Planning_Start_Date__c ' +fd.Plan_Start_Date__c );
            system.debug( 'Value of End time in GMT '+edt.timeGmt());
            system.debug('fd.Plan_End_Date__c ' +fd.Plan_End_Date__c );
            system.debug('todayDate >= fd.Planning_Start_Date__c  '  +(todayDatetime >= fd.Plan_Start_Date__c ));
            system.debug(' todayDate <= fd.Planning_End_Date__c '  +(todayDatetime < fd.Plan_End_Date__c));
           	if(todayDatetime >= fd.Plan_Start_Date__c && todayDatetime < fd.Plan_End_Date__c ){
                
                flag = false;
            }
              
        }
        }
       
        system.debug('flag' +flag);
        ABI_OP_BatchRefreshBOTerritoryAndPoc boBatch = new ABI_OP_BatchRefreshBOTerritoryAndPoc(flag);
         database.executeBatch(boBatch);
    }
}