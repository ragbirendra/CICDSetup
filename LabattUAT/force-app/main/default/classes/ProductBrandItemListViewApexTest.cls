/***
* @Name - ProductBrandItemListViewApexTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description - This test class Created for testing methods of ProductBrandItemListViewApex class
* 

***/
@isTest
public class ProductBrandItemListViewApexTest {
    
    static testmethod void setup()
    {
                          
            List<JSON2ApexPBItems> obj=new List<JSON2ApexPBItems>();
                        
            Program_Brands_Item__c shpkt = new Program_Brands_Item__c();
            shpkt.Program_Name__c='All';
            shpkt.User_Paid__c=false;
            shpkt.Brand_Name__c = 'Test';
            shpkt.Item_Description_FR__c = 'test';
            shpkt.Status_of_Approval__c = 'Submitted for Approval';
            shpkt.Planning_Start_Date__c = '2019-11-01';
            shpkt.Planning_End_Date__c = '2019-11-05';
            shpkt.Unit_of_Measure__c = 'test';
            shpkt.Product_Name__c = 'test';
            shpkt.SAP_Item_Number__c = '10';
            shpkt.Quantity_per_UOM__c = 5;
            shpkt.Ontario__c=true;
            
            insert shpkt;
           // list<ProductBrandItemListViewApex.picklistValWrapper> oListViewWrapper = new list<ProductBrandItemListViewApex.picklistValWrapper>();   
            
            List<Id> shpktid = new List<Id>();
            shpktid.add(shpkt.Id);
                                
        
        ID profileID = [Select ID from Profile where name = 'System Administrator' limit 1].ID;
        
        User userObj=new User();
        userObj.profileid=profileID;
        userObj.Username='testuser@testing99999.com';
        userObj.LastName='testing';
        userObj.Email='testuser@testing99999.com';
        userObj.Alias='test999';
        userObj.CommunityNickname='testingOnly';
        userObj.TimeZoneSidKey='Asia/Kolkata';
        userObj.EmailEncodingKey='ISO-8859-1';
        userObj.LocaleSidKey='fr_BE';
        userObj.LanguageLocaleKey='en_US';
        userObj.is_TAU_Admin__c=true;
        userObj.is_TAU_User__c=false;
        insert userObj;
        
        System.runAs(userObj){
            Test.startTest();
            
            List<ProductBrandItemListViewApex.picklistValWrapper> plistv = ProductBrandItemListViewApex.getPickListVals();
            System.assertEquals('test', plistv[0].ItemDescriptionFR);
            
            List<ProductBrandItemListViewApex.picklistValWrapper> splistv = ProductBrandItemListViewApex.getFilteredvals('Always On','Approved','In Home','2020');                     
            List<ProductBrandItemListViewApex.picklistValWrapper> splistv1 = ProductBrandItemListViewApex.getFilteredvals('Always On','Approved','In Home','2020');
            List<ProductBrandItemListViewApex.picklistValWrapper> splistv2 = ProductBrandItemListViewApex.getFilteredvals('Always On','Approved','In Home','2020');  
            List<ProductBrandItemListViewApex.picklistValWrapper> splistv3 = ProductBrandItemListViewApex.getFilteredvals('Always On','Approved','In Home','2020');
            
            user u = ProductBrandItemListViewApex.FetchUserInfo();        
            List<ProductBrandItemListViewApex.listViewWrapper> listv = ProductBrandItemListViewApex.listValues('Account');
            ProductBrandItemListViewApex.recordsApproval('All','test','test','2020');
            ProductBrandItemListViewApex.recordsRejection('test','test','Loaded','Out of Home','2020');
            ProductBrandItemListViewApex.recordsRejection('test','test','Submitted for Approval','Out of Home','2020');
            ProductBrandItemListViewApex.submitRecordsForApproval('test','Submitted for Approval','Out of Home','2020');
            
              Test.stopTest();
        }
        
   
    }
    static testMethod void myUnitTest2()
    {
        
        ContentVersion cvlist = new Contentversion(); 
        cvlist.Title = 'CZDSTOU'; 
        cvlist.PathOnClient = 'test'; 
        cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        insert cvlist;
        
        string idCV=Id.valueOf(cvlist.Id);
        
        
        Program_Brands_Item__c shpkt = new Program_Brands_Item__c();
        shpkt.Program_Name__c='test';
        shpkt.Brand_Name__c = 'User Paid';
        shpkt.Item_Description_FR__c = 'test';
        shpkt.Status_of_Approval__c = 'Approved';
        shpkt.Planning_Start_Date__c = '2020-05-05';
        shpkt.Planning_End_Date__c = '2020-05-05';
        shpkt.Unit_of_Measure__c = 'test';
        shpkt.Product_Name__c = 'test';
        shpkt.SAP_Item_Number__c = '10';
        shpkt.Quantity_per_UOM__c = 5;
        shpkt.Program_Start_Date__c='2020-05-05';
        shpkt.Program_End_Date__c='2020-05-05';
        shpkt.SAP_Item_Number__c='7522028';
        shpkt.Image_Link__c='/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=null'; 
        shpkt.Year__c='2019';
        shpkt.Business_Line__c='Out of Home';
        shpkt.User_Paid__c = true;
        shpkt.Atlantic__c = true; 
        shpkt.Ontario__c=true;
        shpkt.West__c=true;
        shpkt.Quebec__c=true;
              
        insert shpkt;

          
        Id brandRecId = [Select Id, Name from RecordType where developername = 'Trade_Activation' limit 1].Id;
        Brand__c b=new Brand__c();
        b.Name='User Paid';
        b.User_Paid__c=true;
        b.RecordTypeId=brandRecId;
        insert b;
        
        
        Marketing_Program__c mp=new Marketing_Program__c();
        mp.Brand__c=b.id;
        mp.Business_Line__c='Out of Home';
        
        insert mp;
        
         OnPoint_District__c onpoint1 =new OnPoint_District__c();
         onpoint1.Region_Code__c='20186';
         insert onpoint1;
        
        Marketing_Item__c mi=new Marketing_Item__c();
        mi.Item_Number__c='7522028';
        mi.Brand__c=b.id;
        insert mi;
      
        ABI_OP_District_Codes__c setting = new ABI_OP_District_Codes__c(Name='Atlantic Region Code');
        setting.Region_Code__c = '90041';
        insert setting;
        ABI_OP_District_Codes__c settingO = new ABI_OP_District_Codes__c(Name='Ontario Region Code');
        settingO.Region_Code__c = '20186';
        insert settingO;
        ABI_OP_District_Codes__c settingW = new ABI_OP_District_Codes__c(Name='West Region Code');
        settingW.Region_Code__c = '31685';
        insert settingW;
        ABI_OP_District_Codes__c settingQ = new ABI_OP_District_Codes__c(Name='Quebec Region Code');
        settingQ.Region_Code__c = '1';
        insert settingQ;
        OnPoint_District__c od1 = new OnPoint_District__c();
        od1.Region_Code__c = '90041';
        insert od1;
        OnPoint_District__c od2 = new OnPoint_District__c();
        od2.Region_Code__c = '31685';
        insert od2;
        OnPoint_District__c od3 = new OnPoint_District__c();
        od3.Region_Code__c = '20186';
        insert od3;
        OnPoint_District__c od = new OnPoint_District__c();
        od.Region_Code__c = '1';
        insert od;
        OnPlan_Product_Restriction__c pd = new OnPlan_Product_Restriction__c();
        pd.OnPoint_District__c = od.id;
        pd.Item__c = mi.id;
        insert pd;
        List<Id> shpktlst = new List<Id>();
        shpktlst.add(shpkt.Id);
        system.debug('====MSSS======='+shpktlst);
        Annual_Area_Budget__c aab = new Annual_Area_Budget__c();
        aab.Budget_Year__c = '2019';
        insert aab;
        Test.startTest();
        
        ProductBrandItemListViewApex.PushToOnPlan1(shpktlst);
              
        Test.stopTest();
    }
    
