/*
Version         : 0.3
Company         : Labatt
Creation Date   : 2017-08-18
Author          : Stephen Scholtz
Description     : Test class for OnPoint_dash_Home 

Helpful links   :
    
History         : 
    2017-10-18 - [Stephen] Revised test class to use new architecture
               - rejigged create users another way instead of using testSetup 
    2017-11-09 - [Stephen] Added user role, as we were having problems in NAZUAT without it 

TODO:
*/
@isTest
private class OnPoint_dash_HomeTest {
    
    @testSetup
    static void setup() {
        Profile platformProfileId = [select id, Name from profile where name='System Administrator'];
        Profile communityProfileId = [select id, Name from profile where name='OnPoint Community User'];

        UserRole r = new UserRole(DeveloperName = 'TestRole', Name = 'Test Role');
        insert r;

        User admin = OnPoint_TestUtil.testUser();
        boolean isTAAdmin = true;
        

        System.runAs(admin) {
            List<OnPoint_District__c> districts = OnPoint_TestUtil.createDistrict(1);
            insert districts;
            List<OnPoint_Territory__c> territory = OnPoint_TestUtil.createTerritory(1, districts[0].Id);
            insert territory;
            system.debug('territory.ownerId::::'+territory[0].ownerId);
            
            // Need a contact record type?  Yes
            // Does it matter which one?  Yes, it does.  Do *not* use the 'NAZ User' option, as this
            // has trigger code (owned by Labatt) attached to it
            String rtn = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CDP Contact').getRecordTypeId();

            

            User pu = new User(
                LastName = 'Test'
                , Email = 'ap@slalom.com'
                , UserName = 'ap@slalom.com'
                , Alias = 'apslalom'
                , LanguageLocaleKey='en_US' // no canadian value
                , LocaleSidKey='en_CA'
                , ProfileId = platformProfileId.Id
                , TimeZoneSidKey='America/New_York'
                , EmailEncodingKey='UTF-8' // required
                , CurrencyISOCode='CAD' // Not needed but including for completeness
                , ccrz__CC_CurrencyCode__c='CAD' // Also not needed, but including for completeness
                    //, DefaultDivision = [id value from Division standard object; required in UI but not here]

                    // Setting UserRoleId to null is supposed to allow mixed DML operations...
                    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_non_mix_sobjects.htm
                    // ....it does, but it doesn't allow community users to be inserted the same way :P
                    //, UserRoleId = null
                    //
                    // Bonus: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_non_mix_sobjects_test_methods.htm
                , UserRoleId = r.Id
                ,Is_TAU_Admin__c =true
                
            );
            insert pu;
            Account territoryAccount = new Account(
                Name = 'Test Territory Account'
                //, RecordTypeId = ... need to figure out our new record type...
                // #tags #todo #userModelChange_August
            );
            territoryAccount.OwnerId = pu.Id;
            insert territoryAccount;
            Contact territoryContact = new Contact(
                FirstName = 'Test'
                , LastName = 'Contact'
                , Email = 'ac@slalom.com'
                , Phone = '555-555-5555'
                , AccountId = territoryAccount.Id
                , RecordTypeId = rtn
                // other required fields?

            );
            insert territoryContact;
            // Community User
            User cu = new User(
                LastName = 'TestCommunity'
                , Email = 'ac@slalom.com'
                , UserName = 'ac@slalom.com'
                , Alias = 'acslalom'
                , LanguageLocaleKey='en_US' // no canadian value
                , LocaleSidKey='en_CA'
                , ProfileId = communityProfileId.Id
                , TimeZoneSidKey='America/New_York'
                , EmailEncodingKey='UTF-8' // required
                , CurrencyISOCode='CAD' // Not needed but including for completeness
                , ccrz__CC_CurrencyCode__c='CAD' // Also not needed, but including for completeness
                //, DefaultDivision = [id value from Division standard object; required in UI but not here]
                //, UserRoleId = null

                // Community stuff
                , CommunityNickname = 'barking'
                , ContactId = territoryContact.Id
            );
            insert cu;

            
        }
    }

