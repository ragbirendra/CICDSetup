/***
* @Name				ArchivalFlagEnableBatchForShoppedKitSch
* @Author			Ragbirendra Upadhyay
* @CreatedDate		09-19-2019
***/

global class ArchivalFlagEnableBatchForShoppedKitSch implements Schedulable{
 global void execute(SchedulableContext sc) {
       //schedular class for ArchivalFlagEnableBatch 
      ArchivalFlagEnableBatch obj = new ArchivalFlagEnableBatch('NAZ_OP_Shopkit_Data__c'); 
      database.executebatch(obj);
       
   }
}