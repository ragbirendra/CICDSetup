@isTest
public class Sch_BatchRefreshBOTerritoryAndPocTest {
    static testmethod void schedulerTest() {
        String CRON_EXP = '0 0 9 * * ? *';
        Date todayDate = date.today();
       // Datetime todayDatetime =Datetime.now();
       // boolean flag = true;
       POC_Planning_Setup_Admin__c dataObj = new POC_Planning_Setup_Admin__c();
        dataObj.Type__c='KI Volume and Discretionary';
        dataObj.Budget_Year__c='2020';
        dataObj.Business_Line__c='In Home (IH)';
        dataObj.Plan_End_Date__c=datetime.newInstance(2020, 11, 25, 15, 30, 0);
        dataObj.Plan_Start_Date__c=datetime.newInstance(2020, 11, 25, 12, 30, 0);
        dataObj.Planning_Year__c='2020';
        
        insert dataObj;
        
        Test.startTest();
			Sch_BatchRefreshBOTerritoryAndPoc sh1=new Sch_BatchRefreshBOTerritoryAndPoc();
            //sh1.execute();
           String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, sh1);
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
}