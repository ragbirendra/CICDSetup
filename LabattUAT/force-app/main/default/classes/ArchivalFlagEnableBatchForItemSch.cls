/***
* @Name				ArchivalFlagEnableBatchForItemSch
* @Author			Ragbirendra Upadhyay
* @CreatedDate		09-19-2019
***/

global class ArchivalFlagEnableBatchForItemSch implements Schedulable{
 global void execute(SchedulableContext sc) {
       //schedular class for ArchivalFlagEnableBatch 
      ArchivalFlagEnableBatch obj = new ArchivalFlagEnableBatch('Program_Brands_Item__c'); 
      database.executebatch(obj);
       
   }
}