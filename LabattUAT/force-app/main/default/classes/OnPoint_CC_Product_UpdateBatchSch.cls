/***
* @Name				OnPoint_CC_Product_UpdateBatchSch
* @Author			Ragbirendra Upadhyay
* @CreatedDate		09-19-2019
***/
global class OnPoint_CC_Product_UpdateBatchSch implements Schedulable{
   
   global void execute(SchedulableContext sc) {
       //schedular class for OnPoint_CC_Product_UpdateBatchSch 
      OnPoint_CC_Product_UpdateBatch obj = new OnPoint_CC_Product_UpdateBatch(); 
      database.executebatch(obj);
       
   }

    
}