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
private class RBI_AddInfraPaymentPDRFeedTestClass {

    static testMethod void myUnitTest() {
        
        list<Project__c> projlist = new list<Project__c>();
		Project__c proj = new Project__c(Project_Name__c='Test Class', Land_Area_in_acres__c=30.00, Site_Visit_Date__c = System.Today(),
										 City__c ='test', Brochure_Zipcode__c = '412578', Site_Address_zipcode__c = '123456', 
										 Site_Address_City__c = 'Bangalore', Launch_Date__c = System.today());
		projlist.add(proj);
		insert projlist;
		
		list<Visit__c> vstList = new list<Visit__c>();
    	Visit__c vst = new Visit__c(Status__c = 'Approved', Visit_Report__c = 'Followup Report', Project__c = projlist[0].Id);
    	vstList.add(vst);
    	insert vstList;
    	
        //Start the Test Class
        System.Test.startTest();
        
        //Instantiate the Page of RBI_AddInfraNearProject
        PageReference rbiInfrapage = Page.RBI_AddInfraNearProject;
		System.Test.setCurrentPage(rbiInfrapage);
		Apexpages.currentpage().getparameters().put('ProjId' , projlist[0].Id);
		Apexpages.currentpage().getparameters().put('ProjName' , projlist[0].Project_Name__c);
		Apexpages.currentpage().getparameters().put('VstId' , vstList[0].Id);
		//Instantiate the class which is used in the page above
		RBI_AddInfraNearProject infranearproject = new RBI_AddInfraNearProject();
		infranearproject.ProjectId = Apexpages.currentpage().getparameters().put('ProjId' , projlist[0].Id);
		infranearproject.ProjectName = Apexpages.currentpage().getparameters().put('ProjName' , projlist[0].Project_Name__c);
		//infranearproject.VisitId = Apexpages.currentpage().getparameters().put('VstId' , vstList[0].Id);
		infranearproject.getListofValues();
		infranearproject.WrapperListofval[0].selected=true;
		infranearproject.dosave();
		infranearproject.doCancel();
		
		//Instantiate the class which is used in the page above
		RBI_AddInfraNearProject infranearproject1 = new RBI_AddInfraNearProject();
		infranearproject1.ProjectId=null;
		infranearproject1.VisitId = Apexpages.currentpage().getparameters().put('VstId' , vstList[0].Id);
		infranearproject1.getListofValues();
		infranearproject1.WrapperListofval[0].selected=true;
		infranearproject1.dosave();
		infranearproject1.doCancel();
		
		
		//Instantiate the Page of RBI_AddPaymentPlan
		PageReference rbiAddPayPlan = Page.RBI_AddPaymentPlan;
		System.Test.setCurrentPage(rbiAddPayPlan);
		Apexpages.currentpage().getparameters().put('ProjId' , projlist[0].Id);
		Apexpages.currentpage().getparameters().put('ProjName' , projlist[0].Project_Name__c);
		
		//Instantiate the class which is used in the page above
		RBI_AddPaymentPlan rbipayplan = new RBI_AddPaymentPlan();
		rbipayplan.ProjectId = Apexpages.currentpage().getparameters().put('ProjId' , projlist[0].Id);
		rbipayplan.ProjectName = Apexpages.currentpage().getparameters().put('ProjName' , projlist[0].Project_Name__c);
		rbipayplan.getListofValues();
		rbipayplan.WrapperListofval[0].selected=true;
		rbipayplan.dosave();
		rbipayplan.doCancel();
		
		//Instantiate the Page of RBI_AddPDRList
		PageReference rbiAddPDR = Page.RBI_AddPDRList;
		System.Test.setCurrentPage(rbiAddPDR);
		Apexpages.currentpage().getparameters().put('ProjId' , projlist[0].Id);
		Apexpages.currentpage().getparameters().put('VisId' , vstList[0].Id);
		
		//Instantiate the class which is used in the page above
		RBI_AddPDRList addPDR = new RBI_AddPDRList();
		addPDR.ProjectId = Apexpages.currentpage().getparameters().put('ProjId' , projlist[0].Id);
		addPDR.VisitId = Apexpages.currentpage().getparameters().put('VisId' , vstList[0].Id);
		addPDR.getListofValues();
		addPDR.dosave();
		addPDR.doCancel();
		
		//Instantiate the Page of RBI_AddProjectFeedback
		PageReference rbiProjFeed = Page.RBI_AddProjectFeedback;
		System.Test.setCurrentPage(rbiProjFeed);
		Apexpages.currentpage().getparameters().put('ProjId' , projlist[0].Id);
		Apexpages.currentpage().getparameters().put('ProjName' , projlist[0].Project_Name__c);
		//Apexpages.currentpage().getparameters().put('VstId' , projlist[0].Project_Name__c);
		
		//Instantiate the class which is used in the page above
		RBI_AddProjectFeedback rbiProjFeedback = new RBI_AddProjectFeedback();
		rbiProjFeedback.ProjectId = Apexpages.currentpage().getparameters().put('ProjId' , projlist[0].Id);
		rbiProjFeedback.ProjectName = Apexpages.currentpage().getparameters().put('ProjName' , projlist[0].Project_Name__c);
		//rbiProjFeedback.VisitId = Apexpages.currentpage().getparameters().put('VstId' , vstList[0].Id);
		rbiProjFeedback.getListofValues();
		rbiProjFeedback.WrapperListofval[0].selected=true;
		rbiProjFeedback.dosave();
		rbiProjFeedback.doCancel();
		Apexpages.currentpage().getparameters().put('VstId' , vstList[0].Id);
		RBI_AddProjectFeedback rbiProjFeedback1 = new RBI_AddProjectFeedback();
		rbiProjFeedback1.ProjectId=null;
		rbiProjFeedback1.VisitId = Apexpages.currentpage().getparameters().put('VstId' , vstList[0].Id);
		rbiProjFeedback1.getListofValues();
		rbiProjFeedback1.WrapperListofval[0].selected=true;
		rbiProjFeedback1.dosave();
		rbiProjFeedback1.doCancel();
		
		
		
		//Stop the Test Class
		System.Test.stopTest();
    }
}