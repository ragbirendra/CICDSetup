global class UpdateAreaBudgetStatusSchedular implements Schedulable{
   
   global void execute(SchedulableContext sc) {
       //schedular class for UpdateAreaBudgetStatus 
      UpdateAreaBudgetStatus obj = new UpdateAreaBudgetStatus(); 
      database.executebatch(obj,10);
       
   }

    
}