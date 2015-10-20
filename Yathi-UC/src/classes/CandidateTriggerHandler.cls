public with sharing class CandidateTriggerHandler {

	public void onafterinsert(list <Candidate__c> candlist)
	{
		Job_Application__c job =new Job_Application__c();
		List<Job_Application__c> joblst=new List<Job_Application__c>();
		for(Candidate__c ca:candlist)
		{
			if(ca.CreateJobApplication__c == true)
			{
				job=new Job_Application__c(Cover_Letter__c='Demo Testing', Candidate__c=ca.id);
				joblst.add(job);
			}
		}
		if(joblst!=null && joblst.size()>0)
		insert joblst;
	}


}