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
private class RBI_DeveloperOtherProjectsTestClass {

    static testMethod void DeveloperOtherProject() {
        
        ID  DevRecType = [SELECT Id FROM RecordType WHERE Name = 'Developer'].Id;
        
        list<Account> acc = new list<Account>();
        Account Acnt = new Account(Name = 'TestLastName', RecordTypeId = DevRecType);
        acc.add(Acnt);
        insert acc;
        
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
		PageReference rbiDevOtherproj = Page.RBI_OtherOngoingCompletedProjects;
		System.Test.setCurrentPage(rbiDevOtherproj);
		
		//Instantiate the class which is used in the page above
		Apexpages.currentpage().getparameters().put('AccId' , acc[0].Id);
		ApexPages.StandardController stdCon = new ApexPages.StandardController(lov);
		RBI_DeveloperOtherProjects DevOtherProj = new RBI_DeveloperOtherProjects(stdCon);
		DevOtherProj.AccountId = acc[0].Id;
		DevOtherProj.LOV.Name = 'Other Projects';
		DevOtherProj.LOV.Entity_Type__c = 'Other Projects';
		DevOtherProj.Save();
		
		//Logic for SaveAndNew Method
		ApexPages.StandardController stdCon1 = new ApexPages.StandardController(lov1);
		RBI_DeveloperOtherProjects DevOtherProj1 = new RBI_DeveloperOtherProjects(stdCon1);
		DevOtherProj1.AccountId = acc[0].Id;
		DevOtherProj1.LOV.Name = 'Other Projects';
		DevOtherProj1.LOV.Entity_Type__c = 'Other Projects';
		DevOtherProj1.SaveandNew();
		DevOtherProj.doCancel();
		
		//Stop Test Class
		System.Test.stopTest();
    }
}