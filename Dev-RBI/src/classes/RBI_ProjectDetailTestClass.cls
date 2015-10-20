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
private class RBI_ProjectDetailTestClass {
	
	enum PortalType { CSPLiteUser, PowerPartner, PowerCustomerSuccess, CustomerSuccess }

    static testMethod void ProjectDetailTest() {
        User pu = getPortalUser(PortalType.PowerCustomerSuccess, null, true);
        System.assert([select isPortalEnabled 
                         from user 
                        where id = :pu.id].isPortalEnabled,
                      'User was not flagged as portal enabled.');       
        System.RunAs(pu) {
        }
    }
    
    public static User getPortalUser(PortalType portalType, User userWithRole, Boolean doInsert) {
    
        /* Make sure the running user has a role otherwise an exception 
           will be thrown. */
        if(userWithRole == null) {   
            if(UserInfo.getUserRoleId() == null) {
                UserRole r = new UserRole(name = 'TEST ROLE');
                Database.insert(r);
                userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                    timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
            } else {
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }
            System.assert(userWithRole.userRoleId != null, 
                          'This test requires the target org to have at least one UserRole created. Please create a user role in this organization and try again.');
        }

        Contact c;
       System.runAs(userWithRole) {
	        ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
			ID  DevRecType = [SELECT Id FROM RecordType WHERE Name = 'Developer'].Id;
			//
			list<Account> acc = new list<Account>();
	       	Account Acnt = new Account(Name = 'TestAccount', BillingStreet = 'TestStreet', BillingCity = 'Hyderabad', BillingState = 'AP', BillingCountry = 'India',
	       								BillingPostalCode = '123456', Phone = '124567', Type='Customer',RecordTypeId = CusRecType );
	       	Account Acnt1 = new Account(Name = 'TestAccount5', BillingStreet = 'TestStreet', BillingCity = 'Hyderabad', BillingState = 'AP', BillingCountry = 'India',
	       								BillingPostalCode = '123456', Phone = '124567',RecordTypeId = DevRecType );							
	       	acc.add(Acnt);
	       	acc.add(Acnt1);
	       	insert acc;
	
	        Id Accid = Acnt.Id;
	        c = new Contact(AccountId = Accid, lastname = 'lastname');
	        Database.insert(c);
       
       }
        /* Get any profile for the given type.*/
      Profile p = [select id from profile where usertype = 'PowerCustomerSuccess' limit 1];   
      String testemail = 'puser000@amamama.com';
      User pu = new User(profileId = p.id, username = testemail, email = testemail, emailencodingkey = 'UTF-8', localesidkey = 'en_US',  
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias='cspu', lastname='lastname', 
                           contactId = c.id,Covering_Cities__c='Bangalore');
     if(doInsert) {
	    Database.insert(pu);
	    
       	
		
		ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
		ID  DevRecType = [SELECT Id FROM RecordType WHERE Name = 'Developer'].Id;
		list<Account> acc = new list<Account>();
       	Account Acnt = new Account(Name = 'TestAccount1', BillingStreet = 'TestStreet1', BillingCity = 'Bangalore', BillingState = 'AP', BillingCountry = 'India',
       								BillingPostalCode = '123456', Phone = '124567', Type='Customer',RecordTypeId = CusRecType );
       	Account Acnt1 = new Account(Name = 'TestAccount2', BillingStreet = 'TestStreet1', BillingCity = 'Mumbai', BillingState = 'AP', BillingCountry = 'India',
       								BillingPostalCode = '123456', Phone = '124567',RecordTypeId = DevRecType );							
       	acc.add(Acnt);
       	acc.add(Acnt1);
       	insert acc;

       // Id Accid = Acnt.Id;
        list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today(),Status__c='Approved');
		Project__c proj1 = new Project__c(Project_Name__c='Test Class2', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today(),Status__c='Approved');								 
		projlist.add(proj);
		projlist.add(proj1);
		insert projlist;
        
      //  list<Customer_Projects__c> applist = new list<Customer_Projects__c>();
        
      //  applist = [Select Id, Name, Project_Name__c, Project_Id__c,Project_Id__r.Technical_Head__c,Remarks__c, Exception__c, Project_Approval_Status__c, Project_Id__r.City__c, FTR_File_Path__c
         		//		From Customer_Projects__c where AccountId__c = : Accid and Project_Id__c = : projlist[0].Id];
        
		list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
		Customer_Projects__c cp = new Customer_Projects__c(Remarks__c = 'Good', Project_Id__c = projlist[1].Id, AccountId__c = acc[0].Id, 
															Project_Approval_Status__c = 'Approved', Exception__c = false);
		customerProjectlist.add(cp);
		insert customerProjectlist;
		
		list<Visit__c> vstList = new list<Visit__c>();
    	Visit__c vst = new Visit__c(Status__c = 'Positive', Project__c = projlist[1].Id,  Visit_Report__c = 'TSR Report');
    	Visit__c vst1 = new Visit__c(Status__c = 'Positive', Project__c = projlist[1].Id,  Visit_Report__c = 'DVU Report');
    	Visit__c vst2 = new Visit__c(Status__c = 'Approved', Project__c = projlist[1].Id,  Visit_Report__c = 'First Technical Report');
    	vstList.add(vst);
    	vstList.add(vst1);
    	vstList.add(vst2);
    	insert vstList;
    	
		
		list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
		List_of_Values__c lov = new List_of_Values__c(Name='Market Feedback', Entity_Name__c = 'CRM Report',Entity_Type__c = 'Package',
								Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
		List_of_Values__c lov1 = new List_of_Values__c(Name='PAS', Entity_Name__c = 'CRM Report',Entity_Type__c = 'Document',
								Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Loan_Amount__c=25000, Dev_Project_Address__c='test unit');	
		List_of_Values__c lov2 = new List_of_Values__c(Name='PMS', Entity_Name__c = 'CRM Report',Entity_Type__c = 'Document',
								Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, Loan_Amount__c=25000, Dev_Project_Address__c='test unit');											
		lovlist.add(lov);
		lovlist.add(lov1);
		lovlist.add(lov2);
		insert lovlist;
		
		list<Project_Document_Status__c>  prjDoc = new list<Project_Document_Status__c>();
		Project_Document_Status__c pdoc = new Project_Document_Status__c(Project_Document__c = lovlist[1].Id);
		Project_Document_Status__c pdoc1 = new Project_Document_Status__c(Project_Document__c = lovlist[2].Id);
		prjDoc.add(pdoc);
		prjDoc.add(pdoc1);
		insert prjDoc;
		
    	list<CRM_Report__c> crmrep = new list<CRM_Report__c>();
		CRM_Report__c crmreport = new CRM_Report__c(Name__c = 'Test Report', Project__c = projlist[1].Id, Report_Name__c = lovlist[1].Id);
		CRM_Report__c crmreport1 = new CRM_Report__c(Name__c = 'Test Report1', Project__c = projlist[1].Id, Report_Name__c = lovlist[2].Id);
		crmrep.add(crmreport);
		crmrep.add(crmreport1);
		insert crmrep;
		
		//start test class method
       	System.Test.startTest();
       	System.runAs(userWithRole) {
	       	//Instantiate the RBI_ProjectDetailPage which generates the PDF
			PageReference ProjectDetail = Page.RBI_ProjectDetail;
			System.Test.setCurrentPage(ProjectDetail);
		
			//Test the RBI_ProjectDetail Class And Method 
			ApexPages.StandardController stdCon = new ApexPages.StandardController(proj);
			RBI_ProjectDetail projDetail = new RBI_ProjectDetail(stdCon);
			//projDetail.approvallist = applist;
			//projDetail.appStatus = customerProjectlist[0].Project_Approval_Status__c;
			//projDetail.custProjId = customerProjectlist[0].Id;
			//projDetail.Exceptionflg = customerProjectlist[0].Exception__c;
			projDetail.CreateExpandSendEmail();
			projDetail.loadProjReportList();
			projDetail.loadProjVisitList();
			projDetail.loadProjReportList();
			projDetail.savAppStatus();
			projDetail.saveServices();
			projDetail.CheckFTR();
			projDetail.displayPopup=true;
			projDetail.showPopup();
			projDetail.displayPopup=false;
			projDetail.closePopup();
			projDetail.doCancel();      
       	}              
        }
	return pu;
        
   }
}