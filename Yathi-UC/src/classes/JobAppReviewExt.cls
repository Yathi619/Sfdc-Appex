public with sharing class JobAppReviewExt {

public Job_Application__c job;
public list <Review__c> rev {get;set;}

public JobAppReviewExt(ApexPages.StandardController std )
{
	this.job=(Job_Application__c) std.getRecord();
	rev=new list<Review__c>();
	populateJobReview();
    	
}
public void populateJobReview()
{
Rev=[select id,name,Rating__c,Review_Score__c from Review__c where Job_Application_Number__c=:job.id];

}

}