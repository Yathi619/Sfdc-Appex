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
private class RBI_ExceptionAlertBatchTestClass {

    static testMethod void ExceptionAlertMethod() {
        
        //Querying user from org
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		list<UserRole> ur = [select name from UserRole where Name = 'Technical Head'];
		
		User u = new User(Alias = 'CRMAdmin', Email='manjunath.rao@tugboat.in', EmailEncodingKey='UTF-8', LastName='Testing', FirstName='FstName',
      					LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, City = 'Bangalore', userroleid = ur[0].Id, 
      					TimeZoneSidKey='America/Los_Angeles', UserName='stduser@testorg.com');
      	insert u;
      	System.runAs(u){
      		list<Project__c> projlist = new list<Project__c>();
			Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' , Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
											 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , Team_Leader__c = u.Id,
											 Launch_Date__c = System.today(), Site_Address_City__c='Bangalore',Technical_Head__c = u.Id);
			projlist.add(proj);
			insert projlist;
			
			list<Visit__c> vstLst = new list<Visit__c>();
			Visit__c vs = new Visit__c(Project__c = projlist[0].Id,  Visit_Report__c = 'First Technical Report',Exception__c =true);
			vstLst.add(vs);
			insert vstLst;
			
			list<Query__c> qry = new list<Query__c>();
			Query__c qrExc = new Query__c(Exception_Status__c = 'Open',Expected_Closure_Date__c = system.today()+1,Visit__c = vstLst[0].Id);
			Query__c qrExc1 = new Query__c(Exception_Status__c = 'Open',Expected_Closure_Date__c = system.today()+1, Visit__c = vstLst[0].Id);
			qry.add(qrExc);
			qry.add(qrExc1);
			insert qry;
			
			System.runAs(u){
				//Start Test Class
				Test.StartTest();
				RBI_ExceptionAlertBatch batch =  new RBI_ExceptionAlertBatch();
				batch.QueryString = 'select Name,Expected_Closure_Date__c,Query_Resolved_Date__c,Visit__c,Visit__r.Name,Visit__r.Project__r.Name,Technical_Head_EmailId__c,PAS_Manager_Email__c,Team_Leader_Email__c, Closure_Remarks__c,Expected_Closure_Email_Date__c, Query_Description__c, Query_Initiated_Date__c,Exception_Status__c, Other_Remarks__c,Customer_Project__c,Customer_Project__r.Project_Name__c,Customer_Project__r.Name,Visit__r.Project__r.Project_Name__c from Query__c  where Exception_Status__c != \'Closed\' and Expected_Closure_Email_Date__c = : todayDate order by Visit__c' ; 
				batch.start(null);
				Database.executeBatch(batch);
			    batch.finish(null);
			    RBI_ExceptionAlertScheduler sco = new RBI_ExceptionAlertScheduler();
            	String sch = '0 0 23 * * ?';
            	system.schedule('visit Creates', sch, sco);
			    
		      //stop test class
		    	test.stopTest();
			}
      	}		
    }
}