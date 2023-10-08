/***
* @Name - JSON2Apex
* @Author - Ragbirendra Upadhyay, Ankita Sarda , Amol Parab
* @CreatedDate -09/15/2019
* @Description - 
* 

***/

public class JSON2Apex {
    
    public String ShoppedKitName;
    public String ProgramName;
    public String ShopkitStartDate;
    public String ShopkitEndDate;
    public String ShopkitPrice;
    public String ShopkitSAPNumber;
    public String ShopkitTemporaryItemNumbers;
    public String ShopkitQty;
    public String Year;
    public String BusinessLine;
    
    public static List<JSON2Apex> parse(String json) {
        return (List<JSON2Apex>) System.JSON.deserialize(json, List<JSON2Apex>.class);
    }
}