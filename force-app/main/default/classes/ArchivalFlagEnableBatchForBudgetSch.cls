/***
* @Name				ArchivalFlagEnableBatchForBudgetSch
* @Author			Ragbirendra Upadhyay
* @CreatedDate		09-19-2019
***/

global class ArchivalFlagEnableBatchForBudgetSch implements Schedulable{
 global void execute(SchedulableContext sc) {
       //schedular class for ArchivalFlagEnableBatch 
      ArchivalFlagEnableBatch obj = new ArchivalFlagEnableBatch('BudgetLoadUI__c'); 
      database.executebatch(obj);
       
   }
}