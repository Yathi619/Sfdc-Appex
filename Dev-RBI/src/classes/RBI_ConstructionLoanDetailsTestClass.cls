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
private class RBI_ConstructionLoanDetailsTestClass {

    static testMethod void ConstLoanDetails() {
        
        list<Account> acc = new list<Account>();
        Account Acnt = new Account(Name = 'TestLastName');
        acc.add(Acnt);
        insert acc;
        
        list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , To_Be_Approved__c = false, 
										 Status__c = 'PMR', Launch_Date__c = System.today(), Site_Address_City__c='Bangalore');
		projlist.add(proj);
		insert projlist;
        
        list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
		List_of_Values__c lov = new List_of_Values__c(Name='Other Projects', Entity_Name__c='Other Projects',Entity_Type__c='Other Projects',
								Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
		List_of_Values__c lov1 = new List_of_Values__c(Name='Other Projects1', Entity_Name__c='Other Projects1',Entity_Type__c='Other Projects1',
								Bank_Name__c = 'Axis Bank1', Completion_Year__c = 2012, Dwelling_Units__c=12, Loan_Amount__c=25000, Dev_Project_Address__c='test unit1');					
		lovlist.add(lov);
        lovlist.add(lov1);
        
        //start test class method
       	System.Test.startTest();
       	
       	//Instantiate the RBI_OtherOngoingCompletedProjects
		PageReference ConstLoan = Page.RBI_ConstructionLoanDetails;
		System.Test.setCurrentPage(ConstLoan);
		
		//Instantiate the class which is used in the page above
		Apexpages.currentpage().getparameters().put('ProjId' , acc[0].Id);
		ApexPages.StandardController stdCon = new ApexPages.StandardController(lov);
		RBI_ConstructionLoanDetails ConstLoanDetails = new RBI_ConstructionLoanDetails(stdCon);
		ConstLoanDetails.ProjectId = acc[0].Id;
		ConstLoanDetails.LOV.Project_Id_Const_Loan__c = projlist[0].Id;
		ConstLoanDetails.LOV.Name = 'Construction Loan Details';
		ConstLoanDetails.LOV.Entity_Type__c = 'Construction Loan Details';
		ConstLoanDetails.Save();
		
		//Logic for SaveAndNew Method
		ApexPages.StandardController stdCon1 = new ApexPages.StandardController(lov1);
		RBI_ConstructionLoanDetails ConstLoanDetails1 = new RBI_ConstructionLoanDetails(stdCon1);
		ConstLoanDetails1.ProjectId = acc[0].Id;
		ConstLoanDetails1.LOV.Project_Id_Const_Loan__c = projlist[0].Id;
		ConstLoanDetails1.LOV.Name = 'Construction Loan Details1';
		ConstLoanDetails1.LOV.Entity_Type__c = 'Construction Loan Details1';
		ConstLoanDetails1.SaveandNew();
		ConstLoanDetails.doCancel();
		
		//Stop Test Class
		System.Test.stopTest();
    }
}