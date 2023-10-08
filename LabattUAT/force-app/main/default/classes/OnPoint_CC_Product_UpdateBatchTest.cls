/***
* @Name - OnPoint_CC_Product_UpdateBatchTest
* @Author - Developer@Cognizant
* @CreatedDate -09/15/2019
* @Description -  This test class Created for testing method of OnPoint_CC_Product_UpdateBatch class
* 

***/


@isTest 
public class OnPoint_CC_Product_UpdateBatchTest
{
    static testMethod void testMethod1() 
    {
        OnPoint_Brand__c o=new OnPoint_Brand__c();
        o.Name='Corona';
        insert o;
        String ac=o.Id;
        
        List<ID> lst=new List<ID>();
        lst.add(o.ID);
             
        //ccrz__E_Category__c ca=new ccrz__E_Category__c();
        ccrz__E_Category__c cECParent=new ccrz__E_Category__c();
        cECParent.Name='Brand';
        cECParent.ccrz__CategoryID__c='t1';
        insert cECParent;
        
        ccrz__E_Category__c cECChild=new ccrz__E_Category__c();
        cECChild.Name='Brand';
        cECChild.ccrz__ParentCategory__c=cECParent.id;
        cECChild.ccrz__CategoryID__c='t2';
        
        insert cECChild;
        ccrz__E_Category__c cECChild1=new ccrz__E_Category__c();
        cECChild1.Name='Focus Brands';
        cECChild1.ccrz__ParentCategory__c=cECParent.id;
        cECChild1.ccrz__CategoryID__c='t3';
        
        insert cECChild1;
        ccrz__E_Category__c cECChild2=new ccrz__E_Category__c();
        cECChild2.Name='Test';
        cECChild2.ccrz__ParentCategory__c=cECChild1.id;
        cECChild2.ccrz__CategoryID__c='t4';
        
        insert cECChild2;
        ccrz__E_Category__c cECChild3=new ccrz__E_Category__c();
        cECChild3.Name='Test';
        cECChild3.ccrz__ParentCategory__c=cECChild.id;
        cECChild3.ccrz__CategoryID__c='t5';
        
        insert cECChild3;
        ccrz__E_Category__c cECChild4=new ccrz__E_Category__c();
        cECChild4.Name='Brand';
        cECChild4.ccrz__ParentCategory__c=cECChild1.id;
        cECChild4.ccrz__CategoryID__c='t6';
        
        insert cECChild4;
        
        ccrz__E_Product__c c=new ccrz__E_Product__c();
        // c.name='test';
        //c.OnPoint_Driver__c=false;
        //c.Is_Capex__c=false;
        c.ccrz__SKU__c='7522028';
        insert c;
        
        Staging_Main__c stm = new Staging_Main__c();
        stm.Name = 'test';
        stm.SKU_Number__c ='7522028';
        insert stm;
        
        String aca=c.Id;
        
        ccrz__E_Spec__c bi=new ccrz__E_Spec__c();
        bi.Name='Product Type';
        insert bi;
        
        ccrz__E_Spec__c bb=new ccrz__E_Spec__c();
        bb.Name='Brand';
        insert bb;
        
        ccrz__E_Spec__c bt=new ccrz__E_Spec__c();
        bt.Name='Type de produit';
        insert bt;
        ccrz__E_Spec__c br=new ccrz__E_Spec__c();
        br.Name='Brand FR';
        insert br;
        
        Brand__c b=new Brand__c();
        b.Name='Test';
        insert b;
        
        Marketing_Item__c cp1=new Marketing_Item__c();
        cp1.name='test';
        cp1.Brand__c = b.id; 
        cp1.Item_Number__c='7522028';
        cp1.Items_Parent_Product_Types__c='Focus Brands';
        cp1.Items_Product_Type__c='Brand';
        insert cp1; 
        
        String a='/sfc/servlet.shepherd/version/download/068S0000000kOnlIAE';
        Blob bd = Blob.valueOf(a);
        
        Attachment att = new Attachment();
        att.name='test';
        att.Body = bd;
        att.ParentId = cp1.id;
        insert att;
        
        List<Id> ids = new List<Id>();
        Map<String,Id> SKUNumberIdMap = new Map<String,Id>();
        SKUNumberIdMap.put(c.ccrz__SKU__c,c.Id);
        List<Marketing_Item__c> itemList = new List<Marketing_Item__c>();
        itemList.add(cp1);
        List<String> lstItem = new  List<String>{'7522028'};
            Map<String,Id> itemIdBasedOnItemNumMap = new Map<String,Id>();
        for(Marketing_Item__c mi:itemList){
            ids.add(mi.Id);
            itemIdBasedOnItemNumMap.put(mi.Item_Number__c,mi.Id);
        } 
        Map<Id,Attachment> attachmentMap = new Map<Id,Attachment>();
        for (Attachment att1 : [select Id,Name,body,parentId from Attachment where parentId IN:ids]) {   
            attachmentMap.put(att1.parentId,att1);
        }
        
        UpdateCCProduct m= new UpdateCCProduct();
        
        
        ccrz__E_ProductCategory__c pro=new ccrz__E_ProductCategory__c();
        pro.ccrz__product__c= c.id;
        pro.ccrz__Category__c= cECChild.id;
        insert pro;
        
        OnPoint_CC_Product_UpdateBatch btch1 = new OnPoint_CC_Product_UpdateBatch();
        OnPoint_CC_Product_UpdateBatch btch2 = new OnPoint_CC_Product_UpdateBatch(lstItem);
        
        Test.startTest();  
        
        Database.executebatch(btch1);
        Database.executebatch(btch2);
        
        Test.stopTest();
    }
}