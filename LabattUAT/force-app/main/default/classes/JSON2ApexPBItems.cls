/***
* @Name - JSON2ApexPBItems
* @Author - Ragbirendra Upadhyay, Ankita Sarda , Amol Parab
* @CreatedDate -09/15/2019
* @Description - 
* 

***/
public class JSON2ApexPBItems {
	
    public String BrandName;
	public String varCurrency;
	public String IsIHOnly;
	public String ForDRIVERSONLY;
	public String ProgramName;
	public String ProgramDescription;
	public String ProgramStartDate;
	public String ProgramEndDate;
	public String PlanningStartDate;
    public String PlanningEndDate;
	public String BusinessLine;
	public String SAPItemNumber;
	public String TempItemNumber;
	public String ProductName;
    public String Size;
    public String Language;
	public String UnitOfMeasure;
	public String Currency2;
    public String isUserPaid;
	public Integer QuantityPerUOM;
    public Double StandardPrice;
    public Double FullPriceToRep;
	public String ItemType;
	public String OOHItemClassification;
    public String IHItemClassification;
    public String ItemClassification;
    public String Atlantic;
    public String Quebec;
	public String Ontario;
	public String West;
    public String MenuCategory;
    public String ItemDescriptionEN;
	public String ItemDescriptionFR;
    public String ParentProductType;
    public String ProductType;
    public string IsProgramOnly;
    public string IsAllocationOnly;
    public String IsAvailable;
    public String Year;
   
    
	public static List<JSON2ApexPBItems> parse(String jsonParser) {
        system.debug('jsonParser'+jsonParser);
		return (List<JSON2ApexPBItems>) System.JSON.deserialize(jsonParser, List<JSON2ApexPBItems>.class);
	}
    
}