    @isTest
    static void test1() {
        // Create data

        // Doesn't matter what profile for the test, but may matter in the future
        String platformProfile = 'Standard User'; // 'OnPoint...something?'
        String platformProfileId = null;
        String communityProfile = 'Customer Community User'; // 'OnPoint Community User'
        String communityProfileId = null;
        String sysAdminProfile = 'System Administrator';
        String sysAdminProfileId = null;

        for(Profile p:[SELECT Id, Name FROM Profile WHERE Name = :platformProfile OR Name = :communityProfile]) {
            if(p.Name == platformProfile) {
                platformProfileId = p.Id;
            }
            if(p.Name == communityProfile) {
                communityProfileId = p.Id;
            }
            if(p.Name == sysAdminProfile) {
                sysAdminProfileId = p.Id;
            }
        }

        // Nobody but an admin should be running test classes, so we can use UserInfo.getUserId().
        // It would be better to not make that assumption but then we'd have to create an admin
        // user in @testSetup.  Things start to get cyclical. :P
        //
        // This is a safe enough assumption though.
        User adminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        // Need to use System.runAs to avoid Mixed DML Errors
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_non_mix_sobjects_test_methods.htm
        User cu;
        User pu;
        System.runAs(adminUser) {

            pu = [select LastName, Email, UserName, Alias, LanguageLocaleKey, LocaleSidKey, 
                ProfileId, TimeZoneSidKey, EmailEncodingKey, CurrencyISOCode, 
                ccrz__CC_CurrencyCode__c,Is_TAU_Admin__c from User where UserName = 'ac@slalom.com' limit 1];

            // Community User
            cu = [select LastName, Email, UserName, Alias, LanguageLocaleKey, LocaleSidKey, 
                ProfileId, TimeZoneSidKey, EmailEncodingKey, CurrencyISOCode, 
                ccrz__CC_CurrencyCode__c, CommunityNickname, ContactId from User where UserName = 'ac@slalom.com' limit 1]; 
        }

        // User assignment via Territory...

        // Create Territory
        OnPoint_Territory__c opt = new OnPoint_Territory__c(
            Name = 'Terry Territory'
            , CloudCraze_Community_User__c = cu.Id
            , ownerId =pu.Id
        );
        insert opt;
        system.debug('opt.ownerId::::'+opt.ownerId);

        // Create Territory Role
        OnPoint_Territory_Role__c optr = new OnPoint_Territory_Role__c(
            Name = 'Test OP Territory Role'
            , OnPoint_Territory__c = opt.Id
            , User__c = pu.Id
            , Is_Deactivated__c = false
        );
        insert optr;
        
        // create onplan territory
        lboc_Sales_Territory__c lbocSalesTerr = new lboc_Sales_Territory__c(
        Name ='Test',
        lboc_Territory_ID__c = '50000',
        CurrencyIsoCode = 'CAD',
        lboc_Region_ID__c = 'QUEBEC (Region)',
        ownerId =pu.Id
        );
        insert lbocSalesTerr;
        
        // Create Territory budget
         Annual_Area_Budget__c bdgt = new Annual_Area_Budget__c(
         
            Sales_Territory__c = lbocSalesTerr.Id,
            Budget_Year__c = '2019',
            Discretionary_Budget__c = 4000.33,
            Drivers_Budget__c = 500.66
            
           );
         insert bdgt;

         // insert custom setting 
         TAUserViewRefrence__c cs = new TAUserViewRefrence__c();
         cs.name ='test1';
          cs.previewAs__c ='preview as backoffice';
          cs.user_Email_Id__c='test@test.com';
          insert cs;
        // Instantiate class and test
        Test.startTest();
        System.runAs(pu) {
            OnPoint_dash_Home op = new OnPoint_dash_Home();
            System.assert(op.communityAssignments.size() > 0);
        }
        Test.stopTest();
    }
   
}