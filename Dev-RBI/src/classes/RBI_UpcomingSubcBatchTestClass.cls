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
private class RBI_UpcomingSubcBatchTestClass {

    static testMethod void UpcomingTestClass() {
        
        ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
      	
      	list<Account> accnt = new list<Account>();
		Account acc = new Account(Name = 'Testclass Account', Description = 'Test', RecordTypeId = CusRecType, BillingCity = 'Delhi');
		accnt.add(acc);
		insert accnt;
        
        list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' , Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , Launch_Date__c = System.today(), Site_Address_City__c='Mumbai');
		Project__c proj1 = new Project__c(Project_Name__c='Test1 Class',Status__c='PDS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
		 								 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , Launch_Date__c = System.today()+2, Site_Address_City__c='Hyderabad');
		Project__c proj2 = new Project__c(Project_Name__c='Test2 Class', Status__c='PMS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
		 								  Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , Launch_Date__c = System.today()+5, Site_Address_City__c='Bangalore');							 								 
		projlist.add(proj);
		projlist.add(proj1);
		projlist.add(proj2);
		insert projlist;
		
		//retrive Record Type ID Through  Schema.DescribeSObjectResult
		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.RBI_Subscription__c; 
		Map<String,Schema.RecordTypeInfo> SubRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
		Id UpcomingId = SubRecordTypeInfo .get('Upcoming').getRecordTypeId();
		Id LaunchedId = SubRecordTypeInfo .get('Launched').getRecordTypeId();
		
		//Insert  Subscription Record
		list<RBI_Subscription__c> sublist = new list<RBI_Subscription__c>();
		RBI_Subscription__c sub= new RBI_Subscription__c(Customer__c = accnt[0].Id, Upcoming_Cities__c = 'Bangalore', RecordTypeId = UpcomingId);
		RBI_Subscription__c sub1 = new RBI_Subscription__c(Start_Date__c = system.today()-1, Customer__c = accnt[0].Id, Launched_Cities__c = 'Mumbai', RecordTypeId = LaunchedId);
		sublist.add(sub);									
		sublist.add(sub1); 
		insert sublist;
		
		//start test
		Test.StartTest();

		RBI_UpcomingSubcBatch batch =  new RBI_UpcomingSubcBatch();
		Database.executeBatch(batch);
		
		RBI_UpcomingSubcScheduler sco = new RBI_UpcomingSubcScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('visit Creates', sch, sco);
		     
		//stop test
		test.stopTest();
    }
}