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
@isTest (SeeAllData=true)
private class RBI_ExportXLStarterPgTestClass {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
        list<Account> acc = new list<Account>();
       	Account Acnt = new Account(Name = 'TestAccount', BillingStreet = 'TestStreet', BillingCity = 'Hyderabad', BillingState = 'AP', BillingCountry = 'India',
       								BillingPostalCode = '123456', Phone = '124567', Type='Customer', RecordTypeId = CusRecType);
       	acc.add(Acnt);
       	insert acc;
        
        list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , To_Be_Approved__c = false, 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today(),Status__c='PMR');
		projlist.add(proj);
		insert projlist;
		
		list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
		Customer_Projects__c cp = new Customer_Projects__c(Project_Id__c = projlist[0].Id, AccountId__c = acc[0].Id);
		customerProjectlist.add(cp);
		insert customerProjectlist;
		
		list<Tower__c> tw = new list<Tower__c>();
        Tower__c tow = new Tower__c(Name = 'Test Tower', Project__c = projlist[0].Id,Min_Avg_Developer_BSP_per_Sq_Ft__c=12, Launched_Units__c = 80,
                                        Min_Avg_Resale_Price_Per_Sqft__c=20, Max_Avg_Developer_BSP_per_Sq_Ft__c=25,
                                        Max_Avg_Resale_Price_Per_Sqft__c=27, Sold_Units__c=16);
        tw.add(tow);
        insert tw;
        
        /* This is created for Infrastructure_Near_Project__c */
        list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
            List_of_Values__c lov = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Infrastructure Near Project Site', Entity_Type__c='Public Convenience',
                                    Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
                                    Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
            List_of_Values__c lov1 = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Payment Plan',Entity_Type__c='Payment Plan',
                                    Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
                                    Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
            List_of_Values__c lov2 = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Document',Entity_Type__c='Document',
                                    Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
                                    Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
            List_of_Values__c lov3 = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Remark',Entity_Type__c='Remark',
                                    Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
                                    Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
            List_of_Values__c lov4 = new List_of_Values__c(Name='FTR', Entity_Name__c='Package',Entity_Type__c='Package',
                                    Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
                                    Loan_Amount__c=25000, Dev_Project_Address__c='test unit');  
            List_of_Values__c lov5 = new List_of_Values__c(Name='PAS', Entity_Name__c='Package',Entity_Type__c='Package',
                                    Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
                                    Loan_Amount__c=25000, Dev_Project_Address__c='test unit1');
                                    
            List_of_Values__c lov6 = new List_of_Values__c(Name='PMS', Entity_Name__c='Package',Entity_Type__c='Package',
                                    Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
                                    Loan_Amount__c=25000, Dev_Project_Address__c='test unit3');
                                                                
            lovlist.add(lov);
            lovlist.add(lov1);
            lovlist.add(lov2);
            lovlist.add(lov3);
            lovlist.add(lov4);
            lovlist.add(lov5);
            lovlist.add(lov6);
            insert lovlist;
        
        list<Infrastructure_Near_Project__c> infraproj = new list<Infrastructure_Near_Project__c>();
        Infrastructure_Near_Project__c infranearproj = new Infrastructure_Near_Project__c(Infrastructure_Near_Project__c = lov.Id, 
                                            Project_Id__c = projlist[0].Id);
        infraproj.add(infranearproj);
        insert infraproj;
                
        list<Project_Feedback__c> projfeedbacklist = new list<Project_Feedback__c>();
        Project_Feedback__c projfeed = new Project_Feedback__c(List_of_Values_Id__c = lovlist[3].Id, Project__c=projlist[0].Id,Comments__c='xxx');
        projfeedbacklist.add(projfeed);
        insert projfeedbacklist;        
                
        //start test class method
       	System.Test.startTest(); 
       	
       	//Instantiate the RBI_MyProjects Page
       	PageReference ExportXLStarterPage = Page.RBI_ExporttoXLStarterPg;
       	System.Test.setCurrentPage(ExportXLStarterPage);
       	
       	RBI_ExporttoXLStarterPgHandler ExportHandler = new RBI_ExporttoXLStarterPgHandler();
       	ExportHandler.AcctId = acc[0].Id;
       	ExportHandler.InitialLoad();
       	ExportHandler.WrapperProjList[0].emailCust = true;
       	ExportHandler.sendMail();
       	ExportHandler.closePopup();
       	
       	ExportHandler.SearchVar = 'All';
       	ExportHandler.SelectedProjId = projlist[0].Id;
		ExportHandler.display();
		
		ExportHandler.SearchVar = 'A';
		ExportHandler.display();
		
		ExportHandler.Projectname ='Test Class';
		ExportHandler.Projectcity ='All';
		ExportHandler.SearchProjects();
		
		//test selectoption  GetCity picklist method
		List<selectOption> locale_picklist_options = ExportHandler.getCity();
        System.AssertNotEquals(0, locale_picklist_options.size());
		
		ExportHandler.getproDetails();
		
		ExportHandler.setproDetails(ExportHandler.proDetails);
		ExportHandler.detail();
		
		/* This is for RBI_ProjectExport */
		PageReference ExportPage = Page.RBI_ProjectExport;
		ExportPage.getParameters().put('ProjId' , projlist[0].Id);
		System.Test.setCurrentPage(ExportPage);
		RBI_PrjMultiSheetExcel prjMulti = new RBI_PrjMultiSheetExcel();
		prjMulti.inpprojectId = projlist[0].Id;
		
       	System.Test.stopTest();
    }
}