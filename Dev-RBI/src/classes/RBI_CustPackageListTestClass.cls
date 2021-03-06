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
@isTest
private class RBI_CustPackageListTestClass {

    static testMethod void RBI_CustPackageList() {
        //insert these object record for CustPackTrigTest
        
        ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
        list<Account> acc = new list<Account>();
		Account Acnt = new Account(Name = 'TestAccount1', BillingStreet = 'TestStreet1', BillingCity = 'Hyderabad1', BillingState = 'AP', BillingCountry = 'India',
       								BillingPostalCode = '123456', Phone = '124567', Type='Customer',RecordTypeId = CusRecType );
       	acc.add(Acnt);
       	insert acc; 
        
        list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
		projlist.add(proj);
		insert projlist;
		
		list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
		Customer_Projects__c cp = new Customer_Projects__c(Project_Id__c = projlist[0].Id, AccountId__c = acc[0].Id);
		customerProjectlist.add(cp);
		insert customerProjectlist;
		
		list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
		List_of_Values__c lov = new List_of_Values__c(Name='PAS', Entity_Name__c = 'PAS',Entity_Type__c = 'Package',
								Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
		
		lovlist.add(lov);
		insert lovlist;
		
		list<Project_Cust_Packages__c> prjCustPack = new list<Project_Cust_Packages__c>();
        Project_Cust_Packages__c ProjCustomPack = new Project_Cust_Packages__c (List_of_Values__c=lov.id,Customer_Project__c=customerProjectlist[0].Id);
        prjCustPack.add(ProjCustomPack);
        insert prjCustPack;
       
        //start test class method
       	System.Test.startTest();
       	
       	//Instantiate the RBI_CreateNewProject
		PageReference custpackglist = Page.RBI_CustPackageListPage;  
		System.Test.setCurrentPage(custpackglist);
		ApexPages.StandardController stdCon = new ApexPages.StandardController(proj);
		RBI_CustPackageListClass  CustPackageList= new  RBI_CustPackageListClass(stdCon);
		CustPackageList.projectId = Apexpages.currentPage().getParameters().put('Id', projlist[0].Id); 
		
		//stop test class
		System.Test.stopTest();
    }
}