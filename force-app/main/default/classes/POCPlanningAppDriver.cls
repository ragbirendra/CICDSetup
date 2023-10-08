/* W-013969
   Updated Driver method
   Updated By- Amol P 
*/
public with sharing class POCPlanningAppDriver {
    
    public static QtyRmngResponse OnDriverChange(String pocId, String itemID, Integer quantity, Integer oldQuantity, Boolean hasQty, String POCSpendCategory, String driverItemID, Boolean isSpecialty, String Region) {
        List<Area_Item_Inventory__c> listOfInventory = new List<Area_Item_Inventory__c>();

        if (hasQty) {
            listOfInventory = [SELECT Id, Quantity_Shopped__c, Quantity_Allocated_to_Area__c, Quantity_Remaining__c, Specialty_Quantity_Remaining__c FROM Area_Item_Inventory__c WHERE Marketing_Item__c = :itemID AND Labatt_Region__c = :Region];
        }
        QtyRmngResponse response = new QtyRmngResponse();
        if (listOfInventory.isEmpty() || (listOfInventory[0].Quantity_Allocated_to_Area__c == 0 && !isSpecialty || listOfInventory[0].Quantity_Allocated_to_Area__c == 0 && listOfInventory[0].Specialty_Quantity_Allocated_to_Area__c == 0 && isSpecialty) || (listOfInventory[0].Quantity_Remaining__c - (quantity - oldQuantity) >= 0 && !isSpecialty) || (isSpecialty && listOfInventory[0].Quantity_Remaining__c - (quantity - oldQuantity) > 0 && listOfInventory[0].Specialty_Quantity_Remaining__c - (quantity - oldQuantity) >= 0)) {
            
            if (!listOfInventory.isEmpty()) {
                listOfInventory[0].Quantity_Shopped__c = listOfInventory[0].Quantity_Shopped__c + (quantity - oldQuantity);
                if (isSpecialty) {
                    listOfInventory[0].Specialty_Quantity_Shopped__c = listOfInventory[0].Specialty_Quantity_Shopped__c + (quantity - oldQuantity);
                }
                update listOfInventory;
            }

            Driver_Item__c driverItem = new Driver_Item__c();
            if (driverItemID == null) {
                driverItem.Marketing_Item__c = itemID;
                driverItem.POC_Spend_Category__c = POCSpendCategory;
                driverItem.Quantity__c = quantity;
                insert driverItem;
                response.DriverItemId = driverItem.Id;
            } else {
                driverItem.Id = driverItemID;
                driverItem.Quantity__c = quantity;
                update driverItem;
            }

            response.IsSuccess = true;
            return response;
        } else {
            response.IsSuccess = false;
            response.QtyRmng = listOfInventory[0].Quantity_Remaining__c.intValue();
            if (isSpecialty && listOfInventory[0].Quantity_Remaining__c > listOfInventory[0].Specialty_Quantity_Remaining__c) {
                response.QtyRmng = listOfInventory[0].Specialty_Quantity_Remaining__c.intValue();
            }
            response.OldQty = oldQuantity;
            return response;
        }
    }

    public static List<DriverBrand> Driver(String POCId, Boolean isSpecialty) {
        system.debug('POCId: ' + POCId + ',isSpecialty: ' + isSpecialty);
        List<POC_Spend_Category__c> pocSpendCategoryList=new List<POC_Spend_Category__c>();
        pocSpendCategoryList = [SELECT Id, Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Sales_Territory__R.lboc_Region__c FROM POC_Spend_Category__c WHERE Name = 'Driver' AND Annual_POC_Budget_Plan__c = :POCId];   //AP Changes Creation of driver under drivers

        String region = pocSpendCategoryList[0].Annual_POC_Budget_Plan__r.Annual_Territory_Budget__r.Sales_Territory__R.lboc_Region__c;
        List<Annual_POC_Budget_Plan__c> annualPOCBudgtList;
        List<Driver_Item__c> listOfDriverItems = [
            SELECT Id, Marketing_item__c, Item_Price__c, Quantity__c 
            FROM Driver_Item__c 
            WHERE POC_Spend_Category__c = :pocSpendCategoryList[0].Id
        ];
        
        annualPOCBudgtList = [select id ,Annual_Territory_Budget__r.OwnerId, Annual_Territory_Budget__r.Budget_Year__c from Annual_POC_Budget_Plan__c where Id = : POCId];
        
        List<String> RestricatedBrandList= new List<String>();
        
       List<POC_Planning_Brand_Restriction__c> unUserBrand = [SELECT id, Restricted_Brands__c FROM POC_Planning_Brand_Restriction__c WHERE Budget_Year__c=:annualPOCBudgtList[0].Annual_Territory_Budget__r.Budget_Year__c];
        if(unUserBrand.size()>0){
            for(POC_Planning_Brand_Restriction__c objPrb:unUserBrand){
                String unUserBrandText = objPrb.Restricted_Brands__c;
                List<String> RestricatedBrandFinalList= unUserBrandText.split('\\$');
                for(integer i=0; i<RestricatedBrandFinalList.size();i++){
                    RestricatedBrandList.add(RestricatedBrandFinalList[i]);
                }
            }
        }
        User oUser = [select id,isClubElite__c FROM User Where id =: annualPOCBudgtList[0].Annual_Territory_Budget__r.OwnerId];//added by Ragbirendra (W-013981)
        List<Marketing_Item__c> listOfItems;
        if(!oUser.isClubElite__c){
        listOfItems = [
            SELECT Id, Brand__c, Item_Description_EN__c, Item_Description_FR__c, Price__c, Material__c,
                Item_Type_EN__c, Item_Type_FR__c, Name, Brand__r.Name, Brand__r.Brand_Hex_Color__c,
                Size__c, Item_Dimensions__c, Item_Unit_of_Measure__c,
                Sml_Image_Link__c, Lrg_Image_Link__c
            FROM Marketing_Item__c
            WHERE Marketing_Type__c = 'Driver' AND Is_Program_Only__c =: false AND Is_Cancelled__c =: false AND Brand__c !=:System.Label.Club_elite_brand_view_ID AND Brand__r.Name NOT IN:RestricatedBrandList
            ORDER BY Brand__r.Priority__c ASC NULLS LAST
        ];
        }
        else
        {
          listOfItems = [
            SELECT Id, Brand__c, Item_Description_EN__c, Item_Description_FR__c, Price__c, Material__c,
                Item_Type_EN__c, Item_Type_FR__c, Name, Brand__r.Name, Brand__r.Brand_Hex_Color__c,
                Size__c, Item_Dimensions__c, Item_Unit_of_Measure__c,
                Sml_Image_Link__c, Lrg_Image_Link__c
            FROM Marketing_Item__c
            WHERE Marketing_Type__c = 'Driver' AND Is_Program_Only__c =: false AND Is_Cancelled__c =: false AND Brand__r.Name NOT IN:RestricatedBrandList
            ORDER BY Brand__r.Priority__c ASC NULLS LAST   
        ];  
        }

        system.debug('listOfItems: ' + listOfItems);

        Map<Id, Integer> mapOfItemsWithQuantity = new Map<Id, Integer>();
        Map<Id, String> mapOfItemsWithID = new Map<Id, String>();
        Map<Id, Decimal> mapOfItemsWithPrice = new Map<Id, Decimal>();
        for (Driver_Item__c driverItem : listOfDriverItems) {
            mapOfItemsWithQuantity.put(driverItem.Marketing_Item__c, Integer.valueOf(driverItem.Quantity__c));
            mapOfItemsWithID.put(driverItem.Marketing_Item__c, driverItem.Id);
            mapOfItemsWithPrice.put(driverItem.Marketing_Item__c, POCPlanningApp.cleanValue(driverItem.Item_Price__c));
        }

        Map<Id, Brand__c> tempListOfBrandData = new Map<Id, Brand__c>();
        Map<Id, List<POCPlanningApp.ProgramItem>> ProgramItemListByBrandID = new Map<Id, List<POCPlanningApp.ProgramItem>>();
        Map<Id, Decimal> itemSpendByBrand = new Map<Id, Decimal>();
        List<Id> listOfIDs = new List<Id>();
        for (Marketing_Item__c item : listOfItems) {
            listOfIDs.add(item.Id);
        }

        Map<Id, Decimal> mapOfItemsWithQuantityRemaining = new Map<Id, Decimal>();
        Map<Id, Decimal> mapOfItemsWithMaxShopped = new Map<Id, Decimal>();

        //system.debug('Pre listOfInventory');

        List<Area_Item_Inventory__c> listOfInventory = [SELECT Marketing_Item__c, Specialty_Quantity_Allocated_to_Area__c, Specialty_Quantity_Remaining__c, Quantity_Remaining__c, Quantity_Allocated_to_Area__c FROM Area_Item_Inventory__c WHERE Marketing_Item__c IN :listOfIDs AND Labatt_Region__c = :Region];
        for (Area_Item_Inventory__c areaItemInventory : listOfInventory) {
            if (isSpecialty && areaItemInventory.Quantity_Remaining__c < areaItemInventory.Specialty_Quantity_Remaining__c) {
                mapOfItemsWithQuantityRemaining.put(areaItemInventory.Marketing_Item__c ,areaItemInventory.Specialty_Quantity_Remaining__c);
                mapOfItemsWithMaxShopped.put(areaItemInventory.Marketing_Item__c ,areaItemInventory.Specialty_Quantity_Allocated_to_Area__c);
            } else {
                mapOfItemsWithQuantityRemaining.put(areaItemInventory.Marketing_Item__c ,areaItemInventory.Quantity_Remaining__c);
                mapOfItemsWithMaxShopped.put(areaItemInventory.Marketing_Item__c ,areaItemInventory.Quantity_Allocated_to_Area__c);
            }
        }

        //system.debug('listOfInventory: ' + listOfInventory);

        for (Marketing_Item__c item : listOfItems) {
            if (!ProgramItemListByBrandID.containsKey(item.Brand__c)) {
                ProgramItemListByBrandID.put(item.Brand__c, new List<POCPlanningApp.ProgramItem>());
                Brand__c tempBrand = new Brand__c();
                tempBrand.Name = item.Brand__r.Name;
                tempBrand.Brand_Hex_Color__c = item.Brand__r.Brand_Hex_Color__c;
                tempListOfBrandData.put(item.Brand__c, tempBrand);
                itemSpendByBrand.put(item.Brand__c, 0);
            }

            POCPlanningApp.ProgramItem TempProgItem = new POCPlanningApp.ProgramItem();
            TempProgItem.Id = item.Id;
            TempProgItem.Name = item.Name;
            TempProgItem.SmlImage = item.Sml_Image_Link__c;
            TempProgItem.LrgImage = item.Lrg_Image_Link__c;
            TempProgItem.Size = item.Size__c;
            TempProgItem.Dimensions = item.Item_Dimensions__c;
            TempProgItem.Material = item.Material__c;


            if (UserInfo.getLanguage().containsIgnoreCase('fr')) {
                TempProgItem.Description = item.Item_Description_FR__c;
                TempProgItem.Item_Type = item.Item_Type_FR__c;
            } else {
                TempProgItem.Description = item.Item_Description_EN__c;
                TempProgItem.Item_Type = item.Item_Type_EN__c;
            }
            
            if (mapOfItemsWithPrice.containsKey(item.Id)) {
                TempProgItem.Price = mapOfItemsWithPrice.get(item.Id);
                system.debug('Item.Price: ' + mapOfItemsWithPrice.get(item.Id));
            } else {
                TempProgItem.Price = POCPlanningApp.cleanValue(item.Price__c);
            }

            //system.debug('mapOfItemsWithQuantity');
            if (mapOfItemsWithQuantity.containsKey(item.Id)) {
                TempProgItem.Qty = mapOfItemsWithQuantity.get(item.Id);
                itemSpendByBrand.put(item.Brand__c, itemSpendByBrand.get(item.Brand__c) + (POCPlanningApp.cleanValue(Item.Price__c) * mapOfItemsWithQuantity.get(item.Id)) );
            } else {
                TempProgItem.Qty = 0;
            }

            //system.debug('mapOfItemsWithQuantityRemaining');
            if (mapOfItemsWithQuantityRemaining.containsKey(item.Id)) {
                TempProgItem.QtyRmng = mapOfItemsWithQuantityRemaining.get(item.Id).intValue();
            } else {
                TempProgItem.QtyRmng = null;
            }

            if (mapOfItemsWithMaxShopped.containsKey(item.Id)) {
                TempProgItem.QtyAllocatedToArea = mapOfItemsWithMaxShopped.get(item.Id).intValue();
            } else {
                TempProgItem.QtyAllocatedToArea = null;
            }

            if (mapOfItemsWithID.containsKey(item.Id)) {
                TempProgItem.AltID = mapOfItemsWithID.get(item.Id);
            } else {
                TempProgItem.AltID = null;
            }

            TempProgItem.POCSpendCategory = pocSpendCategoryList[0].Id;

            List<POCPlanningApp.ProgramItem> newList = ProgramItemListByBrandID.get(item.Brand__c);
            //system.debug(TempProgItem);
            newList.add(TempProgItem);
            ProgramItemListByBrandID.put(item.Brand__c, newList);
        }

        List<DriverBrand> brands = new List<DriverBrand>();
        for (Id brandID : ProgramItemListByBrandID.keySet()) {
            DriverBrand driverBrand = new DriverBrand();
            driverBrand.Name = tempListOfBrandData.get(BrandID).Name;
            driverBrand.Id = brandID;
            driverBrand.ItemSpend = itemSpendByBrand.get(BrandID);
            driverBrand.HexColor = tempListOfBrandData.get(BrandID).Brand_Hex_Color__c;
            driverBrand.itemList = ProgramItemListByBrandID.get(brandID);
            system.debug(driverBrand);
            brands.add(driverBrand);
        }

        return brands;
    }

    public class DriverBrand {
        public String Name {get; set;}
        public String Id {get; set;}
        public Decimal ItemSpend {get; set;}
        public String HexColor {get; set;}
        public List<POCPlanningApp.ProgramItem> itemList {get; set;}
        public DriverBrand() {
            itemList = new List<POCPlanningApp.ProgramItem>();
        }
    }

    public class QtyRmngResponse {
        public Integer QtyRmng {get; set;}
        public Boolean IsSuccess {get; set;}
        public Integer OldQty {get; set;}
        public String DriverItemId {get; set;}
    }
}