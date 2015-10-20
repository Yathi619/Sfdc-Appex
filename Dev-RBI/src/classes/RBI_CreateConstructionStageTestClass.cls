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
private class RBI_CreateConstructionStageTestClass {

    static testMethod void RBI_CreateConstructionStage() {
    // Create Project Records
    	list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' , Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , Launch_Date__c = System.today(),
										 Site_Address_City__c='Bangalore');
		Project__c proj1 = new Project__c(Project_Name__c='Test1 Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
		 								 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , Launch_Date__c = System.today()-2,
		 								 Site_Address_City__c='Hydrabad');
		Project__c proj2 = new Project__c(Project_Name__c='Test2 Class', Status__c='PMS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
		 								  Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , Launch_Date__c = System.today()+2,
		 								  Site_Address_City__c='Bangalore');							 								 
		projlist.add(proj);
		projlist.add(proj1);
		projlist.add(proj2);
		insert projlist;
		
	//create tower for project
		list<Tower__c> towerlist = new list<Tower__c>();
		Tower__c twd = new Tower__c(Project__c = projlist[0].Id, Name = 'TowerA',Structure_as_per_Plan__c='13',
									Avg_Resale_Price_per_Sq_Ft__c=250,Deviation__c='Yes',Planned_Basement_Floors__c=2,Planned_Parking_Floors__c=2,Planned_ResCom_Floors__c=15,Actual_Basement_Floors__c=2, Actual_Parking_Floors__c=3,Actual_ResCom_Floors__c=16  );
		towerlist.add(twd);
		insert towerlist;
		
	//create construction Status
		list<Construction_Status__c> Constructionstatuslist = new list<Construction_Status__c>();
		Construction_Status__c constatus = new Construction_Status__c(Electrification_and_Sanitation__c = '8', Masonary__c='6',
											Excavation_of_Footings__c = 'UC',Basement__c='UC',Finishing__c='10' ,RCC_Slab_Casting__c='10',Project__c=projlist[0].id,Tower__c=twd .id);
		Construction_Status__c constatus1 = new Construction_Status__c(Electrification_and_Sanitation__c = '8', Masonary__c='7',
											Excavation_of_Footings__c = 'N',Basement__c='UC',Finishing__c='10' ,RCC_Slab_Casting__c='10',Project__c=projlist[1].id,Tower__c=twd .id);									
		Constructionstatuslist.add(constatus); 
		Constructionstatuslist.add(constatus1);
		insert Constructionstatuslist;
		
	//start test class method
       	Test.startTest();
       	
    //Instantiate the CreateConstructionStatus Page
		PageReference CreateConstructionpage = Page.RBI_CreateConstructionStatus;
		System.Test.setCurrentPage(CreateConstructionpage);
		Apexpages.currentpage().getparameters().put('ProjId' ,projlist[0].Id);
		Apexpages.currentpage().getparameters().put('ProjName' ,projlist[0].Project_Name__c);
		ApexPages.StandardController stdCon = new ApexPages.StandardController(constatus);
		RBI_CreateConstructionStage constage = new RBI_CreateConstructionStage(stdCon);
		constage.getTowers();
		conStage.goToStandard();
		constage.doSave();
		constage.doCancel();
		
	//call doSaveandNew() method
		ApexPages.StandardController stdCon1 = new ApexPages.StandardController(constatus1);
		RBI_CreateConstructionStage constage1 = new RBI_CreateConstructionStage(stdCon1);
		constage1.CommonMethod();
		constage1.doSaveandNew();
		
	//stop test class method
		Test.stopTest();
    }
}