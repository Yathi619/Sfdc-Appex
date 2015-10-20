public with sharing class secondExtension {

private final Job_Application__c Job;
public list<Review__c> Rev {get;set;}

public secondExtension(ApexPages.StandardController std)
{
	this.Job=(Job_Application__c)std.getRecord();
	Rev=new list<Review__c>();
	populateReview();
	
}
public void populateReview()
{
	Rev=[select id,name,Rating__c,Review_Score__c from Review__c where Job_Application_Number__c=:Job.id and Rating__c >= 5 ];
	
	
	
}


}