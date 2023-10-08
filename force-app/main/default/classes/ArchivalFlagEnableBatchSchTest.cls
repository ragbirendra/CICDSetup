@isTest
public class ArchivalFlagEnableBatchSchTest {

    static testmethod void schedulerTest() {
        String CRON_EXP = '0 0 9 * * ? *';
        
       // Datetime todayDatetime =Datetime.now();
       // boolean flag = true;
       Test.startTest();
			ArchivalFlagEnableBatchForBudgetSch sh1=new ArchivalFlagEnableBatchForBudgetSch();
            ArchivalFlagEnableBatchForItemSch sh2=new ArchivalFlagEnableBatchForItemSch();
            ArchivalFlagEnableBatchForShoppedKitSch sh3=new ArchivalFlagEnableBatchForShoppedKitSch();
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, sh1);
            String jobId1 = System.schedule('ScheduleApexClassTest1',  CRON_EXP, sh2);
            String jobId2 = System.schedule('ScheduleApexClassTest2',  CRON_EXP, sh3);
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }

}