/*
    Type:       Custom Controller
    Purpose:    Used to generate the Detail Technical Report for a Customer from Customer Portal.        

    Used By:   RBI_Detail_Technical_Report_PDF.page
    ---------------------------------------------------------------
    History:

    26-Apr-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_DTReportExtension {
	public Tower__c Tower{get; set;}
	public Unit__c Unit{get; set;}
	public list <Tower__c> towerlist {get;set;}
	set<Id> TowerIdsSet = new set<Id>();
	public Project__c prj{get; set;}
	public String ProjectPhase {get; set;}
	public String ContactPerson{get; set;}
	public ApexPages.StandardController sController;
	public list<Project_Feedback__c> feedStatApp{get; set;}
	public list<Project_Feedback__c> feedlist;
	public list<Project_Feedback__c> feedRemark{get; set;}
	public list<Query__c> QueryException{get; set;} //Created for 2nd Phase Date:25.07.2013
	public list<Visit__c> vstList{get; set;} //Created for 2nd Phase Date:25.07.2013
	public list<CStatuswrapper> WrapperCSList {get; set;} 
    public list<CStatuswrapper> TotalWrapperCSList{get; set;}
    public list<Customer_Projects__c> prjweights{get; set;}
    public Integer TotalFloors{get; set;}
    public Integer ResCommCompare{get; set;}
    Integer noOfTowerRec;
    Double totalPhaseComp;
    public Double average{get;set;}
    public Construction_Status__c ConStat {get;set;}
    public Customer_Projects__c CustWeights {get;set;}
    public decimal calcCS {get;set;}
    public map<Id, String> mapTowerUnitType {get; set;} 
    private string AcctId     = '';
    public string fsideviation {get;set;}
    public list<aggregateResult> UnitList{get; set;}
    public list<aggregateResult> UnitQuery{get; set;}
    public list<floorStrucWrap> floorWrapForPDF {get;set;}
    public string unitTypeString {get;set;}
    public string unitTypeStringForMap {get;set;}
    public long longAverage {get;set;}
    public boolean IsPorEnabled {get;set;}    
    private string RBIaccnt = '';
	public decimal calcCSRoundDown;
	public string majorShareHoldDis {get;set;}
	public string majorShareHold = '';
	list<AWS_S3_Object__c> imgList;
	list<AWS_S3_Object__c> totalimgList;
	public list<RBI_TowerReportPdf.imgdata> imgurlList{get; set;} 		
	public RBI_DTReportExtension(ApexPages.StandardController stdCon)
	{
		sController = stdCon;
		this.prj=(Project__c)stdCon.getRecord();
		RBIaccnt =  System.Label.RBI_AccountId;
        AcctId = UserUtil.CurrentUser.AccountId; //Logged in user's account id
        AcctId = (AcctId == null || AcctId == '')?RBIaccnt:AcctId; //set account id to RBI cust record in case it is null
        IsPorEnabled = UserUtil.CurrentUser.IsPortalEnabled;
		towerlist = new list<Tower__c>();
		prjweights = new list<Customer_Projects__c>();
		feedlist = new list<Project_Feedback__c>();
        feedRemark = new list<Project_Feedback__c>();
        feedStatApp = new list<Project_Feedback__c>();
        QueryException = new list<Query__c>(); // Created for 2nd Phase
        WrapperCSList = new list<CStatuswrapper>();
        UnitList = new list<aggregateResult>();
        UnitQuery = new list<aggregateResult>();
       	floorWrapForPDF = new list<floorStrucWrap>();
        noOfTowerRec = 0;
        totalPhaseComp = 0.0;
        average = 0.0;
        queryTower();
        QueryFeedback();
        WeightsQuery();
        mapForTowerUnitTypeValues();
        QueryAWS();        
        QueryException();// Created for 2nd Phase Date 25.07.2013
	}
	
	public void queryTower(){
		
		towerlist = [SELECT Max_Avg_Developer_BSP_per_Sq_Ft__c,Max_Avg_Resale_Price_Per_Sqft__c, Min_Avg_Developer_BSP_per_Sq_Ft__c,Project__r.Contact_Person__r.name,
                    Min_Avg_Resale_Price_Per_Sqft__c , Deviation__c, Id, Total_Floors__c, ResCommCompare__c, Launched_Units__c, Construction_Start_Date__c, Launch_Date__c,
                    Proposed_Completion_Date__c, Actual_Basement_Floors__c, Planned_Basement_Floors__c, Actual_Parking_Floors__c,
                    Planned_Parking_Floors__c, Actual_ResCom_Floors__c, Planned_ResCom_Floors__c, Remarks__c, Name, Project__c, 
                    Sold_Units__c,Structure_as_per_Brochure__c, Structure_as_per_Plan__c,Total_Units__c, Project__r.Site_Address_Actual__c,
                    Project__r.Site_Contact_NameDesg__c,Project__r.Major_Shareholding_Group_1__c, Project__r.Major_Shareholding_Group_2__c,
                    Project__r.Major_Shareholding_Group_3__c,Project__r.Major_Shareholding_Group_4__c,
                    (Select Tower__c, Tower_Name__c, Excavation_of_Footings__c, Basement__c, RCC_Slab_Casting__c,
                    Masonary__c, Electrification_and_Sanitation__c, Finishing__c From Construction_Status__r ORDER BY LastModifiedDate DESC limit 1) 
                    FROM Tower__c where  Project__c = :prj.Id ORDER BY Name];
        if(towerlist != null && towerlist.size() > 0){			
			ContactPerson = towerList[0].Project__r.Site_Contact_NameDesg__c;
			if (towerList[0].Project__r.Major_Shareholding_Group_1__c != null && towerList[0].Project__r.Major_Shareholding_Group_1__c != '')
				majorShareHold += towerList[0].Project__r.Major_Shareholding_Group_1__c + ','; 
			
			if (towerList[0].Project__r.Major_Shareholding_Group_2__c != null && towerList[0].Project__r.Major_Shareholding_Group_2__c != '')
				majorShareHold += towerList[0].Project__r.Major_Shareholding_Group_2__c + ',';
			
			if (towerList[0].Project__r.Major_Shareholding_Group_3__c != null && towerList[0].Project__r.Major_Shareholding_Group_3__c != '')
				majorShareHold += towerList[0].Project__r.Major_Shareholding_Group_3__c + ',' ;
			
			if (towerList[0].Project__r.Major_Shareholding_Group_4__c != null && towerList[0].Project__r.Major_Shareholding_Group_4__c != '')	
				majorShareHold += towerList[0].Project__r.Major_Shareholding_Group_4__c + ',';
			
			if (majorShareHold != '')
				majorShareHoldDis = majorShareHold.substring(0, majorShareHold.length()-1); 
			
			for (Tower__c TowIds : towerlist) {
           		TowerIdsSet.add(TowIds.Id);
            	
        	}
        	unitlist = [Select Unit_Type_Id__r.Unit_Type__c unittyp, Tower_Id__r.Name towername, COUNT(Name) cou, MAX(Unit_Type_Id__r.Carpet_Area_Sq_Ft__c) CarpetArea,
							MAX(Unit_Type_Id__r.Built_up_area_Sq_Ft__c) builtuparea, MAX(Unit_Type_Id__r.Super_Area_Sq_Ft__c) superbuiltuparea From Unit__c 
							WHERE  Tower_Id__c IN : TowerIdsSet
							GROUP BY Tower_Id__r.Name, Unit_Type_Id__r.Unit_Type__c];
			for(aggregateResult aggRes : unitlist){
				String towname = '';
				String unitType = '';
				Integer noOfUnit;
				Double cpparam;
				Double builtparam;
				Double superbuiltparam;
				
				towname  = (String) aggRes.get('towername');
				unitType = (String) aggRes.get('unittyp');
				noOfUnit = (Integer) aggRes.get('cou');
				cpparam = (Double) aggRes.get('CarpetArea');
				builtparam = (Double) aggRes.get('builtuparea');
				superbuiltparam = (Double) aggRes.get('superbuiltuparea');	
				floorWrapForPDF.add(new floorStrucWrap(towname, unitType, noOfUnit, cpparam, builtparam, superbuiltparam));
				
			}
				
        }
	}
	
	/*Query the Project FeedBack Object*/
    public void QueryFeedback(){
        feedlist = [Select List_of_Values_Id__r.Name, List_of_Values_Id__r.Entity_Name__c,  Comments__c From Project_Feedback__c where Project__c =: prj.Id];
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
    
    //Created for 2nd Phase Date: 25.07.2013
    /*Query the QueryException Object*/
    public void QueryException(){
    	vstList = [Select Name, Exception__c, Project__c, (Select Query_Resolved_Date__c, Closure_Remarks__c, Query_Description__c, Query_Initiated_Date__c,
    			   Exception_Status__c, Other_Remarks__c from Queries_Exceptions__r) From Visit__c where Project__c = :prj.Id and Visit_Report__c = 'First Technical Report'];
		if((vstList != null) && (vstList.size()>0)){    			   
    		QueryException = vstList[0].Queries_Exceptions__r;
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
    		prjweights = [select Project_Id__c, Weightage_Basement__c, Weightage_Electrification_Sanitation__c,Customer_Name__c,
                       	 Weightage_Excavaton_of_Footings__c, Weightage_Finishing__c, Weightage_Masonary__c,
                       	 Weightage_RCC_Slab_Casting__c from Customer_Projects__c where Project_Id__c =:prj.Id and AccountId__c=:AcctId];
        }
        
        	WrapperCSList = new list<CStatuswrapper>();
        	TotalWrapperCSList = new list<CStatuswrapper>();
       
        if(prjweights != null && prjweights.size() > 0){
            for(Tower__c TL: towerList)
            {
                ConStat = new Construction_Status__c();
                Customer_Projects__c wtobj = new Customer_Projects__c();
               /* ConStat = TL.Construction_Status__r;
                if(ConStat != null){*/
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
            if (noOfTowerRec != 0){
            	average = totalPhaseComp/noOfTowerRec;
            	longAverage = average.round();
            }
        }
    }
    
    public void mapForTowerUnitTypeValues(){
        set<Id> TowIdsSet = new set<Id>();
        mapTowerUnitType = new map<Id, String>();
        set<Id> unitTypeIds;
        unitTypeStringForMap = '';
        unitTypeString = '';
        unitQuery = [select Unit_Type_Id__r.Unit_Type__c unittyp from Unit__c where 
                    Tower_Id__c IN : TowerIdsSet GROUP BY Unit_Type_Id__r.Unit_Type__c];
        for(aggregateResult aggRes : unitQuery){
        	unitTypeString += (String) aggRes.get('unittyp');
        	unitTypeString +=',';
        }
        if (unitTypeString != null && unitTypeString != '')
        	unitTypeStringForMap = unitTypeString.substring(0, unitTypeString.length()-1); 
    }
    
   	/*Query the AWS Object for Tower Images*/
    public void QueryAWS(){
    	Set <Id> setTowerIds = new Set <Id>();    	
		imgList = new list<AWS_S3_Object__c>();
		totalimgList  = new list<AWS_S3_Object__c>();
		imgurlList  = new list<RBI_TowerReportPdf.imgdata>();
		string qrystring;
		AWS_S3_ExampleController awscontroller = new AWS_S3_ExampleController();				
		totalimgList = [select id,bucket_name__c,content_type__c, file_name__c, access__c,Project__c,Tower__c,Tower__r.Name,Tower__r.Project__c,Preview_Link__c,imageurl__c from AWS_S3_Object__c where Tower__r.Project__c = :prj.Id order by Tower__c, createddate desc];
		for(AWS_S3_Object__c awsobj : totalimgList){
		 if(setTowerIds.add(awsobj.Tower__c)){
			qrystring = '';
			qrystring = awscontroller.AWSLogin(awsobj.file_name__c, awsobj.bucket_name__c);
			imgurlList.add(new RBI_TowerReportPdf.imgdata(qrystring,awsobj.Tower__r.Name));			
		  }
		}		
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
    
    public class floorStrucWrap{
    	public String towname        {get;set;}
    	public String unitType     {get;set;} 
    	public Integer noOfUnits   {get;set;}
    	public Double carpetarea  {get;set;}
    	public Double builtuparea {get;set;}
    	public Double superbuiltuparea {get;set;}    	    	
    	public floorStrucWrap(String tname, String unitTyp, Integer noOfUni, Double cparea,Double btarea, Double sbtarea){
    		towname = tname;
    		unitType = unitTyp;
    		noOfUnits = noOfUni;
    		carpetarea = cparea;
    		builtuparea = btarea;
    		superbuiltuparea = sbtarea;
    	}
    }
}