    static testmethod void setupNew()
    {
           
           
            List<JSON2ApexPBItems> obj=new List<JSON2ApexPBItems>();
                     
            Program_Brands_Item__c shpkt = new Program_Brands_Item__c();
            shpkt.Program_Name__c='All';
            shpkt.Brand_Name__c = 'Test';
            shpkt.Item_Description_FR__c = 'test';
            shpkt.Status_of_Approval__c = 'Submitted for Approval';
            shpkt.Planning_Start_Date__c = '2019-11-01';
            shpkt.Planning_End_Date__c = '2019-11-05';
            shpkt.Unit_of_Measure__c = 'test';
            shpkt.Product_Name__c = 'test';
            shpkt.SAP_Item_Number__c = '10';
            shpkt.Quantity_per_UOM__c = 5;
            shpkt.Program_Start_Date__c='2020-05-05';
            shpkt.Program_End_Date__c='2020-05-05';
            shpkt.SAP_Item_Number__c='7522028';            
            shpkt.Year__c='2019';
            shpkt.Business_Line__c='Out of Home';
            shpkt.User_Paid__c = true;
            shpkt.Atlantic__c = true; 
            shpkt.Ontario__c=true;
            
            insert shpkt;
        
           
            list<ProductBrandItemListViewApex.picklistValWrapper> oListViewWrapper = new list<ProductBrandItemListViewApex.picklistValWrapper>();   
            
            List<Id> shpktid = new List<Id>();
            shpktid.add(shpkt.Id);            
                    
        
            ID profileID = [Select ID from Profile where name = 'System Administrator' limit 1].ID;
        
            User userObj=new User();
            userObj.profileid=profileID;
            userObj.Username='testuser@testing99999.com';
            userObj.LastName='testing';
            userObj.Email='testuser@testing99999.com';
            userObj.Alias='test999';
            userObj.CommunityNickname='testingOnly';
            userObj.TimeZoneSidKey='Asia/Kolkata';
            userObj.EmailEncodingKey='ISO-8859-1';
            userObj.LocaleSidKey='fr_BE';
            userObj.LanguageLocaleKey='en_US';
            userObj.is_TAU_Admin__c=false;
            userObj.is_TAU_User__c=true;
            insert userObj;
        
            System.runAs(userObj){
              Test.startTest();
            
              List<ProductBrandItemListViewApex.listViewWrapper> listv = ProductBrandItemListViewApex.listValues('Account');
              ProductBrandItemListViewApex.deleteRecord(shpkt.id);
              List<ProductBrandItemListViewApex.picklistValWrapper> plistv = ProductBrandItemListViewApex.getPickListVals();           
              List<ProductBrandItemListViewApex.picklistValWrapper> splistv = ProductBrandItemListViewApex.getFilteredvals('Always On','Approved','In Home','2020');     
              try {
              ProductBrandItemListViewApex.saveUpdateditemRecords('[{ "Quebec":"true","Atlantic":"true","Ontario":"true","West":"true","IsIHOnly":"true","isUserPaid":"yes","IsProgramOnly":"no"}]','Comment');
              } catch (AuraHandledException e) {
              System.debug(e.getMessage());
              System.debug(e.getTypeName());          
              }
              user u = ProductBrandItemListViewApex.FetchUserInfo();
              ProductBrandItemListViewApex.recordsApproval('All','test','test','2020');
              ProductBrandItemListViewApex.recordsRejection('test','test','Loaded','Out of Home','2020');
              ProductBrandItemListViewApex.recordsRejection('test','test','Submitted for Approval','Out of Home','2020');
              ProductBrandItemListViewApex.submitRecordsForApproval('test','Submitted for Approval','Out of Home','2020');
            
             Test.stopTest();
            }
     
    }   
}