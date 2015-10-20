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
private class RBI_ProjectSnapshotTestclass {

    static testMethod void RBI_ProjectSnapshot() {
		ID  DevRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Developer'].Id;
    	list<Account> accnt = new list<Account>();
    	Account acc = new Account(Name = 'Developer1', Type='Customer', Account_Subtype__c = 'Developer',RecordTypeId = DevRecType);
    	accnt.add(acc);
    	insert accnt;
    	
        list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Developer_Id__c = accnt[0].Id, Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
		projlist.add(proj);
		insert projlist;
		system.debug('projid is:'+projlist[0].Id);
		
		list<Contact> con = new list<Contact>();
    	Contact cnt = new Contact(LastName = 'Test Contact', Age__c = 23, Details_of_Experience__c='exp', Qualifications__c = 'BE',
		 							AccountId = projlist[0].Developer_Id__c);
		con.add(cnt);
		insert con;
		
		list<Visit__c> vstList = new list<Visit__c>();
    	Visit__c vst = new Visit__c(Status__c = 'Approved', Project__c = projlist[0].Id,  Visit_Report__c = 'TSR Report');
    	Visit__c vst1 = new Visit__c(Status__c = 'Approved', Project__c = projlist[0].Id, Visit_Report__c = 'DVU Report');
    	vstList.add(vst);
    	vstList.add(vst1);
    	insert vstList;
		
		list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
		List_of_Values__c lov = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Remark',Entity_Type__c='Remark',
								Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
								Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
		lovlist.add(lov);
		insert lovlist;
		
		list<Project_Feedback__c> projfeedbacklist = new list<Project_Feedback__c>();
		Project_Feedback__c projfeed = new Project_Feedback__c(List_of_Values_Id__c = lov.Id, Project__c = projlist[0].id,Comments__c='xxx');
		projfeedbacklist.add(projfeed);
		insert projfeedbacklist;
       	
		//start test class method
       	System.Test.startTest();
       	
       	PageReference ProjectsnapPage = Page.RBI_GenerateProjectSnapshotReport;
		System.Test.setCurrentPage(ProjectsnapPage);
		Apexpages.currentPage().getParameters().put('id' ,projlist[0].Id);
		ApexPages.StandardController stdCon = new ApexPages.StandardController(proj);
		RBI_ProjectSnapshot projsnapshot= new RBI_ProjectSnapshot(stdCon);
		projsnapshot.projid = Apexpages.currentPage().getParameters().put('id' ,projlist[0].Id);
		projsnapshot.showDevAccContact();
		System.assertEquals(projsnapshot.projlist.size()>0,true);
		projsnapshot.showlovproject();
		projsnapshot.showvisit();
		
		//Stop Test Class
       	System.Test.stopTest();
    }
}