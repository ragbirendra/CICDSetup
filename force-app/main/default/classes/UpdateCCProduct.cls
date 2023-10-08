/***
* @Name				UpdateCCProduct
* @Author			Ragbirendra Upadhyay
* @CreatedDate		10-31-2019
* @Description		process Batch Class(OnPoint_CC_Product_UpdateBatch) for Update CC Product Record from 
*					Item Object record based on SKU Number and Id of CC Product
*
*/
public with sharing class UpdateCCProduct {
    
    String selectedParentProductType ; 
    //Boolean selectedDriver ;
    //Boolean selectedCapex ;
    Map<String, ccrz__E_Category__c> brandCategoriesByName;
    Map<String, ccrz__E_Category__c> focusBrandCategoriesByName; 
    Map<String, ccrz__E_Category__c> parentPTCategoriesByName;
    @TestVisible private Map<String, ccrz__E_Category__c> ptCategoriesByName;
    private ccrz__E_Category__c brandCategory;
    Id productTypeSpecId;
    Id brandSpecId;
    Id productTypeFrSpecId;
    Id brandFrSpecId;
    
    
    public String updateProduct(Map<String,Id> SKUNumberIdMap,List<Marketing_Item__c> itemList,Map<Id,Attachment> attachmentMap,Map<String,Id> itemIdBasedOnItemNumMap) {
        
        
        brandCategoriesByName = new Map<String, ccrz__E_Category__c>();
        focusBrandCategoriesByName = new Map<String, ccrz__E_Category__c>();
        parentPTCategoriesByName = new Map<String, ccrz__E_Category__c>();
        String mailBody ='';
        String SKUNumber ='';
        
        //brands = [select Id, Name from OnPoint_Brand__c];
        List<ccrz__E_Category__c> categories = [select Id, Name, ccrz__ParentCategory__r.Name from ccrz__E_Category__c];
        
        //Reduced down to one query instead of doing 4 individual queries
        List<String> specNames = new List<String>{'Product Type','Brand','Type de produit','Brand FR'}; // Product Type
            
            List<ccrz__E_Spec__c> specCheck = [SELECT Id, Name FROM ccrz__E_Spec__c WHERE Name IN :specNames];
        
        for(ccrz__E_Spec__c spec:specCheck) {
            if(spec.Name == 'Product Type') {
                this.productTypeSpecId = spec.Id;
            } else if(spec.Name == 'Brand') {
                this.brandSpecId = spec.Id;
            } else if(spec.Name == 'Type de produit') {
                this.productTypeFrSpecId = spec.Id;
            } else if(spec.Name == 'Brand FR') {
                this.brandFrSpecId = spec.Id;
            }
        }
        if (specCheck.size() != 4) {
            String msg = 'Your system is missing CC Spec records.  Make sure CC Spec records exist for: ';
            system.debug('Error');
        }
        
        
        //sort and organize the CC Categories
        for (ccrz__E_Category__c category : categories) {
            if (category.Name == 'Brand') {
                this.brandCategory = category;
            }
            if(category.ccrz__ParentCategory__r.Name == 'Brand') {
                this.brandCategoriesByName.put(category.Name, category);
            }
            else if(category.ccrz__ParentCategory__r.Name == 'Focus Brands') {
                this.focusBrandCategoriesByName.put(category.Name, category);
            }
            else if(category.ccrz__ParentCategory__r.Name == 'Product Type') {
                this.parentPTCategoriesByName.put(category.Name, category); // This doesn't appear to be used??
            }
        }
        
        ptCategoriesByName = new Map<String, ccrz__E_Category__c>();
        for(Marketing_Item__c mi:itemList)
        {
            for (ccrz__E_Category__c category : categories) {
                if(category.ccrz__ParentCategory__r.Name == mi.Items_Parent_Product_Types__c) {
                    ptCategoriesByName.put(category.Name, category);
                }
            } 
        }
        // find the brand category from the list of brand categories
        ccrz__E_Category__c selectedBrandCategory = null;
        
        List<Id> productId = new List<Id>();
        for(Marketing_Item__c mi:itemList){
            SKUNumber = SKUNumber+' ,'+ mi.Item_Number__c;
            productId.add(SKUNumberIdMap.get(mi.Item_Number__c));  
        }
        List<ccrz__E_ProductCategory__c> deleteCategory = [select Id from ccrz__E_ProductCategory__c where ccrz__product__c IN: productId];
        List<ccrz__E_ProductCategory__c> productCategories = new List<ccrz__E_ProductCategory__c>();
        List<ccrz__E_ProductSpec__c> prodSpecsToCreate = new List<ccrz__E_ProductSpec__c>();
        List<ccrz__E_ProductSpec__c> existingProdSpecs = new List<ccrz__E_ProductSpec__c>(
            [select Id, ccrz__Spec__c, ccrz__Product__c
             from ccrz__E_ProductSpec__c where ccrz__Product__c IN:productId]);
        
        List<ccrz__E_ProductMedia__c> newProductMedias = new List<ccrz__E_ProductMedia__c>();
        List<ccrz__E_ProductMedia__c> existingProductMedias = new List<ccrz__E_ProductMedia__c>(
            [select Id, ccrz__Product__c, ccrz__MediaType__c 
             from ccrz__E_ProductMedia__c where ccrz__Product__c IN: productId]);
        List<ccrz__E_Product__c> updateCCProductList = new List<ccrz__E_Product__c>();
        
        try{
        
        for(Marketing_Item__c mi:itemList){
            
            // Create Product Catagories 
            
            if (focusBrandCategoriesByName.containsKey(mi.Brand__r.name)) {
                ccrz__E_Category__c category = focusBrandCategoriesByName.get(mi.Brand__r.name);
                ccrz__E_ProductCategory__c ccrzProdCat = new ccrz__E_ProductCategory__c(ccrz__Product__c = SKUNumberIdMap.get(mi.Item_Number__c),ccrz__Category__c = category.Id);
                productCategories.add(ccrzProdCat);
            }
            ccrz__E_Category__c category1 = brandCategoriesByName.get(mi.Brand__r.name);
            ccrz__E_ProductCategory__c ccrzProdCat1 = new ccrz__E_ProductCategory__c(ccrz__Product__c = SKUNumberIdMap.get(mi.Item_Number__c),ccrz__Category__c = category1.Id);
            productCategories.add(ccrzProdCat1);
            ccrz__E_Category__c category2 = ptCategoriesByName.get(mi.Items_Product_Type__c);
            ccrz__E_ProductCategory__c ccrzProdCat2 = new ccrz__E_ProductCategory__c(ccrz__Product__c = SKUNumberIdMap.get(mi.Item_Number__c),ccrz__Category__c = category2.Id);
            productCategories.add(ccrzProdCat2);
            
            // Create product Specification
            ccrz__E_ProductSpec__c ccProdSpec= new ccrz__E_ProductSpec__c(
                ccrz__Spec__c = brandSpecId,
                ccrz__SpecValue__c = mi.Brand__r.name,
                ccrz__Product__c = SKUNumberIdMap.get(mi.Item_Number__c)
            );
            ccrz__E_ProductSpec__c ccProdSpec1= new ccrz__E_ProductSpec__c(
                ccrz__Spec__c = brandFrSpecId,
                ccrz__SpecValue__c = mi.Brand__r.name,
                ccrz__Product__c = SKUNumberIdMap.get(mi.Item_Number__c)
            );
            ccrz__E_ProductSpec__c ccProdSpec2= new ccrz__E_ProductSpec__c(
                ccrz__Spec__c = productTypeSpecId,
                ccrz__SpecValue__c = mi.Items_Product_Type__c,
                ccrz__Product__c = SKUNumberIdMap.get(mi.Item_Number__c)
            );
            ccrz__E_ProductSpec__c ccProdSpec3= new ccrz__E_ProductSpec__c(
                ccrz__Spec__c = productTypeFrSpecId,
                ccrz__SpecValue__c = mi.Items_Product_Type__c,
                ccrz__Product__c = SKUNumberIdMap.get(mi.Item_Number__c)
            );
            prodSpecsToCreate.add(ccProdSpec);
            prodSpecsToCreate.add(ccProdSpec1);
            prodSpecsToCreate.add(ccProdSpec2);
            prodSpecsToCreate.add(ccProdSpec3);
            //duplicate check 
            for (ccrz__E_ProductSpec__c prodSpec : prodSpecsToCreate) {
                for (ccrz__E_ProductSpec__c existingProdSpec : existingProdSpecs) {
                    if (prodSpec.ccrz__Product__c == existingProdSpec.ccrz__Product__c
                        && prodSpec.ccrz__Spec__c == existingProdSpec.ccrz__Spec__c) {
                            prodSpec.Id = existingProdSpec.Id;
                        }
                }
            }
            
            // Create CC product Media
            ccrz__E_ProductMedia__c ccprodMed = new ccrz__E_ProductMedia__c(
                ccrz__Product__c = SKUNumberIdMap.get(mi.Item_Number__c),
                ccrz__Enabled__c = TRUE,
                ccrz__Locale__c = 'en_US',
                ccrz__MediaType__c = 'Product Search Image',
                ccrz__Sequence__c = 500,
                ccrz__AltMessage__c = mi.Item_Number__c,
                ccrz__ProductMediaSource__c = 'Attachment'
            ); 
            ccrz__E_ProductMedia__c ccprodMed1 = new ccrz__E_ProductMedia__c(
                ccrz__Product__c = SKUNumberIdMap.get(mi.Item_Number__c),
                ccrz__Enabled__c = TRUE,
                ccrz__Locale__c = 'en_US',
                ccrz__MediaType__c = 'Product Image',
                ccrz__Sequence__c = 500,
                ccrz__AltMessage__c = mi.Item_Number__c,
                ccrz__ProductMediaSource__c = 'Attachment'
            ); 
            
            ccrz__E_ProductMedia__c ccprodMed2 = new ccrz__E_ProductMedia__c(
                ccrz__Product__c = SKUNumberIdMap.get(mi.Item_Number__c),
                ccrz__Enabled__c = TRUE,
                ccrz__Locale__c = 'en_US',
                ccrz__MediaType__c = 'Product Image Thumbnail',
                ccrz__Sequence__c = 500,
                ccrz__AltMessage__c = mi.Item_Number__c,
                ccrz__ProductMediaSource__c = 'Attachment'
            ); 
            newProductMedias.add(ccprodMed);
            newProductMedias.add(ccprodMed1);
            newProductMedias.add(ccprodMed2);
            //Duplicate check
            for (ccrz__E_ProductMedia__c productMedia : newProductMedias) {
                for (ccrz__E_ProductMedia__c existingProductMedia : existingProductMedias) {
                    if (productMedia.ccrz__MediaType__c == existingProductMedia.ccrz__MediaType__c) {
                        productMedia.Id = existingProductMedia.Id;
                    }
                }
            }                       
            //Update CC Product
            ccrz__E_Product__c ccProduct = new ccrz__E_Product__c();
            ccProduct.OnPoint_Brand__c = mi.Brand__r.name;       
            ccProduct.Name = mi.Name;    
            ccProduct.ccrz__Storefront__c = 'OnPointSE';	
            ccProduct.Id = SKUNumberIdMap.get(mi.Item_Number__c);
            if(mi.Is_Program_Only__c == true){
                ccProduct.OnPoint_Max_Order_Quantity__c = 0.0;  
            } 
            updateCCProductList.add(ccProduct);
        }//end of for Loop
        }
         catch(Exception e){
            mailBody+='SKUNumber :'+SKUNumber +'</br>';
            mailBody+='Please Reverify cc catgories for Parent product type and Product Type '+'</br>';
            mailBody+=e+'</br>';
            system.debug('Test 7:::'+e);
        }
        
        try{ 
            
            if (deleteCategory.size() > 0)
                delete deleteCategory; 
            upsert productCategories; 
            upsert prodSpecsToCreate; 
            upsert newProductMedias; 
            
            List<Attachment>  attachments = new List<Attachment>(); 
            for (ccrz__E_ProductMedia__c productMedia : newProductMedias) {
                //attachments.add(createAttachment(productMedia.Id));
                Id itemId = itemIdBasedOnItemNumMap.get(productMedia.ccrz__AltMessage__c);
                Attachment attchItem = attachmentMap.get(itemId);
                Attachment att = new Attachment(
                    Name = attchItem.Name,
                    ParentId = productMedia.Id,
                    Body = attchItem.Body,
                    ContentType = 'image/jpg'
                );
                attachments.add(att);
            }  
            
            upsert attachments;                
            //Update CC Product
            
            List<Database.SaveResult> updateResults = Database.update(updateCCProductList, false);
            for(Integer i=0;i<updateResults.size();i++){
                if (updateResults.get(i).isSuccess()){
                    updateResults.get(i).getId();
                   // mailBody+=' Succesfully Updated Record Id: '+ updateResults.get(i).getId()+'</br>';
                }else if (!updateResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = updateResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    mailBody+=' Update failed Record Id: '+ updateResults.get(i).getId()+'</br>';
                    mailBody+=' Failed comment: '+ failedDML+'</br>';
                }
                
            }
        }
        catch(Exception e){
           mailBody+='SKUNumber :'+ SKUNumber +'</br>';
           mailBody+='Upsert Failed due below Error:'+'</br>';
           mailBody+=e+'</br>';
           system.debug('Test 7:::'+e);
        } 
        return mailBody;
    }
}