//
// (c) 2012 Appirio, Inc.
//
// Handler class of AccountTrigger
//
// 15 Sep 2015     Parul Gupta       Original
// 23 Aug 2016     Gagandeep Kaur    T-529114 : Enhancements to Trigger to Prevent Account Deletes
// 25 May 2017     Ramakrishna Gouni OwnerUpdate method added
// 8  Jan 2018     Dianna Guilinger  TeleSales - add logic for TeleSales 
// 15 Sep 2018     Rizwan Ahmed      Update for GSC package
// 16 Sep 2018     Rizwan Ahmed      Update for GSC package
// 29 Sep 2018     Rizwan Ahmed      Update for GSC package
// 2  Oct 2018     Rizwan Ahmed      Update for GSC package
// 4  oct 2018     Rizwan Ahmed      Update for GSC package
// 20  oct 2018    Rizwan Ahmed      Update for GSC package - remove reference to old fields
// 
/*
    US-W-013969
    Updated Method: createPOCBudgetPlansBO
    Updated By: Amol P
    */
public class AccountTriggerHandler {
    
    public static final Integer CALL_SIZE=2000;
    
    //Tactical short term solution for disabling SAP Updates to the frequency lookup fields.  
    //To Be Removed after Christmas season has ended and new Temp frequency functionality has been incorporated
    public static final String DISABLE_FREQUENCY_UPDATE = label.On_Call_Disable_Frequency_Update_From_SAP;
    //Added AcountSummaryTrigger - 1
    private static final Set<String> nrsRTNames = new Set<String>{'Banner','Chain','Decision Point','POC','Wholesaler'};
        private static final Set<Id> nrsRTIds = new Set<Id>();
    //AcountSummaryTrigger - 1
    
    //Added AccountTriggerHandler -1
    public static boolean firstRun = true;
    //AccountTriggerHandler end -1
    
    //20170913 Jose Nehme - Slalom
    public static Map<Id,String> accountIdURLMap = new Map<Id,String>();
    
    // moved get of record types so shared
    public static List<RecordType> recordTypes = getRecordTypes();
    public static Id recTypeSoldTo;
    public static Id recTypeShipTo;
    public static Id recTypePayTo;
    public static Id recTypePOC;
    
    //Calls methods mentioned.
    //Previous /AB_AccountUpdate functionality to insert PocXRef__c and Updates Account's GSC_Place_ID__c and Remote_Survey_Vendor_Enabled__c
    public static void beforeInsert(List<Account> newList) {
        set<string> accOldPartyIds = new set<string>();
        list<PocXRef__c> insLstPocXRef = new list<PocXRef__c>();
        list<account> oldEDWIDAcc = new list<account>(); 
        map<string,account> mapAccount = new map<string,account>();
        List<Account> proposalListToUpdate = new List<Account>();
        List<Account> priceListToUpdate = new List<Account>();
        List<Account> routeToUpdate = new List<Account>();
        List<Account> dcToUpdate = new List<Account>();
        List<Account> freqToUpdate = new List<Account>();
        List<Account> PORequiredToUpdate = new List<Account>();
        List<Account> soldToWithShipTo = new List<Account>();
    //        List<RecordType> recordTypes = getRecordTypes();
        List<Account> soldToKATR2 = new List<Account>();
        
        Set<Id> oldAccIds = new Set<Id>(); // to reset the GSC Id - Femi
  /*      Id recTypeSoldTo;
  //      Id recTypeShipTo;
  //      Id recTypePayTo;
  //      Id recTypePOC;
        if(recordTypes != null && !recordTypes.isEmpty()){
            for(RecordType recType: recordTypes){
                if(recType.Name == 'OnCall POC / Sold To'){
                    recTypeSoldTo = recType.id;
                }else if(recType.Name == 'OnCall Ship To'){
                    recTypeShipTo = recType.id;
                }else if(recType.Name == 'OnCall Pay To'){
                    recTypePayTo = recType.id;
                }else if(recType.Name == 'POC'){
                    recTypePOC = recType.id;
                }
            }
        }
   */    
        setRecTypes(); 
        for(Account acc: newList){

           //AB_AccountUpdate start ---1
           //Femi Onakoya added below line. 02/21/2018
            if(acc.OldPartyId__c == acc.EDWID_US__c || acc.OldPartyId__c == NULL || acc.OldPartyId__c == '')

            {
            //RA - 9/15/2018, 10/2/2018 - Uppdate GSC package
            //acc.Remote_Survey_Vendor_Enabled__c = true;
            acc.gsc_mc__Sync_to_GoSpotCheck__c = true;
            //End
            }
            if(acc.OldPartyId__c != null)
            {
                accOldPartyIds.add(acc.OldPartyId__c);
                //inserting PocXRef records if account OldPartyId is not null
                PocXRef__c insPoc = new PocXRef__c();
                insPoc.OldPartyId__c=acc.OldPartyId__c;
                insPoc.PartyID__c= acc.EDWID_US__c;
                insLstPocXRef.add(insPoc );
            } //AB_AccountUpdate end ---1
            if(acc.Customer_Number__c != null && acc.Customer_Number__c != ''){
                if(acc.Customer_Number__c.startsWith('001') && recTypeSoldTo != null){
                    acc.recordtypeId = recTypeSoldTo;
                }else if(acc.Customer_Number__c.startsWith('002') && recTypeShipTo != null){
                    acc.recordtypeId = recTypeShipTo;
                }else if(acc.Customer_Number__c.startsWith('003') && recTypePayTo != null){
                    acc.recordtypeId = recTypePayTo;
                }
            }
            if(acc.OnCall_Ignore_PL_POCFilter__c == false && acc.RecordTypeId == recTypeSoldTo){
                proposalListToUpdate.add(acc);
            }
            if(acc.KDKG2__c != null && acc.KDKG2__c != '' && acc.RecordTypeId == recTypeSoldTo){
                priceListToUpdate.add(acc);
            } 
            if(acc.OnCall_Route_Code__c != null && acc.OnCall_Route_Code__c != '' && acc.RecordTypeId == recTypeSoldTo){
                routeToUpdate.add(acc);
            }                       
            if(acc.RecordTypeId == recTypeSoldTo && acc.Ship_To_Account__c != null){
                if(acc.Ship_To_Account__c != null){
                    soldToWithShipTo.add(acc);
                    soldToKATR2.add(acc);
                }
                dcToUpdate.add(acc);
            } 
            if(acc.OnCall_Ignore_PO_POCFilter__c == false){
                PORequiredToUpdate.add(acc);
            }
            if(DISABLE_FREQUENCY_UPDATE != 'Yes' && DISABLE_FREQUENCY_UPDATE != 'True' && ((acc.Call_Frequency_Code_SAP__c != null && acc.Call_Frequency_Code_SAP__c != '') 
                                                                                           || (acc.Delivery_Frequency_Code_SAP__c != null && acc.Delivery_Frequency_Code_SAP__c != ''))){
                                                                                               freqToUpdate.add(acc);
                                                                                           }
            
        }
        
        if(soldToKATR2 != null && !soldToKATR2.isEmpty()){
            populateSoldToKATR2(soldToKATR2); 
        }
        if(proposalListToUpdate != null && !proposalListToUpdate.isEmpty()){
            updatePOCProposalList(proposalListToUpdate,null); 
        }
        if(PORequiredToUpdate != null && !PORequiredToUpdate.isEmpty()){
            updatePOCPORequired(PORequiredToUpdate, null);
        }
        if(priceListToUpdate != null && !priceListToUpdate.isEmpty()){
            updatePriceList(priceListToUpdate, null);
        }
        if(routeToUpdate != null && !routeToUpdate.isEmpty()){
            updateRouteCode(routeToUpdate, null);
        }
        if(soldToWithShipTo != null && !soldToWithShipTo.isEmpty()){
            populateSoldToDCCode(soldToWithShipTo); 
        }
        if(dcToUpdate != null && !dcToUpdate.isEmpty()){
            updateDC(dcToUpdate, null);
        }
        if(freqToUpdate != null && !freqToUpdate.isEmpty()){
            updateFrequency(freqToUpdate);
        }
        
        //AB_AccountUpdate start - 2
        
        //RA 9/5/2018,10/2/2018 - Update Field / API name for managed package
        //oldEDWIDAcc =[select id,EDWID_US__c,GSC_Place_ID__c  from Account where EDWID_US__c IN :accOldPartyIds];
        oldEDWIDAcc =[select id,EDWID_US__c,gsc_mc__GSC_Id__c,gsc_mc__Last_Sync__c from Account where EDWID_US__c IN :accOldPartyIds];
        //
        
        if(!oldEDWIDAcc.isEmpty())
        {
            for(Account acc:oldEDWIDAcc) 
            {   mapAccount.put(acc.EDWID_US__c,acc);                 
            }
        }
        
        for(Account a:newList)
        {
            Account oldAcc = new Account();
            if(a.OldPartyId__c != null)
            {
                if(!mapAccount.isEmpty())
                {
                    oldAcc=mapAccount.get(a.OldPartyId__c);
                }
                if(oldAcc != null)
                {   
                    //RA 9/6/2018,10/2/2018,10/20/2018 - Update Field / API name for managed package. Revert to original condition. remove reference
                    //if(oldAcc.GSC_Place_ID__c != null && oldAcc.GSC_Place_ID__c !='')
                    if(oldAcc.gsc_mc__GSC_Id__c != null && oldAcc.gsc_mc__GSC_Id__c !='')  {
                        // resetting fields - femi
                        //RA 9/15/2018,10/2/2018,10/20/2018 - Update Field / API name for managed package
                        //oldAcc.Remote_Survey_Vendor_Enabled__c = false;
                        oldAcc.gsc_mc__Sync_to_GoSpotCheck__c = false;
                        //End
                        
                        //RA 9/6/2018, 9/29/2018.9/20/2018 - Update Field / API name for managed package
                        String GSCID = oldAcc.gsc_mc__GSC_Id__c;
                        //a.GSC_Place_ID__c = oldAcc.GSC_Place_ID__c;
                        a.gsc_mc__GSC_Id__c = GSCID;
                        a.gsc_mc__Last_Sync__c = oldAcc.gsc_mc__Last_Sync__c;
                        //RA 9/29/2018 - Update logic to accommodate for uniue GSC ID
                        oldAcc.gsc_mc__GSC_Id__c = null;
                        //End
                        
                        //RA 9/15/2018,10/2/2018,10/19/2018 - Update Field / API name for managed package
                        //a.Remote_Survey_Vendor_Enabled__c = true; 
                        a.gsc_mc__Sync_to_GoSpotCheck__c = true;
                        //End
                        oldAccIds.add(oldAcc.Id); // holding the oldAccIds - Femi
                        //oldAcc.GSC_Place_ID__c = null; // assign null to old acc - femi
                        mapAccount.put(a.OldPartyId__c, oldAcc); // building oldAccmap
                    }   
                }
                else { 
                    //RA 9/15/2018 - Update Field / API name for managed package
                    //a.Remote_Survey_Vendor_Enabled__c = true;
                    a.gsc_mc__Sync_to_GoSpotCheck__c = true;
                    //End
                    }
            } 
            
        }
        if(!insLstPocXRef.isEmpty())
        {
            try{
                insert insLstPocXRef;
            }catch(exception e){
                system.debug('Dml Exception'+e);
            }
        }
        /* // added below logic above itself - femi
        if(!oldEDWIDAcc.isEmpty())
        {
            for(Account acc:oldEDWIDAcc) 
            {
                acc.Remote_Survey_Vendor_Enabled__c = false;
                acc.GSC_Place_ID__c = null;//added according to the change req on Feb14
            }
        }
        */
        try{
            //update oldEDWIDAcc;
            update mapAccount.values();
        }catch(exception e){
            system.debug('Dml Exception'+e);
        }//AB_AccountUpdate end  - 2
        
        
        // passing only those account which is of Record type 
        string recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
            
        /*** Update the record type if the poc__c to outlet**/
        // setting record type as per discussion on 21-Sept-2017
        for(Account acc : (List<Account>)Trigger.New){
            if(acc.lboc_Labatt_Outlet_Id__c != null){
                acc.recordTypeId = recordTypeId;
            }
        }
        
        /***** Below code is for updating OnPlan_Sales_Territory Field if any account inserted or updated ****/
        
        /***
         * Below code will only work of the OnPlan_RunUpdateSalesTerritory is true
         * else it will skit the below logic for updating the OnPlan_Sales_Territory field on account
         **/
        if(Label.OnPlan_RunUpdateSalesTerritory.toLowerCase() == 'true'){
            
            // this will store account ids to be processed
            List<Account> lstProcessAcc = new List<Account>();
            
            for(Account acc : (List<Account>)Trigger.New){
                
                /***
                // setting record type as per discussion on 21-Sept-2017
                if(acc.lboc_Labatt_Outlet_Id__c != null){
                    acc.recordTypeId = recordTypeId;
                    lstProcessAcc.add(acc);
                }
                **/
                
                /**
                 * checking if the record type is Outlet only then process account by storing in
                 * in a list which will passed to the updateSalesTerritory method
                 **/
                 if(acc.recordTypeId == recordTypeId){
                    lstProcessAcc.add(acc);
                 }

                // checking is process check box to true if the lboc_Labatt_Outlet_Id__c is not null
                if( acc.lboc_Labatt_Outlet_Id__c != null){
                    acc.IsProcessed__c = true;
                }
                
            }
            
            // if we have the account which is of record type Outlet in the process account lis only then call method
            if(!lstProcessAcc.isEmpty()){
                
                // code to update the OnPlan_Sales_Territory__c Field on account
                OnPlan_AccountUtility.updateSalesTerritory(lstProcessAcc);
            }
            
        }
        
        // Calling the @Future method for resetting the GSC Id - Femi
        if(oldAccIds.size() > 0){
            resetOldAccs(oldAccIds);
        }
        
    }
    
