/***
* @Name - JSON2ApexPBItemsTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description - This test class Created for testing methods of JSON2ApexPBItems class
* 

***/

@isTest
Public class JSON2ApexPBItemsTest{
  
    static testmethod void runTest(){ 
     
    JSON2ApexPBItems jsn = new JSON2ApexPBItems();
    jsn.BrandName = 'test';
    jsn.varCurrency = 'test';
    jsn.ProgramName = 'test';
    jsn.ProgramDescription = 'test';
    jsn.BusinessLine = '1234567';
    jsn.SAPItemNumber = '1234567';
    jsn.MenuCategory = '2';
    jsn.ItemDescriptionFR = 'abc';  
    List<JSON2ApexPBItems> jsnlst = new List<JSON2ApexPBItems>();
    jsnlst.add(jsn);
    
        
    Test.startTest();       
        
    List<JSON2ApexPBItems> lst=JSON2ApexPBItems.parse('[{ "Quebec":"true","Atlantic":"true","Ontario":"true","West":"true"}]');
        
    Test.stopTest();
    

    
   }
}