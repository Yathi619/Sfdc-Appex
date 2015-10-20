public with sharing class RBI_ProjectUnitClassTest {

	public String selectedTowers {get; set;}
	
	public Id selectedUnit {get;set;}
	public Id selectedPaymType {get;set;}
	public list<Tower__c> towerRecordsForPDF {get;set;}
	public Tower__c TowerRecord{get; set;} 
	public list<Unit__c> UnitValues {get;set;}
	public list<Project_Feedback__c> feedRemark{get; set;}
	public list<Project_Feedback__c> feedStatApp{get; set;}
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
	//public list<CStatuswrapper> WrapperCSList {get; set;} 
	//public list<floorStrucWrap> floorWrapForPDF {get;set;}
	public Double DeveloperBSP {get;set;}
	public Double Discount{get; set;}
	public Double DiscountedDeveloperBSP{get; set;}
	public Construction_Status__c ConStat {get;set;}
	public list<aggregateResult> finalUnitList{get; set;}
	public decimal calcCS {get;set;}
	private string AcctId = '';
	
	/* Borrower Info */
	public String BorrowerName {get;set;}
	public String BorrowerEmail {get;set;}
	public Project__c ProjectRec {get;set;}
	
	public RBI_ProjectUnitClassTest(){
        projectId = ApexPages.currentPage().getParameters().get('projectId');
        projectName = '';
        unitOptions = new List<SelectOption>() ;
        BorrowerName = '';
        BorrowerEmail = '';
        selUnitTowerId = '';
        selUnitFloor = '';
      /*  detailPriceforSelUnit = new Detail_Price_List__c();
        feedRemark = new list<Project_Feedback__c>();
       	feedStatApp = new list<Project_Feedback__c>();
       	finalUnitList = new list<aggregateResult>();*/
       	//AcctId = UserUtil.CurrentUser.AccountId; //Logged in user's account id
      // 	AcctId = '0019000000NV0Ld';
       	ProjectRec = new Project__c();
       	ProjectRec=[SELECT Id, Project_Name__c from Project__c where id=:projectId];
     }
	
	public list<selectOption> getTypesofPaymPlan(){
		List<SelectOption> options = new List<SelectOption>();
		list<Payment_Plan__c> paymentPlanRec = new list<Payment_Plan__c>();
		paymentPlanRec = [select name, Plan_Type__r.name from Payment_Plan__c where Project__c =: projectId];
		if(paymentPlanRec != null && paymentPlanRec.size()>0){
			for(Payment_Plan__c payPlan:paymentPlanRec){ 
		     	options.add(new SelectOption(payPlan.Id,payPlan.Plan_Type__r.name));
	   		}
		}
		return options;
	}
	public Payment_Plan__c getPaymentType(){
		Payment_Plan__c paymTypeRecord = new Payment_Plan__c();
		if(selectedPaymType != null){
			paymTypeRecord = [select name, Discount__c, Plan_Type__r.name from Payment_Plan__c where Id =: selectedPaymType];
		}
		Discount = paymTypeRecord.Discount__c;
		return paymTypeRecord;
	}
	
	public List<SelectOption> gettowerRecords(){
 		List<SelectOption> options = new List<SelectOption>();
		towerRecordsForPDF = [select Max_Avg_Developer_BSP_per_Sq_Ft__c,Max_Avg_Resale_Price_Per_Sqft__c, Min_Avg_Developer_BSP_per_Sq_Ft__c,
					Min_Avg_Resale_Price_Per_Sqft__c ,Deviation__c , Id,Launched_Units__c,Name,
					Project_Name__c,Project__c,Project__r.name,Project__r.Site_Address_Actual__c, Project__r.Site_Visit_Date__c,Project__r.Project_Phase__c,
					Project__r.Project_Phase__r.name, Project__r.Contact_Person__r.name, Project__r.Contact_Person__c,
					Project__r.Developer_Name__c,Project__r.Developer_Address__c,Project__r.License_Registration_Number__c,
					Project__r.Name_of_the_Municipal_Corporation__c,Project__r.Plot_Area__c, Project__r.construction_Status__c,
					Project__r.Launch_Date__c,Project__r.Construction_Start_Date__c,Project__r.Expected_Possesion_Date__c,
					Sold_Units__c,Structure_as_per_Brochure__c, Structure_as_per_Plan__c,Total_Units__c , 
					(Select Tower__c, Tower_Name__c, Excavation_of_Footings__c, Basement__c, RCC_Slab_Casting__c,
                    Masonary__c, Electrification_and_Sanitation__c, Finishing__c From Construction_Status__r) from Tower__c where Project__c = : projectId];
					
		projectName = towerRecordsForPDF[0].Project_Name__c;
		ProjectAddress = towerRecordsForPDF[0].Project__r.Site_Address_Actual__c;
				
		if (towerRecordsForPDF.Size() >0){
			for(Tower__c tower:towerRecordsForPDF){ 
		     	options.add(new SelectOption(tower.Id,tower.name));
	   		}
	    }
	   
	    return options;
	}
	
	public void getPopUnitPicklst(){
		
		UnitValues = [select name, Floor__c, Unit_Type__c,Tower_Id__c, Tower_Id__r.name,Tower_Id__r.Avg_Resale_Price_per_Sq_Ft__c,
		Carpet_Area_Sq_Ft__c, Built_up_area_Sq_Ft__c from Unit__c where Tower_Id__c = : selectedTowers];
		if (UnitValues != null && UnitValues.Size() >0){
			for(Unit__c unit:UnitValues){
		     	unitOptions.add(new SelectOption(unit.Id,unit.name));
	   		}
		}
		
	}
	
    public PageReference populatePicklistValue(){
    	if(SelectedTowers != '--None--'){
	    	unitOptions = new List<SelectOption>() ;
    		getPopUnitPicklst();
    	}
    	else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Tower Name'));
		}
    	return null;
    }
    
        
    
	public PageReference generatePDF(){
		
		 if(selectedTowers != null && selectedTowers != '--None--'){
			//PageReference pg = new PageReference('/apex/RBI_ProjectUnitPDFPage');
			//PageReference newPAge = page.SFDCVariables02;
               
			PageReference pg = new PageReference('/apex/RBI_ProjectUnitPDFPageTest');
			pg.getParameters().put('MyVar1', projectId);
			pg.getParameters().put('MyVar2', selectedTowers);
			pg.getParameters().put('MyVar3', SelectedUnit);
			pg.getParameters().put('MyVar4', selectedPaymType);
			
			return pg; 
		}
		else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Tower Name'));
		}
		return null;
	}

	
}