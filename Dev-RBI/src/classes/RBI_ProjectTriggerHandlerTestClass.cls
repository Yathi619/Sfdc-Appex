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
private class RBI_ProjectTriggerHandlerTestClass {

    static testMethod void RBI_ProjectTriggerHandler() {
    	
   	 	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
   	 	//UserRole r = [Select id from UserRole where Name='Surveyor'];
   	 	UserRole ur = new UserRole(Name = 'Surveyor');
   	 	insert ur;
      	User u = new User(Alias = 'CRMAdmin', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
      					LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, City = 'Bangalore', userroleid = ur.Id, 
      					TimeZoneSidKey='America/Los_Angeles', UserName='stduser@testorg.com');
      				
      	System.runAs(u) {
      		System.debug('Current User: ' + UserInfo.getUserName());
      		System.debug('Current Profile: ' + UserInfo.getProfileId());
      		//insert project record for before insert And before update
		
		ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
		ID  DevRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Developer'].Id;
		      		
      	list<Account> accnt = new list<Account>();
      	Map<Id, Account> ObjectMap = new Map<Id, Account>();//blank
		Account acc = new Account(Name = 'Testclass Account', Description = 'Test', RecordTypeId = CusRecType, BillingCity = 'Delhi');
		Account acc1 = new Account(Name = 'Testclass Account1', Description = 'Test', RecordTypeId = DevRecType, BillingCity = 'Bangalore');
		Account acc2 = new Account(Name = 'Testclass Account2', Description = 'Test', RecordTypeId = DevRecType, BillingCity = 'Chennai');
		accnt.add(acc);
		accnt.add(acc1);
		accnt.add(acc2);
		insert accnt;
		
		list<Account> accnt1 = new list<Account>();
		accnt[2].name = 'Test Account1';
		Account acc3 = new Account(Name = 'Test Account2', Description = 'Test', RecordTypeId = DevRecType, BillingCity = 'Faridabad');
		accnt1.add(accnt[2]);
		accnt1.add(acc3);
		try{
			upsert accnt1;
		}catch(DMLException e){
			system.debug(e);
		}
		   
		list<Contact> cnt = new list<Contact>();
		Contact con = new Contact(LastName = 'LastContact', AccountId = accnt[0].Id, Email = 'test@gmail.com', Primary__c = true, Group_Email__c = 'test1@gmail.com, abc@xyz.com');
		cnt.add(con);
		insert cnt;
      	
      	list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class',Status__c='PDS' , Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Developer_Id__c = accnt[1].Id, Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
										 Launch_Date__c = System.today(),Site_Address_City__c='Bangalore',OwnerId = u.id, Surveyor__c = u.Id);
		Project__c proj1 = new Project__c(Project_Name__c='Test1 Class',Status__c='PMR' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
		 								 City__c ='test', Developer_Id__c = accnt[1].Id, Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
		 								 Launch_Date__c = System.today(),Site_Address_City__c='Hydrabad');
		Project__c proj2 = new Project__c(Project_Name__c='Test2 Class', Status__c='PMS' ,Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
		 								  Brochure_Zipcode__c = '123456', Developer_Id__c = accnt[1].Id, Site_Address_zipcode__c = '654321' , 
		 								  Launch_Date__c = System.today(),Site_Address_City__c='Bangalore');							 								 
		projlist.add(proj);
		projlist.add(proj1);
		projlist.add(proj2);
		insert projlist;
		
		//Id  Accid=System.Label.RBI_AccountId;
		
		list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
		List_of_Values__c lov = new List_of_Values__c(Name='PAS', Entity_Name__c = 'PAS',Entity_Type__c = 'Package',
								Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
		List_of_Values__c lov1 = new List_of_Values__c(Name='FTR',Entity_Name__c = 'FTR',Entity_Type__c = 'Package',
								Bank_Name__c = 'HDFC Bank', Completion_Year__c = 2014, Dwelling_Units__c=13, Loan_Amount__c=24000, Dev_Project_Address__c='test unit2');
		List_of_Values__c lov2 = new List_of_Values__c(Name='CRM Report',Key__c='Followup Report',Entity_Name__c = 'CRM Report',Entity_Type__c = 'Package',
								Bank_Name__c = 'HDFC Bank', Completion_Year__c = 2014, Dwelling_Units__c=13, Loan_Amount__c=24000, Dev_Project_Address__c='test unit2');
		List_of_Values__c lov3 = new List_of_Values__c(Name='PMS',Entity_Name__c = 'PMS',Entity_Type__c = 'Package',
								Bank_Name__c = 'HDFC Bank', Completion_Year__c = 2014, Dwelling_Units__c=13, Loan_Amount__c=24000, Dev_Project_Address__c='test unit2');																
		lovlist.add(lov);
		lovlist.add(lov1);
		lovlist.add(lov2);
		lovlist.add(lov3);
		insert lovlist;
		
		list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
		Customer_Projects__c cp = new Customer_Projects__c(Project_Id__c = projlist[0].Id, AccountId__c = accnt[0].Id);
		Customer_Projects__c cp1 = new Customer_Projects__c(Project_Id__c = projlist[1].Id, AccountId__c = accnt[0].Id);
		Customer_Projects__c cp2 = new Customer_Projects__c(Project_Id__c = projlist[2].Id, AccountId__c = accnt[0].Id);
		customerProjectlist.add(cp);
		customerProjectlist.add(cp1);
		customerProjectlist.add(cp2);
		insert customerProjectlist;
		
    	list<Project_Cust_Packages__c> prjCustPack = new list<Project_Cust_Packages__c>();
        Project_Cust_Packages__c ProjCustomPack = new Project_Cust_Packages__c (List_of_Values__c=lov.id, Customer_Project__c=customerProjectlist[0].Id);
        Project_Cust_Packages__c ProjCustomPack1 = new Project_Cust_Packages__c (List_of_Values__c=lov1.id, Customer_Project__c=customerProjectlist[1].Id);
        Project_Cust_Packages__c ProjCustomPack2 = new Project_Cust_Packages__c (List_of_Values__c=lov2.id, Customer_Project__c=customerProjectlist[2].Id);
        prjCustPack.add(ProjCustomPack);
        prjCustPack.add(ProjCustomPack1);
        prjCustPack.add(ProjCustomPack2);
        insert prjCustPack;
    	
		//for update trigger
		//Start Test Class
		Test.startTest();
		
        projlist[1].Project_Name__c='Test1 Class';
		projlist[1].Site_Address_City__c='Bangalore';
		projlist[1].Status__c = 'PMR';
		update projlist[1];
		
		projlist[2].Project_Name__c='Test2 Class';
		projlist[2].Site_Address_City__c='Mumbai';
		projlist[2].Status__c = 'PMR';
		update projlist[2];
		
		RBI_AccountTriggerHandler acTrHand = new RBI_AccountTriggerHandler();
		list<Account> actr = new list<Account>();
		//acTrHand.OnBeforeUpdate(accnt, actr, ObjectMap);
		RBI_ProjectTriggerHandler handler = new RBI_ProjectTriggerHandler();
		proj.Surveyor__c = u.Id;
		
		RBI_ProjectTriggerHandler.wrapEmailProject wrp1 = new RBI_ProjectTriggerHandler.wrapEmailProject(cp1);
		RBI_ProjectTriggerHandler.wrapEmailProject wrp = new RBI_ProjectTriggerHandler.wrapEmailProject(cp1,'sr@gmail.com');
		
		//Stop Test Class
		Test.stopTest();
      	}
    }
}