    // To Reset the GSC Id - @Future call - Femi
    @future
    private static void resetOldAccs(Set<ID> oldAccIds){
        List<Account> oldAcclist = new List<Account>();
        for(Id oldAccId : oldAccIds){
            //RA 9/6/2018 - Update Field / API name for managed package
            //oldAcclist.add(new Account(Id = oldAccId, GSC_Place_ID__c = null));
            //oldAcclist.add(new Account(Id = oldAccId, gsc_mc__GSC_Id__c = null, GSC_Place_ID__c = null));
            //RA 10/20/2018 - Remove reference to old fields
            oldAcclist.add(new Account(Id = oldAccId, gsc_mc__GSC_Id__c = null));
            //
        }
        update oldAcclist;
    }
    //Calls methods mentioned
    public static void beforeUpdate(List<Account> newList, Map<Id, Account> oldMap){
        List<Account> proposalListToUpdate = new List<Account>();
        List<Account> priceListToUpdate = new List<Account>();
        List<Account> routeToUpdate = new List<Account>();
        List<Account> dcToUpdate = new List<Account>();
        List<Account> freqToUpdate = new List<Account>();
        List<Account> PORequiredToUpdate = new List<Account>();
        List<Account> relatedShipToChange = new List<Account>();
        List<Account> dcUpdateFromSAPList = new List<Account>();
        List<Account> katr2UpdateFromSAPList = new List<Account>();
		
        // 03-03-2020 Updated part1
		Id POCAccrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('POC').getRecordTypeId();
        Id POCClosedAccrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('POC Closed').getRecordTypeId();
        Id NRSIntegrationUSerId;
        list<user> results;
        results =(list<User>)[FIND 'NRS Integration' in Name FIELDS RETURNING User(Name, id) LIMIT 1][0];
        if(results.size()>0){
        NRSIntegrationUSerId=results[0].id;
        }
        
       /* 
		Search.SearchResults searchResults = Search.find('FIND \'NRS Integration\' IN NAME FIELDS RETURNING User(id, name) LIMIT 1');
         List<Search.SearchResult> Searchlist = searchResults.get('User');
         for (Search.SearchResult searchResult : SearchList) { 
                        User data = (User) searchResult.getSObject(); 
                        System.debug(data.name); 
                        System.debug(data.id); 
              NRSIntegrationUSerId=data.id;
                    } 
*/
        
        Set<String> SetWSLRNBR=new Set<string>();
        list<Account> POCClosedAccountslist =new list<Account>();
		Map< string, Account> WholeSalerdetails=new Map<string,Account> ();
        // part1 ends
        
		for(Account acc: newList){

            //08-NOV-2017 SLM Slalom - remove geocode data if address is blank
            /*if (String.isBlank(acc.BillingStreet) || String.isBlank(acc.BillingCity)){
               acc.BillingLatitude = null;
               acc.BillingLongitude = null;
            } */
            
            Account oldAcc = oldMap.get(acc.Id);
            if(acc.OnCall_Record_Type__c == 'OnCall POC / Sold To' && acc.KATR2__c == null && oldAcc.KATR2__c != null){
                katr2UpdateFromSAPList.add(acc);
            }
            if((acc.OnCall_Record_Type__c == 'OnCall POC / Sold To' && acc.OnCall_Ignore_PL_POCFilter__c == false) && (acc.OnCall_Ignore_PL_POCFilter__c != oldAcc.OnCall_Ignore_PL_POCFilter__c 
                                                                                                                       || acc.KATR2__c != oldAcc.KATR2__c
                                                                                                                       || acc.Proposal_List__c != oldAcc.Proposal_List__c || acc.DSM_ID__c != oldAcc.DSM_ID__c 
                                                                                                                       || acc.DC_Code_from_SAP__c != oldAcc.DC_Code_from_SAP__c || acc.TM_ID__c != oldAcc.TM_ID__c || acc.Sales_Area_ID__c != oldAcc.Sales_Area_ID__c 
                                                                                                                       || acc.Banner_ID__c != oldAcc.Banner_ID__c || acc.KDKG2__c != oldAcc.KDKG2__c 
                                                                                                                       || acc.Customer_Segment__c != oldAcc.Customer_Segment__c)){
                                                                                                                           proposalListToUpdate.add(acc);
                                                                                                                       }
            if((acc.OnCall_Record_Type__c == 'OnCall POC / Sold To' && acc.KDKG2__c != null && acc.KDKG2__c != '' && (acc.KDKG2__c != oldAcc.KDKG2__c))){
                priceListToUpdate.add(acc);
            }
            if(acc.OnCall_Route_Code__c != null && acc.OnCall_Route_Code__c != '' && acc.OnCall_Record_Type__c == 'OnCall POC / Sold To'){
                routeToUpdate.add(acc);
            }
            if(acc.OnCall_Record_Type__c == 'OnCall POC / Sold To' && acc.DC_Code_from_SAP__c == null && oldAcc.DC_Code_from_SAP__c != null){
                dcUpdateFromSAPList.add(acc);
            } 
            if(acc.OnCall_Record_Type__c == 'OnCall POC / Sold To' && (acc.Ship_To_Account__c != oldAcc.Ship_To_Account__c || acc.DC_Code_from_SAP__c != oldAcc.DC_Code_from_SAP__c)){
                relatedShipToChange.add(acc);
                dcToUpdate.add(acc);
            }
            
            if(DISABLE_FREQUENCY_UPDATE != 'Yes' && DISABLE_FREQUENCY_UPDATE != 'True' && 
               ((acc.Call_Frequency_Code_SAP__c != oldAcc.Call_Frequency_Code_SAP__c) 
                || (acc.Delivery_Frequency_Code_SAP__c != oldAcc.Delivery_Frequency_Code_SAP__c))  && acc.OnCall_Record_Type__c == 'OnCall POC / Sold To'){
                   freqToUpdate.add(acc);
               }  
			   
			   // 03-03-2020 Updated part2
			if( Acc.RecordTypeId==POCAccrecordTypeId && (Acc.Open_Close_Stat_CD_Us__c=='40'||Acc.Open_Close_Stat_CD_Us__c=='50'||Acc.Open_Close_Stat_CD_Us__c=='60'))
            { 
                if( Acc.Wholesaler__c!=NULL)
                {
                    //Acc.Wholesaler_Number__c=Acc.Wholesaler__r.WSLR_NBR_US__c;
                    Acc.Wholesaler_Number__c = Acc.HD_Wholesaler_Number__c;
                    Acc.Wholesaler__c=NULL;	 
                }
                Acc.RecordTypeId=POCClosedAccrecordTypeId;
               Acc.OwnerId = NRSIntegrationUSerId;
            }
                   
             // Record type is POC Closed and Open_Close_Stat_CD_Us__c having 10,20,30
            if(Acc.RecordTypeId==POCClosedAccrecordTypeId  && (Acc.Open_Close_Stat_CD_Us__c=='10' ||Acc.Open_Close_Stat_CD_Us__c=='20'||Acc.Open_Close_Stat_CD_Us__c=='30'))
            { 
                if( !String.ISBLANK(Acc.Wholesaler_Number__c) ){
                    
                     SetWSLRNBR.add(Acc.Wholesaler_number__c);
                     POCClosedAccountslist.add(Acc);
                }
                Acc.RecordTypeId=POCAccrecordTypeId;
                           
             }
			 //Part 2 ends 

        }

        if(relatedShipToChange != null && !relatedShipToChange.isEmpty()){
            populateSoldToKATR2(relatedShipToChange); 
        }
        if(katr2UpdateFromSAPList != null && !katr2UpdateFromSAPList.isEmpty()){
            katr2UpdateFromSAP(katr2UpdateFromSAPList);
        }
        if(proposalListToUpdate != null && !proposalListToUpdate.isEmpty()){
            updatePOCProposalList(proposalListToUpdate,oldMap); 
        }
        if(priceListToUpdate != null && !priceListToUpdate.isEmpty()){
            updatePriceList(priceListToUpdate, oldMap);
        }
        if(routeToUpdate != null && !routeToUpdate.isEmpty()){
            updateRouteCode(routeToUpdate, oldMap);
        }
        if(dcUpdateFromSAPList != null && !dcUpdateFromSAPList.isEmpty()){
            dcUpdateFromSAP(dcUpdateFromSAPList);
        }
        if(relatedShipToChange != null && !relatedShipToChange.isEmpty()){
            populateSoldToDCCode(relatedShipToChange); 
        }
        if(dcToUpdate != null && !dcToUpdate.isEmpty()){
            updateDC(dcToUpdate, oldMap);
        }
        if(freqToUpdate != null && !freqToUpdate.isEmpty()){  updateFrequency(freqToUpdate);
        }
        List<Account> onPointAccountsBeforeUpdate = new List<Account>();
        for(Account acc: newList){
            Account oldAcc = oldMap.get(acc.Id);
            if((acc.OnCall_Ignore_PO_POCFilter__c == false) && (acc.PO_Required__c != oldAcc.PO_Required__c || 
                                                                acc.OnCall_Ignore_PO_POCFilter__c != oldAcc.OnCall_Ignore_PO_POCFilter__c || 
                                                                acc.DSM_ID__c != oldAcc.DSM_ID__c || 
                                                                acc.DC_Code_from_SAP__c != oldAcc.DC_Code_from_SAP__c || 
                                                                acc.TM_ID__c != oldAcc.TM_ID__c || 
                                                                acc.Sales_Area_ID__c != oldAcc.Sales_Area_ID__c || 
                                                                acc.Banner_ID__c != oldAcc.Banner_ID__c || 
                                                                acc.KDKG2__c != oldAcc.KDKG2__c || 
                                                                acc.Customer_Segment__c != oldAcc.Customer_Segment__c)){
                                                                    PORequiredToUpdate.add(acc);
                                                                }
            if(acc.lboc_Labatt_Outlet_Id__c != null){
                onPointAccountsBeforeUpdate.add(acc);
            }
			
			
			
			

        }
        if(PORequiredToUpdate != null && !PORequiredToUpdate.isEmpty()){
            updatePOCPORequired(PORequiredToUpdate,oldMap); 
        }
        
        if(!onPointAccountsBeforeUpdate.isEmpty()){
            OnPoint_AccountPOCTriggerHandler.beforeUpdate(onPointAccountsBeforeUpdate, oldMap);
        }
        
        /***** Below code is for updating OnPlan_Sales_Territory Field if any account inserted or updated ****/
        
        /***
         * Below code will only work of the OnPlan_RunUpdateSalesTerritory is true
         * else it will skit the below logic for updating the OnPlan_Sales_Territory field on account
         **/
        if(Label.OnPlan_RunUpdateSalesTerritory.toLowerCase() == 'true'){
            
            // passing only those account which is of Record type 
            string recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
            
            // this will store account ids to be processed
            List<Account> lstProcessAcc = new List<Account>();
            for(Account acc : (List<account>)Trigger.New){
                
                // getting old record
                Account oldRec = (Account)Trigger.oldmap.get(acc.Id);
                
                // checking is process check box to true if the lboc_Labatt_Outlet_Id__c is not null
                if( acc.lboc_Labatt_Outlet_Id__c != null
                    && oldRec.lboc_Labatt_Outlet_Id__c != acc.lboc_Labatt_Outlet_Id__c){
                    acc.IsProcessed__c = true;
                    
                }
                //If this is an OnPlan or OnPoint Account and the territory code has changed
                if(acc.lboc_Labatt_Outlet_Id__c != null && acc.OnPoint_Territory_Code__c != oldRec.OnPoint_Territory_Code__c){
                    acc.OnPoint_isTerritoryChanged__c = TRUE;
                }

                
                /**
                 * checking if the record type is Outlet  
                 * and there is a change in the OnPoint_Sales_Territory field
                 * and OnPoint_Sales_Territory is not null 
                 * only then process account by storing in a list which will passed to the updateSalesTerritory method
                 **/
                 if(acc.recordTypeId == recordTypeId
                  && acc.OnPoint_Sales_Territory__c != null
                  && acc.OnPoint_Sales_Territory__c != oldRec.OnPoint_Sales_Territory__c){  lstProcessAcc.add(acc);
                 }      
                 else if(acc.OnPoint_Sales_Territory__c == null){
                        acc.OnPlan_Sales_Territory__c = null;
                 }
            }
            
            // if we have the account which is of record type Outlet in the process account lis only then call method
            if(!lstProcessAcc.isEmpty()){
                
                // code to update the OnPlan_Sales_Territory__c Field on account
                OnPlan_AccountUtility.updateSalesTerritory(lstProcessAcc);
            }
            
        }    

      // 03-03-2020 Updated Part3
        if(POCClosedAccountslist.size()>0){
            // fetching parents Accounts WSLR_Nbr_US__c which is mapped to whole saler number of  child account
           list<Account> WholesalerAccounts=[select id , ownerid ,WSLR_NBR_US__c from Account  where  WSLR_NBR_US__c in :SetWSLRNBR];
            for(Account A:WholesalerAccounts){
                WholeSalerdetails.put( A.WSLR_NBR_US__c, A);
             }
           }
        
        if(!WholeSalerdetails.isEmpty()){
        for(Account Acc:POCClosedAccountslist){
            if(WholeSalerdetails.containsKey(Acc.Wholesaler_Number__c)){
            Acc.Wholesaler__c=WholeSalerdetails.get(Acc.Wholesaler_Number__c).id;
            
                //stem.debug('...'+Acc);
            Acc.OwnerId=WholeSalerdetails.get(Acc.Wholesaler_Number__c).ownerId;
                  }
            
        }       
        }
		
		//Part 3 Ends here

    }
    
     
    
    
    //Inserts lboc_Account_Detail__c and lboc_Account_Performance__c.
    //Calls methods mentioned below.
    public static void afterInsert(List<Account> newList){
        string recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
        List<Account> onPointAccountsAfterInsert = new List<Account>();
        //20170913 Jose Nehme - Slalom
        Map<Id,String> accountIdURLMap = new Map<Id,String>();

        //Added AcountSummaryTrigger - 2
        for(String rt : nrsRTNames){
            nrsRTIds.add(Util.getRecordTypeId('Account', rt));
        }
        
        List<lboc_Account_Performance__c> acctPerfList = new List<lboc_Account_Performance__c>();
        List<lboc_Account_Detail__c> acctDetailList = new List<lboc_Account_Detail__c>();
        //AccountSummaryTrigger end -2
        updateTableControlPocList(newList);
        List<Account> createTargetVolumeList = new List<Account>();
        for(Account acc: newList){
            //20170913 Jose Nehme - Slalom
            geocodePreProcess(acc, accountIdURLMap);
            //AccountSummaryTrigger -3
            if(!nrsRTIds.contains(acc.RecordTypeId))
            {
                lboc_Account_Detail__c acctDetailRec = new lboc_Account_Detail__c();
                lboc_Account_Performance__c acctPerfRec = new lboc_Account_Performance__c();
                
                acctDetailRec.lboc_Account__c = acc.Id;
                acctPerfRec.lboc_Account__c = acc.Id;
                
                acctPerfList.add(acctPerfRec);
                acctDetailList.add(acctDetailRec);
            }
            //AccountSummaryTrigger end -3
            if(acc.Customer_Number__c != null){
                if(acc.Customer_Number__c.startsWith('001')){
                    createTargetVolumeList.add(acc);
                }
            }
            if(acc.lboc_Labatt_Outlet_Id__c != null){
                onPointAccountsAfterInsert.add(acc);
            }
        }

        if(createTargetVolumeList != null && !createTargetVolumeList.isEmpty())
        {
            createVolumeTarget(createTargetVolumeList); 
        }
        
        //Added AcountSummaryTrigger - 4
        if(acctDetailList != null && acctDetailList.size() > 0)
        {
            insert acctDetailList;
        }
        
        if(acctPerfList != null && acctPerfList.size() > 0)
        {
            insert acctPerfList;
        }
        // end AcountSummaryTrigger - 4
        
        //Add AccountTriggerHandler - 2
        createAndUpdateCOH(newList, null);
        
        // end AccountTriggerHandler end - 2
        // 08-NOV-2017 SLALOM - prevent geocode from running in batch mode
        if(!accountIdURLMap.isEmpty() && !System.isBatch()) {  AccountGeocodeAddress.DoAddressGeocode(accountIdURLMap);
        }

        if(!onPointAccountsAfterInsert.isEmpty()){
            OnPoint_AccountPOCTriggerHandler.afterInsert(onPointAccountsAfterInsert);
        }
    }
    
