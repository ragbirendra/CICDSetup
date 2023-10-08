/***
* @Name - ProgramBrandItemControllerTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description - This test class Created for testing methods of ProgramBrandItemController class
* 

***/

@isTest
public class ProgramBrandItemControllerTest {
    
    @testSetup static void setup()
    {
          
        Program_Brands_Item__c obj =new Program_Brands_Item__c();
        obj.Brand_Name__c='Corona';
        obj.Program_Name__c= 'Always On';
        obj.Status_of_Approval__c = 'Approved';
        obj.Business_Line__c='Out Of Home';
        obj.Is_Available__c=true;
        obj.Product_Name__c='Corona Jacket';
        obj.Year__c='2020';
        insert obj;
        
    }
    
    static testmethod void setup1()
    {
                
        Test.startTest();
        
        List<string> lstProgramData =ProgramBrandItemController.getStatusData();
        System.assertEquals('Approved', lstProgramData[0]);
        
        List<string> lstProgramData1 =ProgramBrandItemController.getBusinessLineData();
        System.assertEquals('Out Of Home', lstProgramData1[0]);
        
        List<string> lstProgramData2 = ProgramBrandItemController.getProgramData('corona');
        System.assertEquals('Always On', lstProgramData2[0]);
        
         List<ProgramBrandItemController.itemWrapper> lstitemWrapper=ProgramBrandItemController.getData('Always On','2020','Approved','Out Of Home');
         System.assertEquals('Corona',lstitemWrapper[0].BrandName);
        
         Test.stopTest();
    }

}