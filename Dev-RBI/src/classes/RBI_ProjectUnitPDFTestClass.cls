public with sharing class RBI_ProjectUnitPDFTestClass {

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
	//public Unit__c unitforPDF {get;set;}
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
	private string AcctId = '';
	
	
	public list<Project_Feedback__c> feedlist {get;set;}
	/* Borrower Info */
	public Project__c ProjectRec {get;set;}
	public Tower__c TowerRec {get;set;}
	public Unit__c UnitRecord {get;set;}
	public Payment_Plan__c paymTypeRecord {get;set;}
	public String BorrowerName {get;set;}
	public String BorrowerEmail {get;set;}
	public string TID {get;set;}
	public string UID {get;set;}
	public string PPID {get;set;}
	
	
	public RBI_ProjectUnitPDFTestClass(){
        projectId = ApexPages.currentPage().getParameters().get('myvar1');
        TID = ApexPages.currentPage().getParameters().get('myvar2');
        UID = ApexPages.currentPage().getParameters().get('myvar3');
        PPID = ApexPages.currentPage().getParameters().get('myvar4');
        system.debug ('AAAA' +projectId +TID +UID+PPID);
        system.debug ('TTTT' +TID);
       	system.debug ('UUUU' +UID);
        system.debug ('PAPA' +PPID);
        projectName = '';
        unitOptions = new List<SelectOption>() ;
        TowerRec = new Tower__c();
        //selectedTowers = '';
        BorrowerName = '';
        BorrowerEmail = '';
        selUnitTowerId = '';
        selUnitFloor = '';
        detailPriceforSelUnit = new Detail_Price_List__c();
        feedRemark = new list<Project_Feedback__c>();
       	feedStatApp = new list<Project_Feedback__c>();
       	finalUnitList = new list<aggregateResult>();
       	floorWrapForPDF = new list<floorStrucWrap>();
       	//AcctId = UserUtil.CurrentUser.AccountId; //Logged in user's account id
       	AcctId = '0019000000NV0Ld';
       	ProjectRec = new Project__c();
       	ProjectRec=[SELECT Id, Project_Name__c, Site_Visit_Date__c,Site_Address_Actual__c,Site_Contact_NameDesg__c,Developer_Name__c,
       				Developer_Address__c,Construction_Start_Date__c,Name_of_the_Municipal_Corporation__c,Launch_Date__c,construction_Status__c
       				from Project__c where id=:projectId];
       	WrapperCSList = new list<CStatuswrapper>();
       	//gettowerRecords();
       	queryTower();
       	UnitforPDF();
        QueryFeedback();
  
	}
	
	public void queryTower(){
		//TowerRecord = new Tower__c();
		system.debug('selectedTowers in tower '+selectedTowers);
		if(TID != null){
			TowerRec = [select Max_Avg_Developer_BSP_per_Sq_Ft__c,Max_Avg_Resale_Price_Per_Sqft__c, Min_Avg_Developer_BSP_per_Sq_Ft__c,
					Min_Avg_Resale_Price_Per_Sqft__c ,Id, Deviation__c, Total_Floors__c, ResCommCompare__c, Launched_Units__c,Name, Construction_Start_Date__c, Launch_Date__c,
                    Proposed_Completion_Date__c, Actual_Basement_Floors__c, Planned_Basement_Floors__c, Actual_Parking_Floors__c,
                    Planned_Parking_Floors__c, Actual_ResCom_Floors__c, Planned_ResCom_Floors__c, Remarks__c,
                    Project__r.Project_Name__c, Project__r.Site_Address_Actual__c,Project__c,Project__r.name, Project__r.Site_Visit_Date__c,Project__r.Project_Phase__c,
					Project__r.Project_Phase__r.name, Project__r.Contact_Person__r.name, Project__r.Contact_Person__c,
					Project__r.Developer_Name__c,Project__r.Developer_Address__c,Project__r.License_Registration_Number__c,
					Project__r.Name_of_the_Municipal_Corporation__c,Project__r.Plot_Area__c, Project__r.construction_Status__c,
					Project__r.Launch_Date__c,Project__r.Construction_Start_Date__c,Project__r.Expected_Possesion_Date__c,
					Sold_Units__c,Structure_as_per_Brochure__c, Structure_as_per_Plan__c,Total_Units__c, 
					(Select Tower__c, Tower_Name__c, Excavation_of_Footings__c, Basement__c, RCC_Slab_Casting__c,
                    Masonary__c, Electrification_and_Sanitation__c, Finishing__c From Construction_Status__r) from Tower__c where Id =: TID];
            projectName = towerRec.Project__r.Project_Name__c;
			ProjectAddress = towerRec.Project__r.Site_Address_Actual__c;
        	system.debug('TowerRecccccccccccccccccccc' + TowerRec);
		}
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
		system.debug('PAY ID:' +PPID);
		if(PPID != null){
			paymTypeRecord = [select name, Discount__c, Plan_Type__r.name from Payment_Plan__c where Id =: PPID];
		}
		system.debug('PAYMENT REC:' +paymTypeRecord);
		Discount = paymTypeRecord.Discount__c;
		return paymTypeRecord;
	}
	
	/*Query the Customer Project Object*/
	public void WeightsQuery(){
		prjweights = [select Project_Id__c, Weightage_Basement__c, Weightage_Electrification_Sanitation__c, Customer_Name__c,
                        Weightage_Excavaton_of_Footings__c, Weightage_Finishing__c, Weightage_Masonary__c,
                        Weightage_RCC_Slab_Casting__c from Customer_Projects__c where Project_Id__c =:projectId and AccountId__c=:AcctId];
        system.debug('PRJWEIGHTS:' +prjweights);
					  
	}
    
    public void UnitforPDF(){
    	unitRecord = new Unit__c();
    	system.debug('SelectedUnitgetUnitforPDF '+UID);
    	if(UID != null){
    		selUnitTowerId = '';
    		selUnitFloor = '';
    		unitRecord = [select name, Floor__c,Floor_Number__c, Unit_Type__c,Tower_Id__c, Tower_Id__r.name,Tower_Id__r.Avg_Resale_Price_per_Sq_Ft__c,
			Carpet_Area_Sq_Ft__c, Built_up_area_Sq_Ft__c from Unit__c where Id =: UID];
			system.debug('unitRecord '+unitRecord);
			selUnitTowerId = unitRecord.Tower_Id__c;
			selUnitFloor = (string)unitRecord.Floor__c;
			system.debug('FLOOOOOR '+selUnitFloor);
			finalUnitList = [Select Unit_Type_Id__r.Unit_Type__c unittyp, Floor__c, COUNT(Name) cou, MAX(Unit_Type_Id__r.Carpet_Area_Sq_Ft__c) CarpetArea,
							MAX(Unit_Type_Id__r.Built_up_area_Sq_Ft__c) builtuparea From Unit__c 
							WHERE  Tower_Id__c = : TID  AND Floor__c= : selUnitFloor
							GROUP BY Unit_Type_Id__r.Unit_Type__c, Floor__c];
			system.debug('fiiiiiiiiii' + finalUnitList);
			for(aggregateResult aggRes : finalUnitList){
				String floor = '';
				String unitType = '';
				Integer noOfUnit;
				Double cpparam;
				Double builtparam;
				
				floor  = (String) aggRes.get('Floor__c');
				unitType = (String) aggRes.get('unittyp');
				noOfUnit = (Integer) aggRes.get('cou');
				cpparam = (Double) aggRes.get('CarpetArea');
				builtparam = (Double) aggRes.get('builtuparea');	
											
				floorWrapForPDF.add(new floorStrucWrap(floor, unitType, noOfUnit, cpparam, builtparam));
			}
			
			/* Logic for DeveloperBSP */
			string ratepersftColumn = 'Rate_'+selUnitFloor+'__c';
			system.debug('ratepersftColumn'+ratepersftColumn);
			string queryPrice = 'select name,'+ratepersftColumn+' from Detail_Price_List__c where Tower__c = \''+selUnitTowerId+'\' limit 1';
			system.debug('queryPrice'+queryPrice);
			if(queryPrice != ''){
				detailPriceforSelUnit = Database.query(queryPrice);
				if(detailPriceforSelUnit != null){
					DeveloperBSP = (Double)detailPriceforSelUnit.get(ratepersftColumn);
				}
				system.debug('DeveloperBSP '+DeveloperBSP);
			}
			getPaymentType();
			DiscountedDeveloperBSP = (DeveloperBSP - (DeveloperBSP*(Discount/100)));
			WeightsQuery();
			/* Building Wrapper Tower List */
			WrapperCSList = new list<CStatuswrapper>();
	        if(prjweights != null && prjweights.size() > 0){
	        	queryTower();
	        	if(TowerRec != null)
	        	{
		        	ConStat = new Construction_Status__c();
		            Customer_Projects__c wtobj = new Customer_Projects__c();
		            ConStat = TowerRec.Construction_Status__r;
		            system.debug('ConStat' + ConStat);
		            TotalFloors = (Integer)TowerRec.Total_Floors__c;
		            ResCommCompare = (Integer)TowerRec.ResCommCompare__c;
		            calcCS  = RBI_UtilClass.calculateconststatus(ConStat,prjweights[0],TotalFloors,ResCommCompare);
		            system.debug('calcCS' + calcCS);                   
		            WrapperCSList.add(new CStatuswrapper(ConStat, calcCS));
	        	}
	        }
    	}
    	
    }
	
	public PageReference generatePDF(){
		
		//LaunchPDFPage(); 
		if(selectedTowers != null && selectedTowers != '--None--'){
			
			UnitforPDF();
			//PageReference pg = new PageReference('/apex/RBI_ProjectUnitPDFPage');
			PageReference pg = new PageReference('/apex/RBI_ProjectUnitPDFPageTest');
			return pg; 
		}
		else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Tower Name'));
		}
		return null;
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
    	public floorStrucWrap(String flr, String unitTyp, Integer noOfUni, Double cparea,Double btarea){
    		floor = flr;
    		unitType = unitTyp;
    		noOfUnits = noOfUni;
    		carpetarea = cparea;
    		builtuparea = btarea;
    	}
    }
}