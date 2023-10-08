/***
* @Name - JSON2ApexTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description - This test class Created for testing methods of JSON2Apex class
* 

***/


@isTest
Public class JSON2ApexTest{
    @isTest
    public static void runTest(){ 
           
    JSON2Apex jsn = new JSON2Apex();
    jsn.ShoppedKitName = 'test';
    jsn.ProgramName = 'test';
    jsn.ShopkitStartDate = String.valueof(Date.today());
    jsn.ShopkitEndDate = String.valueof(Date.today().addDays(5));
    jsn.ShopkitSAPNumber = '1234567';
    jsn.ShopkitTemporaryItemNumbers = '1234567';
    jsn.ShopkitQty = '2';
    jsn.ShopkitPrice = '100';
    List<JSON2Apex> jsnlst = new List<JSON2Apex>();
    jsnlst.add(jsn);
        
    Test.startTest();   
        
    List<JSON2Apex> lst=JSON2Apex.parse('[{ "Quebec":"true","Atlantic":"true","Ontario":"true","West":"true"}]');
         
    Test.stopTest();    
  
    
   }
}