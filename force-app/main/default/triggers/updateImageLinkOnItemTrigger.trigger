trigger updateImageLinkOnItemTrigger on Attachment (After insert, After Update) {
    
    Map<Id,Marketing_Item__c> parentItems = new Map<Id,Marketing_Item__c>();
    Map<Id,Brand__c> parentBrands = new Map<Id,Brand__c>();
    Set<Id> setOfIds = new Set<Id>();
    boolean otherobjectAttachmentFlag = true;
    for(Attachment atchmnt : Trigger.new){
        String str= String.valueOf(atchmnt.ParentId);
        if(atchmnt.ParentId.getSobjectType() == Marketing_Item__c.SobjectType){
            setOfIds.add(atchmnt.ParentId);
        }
        if(atchmnt.ParentId.getSobjectType() == Brand__c.SobjectType){
            setOfIds.add(atchmnt.ParentId);
        }
      
    }
 
    if(setOfIds !=null){
    //parentItems = new Map<Id,Marketing_Item__c>([Select Id,Sml_Image_Link__c, (Select Id from Attachments) from Marketing_Item__c where Id IN :setOfIds]);
    parentItems = new Map<Id,Marketing_Item__c>([Select Id,Sml_Image_Link__c from Marketing_Item__c where Id IN :setOfIds]);
    parentBrands = new Map<Id,Brand__c>([Select Id,Logo_Link__c from Brand__c where Id IN :setOfIds]);
    system.debug('parentItems----> '+parentItems);
    for(Attachment atch : Trigger.new){ 
        if(atch.ParentId.getSobjectType() == Marketing_Item__c.SobjectType)
        {
        Marketing_Item__c item = parentItems.get(atch.ParentId);
        //item.Sml_Image_Link__c = Label.ABI_OP_URLForImage+'/servlet/servlet.FileDownload?file='+atch.Id;
            item.Sml_Image_Link__c = '/servlet/servlet.FileDownload?file='+atch.Id;
        }
        if(atch.ParentId.getSobjectType() == Brand__c.SobjectType){
         Brand__c br = parentBrands.get(atch.ParentId);
         br.Logo_Link__c = '/servlet/servlet.FileDownload?file='+atch.Id;   
        }
    }
    system.debug('Items to be updated----> '+parentItems.values());
    Update parentItems.values();
    Update parentBrands.values();
    }
}