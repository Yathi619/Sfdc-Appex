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
private class RBI_ProjectsForApprovalTestClass {

    static testMethod void RBI_ProjectForApproval() {
    	//create record for following object and make association between them
		list<User> userlist=[Select id from User where Profile.Name='RBI Customer Portal Manager'];
    	
    	ID ProjRecTypeId = [select Id,name from RecordType where name='Project' and SObjectType='Visit__c'].Id;
    	
    	list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321',
										 Site_Address_City__c='Bangalore', To_Be_Approved__c = false, Launch_Date__c = System.today()-1,OwnerId=userlist[0].Id);
		Project__c proj1 = new Project__c(Project_Name__c='Test1 Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test1',Brochure_Zipcode__c = '123456' , Site_Address_zipcode__c = '654321' ,
										 Site_Address_City__c='Hydrabad', Launch_Date__c = System.today()-5,To_Be_Approved__c = false,OwnerId=userlist[0].Id);								 
		projlist.add(proj);
		projlist.add(proj1);
		insert projlist;
		
		list<Visit__c> vst = new list<Visit__c>();
		Visit__c vis = new Visit__c(Project__c = projlist[0].Id, RecordTypeId = ProjRecTypeId);
		vst.add(vis);
		insert vst;
		//start test class method
       	System.Test.startTest();
       	
       	//Instantiate the RBI_ProjectsForApproval Page
       	PageReference ProjectApprovePage = Page.RBI_ProjectsForApproval;
		System.Test.setCurrentPage(ProjectApprovePage);
		
		//Instantiate the RBI_ProjectsForApproval class
		RBI_ProjectsForApproval projApprove= new RBI_ProjectsForApproval();
		
		//Test Method RBI_ProjectsForApproval class
    	projApprove.InitialLoad();
    	projApprove.display();
    	projApprove.getproDetails();
    	projApprove.setproDetails(projApprove.proDetails);
    	
    	//test searchproject Method
    	projApprove.Projectcity='- All -';
    	projApprove.searchProjects();
    	projApprove.Projectcity='A';
    	projApprove.searchProjects();
    	
    	//test selectoption  GetCity picklist method
    	List<selectOption> locale_picklist_options = projApprove.getCity();
        System.AssertNotEquals(0, locale_picklist_options.size());
        projApprove.detail();
        
        //Instantiate the RBI_ApproveProject Page
        PageReference ProjectAppPage = Page.RBI_ApproveProject;
		System.Test.setCurrentPage(ProjectAppPage);
        
        //test for RBI_ApproveProject class
        ApexPages.StandardController stdCon = new ApexPages.StandardController(proj);
        RBI_ApproveProject AppProj= new RBI_ApproveProject(stdCon);
        
        //test Method for RBI_ApproveProject class
        
        //vis.Project__c = proj1.Id;
       // vis.Visit_Report__c = 'First Technical Report'; 
        AppProj.AprovPrj();
        AppProj.doCancel();
        AppProj.RejectPrj();
        AppProj.displayPopup=false;
        AppProj.closePopup();
        AppProj.displayPopup=true;
        AppProj.showPopup();
        
        //stop test class Method
    	System.Test.stopTest();
		
	}
        
    
}