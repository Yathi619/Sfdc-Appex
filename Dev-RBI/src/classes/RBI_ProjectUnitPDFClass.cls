/*
    Type:       Custom Controller
    Purpose:    Used to generate the Unit Report in PDF Format for a Customer in Customer Portal. 
    			This can be accessed in Customer Portal under My Projects tab - Reports subtab and after entering the inputs like
    			Tower, Unit and Payment Plan and clicking on the Generate PDF button.     

    Used By:   RBI_ProjectUnitPDFPage.page
    ----------------------------------------------------------------------------------
    History:

    25-Apr-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_ProjectUnitPDFClass {

	public String selectedTowers {get; set;}
	public Id selectedUnit {get;set;}
	public Id selectedPaymType {get;set;}
	public list<Tower__c> towerRecordsForPDF {get;set;}
	public Tower__c TowerRecord{get; set;} 
	public list<Unit__c> UnitValues {get;set;}
	public list<Project_Feedback__c> feedRemark{get; set;}
	public list<Project_Feedback__c> feedStatApp{get; set;}
	public list<Customer_Projects__c> prjweights {get;set;}
	public Integer TotalFloors{get; set;}
    public Integer ResCommCompare{get; set;}
	public Id projectId = null;
	public boolean EnabledBuilding{get; set;}
	public List<SelectOption> unitOptions {get; set;}
	public String ProjectAddress{get; set;}
	public Project__c objproject {get;set;}
	public string projectName {get; set;}
	public String selUnitTowerId {get;set;}
	public String selUnitFloor {get;set;}
	public Detail_Price_List__c detailPriceforSelUnit {get;set;}
	public list<CStatuswrapper> WrapperCSList {get; set;} 
	public list<floorStrucWrap> floorWrapForPDF {get;set;}
	public Double DeveloperBSP {get;set;}
	public Double Discount{get; set;}
	public Double DiscountedDeveloperBSP{get; set;}
	public Construction_Status__c ConStat {get;set;}
	public list<aggregateResult> finalUnitList{get; set;} 
	public decimal calcCS {get;set;}
	public string queryPrice;
	public string ratepersftColumn;
	private string AcctId = '';
	public boolean IsPorEnabled {get;set;}    
    private string RBIaccnt = '';
    public list<Project_Feedback__c> feedlist {get;set;}
	public Project__c ProjectRec {get;set;}
	public Tower__c TowerRec {get;set;}
	public Unit__c UnitRecord {get;set;}
	public Payment_Plan__c paymTypeRecord {get;set;}
	/* Borrower Info */
	public String BorrowerName {get;set;}
	public String BorrowerEmail {get;set;}
	public string TID {get;set;}
	public string UID {get;set;}
	public string PPID {get;set;}
	public decimal calcCSRoundDown;
	public Double CostOfFlat{get; set;}
	public string saleableareaCalc;
	public Double saleablearea;
	public Double MinAvgResalePricePerSqft {get;set;}
	public Double MaxAvgResalePricePerSqft {get;set;}
	public Double MinAvgResalePricePerSqftCalc;
	public Double MaxAvgResalePricePerSqftCalc;
	string MinEst;
	string MaxEst;
	public string LineChartData {get;set;}
	public List<TableDataItem> tableitems {get;set;}
	Datetime optenddt;
	Datetime pstenddt;
	Datetime proposedenddt;
	Datetime visitdt ;
	Datetime constdt;
	string proposedendmon,
       	   optendmon,
       	   pstendmon;
	public list<AWS_S3_Object__c> 			imgList{get; set;}       	   	
	public list<RBI_TowerReportPdf.imgdata> imgurlList{get; set;} 
	
	public RBI_ProjectUnitPDFClass(){
        projectId = ApexPages.currentPage().getParameters().get('projId');
        TID = ApexPages.currentPage().getParameters().get('SelTowId');
        UID = ApexPages.currentPage().getParameters().get('SelUnitId');
        PPID = ApexPages.currentPage().getParameters().get('SelPayTypeId');
        projectName = '';
        unitOptions = new List<SelectOption>() ;
        TowerRec = new Tower__c();
       	BorrowerName = '';
        BorrowerEmail = '';
        selUnitTowerId = '';
        selUnitFloor = '';
        proposedendmon = '';
        optendmon = '';
        pstendmon = '';
        detailPriceforSelUnit = new Detail_Price_List__c();
        feedRemark = new list<Project_Feedback__c>();
       	feedStatApp = new list<Project_Feedback__c>();
       	finalUnitList = new list<aggregateResult>();
       	floorWrapForPDF = new list<floorStrucWrap>();
       	RBIaccnt =  System.Label.RBI_AccountId;
        AcctId = UserUtil.CurrentUser.AccountId; //Logged in user's account id
        AcctId = (AcctId == null || AcctId == '')?RBIaccnt:AcctId; //set account id to RBI cust record in case it is null
        IsPorEnabled = UserUtil.CurrentUser.IsPortalEnabled;
       	ProjectRec = new Project__c();
       	ProjectRec=[SELECT Id, Project_Name__c, Site_Visit_Date__c,Site_Address_Actual__c,Site_Contact_NameDesg__c,Developer_Name__c,
       				Developer_Address__c,Construction_Start_Date__c,Name_of_the_Municipal_Corporation__c,Launch_Date__c,construction_Status__c,
       				Project_LatLong__Longitude__s,Project_LatLong__Latitude__s
       				from Project__c where id=:projectId];
       	WrapperCSList = new list<CStatuswrapper>();
       	queryTower();
       	UnitforPDF();
        QueryFeedback();
        QueryAWS();
	}
	
	public void queryTower(){
		if(TID != null){
			TowerRec = [select VisitDuration__c,StartdtDuration__c,Duration__c,Max_Avg_Developer_BSP_per_Sq_Ft__c,Max_Avg_Resale_Price_Per_Sqft__c, Min_Avg_Developer_BSP_per_Sq_Ft__c,
					Min_Avg_Resale_Price_Per_Sqft__c ,Id, Deviation__c, Total_Floors__c, ResCommCompare__c, Launched_Units__c,Name, Construction_Start_Date__c, Launch_Date__c,
                    Proposed_Completion_Date__c, Actual_Basement_Floors__c, Planned_Basement_Floors__c, Actual_Parking_Floors__c,
                    Planned_Parking_Floors__c, Actual_ResCom_Floors__c, Planned_ResCom_Floors__c, Remarks__c,
                    Project__r.Project_Name__c, Project__r.Site_Address_Actual__c,Project__c,Project__r.name, Project__r.Site_Visit_Date__c,Project__r.Project_Phase__c,
					Project__r.Project_Phase__r.name, Project__r.Contact_Person__r.name, Project__r.Contact_Person__c,
					Project__r.Developer_Name__c,Project__r.Developer_Address__c,Project__r.License_Registration_Number__c,
					Project__r.Name_of_the_Municipal_Corporation__c,Project__r.Plot_Area__c, Project__r.construction_Status__c,
					Project__r.Launch_Date__c,Project__r.Construction_Start_Date__c,Project__r.Expected_Possesion_Date__c, Project__r.Project_LatLong__Longitude__s,
                    Project__r.Project_LatLong__Latitude__s, Sold_Units__c,Structure_as_per_Brochure__c, Structure_as_per_Plan__c,Total_Units__c, 
					(Select Tower__c, Tower_Name__c, Excavation_of_Footings__c, Basement__c, RCC_Slab_Casting__c,
					Masonary__c, Electrification_and_Sanitation__c, Finishing__c, Excavation_Min_Calc__c, Excavation_Max_Calc__c, 
					Basement_Construction_Min_Calc__c, Basement_Construction_Max_Calc__c, RCC_Structure_Min_Calc__c, RCC_Structure_Max_Calc__c, Masonary_Work_Min_Calc__c,
					Masonary_Work_Max_Calc__c, Electrification_Sanitation_Min__c, Electrification_Sanitation_Max__c
					,Finishing_Min_Calc__c, Finishing_Max_Calc__c From Construction_Status__r) from Tower__c where Id =: TID];
            projectName = towerRec.Project__r.Project_Name__c;
			ProjectAddress = towerRec.Project__r.Site_Address_Actual__c;
			MinAvgResalePricePerSqftCalc = towerRec.Min_Avg_Resale_Price_Per_Sqft__c;
			MaxAvgResalePricePerSqftCalc = towerRec.Max_Avg_Resale_Price_Per_Sqft__c;
        	
		}
	}
	
	/*Query the Additional Charges Object*/
  	public list<Additional_Charges__c> getAddChg(){
		list<Additional_Charges__c> addnchg = [select Charge_Per_Sqft__c, Description__c, Charge_Type__c, Charge_Detail__c, From_Floor__c,
					To_Floor__c, Mandatory__c, Input_Guidance__c, Project__c, Remarks__c, Resale_Value__c, Visit__c from Additional_Charges__c where
					Project__c =:projectId ];
		return addnchg;										
	}
  		
	 /*Query the Project FeedBack Object*/
    public void QueryFeedback(){
        feedlist = [Select List_of_Values_Id__r.Name, List_of_Values_Id__r.Entity_Name__c,  Comments__c From Project_Feedback__c where Project__c =: projectId];
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
	

	public Payment_Plan__c getPaymentType(){
		paymTypeRecord = new Payment_Plan__c();
		Discount=0;
		if(PPID != null){
			paymTypeRecord = [select name, Discount__c, Plan_Type__r.name from Payment_Plan__c where Id =: PPID];
		}
		if(paymTypeRecord!=null){
			Discount = paymTypeRecord.Discount__c;
			if (Discount > 0)
				Discount = paymTypeRecord.Discount__c;
			else
				Discount = 0;
		}
		return paymTypeRecord;
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
                        Weightage_RCC_Slab_Casting__c from Customer_Projects__c where Project_Id__c =:projectId and AccountId__c=:AcctId];
        	
        }
					  
	}
    
    public void UnitforPDF(){
    	string retconstat = '';
    	MinEst = '0';
    	MaxEst = '0';
       	List<string> calcconstatlist = new list<string>();     	
    	unitRecord = new Unit__c();
    	if(UID != null){
    		selUnitTowerId = '';
    		selUnitFloor = '';
    		unitRecord = [select name, Floor__c,Floor_Number__c, Unit_Type__c,Tower_Id__c, Tower_Id__r.name,Tower_Id__r.Avg_Resale_Price_per_Sq_Ft__c,
			Carpet_Area_Sq_Ft__c, Built_up_area_Sq_Ft__c, Super_Area_Sq_Ft__c from Unit__c where Id =: UID];
			selUnitTowerId = unitRecord.Tower_Id__c;
			selUnitFloor = (string)unitRecord.Floor__c;
			finalUnitList = [Select Unit_Type_Id__r.Unit_Type__c unittyp, Floor__c, COUNT(Name) cou, MAX(Unit_Type_Id__r.Carpet_Area_Sq_Ft__c) CarpetArea,
							MAX(Unit_Type_Id__r.Built_up_area_Sq_Ft__c) builtuparea, MAX(Unit_Type_Id__r.Super_Area_Sq_Ft__c) superbuiltuparea  From Unit__c 
							WHERE  Tower_Id__c = : TID  AND Floor__c= : selUnitFloor
							GROUP BY Unit_Type_Id__r.Unit_Type__c, Floor__c];
			for(aggregateResult aggRes : finalUnitList){
				String floor = '';
				String unitType = '';
				Integer noOfUnit;
				Double cpparam;
				Double builtparam;
				Double superbuiltparam;
				
				floor  = (String) aggRes.get('Floor__c');
				unitType = (String) aggRes.get('unittyp');
				noOfUnit = (Integer) aggRes.get('cou');
				cpparam = (Double) aggRes.get('carpetarea');
				builtparam = (Double) aggRes.get('builtuparea');
				superbuiltparam = (Double) aggRes.get('superbuiltuparea');
											
				floorWrapForPDF.add(new floorStrucWrap(floor, unitType, noOfUnit, cpparam, builtparam, superbuiltparam));
			}
			
			/* Logic for DeveloperBSP */
			ratepersftColumn = 'Rate_'+selUnitFloor+'__c';
			queryPrice = 'select name,'+ratepersftColumn+' from Detail_Price_List__c where Tower__c = \''+selUnitTowerId+'\' limit 1';
			List <Detail_Price_List__c> queryPricelst = new List<Detail_Price_List__c>(); 
			if(queryPrice != ''){
				detailPriceforSelUnit = new Detail_Price_List__c();
				queryPricelst = Database.query(queryPrice);
				if((queryPricelst != null)&&(queryPricelst.size()>0)){
					detailPriceforSelUnit =queryPricelst[0];
					DeveloperBSP = (Double)detailPriceforSelUnit.get(ratepersftColumn);
				}
			}
			
			getPaymentType();
			
			DiscountedDeveloperBSP = (DeveloperBSP==null)?0:(DeveloperBSP - (DeveloperBSP*(Discount/100)));
			saleableareaCalc = UnitRecord.Super_Area_Sq_Ft__c;
			Decimal saleableareaDec = (saleableareaCalc==null)?0:(decimal.valueOf(saleableareaCalc));
			CostOfFlat = DiscountedDeveloperBSP * saleableareaDec;
			MinAvgResalePricePerSqft = (MinAvgResalePricePerSqftCalc==null)?0:MinAvgResalePricePerSqftCalc * saleableareaDec;
			MaxAvgResalePricePerSqft = (MaxAvgResalePricePerSqftCalc==null)?0:MaxAvgResalePricePerSqftCalc * saleableareaDec;
			
			WeightsQuery();
			/* Building Wrapper Tower List */
			WrapperCSList = new list<CStatuswrapper>();
			List <Construction_Status__c> ConStatList = new List<Construction_Status__c>(); 
	        if(prjweights != null && prjweights.size() > 0){
	        	queryTower();
	        	if(TowerRec != null)
	        	{
	        		ConStat = new Construction_Status__c();
		            Customer_Projects__c wtobj = new Customer_Projects__c();
		            //ConStatList = TowerRec.Construction_Status__r;
		            //if(ConStatList != null && ConStatList.size()>0){
		            if(TowerRec.Construction_Status__r != null && TowerRec.Construction_Status__r.size() > 0){
		            	ConStatList = TowerRec.Construction_Status__r;
			            ConStat = ConStatList[0];
			            TotalFloors = (Integer)TowerRec.Total_Floors__c;
			            ResCommCompare = (Integer)TowerRec.ResCommCompare__c;
			            retconstat  = RBI_UtilClass.calcconststatus_unit(ConStat,prjweights[0],TotalFloors,ResCommCompare);
			            calcconstatlist = retconstat.split(',');
	        	    	if((calcconstatlist != null) && (calcconstatlist.size()>0))
		        	    {
		        	    	calcCS = (calcconstatlist[0]==null)?0:decimal.valueOf(calcconstatlist[0]);
		        	    	calcCS=calcCS.setscale(2,System.RoundingMode.HALF_UP);
		        	    	MinEst = (calcconstatlist[1]==null)?'0':calcconstatlist[1];
		        	    	MaxEst = (calcconstatlist[2]==null)?'0':calcconstatlist[2];
		        	    }
			            WrapperCSList.add(new CStatuswrapper(ConStat, calcCS));
		            }
		            loadLineChartdata();
	        	}
	        }
    	}
    }
	// helper function to build the google line chart url
	private void loadLineChartdata(){
		generateTableItems();
		LineChartData = '';
		string promisedvals;
		string constatvals;
		string constatvstvals;
		string optvals;
		string pstvals;
		Datetime optdt = null;
		Datetime pstdt = null;
		Decimal vstduration;	
		Decimal stduration;
		Decimal duration;
		decimal calcCSgraph = 0.0;
		stduration = (TowerRec.StartdtDuration__c == null)?0:TowerRec.StartdtDuration__c;
		duration = (TowerRec.Duration__c == null)?0:TowerRec.Duration__c;			
		if(visitdt == null){
			promisedvals = string.valueOf(stduration)+','+string.valueOf(duration);
			constatvals = '0'+','+'100';
			optvals = string.valueOf(stduration)+','+MinEst;
			pstvals = string.valueOf(stduration)+','+MaxEst;
			if (constdt != null){
				optdt = constdt.addMonths(Integer.valueof(MinEst));
				pstdt = constdt.addMonths(Integer.valueof(MaxEst));
			}
			constatvstvals = constatvals;
		}	
		else{
			calcCS = ((calcCS!= null)&&(calcCS>=0))?(calcCS):0;
			//calcCSgraph  = (calcCS.divide(2, 2, System.RoundingMode.HALF_UP));
			calcCSgraph = calcCS;
			vstduration = (TowerRec.VisitDuration__c==null)?0:TowerRec.VisitDuration__c;
			promisedvals = string.valueOf(stduration)+','+string.valueOf(vstduration)+','+string.valueOf(duration);
			constatvals = '0'+','+calcCSgraph+','+'100';
			constatvstvals =calcCSgraph+','+'100';
			if(MinEst != null && MinEst != '')
				optvals = string.valueOf(vstduration)+','+((Integer.valueOf(MinEst))+vstduration);				
				if(MaxEst != null && MaxEst != '')
					pstvals = string.valueOf(vstduration)+','+((Integer.valueOf(MaxEst))+vstduration);	
				if (constdt != null){
					optdt = constdt.addMonths(Integer.valueof(MinEst));
					pstdt = constdt.addMonths(Integer.valueof(MaxEst));
				}
			}
		
		string prpcomplbl = 'Proposed completion';
		string optcomplbl ='Optimistic Projection';
		string pescomplbl ='Pessimistic Projection';
		if(proposedendmon != null && proposedendmon != '')
			prpcomplbl += '('+proposedendmon+')';
		if(optcomplbl != null && optcomplbl != '')		
			optcomplbl += '('+optendmon+')';
		if(pescomplbl != null && pescomplbl != '')				
			pescomplbl += '('+pstendmon+')';
					
		LineChartData = System.Label.RBI_LineChartlink;
		LineChartData += '&chdl='+prpcomplbl+'|'+optcomplbl+'|'+pescomplbl;
		LineChartData += '&chd=t:'+promisedvals+'|'+constatvals+'|'+optvals+'|'+constatvstvals+'|'+pstvals+'|'+constatvstvals;
		system.debug('LineChartData'+LineChartData);
			
	}   
	 
	// helper function to build line chart table
	private void generateTableItems(){
		string launchmon,visitmon,constmon;		
		tableitems = new List<TableDataItem>();
		proposedenddt = null;
		visitdt	      = null;
		constdt       = null;
		optenddt      = null;
		pstenddt      = null;
		Datetime launchdt = null;
		launchdt = TowerRec.Launch_Date__c;
		proposedenddt = TowerRec.Proposed_Completion_Date__c;
		visitdt	= TowerRec.Project__r.Site_Visit_Date__c;
		constdt	= TowerRec.Construction_Start_Date__c;
		
		if(visitdt == null){
			if (constdt != null){
				optenddt = constdt.addMonths(Integer.valueof(MinEst));
				pstenddt = constdt.addMonths(Integer.valueof(MaxEst));
			}
		}	
		else{
			if (visitdt != null){
				optenddt = visitdt.addMonths(Integer.valueof(MinEst));
				pstenddt = visitdt.addMonths(Integer.valueof(MaxEst));
			}
		}
		proposedendmon = (proposedenddt!= null)?proposedenddt.format('MMM-yyyy'):'';
		optendmon 	   = (optenddt!= null)?optenddt.format('MMM-yyyy'):'';		
		pstendmon 	   = (pstenddt!= null)?pstenddt.format('MMM-yyyy'):'';
		launchmon      = (launchdt!=null)?launchdt.format('MMM-yyyy'):'';
		visitmon       = (visitdt!=null)?visitdt.format('MMM-yyyy'):'';
		constmon	   = (constdt!=null)?constdt.format('MMM-yyyy'):'';				
		tableitems.add(new TableDataItem('Launch Date',launchmon));
		tableitems.add(new TableDataItem('Construction Start Date',constmon));
		tableitems.add(new TableDataItem('Visit Date',visitmon));
		tableitems.add(new TableDataItem('Proposed Completion Date',proposedendmon));
		tableitems.add(new TableDataItem('Optimistic Projected Completion',optendmon));
		tableitems.add(new TableDataItem('Pessimistic Projected Completion',pstendmon));
	}
	
	/*Query the AWS Object for Tower Images*/
    public void QueryAWS(){
		imgList = new list<AWS_S3_Object__c>();
		imgurlList  = new list<RBI_TowerReportPdf.imgdata>();
		string qrystring;
		AWS_S3_ExampleController awscontroller = new AWS_S3_ExampleController();		
		imgList = [select id,bucket_name__c,content_type__c, file_name__c, access__c,Project__c,Tower__c,Tower__r.Name,Tower__r.Project__c,Preview_Link__c,imageurl__c from AWS_S3_Object__c 
				   where Tower__c = :TID order by LastModifiedDate desc LIMIT 1];
		if(imgList != null && imgList.size()>0){
			qrystring = '';
			qrystring = awscontroller.AWSLogin(imgList[0].file_name__c, imgList[0].bucket_name__c);
			imgurlList.add(new RBI_TowerReportPdf.imgdata(qrystring,imgList[0].Tower__r.Name));
		}
    }
	
	//wrapper class for table data
	public class TableDataItem
	{
		 public Date DateValue {get;set;}
		 public string strDateValue {get;set;}		 
		 public String sLabel {get;set;}
		 public TableDataItem(String Lbl, string Value)
		 {
		    this.sLabel = Lbl;
		    this.strDateValue = Value;
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
    	public String floor        {get;set;}
    	public String unitType     {get;set;} 
    	public Integer noOfUnits   {get;set;}
    	public Double carpetarea  {get;set;}
    	public Double builtuparea {get;set;}
    	public Double superbuiltuparea {get;set;}     	    	
    	public floorStrucWrap(String flr, String unitTyp, Integer noOfUni, Double cparea,Double btarea, Double sbtarea){
    		floor = flr;
    		unitType = unitTyp;
    		noOfUnits = noOfUni;
    		carpetarea = cparea;
    		builtuparea = btarea;
    		superbuiltuparea = sbtarea;
    	}
    }
    @IsTest(SeeAllData=true)  static  void UnitTestPDF() {
    	//create record for following object and make association between them
    	
    	ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
    	
    	list<Account> acc = new list<Account>();
        Account Acnt = new Account(Name = 'TestLastName', RecordTypeId = CusRecType);
        acc.add(Acnt);
        insert acc;
    	
		list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test',  Brochure_Zipcode__c = '568980', Site_Address_zipcode__c = '412578',
										 Launch_Date__c = System.today(),Site_Address_City__c='Bangalore', Construction_Start_Date__c = System.Today() - 25);
		projlist.add(proj);
		insert projlist;
		Id Acctid=System.Label.RBI_AccountId;
      	 
		list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
		Customer_Projects__c cp = new Customer_Projects__c(Project_Id__c = projlist[0].Id, AccountId__c = acc[0].Id);
		customerProjectlist.add(cp);
		insert customerProjectlist;
		
		list<Tower__c> towerlist = new list<Tower__c>();
		Tower__c twd = new Tower__c(Project__c = projlist[0].Id, Name = 'TowerA',Structure_as_per_Plan__c='13',Construction_Start_Date__c = System.Today() - 10,
									Avg_Resale_Price_per_Sq_Ft__c=250,Deviation__c='Yes',Planned_Basement_Floors__c=2,Planned_Parking_Floors__c=2,
									Planned_ResCom_Floors__c=15,Actual_Basement_Floors__c=2, Actual_Parking_Floors__c=3,Actual_ResCom_Floors__c=16,
									Min_Avg_Resale_Price_Per_Sqft__c=10, Max_Avg_Resale_Price_Per_Sqft__c=40);
		towerlist.add(twd);
		insert towerlist;
		
		list<Unit_Type__c> unittypelist= new list<Unit_Type__c>();
		Unit_Type__c unit= new Unit_Type__c(Built_up_area_Sq_Ft__c = 20, Carpet_Area_Sq_Ft__c = 15, 
											Project__c=projlist[0].Id, Unit_Type__c='1 BHK');
		unittypelist.add(unit);
		insert unittypelist;
		
		list<Unit__c> unitlist = new list<Unit__c>();
		Unit__c un = new Unit__c(Unit_Type_Id__c = unittypelist[0].Id, Tower_Id__c = towerlist[0].Id, Floor__c = '11');
		unitlist.add(un);
		insert unitlist;
		
		list<Construction_Status__c> Constructionstatuslist = new list<Construction_Status__c>();
		Construction_Status__c constatus = new Construction_Status__c(Electrification_and_Sanitation__c = '8', Masonary__c='6',
											Excavation_of_Footings__c = 'UC',Basement__c='UC',Finishing__c='10' ,Tower__c=towerlist[0].Id,RCC_Slab_Casting__c='10');
		Constructionstatuslist.add(constatus); 
		insert Constructionstatuslist;
		
		list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
		List_of_Values__c lov = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Remark',Entity_Type__c='Remark',
								Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Unit__c=unitlist[0].Id,
								Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
		List_of_Values__c lov1 = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Payment Plan',Entity_Type__c='Payment Plan',
								Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Unit__c=unitlist[0].Id,
								Loan_Amount__c=25000, Dev_Project_Address__c='test unit');						
		lovlist.add(lov);
		lovlist.add(lov1);
		insert lovlist;
		
		list<Project_Feedback__c> projfeedbacklist = new list<Project_Feedback__c>();
		Project_Feedback__c projfeed = new Project_Feedback__c(List_of_Values_Id__c = lov.Id, Project__c = projlist[0].id,Comments__c='xxx');
		projfeedbacklist.add(projfeed);
		insert projfeedbacklist;
		
		list<Payment_Plan__c> paymentlist = new list<Payment_Plan__c>();
		Payment_Plan__c payment = new Payment_Plan__c(Discount__c =20, Project__c = projlist[0].id,Plan_Type__c=lov1.Id);
		paymentlist.add(payment);
		insert paymentlist;
       	
       	list<Additional_Charges__c> addnchglist = new list<Additional_Charges__c>();
       	Additional_Charges__c addchg = new Additional_Charges__c(Project__c = projlist[0].Id, Charge_Per_Sqft__c = 100, Charge_Type__c = 'PLC', Charge_Detail__c = 'Floor Rise'
       									, From_Floor__c = '1', Mandatory__c = true, To_Floor__c = '5', Remarks__c = 'Very good'
       									, Resale_Value__c = 'Transferable');
       	addnchglist.add(addchg);
       	insert addnchglist;
       	
       	list<Detail_Price_List__c> Detailpricelist = new list<Detail_Price_List__c>();
		Detail_Price_List__c detail = new Detail_Price_List__c( Project__c = projlist[0].id,Tower__c=towerlist[0].Id,Rate_11__c=200);
		Detailpricelist.add(detail);
		insert Detailpricelist;
		
		//start test class method
       	System.Test.startTest();
       	
       	//Instantiate the RBI_ProjectUnitPDFPage which generates the PDF
		PageReference RBI_ProjectUnitPDFPage = Page.RBI_ProjectUnitPDFPage;
		System.Test.setCurrentPage(RBI_ProjectUnitPDFPage);
		
		//Instantiate the class which is used in the page above
		apexpages.currentpage().getparameters().put('projId' , projlist[0].Id);
		apexpages.currentpage().getparameters().put('SelTowId', towerlist[0].Id);
		apexpages.currentpage().getparameters().put('SelUnitId', unitlist[0].Id);
		apexpages.currentpage().getparameters().put('SelPayTypeId', paymentlist[0].Id);
       	RBI_ProjectUnitPDFClass rbiprjpdfunit = new RBI_ProjectUnitPDFClass();
       	rbiprjpdfunit.projectId = Apexpages.currentPage().getParameters().put('projId', projlist[0].Id);
       	rbiprjpdfunit.TID = Apexpages.currentPage().getParameters().put('SelTowId', towerlist[0].Id);
       	rbiprjpdfunit.UID = Apexpages.currentPage().getParameters().put('SelUnitId', unitlist[0].Id);
       	rbiprjpdfunit.PPID = Apexpages.currentPage().getParameters().put('SelPayTypeId', paymentlist[0].Id);
       	//Test queryTower method of RBI_ProjectUnitPDFClass
        	rbiprjpdfunit.queryTower();
        	
       	//test getAddChg method of RBI_ProjectUnitPDFClass
       	rbiprjpdfunit.getAddChg();
       	
       	//test QueryFeedback method of RBI_ProjectUnitPDFClass
       	rbiprjpdfunit.QueryFeedback();
       	
       	//test getPaymentType method of RBI_ProjectUnitPDFClass
       	rbiprjpdfunit.getPaymentType();
       	
       	string AccId = UserUtil.CurrentUser.AccountId;
       	rbiprjpdfunit.AcctId = AccId;
      
       	string RBIacct=System.Label.RBI_AccountId;
      	rbiprjpdfunit.RBIaccnt = RBIacct;
       	rbiprjpdfunit.WeightsQuery();
       	rbiprjpdfunit.UnitforPDF();
       	rbiprjpdfunit.MinEst='5';
       	rbiprjpdfunit.MaxEst='7';
       	rbiprjpdfunit.loadLineChartdata();
       	
       	//stop test class method
       	System.Test.stopTest();
    }
}