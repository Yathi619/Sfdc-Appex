public with sharing class PosJobRevExt {
	public String posId {set;get;}
	public list<Review__c> JobRev {get;set;}


	public PosJobRevExt (Apexpages.Standardcontroller std )
	{
		JobRev=new list<Review__c>();
	
	}
	public void PopulatePosJobRev()
	{
		JobRev=[select Id,Name,Cost_Of_Review__c,Rating__c from Review__c where Job_Application_Number__c=: posId];
		System.debug('AAA' + posId);
		
	}

}