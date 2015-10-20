@isTest
private class TestClassCandidJobReview {

	static testMethod void myUnitTest() {
    
  
       
       system.test.startTest();
       Candidate__c can=new Candidate__c();
       
       Job_Application__c job=new Job_Application__c();
       list <Job_Application__c> joblst=new list<Job_Application__c>();
       joblst.add(job);
       insert joblst;
       
       //below code executes without any hassle
       //Job_Application__c job=new Job_Application__c();
       //insert job;
       
       Pagereference addCanPage=page.SetCandidateJobReview;
       System.Test.setCurrentPage(addCanPage);
       
       ApexPages.Standardcontroller stdCon=new ApexPages.Standardcontroller(can);
       SetCandidateJobReviExt extn=new SetCandidateJobReviExt(stdCon);
       
       extn.populateCanReview();
       system.test.stopTest();
       
       
    }
}