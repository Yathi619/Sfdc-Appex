@isTest(SeeAllData=true)
private class RBI_CreateNewProjectTestClass {

    static testMethod void CreateNewProjectTest() {
      	ID  DevRecType = [SELECT Id FROM RecordType WHERE Name = 'Developer'].Id;
      	ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
       	list<Account> acc = new list<Account>();
       	Account Acnt = new Account(Name = 'TestAccount', BillingStreet = 'TestStreet', BillingCity = 'Hyderabad', BillingState = 'AP', BillingCountry = 'India',
       								BillingPostalCode = '123456', Phone = '124567', Type='Customer',RecordTypeId = DevRecType );
		Account Acnt1 = new Account(Name = 'TestAccount1', BillingStreet = 'TestStreet1', BillingCity = 'Hyderabad1', BillingState = 'AP', BillingCountry = 'India',
       								BillingPostalCode = '123456', Phone = '124567', Type='Customer',RecordTypeId = CusRecType );       								
       	acc.add(Acnt);
       	acc.add(Acnt1);
       	insert acc;
       
       	list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 Developer_Id__c =acc[0].Id , City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' ,
										 To_Be_Approved__c = true, Launch_Date__c = System.today(),Site_Address_City__c='Bangalore');
		projlist.add(proj);
		//insert projlist;
		
		
		//start test class method
       	System.Test.startTest();
       	
       	//Instantiate the RBI_CreateNewProject
		PageReference rbicreatproj = Page.RBI_CreateNewProject;
		System.Test.setCurrentPage(rbicreatproj);
		
		//Instantiate the class which is used in the page above
		ApexPages.StandardController stdCon = new ApexPages.StandardController(proj);
		RBI_CreateNewProject creatproj = new RBI_CreateNewProject(stdCon);
		creatproj.AddValue();
		creatproj.prj.To_Be_Approved__c = true; 
		creatproj.AcctId=acc[1].Id;
       	creatproj.save();
       	PageReference myProj = Page.RBI_MyProjects;
       	System.Test.setCurrentPage(myProj);
       	creatproj.doCancel();
       	
       	//Stop the Test class
       	System.Test.stopTest();
    }
}