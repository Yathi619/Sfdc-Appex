public with sharing class SetCandidateJobReviExt {

public list <Candidate__c> can{get;set;}
public string canid{get;set;}
public list <Job_Application__c> job{get;set;}
public list <Review__c> rev{get;set;}
public set <string> jid;

public SetCandidateJobReviExt( Apexpages.Standardcontroller std)
	{
     can=new list<Candidate__c>();
	 can=[select id,Name,Full_Name__c from Candidate__c];
	}
	public void populateCanReview()
	{
		jid=new set<String>();
		rev=new list<Review__c>();
		
		job=new list <Job_Application__c>();
		job=[select id,name from Job_Application__c where Candidate__c=: canid];
		
		for(Job_Application__c j : job)
		jid.add(j.id);
		
		rev=[select id,name from Review__c where Job_Application_Number__c in :jid];
		
		
	}
    
}