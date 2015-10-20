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
private class RBI_TowerUnitTyCountTestClass {

    static testMethod void RBI_TowerUnitTyCount() {
    	list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Launch_Date__c = System.today(),Brochure_Zipcode__c = '568980', 
										 Site_Address_City__c = 'Bangalore', Site_Address_zipcode__c = '412578');
		projlist.add(proj);
		insert projlist;
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
		
		//start test class method
       	System.Test.startTest();
       	
       	//Instantiate the RBI_TowerUnitTypeCount which generates the PDF
		PageReference ToweruncountPage = Page.RBI_TowerUnitTypeCount;
		System.Test.setCurrentPage(ToweruncountPage);
		apexpages.currentpage().getparameters().put('id' , towerlist[0].Id);
		
		//Instantiate  RBI_TowerUnittypeCount class
		ApexPages.StandardController stdCon = new ApexPages.StandardController(un);
		RBI_TowerUnittypeCount unitCount= new RBI_TowerUnittypeCount(stdCon);
		unitCount.towerId=apexpages.currentpage().getparameters().put('id' , towerlist[0].Id); 
		
		//Stop Test Class
		System.Test.stopTest();
    }
}