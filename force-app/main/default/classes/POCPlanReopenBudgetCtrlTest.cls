@isTest
public class POCPlanReopenBudgetCtrlTest {
 static testMethod void myUnitTest() {

     RecordType rt = [select id, DeveloperName from RecordType where SobjectType = 'Annual_Area_Budget__c' and DeveloperName = 'New_IH_Territory' Limit 1];
     
     
     lboc_Sales_Territory__c st = new lboc_Sales_Territory__c();
     st.Name = '10119 - NB SAINT JOHN/ST STEPHEN';  
     
     insert st;
     
     Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
     aab.Territory_Code__c = '10119';
     aab.Sales_Territory__c = st.id;
     aab.RecordTypeId = rt.id;
     aab.Approval_Status__c = 'Approved';
     aab.Budget_Year__c = '2020';
     
     insert aab;
     
     Annual_Area_Budget__c aab1=[select id,Owner.FirstName,Owner.LastName from Annual_Area_Budget__c where id=:aab.id];
     POCPlanReopenBudgetCtrl poc=new POCPlanReopenBudgetCtrl();
     POCPlanReopenBudgetCtrl.fetchAnnAreaBudgetRec(aab.Budget_Year__c,aab1.Owner.FirstName,aab1.Owner.LastName);
     POCPlanReopenBudgetCtrl.updateAnnAreaBudget(aab1);
 }

}