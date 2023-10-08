@isTest
public class UpdateAreaBudgetStatusSchedularTest {

    static testmethod void schedulerTest() {
        String CRON_EXP = '0 0 9 * * ? *';
        
       // Datetime todayDatetime =Datetime.now();
       // boolean flag = true;
        	Test.startTest();
			UpdateAreaBudgetStatusSchedular sh1=new UpdateAreaBudgetStatusSchedular();
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, sh1);
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }

}