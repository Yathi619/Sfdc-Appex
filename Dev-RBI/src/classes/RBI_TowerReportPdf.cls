/*
    Type:       Custom Controller
    Purpose:    Used to generate the Tower Report for a project from Customer Portal.         

    Used By:   RBI_GenerateTowerReportPDF.page
    ----------------------------------------------------------------------------------
    History:

    26-Apr-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_TowerReportPdf {
    public list<Tower__c> towList {get;set;}
    public list<Tower__c> totalList{get; set;}
    public list<Project_Feedback__c> feedlist;
    public list<Customer_Projects__c> prjweights{get; set;}
    Set<Id> towerIds = new Set<Id>();
    public Project__c objproject {get;set;}
    public list<CStatuswrapper> WrapperCSList {get; set;} 
    public list<CStatuswrapper> TotalWrapperCSList{get; set;}
    public list<Project_Feedback__c> feedRemark{get; set;}
    public list<Project_Feedback__c> feedStatApp{get; set;}
    public Integer TotalFloors{get; set;}
    public Integer ResCommCompare{get; set;}
    Integer noOfTowerRec;
    Double totalPhaseComp;
    public Double average;
    public long longAverage {get;set;}
    
    //For Bar graph
	List<ChartDataItem> items;
	public string ChartData {get;set;}
    
    public Construction_Status__c ConStat {get;set;}
    public Customer_Projects__c CustWeights {get;set;}
    public decimal calcCS;
    public decimal calcCSRoundDown;
    public ApexPages.StandardController std;
    public String towIdFromURL = '';
    List<string> towId = new list<string>();
   
    /* Project Details */
    public String ProjectName {get; set;}
    public String ProjectId {get;set;}
    public String PrjId {get;set;}
    public String ProjectPhase {get; set;}
    public String DeveloperName {get; set;}
    public String DeveloperAddress{get; set;}
    public String ContactPerson{get; set;}
    public String ProjectAddress{get; set;}
    public String FARDeviation{get; set;}
    
    public map<Id, String> mapTowerUnitType {get; set;} 
    private string AcctId     = '';
    public boolean IsPorEnabled {get;set;}    
    private string RBIaccnt = '';
	list<AWS_S3_Object__c> imgList;
	public list<imgdata> imgurlList{get; set;}    
   
    public RBI_TowerReportPdf(){
        towList = new list<Tower__c>();
        totalList = new list<Tower__c>();
        feedlist = new list<Project_Feedback__c>();
        prjweights = new list<Customer_Projects__c>();
        feedRemark = new list<Project_Feedback__c>();
        feedStatApp = new list<Project_Feedback__c>();
        
        RBIaccnt =  System.Label.RBI_AccountId;
        AcctId = UserUtil.CurrentUser.AccountId; //Logged in user's account id
        AcctId = (AcctId == null || AcctId == '')?RBIaccnt:AcctId; //set account id to RBI cust record in case it is null
        items = new List<ChartDataItem>(); //graph
        towIdFromURL = ApexPages.currentPage().getParameters().get('TowerList');
        if(towIdFromURL!= null){
        	towIdFromURL = towIdFromURL.substring(1, towIdFromURL.length());
       		towIdFromURL = towIdFromURL.substring(0, towIdFromURL.length()-1);
        	towId = towIdFromURL.split(',');
        	
        }
        ProjectName = '';
        WrapperCSList = new list<CStatuswrapper>();
        noOfTowerRec = 0;
        totalPhaseComp = 0.0;
        average = 0.0;
        longAverage = 0;
        
    }   
    
    public void QueryTower(){
        for(string tifu : towId){
            Id tifuid = tifu.trim();
            towerIds.add(tifuid);
        }
    
        QueryAWS();
        towList = [SELECT Max_Avg_Developer_BSP_per_Sq_Ft__c,Max_Avg_Resale_Price_Per_Sqft__c, Min_Avg_Developer_BSP_per_Sq_Ft__c,
                    Min_Avg_Resale_Price_Per_Sqft__c , Deviation__c, Id, Total_Floors__c, ResCommCompare__c, Launched_Units__c, Construction_Start_Date__c, Launch_Date__c,
                    Proposed_Completion_Date__c, Actual_Basement_Floors__c, Planned_Basement_Floors__c, Actual_Parking_Floors__c,
                    Planned_Parking_Floors__c, Actual_ResCom_Floors__c, Planned_ResCom_Floors__c, Remarks__c, Name, Project_Name__c,Project__c,Project__r.name, 
                    Project__r.Site_Visit_Date__c,Project__r.Project_Phase__c, Project__r.Project_Phase__r.name, Project__r.Contact_Person__r.name,
                    Project__r.Contact_Person__c, Project__r.Developer_Name__c,Project__r.Developer_Address__c,Project__r.License_Registration_Number__c,
                    Project__r.Name_of_the_Municipal_Corporation__c,Project__r.Plot_Area__c, Project__r.construction_Status__c, Project__r.FSI_Deviation__c,Project__r.Site_Contact_NameDesg__c,
                    Project__r.Launch_Date__c,Project__r.Construction_Start_Date__c,Project__r.Expected_Possesion_Date__c, Project__r.Project_LatLong__Longitude__s,
                    Project__r.Project_LatLong__Latitude__s, Sold_Units__c,Structure_as_per_Brochure__c, Structure_as_per_Plan__c,
                    Total_Units__c, Project__r.Site_Address_Actual__c,
                    (Select Tower__c, Tower_Name__c, Excavation_of_Footings__c, Basement__c, RCC_Slab_Casting__c,
                    Masonary__c, Electrification_and_Sanitation__c, Finishing__c From Construction_Status__r ORDER BY LastModifiedDate DESC limit 1) 
                    FROM Tower__c where Id IN : towerIds];
                    
        if(towList != null && towList.size() > 0){
	        PrjId = towList[0].Project__c;
	        ProjectName = towList[0].Project_Name__c;           
	        ProjectId = towList[0].Project__r.name;
	        ProjectPhase = towList[0].Project__r.Project_Phase__r.Name;
	        DeveloperName = towList[0].Project__r.Developer_Name__c;  
	        DeveloperAddress = towList[0].Project__r.Developer_Address__c;
	        ContactPerson = towList[0].Project__r.Site_Contact_NameDesg__c;
	        ProjectAddress = towList[0].Project__r.Site_Address_Actual__c;
	        FARDeviation = towList[0].Project__r.FSI_Deviation__c;
        }
        
        /*Query for all the towers in the Projects*/
        totalList = [SELECT Max_Avg_Developer_BSP_per_Sq_Ft__c,Max_Avg_Resale_Price_Per_Sqft__c, Min_Avg_Developer_BSP_per_Sq_Ft__c,
                    Min_Avg_Resale_Price_Per_Sqft__c , Deviation__c, Id, Total_Floors__c, ResCommCompare__c, Launched_Units__c, Construction_Start_Date__c, Launch_Date__c,
                    Proposed_Completion_Date__c, Actual_Basement_Floors__c, Planned_Basement_Floors__c, Actual_Parking_Floors__c,
                    Planned_Parking_Floors__c, Actual_ResCom_Floors__c, Planned_ResCom_Floors__c, Remarks__c, Name, Project_Name__c,Project__c,Project__r.name, 
                    Project__r.Site_Visit_Date__c,Project__r.Project_Phase__c, Project__r.Project_Phase__r.name, Project__r.Contact_Person__r.name, 
                    Project__r.Contact_Person__c, Project__r.Developer_Name__c,Project__r.Developer_Address__c,Project__r.License_Registration_Number__c,
                    Project__r.Name_of_the_Municipal_Corporation__c,Project__r.Plot_Area__c, Project__r.construction_Status__c, Project__r.FSI_Deviation__c,
                    Project__r.Launch_Date__c,Project__r.Construction_Start_Date__c,Project__r.Expected_Possesion_Date__c, Project__r.Project_LatLong__Longitude__s,
                    Project__r.Project_LatLong__Latitude__s, Sold_Units__c,Structure_as_per_Brochure__c, Structure_as_per_Plan__c,
                    Total_Units__c, Project__r.Site_Address_Actual__c,
                    (Select Tower__c, Tower_Name__c, Excavation_of_Footings__c, Basement__c, RCC_Slab_Casting__c,
                    Masonary__c, Electrification_and_Sanitation__c, Finishing__c From Construction_Status__r ORDER BY LastModifiedDate DESC limit 1) 
                    FROM Tower__c where  Project__c = :PrjId ];
        if(totalList != null && totalList.size() > 0){
        
        	objproject = new Project__c(Expected_Possesion_Date__c = totalList[0].Project__r.Expected_Possesion_Date__c, 
	                    Project_Phase__c = totalList[0].Project__r.Project_Phase__c, Contact_Person__c = totalList[0].Project__r.Contact_Person__c, 
	                    License_Registration_Number__c = totalList[0].Project__r.License_Registration_Number__c, 
	                    Site_Visit_Date__c = totalList[0].Project__r.Site_Visit_Date__c, Project_LatLong__Longitude__s = totalList[0].Project__r.Project_LatLong__Longitude__s,
	                    Project_LatLong__Latitude__s = totalList[0].Project__r.Project_LatLong__Latitude__s,
	                    Name_of_the_Municipal_Corporation__c = totalList[0].Project__r.Name_of_the_Municipal_Corporation__c,
	                    Plot_Area__c = totalList[0].Project__r.Plot_Area__c, construction_Status__c = totalList[0].Project__r.construction_Status__c, 
	                    Launch_Date__c = totalList[0].Project__r.Launch_Date__c,
	                    Construction_Start_Date__c = totalList[0].Project__r.Construction_Start_Date__c);
        }
    } 
    
    public void mapForTowerUnitTypeValues(){
        set<Id> TowerIdsSet = new set<Id>();
        mapTowerUnitType = new map<Id, String>();
        set<Id> unitTypeIds;
        String unitTypeString;
        
        QueryTower();
        QueryFeedback();
        WeightsQuery();
        
    }
    
    /*Query the Project FeedBack Object*/
    public void QueryFeedback(){
        feedlist = [Select List_of_Values_Id__r.Name, List_of_Values_Id__r.Entity_Name__c,  Comments__c From Project_Feedback__c where Project__c =: PrjId];
        if(feedlist != null && feedlist.size() > 0){
        	for(Project_Feedback__c pf : feedlist){
            	if(pf.List_of_Values_Id__r.Entity_Name__c == 'Remark'){
                	feedRemark.add(pf);
            	}
            	else if(pf.List_of_Values_Id__r.Entity_Name__c == 'Statutory Approval'){
                	feedStatApp.add(pf);
            	}
        	}
        }
        
    }
    
    /*Query the Customer Project Object*/
    public void WeightsQuery(){ 
    	prjweights = new list<Customer_Projects__c>();
    	if(AcctId == RBIaccnt){
        	List <Account> accntlst = [Select Id, Name, Weightage_RCC_Slab_Casting__c, Weightage_Masonary__c, Weightage_Finishing__c, Weightage_Excavaton_of_Footings__c,
        					Weightage_Electrification_Sanitation__c, Weightage_Basement__c From Account where Id =:AcctId];
        	if(accntlst != null && accntlst.size() > 0){
        		Account accnt = accntlst[0];	
            	prjweights.add(new Customer_Projects__c(
            										Weightage_RCC_Slab_Casting__c = accnt.Weightage_RCC_Slab_Casting__c,
										            Weightage_Masonary__c = accnt.Weightage_Masonary__c,
										            Weightage_Finishing__c = accnt.Weightage_Finishing__c,
										            Weightage_Excavaton_of_Footings__c = accnt.Weightage_Excavaton_of_Footings__c,
										            Weightage_Electrification_Sanitation__c = accnt.Weightage_Electrification_Sanitation__c,
										            Weightage_Basement__c = accnt.Weightage_Basement__c, 
            	AccountId__c = accnt.Id));
        	}
      	}
        else{
        	prjweights = [select Project_Id__c, Weightage_Basement__c, Weightage_Electrification_Sanitation__c, Customer_Name__c,
                        Weightage_Excavaton_of_Footings__c, Weightage_Finishing__c, Weightage_Masonary__c,
                        Weightage_RCC_Slab_Casting__c from Customer_Projects__c where Project_Id__c =:PrjId and AccountId__c=:AcctId];
        
        }
        WrapperCSList = new list<CStatuswrapper>();
        TotalWrapperCSList = new list<CStatuswrapper>();
        if(prjweights != null && prjweights.size() > 0){
            for(Tower__c TL: totalList)
            {
                ConStat = new Construction_Status__c();
                Customer_Projects__c wtobj = new Customer_Projects__c();
                if(TL.Construction_Status__r != null && TL.Construction_Status__r.size() > 0){
                	ConStat = TL.Construction_Status__r;
	               	TotalFloors = (Integer)TL.Total_Floors__c;
	               	ResCommCompare = (Integer)TL.ResCommCompare__c;
	               	calcCS  = RBI_UtilClass.calculateconststatus(ConStat,prjweights[0],TotalFloors,ResCommCompare); 
	               	totalPhaseComp += calcCS;
	               	calcCSRoundDown = calcCS.setscale(2,System.RoundingMode.HALF_UP);
	               	noOfTowerRec++;
	               	TotalWrapperCSList.add(new CStatuswrapper(ConStat, calcCSRoundDown));
                }
               	
            }
            for(CStatuswrapper totWrap : TotalWrapperCSList){
            	for(Id towSelId : towerIds){
            		if(totWrap.CStatus.Tower__c == towSelId){
            			WrapperCSList.add(totWrap);
            			items.add(new ChartDataItem(totWrap.CStatus.Tower_Name__c, totWrap.TotConstStatus));//graph
            		}
            	}
            }
            if (noOfTowerRec != 0){
            	average = totalPhaseComp/noOfTowerRec;
            	longAverage = average.round();
	        }
        }
        loadChartData();
        
    }
    
    public class CStatuswrapper{
        public Construction_Status__c CStatus {get; set;} 
        public decimal TotConstStatus {get; set;}
        
        public CStatuswrapper(Construction_Status__c CS, decimal TCS)
        {
            CStatus = cs;
            TotConstStatus= TCS;
        }
    }
    
    //Method for loading chart data
	private void loadChartData()
	{
	 //Prepare the chart URL
	 	String chartPath = System.Label.RBI_BarChartlink;
	 	chartData 		 = chartPath +  getChartDataItem(items);
	 	chartData 		 = + chartData +'&chxr=1,0,100,10'+'&chtt= + '+ '&chg=0,10,0,0' + '&chts=000000,11.5';
	}
	
	//helper function for loadChartData
	private String getChartDataItem(List<ChartDataItem> items)
	{
	 String chd = ''; 
	 String chl = ''; 
	
	 for(ChartDataItem citem : items)
	 {
	    chd += citem.ItemValue + ',';
	    chl += citem.sLabel + '|';
	 }
	 //remove the last comma or pipe
	 
	 chd = (chd!='' && chd.length()>1)?(chd.substring(0, chd.length() -1)):chd;
	 chl = (chl!='' && chl.length()>1)?chl.substring(0, chl.length() -1):chl;
	
	 String result = '&chd=t:' + chd + '&chl=' + chl;
	 return result;
	}// end of method
	
	/*Query the AWS Object for Tower Images*/
    public void QueryAWS(){
    	Set <Id> setTowerIds = new Set <Id>();
		imgList 	= new list<AWS_S3_Object__c>();
		imgurlList  = new list<imgdata>();
		string qrystring;
		AWS_S3_ExampleController awscontroller = new AWS_S3_ExampleController();
		imgList = [select id,bucket_name__c,content_type__c, file_name__c, access__c,Project__c,Tower__c,Tower__r.Name,Tower__r.Project__c,Preview_Link__c,imageurl__c from AWS_S3_Object__c where Tower__c IN : towerIds order by Tower__c, createddate desc];
		for(AWS_S3_Object__c img :imgList){
			if(setTowerIds.add(img.Tower__c)){
				qrystring = '';
				qrystring = awscontroller.AWSLogin(img.file_name__c, img.bucket_name__c);
				imgurlList.add(new imgdata(qrystring,img.Tower__r.Name));
			}
		}
		
		
    }		      	
	//wrapper class for chart data
	
	public class ChartDataItem
	{
		 public Decimal ItemValue {get;set;}
		 public String sLabel {get;set;}
		 public ChartDataItem(String Lbl, Decimal Value)
		 {
		    this.sLabel = Lbl;
		    this.ItemValue = Value;
		  }
	}
   //wrapper class for chart data
	
	public class imgdata
	{
		 public String docurl {get;set;}
		 public String towername {get;set;}
		 public imgdata(String Lbl, string inpname)
		 {
		    this.docurl = Lbl;
		    this.towername = inpname;
		  }
	}
   
}