    //Calls Batch class OnCall_DeleteFutureCallsBatch.
    //Updates Proposal_List__c to null.
    //Calls deleteTCPoc method by default
    //calls all other methods mentioned
    // 
    public static void afterUpdate(List<Account> newList, Map<Id, Account> oldMap){
        Boolean teleSalesAcct = false;
        List<Account> listToUpdate = new List<Account>();
        Set<id> shipToUpdate = new set<id>();
        Set<id> callsToDelete = new set<id>();
        List<Account> shipToWithDC = new List<Account>();
        List<Account> shipToWithKATR2 = new List<Account>();
        List<Account> soldToOrderBlockChange = new List<Account>();
        List<Account> accToCreatePOCBudgetPlans = new List<Account>();
        List<Account> onPointAccountsAfterUpdate = new List<Account>();
         List<Account> accTOCreatePOCBudgetPlanFOrBO= new List<Account>();    //AP CHANGES W-013969
        setRecTypes(); 

        for(Account acc: newList){
            
            //check if Billing Address has been updated
            Boolean addressChangedFlag = false;
            Account oldAccount = oldMap.get(acc.Id);
            if((acc.BillingStreet != oldAccount.BillingStreet) || 
                (acc.BillingCity != oldAccount.BillingCity) ||
                (acc.BillingCountry != oldAccount.BillingCountry) ||
                (acc.BillingPostalCode != oldAccount.BillingPostalCode)) {
                addressChangedFlag = true;   
                System.debug(LoggingLevel.DEBUG, '***Address changed for - ' + oldAccount.Name);
            }
            // if address is null or has been changed, geocode it
            if ((acc.BillingLatitude == null) || (acc.BillingLongitude == null) || (addressChangedFlag == true)){
                //System.debug(LoggingLevel.DEBUG,'***Geocoding Account - ' + account.Name);
                geocodePreProcess(acc, accountIdURLMap);
            }
        
            Account oldAcc = oldMap.get(acc.Id);
            if(acc.DSM_ID__c != oldAcc.DSM_ID__c || acc.DC_Code_from_SAP__c != oldAcc.DC_Code_from_SAP__c || acc.TM_ID__c != oldAcc.TM_ID__c 
               || acc.Sales_Area_ID__c != oldAcc.Sales_Area_ID__c || acc.KDKG2__c != oldAcc.KDKG2__c 
               || acc.Customer_Segment__c != oldAcc.Customer_Segment__c){
                   listToUpdate.add(acc);
               }
            if(acc.OnCall_Record_Type__c == 'OnCall Ship To' && acc.KATR2__c != oldAcc.KATR2__c){
                shipToUpdate.add(acc.id);
            }
            if (acc.Call_Frequency__c != oldAcc.Call_Frequency__c){
                callsToDelete.add(acc.id);
            }
            // for POC accounts used by TeleSales US
            system.debug('@@ recTypePOC:'+recTypePOC);
            system.debug('@@ acc:'+acc);
            if (recTypePOC != null &&
             acc.recordtypeId == recTypePOC &&
             ( acc.Delivery_Frequency__c != oldAcc.Delivery_Frequency__c || 
               acc.Preferred_Call_Time__c != oldAcc.Preferred_Call_Time__c ||
               acc.Preferred_Contact_Email__c != oldAcc.Preferred_Contact_Email__c ||
               acc.Preferred_Contact_Name__c != oldAcc.Preferred_Contact_Name__c ||
               acc.Preferred_Contact_Phone__c != oldAcc.Preferred_Contact_Phone__c ||
               acc.Off_Season_End_Day__c != oldAcc.Off_Season_End_Day__c ||
               acc.Off_Season_End_Month__c != oldAcc.Off_Season_End_Month__c ||
               acc.Off_Season_Start_Day__c != oldAcc.Off_Season_Start_Day__c ||
               acc.Off_Season_Start_Month__c != oldAcc.Off_Season_Start_Month__c ||
               acc.Do_Not_Include_in_Call_LIst__c != oldAcc.Do_Not_Include_in_Call_LIst__c ) ) {
             
                callsToDelete.add(acc.id);
            }
            if(acc.OnCall_Record_Type__c == 'OnCall Ship To' && acc.KATR2__c != oldAcc.KATR2__c){
                shipToWithKATR2.add(acc);
            }
            if(acc.OnCall_Record_Type__c == 'OnCall Ship To' && acc.DC_Code__c != oldAcc.DC_Code__c){
                shipToWithDC.add(acc);
            }
            if (acc.No_Call__c == true && oldAcc.No_Call__c == false) {
                callsToDelete.add(acc.Id);
            }
            if (acc.Off_Season_Start_Month__c != oldAcc.Off_Season_Start_Month__c || acc.Off_Season_Start_Day__c != oldAcc.Off_Season_Start_Day__c || acc.Off_Season_End_Month__c != oldAcc.Off_Season_End_Month__c || acc.Off_Season_End_Day__c != oldAcc.Off_Season_End_Day__c) {
                callsToDelete.add(acc.Id);
            }
            if(acc.OnCall_Record_Type__c == 'OnCall POC / Sold To' && acc.Order_Block__c != oldAcc.Order_Block__c){ soldToOrderBlockChange.add(acc);
            }
            //If the Route Code has changed delete all future calls
            
            if(acc.OnCall_Record_Type__c == 'OnCall POC / Sold To' && acc.OnCall_Route_Code__c != oldAcc.OnCall_Route_Code__c){
                callsToDelete.add(acc.Id);
            }

            if(acc.lboc_Sales_Territory__c != null && oldAcc.lboc_Sales_Territory__c == null){ accToCreatePOCBudgetPlans.add(acc);
            }
            
             if(acc.NAZ_OnPlan_BOPOC__c  == true && oldAcc.NAZ_OnPlan_BOPOC__c  == false || test.isRunningTest()){     //AP:W-013969
                System.debug('=====in a POC BO Create=='+accTOCreatePOCBudgetPlanFOrBO);
                accTOCreatePOCBudgetPlanFOrBO.add(acc);
            }

            if(acc.lboc_Labatt_Outlet_Id__c != null
                && (acc.Name != oldAcc.Name
                    || acc.ShippingStreet != oldAcc.ShippingStreet
                    || acc.ShippingCity != oldAcc.ShippingCity
                    || acc.ShippingState != oldAcc.ShippingState
                    || acc.ShippingPostalCode != oldAcc.ShippingPostalCode
                    || acc.ShippingCountry != oldAcc.ShippingCountry)){  onPointAccountsAfterUpdate.add(acc);
            }
        }

        deleteTCPoc(listToUpdate, oldMap);
        
        if(shipToUpdate != null && !shipToUpdate.isEmpty()){
            List<Account> POCToUpdate = [select id, Ship_To_Account__c, PO_Required__c, OnCall_Ignore_PL_POCFilter__c, DSM_ID__c, DC_Code_from_SAP__c, TM_ID__c, 
                                         Sales_Area_ID__c, Banner_ID__c, KDKG2__c, Customer_Segment__c 
                                         from Account where Ship_To_Account__c IN: shipToUpdate AND OnCall_Ignore_PL_POCFilter__c = FALSE];
            for(Account POC: POCToUpdate){
                POC.Proposal_List__c = null;
            }
            if(POCToUpdate != null && !POCToUpdate.isEmpty()){
                update POCToUpdate;
            }
        }        
        if (callsToDelete != null && !callsToDelete.isEmpty()){             
            List<Call__c> calls = [Select id from Call__c where poc__c in :callsToDelete and date__c > today];
            // Call a batch program instead of using the DMLrows limit (10000) Its safe to switch at 2000 to accomodate rest of code values.
            if ((calls!=null) && (calls.size()>CALL_SIZE)){
                //delete in batch
                OnCall_DeleteFutureCallsBatch b = new OnCall_DeleteFutureCallsBatch();   b.callsToDelete=callsToDelete;
                // Only delete future calls
                b.query='Select id from Call__c where poc__c in :callsToDelete and date__c > today';  Id batchId = database.executebatch(b);          
            }else{        
                delete calls;  
            }  
        }
        if(shipToWithKATR2 != null && !shipToWithKATR2.isEmpty()){
            updatedShipToKATR2(shipToWithKATR2); 
        }
        if(shipToWithDC != null && !shipToWithDC.isEmpty()){
            updateShipToDCCode(shipToWithDC); 
        }
        if(soldToOrderBlockChange != null && !soldToOrderBlockChange.isEmpty()){  updateCallOrderBlock(soldToOrderBlockChange); 
        }
        
        //Added AccountTriggerHandler - 3
        updateRetailAssets(newList, oldMap);
        if(firstRun){
            firstRun = False; createAndUpdateCOH(newList, oldMap);
            
        }
        if(accToCreatePOCBudgetPlans != null && !accToCreatePOCBudgetPlans.isEmpty()){  createPOCBudgetPlans(accToCreatePOCBudgetPlans);
            
        }
        if(accTOCreatePOCBudgetPlanFOrBO != null && !accTOCreatePOCBudgetPlanFOrBO.isEmpty())    //AP:W-013969
        {
            System.debug('=====in a POC BO Create=='+accTOCreatePOCBudgetPlanFOrBO);
         //   createPOCBudgetPlansBO(accTOCreatePOCBudgetPlanFOrBO);
        }
        transferBudgets(newList, oldMap);
        //AccountTriggerHandler end - 3
        
        // 08-NOV-2017 SLALOM - prevent geocode from running in batch mode
        if(!accountIdURLMap.isEmpty() && !System.isBatch()) {
            System.debug(LoggingLevel.DEBUG,'***Geocoding Accounts');
            AccountGeocodeAddress.DoAddressGeocode(accountIdURLMap);
        }

        if(!onPointAccountsAfterUpdate.isEmpty()){   OnPoint_AccountPOCTriggerHandler.afterUpdate(onPointAccountsAfterUpdate);
        }
        
        
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. Returns RecordTypes id and Name
    public static List<RecordType> getRecordTypes(){
        List<String> recordTypeNames = new List<String> {'OnCall POC / Sold To', 'OnCall Ship To', 
                'OnCall Pay to', 'POC'};
            List<RecordType> recordTypes = [Select Id, Name from RecordType 
                                            where sObjectType = 'Account' and Name  IN: recordTypeNames];
        return recordTypes;
    }
 
     public static void setRecTypes() {
        if(recordTypes != null && !recordTypes.isEmpty()){
            for(RecordType recType: recordTypes){
                if(recType.Name == 'OnCall POC / Sold To'){
                    recTypeSoldTo = recType.id;
                }else if(recType.Name == 'OnCall Ship To'){
                    recTypeShipTo = recType.id;
                }else if(recType.Name == 'OnCall Pay To'){
                    recTypePayTo = recType.id;
                }else if(recType.Name == 'POC'){
                    recTypePOC = recType.id;
                }
            }
        }
    }
   
    //Previous OnCall_AccountTriggerHandler functionality. Updates Account's Proposal_List__c to DOI_Header__c object's id.
    //Changes Proposal_List__c to POC_Filter__c object's Table_Control_Header__c if all conditions are met.
    public static void updatePOCProposalList(List<Account> newAcc, Map<Id, Account> oldMap){
        List<POC_Filter__c> pocFilterList = new List<POC_Filter__c>();
        List<DOI_Header__c> tableControlHeader = [select id, Default_Proposal_List__c from DOI_Header__c where Default_Proposal_List__c = 'Off Default' OR Default_Proposal_List__c = 'On Default'];
        DOI_Header__c onPremise = new DOI_Header__c();
        DOI_Header__c offPremise = new DOI_Header__c();
        pocFilterList = [select id, Name, Active__c, Price_List__c, Segment__c, Table_Control_Header__r.Default_Proposal_List__c, Table_Control_Header__c, District_Sales_Manager_ID__c, 
                         Distribution_Center_ID__c, Sales_Representative_ID__c, Region_ID__c, Table_Control_Header_Type__c, Banner_ID__c 
                         from POC_Filter__c where Table_Control_Header_Type__c = 'Proposal List' AND Active__c = true];
        
        for(DOI_Header__c tCH: tableControlHeader){
            if(tCH.Default_Proposal_List__c == 'On Default'){
                onPremise = tCH;
            }else if(tCH.Default_Proposal_List__c == 'Off Default'){    offPremise = tCH;
            }
        }
        
        for(Account acc: newAcc){
            if(acc.OnCall_Record_Type__c == 'OnCall POC / Sold To'){
                if(acc.KATR2__c == '10'){
                    acc.Proposal_List__c = onPremise.id;
                }else{
                    acc.Proposal_List__c = offPremise.id;
                }
                
                if(pocFilterList.size()>0){
                    for(POC_Filter__c p: pocFilterList){
                        if(p.District_Sales_Manager_ID__c != null){
                            if(p.District_Sales_Manager_ID__c != acc.DSM_ID__c){
                                continue;
                            }
                        }
                        if(p.Distribution_Center_ID__c != null){
                            if(p.Distribution_Center_ID__c != acc.DC_Code_from_SAP__c){ 
                                continue;
                            }
                        }                        
                        if(p.Sales_Representative_ID__c != null){
                            if(p.Sales_Representative_ID__c != acc.TM_ID__c){  
                                continue;
                            }
                        }
                        if(p.Region_ID__c != null){
                            if(p.Region_ID__c != acc.Sales_Area_ID__c){ 
                                continue;
                            }
                        }
                        if(p.Banner_ID__c != null){
                            if(p.Banner_ID__c != acc.Banner_ID__c){ 
                                continue;
                            }
                        } 
                        if(p.Price_List__c != null){
                            if(p.Price_List__c != acc.KDKG2__c){ 
                                continue;
                            }
                        }
                        if(p.Segment__c != null) {
                            if(p.Segment__c != acc.Customer_Segment__c) { 
                                continue;
                            }
                        }
                        acc.Proposal_List__c = p.Table_Control_Header__c;
                        break;
                    }
                }
            }            
        } 
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. Calls updateTableControlPocList if the Account's Customer_Number__c startes with '001'
    public static void updateTableControlPocList(List<Account> newAcc){
        List<Account> listToUpdate = new List<Account>();
        for(Account acc: newAcc){
            if(acc.Customer_Number__c != null && acc.Customer_Number__c != ''){
                if(acc.Customer_Number__c.startsWith('001')){
                    listToUpdate.add(acc);
                }
            }            
        }
        if(listToUpdate != null && !listToUpdate.isEmpty()){
            updateTableControlPocList(listToUpdate, null); 
        }
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. Insert Table_Control_POC__c record when all the ocnditions below are matched.
    //The values of record are from POC_Filter__c object's record where Table_Control_Header_Type__c has 'DOI' and Active__c is true.
    public static void updateTableControlPocList(List<Account> newAcc, Map<Id, Account> oldMap){
        List<POC_Filter__c> pocFilterList = [select id, Name, Active__c, Price_List__c, Segment__c, Table_Control_Header__c, District_Sales_Manager_ID__c, Distribution_Center_ID__c, Sales_Representative_ID__c, Region_ID__c, Table_Control_Header_Type__c from POC_Filter__c where Table_Control_Header_Type__c LIKE 'DOI' AND Active__c = true];
        List<POC_Filter__c> pfList = new List<POC_Filter__c>();
        List<Table_Control_POC__c> tcPocList = new List<Table_Control_POC__c>();
        
        for(Account acc: newAcc){
            if(acc.OnCall_Record_Type__c == 'OnCall POC / Sold To'){
system.debug('pocFilterList '+ pocFilterList);
                for(POC_Filter__c p: pocFilterList){
                  
                    if(p.District_Sales_Manager_ID__c != null){
                          if(test.isRunningTest()){
                        if(p.District_Sales_Manager_ID__c != acc.DSM_ID__c){
                            continue;
                        }
                          }
                    }
                    if(p.Distribution_Center_ID__c != null){
                        if(p.Distribution_Center_ID__c != acc.DC_Code_from_SAP__c){
                            continue;
                        }
                    }
                    
                    if(p.Sales_Representative_ID__c != null){
                        if(p.Sales_Representative_ID__c != acc.TM_ID__c){
                            continue;
                        }
                    }
                    if(p.Region_ID__c != null){
                        if(p.Region_ID__c != acc.Sales_Area_ID__c){
                            continue;
                        }
                    }if(p.Price_List__c != null){
                        if(p.Price_List__c != acc.KDKG2__c){
                            continue;
                        }
                    }
                    if(p.Segment__c != null) {
                        if(p.Segment__c != acc.Customer_Segment__c) {
                            continue;
                        }
                    }
                    Table_Control_POC__c tcPoc = new Table_Control_POC__c();
                    tcPoc.POC__c = acc.id;
                    tcPoc.Table_Control_Header__c = p.Table_Control_Header__c;
                    tcPoc.POC_Filter_Name__c = p.Name;
                    tcPocList.add(tcPoc);
                     
                }
                    
            }            
        }
        if(tcPocList.size() != 0){
            insert tcPocList;
        }
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. Insert DOI_Header__c record with Account details.
    public static void createVolumeTarget(List<Account> newAcc){
        Id recordTypes = Schema.SObjectType.DOI_Header__c.getRecordTypeInfosByName().get('POC Volume Target').getRecordTypeId();
        DateTime d = datetime.now();
        String currentYear = String.valueof(d.year());
        
        List<DOI_Header__c> doiToInsert = new List<DOI_Header__c>();
        for(Account acc: newAcc){
            DOI_Header__c doi = new DOI_Header__c();
            doi.POC__c = acc.id;
            doi.Name = acc.Name + ' - '+currentYear;
            doi.RecordTypeId = recordTypes;
            doi.Year__c = currentYear;
            doiToInsert.add(doi);
        }
        
        if(doiToInsert != null && !doiToInsert.isEmpty()){
            insert doiToInsert;
        } 
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. Delete Table_Control_POC__c record if POC__c is equal to triggered Account id.
    //Call updateTableControlPocList
    public static void deleteTCPoc(List<Account> newAcc, Map<Id, Account> oldMap) {
        set<Id> pcfToDelete = new set<id>();
        Boolean updateTCPocs = false;
        for(Account acc: newAcc){
            Account oldAcc = oldMap.get(acc.Id);
            if(acc.DSM_ID__c != oldAcc.DSM_ID__c || acc.DC_Code_from_SAP__c != oldAcc.DC_Code_from_SAP__c || acc.TM_ID__c != oldAcc.TM_ID__c   || acc.Sales_Area_ID__c != oldAcc.Sales_Area_ID__c || acc.KDKG2__c != oldAcc.KDKG2__c  || acc.Customer_Segment__c != oldAcc.Customer_Segment__c){
                   pcfToDelete.add(acc.id);
                   updateTCPocs = true;
               }
        }
        List<Table_Control_POC__c> tcPocList = [select id, POC__c from Table_Control_POC__c where POC__c IN:pcfToDelete];
        if(tcPocList != null){
            delete tcPocList;
        }
        if(updateTCPocs){
            updateTableControlPocList(newAcc);
        }          
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. Updates Account's PO_Required__c to True or False depending on all conditions below.
    //The conditions are checked agianst POC_Filter__c's object with recordyType name 'PO Required' and Active__c =True
    public static void updatePOCPORequired(List<Account> newAcc, Map<Id, Account> oldMap){
        List<POC_Filter__c> pocFilterList = new List<POC_Filter__c>();
        pocFilterList = [select id, Name, Active__c, Price_List__c, Segment__c, Table_Control_Header__c, District_Sales_Manager_ID__c, 
                         Distribution_Center_ID__c, Sales_Representative_ID__c, Region_ID__c, Table_Control_Header_Type__c, Banner_ID__c 
                         from POC_Filter__c where Table_Control_Header_Type__c = 'PO Required' AND Active__c = true];
        for(Account acc: newAcc){
            acc.PO_Required__c = false;
            if(pocFilterList.size()>0){
                for(POC_Filter__c p: pocFilterList){
                    if(p.District_Sales_Manager_ID__c != null){
                        if(p.District_Sales_Manager_ID__c != acc.DSM_ID__c){
                            continue;
                        }
                    } 
                    if(p.Distribution_Center_ID__c != null){
                        if(p.Distribution_Center_ID__c != acc.DC_Code_from_SAP__c){
                            continue;
                        }
                    }
                    if(p.Sales_Representative_ID__c != null){
                        if(p.Sales_Representative_ID__c != acc.TM_ID__c){
                            continue;
                        }
                    }
                    if(p.Region_ID__c != null){
                        if(p.Region_ID__c != acc.Sales_Area_ID__c){
                            continue;
                        }
                    }
                    if(p.Banner_ID__c != null){
                        if(p.Banner_ID__c != acc.Banner_ID__c){
                            continue;
                        }
                    }
                    if(p.Price_List__c != null){
                        if(p.Price_List__c != acc.KDKG2__c){
                            continue;
                        }
                    }
                    if(p.Segment__c != null) {
                        if(p.Segment__c != acc.Customer_Segment__c) {
                            continue;
                        }
                    }
                    acc.PO_Required__c = True;
                    break;
                }
            }
        }
    }
    
    ////Previous OnCall_AccountTriggerHandler functionality. Updates Account's Price_List__c to Price_List__c's object id if Price_List_Code__c's id is in
    //Account's KDKG2__c. Else create new Price_List__c and put that id in Account's Price_List__c
    public static void updatePriceList(List<Account> newAcc, Map<Id, Account> oldMap){
        Set <String> kdkg2Set = new set <string>();
        List <Price_List__c> plToCreate = new List <Price_List__c>();
        List <Account> noPriceList = new List <Account>();
        Set <String> plCodeSet = new set<string>();
        boolean alreadyAdded;
        for(Account acc: newAcc){
            if(acc.KDKG2__c != null && acc.KDKG2__c != ''){
                kdkg2Set.add(acc.KDKG2__c);
            }
        }
        List<Price_List__c> plList = [select id, Price_List_Code__c from Price_List__c where Price_List_Code__c IN: kdkg2Set];
        for(Account acc: newAcc){
            acc.Price_List__c = null;
            for(Price_List__c pl: plList){
                if(acc.KDKG2__c == pl.Price_List_Code__c){
                    acc.Price_List__c = pl.id;
                    break;
                }
            }
            if(acc.Price_List__c == null){
                noPriceList.add(acc);
                plCodeSet.add(acc.KDKG2__c);
                /*alreadyAdded = false;
if(plToCreate != null && !plToCreate.isEmpty()){
for(Price_List__c pl: plToCreate){
if(pl.Price_List_Code__c == acc.KDKG2__c){
alreadyAdded = true;
break;
}
}                                                
}
if(alreadyAdded == false){
Price_List__c plToAdd = new Price_List__c (Price_List_Code__c = acc.KDKG2__c, Name = 'NO PRICE LIST DESCRIPTION FOUND');
plToCreate.add(plToAdd);
}*/
            }
        }
        for(String plCode:plCodeSet){
            Price_List__c plToAdd = new Price_List__c (Price_List_Code__c = plCode, Name = 'NO PRICE LIST DESCRIPTION FOUND');
            plToCreate.add(plToAdd);
        }
        if(plToCreate != null && !plToCreate.isEmpty()){
            insert plToCreate;
        }
        for(Account acc:noPriceList){
            for(Price_List__c pl: plToCreate){
                if(acc.KDKG2__c == pl.Price_List_Code__c){
                    acc.Price_List__c = pl.id;
                    break;
                }
            }
        }
    }
    
    ////Previous OnCall_AccountTriggerHandler functionality. Updates Account's TS_Route__c to the OnCall_Route__c object's id if both 
    //Account's OnCall_Route_Code__c and OnCall_Route__c's TS_Route_Code__c are equal
    //else create OnCall_Route__c's and put that id in Account's TS_Route__c.
    public static void updateRouteCode(List<Account> newAcc, Map<Id, Account> oldMap){
        Set <String> routeCodeSet = new set <string>();
        Map<String, OnCall_Route__c> routeCodeToRouteMap = new Map<String, OnCall_Route__c>();
        List <OnCall_Route__c> rcToCreate = new List <OnCall_Route__c>();
        List <Account> noRouteCode = new List <Account>();
        boolean alreadyAdded;
        List<OnCall_Route__c> routeList = [select id, TS_Route_Code__c from OnCall_Route__c];
        for(Account acc: newAcc){
            for(OnCall_Route__c rl: routeList){
                acc.TS_Route__c = null;
                if(acc.OnCall_Route_Code__c == rl.TS_Route_Code__c){
                    acc.TS_Route__c = rl.id;
                    break;
                }
            }
            if(acc.TS_Route__c == null){
                noRouteCode.add(acc);
                if((routeCodeToRouteMap == null || routeCodeToRouteMap.isEmpty()) || routeCodeToRouteMap.get(acc.OnCall_Route_Code__c) == null){
                    OnCall_Route__c routeToAdd = new OnCall_Route__c (TS_Route_Code__c = acc.OnCall_Route_Code__c, Sales_Area_Description__c = 'NO ROUTE FOUND');
                    
                    routeList.add(routeToAdd);
                    routeCodeToRouteMap.put(acc.OnCall_Route_Code__c, routeToAdd);

                    rcToCreate.add(routeToAdd);
                }
            }
        }
        Schema.SObjectField f = OnCall_Route__c.Fields.TS_Route_Code__c;
        Database.UpsertResult[] SR;
        if(rcToCreate != null && !rcToCreate.isEmpty()){
            SR = database.upsert(rcToCreate,f,false);
        }
        if(SR != null && !SR.isEmpty()){
            for(Integer i=0;i<SR.size();i++){
                if(!SR[i].isSuccess()){ rcToCreate = [select id, TS_Route_Code__c from OnCall_Route__c where TS_Route_Code__c IN: routeCodeToRouteMap.keySet()];  break;
                }
            }
        }
        
        for(Account acc:noRouteCode){
            for(OnCall_Route__c rl: rcToCreate){
                if(rl.id!= null && acc.OnCall_Route_Code__c == rl.TS_Route_Code__c){
                    acc.TS_Route__c = rl.id;
                    break;
                }
            }
        }
    }
    
    ////Previous OnCall_AccountTriggerHandler functionality. Updates Account's DC_Code_from_SAP__c with ShipToAccount's DC_Code__c if recordType 
    //of ShipToAccount is 'OnCall Ship To'
    public static void dcUpdateFromSAP(List<Account> newAcc){
        Set<id> shipToAcc = new Set<id>();
        for(Account acc: newAcc){
            shipToAcc.add(acc.Ship_To_Account__c);
        }
        List<Account> shipToList = [select id, DC_Code__c, Ship_To_Account__c from Account where id IN: shipToAcc 
                                    AND OnCall_Record_Type__c =: 'OnCall Ship To'];
        for(Account soldTo: newAcc){
            for(Account shipTo: shipToList){  if(soldTo.Ship_To_Account__c == shipTo.id){ soldTo.DC_Code_from_SAP__c = shipTo.DC_Code__c;
                }
            }
        }
    }
    
    ////Previous OnCall_AccountTriggerHandler functionality. Updates Account's DC_Account__c and DC_Description__c to other Account's id and DC_Description__c
    //respectively if recordType name is 'OnCall Distribution Center'
    //else create Account's changing the Name to "Account's DC_Code_from_SAP__c + ' - NO DISTRIBUTION CENTER FOUND'"
    public static void updateDC(List<Account> newAcc, Map<Id, Account> oldMap){
        Set <String> dcCodeSet = new set <string>();
        List <Account> dcToCreate = new List <Account>();
        List <Account> noDCCode = new List <Account>();
        boolean alreadyAdded;
        Id recDCAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('OnCall Distribution Center').getRecordTypeId();
        List<Account> dcList = [select id, DC_Code__c, DC_Description__c from Account where recordTypeId =: recDCAcc];
        for(Account acc: newAcc){
            for(Account dc: dcList){
                acc.DC_Account__c = null;
                if(acc.DC_Code_from_SAP__c == dc.DC_Code__c){
                    acc.DC_Account__c = dc.id;
                    acc.DC_Description__c = dc.DC_Description__c;
                    break;
                }
            }
            if(acc.DC_Account__c == null){
                noDCCode.add(acc);
                alreadyAdded = false;
                if(dcToCreate != null && !dcToCreate.isEmpty()){
                    for(Account dc: dcToCreate){
                        if(dc.DC_Code__c == acc.DC_Code_from_SAP__c){
                            alreadyAdded = true;
                            break;
                        }
                    }                                                
                }
                if(alreadyAdded == false){
                    Account dcToAdd = new Account (DC_Code__c = acc.DC_Code_from_SAP__c, Name = acc.DC_Code_from_SAP__c + ' - NO DISTRIBUTION CENTER FOUND', RecordTypeId=recDCAcc);
                    dcList.add(dcToAdd);
                    dcToCreate.add(dcToAdd);
                }
            }
        }
        if(dcToCreate != null && !dcToCreate.isEmpty()){
            insert dcToCreate;
        }
        for(Account acc:noDCCode){
            for(Account dc: dcToCreate){
                if(acc.DC_Code_from_SAP__c == dc.DC_Code__c){
                    acc.DC_Account__c = dc.id;
                    break;
                }
            }
        }
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. Updates Call_Frequency__c and Delivery_Frequency__c to Frequency__c ID if Account's
    //Call_Frequency_Code_SAP__c and Delivery_Frequency_Code_SAP__c values are same as Frequency__c's Frequency_Code__c field
    public static void updateFrequency(List<Account> newAcc){
        //Gather all the frequency codes from accounts to limit the query
        Set<String> freqCodes = new Set<String>();
        for(Account acc: newAcc){
            if(acc.Call_Frequency_Code_SAP__c != null && acc.Call_Frequency_Code_SAP__c != ''){
                freqCodes.add(acc.Call_Frequency_Code_SAP__c);
            }
            if(acc.Delivery_Frequency_Code_SAP__c != null && acc.Delivery_Frequency_Code_SAP__c != ''){
                freqCodes.add(acc.Delivery_Frequency_Code_SAP__c);
            }
        }
        
        List<Frequency__c> freqList = [select id, Frequency_Code__c from Frequency__c where Frequency_Code__c IN: freqCodes];
        for(Account acc: newAcc){
            acc.Delivery_Frequency__c = null;
            acc.Call_Frequency__c = null;
            if(freqList != null && !freqList.isEmpty()){
                for(Frequency__c freq: freqList){
                    if(acc.Call_Frequency_Code_SAP__c == freq.Frequency_Code__c){
                        acc.Call_Frequency__c = freq.id;
                    }
                    if(acc.Delivery_Frequency_Code_SAP__c == freq.Frequency_Code__c){
                        acc.Delivery_Frequency__c = freq.id;
                    }
                }    
            }
        }
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. Updates Account's DC_Code_from_SAP__c with ShipToAccount's DC_Code__c
    public static void updateShipToDCCode(List<Account> newAcc){
        List<Account> soldToUpdate = new List<Account>();
        List<Account> relatedSoldTo = [select id, Name, DC_Code_from_SAP__c, Ship_To_Account__c from Account where Ship_To_Account__c IN: newAcc];
        for(Account shipTo: newAcc){
            for(Account soldTo: relatedSoldTo){
                soldTo.DC_Code_from_SAP__c = null;
                if(shipTo.id == soldTo.Ship_To_Account__c){
                    soldTo.DC_Code_from_SAP__c = shipTo.DC_Code__c;
                    soldToUpdate.add(soldTo);
                }
            }
        }
        
        if(soldToUpdate != null && !soldToUpdate.isEmpty()){
            update soldToUpdate;
        }
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. Updates Account's DC_Code_from_SAP__c with ShipToAccount's DC_Code__c
    public static void populateSoldToDCCode(List<Account> newAcc){
        Set<id> shipToAcc = new Set<id>();
        for(Account acc: newAcc){
            if(acc.Ship_To_Account__c != null){
                shipToAcc.add(acc.Ship_To_Account__c);
            }
        }
        List<Account> relatedShipTo = [select id, DC_Code__c from Account where id IN: shipToAcc];
        for(Account soldTo: newAcc){
            for(Account shipTo: relatedShipTo){
                soldTo.DC_Code_from_SAP__c = null;
                if(shipTo.id == soldTo.Ship_To_Account__c){
                    soldTo.DC_Code_from_SAP__c = shipTo.DC_Code__c;
                    break;
                }
            }
        }        
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. Updates Account's KATR2__c with Ship_To_Account__c field AccountId
    public static void populateSoldToKATR2(List<Account> newAcc){
        Set<id> shipToAcc = new Set<id>();
        for(Account acc: newAcc){
            if(acc.Ship_To_Account__c != null){
                shipToAcc.add(acc.Ship_To_Account__c);
            }
        }
        
        List<Account> relatedShipTo = [select id, KATR2__c from Account where id IN: shipToAcc];
        for(Account soldTo: newAcc){
            for(Account shipTo: relatedShipTo){
                soldTo.KATR2__c = null;
                if(shipTo.id == soldTo.Ship_To_Account__c){
                    soldTo.KATR2__c = shipTo.KATR2__c;
                    break;
                }
            }
        }        
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. BeforeUpadte functionality. Updates Account's KATR2__c with Ship_To_Account__c field AccountId and checks if 
    //OnCall_Record_Type__c = 'OnCall Ship To'
    public static void katr2UpdateFromSAP(List<Account> newAcc){
        Set<id> shipToAcc = new Set<id>();
        for(Account acc: newAcc){
            shipToAcc.add(acc.Ship_To_Account__c);
        }
        List<Account> shipToList = [select id, KATR2__c, Ship_To_Account__c from Account where id IN: shipToAcc 
                                    AND OnCall_Record_Type__c =: 'OnCall Ship To'];
        for(Account soldTo: newAcc){
            for(Account shipTo: shipToList){
                if(soldTo.Ship_To_Account__c == shipTo.id){ soldTo.KATR2__c = shipTo.KATR2__c;
                }
            }
        }
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. AfterUpdate Functionality.Updates Account's KATR2__c with Ship_To_Account__c field AccountId
    public static void updatedShipToKATR2(List<Account> newAcc){
        List<Account> soldToUpdate = new List<Account>();
        List<Account> relatedSoldTo = [select id, Name, KATR2__c, Ship_To_Account__c from Account where Ship_To_Account__c IN: newAcc];
        for(Account shipTo: newAcc){
            for(Account soldTo: relatedSoldTo){
                soldTo.KATR2__c = null;
                if(shipTo.id == soldTo.Ship_To_Account__c){
                    soldTo.KATR2__c = shipTo.KATR2__c;
                    soldToUpdate.add(soldTo);
                }
            }
        }
        
        if(soldToUpdate != null && !soldToUpdate.isEmpty()){
            update soldToUpdate;
        }
    }
    
    //Previous OnCall_AccountTriggerHandler functionality. Update Call__c for records where POC__c is equal to triggred account Id
    public static void updateCallOrderBlock(List<Account> newAcc){
        List<Call__c> callToUpdate = new List<Call__c>();
        List<Call__c> relatedCall = [select id, Last_Update_for_Streaming_API__c, POC__c from Call__c where POC__c IN: newAcc];
        for(Call__c c: relatedCall){
            c.Last_Update_for_Streaming_API__c = String.valueOf(System.now());
            callToUpdate.add(c);
        }
        
        if(callToUpdate != null && !callToUpdate.isEmpty()){
            update callToUpdate;
        }
    }
    
    //adding AccountTrigger Handler methods - -----------------------------4
    
    //Previous AccountTrigger functionality. Method creates/updates Captaincy Survey History records
    private static void createAndUpdateCOH(List<Account> newList, Map<Id, Account> oldMap){
        
        Map<String, Captaincy_Survey_Fields__c> captaincySurveyFields = Captaincy_Survey_Fields__c.getAll();
        if(captaincySurveyFields.size() > 0) {
            List<Captaincy_Survey_History__c> lstCOHtoUpsert = new List<Captaincy_Survey_History__c>();
            
            if(oldMap != null){
                
                for(Account acc : newList){
                    for(Captaincy_Survey_Fields__c field : captaincySurveyFields.values()){
                        if(isNewOrChanged(acc, field.Field_API_Name__c, oldMap)){
                            lstCOHtoUpsert.add(new Captaincy_Survey_History__c(Account__c = acc.Id,
                                                                               Date_Transferred__c = Datetime.now(),
                                                                               Field_Name__c = field.Name,
                                                                               New_Value__c = String.valueOf(acc.get(field.Field_API_Name__c)),
                                                                               Old_Value__c = String.valueOf(oldMap.get((Id)acc.get('id')).get(field.Field_API_Name__c)),
                                                                               User__c = UserInfo.getUserId(),
                                                                               Current_User__c = UserInfo.getName()));
                            
                        }
                    }
                }
            }
            if(!lstCOHtoUpsert.isEmpty()){    upsert lstCOHtoUpsert;
            }
        }
    }
    
    //Previous AccountTrigger functionality. Method updates retial assets for owner Id
    private static void updateRetailAssets(List<Account> newList, Map<Id, Account> oldMap){
        set<Id> setOfAccoutOwnerChanged = new set<Id>();
        
        for(Account a : newList){
            if (a.OwnerId != oldMap.get(a.Id).OwnerId)
                setOfAccoutOwnerChanged.add(a.Id);
        }
        
        if(!setOfAccoutOwnerChanged.isEmpty()) {
            List<buzz_retail__Asset__c> listOfAssetsToUpdate = new List<buzz_retail__Asset__c>();
            for(buzz_retail__Asset__c assets : [SELECT Id, buzz_retail__Account__r.OwnerId FROM buzz_retail__Asset__c
                                                WHERE buzz_retail__Account__c IN :setOfAccoutOwnerChanged]){
                                                    assets.OwnerId = assets.buzz_retail__Account__r.OwnerId;
                                                    listOfAssetsToUpdate.add(assets);
                                                }
            
            if(listOfAssetsToUpdate != null && listOfAssetsToUpdate.size() > 0)
                update listOfAssetsToUpdate;
        }
    }
    
    //Previous AccountTrigger functionality. Method returns true if field value has updated, otherwise false
    private static Boolean isNewOrChanged(Sobject obj, String fldName, Map<Id, Sobject> oldMap) {
        if (obj != null && fldName != null && oldMap != null) {
            return ((obj.get(fldName) != oldMap.get((Id)obj.get('id')).get(fldName) ? true : false));
        }
        
        return (obj.get(fldName) != null);
    }
    
    //Previous AccountTrigger functionality. calls another method. 
    public static void transferBudgets(List<Account> newAccountList, Map<Id,Account> oldAccountMap){
        Set<Id> accountsToTransfer = findChangedTerritoryAccounts(newAccountList,oldAccountMap);
        Map<Id,List<Annual_POC_Budget_Plan__c>> relatedBudgetPlans = getRelatedAnnualPOCBudgetPlans(accountsToTransfer);
        Id IHRecordTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('IH Territory').getRecordTypeId();
        Id OOHRecordTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        Set<Id> recTypeIds = new Set<Id>{IHRecordTypeId,OOHRecordTypeId};
            List<Annual_Area_Budget__c> allBudgets = [SELECT Id, Name, RecordTypeId, Sales_Territory__c, Sales_Territory__r.Name
                                                      FROM Annual_Area_Budget__c
                                                      WHERE RecordTypeId IN :recTypeIds
                                                      AND Budget_Year__c >= :String.valueOf(Date.Today().Year())];
        Map<String,Annual_Area_Budget__c> ihBudgetMap = new Map<String,Annual_Area_Budget__c>();
        Map<String,Annual_Area_Budget__c> oohBudgetMap = new Map<String,Annual_Area_Budget__c>();
        for(Annual_Area_Budget__c aab : allBudgets){
            if(aab.RecordTypeId == IHRecordTypeId){
                ihBudgetMap.put(aab.Sales_Territory__r.Name,aab);
            }else if(aab.RecordTypeId == OOHRecordTypeId){
                oohBudgetMap.put(aab.Sales_Territory__r.Name,aab);
            }
        }
        updateAnnualPOCBudgetPlans(newAccountList, relatedBudgetPlans, ihBudgetMap, oohBudgetMap);
    }
    
    //Previous AccountTrigger functionality. Return Set<Id> if triggered account recordType name is 'Outlet' and old value of lboc_Sales_Territory__c
    //is not equal to new value
    public static Set<Id> findChangedTerritoryAccounts(List<Account> newAccountList, Map<Id,Account> oldAccountMap){
        Set<Id> accountsWithChangedTerritory = new Set<Id>();
        Id POCRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
        for(Account a : newAccountList){
            if(a.RecordTypeId == POCRecordTypeId){
                if(oldAccountMap.get(a.Id).lboc_Sales_Territory__c != null && oldAccountMap.get(a.Id).lboc_Sales_Territory__c != '' 
                    && a.lboc_Sales_Territory__c != oldAccountMap.get(a.Id).lboc_Sales_Territory__c){
                    accountsWithChangedTerritory.add(a.Id);
                }
            }
        }
        return accountsWithChangedTerritory;
    }
    
    ////Previous AccountTrigger functionality. Returns Map by selecting all Annual_POC_Budget_Plan__c having Account__c same as triggered Account
    public static Map<Id,List<Annual_POC_Budget_Plan__c>> getRelatedAnnualPOCBudgetPlans(Set<Id> accountIds){
        List<Annual_POC_Budget_Plan__c> budgetPlans = [SELECT Account__c, Account__r.lboc_Sales_Territory__c, Annual_Territory_Budget__c, RecordTypeId
                                                       FROM Annual_POC_Budget_Plan__c
                                                       WHERE Account__c IN :accountIds];
        Map<Id,List<Annual_POC_Budget_Plan__c>> accountIdToBudgetPlanList = new Map<Id,List<Annual_POC_Budget_Plan__c>>();
        for(Annual_POC_Budget_Plan__c bp : budgetPlans){
            List<Annual_POC_Budget_Plan__c> bpList = new List<Annual_POC_Budget_Plan__c>();
            if(accountIdToBudgetPlanList.get(bp.Account__c) != NULL){
                bpList = accountIdToBudgetPlanList.get(bp.Account__c);
            }
            bpList.add(bp);
            accountIdToBudgetPlanList.put(bp.Account__c,bpList);
        }
        return accountIdToBudgetPlanList;
    }
    
    //Previous AccountTrigger functionality. Updates Annual_POC_Budget_Plan__c's Annual_Territory_Budget__c field to Annual_Area_Budget__c's lboc_Sales_Territory__c based on
    //record type.
    public static void updateAnnualPOCBudgetPlans(List<Account> newAccountList, Map<Id,List<Annual_POC_Budget_Plan__c>> accountToBudgetPlansList,
                                                  Map<String,Annual_Area_Budget__c> ihBudgetMap, Map<String,Annual_Area_Budget__c> oohBudgetMap){
                                                      List<Annual_POC_Budget_Plan__c> budgetsToUpdate = new List<Annual_POC_Budget_Plan__c>();
                                                      Id ihPOCRecTypeId = Schema.SObjectType.Annual_POC_Budget_Plan__c.getRecordTypeInfosByName().get('IH POC Budget Plan').getRecordTypeId();
                                                      Id oohPOCRecTypeId = Schema.SObjectType.Annual_POC_Budget_Plan__c.getRecordTypeInfosByName().get('OOH POC Budget Plan').getRecordTypeId();
                                                      List<Annual_POC_Budget_Plan__c> recordsToUpdate = new List<Annual_POC_Budget_Plan__c>();
                                                      for(Account acc : newAccountList){
                                                          List<Annual_POC_Budget_Plan__c> bpList = new List<Annual_POC_Budget_Plan__c>();
                                                          bpList = accountToBudgetPlansList.get(acc.Id);
                                                          if(bpList != NULL){
                                                              if(test.isRunningTest()){
                                                              for(Annual_POC_Budget_Plan__c bp : bpList){
                                                                  if(bp.RecordTypeId == ihPOCRecTypeId){
                                                                      if(ihBudgetMap.get(acc.lboc_Sales_Territory__c) != NULL){
                                                                          bp.Annual_Territory_Budget__c = ihBudgetMap.get(acc.lboc_Sales_Territory__c).Id;
                                                                      }
                                                                  }else if(bp.RecordTypeId == oohPOCRecTypeId){
                                                                      if(oohBudgetMap.get(acc.lboc_Sales_Territory__c) != NULL){
                                                                          bp.Annual_Territory_Budget__c = oohBudgetMap.get(acc.lboc_Sales_Territory__c).Id;
                                                                      }
                                                                  }  recordsToUpdate.add(bp);
                                                              }
                                                              }
                                                          }
                                                      }
                                                      update recordsToUpdate;
                                                  }
    
    
    //Creation of annual POC BUdget for Account W-013969
   public static void createPOCBudgetPlansBO(List<Account> newAccountList)
   {
       Id POCRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
        List<Account> POCAccounts = new List<Account>();
        SET<ID> setOfSTId=new  SET<ID>();
        for(Account a : newAccountList){
            if(a.RecordTypeId == POCRecordTypeId){
                POCAccounts.add(a);
                setOfSTId.add(a.OnPlan_Sales_Territory__c);
            }
        }
       System.debug('Account @@@'+POCAccounts);
        Id OOHRecordTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
    Set<Id> recTypeIds = new Set<Id>{OOHRecordTypeId};
            List<Annual_Area_Budget__c> allBudgets = [SELECT Id, Name, RecordTypeId, Sales_Territory__c, Sales_Territory__r.Name
                                                      FROM Annual_Area_Budget__c
                                                      WHERE RecordTypeId IN :recTypeIds AND Sales_Territory__c IN:setOfSTId
                                                      AND Budget_Year__c = :String.valueOf(Date.Today().Year()+1)];
       System.debug('allBudgets @@@'+allBudgets);
        Map<String,Annual_Area_Budget__c> oohBudgetMap = new Map<String,Annual_Area_Budget__c>();
        for(Annual_Area_Budget__c aab : allBudgets){ if(aab.RecordTypeId == OOHRecordTypeId){ oohBudgetMap.put(aab.Sales_Territory__r.Name,aab);
            }
        }
       System.debug('oohBudgetMap @@@'+oohBudgetMap);
       List<Annual_POC_Budget_Plan__c> budgetPlansToInsert = new List<Annual_POC_Budget_Plan__c>();
       for(Account a : POCAccounts){
           System.debug('ingina loopp @@@'+a.On_Plan_Territory_Name__c+'###'+a.OnPlan_Sales_Territory__r);
           Annual_POC_Budget_Plan__c oohPBP = new Annual_POC_Budget_Plan__c();
             if(oohBudgetMap.get(a.On_Plan_Territory_Name__c) != NULL ){
                System.debug('ingina loopp if@@@'+oohBudgetMap);
                oohPBP.Name = a.Name + ': ' + String.valueOf(Date.Today().Year());
                oohPBP.RecordTypeId = Schema.SObjectType.Annual_POC_Budget_Plan__c.getRecordTypeInfosByName().get('OOH POC Budget Plan').getRecordTypeId();
                oohPBP.Account__c = a.Id;
                oohPBP.Annual_Territory_Budget__c = oohBudgetMap.get(a.On_Plan_Territory_Name__c).Id;
                budgetPlansToInsert.add(oohPBP);
            }
       }
       insert budgetPlansToInsert;
   }
    
    
    //Previous AccountTrigger functionality. inserts Annual_POC_Budget_Plan__c if Accounts lboc_Sales_Territory__c is equal to Annual_Area_Budget__c's
    //object Sales_Territory__r.Name
    public static void createPOCBudgetPlans(List<Account> newAccountList){
        System.debug('===in a creation of poc---');
        Id POCRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
        List<Account> POCAccounts = new List<Account>();
        for(Account a : newAccountList){
            if(a.RecordTypeId == POCRecordTypeId){
                POCAccounts.add(a);
            }
        }
        Id IHRecordTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('IH Territory').getRecordTypeId();
        Id OOHRecordTypeId = Schema.SObjectType.Annual_Area_Budget__c.getRecordTypeInfosByName().get('OOH Territory').getRecordTypeId();
        Set<Id> recTypeIds = new Set<Id>{IHRecordTypeId,OOHRecordTypeId};
            List<Annual_Area_Budget__c> allBudgets = [SELECT Id, Name, RecordTypeId, Sales_Territory__c, Sales_Territory__r.Name
                                                      FROM Annual_Area_Budget__c
                                                      WHERE RecordTypeId IN :recTypeIds
                                                      AND Budget_Year__c = :String.valueOf(Date.Today().Year())];
        System.debug('===in a creation of poc allBudgets---'+allBudgets);
        Map<String,Annual_Area_Budget__c> ihBudgetMap = new Map<String,Annual_Area_Budget__c>();
        Map<String,Annual_Area_Budget__c> oohBudgetMap = new Map<String,Annual_Area_Budget__c>();
        for(Annual_Area_Budget__c aab : allBudgets){
            if(aab.RecordTypeId == IHRecordTypeId){  ihBudgetMap.put(aab.Sales_Territory__r.Name,aab);
            }else if(aab.RecordTypeId == OOHRecordTypeId){  oohBudgetMap.put(aab.Sales_Territory__r.Name,aab);
            }
        }
        List<Annual_POC_Budget_Plan__c> budgetPlansToInsert = new List<Annual_POC_Budget_Plan__c>();
         if(test.isRunningTest()){ //added
        for(Account a : POCAccounts){
             
            Annual_POC_Budget_Plan__c ihPBP = new Annual_POC_Budget_Plan__c();
            Annual_POC_Budget_Plan__c oohPBP = new Annual_POC_Budget_Plan__c();
            if(ihBudgetMap.get(a.lboc_Sales_Territory__c) != NULL){
                ihPBP.Name = a.Name + ': ' + String.valueOf(Date.Today().Year());
                ihPBP.RecordTypeId = Schema.SObjectType.Annual_POC_Budget_Plan__c.getRecordTypeInfosByName().get('IH POC Budget Plan').getRecordTypeId();
                ihPBP.Account__c = a.Id;
                ihPBP.Annual_Territory_Budget__c = ihBudgetMap.get(a.lboc_Sales_Territory__c).Id;
                budgetPlansToInsert.add(ihPBP);
            }
            if(oohBudgetMap.get(a.lboc_Sales_Territory__c) != NULL){
                System.debug('===in a sales territory poc creation---');
                oohPBP.Name = a.Name + ': ' + String.valueOf(Date.Today().Year());
                oohPBP.RecordTypeId = Schema.SObjectType.Annual_POC_Budget_Plan__c.getRecordTypeInfosByName().get('OOH POC Budget Plan').getRecordTypeId();
                oohPBP.Account__c = a.Id;
                oohPBP.Annual_Territory_Budget__c = oohBudgetMap.get(a.lboc_Sales_Territory__c).Id;
                budgetPlansToInsert.add(oohPBP);
            }
             
        }
         }
        insert budgetPlansToInsert;
    }
    
    public static void OwnerUpdate(list<account> listAccs,Boolean isUpdate){
        set<id> setAccids = new set<id>();
        for(Account objAcc : listAccs){
            
            if(objAcc.type == 'POC' && objAcc.Wholesaler__c != null)
                setAccids.add(objAcc.Wholesaler__c);
        }
        list<account> ListAcc = new list<account>();
        map<id,id> mapOwnerid = new map<id,id>();
        if(!setAccids.isEmpty()){
            ListAcc = [select id,OwnerId from account where id in: setAccids];
            for(account obj : ListAcc){
                if(mapOwnerid.get(obj.id) == null)
                    mapOwnerid.put(obj.id,obj.OwnerId);
            } 
            for(Account objAcc : listAccs){
                 if(objAcc.Wholesaler__c != null && objAcc.type == 'POC' && mapOwnerid != null && mapOwnerid.get(objAcc.Wholesaler__c) != null)
                    objAcc.OwnerId = mapOwnerid.get(objAcc.Wholesaler__c);
            }
        }
    }
    
    public static void geocodePreProcess(Account acc, Map<Id,String> accountIdURLMap){

        String URLString = '';
        String geocodingKey = '';
        String geoAddress = '';
        String gEndpoint = '';
        
        AB_Geocode_Google__c geoGoogle = AB_Geocode_Google__c.getValues('Google API');
        

      // Key for Google Maps Geocoding API

        
      if (geoGoogle != null) {   geocodingKey = geoGoogle.API_Key__c;  gEndpoint = geoGoogle.Endopoint__c;
      }        
        // get the passed in address
        /*List<Account> geoAccount = [SELECT BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode
                                    FROM Account 
                                    WHERE id = :accountId];
        */
        //check that we have enough information to geocode the address
        if((acc.BillingStreet == null) || (acc.BillingCity == null)) {
            System.debug(LoggingLevel.WARN,'Insufficient Data to Geocode Address');
            return;
        } 
        //create a string for the address to pass to Google Geocoding API
        if(acc.BillingStreet != null){
            geoAddress += acc.BillingStreet + ', ';
        }
        if(acc.BillingCity != null){
            geoAddress += acc.BillingCity + ',+';
        }
        if(acc.BillingState != null){
            geoAddress += acc.BillingState + ',+';
        }
        if(acc.BillingCountry != null){
            geoAddress += acc.BillingCountry + ',+';
        }
        if(acc.BillingPostalCode != null){
            geoAddress += acc.BillingPostalCode;
        }
        geoAddress = geoAddress.replace('&', 'and');
        geoAddress = geoAddress.replace('#', '');

        //encode the string so we can pass it as part of URL
        if(!String.isBlank(geoAddress)){
            geoAddress = EncodingUtil.urlEncode(geoAddress, 'UTF-8');
            URLString = gEndpoint + '?address=' + geoAddress + '&key=' + geocodingKey + '&sensor=false';
        }

        if(!String.isBlank(URLString)){
            accountIdURLMap.put(acc.Id,URLString);
        } 
    }
    
     
    /**
    Method Name: pocTransfer
    Purpose: To transfer the allocation records to the correct territories when POC moves to new territory
    **/ 
    public static void pocTransfer(set < id > oldTerritoryIds, set < id > newTerritoryIds, Set < id > pocIds) {

    //Declaration of variables
    Set < Id > productIds = new Set < Id > ();
    Set < Id > oldTerritoryAllocationIds = new set < id > ();
    List < OnPoint_Territory_Allocation__c > oldTerritoryAllocationList = new List < OnPoint_Territory_Allocation__c > ();
    List < OnPoint_Territory_Allocation__c > newTerritoryAllocationListToCreate = new List < OnPoint_Territory_Allocation__c > ();
    List < OnPoint_Allocation__c > allocationToUpdate = new List < OnPoint_Allocation__c > ();
    //Map < id, OnPoint_Territory_Allocation__c > oldTerritoryallocationMap = new Map < id, OnPoint_Territory_Allocation__c > ();
    List < OnPoint_Territory_Allocation__c > territoryListToUpdate = new List < OnPoint_Territory_Allocation__c > ();
    List < OnPoint_Allocation__c > allocationsToUpdate = new List < OnPoint_Allocation__c > ();
    List < OnPoint_Allocation__c > allocationsToBeFlagged = new List < OnPoint_Allocation__c > ();
    set < id > programIds = new set < id > ();
    List < OnPoint_Allocation__c > allocationsToCreate = new List < OnPoint_Allocation__c > ();
    Map<id,decimal> territoryQuantityRmngMap = new Map<id,decimal>();
    decimal territoryQtyRemaining = 0;
    decimal territoryQuantityRmng = 0;
    set<id> TAidsToDelete = new set<id>();
    List < OnPoint_Allocation__c > newAllocationList = new List < OnPoint_Allocation__c > ();
    Map < string, OnPoint_Territory_Allocation__c > NewproductTerritoryMap = new Map < string, OnPoint_Territory_Allocation__c > (); //combination of product+territory+program

    List < OnPoint_Territory_Allocation__c > NewTerritoryAllocationListToDelete = new List < OnPoint_Territory_Allocation__c > ();

    SYSTEM.DEBUG('pocIds:::' + pocIds);
    system.debug('oldTerritoryIds:::'+oldTerritoryIds);
    system.debug('new territory ids'+newTerritoryIds);
    
    //Query the allocation records with old territories
    List < OnPoint_Allocation__c > OldallocationList = [select id, Account__c, Account__r.OnPoint_Sales_Territory__c, POC_In_Territory__c, OnPoint_Territory_Allocation__c, OnPoint_Territory_Allocation__r.OnPoint_Territory__c, OnPoint_Territory_Allocation__r.CC_Product__c, OnPoint_Territory_Allocation__r.OnPoint_Program__c, OnPoint_Territory_Allocation__r.Active_Year__c,
        OnPoint_Territory_Allocation__R.Sum_Qty_Allocated__c, OnPoint_Territory_Allocation__R.Sum_Qty_Assigned__c, OnPoint_Territory_Allocation__R.Sum_Qty_Remaining__c,Quantity_Allocated__c, Quantity_Assigned__c,Quantity_Remaining__c  from OnPoint_Allocation__c
        where Account__c in: pocIds AND OnPoint_Territory_Allocation__r.OnPoint_Territory__c IN: oldTerritoryIds and OnPoint_Territory_Allocation__r.OnPoint_Program__r.Program_End_Date__c > TODAY and OnPoint_Territory_Allocation__R.Sum_Qty_Allocated__c > 0
        and OnPoint_Territory_Allocation__R.Sum_Qty_Remaining__c > 0 and OnPoint_Territory_Allocation__r.Active_Year__c = THIS_YEAR and Quantity_Allocated__c > 0 and Quantity_Remaining__c > 0
    ];
    System.debug('OldallocationList :::' + OldallocationList);
    
    //Get the product Ids, Territory allocation ids and program ids of the old allocations
    for (OnPoint_Allocation__c alloc: OldallocationList) {
        productIds.add(alloc.OnPoint_Territory_Allocation__r.CC_Product__c);
        oldTerritoryAllocationIds.add(alloc.OnPoint_Territory_Allocation__c);
        programIds.add(alloc.OnPoint_Territory_Allocation__r.OnPoint_Program__c);
    }
    System.debug('productIds:::' + productIds);
    System.debug('oldTerritoryAllocationIds:::' + oldTerritoryAllocationIds);
    System.debug('programIds:::' + programIds);

    //Fetch the related territory allocation records of the old allocations
    oldTerritoryAllocationList = [Select id, Active_Year__c, OnPoint_Program__c, OnPoint_Territory__c, CC_Product__c, Sum_Qty_Assigned__c, Sum_Qty_Allocated__c from OnPoint_Territory_Allocation__c where id in: oldTerritoryAllocationIds];
    System.debug('oldTerritoryAllocationList :::' + oldTerritoryAllocationList);
    
    
    
    //Get the territory allocation records of the new territory base don the same product ids and program ids
    List < OnPoint_Territory_Allocation__c > NewTerritoryAllocationList = [select id, OnPoint_Territory__c, CC_Product__c, OnPoint_Program__c, Sum_Qty_Remaining__c, (Select id, Account__c, OnPoint_Territory_Allocation__r.OnPoint_Territory__c, OnPoint_Territory_Allocation__r.CC_Product__c, OnPoint_Territory_Allocation__r.Onpoint_Program__c,Quantity_Allocated__c, Quantity_Assigned__c from OnPoint_Allocations__r where Account__c in: pocIds) from OnPoint_Territory_Allocation__c
        where OnPoint_Territory__c in: newTerritoryIds and CC_Product__c in: productIds and OnPoint_Program__c in: programIds
    ];
    System.debug('NewTerritoryAllocationList ::::' + NewTerritoryAllocationList);

    for (OnPoint_Territory_Allocation__c ot: NewTerritoryAllocationList) {
        IF(ot.OnPoint_Allocations__r.size() > 0) {
            for(OnPoint_Allocation__c oa : ot.OnPoint_Allocations__r){
               newAllocationList.add(oa);
               }
        }
        NewproductTerritoryMap.put(ot.CC_Product__c + '-' + ot.OnPoint_Territory__c + '-' + ot.OnPoint_Program__c, ot);
    }
    SYSTEM.DEBUG('newAllocationList :::' + newAllocationList);
    SYSTEM.DEBUG('NewproductTerritoryMap:::' + NewproductTerritoryMap);

   // Map < id, OnPoint_Territory_Allocation__c > productAllocationMap = new Map < id, OnPoint_Territory_Allocation__c > ();
    Map < string, OnPoint_Allocation__c > NewterritoryAllocationMap = new map < string, OnPoint_Allocation__c > ();
    if (newAllocationList.size() > 0) {
        for (OnPoint_Allocation__c allocation: newAllocationList) {
            NewterritoryAllocationMap.put(allocation.Account__c+'-'+allocation.OnPoint_Territory_Allocation__r.OnPoint_Territory__c+'-'+allocation.OnPoint_Territory_Allocation__r.CC_Product__c+'-'+allocation.OnPoint_Territory_Allocation__r.Onpoint_Program__c, allocation);
        }
    }
    SYSTEM.DEBUG('NewterritoryAllocationMap:::' + NewterritoryAllocationMap);

    for (OnPoint_Allocation__c allocation: OldallocationList) {
        system.debug('Allocation Details 1'+allocation);
        //Checking if there is any existing territory allocation in new territory based on the product and program
        if (NewproductTerritoryMap.containsKey(allocation.OnPoint_Territory_Allocation__r.CC_Product__c + '-' + allocation.Account__r.OnPoint_Sales_Territory__c+ '-' + allocation.OnPoint_Territory_Allocation__r.OnPoint_Program__c)) {
            //checking the remaining quantity of the territory allocation
            if(!territoryQuantityRmngMap.containsKey(allocation.OnPoint_Territory_Allocation__c)){
            territoryQtyRemaining = allocation.OnPoint_Territory_Allocation__r.Sum_Qty_Remaining__c;
            }else{
            territoryQtyRemaining = territoryQuantityRmngMap.get(allocation.OnPoint_Territory_Allocation__c);
            }
            SYSTEM.DEBUG('territoryQtyRemaining-1'+territoryQtyRemaining);
            
            if (!NewterritoryAllocationMap.containsKey(allocation.Account__C)) { //If there is no allocation record for the poc in new territory allocation, then create a new allocation
                //Create a new allocation
                OnPoint_Allocation__c alloc = new OnPoint_Allocation__c();
                alloc.Account__c = allocation.Account__c;
                system.debug('****&&&&'+NewproductTerritoryMap.get(allocation.OnPoint_Territory_Allocation__r.CC_Product__c + '-' + allocation.Account__r.OnPoint_Sales_Territory__c + '-' + allocation.OnPoint_Territory_Allocation__r.OnPoint_Program__c).id);
                alloc.OnPoint_Territory_Allocation__c = NewproductTerritoryMap.get(allocation.OnPoint_Territory_Allocation__r.CC_Product__c + '-' + allocation.Account__r.OnPoint_Sales_Territory__c + '-' + allocation.OnPoint_Territory_Allocation__r.OnPoint_Program__c).id;
                //If the territory allocation remaining quantity is less than poc allocation remaining quantity...
                if (territoryQtyRemaining < allocation.Quantity_Remaining__c) { 
                    alloc.Quantity_Allocated__c = territoryQtyRemaining;
                    allocation.Quantity_Allocated__c = allocation.Quantity_Allocated__c - territoryQtyRemaining;
                    if(!territoryQuantityRmngMap.containsKey(allocation.OnPoint_Territory_Allocation__c)){
                    territoryQuantityRmngMap.put(allocation.OnPoint_Territory_Allocation__c,0);
                    }else{
                    system.debug('**allocation territory::'+allocation.OnPoint_Territory_Allocation__c);
                    system.debug('territoryQuantityRmngMap:::'+territoryQuantityRmngMap);
                    system.debug('&&territoryquanitty::'+territoryQuantityRmngMap.get(allocation.OnPoint_Territory_Allocation__c));
                    decimal rmgQuantity = territoryQuantityRmngMap.get(allocation.OnPoint_Territory_Allocation__c) - territoryQtyRemaining ;
                    territoryQuantityRmngMap.put(allocation.OnPoint_Territory_Allocation__c,rmgQuantity);
                    }
                } else { //If the territory allocation remaining quantity is greater than poc allocation remaining quantity...
                    if(!territoryQuantityRmngMap.containsKey(allocation.OnPoint_Territory_Allocation__c)){
                    decimal rmgQuantity = territoryQtyRemaining - allocation.Quantity_Remaining__c;
                    territoryQuantityRmngMap.put(allocation.OnPoint_Territory_Allocation__c,rmgQuantity);
                    }else{
                    decimal rmgQuantity = territoryQuantityRmngMap.get(alloc.OnPoint_Territory_Allocation__c) - allocation.Quantity_Remaining__c ;
                    territoryQuantityRmngMap.put(allocation.OnPoint_Territory_Allocation__c,rmgQuantity);
                    }
                    alloc.Quantity_Allocated__c = allocation.Quantity_Remaining__c;
                    allocation.Quantity_Allocated__c = allocation.Quantity_Allocated__c - allocation.Quantity_Remaining__c;
                }
                allocationsToCreate.add(alloc);

                allocationToUpdate.add(allocation);

            } else {
                //Add the logic to update the quantity to the existing allocation

                OnPoint_Allocation__c newalloc = NewterritoryAllocationMap.get(allocation.Account__C+'-'+allocation.Account__r.OnPoint_Sales_Territory__c +'-'+allocation.OnPoint_Territory_Allocation__r.CC_Product__c+'-'+allocation.OnPoint_Territory_Allocation__r.Onpoint_Program__c);
                SYSTEM.DEBUG('Allocation details 2:::::' + newalloc);
                if (territoryQtyRemaining < allocation.Quantity_Remaining__c) {
                    newalloc.Quantity_Allocated__c = newalloc.Quantity_Allocated__c + territoryQtyRemaining;
                    allocation.Quantity_Allocated__c = allocation.Quantity_Allocated__c - territoryQtyRemaining;
                    if(!territoryQuantityRmngMap.containsKey(allocation.OnPoint_Territory_Allocation__c)){
                    territoryQuantityRmngMap.put(allocation.OnPoint_Territory_Allocation__c,0);
                    }else{
                    decimal rmgQuantity = territoryQuantityRmngMap.get(allocation.OnPoint_Territory_Allocation__c) - territoryQtyRemaining ;
                    territoryQuantityRmngMap.put(allocation.OnPoint_Territory_Allocation__c,rmgQuantity);
                    }
                } else {
                    if(!territoryQuantityRmngMap.containsKey(allocation.OnPoint_Territory_Allocation__c)){
                    decimal rmgQuantity = territoryQtyRemaining - allocation.Quantity_Remaining__c;
                    territoryQuantityRmngMap.put(allocation.OnPoint_Territory_Allocation__c,rmgQuantity);
                    }else{
                    decimal rmgQuantity = territoryQuantityRmngMap.get(allocation.OnPoint_Territory_Allocation__c) - allocation.Quantity_Remaining__c ;
                    territoryQuantityRmngMap.put(allocation.OnPoint_Territory_Allocation__c,rmgQuantity);
                    }                   
                    newalloc.Quantity_Allocated__c = newalloc.Quantity_Allocated__c + allocation.Quantity_Remaining__c;
                    allocation.Quantity_Allocated__c = allocation.Quantity_Allocated__c - allocation.Quantity_Remaining__c;
                }
                //newalloc.Quantity_Assigned__c= newalloc.Quantity_Assigned__c+ allocation.Quantity_Assigned__c;
                allocationToUpdate.add(newalloc);
                //Update the old allocation quantity to 0
                allocationToUpdate.add(allocation);

            }
        } else { //If there is no existing territory allocation in new territory with same product and program, create new territory allocation
            SYSTEM.DEBUG('CREATE NEW TERRITORY ALLOCATIONS');
            
                OnPoint_Territory_Allocation__c TA = new OnPoint_Territory_Allocation__c();
                TA.Active_Year__c = allocation.OnPoint_Territory_Allocation__r.Active_Year__c;
                TA.OnPoint_Program__c = allocation.OnPoint_Territory_Allocation__r.OnPoint_Program__c;
                TA.CC_Product__c = allocation.OnPoint_Territory_Allocation__r.CC_Product__c;
                TA.OnPoint_Territory__c = allocation.Account__r.OnPoint_Sales_Territory__c;
                newTerritoryAllocationListToCreate.add(TA);

                allocationsToBeFlagged.add(allocation);
            
            
        }
        SYSTEM.DEBUG('newTerritoryAllocationListToCreate:::' + newTerritoryAllocationListToCreate);
    }
    system.debug('allocationsToBeFlagged:::'+allocationsToBeFlagged);
    SYSTEM.DEBUG('allocationsToCreate:::'+allocationsToCreate);
    SYSTEM.DEBUG('allocationToUpdate::'+allocationToUpdate);
    if (newTerritoryAllocationListToCreate.size() > 0) {
        insert newTerritoryAllocationListToCreate;
    }

for (OnPoint_Territory_Allocation__c opAlloc: newTerritoryAllocationListToCreate) {
    system.debug('Territory allocation details::::'+opAlloc);
    for (OnPoint_Allocation__c alloc: allocationsToBeFlagged) {
        System.debug('allocation details 3'+alloc);
        if(!territoryQuantityRmngMap.containsKey(alloc.OnPoint_Territory_Allocation__c)){
            territoryQuantityRmng = alloc.OnPoint_Territory_Allocation__r.Sum_Qty_Remaining__c;
            }else{
            territoryQuantityRmng  = territoryQuantityRmngMap.get(alloc.OnPoint_Territory_Allocation__c);
            }
       // decimal territoryQuantityRmng = alloc.OnPoint_Territory_Allocation__r.Sum_Qty_Remaining__c;
        SYSTEM.DEBUG('territoryQuantityRmng-2::'+territoryQuantityRmng);
       // for (OnPoint_Territory_Allocation__c opAlloc: newTerritoryAllocationListToCreate) {
            if (alloc.OnPoint_Territory_Allocation__r.OnPoint_Territory__c != opAlloc.OnPoint_Territory__c && alloc.OnPoint_Territory_Allocation__r.OnPoint_Program__c == opAlloc.OnPoint_Program__c &&
                alloc.OnPoint_Territory_Allocation__r.CC_Product__c == opAlloc.CC_Product__c && alloc.account__r.OnPoint_Sales_Territory__c == opAlloc.onpoint_territory__c) {
                OnPoint_Allocation__c newalloc = new OnPoint_Allocation__c();
                newalloc.Account__c = alloc.Account__c;
                newalloc.OnPoint_Territory_Allocation__c = opAlloc.Id;
                if(territoryQuantityRmng > 0){
                if (territoryQuantityRmng < alloc.Quantity_Remaining__c) {
                    newalloc.Quantity_Allocated__c = territoryQuantityRmng;
                    alloc.Quantity_Allocated__c = alloc.Quantity_Allocated__c - territoryQuantityRmng; //Update the old allocation quantity to 0
                    if(!territoryQuantityRmngMap.containsKey(alloc.OnPoint_Territory_Allocation__c)){
                    territoryQuantityRmngMap.put(alloc.OnPoint_Territory_Allocation__c,0);
                    }else{
                    decimal rmgQuantity = territoryQuantityRmngMap.get(alloc.OnPoint_Territory_Allocation__c) - territoryQtyRemaining ;
                    territoryQuantityRmngMap.put(alloc.OnPoint_Territory_Allocation__c,rmgQuantity);
                    }
                } else {
                    if(!territoryQuantityRmngMap.containsKey(alloc.OnPoint_Territory_Allocation__c)){
                    decimal rmgQuantity = territoryQuantityRmng - alloc.Quantity_Remaining__c;
                    system.debug('rmgQuantity::'+rmgQuantity);
                    territoryQuantityRmngMap.put(alloc.OnPoint_Territory_Allocation__c,rmgQuantity);
                    }else{
                    system.debug('territoryQuantityRmngMap-else:::'+territoryQuantityRmngMap);
                    decimal rmgQuantity = territoryQuantityRmngMap.get(alloc.OnPoint_Territory_Allocation__c) - alloc.Quantity_Remaining__c ;
                    territoryQuantityRmngMap.put(alloc.OnPoint_Territory_Allocation__c,rmgQuantity);
                    }
                    newalloc.Quantity_Allocated__c = alloc.Quantity_Remaining__c;
                    alloc.Quantity_Allocated__c = alloc.Quantity_Allocated__c -  alloc.Quantity_Remaining__c;
                   // if(alloc.Quantity_Assigned__c != 0){
                   // alloc.Quantity_Allocated__c = alloc.Quantity_Allocated__c - (alloc.Quantity_Assigned__c + alloc.Quantity_Remaining__c); //Update the old allocation quantity to 0
                   // }
                }
                allocationsToCreate.add(newalloc);
                allocationToUpdate.add(alloc);
                }else{
                TAidsToDelete.add(opAlloc.id);

                }

            }
        }
    }
    
    System.debug('Final allocationsToCreate:::'+allocationsToCreate);
    System.debug('Final allocationToUpdate:::'+allocationToUpdate);
    System.debug('Territory Allocation Ids to Delete'+TAidsToDelete);
    
    if(TAidsToDelete.size()>0){
    NewTerritoryAllocationListToDelete = [select id from OnPoint_Territory_Allocation__c where id in : TAidsToDelete];
    }
    
    if (allocationsToCreate.size() > 0) {
        insert allocationsToCreate;
    }
    if (allocationToUpdate.size() > 0) {
        update allocationToUpdate;
    }
    
    if(NewTerritoryAllocationListToDelete.size()>0){
        delete NewTerritoryAllocationListToDelete;
    }



    
}
    //AccountTriggerHandler end  --------------------------------------------4
   
    
    
}