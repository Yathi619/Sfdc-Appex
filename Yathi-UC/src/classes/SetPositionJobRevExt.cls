public with sharing class SetPositionJobRevExt {

public list<Position__c> pos{get;set;}
public string pid{get;set;}
public list <Job_Application__c> job;
public set <string> jid{get;set;}
public list <Review__c> rev{get;set;}

public SetPositionJobRevExt( Apexpages.Standardcontroller std)
	{
		
		pos=new list <Position__c>();
		pos=[select Name,Id from Position__c];
		
	 
	}
	public void populateReview() 
	{
		system.debug('positionid' +pid); 
		jid = new set<string>(); 
		job=new list<Job_Application__c>();
		rev=new list<Review__c>();
		
	/* job contains the list of all fields thats queried...in the above query only id is retrieved */
		job=[select id from Job_Application__c where Position__c=:pid];
	
	/*  variable 'j' must be of the same primitive or sObject type as list_or_set.    */
	/*When executing this type of for loop, the Apex runtime engine assigns variable to each
	 element in list_or_set, and runs the code_block for each value. */
		
		for(Job_Application__c j:job){
			jid.add(j.id);
		}
		rev=[select id,name,Rating__c from Review__c where Job_Application_Number__c in :jid];
	}
	
}