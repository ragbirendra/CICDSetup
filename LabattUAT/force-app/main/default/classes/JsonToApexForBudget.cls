/***
* @Name - JsonToApexForBudget
* @Author - Ragbirendra Upadhyay, Ankita Sarda , Amol Parab
* @CreatedDate -09/15/2019
* @Description - 
* 

***/
public class JsonToApexForBudget {
    
        public String DistrictCode;
	    public String DistrictName;
	    public String Year; 	
	    public String BusinessLine;	
	    public String Region;	
	    public String TerritoryName;	
	    public String TerritoryCode;
        public String DiscretionaryBudget;
	    public String Brand;	
	    public String TerritoryBrandBudget;

    	public static List<JsonToApexForBudget> parse(String jsonParser) {
        system.debug('jsonParser'+jsonParser);
		return (List<JsonToApexForBudget>) System.JSON.deserialize(jsonParser, List<JsonToApexForBudget>.class);
	}

}