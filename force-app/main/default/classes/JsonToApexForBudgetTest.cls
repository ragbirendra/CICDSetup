/***
* @Name - JsonToApexForBudgetTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description - This test class Created for testing methods of JsonToApexForBudget class, JSON2ApexPBItems class and JSON2Apex class
* 

***/

@isTest
public class JsonToApexForBudgetTest {
	
   
    @isTest
    public static void runTest(){ 
               
    Test.startTest();   
        
    List<JsonToApexForBudget> lst=JsonToApexForBudget.parse('[{ "Quebec":"true","Atlantic":"true","Ontario":"true","West":"true"}]');
    List<JSON2ApexPBItems> lst1=JSON2ApexPBItems.parse('[{ "Quebec":"true","Atlantic":"true","Ontario":"true","West":"true"}]');
    List<JSON2Apex> lst2=JSON2Apex.parse('[{ "Quebec":"true","Atlantic":"true","Ontario":"true","West":"true"}]');
        
    Test.stopTest();
    
    
   }
    
}