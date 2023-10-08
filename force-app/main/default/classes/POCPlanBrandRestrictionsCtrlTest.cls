@isTest
public class POCPlanBrandRestrictionsCtrlTest {
 static testMethod void myUnitTest() {
   
      Brand__c b=new Brand__c();
      b.Name='Corona';
      insert b;
     
     POC_Planning_Brand_Restriction__c rb = new POC_Planning_Brand_Restriction__c();
     rb.Budget_Year__c = '2019';
     insert rb;
     
     List<String> lst = new List<String>();
     lst.add('budweiser');
     
     POCPlanBrandRestrictionsCtrl cntrl = new POCPlanBrandRestrictionsCtrl();
     POCPlanBrandRestrictionsCtrl.fetchAllBrandRecords('2019');
     POCPlanBrandRestrictionsCtrl.saveBrandRestrictions(lst,'2019');
     POCPlanBrandRestrictionsCtrl.saveBrandRestrictions(lst,'2020');
     
     
 }

}