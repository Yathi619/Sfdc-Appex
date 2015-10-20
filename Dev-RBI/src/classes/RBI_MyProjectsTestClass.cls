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
private class RBI_MyProjectsTestClass {

    static testMethod void MyProjectsTest() {
        
        ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
        list<Account> acc = new list<Account>();
       	Account Acnt = new Account(Name = 'TestAccount', BillingStreet = 'TestStreet', BillingCity = 'Hyderabad', BillingState = 'AP', BillingCountry = 'India',
       								BillingPostalCode = '123456', Phone = '124567', Type='Customer', RecordTypeId = CusRecType);
       	acc.add(Acnt);
       	insert acc;
        
        list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , To_Be_Approved__c = false, 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
		projlist.add(proj);
		insert projlist;
		
		list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
		Customer_Projects__c cp = new Customer_Projects__c(Project_Id__c = projlist[0].Id, AccountId__c = acc[0].Id);
		customerProjectlist.add(cp);
		insert customerProjectlist;
		
		//start test class method
       	System.Test.startTest();
       	
       	//Instantiate the RBI_MyProjects Page
       	PageReference MyProjectPage = Page.RBI_MyProjects;
		System.Test.setCurrentPage(MyProjectPage);
		
		//Instantiate the RBI_MyProjects class
		RBI_MyProjects myProj= new RBI_MyProjects();
		myProj.InitialLoad();
		
		myProj.SearchVar = 'All';
		myProj.display();
		
		myProj.SearchVar = 'A';
		myProj.display();
		
		myProj.Projectname ='Test Class';
		myProj.Projectcity ='All';
		myProj.SearchProjects();
		
		//test selectoption  GetCity picklist method
		List<selectOption> locale_picklist_options = myProj.getCity();
        System.AssertNotEquals(0, locale_picklist_options.size());
		
		myProj.WrapperProjList = customerProjectlist;
		myProj.getproDetails();
		
		myProj.setproDetails(myProj.proDetails);
		myProj.detail();
		
		//Stop Test Class
		System.Test.stopTest();
    }
}