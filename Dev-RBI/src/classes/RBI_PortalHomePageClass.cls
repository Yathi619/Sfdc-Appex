/*
    Type:       Custom Controller
    Purpose:    Used to display the City-wise package details and Region-wise table on the Customer Portal Home Page          

    Used By:   RBI_PortalHomePage.page
    ---------------------------------------------------------------
    History:

    29-Apr-2013         Created		Tugboat Info Solutions Pvt.Ltd

*/
public with sharing class RBI_PortalHomePageClass {
	public list<Customer_Projects__c> approvallist;
    list<Project_Cust_Packages__c> custPackageList;
    /*public Integer EastPASTotal;
    public Integer EastPMSTotal;
    public Integer WestPASTotal;
    public Integer WestPMSTotal;
    public Integer NorthPASTotal;
    public Integer NorthPMSTotal;
    public Integer SouthPASTotal;
    public Integer SouthPMSTotal;*/
    Integer EastTotal;
    Integer WestTotal;
    Integer NorthTotal;
    Integer SouthTotal;
    
    public set<Id> EastPASTotSet;
    public set<Id> WestPASTotSet;
    public set<Id> NorthPASTotSet;
    public set<Id> SouthPASTotSet;
    
    public set<Id> EastPMSTotSet;
    public set<Id> WestPMSTotSet;
    public set<Id> NorthPMSTotSet;
    public set<Id> SouthPMSTotSet;
    
    public RegionWrapper regionWrapForReport;
    public map<String, RegionWrapper> mapOfRegionwrapper {get;set;}
    public String customerId = ''; 
    
    public Integer EastPASCustRec;
    public Integer EastPMSCustRec;
    public Integer WestPASCustRec;
    public Integer WestPMSCustRec;
    public Integer NorthPASCustRec;
    public Integer NorthPMSCustRec;
    public Integer SouthPASCustRec;
    public Integer SouthPMSCustRec;
    public Integer i;
    public string s='';
    public Integer j;
    public string s1='';
    public Integer alertCount {get;set;}
    
    Map<String,CityData> totalCustCitydataMap;
    public list<CityData> totalWrapCityData {get;set;}
	Set <Id> custprojids;
	Map<String, String> custpackageidsMap;
	    
    public RBI_PortalHomePageClass(){
    	string mapkey;
    	alertCount=0;
    	customerId          = UserUtil.CurrentUser.AccountId; //Logged in user's account id
    	approvallist = [Select Id, Name, Project_Name__c, Project_Id__c, Remarks__c, Project_Approval_Status__c, Project_Id__r.City__c
         From Customer_Projects__c where AccountId__c = : customerId and Project_Approval_Status__c = 'In Progress' and Project_Status__c = 'PMR'];
	  	//Used to check if the Customer is having PAS service
	     custprojids = new set<id>();  		
	  	 for (Customer_Projects__c o : approvallist) {
	        	custprojids.add( o.id );
	     }         
         LoadCustPackagesMap();
		 for(Customer_Projects__c proj : approvallist){
				mapkey = proj.Name+'-PAS';
				if(custpackageidsMap.containsKey(mapkey)){		
					alertCount++;
				}	
		 }         
         /*if(approvallist != null){
            alertCount = approvallist.size();
        
         }*/
    	custPackageList = new list<Project_Cust_Packages__c>();
        custPackageList = [select name,Customer_Project__c, Customer_Project__r.AccountId__c, Customer_Project__r.Project_Id__c, List_of_Values__r.name, Customer_Project__r.Project_Region__c from Project_Cust_Packages__c where Customer_Project__r.AccountId__c =: customerId];
        
        if(custPackageList != null && custPackageList.size()>0){
            
        	customerId          = UserUtil.CurrentUser.AccountId; //Logged in user's account id         
            mapOfRegionwrapper = new map<String, RegionWrapper>();
            list<Project_Cust_Packages__c> custPackageListDup = new list<Project_Cust_Packages__c>();
            custPackageListDup.addAll(custPackageList);
                /*EastPASTotal = 0;
                EastPMSTotal = 0;
                WestPASTotal = 0;
                WestPMSTotal = 0;
                NorthPASTotal = 0;
                NorthPMSTotal = 0;
                SouthPASTotal = 0;
                SouthPMSTotal = 0;*/
    			EastTotal = 0;
    			WestTotal = 0;
    			NorthTotal = 0;
    			SouthTotal = 0;                
                EastPASTotSet = new set<Id>();
                WestPASTotSet = new set<Id>();
                NorthPASTotSet = new set<Id>();
                SouthPASTotSet = new set<Id>();
                
                EastPMSTotSet = new set<Id>();
                WestPMSTotSet = new set<Id>();
                NorthPMSTotSet = new set<Id>();
                SouthPMSTotSet = new set<Id>();
                
                EastPASCustRec = 0;
                EastPMSCustRec = 0;
                WestPASCustRec = 0;
                WestPMSCustRec = 0;
                NorthPASCustRec = 0;
                NorthPMSCustRec = 0;
                SouthPASCustRec = 0;
                SouthPMSCustRec = 0;
				List<aggregateResult> rgnaggrList = new list<aggregateResult>();  
				string trgn = '';
		        rgnaggrList = [Select count_distinct(Id) totalrgncount, Project_Region__c projregn from Project__c group by Project_Region__c order by Project_Region__c];
		        for(aggregateResult ragg : rgnaggrList){
		    	       	trgn = (string)ragg.get('projregn');
		        	if(trgn == 'East')
		        		EastTotal = (Integer)ragg.get('totalrgncount');
		        	else if(trgn == 'West')
		        		WestTotal = (Integer)ragg.get('totalrgncount');
			       	else if(trgn == 'North')
		        		NorthTotal = (Integer)ragg.get('totalrgncount');        		
			       	else if(trgn == 'South')
		        		SouthTotal = (Integer)ragg.get('totalrgncount');        		        		
		        }				
				              
                for(Project_Cust_Packages__c custPack : custPackageList){
                	if(custPack.List_of_Values__r.name == 'PAS'){
                           /* if(custPack.Customer_Project__r.Project_Region__c == 'East')
                            {
                                if(EastPASTotSet.add(custPack.Customer_Project__r.Project_Id__c))
                                    EastPASTotal++;
                            }
                            else if(custPack.Customer_Project__r.Project_Region__c == 'West')
                            {
                                if(WestPASTotSet.add(custPack.Customer_Project__r.Project_Id__c))
                                    WestPASTotal++;
                            }
                            else if(custPack.Customer_Project__r.Project_Region__c == 'North')
                            {
                                if(NorthPASTotSet.add(custPack.Customer_Project__r.Project_Id__c))
                                    NorthPASTotal++;
                            }
                            else if(custPack.Customer_Project__r.Project_Region__c == 'South')
                            {
                                if(SouthPASTotSet.add(custPack.Customer_Project__r.Project_Id__c))
                                    SouthPASTotal++;
                            }*/
                            
                                if(custPack.Customer_Project__r.Project_Region__c == 'East')
                                    EastPASCustRec++;
                                else if(custPack.Customer_Project__r.Project_Region__c == 'West')
                                    WestPASCustRec++;
                                else if(custPack.Customer_Project__r.Project_Region__c == 'North')
                                    NorthPASCustRec++;
                                else if(custPack.Customer_Project__r.Project_Region__c == 'South')
                                    SouthPASCustRec++;
                                
                            
                        }
                        
                        else if(custPack.List_of_Values__r.name == 'PMS'){
                            /*if(custPack.Customer_Project__r.Project_Region__c == 'East')
                            {
                                if(EastPMSTotSet.add(custPack.Customer_Project__r.Project_Id__c))
                                    EastPMSTotal++;
                            }
                            else if(custPack.Customer_Project__r.Project_Region__c == 'West')
                            {
                                if(WestPMSTotSet.add(custPack.Customer_Project__r.Project_Id__c))
                                    WestPMSTotal++;
                            }
                            else if(custPack.Customer_Project__r.Project_Region__c == 'North')
                            {
                                if(NorthPMSTotSet.add(custPack.Customer_Project__r.Project_Id__c))
                                    NorthPMSTotal++;
                            }
                            else if(custPack.Customer_Project__r.Project_Region__c == 'South')
                            {
                                if(SouthPMSTotSet.add(custPack.Customer_Project__r.Project_Id__c))
                                    SouthPMSTotal++;
                            }
                              */  
                            if(custPack.Customer_Project__r.Project_Region__c == 'East')
                                EastPMSCustRec++;
                            else if(custPack.Customer_Project__r.Project_Region__c == 'West')
                                WestPMSCustRec++;
                            else if(custPack.Customer_Project__r.Project_Region__c == 'North')
                                NorthPMSCustRec++;
                            else if(custPack.Customer_Project__r.Project_Region__c == 'South')
                                SouthPMSCustRec++;
                        }
           
             }
            regionWrapForReport = new RegionWrapper(EastTotal, EastPASCustRec, EastTotal, EastPMSCustRec);
            mapOfRegionwrapper.put('East', regionWrapForReport);
        
            regionWrapForReport = new RegionWrapper(WestTotal, WestPASCustRec, WestTotal, WestPMSCustRec);
            mapOfRegionwrapper.put('West', regionWrapForReport);
        
            regionWrapForReport = new RegionWrapper(NorthTotal, NorthPASCustRec, NorthTotal, NorthPMSCustRec);
            mapOfRegionwrapper.put('North', regionWrapForReport);
        
            regionWrapForReport = new RegionWrapper(SouthTotal, SouthPASCustRec, SouthTotal, SouthPMSCustRec);
            mapOfRegionwrapper.put('South', regionWrapForReport);            
            
        }
   
    }
    
    public class RegionWrapper{
        public Integer PASTotal {get;set;}
        public Integer PMSTotal {get;set;}
        public Integer PASCustRec {get;set;}
        public Integer PMSCustRec {get;set;}
        
        public RegionWrapper(Integer PATotal, Integer PACustRec, Integer PMTotal, Integer PMCustRec){
            
            PASTotal = PATotal;
            PMSTotal = PMTotal;
            PASCustRec = PACustRec;
            PMSCustRec = PMCustRec;
        }
    }

    public List<PieWedgeData> getBarDataPAS() {
        List<PieWedgeData> data = new List<PieWedgeData>();
        if(mapOfRegionwrapper != null && mapOfRegionwrapper.size()>0){
        data.add(new PieWedgeData('North', mapOfRegionwrapper.get('North').PASCustRec, mapOfRegionwrapper.get('North').PASTotal, '0'));
        data.add(new PieWedgeData('South', mapOfRegionwrapper.get('South').PASCustRec, mapOfRegionwrapper.get('South').PASTotal, '100'));
        data.add(new PieWedgeData('East', mapOfRegionwrapper.get('East').PASCustRec, mapOfRegionwrapper.get('East').PASTotal, s));
        data.add(new PieWedgeData('West', mapOfRegionwrapper.get('West').PASCustRec, mapOfRegionwrapper.get('West').PASTotal, '0'));
        }
        return data;
    }
     public List<PieWedgeData> getBarDataPMS() {
        List<PieWedgeData> data = new List<PieWedgeData>();
        if(mapOfRegionwrapper != null && mapOfRegionwrapper.size()>0){        
        data.add(new PieWedgeData('North', mapOfRegionwrapper.get('North').PMSCustRec, mapOfRegionwrapper.get('North').PMSTotal, '0'));
        data.add(new PieWedgeData('South', mapOfRegionwrapper.get('South').PMSCustRec, mapOfRegionwrapper.get('South').PMSTotal, '100'));
        data.add(new PieWedgeData('East', mapOfRegionwrapper.get('East').PMSCustRec, mapOfRegionwrapper.get('East').PMSTotal, '0'));
        data.add(new PieWedgeData('West', mapOfRegionwrapper.get('West').PMSCustRec, mapOfRegionwrapper.get('West').PMSTotal, s1));
        }
        return data;
    }

    // Wrapper class
    public class PieWedgeData {

        public String name { get; set; }
        public Integer data { get; set; }
        public Integer data1 { get; set; }
        public String data2 { get; set; }
       
        public PieWedgeData(String name, Integer data,Integer data1, String data2) {
            this.name = name;
            this.data = data;
            this.data1 = data1;
            this.data2 = data2;
        }
    }
    
    public list<CityData> getCityTableData(){
    	totalCustCitydataMap = new Map<String,CityData>();
    	totalWrapCityData = new list<CityData>();
    	
        Map<String,CityData> CustCitydataMap;
        CustCitydataMap = new Map<String,CityData>();
        List<CityData> tabledata = new List<CityData>();
        List<aggregateResult> aggrList = new list<aggregateResult>();
        CityData custcitydata;
        CityData totalcitydata;
        string tcity = '';
        string csPack = '';
        Double aggrPAS  = 0; // stores PAS record count of all cities
        Double aggrPMS  = 0; // stores PMS record count of all cities
        Double aggrCustPAS = 0; // stores Customer PAS record count of all cities
        Double aggrCustPMS = 0; // stores Customer PMS record count of all cities        
        Double projcount  = 0; //store citywise project count
        
        aggrList = [Select count_distinct(Id) totalcount, Site_Address_City__c city from Project__c group by Site_Address_City__c order by Site_Address_City__c];
        for(aggregateResult agg : aggrList){
        	tcity 				   = (string)agg.get('city');
        	projcount 			   = (Integer)agg.get('totalcount');
        	aggrPAS += projcount;
        	CustCitydataMap.put(tcity, new CityData((string)agg.get('city'),projcount,projcount,0,0));
        }
        List<aggregateResult> aggrListcust = new list<aggregateResult>();
        aggrListcust = [Select count_distinct(Project_Id__c) totalcust,Customer_Project__r.Project_Id__r.Site_Address_City__c city, List_of_Values__r.Name csPack1 
                        From Project_Cust_Packages__c  where Customer_Project__r.AccountId__c=:customerId group by Customer_Project__r.Project_Id__r.Site_Address_City__c
                        ,List_of_Values__r.Name order by Customer_Project__r.Project_Id__r.Site_Address_City__c asc];
        string csPack1 = '';
		for(aggregateResult aggcust : aggrListcust){
            custcitydata = CustCitydataMap.get((string)aggcust.get('city'));
            csPack1       = (string)aggcust.get('csPack1');
            if(csPack1 =='PAS')
            {
                custcitydata.CustTotalPAS = (integer)aggcust.get('totalcust');
                custcitydata.CovrgPAS = (custcitydata.TotalPAS == 0)?0:((custcitydata.CustTotalPAS/custcitydata.TotalPAS)*100);
                CustCitydataMap.put((string)aggcust.get('city'), custcitydata);
                aggrCustPAS += (Integer)aggcust.get('totalcust');
                
            }
            else if(csPack1 =='PMS'){
                custcitydata.CustTotalPMS = (integer)aggcust.get('totalcust');
                custcitydata.CovrgPMS = (custcitydata.TotalPMS == 0)?0:((custcitydata.CustTotalPMS/custcitydata.TotalPMS)*100);             
                CustCitydataMap.put((string)aggcust.get('city'), custcitydata);
                aggrCustPMS += (Integer)aggcust.get('totalcust');   
            }
        }
        CityData aggrcitydata = new CityData('Total', aggrPAS, aggrPAS, aggrCustPAS, aggrCustPMS);
        aggrcitydata.CovrgPAS = (aggrPAS == 0)?0:((aggrCustPAS/aggrPAS)*100);
        aggrcitydata.CovrgPMS = (aggrPAS == 0)?0:((aggrCustPMS/aggrPAS)*100);
        
        totalCustCitydataMap.put('Total', aggrcitydata);     
        
        tabledata = CustCitydataMap.values();
        totalWrapCityData = totalCustCitydataMap.values();
       //}
        return tabledata;
    }
    // Wrapper class for citywise total
    public class CityData {

        public String  Cityname  { get; set; }
        public Double TotalPAS  { get; set; }
        public Double CustTotalPAS { get; set; }
        public Double TotalPMS   { get; set; }
        public Double CustTotalPMS { get; set; }
        public Double CovrgPMS { get; set; }
        public Double CovrgPAS { get; set; }
        

        public CityData(){
            Cityname = '';
            TotalPAS = 0;
            TotalPMS = 0;
            CustTotalPAS = 0;
            CustTotalPMS = 0;
            CovrgPMS = 0;
            CovrgPAS = 0;
        }
        public CityData(String City, Double totPAS,Double totPMS, Double custtotalPAS, Double custtotalPMS) {
            this.Cityname = City;
            this.TotalPAS = totPAS;
            this.TotalPMS = totPMS;
            this.CustTotalPAS = custtotalPAS;
            this.CustTotalPMS = custtotalPMS;
            this.CovrgPMS = 0;
            this.CovrgPAS = 0;            
             
        }
    }  
        // Helper function to load customer package map.USed to check PAS service
    private void LoadCustPackagesMap(){
		custpackageidsMap = new Map<String, String>();
		List <Project_Cust_Packages__c> custservlist;
                custservlist = [select Customer_Project__r.Name,Name,Customer_Project__r.Project_Id__r.Id,
                		List_of_Values__r.Name,IsContractInActive__c from Project_Cust_Packages__c
                		where Customer_Project__c IN :custprojids AND IsContractInActive__c !='Y' 
                		order by List_of_Values__r.Value__c ASC];
                		
				 for (Project_Cust_Packages__c cpkg : custservlist) {
                            custpackageidsMap.put(cpkg.Customer_Project__r.Name+'-'+cpkg.List_of_Values__r.Name,cpkg.Id);
                 }      	
    } 
    
}