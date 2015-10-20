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
private class RBI_LaunchedProjectsTestClass {

   static testMethod void RBI_LaunchedProjects() {
        //Create And Insert Data
        ID  CusRecType = [SELECT Id FROM RecordType WHERE Name = 'Customer'].Id;
        
        list<Account> acc = new list<Account>();
       	Account Acnt = new Account(Name = 'TestAccount', BillingStreet = 'TestStreet', BillingCity = 'Hyderabad', BillingState = 'AP', BillingCountry = 'India',
       								BillingPostalCode = '123456', Phone = '124567', Type='Customer',RecordTypeId = CusRecType );
       	acc.add(Acnt);
       	insert acc;
        
        list<Project__c> projlist = new list<Project__c>();
        Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
                                         City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' ,To_Be_Approved__c = true, 
                                         Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
        Project__c proj1 = new Project__c(Project_Name__c='Test1 Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
                                     	 City__c ='test1', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' , 
                                     	 Site_Address_City__c = 'Mumbai', Launch_Date__c = System.today()+1);    
                              
        projlist.add(proj);
        projlist.add(proj1);
        insert projlist;
        
        list<Customer_Projects__c> customerProjectlist = new list<Customer_Projects__c>();
        Customer_Projects__c cp = new Customer_Projects__c(Project_Id__c = projlist[0].Id,AccountId__c= acc[0].id);
        customerProjectlist.add(cp);
        insert customerProjectlist;
        
        list<List_of_Values__c> lovlist = new list<List_of_Values__c>();
        List_of_Values__c lov = new List_of_Values__c(Name='Marker Feedback', Entity_Name__c='Package',Entity_Type__c='Package',
                                Bank_Name__c = 'Axis Bank', Completion_Year__c = 2013, Dwelling_Units__c=12, 
                                Loan_Amount__c=25000, Dev_Project_Address__c='test unit');
        lovlist.add(lov);
        insert lovlist;
        
        list<Project_Cust_Packages__c> projcustpackagelist= new list<Project_Cust_Packages__c>();
        Project_Cust_Packages__c projectCustPackage = new Project_Cust_Packages__c(Customer_Project__c =customerProjectlist[0].Id ,List_of_Values__c=lovlist[0].Id);
        projcustpackagelist.add(projectCustPackage);
        //insert projcustpackagelist;
        
        //Start Test Class
        System.Test.startTest();
        
        //Instantiate the RBI_LaunchedProjects
        PageReference RBI_ProjectLaunchedPage = Page.RBI_LaunchedProjects;
        System.Test.setCurrentPage(RBI_ProjectLaunchedPage);
        
        ////Class instantiating 
        RBI_LaunchedProjects RBILaunched= new  RBI_LaunchedProjects();
        RBILaunched.InitialLoad();
        
        //Test for display method in RBI_LaunchedProjects class
        RBILaunched.SearchVar='All'; 
        RBILaunched.display();
        
        //Test for  else part in display method in RBI_LaunchedProjects class
        RBILaunched.SearchVar='T';   
        RBILaunched.display(); 
        
        //Test for  else part in display method in RBI_LaunchedProjects class
        RBILaunched.SearchVar='t';   
        RBILaunched.display(); 
        
        //Test for getproDetails method
        
        RBILaunched.getproDetails();
        RBILaunched.setproDetails(RBILaunched.proDetails);
        
        //Test for  searchProjects method
        RBILaunched.Projectcity='- All -';
        RBILaunched.searchProjects();
        
        //Test for else part  searchProjects method
        RBILaunched.Projectcity='A';
        RBILaunched.searchProjects();
        
        //test selectoption  GetCity picklist method
        List<selectOption> locale_picklist_options = RBILaunched.getCity();
        System.AssertNotEquals(0, locale_picklist_options.size());
        
        //Test For savelist Method
        RBILaunched.savelist();
       
        //Test For QryDevProfile
        RBILaunched.QryDevProfile() ;
        
        //Test For Displaypopup method
        RBILaunched.displayPopup=false;
        RBILaunched.closePopup();
        RBILaunched.displayPopup=true;
        RBILaunched.showPopup();
        
        //Test for FTRPASIdGenerate And CheckFTR method
        RBILaunched.FTRPASIdGenerate();
        RBILaunched.CheckFTR();
        
       	//Test for GoogleMap popup
       	RBILaunched.displayPopupforPrjMap=true;
       	RBILaunched.showPopupforPrjMap();
       	RBILaunched.displayPopupforPrjMap=false;
       	RBILaunched.closePopupforPrjMap();
        
        //stop the Test class
        System.Test.stopTest();
    }
}