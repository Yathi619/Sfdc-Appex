/*
    Type:       Custom Controller
    Purpose:    Used to Generate Project Report in PDF format by Customer in the Customer Portal.     

    Used By:   RBI_VisitReportPDF.page
    ----------------------------------------------------------------------------------
    History:

    30-Apr-2013     Created     Tugboat Info Solutions Pvt. Ltd

*/
public without sharing class RBI_VisitReportPDF {

    public Visit__c projvst{get; set;}
    string projectid;
    
    public Project__c prj{get; set;}
    public Tower__c Tower{get; set;}
    public Unit__c Unit{get; set;}
    public list <Visit__c> towerlist {get;set;}
    set<Id> TowerIdsSet = new set<Id>();
    public String ProjectPhase {get; set;}
    public String ContactPerson{get; set;}
    public ApexPages.StandardController sController;
    public list<Project_Feedback__c> feedStatApp{get; set;}
    public list<Project_Feedback__c> feedlist;
    public list<Project_Feedback__c> feedRemark{get; set;}  
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
    	public string unitTypeString {get;set;}
        public string unitTypeStringForMap {get;set;}
        public long longAverage {get;set;}
        public boolean IsPorEnabled {get;set;}    
        private string RBIaccnt = '';
        public string AcctName {get;set;}
    public decimal calcCSRoundDown;
    //For Bar graph
    List<ChartDataItem> items;
    public string ChartData {get;set;}
    list<AWS_S3_Object__c> imgList{get; set;}
	public list<RBI_TowerReportPdf.imgdata> imgurlList{get; set;} 	
	    
    public boolean disChart {get;set;} 
    public RBI_VisitReportPDF(ApexPages.StandardController stdCon)
    {
        sController = stdCon;
        this.projvst=(Visit__c)stdCon.getRecord();
        system.debug('projvst'+projvst);
        RBIaccnt =  System.Label.RBI_AccountId;
            AcctId = UserUtil.CurrentUser.AccountId; //Logged in user's account id
            AcctId = (AcctId == null || AcctId == '')?RBIaccnt:AcctId; //set account id to RBI cust record in case it is null
            IsPorEnabled = UserUtil.CurrentUser.IsPortalEnabled;
            AcctName = UserUtil.CurrentUser.contact.account.Name;
            towerlist = new list<Visit__c>();
            prjweights = new list<Customer_Projects__c>();
            feedlist = new list<Project_Feedback__c>();
            feedRemark = new list<Project_Feedback__c>();
            feedStatApp = new list<Project_Feedback__c>();
            WrapperCSList = new list<CStatuswrapper>();
            UnitList = new list<aggregateResult>();
            UnitQuery = new list<aggregateResult>();
            items = new List<ChartDataItem>(); //graph
            disChart = false;
            noOfTowerRec = 0;
            totalPhaseComp = 0.0;
            average = 0.0;
            queryTower();
            QueryFeedback();
            WeightsQuery();
            mapForTowerUnitTypeValues();
            QueryAWS();
        
    }
    
    public void queryTower(){
        
        towerlist = [SELECT Visit__r.Site_contact_NameDesg__c,Visit__r.Project__c,Tower__c,
                Max_Avg_Developer_BSP_per_Sqft__c,Max_Avg_Resale_Price_Per_Sqft__c, Min_Avg_Developer_BSP_per_Sqft__c,Min_Avg_Resale_Price_Per_Sqft__c,
                Deviation__c, Id, Launched_Units__c,Proposed_Completion_Date__c,Actual_Basement_Floors__c,Actual_Parking_Floors__c,
                Actual_ResCom_Floors__c,Remarks__c,Sold_Units__c,Res_Comm_Compare__c,
                Tower__r.Total_Floors__c, Tower__r.Construction_Start_Date__c,Tower__r.Launch_Date__c, 
                Tower__r.Planned_Basement_Floors__c,Tower__r.Planned_Parking_Floors__c, Tower__r.Planned_ResCom_Floors__c, 
                Tower__r.Name, Tower__r.Project__c,Tower__r.Project__r.Contact_Person__r.name,Tower__r.Total_Units__c, Tower__r.Project__r.Site_Address_Actual__c,
                (Select Tower_Visit__r.Tower__c, Tower_Visit__r.Tower__r.Name, Excavation_of_Footings__c, Basement__c, RCC_Slab_Casting__c,
                Masonary__c, Electrification_and_Sanitation__c, Finishing__c From TowerConstruction_Status__r ORDER BY LastModifiedDate DESC limit 1) 
                FROM Visit__c where  Visit__c = :projvst.Id ORDER BY Tower__r.Name];
      	if(towerlist != null && towerlist.size() > 0){           
        	if(towerList[0].Visit__r!=null){
            	ContactPerson = towerList[0].Visit__r.Site_Contact_NameDesg__c;
                projectid = towerList[0].Visit__r.Project__c;
            }
            for (Visit__c TowIds : towerlist) {
            	TowerIdsSet.add(TowIds.Tower__c);
            }
		}
    }
    
    /*Query the Project FeedBack Object*/
    public void QueryFeedback(){
        feedlist = [Select List_of_Values_Id__r.Name, List_of_Values_Id__r.Entity_Name__c,  Comments__c From Project_Feedback__c where Visit__c =: projvst.Id];
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
            prjweights = [select Project_Id__c, Weightage_Basement__c, Weightage_Electrification_Sanitation__c,Customer_Name__c,
                         Weightage_Excavaton_of_Footings__c, Weightage_Finishing__c, Weightage_Masonary__c,
                         Weightage_RCC_Slab_Casting__c from Customer_Projects__c where Project_Id__c =:projectid and AccountId__c=:AcctId];
        }

        WrapperCSList = new list<CStatuswrapper>();
        TotalWrapperCSList = new list<CStatuswrapper>();
        
        if(prjweights != null && prjweights.size() > 0){
            for(Visit__c TL: towerList){
                ConStat = new Construction_Status__c();
                Customer_Projects__c wtobj = new Customer_Projects__c();
                system.debug('AAA'+TL);
                if((TL.TowerConstruction_Status__r != null)&&(TL.TowerConstruction_Status__r.size()>0)){                
                	ConStat = TL.TowerConstruction_Status__r;
					TotalFloors = (Integer)TL.Tower__r.Total_Floors__c;
                    ResCommCompare = (Integer)TL.Res_Comm_Compare__c;
                    calcCS  = RBI_UtilClass.calculateconststatus(ConStat,prjweights[0],TotalFloors,ResCommCompare); 
                    totalPhaseComp += calcCS;
                    calcCSRoundDown = calcCS.setscale(2,System.RoundingMode.HALF_UP);
                    noOfTowerRec++;
                    TotalWrapperCSList.add(new CStatuswrapper(ConStat, calcCSRoundDown));
             	}
            }
            if (TotalWrapperCSList != null){
                for(CStatuswrapper totWrap : TotalWrapperCSList){
                    items.add(new ChartDataItem(totWrap.CStatus.Tower_Visit__r.Tower__r.Name, totWrap.TotConstStatus));//graph
                }
            }
            if (noOfTowerRec != 0){
                average = totalPhaseComp/noOfTowerRec;
                longAverage = average.round();
                loadChartData();
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
        if (unitTypeString !=null && unitTypeString != '')
            unitTypeStringForMap = unitTypeString.substring(0, unitTypeString.length()-1); 
    }
    
    public class CStatuswrapper{
        public Construction_Status__c CStatus {get; set;} 
        public decimal TotConstStatus {get; set;}
        
        public CStatuswrapper(Construction_Status__c CS, decimal TCS){
            CStatus = cs;
            TotConstStatus= TCS;
        }
    }
    
    //Method for loading chart data
    private void loadChartData(){
     	//Prepare the chart URL
        String chartPath = System.Label.RBI_BarChartlink;
        chartData        = chartPath +  getChartDataItem(items);
        chartData        = + chartData +'&chxr=1,0,100,10' + '&chtt= + ' + '&chg=0,10,0,0' + '&chts=000000,11.5';
        disChart = true;
    }
    
    //helper function for loadChartData
    private String getChartDataItem(List<ChartDataItem> items){
    	String chd = ''; 
     	String chl = ''; 
	    for(ChartDataItem citem : items){
        	chd += citem.ItemValue + ',';
        	chl += citem.sLabel + '|';
     	}
     	//remove the last comma or pipe
     	chd = chd.substring(0, chd.length() -1);
     	chl = chl.substring(0, chl.length() -1);
	    String result = '&chd=t:' + chd + '&chl=' + chl;
    	return result;
    }// end of method
    
    /*Query the AWS Object for Tower Images*/
    public void QueryAWS(){
        imgList = new list<AWS_S3_Object__c>();
		imgurlList  = new list<RBI_TowerReportPdf.imgdata>();
		string qrystring;
		AWS_S3_ExampleController awscontroller = new AWS_S3_ExampleController();	        
        if(projvst.Id!=null)
	        imgList = [select id,bucket_name__c,content_type__c, file_name__c, access__c,Project__c,Tower__c,Tower__r.Name,Tower__r.Project__c,Preview_Link__c,imageurl__c from AWS_S3_Object__c where FollowUp_Visit__c = :projvst.Id];
		for(AWS_S3_Object__c s3obj : imgList){
			qrystring = '';
			qrystring = awscontroller.AWSLogin(s3obj.file_name__c, s3obj.bucket_name__c);
			imgurlList.add(new RBI_TowerReportPdf.imgdata(qrystring,s3obj.Tower__r.Name));				
		}	        
    }
                
    //wrapper class for chart data
    public class ChartDataItem{
    	public Decimal ItemValue {get;set;}
        public String sLabel {get;set;}
        public ChartDataItem(String Lbl, Decimal Value){
        	this.sLabel = Lbl;
            this.ItemValue = Value;
        }
    }
}