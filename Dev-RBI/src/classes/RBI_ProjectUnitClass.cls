/*
    Type:       Custom Controller
    Purpose:    Used to take the inputs from the Customer for running the Unit Rreport, from Customer Portal.     

    Used By:   RBI_ProjectUnitPage.page
    ----------------------------------------------------------------------------------
    History:

    25-Apr-2013     Created		Tugboat Info Solutions Pvt. Ltd

*/
public with sharing class RBI_ProjectUnitClass{

	public String selectedTowers {get; set;}
	public Attachment myAttach = new Attachment();
	public Id selectedUnit {get;set;}
	public Id selectedPaymType {get;set;}
	public list<Tower__c> towerRecordsForPDF {get;set;}
	public Tower__c TowerRecord{get; set;} 
	public list<Unit__c> UnitValues {get;set;}
	public list<Project_Feedback__c> feedRemark{get; set;}
	public list<Project_Feedback__c> feedStatApp{get; set;}
	public Integer TotalFloors{get; set;}
    public Integer ResCommCompare{get; set;}
	public Id projectId = null;
	public boolean EnabledBuilding{get; set;}
	public List<SelectOption> unitOptions {get; set;}
	public String ProjectAddress{get; set;}
	public Project__c objproject {get;set;}
	public Contact con{get; set;}
	list<Contact> conList; 
	public string projectName {get; set;}
	public String selUnitTowerId {get;set;}
	public String selUnitFloor {get;set;}
	public Detail_Price_List__c detailPriceforSelUnit {get;set;}
	public Double DeveloperBSP {get;set;}
	public Double Discount{get; set;}
	public Double DiscountedDeveloperBSP{get; set;}
	public Construction_Status__c ConStat {get;set;}
	public list<aggregateResult> finalUnitList{get; set;}
	public decimal calcCS {get;set;}
	public boolean IsPorEnabled {get;set;} 
	private string AcctId = '';
	private string RBIaccnt = '';
	
	/* Borrower Info */
	public String BorrowerName {get;set;}
	public String BorrowerEmail {get;set;}
	public Project__c ProjectRec {get;set;}
	public boolean generateButtonFlag {get;set;}
	
	public RBI_ProjectUnitClass(){
        projectId = ApexPages.currentPage().getParameters().get('projectId');
        RBIaccnt =  System.Label.RBI_AccountId;
        projectName = '';
        unitOptions = new List<SelectOption>() ;
        BorrowerName = '';
        BorrowerEmail = '';
        selUnitTowerId = '';
        selUnitFloor = '';
        generateButtonFlag = true;
      	AcctId = UserUtil.CurrentUser.AccountId; //Logged in user's account id
       	AcctId = (AcctId == null || AcctId == '')?RBIaccnt:AcctId; //set account id to RBI cust record in case it is null
       	IsPorEnabled = UserUtil.CurrentUser.IsPortalEnabled;
      	ProjectRec = new Project__c();
       	ProjectRec = [SELECT Id, Project_Name__c from Project__c where id=:projectId];
       	
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
		towerRecordsForPDF = [select Id, Name, Project_Name__c,Project__c, Project__r.name, Project__r.Site_Address_Actual__c
                    		  from Tower__c where Project__c = : projectId];
		if (towerRecordsForPDF != null && towerRecordsForPDF.Size() > 0){			
			projectName = towerRecordsForPDF[0].Project_Name__c;
			ProjectAddress = towerRecordsForPDF[0].Project__r.Site_Address_Actual__c;
			for(Tower__c tower:towerRecordsForPDF){ 
		     	options.add(new SelectOption(tower.Id,tower.name));
	   		}
	    }
	    return options;
	}
	
	public void getPopUnitPicklst(){
		
		UnitValues = [select name, Floor__c, Unit_Type__c from Unit__c where Tower_Id__c = : selectedTowers];
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
    		if(unitOptions != null && unitOptions.size() > 0){
    			generateButtonFlag = false;
    			
    		}
    		else{
    			generateButtonFlag = true;	
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, System.Label.RBI_ProjectUnitButtonDisable));
    		}
    	}
    	else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.RBI_ProjectTowerSelection));
		}
    	return null;
    }
    
    public PageReference generatePDF(){
		conList = new list<Contact>();
       	if(selectedTowers != null && selectedTowers != '--None--'){
			conList = [SELECT Name, FirstName, Email, LastName FROM Contact WHERE AccountId = :AcctId AND Primary__c = true];
			if(conList != null && conList.size() > 0)
				con = conList[0];
			if(BorrowerEmail != null && BorrowerEmail != '' && con != null){
	    		myAttach.Name = ProjectRec.Project_Name__c + 'UnitReport.pdf';
	    		PageReference myPdf = Page.RBI_ProjectUnitPDFPage;
	    		myPdf.getParameters().put('projId', projectId);
				myPdf.getParameters().put('SelTowId', selectedTowers);
				myPdf.getParameters().put('SelUnitId', SelectedUnit);
				myPdf.getParameters().put('SelPayTypeId', selectedPaymType);
				Blob b;
				if(!Test.isRunningTest()){
		    		myAttach.Body = myPdf.getContentAsPdf();
		    		b = myPdf.getContent();
		    		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		    		email.setTargetObjectId(con.Id);
		    		email.saveAsActivity = false;
		    		email.setTemplateId(System.Label.RBI_UnitReportTemplate);
		    		email.setWhatId(ProjectRec.Id);
		    		String [] toAddresses = new String[] 
		    		{
		    			BorrowerEmail
		    		};
		    		email.setToAddresses(toAddresses);   
		    		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		    		efa.setFileName(ProjectRec.Project_Name__c + 'UnitReport.pdf');
		    		efa.setBody(b);
		    		email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
		    		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
				 }
			}
			PageReference pg = new PageReference('/apex/RBI_ProjectUnitPDFPage');
			pg.getParameters().put('projId', projectId);
			pg.getParameters().put('SelTowId', selectedTowers);
			pg.getParameters().put('SelUnitId', SelectedUnit);
			pg.getParameters().put('SelPayTypeId', selectedPaymType);
			List_of_Values__c listOfValues;
			
			if(projectId != null && SelectedUnit != null && AcctId != null && AcctId != System.Label.RBI_AccountId){
				 listOfValues = new List_of_Values__c(Name = 'Unit Report Matrix', Entity_Type__c = 'Unit Report Matrix', Unit_Report_Gen_Date__c = system.today(), Customer__c = AcctId, Unit__c = SelectedUnit);	
			}
			try{
				if(listOfValues != null){
					insert listOfValues;
				}
			}catch(DMLException e){
				system.debug(e);
			}
			
			return pg; 
		 }
		 else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Tower Name'));
		}
		return null;
	}


	@IsTest(SeeAllData=true)  static  void UnitTest() {
    	
    	//create record for following object and make association between them
    	ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
    	
    	list<Account> acc = new list<Account>();
        Account Acnt = new Account(Name = 'TestLastName', RecordTypeId = CusRecType);
        acc.add(Acnt);
        insert acc;
		
		list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '568980', Site_Address_zipcode__c = '412578', 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
		projlist.add(proj);
		insert projlist;
		
		list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
		Customer_Projects__c cp = new Customer_Projects__c(Project_Id__c = projlist[0].Id, AccountId__c = acc[0].Id,Weightage_Basement__c=3,Weightage_Electrification_Sanitation__c=3,Weightage_Excavaton_of_Footings__c=1,Weightage_Finishing__c=5,Weightage_Masonary__c=6,Weightage_RCC_Slab_Casting__c=4);
		customerProjectlist.add(cp);
		insert customerProjectlist;
		
		list<Tower__c> towerlist = new list<Tower__c>();
		Tower__c twd = new Tower__c(Project__c = projlist[0].Id, Name = 'TowerA',Structure_as_per_Plan__c='30',
									Avg_Resale_Price_per_Sq_Ft__c=22,Deviation__c='Yes' );
		towerlist.add(twd);
		insert towerlist;
		
		list<Unit_Type__c> unittypelist= new list<Unit_Type__c>();
		Unit_Type__c unit= new Unit_Type__c(Built_up_area_Sq_Ft__c = 20, Carpet_Area_Sq_Ft__c = 15, 
											Project__c=projlist[0].Id, Unit_Type__c='1 BHK');
		unittypelist.add(unit);
		insert unittypelist;
		
		list<Unit__c> unitlist = new list<Unit__c>();
		Unit__c un = new Unit__c(Unit_Type_Id__c = unittypelist[0].Id, Tower_Id__c = towerlist[0].Id);
		unitlist.add(un);
		insert unitlist;
		
		list<Construction_Status__c> Constructionstatuslist = new list<Construction_Status__c>();
		Construction_Status__c constatus = new Construction_Status__c(Electrification_and_Sanitation__c = '8', 
											Excavation_of_Footings__c = 'U',Finishing__c='10' ,Tower__c=towerlist[0].Id,RCC_Slab_Casting__c='10');
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
		Payment_Plan__c payment = new Payment_Plan__c(Discount__c =20, Project__c = projlist[0].id, Plan_Type__c=lov1.Id);
		paymentlist.add(payment);
		insert paymentlist;
       	
       	list<Additional_Charges__c> addnchglist = new list<Additional_Charges__c>();
       	Additional_Charges__c addchg = new Additional_Charges__c(Project__c = projlist[0].Id, Charge_Per_Sqft__c = 100, Charge_Type__c='PLC',Charge_Detail__c = 'Floor Rise'
       									, From_Floor__c = '1', Mandatory__c = true, To_Floor__c = '10', Remarks__c = 'Very good'
       									, Resale_Value__c = 'Transferable');
       	addnchglist.add(addchg);
       	insert addnchglist;
       	
       	list<Detail_Price_List__c> Detailpricelist = new list<Detail_Price_List__c>();
		Detail_Price_List__c detail = new Detail_Price_List__c( Project__c = projlist[0].id,Tower__c=towerlist[0].Id,Rate_11__c=200);
		Detailpricelist.add(detail);
		insert Detailpricelist;
		
		//start test class method
       	System.Test.startTest();
       	
       	//Instantiate the RBI_ProjectUnitPage
		PageReference RBI_ProjectUnitPage = Page.RBI_ProjectUnitPage;
		System.Test.setCurrentPage(RBI_ProjectUnitPage);
		
		//Instantiate the class which is used in the page above
		apexpages.currentpage().getparameters().put('projectId' , projlist[0].Id);
       	RBI_ProjectUnitClass rbiprjunit = new RBI_ProjectUnitClass();
       	rbiprjunit.projectId=projlist[0].id;
       	rbiprjunit.BorrowerName = 'Test';
       	rbiprjunit.selectedTowers = towerlist[0].Id;
       	rbiprjunit.selectedPaymType = paymentlist[0].Id;
       	rbiprjunit.selectedUnit = unitlist[0].Id;
       	rbiprjunit.selUnitFloor= un.Floor__c;
        
        //test  method of RBI_ProjectUnitClass
       	rbiprjunit.getTypesofPaymPlan();
       	rbiprjunit.getPaymentType();
       	rbiprjunit.gettowerRecords();
       	rbiprjunit.getPopUnitPicklst();
        rbiprjunit.generateButtonFlag=true;
       	rbiprjunit.populatePicklistValue();
       	rbiprjunit.BorrowerEmail='';
       	rbiprjunit.generatePDF();
       	rbiprjunit.BorrowerEmail='samal@gmail.com';
       	rbiprjunit.generatePDF();
       	
       	//Stop the Test Class
       	System.Test.stopTest();
    	}
}