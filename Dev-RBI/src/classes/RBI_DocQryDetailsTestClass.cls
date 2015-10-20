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
private class RBI_DocQryDetailsTestClass {

    static testMethod void DocQryDetails() {
    	
    	list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '412578', Site_Address_zipcode__c = '123456', 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
		projlist.add(proj);
		insert projlist;
        
        list<Visit__c> vstList = new list<Visit__c>();
    	Visit__c vst = new Visit__c(Status__c = 'Approved', Visit_Report__c = 'First Technical Report', Exception__c = true, Project__c = projlist[0].Id);
    	vstList.add(vst);
    	insert vstList;
        
        list<Project_Document_Status__c> prjDoc = new list<Project_Document_Status__c>();
        Project_Document_Status__c prjDocStat = new Project_Document_Status__c(Date_of_Approval__c = System.today(), Provided_By_Bank__c = 'Yes',
        										Visit__c = vstList[0].Id);
        prjDoc.add(prjDocStat);
        insert prjDoc;
        
        list<Query__c> query = new list<Query__c>();
        Query__c qry = new Query__c(Project_Document_Status__c = prjDoc[0].Id, Query_Description__c = 'TestDescription', Visit__c = vstList[0].Id);
        query.add(qry);
        insert query;
        
        
         //start test class method
       	System.Test.startTest();
        
       	//Instantiate the RBI_VisitDetails
		PageReference rbiDocQry = Page.RBI_VisitDetails;
		System.Test.setCurrentPage(rbiDocQry);
		
		//Instantiate the class which is used in the page above
		Apexpages.currentpage().getparameters().put('Id' ,vstList[0].Id);
		ApexPages.StandardController stdCon = new ApexPages.StandardController(vst);
		RBI_DocQryDetails DocQry = new RBI_DocQryDetails(stdCon);
		DocQry.allQryList = prjDoc;
		DocQry.selectRow();
		DocQry.docId = prjDoc[0].Id;
		String qId = query[0].Id;
		DocQry.getqueryList(qId);
		
		//Stop Test Class
		System.Test.stopTest();
    }
}