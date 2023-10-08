@isTest
public class SetPOCPlanningWindowsTest {
    static testMethod void myUnitTest() {
        POC_Planning_Setup_Admin__c testData = new POC_Planning_Setup_Admin__c();
            testData.Budget_Year__c='2020';
            testData.Business_Line__c='OOH';
            testData.Plan_Start_Date__c= datetime.newInstance(2019, 11, 25, 12, 30, 0);
            //testData.Id='a5LS00000003Vw8MAE';
            testData.Plan_End_Date__c=datetime.newInstance(2019, 11, 25, 15, 30, 0);
            testData.Planning_Year__c='2019';
            testData.Type__c='  KI Volume and Discretionary';  
        
        insert testData;
        
        
        
        //SetPOCPlanningWindows objclass = new SetPOCPlanningWindows();
        SetPOCPlanningWindows.fetchPlanningWindows('2019');
        SetPOCPlanningWindows.fetchAllPlanningWindows(testData.Id);
        SetPOCPlanningWindows.changeStringToDate('2019-01-01');
        
        POC_Planning_Setup_Admin__c testData2 = new POC_Planning_Setup_Admin__c();
            testData2.Budget_Year__c='2020';
            testData2.Business_Line__c='OOH';
            testData2.Plan_Start_Date__c= datetime.newInstance(2019, 11, 27, 12, 30, 0);

            testData2.Plan_End_Date__c=datetime.newInstance(2019, 11, 29, 15, 30, 0);
            testData2.Planning_Year__c='2019';
            testData2.Type__c=' KI Volume and Discretionary';     
        
        SetPOCPlanningWindows.definePlanningWindow(testData2);
        
        testData2.Business_Line__c='IH';
        SetPOCPlanningWindows.updatePlanWindows(testData2, '2019');
        SetPOCPlanningWindows.deletePlanWindows(testData.Id, '2020');
        
    }
}