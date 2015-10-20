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
@IsTest(SeeAllData=true) 
private class RBI_PortalHomePageTestClass {

    static testMethod void PortalHomePageTest() {
        
        ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
        
        list<Account> acc = new list<Account>();
        Account Acnt = new Account(Name = 'TestLastName', RecordTypeId = CusRecType);
        acc.add(Acnt);
        insert acc;
        
        list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(), Site_Address_City__c = 'Bangalore',
										 City__c ='test', Brochure_Zipcode__c = '123456' , Status__c = 'PMR', Site_Address_zipcode__c = '654321',  
										 Project_Region__c = 'East', Launch_Date__c = System.today());
		projlist.add(proj);
		insert projlist;
		
		list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
		Customer_Projects__c cp = new Customer_Projects__c(Remarks__c = 'Good', Project_Id__c = projlist[0].Id, AccountId__c = acc[0].Id , 
														   Project_Approval_Status__c = 'In Progress');
		customerProjectlist.add(cp);
		insert customerProjectlist;
		
		list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
		List_of_Values__c lov = new List_of_Values__c(Name='PMS', Entity_Name__c = 'Package',Entity_Type__c = 'Package',
								Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
		lovlist.add(lov);
		insert lovlist;
		
		list<Project_Cust_Packages__c> projCust = new list<Project_Cust_Packages__c>();
		Project_Cust_Packages__c prjCustPack = new Project_Cust_Packages__c(Customer_Project__c = customerProjectlist[0].Id, List_of_Values__c = lovlist[0].Id);
        projCust.add(prjCustPack);
        //insert prjCustPack;        
        
        //Start Test Class
        RBI_PortalHomePageClass portalHomeClass = new RBI_PortalHomePageClass();
        portalHomeclass.getBarDataPAS();
        portalHomeclass.getBarDataPMS();
        portalHomeclass.getCityTableData();
    }
}