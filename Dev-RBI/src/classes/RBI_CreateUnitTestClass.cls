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
private class RBI_CreateUnitTestClass {

    static testMethod void RBI_CreateUnitTest() {
     list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '412578', Site_Address_zipcode__c = '123456', 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
		projlist.add(proj);
		insert projlist;
        list<Tower__c> towerlist = new list<Tower__c>();
		Tower__c twd = new Tower__c(Project__c = projlist[0].Id, Name = 'TowerA',Structure_as_per_Plan__c='13',
									Avg_Resale_Price_per_Sq_Ft__c=250,Deviation__c='Yes',Planned_Basement_Floors__c=2,Planned_Parking_Floors__c=2,Planned_ResCom_Floors__c=15,Actual_Basement_Floors__c=2, Actual_Parking_Floors__c=3,Actual_ResCom_Floors__c=16  );
		towerlist.add(twd);
		insert towerlist;
		list<Unit_Type__c> unittypelist = new list<Unit_Type__c>();
		Unit_Type__c unit= new Unit_Type__c(Built_up_area_Sq_Ft__c = 20, Carpet_Area_Sq_Ft__c = 15, 
											Project__c=projlist[0].Id, Unit_Type__c='1 BHK');
		unittypelist.add(unit);
		insert unittypelist;
		//start test class method
       	System.Test.startTest();
       	
       	//Instantiate the RBI_CreateUnits which generates the PDF
		PageReference CreateunitPage = Page.RBI_CreateUnits;
		System.Test.setCurrentPage(CreateunitPage);
		apexpages.currentpage().getparameters().put('ProjId' , projlist[0].Id);
		apexpages.currentpage().getparameters().put('TowId' , towerlist[0].Id);
		apexpages.currentpage().getparameters().put('TowName' , towerlist[0].Name);
	
		//Instantiate  RBI_CreateUnits class
		RBI_CreateUnits unitCreate= new RBI_CreateUnits();
		unitCreate.towerId = apexpages.currentpage().getparameters().put('TowId' , towerlist[0].Id);
		unitCreate.ProjectId = apexpages.currentpage().getparameters().put('ProjId' , projlist[0].Id); 
		unitCreate.TowerName = apexpages.currentpage().getparameters().put('TowName' , towerlist[0].Name);
		//Call RBI_CreateUnits Class Method
		unitCreate.getUnitTypeOptions();
		unitCreate.unitCount = 3;
		unitCreate.selectedUnitType = unit.Id;
		unitCreate.populateSuperArea();
		unitCreate.doCreate();
		unitCreate.doCreateandNew();
		unitCreate.doCancel();
		//stop test class Method
		System.Test.stopTest();
    }
}