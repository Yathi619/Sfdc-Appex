/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class RBI_ProjectReportPDFTestClass {

    static testMethod void myUnitTest() {
    	
		ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
		
		list<Account> acc = new list<Account>();
		Account accnt = new Account(Name = 'AccTest', Weightage_RCC_Slab_Casting__c = 4, Weightage_Masonary__c = 15, Weightage_Finishing__c = 5, 
									Weightage_Excavaton_of_Footings__c = 6, Weightage_Electrification_Sanitation__c = 3, Weightage_Basement__c = 10, RecordTypeId = CusRecType);
		acc.add(accnt);
		insert acc;    	
    	
       	list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
		projlist.add(proj);
		insert projlist;
		system.debug('projid is:'+projlist[0].Id);
		
		list<Visit__c> vstList = new list<Visit__c>();
    	Visit__c vst = new Visit__c(Status__c = 'Approved', Project__c = projlist[0].Id,  Visit_Report__c = 'TSR Report');
    	vstList.add(vst);
    	insert vstList;
		
		list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
		Customer_Projects__c cp = new Customer_Projects__c(Project_Id__c = projlist[0].Id, AccountId__c = acc[0].id);
		customerProjectlist.add(cp);
		insert customerProjectlist;
		
		list<Tower__c> towerlist = new list<Tower__c>();
		Tower__c twd = new Tower__c(Project__c = projlist[0].Id, Name = 'TowerA',Structure_as_per_Plan__c='13',
									Avg_Resale_Price_per_Sq_Ft__c=250,Deviation__c='Yes',Planned_Basement_Floors__c=2,Planned_Parking_Floors__c=2,Planned_ResCom_Floors__c=15,Actual_Basement_Floors__c=2, Actual_Parking_Floors__c=3,Actual_ResCom_Floors__c=16  );
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
		Payment_Plan__c payment = new Payment_Plan__c(Discount__c =20, Project__c = projlist[0].id,Plan_Type__c = lov1.Id);
		paymentlist.add(payment);
		insert paymentlist;
       	
       	list<Additional_Charges__c> addnchglist = new list<Additional_Charges__c>();
       	Additional_Charges__c addchg = new Additional_Charges__c(Project__c = projlist[0].Id, Charge_Per_Sqft__c = 100, Charge_Type__c='PLC',Charge_Detail__c = 'Floor Rise'
       									, From_Floor__c = '1', Mandatory__c = true, To_Floor__c = '20', Remarks__c = 'Very good'
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
		PageReference ProjectPdf = Page.RBI_ProjectReportPDF;
		System.Test.setCurrentPage(ProjectPdf);
		
		//Instantiate the Class
		ApexPages.StandardController stdCon = new ApexPages.StandardController(proj);
		RBI_ProjectReportPDF prjRep = new RBI_ProjectReportPDF(stdCon);
		
		//Stop the Test Class
		System.Test.stopTest();
    }
}