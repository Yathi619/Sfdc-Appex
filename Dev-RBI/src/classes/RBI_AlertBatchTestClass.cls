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
private class RBI_AlertBatchTestClass {

	static testMethod void RBI_AlertBatch() {
	//Querying user from org
	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    
      //UserRole ur = new UserRole(Name = 'Surveyor');
     // insert ur;
    list<UserRole> ur = [select name from UserRole where Name = 'Surveyor'];
	    User u = new User(Alias = 'CRMAdmin', Email='manjunath.rao@tugboat.in', EmailEncodingKey='UTF-8', LastName='Testing', FirstName='FstName',
      					LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, City = 'Bangalore', userroleid = ur[0].Id, 
      					TimeZoneSidKey='America/Los_Angeles', UserName='stduser@testorg.com');
      	insert u;
      	System.runAs(u) {			
			//creating project records
		    list<Project__c> projlist = new list<Project__c>();
			Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' , Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
											 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , Team_Leader__c = u.Id,
											 Launch_Date__c = System.today(), Site_Address_City__c='Mumbai');
			Project__c proj1 = new Project__c(Project_Name__c='Test1 Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
			 								 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , Team_Leader__c = u.Id,
			 								 Surveyor__c=u.id, Launch_Date__c = System.today()-2, Site_Address_City__c='Hydrabad');
			Project__c proj2 = new Project__c(Project_Name__c='Test2 Class', Status__c='PMS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
			 								  Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , Team_Leader__c = u.Id,
			 								  Launch_Date__c = System.today()+2, Site_Address_City__c='Bangalore');							 								 
			projlist.add(proj);
			projlist.add(proj1);
			projlist.add(proj2);
			insert projlist;
			
			//creating lov records
			list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
			List_of_Values__c lov = new List_of_Values__c(Name='test batch lov', Entity_Name__c = 'PAS',Entity_Type__c = 'Service Visit',
									Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
			List_of_Values__c lov1 = new List_of_Values__c(Name=' test Followup Lov',Key__c='FTR',Entity_Name__c = 'FTR',Entity_Type__c = 'Service Visit');
			lovlist.add(lov);
			lovlist.add(lov1);
			insert lovlist;
			
			System.runAs(u) {
		      	System.debug('Current User: ' + UserInfo.getUserName());
		      	System.debug('Current Profile: ' + UserInfo.getProfileId());
		      	//start test
				Test.StartTest();
				RBI_AlertBatch batch =  new RBI_AlertBatch();
				batch.QueryString = 'select Site_Address_City__c,Team_Lead_Email__c,PAS_Manager_Name__c, Launch_Date__c,Team_Leader__c, Surveyor__c, Launched_Flag__c, Name, OwnerId, Owner.Name, Project_Name__c from Project__c where Launched_Flag__c =\'false\' order by Team_Leader__c' ; 
				batch.start(null);
			    batch.execute(null, projlist);
			    batch.finish(null);
			    RBI_AlertScheduler sco = new RBI_AlertScheduler();
			    String sch = '0 0 23 * * ?';        
				system.schedule('visit Creates', sch, sco);
		    	//stop test
		    	test.stopTest();
			} 
      	    
      	}
		
	}
}